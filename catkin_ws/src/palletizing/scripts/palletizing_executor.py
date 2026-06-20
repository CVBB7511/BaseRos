#!/usr/bin/env python3
"""Simplified palletizing executor.

Flow:
  1. Navigate to source table.
  2. Detect objects and choose the safest target.
  3. Transform the selected grasp point to /map for a stable absolute record,
     then transform it back to the current base frame for grab_action.
  4. Grab, raise arm to the safe height, back up only until the arm clears the table edge.
  5. Navigate to destination table.
  6. Place in the configured destination zone, raise arm, back up only until the arm clears the table edge.
  7. Repeat until no objects remain.
"""

import math
import os
import threading
import time

import actionlib
import rospkg
import rospy
import tf
import yaml
from geometry_msgs.msg import PointStamped, Pose, Twist
from move_base_msgs.msg import MoveBaseAction, MoveBaseGoal
from palletizing.msg import PalletizingStats
from palletizing.srv import MarkZone, MarkZoneResponse
from palletizing.srv import StartTask, StartTaskResponse
from palletizing_detection import ObjectDetectionMixin
from sensor_msgs.msg import JointState
from sound_play.msg import SoundRequest
from std_msgs.msg import String
from wpb_home_behaviors.msg import Coord


class SimpleGridStacking:
    """Small destination-table grid, laid out in map coordinates."""

    def __init__(self, table_x, table_y, table_z, approach_yaw,
                 grid_cols=2, grid_rows=2, spacing_x=0.20,
                 spacing_y=0.17, depth_retreat=0.06):
        self.table_x = table_x
        self.table_y = table_y
        self.table_z = table_z
        self.grid_cols = grid_cols
        self.grid_rows = grid_rows
        self.spacing_x = spacing_x
        self.spacing_y = spacing_y
        self.depth_retreat = depth_retreat
        self.depth_x = math.cos(approach_yaw)
        self.depth_y = math.sin(approach_yaw)
        self.side_x = -math.sin(approach_yaw)
        self.side_y = math.cos(approach_yaw)
        self.current_index = 0
        self.current_layer = 0
        self.cell_heights = []

    def get_place_pose(self, object_height):
        col = self.current_index % self.grid_cols
        row = self.current_index // self.grid_cols
        side_offset = -(self.grid_cols - 1) * self.spacing_x / 2.0 + col * self.spacing_x
        depth_offset = ((self.grid_rows - 1) * self.spacing_y / 2.0
                        - row * self.spacing_y
                        - self.depth_retreat)
        x = self.table_x + self.side_x * side_offset + self.depth_x * depth_offset
        y = self.table_y + self.side_y * side_offset + self.depth_y * depth_offset
        cell_idx = self.current_index
        if cell_idx >= len(self.cell_heights):
            self.cell_heights.append(self.table_z)
        z = self.cell_heights[cell_idx]
        return x, y, z

    def mark_placed(self, object_height):
        cell_idx = self.current_index
        if cell_idx >= len(self.cell_heights):
            self.cell_heights.append(self.table_z)
        self.cell_heights[cell_idx] += object_height
        self.current_index += 1
        if self.current_index >= self.grid_cols * self.grid_rows:
            self.current_index = 0
            self.current_layer += 1


class PalletizingExecutor(ObjectDetectionMixin):
    """Simplified executor that follows scripts/简化流程.txt."""

    # PCL prism filter clips points below the table; objects.z is close to
    # actual_bottom + 0.03 in this project.
    PRISM_Z_OFFSET = 0.03

    def __init__(self):
        rospy.init_node('palletizing_executor')

        self.source_table_x = rospy.get_param('~source_table_x', -1.5)
        self.source_table_y = rospy.get_param('~source_table_y', 0.0)
        self.source_table_z = rospy.get_param('~source_table_z', 0.75)
        self.grab_table_height = rospy.get_param('~grab_table_height', 0.75)
        self.dest_table_x = rospy.get_param('~dest_table_x', 1.5)
        self.dest_table_y = rospy.get_param('~dest_table_y', 0.0)
        self.dest_table_z = rospy.get_param('~dest_table_z', 0.75)
        self.source_table_yaw = rospy.get_param('~source_table_yaw', 0.0)
        self.dest_table_yaw = rospy.get_param('~dest_table_yaw', math.pi)
        self.source_table_width = rospy.get_param('~source_table_width', 0.5)
        self.dest_table_width = rospy.get_param('~dest_table_width', 0.5)
        self.source_table_length = rospy.get_param('~source_table_length', 1.0)
        self.dest_table_length = rospy.get_param('~dest_table_length', 1.0)

        self.source_approach_yaw = self._derive_approach_yaw(self.source_table_yaw)
        self.dest_approach_yaw = self._derive_approach_yaw(self.dest_table_yaw)

        self.grid_cols = rospy.get_param('~grid_cols', 2)
        self.grid_rows = rospy.get_param('~grid_rows', 2)
        self.spacing_x = rospy.get_param('~spacing_x', 0.20)
        self.spacing_y = rospy.get_param('~spacing_y', 0.17)
        self.zone_separation_y = rospy.get_param('~zone_separation_y', 0.45)
        self.place_depth_retreat = rospy.get_param('~place_depth_retreat', 0.06)

        self.cube_height = rospy.get_param('~cube_height', 0.06)
        self.hard_cube_height = rospy.get_param('~hard_cube_height', 0.10)
        self.soft_cube_height = rospy.get_param('~soft_cube_height', 0.15)
        self.sphere_height = rospy.get_param('~sphere_height', 0.15)
        self.soft_place_offset = rospy.get_param('~soft_place_offset', 0.005)
        self.place_stack_clearance = rospy.get_param('~place_stack_clearance', 0.0)

        self.safe_lift_height = rospy.get_param('~safe_lift_height', 0.80)
        self.safe_gripper_open = rospy.get_param('~safe_gripper_open', 0.15)
        self.detect_lift_height = rospy.get_param('~detect_lift_height', 0.0)
        self.detect_gripper_open = rospy.get_param('~detect_gripper_open', self.safe_gripper_open)
        # Retract while navigating back so the arm is already in the
        # detection pose when the robot reaches the source table.
        self.retract_lift_height = rospy.get_param(
            '~retract_lift_height', self.detect_lift_height)
        self.back_distance = rospy.get_param('~back_distance', 0.50)
        self.arm_reach_distance = rospy.get_param('~arm_reach_distance', 0.50)
        self.arm_exit_margin = rospy.get_param('~arm_exit_margin', 0.10)
        self.min_table_exit_back_distance = rospy.get_param('~min_table_exit_back_distance', 0.02)
        self.back_speed = rospy.get_param('~back_speed', -0.18)
        self.back_period = rospy.get_param('~back_period', 0.10)

        self.approach_offset = rospy.get_param('~approach_offset', 0.70)
        self.place_approach_offset = rospy.get_param('~place_approach_offset', 0.70)
        self.table_half_depth = rospy.get_param('~table_half_depth', 0.25)

        self.nav_timeout = rospy.get_param('~nav_timeout', 120.0)
        self.nav_accept_xy_tolerance = rospy.get_param('~nav_accept_xy_tolerance', 0.05)
        self.nav_accept_yaw_tolerance = rospy.get_param('~nav_accept_yaw_tolerance', 0.15)
        self.robot_settle_time = rospy.get_param('~robot_settle_time', 0.40)
        self._init_object_detection()
        self.max_direct_grab_y = rospy.get_param('~max_direct_grab_y', 0.15)
        self.action_poll_period = rospy.get_param('~action_poll_period', 0.20)
        self.place_timeout = rospy.get_param('~place_timeout', 120.0)
        self.nav_release_delay = rospy.get_param('~nav_release_delay', 0.15)
        self.nav_stop_publish_count = rospy.get_param('~nav_stop_publish_count', 3)
        self.nav_stop_publish_period = rospy.get_param('~nav_stop_publish_period', 0.05)
        self.arm_publish_count = rospy.get_param('~arm_publish_count', 3)
        self.arm_publish_period = rospy.get_param('~arm_publish_period', 0.10)

        self.object_frame = rospy.get_param('~object_frame', '/base_footprint')
        self.action_frame = rospy.get_param('~action_frame', self.object_frame)
        self.zones_file = rospy.get_param('~zones_file', self._default_zones_file())
        self._load_saved_zones()

        self.gripper_values = {
            'hard_cube': rospy.get_param('~gripper_hard_cube', 0.032),
            'soft_cube': rospy.get_param('~gripper_soft_cube', 0.115),
            'hard_sphere': rospy.get_param('~gripper_hard_sphere', 0.028),
            'soft_sphere': rospy.get_param('~gripper_soft_sphere', 0.040),
        }
        self.gripper_open_values = {
            'hard_cube': rospy.get_param('~gripper_open_hard_cube', 0.16),
            'soft_cube': rospy.get_param('~gripper_open_soft_cube', 0.22),
            'hard_sphere': rospy.get_param('~gripper_open_hard_sphere', 0.16),
            'soft_sphere': rospy.get_param('~gripper_open_soft_sphere', 0.20),
        }

        self.behavior_pub = rospy.Publisher('/wpb_home/behaviors', String, queue_size=10)
        self.grab_action_pub = rospy.Publisher('/wpb_home/grab_action', Pose, queue_size=10)
        self.place_pub = rospy.Publisher('/wpb_home/place_action', Pose, queue_size=10)
        self.cmd_vel_pub = rospy.Publisher('/cmd_vel', Twist, queue_size=10)
        self.mani_ctrl_pub = rospy.Publisher('/wpb_home/mani_ctrl', JointState, queue_size=10)
        self.stats_pub = rospy.Publisher('/palletizing/stats', PalletizingStats, queue_size=10)
        self.tts_pub = rospy.Publisher('/robotsound', SoundRequest, queue_size=5)

        self.state = 'IDLE'
        self.grab_done = False
        self.place_done = False
        self.grab_feedback = ''
        self.place_feedback = ''
        self.place_command_time = 0.0
        self.objects_processed = 0
        self.objects_succeeded = 0
        self.objects_failed = 0
        self.objects_total = 0
        self.current_object_type = ''
        self.task_start_time = 0.0
        self.last_cycle_start = 0.0
        self.cycle_times = []

        rospy.Subscriber('/wpb_home/objects_3d', Coord, self._objects_callback)
        rospy.Subscriber('/wpb_home/grab_result', String, self._grab_result_callback)
        rospy.Subscriber('/wpb_home/place_result', String, self._place_result_callback)

        self.move_base_client = actionlib.SimpleActionClient('move_base', MoveBaseAction)
        rospy.loginfo("Waiting for move_base action server...")
        if self.move_base_client.wait_for_server(rospy.Duration(10.0)):
            rospy.loginfo("move_base action server connected")
        else:
            rospy.logwarn("move_base action server not available yet")

        self.tf_listener = tf.TransformListener()
        self.zones = self._create_zones()

        rospy.Service('/palletizing/mark_zone', MarkZone, self._mark_zone)
        rospy.Service('/palletizing/start', StartTask, self._start_callback)
        self.stats_timer = rospy.Timer(rospy.Duration(1.0), self._publish_stats_timer)
        rospy.loginfo("Simplified palletizing executor ready")

    @staticmethod
    def _derive_approach_yaw(table_yaw):
        yaw = table_yaw + math.pi
        return math.atan2(math.sin(yaw), math.cos(yaw))

    @staticmethod
    def _angle_diff(a, b):
        return math.atan2(math.sin(a - b), math.cos(a - b))

    def _default_zones_file(self):
        try:
            pkg_path = rospkg.RosPack().get_path('palletizing')
            project_root = os.path.abspath(os.path.join(pkg_path, '..', '..', '..'))
            return os.path.join(project_root, 'zones.yaml')
        except Exception:
            return os.path.join(os.path.expanduser('~'), 'waterjet', 'zones.yaml')

    def _load_zones_file(self):
        try:
            if os.path.exists(self.zones_file):
                with open(self.zones_file, 'r') as f:
                    return yaml.safe_load(f) or {}
        except Exception as e:
            rospy.logwarn("Failed to load zones file %s: %s", self.zones_file, e)
        return {}

    def _save_zones_file(self, data):
        try:
            os.makedirs(os.path.dirname(self.zones_file), exist_ok=True)
            with open(self.zones_file, 'w') as f:
                yaml.safe_dump(data, f)
            return True
        except Exception as e:
            rospy.logerr("Failed to save zones file %s: %s", self.zones_file, e)
            return False

    def _load_saved_zones(self):
        saved = self._load_zones_file()
        if not saved:
            return
        self.source_table_x = saved.get('source_x', self.source_table_x)
        self.source_table_y = saved.get('source_y', self.source_table_y)
        self.source_table_z = saved.get('source_z', self.source_table_z)
        self.dest_table_x = saved.get('dest_x', self.dest_table_x)
        self.dest_table_y = saved.get('dest_y', self.dest_table_y)
        self.dest_table_z = saved.get('dest_z', self.dest_table_z)
        self.source_table_yaw = saved.get('source_yaw', self.source_table_yaw)
        self.dest_table_yaw = saved.get('dest_yaw', self.dest_table_yaw)
        self.source_table_width = saved.get('source_width', self.source_table_width)
        self.dest_table_width = saved.get('dest_width', self.dest_table_width)
        self.source_table_length = saved.get('source_length', self.source_table_length)
        self.dest_table_length = saved.get('dest_length', self.dest_table_length)
        self.source_approach_yaw = self._derive_approach_yaw(self.source_table_yaw)
        self.dest_approach_yaw = self._derive_approach_yaw(self.dest_table_yaw)
        rospy.loginfo("Loaded saved table zones from %s", self.zones_file)

    def _mark_zone(self, req):
        saved = self._load_zones_file()
        length = req.length if req.length > 0.01 else 1.0
        width = req.width if req.width > 0.01 else 0.5
        if req.zone_name == 'source':
            prefix = 'source'
            self.source_table_x = req.x
            self.source_table_y = req.y
            self.source_table_z = req.z
            self.source_table_yaw = req.yaw
            self.source_table_length = length
            self.source_table_width = width
            self.source_approach_yaw = self._derive_approach_yaw(req.yaw)
        elif req.zone_name == 'dest':
            prefix = 'dest'
            self.dest_table_x = req.x
            self.dest_table_y = req.y
            self.dest_table_z = req.z
            self.dest_table_yaw = req.yaw
            self.dest_table_length = length
            self.dest_table_width = width
            self.dest_approach_yaw = self._derive_approach_yaw(req.yaw)
        else:
            return MarkZoneResponse(success=False)

        saved[prefix + '_x'] = req.x
        saved[prefix + '_y'] = req.y
        saved[prefix + '_z'] = req.z
        saved[prefix + '_yaw'] = req.yaw
        saved[prefix + '_length'] = length
        saved[prefix + '_width'] = width
        ok = self._save_zones_file(saved)
        self.zones = self._create_zones()
        rospy.loginfo("Marked %s table: %.3f %.3f %.3f yaw=%.1f",
                      req.zone_name, req.x, req.y, req.z, math.degrees(req.yaw))
        return MarkZoneResponse(success=ok)

    def _create_zones(self):
        zones = {}
        side_x = -math.sin(self.dest_approach_yaw)
        side_y = math.cos(self.dest_approach_yaw)
        offsets = {'hard': self.zone_separation_y / 2.0,
                   'soft': -self.zone_separation_y / 2.0}
        for name, side_offset in offsets.items():
            zones[name] = SimpleGridStacking(
                self.dest_table_x + side_x * side_offset,
                self.dest_table_y + side_y * side_offset,
                self.dest_table_z,
                self.dest_approach_yaw,
                self.grid_cols,
                self.grid_rows,
                self.spacing_x,
                self.spacing_y,
                self.place_depth_retreat)
        return zones

    def _on_detection_message(self, msg):
        self.objects_total = len(msg.name)

    def _grab_result_callback(self, msg):
        self.grab_feedback = msg.data
        rospy.loginfo("[grab_result] %s", msg.data)
        if msg.data in ('done', 'failed'):
            self.grab_done = True

    def _place_result_callback(self, msg):
        if msg.data != self.place_feedback:
            rospy.loginfo("[place_result] %s", msg.data)
        self.place_feedback = msg.data
        if msg.data == 'done' and time.time() - self.place_command_time > 0.5:
            self.place_done = True

    def _start_callback(self, _req):
        if self.state not in ('IDLE', 'DONE'):
            return StartTaskResponse(
                success=False,
                message="Task already running (state: %s)" % self.state)
        self.state = 'STARTING'
        threading.Thread(target=self.run, daemon=True).start()
        return StartTaskResponse(success=True, message="Simplified palletizing started")

    def _get_object_height(self, obj_type):
        if obj_type == 'hard_cube':
            return self.hard_cube_height
        if obj_type == 'soft_cube':
            return self.soft_cube_height
        if 'sphere' in obj_type:
            return self.sphere_height
        return self.cube_height

    def _object_type(self, objects, idx, default='hard_cube'):
        types = getattr(objects, 'type', [])
        if idx < len(types) and types[idx]:
            raw_type = types[idx]
            if raw_type in ('10cm_cube', 'hard_cube'):
                return 'hard_cube'
            if raw_type in ('15cm_cube', 'soft_cube'):
                return 'soft_cube'
            return raw_type
        return default

    def _zone_for_type(self, obj_type):
        return self.zones['soft'] if 'soft' in obj_type else self.zones['hard']

    def _material_name(self, obj_type):
        return 'soft' if 'soft' in obj_type else 'hard'

    def _estimate_half_size(self, obj_type):
        return self._get_object_height(obj_type) / 2.0

    def _compute_collision_risk(self, objects):
        n = len(objects.name)
        half = []
        cx = []
        cy = []
        cz = []
        edge_x = []
        z_top = []
        z_bot = []
        for i in range(n):
            obj_type = self._object_type(objects, i)
            hsize = self._estimate_half_size(obj_type)
            half.append(hsize)
            ex = objects.x[i] if i < len(objects.x) else 999.0
            y = objects.y[i] if i < len(objects.y) else 0.0
            edge_x.append(ex)
            cx.append(ex - hsize)
            cy.append(y)
            z_bot.append(self.grab_table_height)
            z_top.append(self.grab_table_height + 2.0 * hsize)
            cz.append(self.grab_table_height + hsize)

        gripper_half = 0.04
        arm_body_h = 0.05
        arm_body_w = 0.06
        layer_tol = 0.03
        blocked_penalty = 100.0
        risk = [0.0] * n
        blocked = [False] * n
        arm_blocked = [False] * n
        arm_blockers = [set() for _ in range(n)]
        y_nbrs = [0] * n

        for i in range(n):
            for j in range(n):
                if i == j:
                    continue
                if abs(cz[i] - cz[j]) > (half[i] + half[j] + layer_tol):
                    continue
                dx = abs(cx[i] - cx[j])
                dy = abs(cy[i] - cy[j])
                if dx < (half[i] + half[j]) and edge_x[j] < edge_x[i]:
                    blocked[i] = True

                y_clear = dy - (half[i] + half[j])
                if y_clear < gripper_half:
                    y_nbrs[i] += 1
                    risk[i] += 1.0 + max(0.0, gripper_half - y_clear) * 20.0

                arm_top_i = cz[i] + arm_body_h
                arm_top_j = cz[j] + arm_body_h
                y_overlap = dy < (arm_body_w + max(half[i], half[j]))
                z_overlap_ij = z_bot[j] < arm_top_i and z_top[j] > cz[i]
                z_overlap_ji = z_bot[i] < arm_top_j and z_top[i] > cz[j]
                if edge_x[j] > edge_x[i]:
                    if z_overlap_ij and y_overlap:
                        arm_blocked[i] = True
                        risk[i] += 5.0
                    if z_overlap_ji and y_overlap:
                        arm_blocked[j] = True
                        arm_blockers[j].add(i)
                        risk[j] += 8.0

        for i in range(n):
            if blocked[i]:
                risk[i] += blocked_penalty
            if arm_blocked[i]:
                risk[i] += blocked_penalty * 0.5
        return risk, blocked, y_nbrs, arm_blocked, z_top, edge_x, arm_blockers, cx, cy, cz

    def _sort_objects(self, objects):
        n = len(objects.name)
        if n == 0:
            return []
        if n == 1:
            return [0]
        risk, blocked, y_nbrs, arm_blocked, z_arr, x_arr, arm_blockers, cx, cy, cz = \
            self._compute_collision_risk(objects)

        remaining = set(range(n))
        sorted_indices = []
        while remaining:
            safe = [i for i in remaining if not (arm_blockers[i] & remaining)]
            if not safe:
                rospy.logwarn("Circular arm dependency, falling back to risk sort")
                safe = list(remaining)
            # Prefer the object that requires the least correction from the
            # current base pose.  Risk/blocked status must dominate height;
            # otherwise a slightly higher edge object can be picked before a
            # centered, unblocked object and force a large Y correction.
            safe.sort(key=lambda i: (
                abs(cy[i]) > self.max_direct_grab_y,
                risk[i],
                blocked[i],
                arm_blocked[i],
                abs(cy[i]),
                x_arr[i],
                -z_arr[i],
            ))
            best = safe[0]
            sorted_indices.append(best)
            remaining.remove(best)

        rospy.loginfo("Simplified picking order:")
        for rank, idx in enumerate(sorted_indices):
            rospy.loginfo("  %d idx=%d name=%s type=%s cx=%.3f cy=%.3f risk=%.1f blocked=%s arm=%s",
                          rank + 1, idx, objects.name[idx],
                          self._object_type(objects, idx), cx[idx], cy[idx],
                          risk[idx], blocked[idx], arm_blocked[idx])
        return sorted_indices

    def _transform_point(self, x, y, z, from_frame, to_frame):
        point = PointStamped()
        point.header.frame_id = from_frame
        point.header.stamp = rospy.Time(0)
        point.point.x = x
        point.point.y = y
        point.point.z = z
        try:
            self.tf_listener.waitForTransform(
                to_frame, from_frame, rospy.Time(0), rospy.Duration(0.5))
            out = self.tf_listener.transformPoint(to_frame, point)
            return out.point.x, out.point.y, out.point.z
        except (tf.LookupException, tf.ConnectivityException,
                tf.ExtrapolationException, tf.Exception) as e:
            raise RuntimeError("TF transform %s -> %s failed: %s" %
                               (from_frame, to_frame, e))

    def _get_robot_position(self):
        try:
            self.tf_listener.waitForTransform(
                '/map', '/base_link', rospy.Time(0), rospy.Duration(0.5))
            trans, rot = self.tf_listener.lookupTransform('/map', '/base_link', rospy.Time(0))
            yaw = math.atan2(2.0 * (rot[3] * rot[2] + rot[0] * rot[1]),
                             1.0 - 2.0 * (rot[1]**2 + rot[2]**2))
            return trans[0], trans[1], yaw
        except (tf.LookupException, tf.ConnectivityException,
                tf.ExtrapolationException, tf.Exception) as e:
            raise RuntimeError("TF lookup /map -> /base_link failed: %s" % e)

    def _wait_robot_settled(self, duration=None):
        if duration is None:
            duration = self.robot_settle_time
        self._publish_stop()
        if duration > 0.0:
            rospy.sleep(duration)

    def _publish_stop(self):
        stop = Twist()
        for _ in range(self.nav_stop_publish_count):
            self.cmd_vel_pub.publish(stop)
            rospy.sleep(self.nav_stop_publish_period)

    def _raise_arm(self):
        self._set_arm(self.safe_lift_height, self.safe_gripper_open)

    def _prepare_arm_for_detection(self):
        self._set_arm(self.detect_lift_height, self.detect_gripper_open)

    def _raise_arm_keep_grip(self, obj_type):
        self._set_arm(self.safe_lift_height, self._get_gripper_value(obj_type))

    def _retract_arm(self):
        rospy.loginfo("Retracting arm after table exit: lift=%.3f gripper=%.3f",
                      self.retract_lift_height, self.safe_gripper_open)
        self._set_arm(self.retract_lift_height, self.safe_gripper_open)

    def _set_arm(self, lift, gripper):
        cmd = JointState()
        cmd.name = ['lift', 'gripper']
        cmd.position = [lift, gripper]
        cmd.velocity = [0.0, 0.0]
        for _ in range(self.arm_publish_count):
            self.mani_ctrl_pub.publish(cmd)
            rospy.sleep(self.arm_publish_period)

    def _back_up(self, distance=None):
        if distance is None:
            distance = self.back_distance
        if distance <= 0.0:
            self._publish_stop()
            return
        speed = self.back_speed if self.back_speed < 0.0 else -abs(self.back_speed)
        duration = distance / max(abs(speed), 0.01)
        steps = max(1, int(math.ceil(duration / self.back_period)))
        cmd = Twist()
        cmd.linear.x = speed
        rospy.loginfo("Backing up %.2fm at %.2fm/s", distance, speed)
        for _ in range(steps):
            self.cmd_vel_pub.publish(cmd)
            rospy.sleep(self.back_period)
        self._publish_stop()

    def _table_edge_clearance(self, table_x, table_y, table_width, approach_yaw):
        robot_x, robot_y, _ = self._get_robot_position()
        depth_x = math.cos(approach_yaw)
        depth_y = math.sin(approach_yaw)
        center_distance = ((table_x - robot_x) * depth_x +
                           (table_y - robot_y) * depth_y)
        half_depth = table_width / 2.0 if table_width > 0.01 else self.table_half_depth
        return center_distance - half_depth

    def _back_up_until_arm_exits_table(self, table_x, table_y, table_width,
                                       approach_yaw, label):
        required_clearance = self.arm_reach_distance + self.arm_exit_margin
        try:
            current_clearance = self._table_edge_clearance(
                table_x, table_y, table_width, approach_yaw)
        except RuntimeError as e:
            rospy.logwarn("Cannot compute %s table clearance: %s; using fallback back distance %.2fm",
                          label, e, self.back_distance)
            self._back_up(self.back_distance)
            return

        back_distance = required_clearance - current_clearance
        if back_distance <= self.min_table_exit_back_distance:
            rospy.loginfo("%s table cleared: edge clearance %.2fm >= required %.2fm",
                          label, current_clearance, required_clearance)
            self._publish_stop()
            return

        rospy.loginfo("Backing out of %s table: edge clearance %.2fm -> %.2fm, back %.2fm",
                      label, current_clearance, required_clearance, back_distance)
        self._back_up(back_distance)

    def _get_approach_position(self, table_x, table_y, for_place=False):
        if for_place:
            yaw = self.dest_approach_yaw
            half_depth = self.dest_table_width / 2.0 if self.dest_table_width > 0.01 else self.table_half_depth
            distance = half_depth + self.place_approach_offset
        else:
            yaw = self.source_approach_yaw
            half_depth = self.source_table_width / 2.0 if self.source_table_width > 0.01 else self.table_half_depth
            distance = half_depth + self.approach_offset
        return table_x - distance * math.cos(yaw), table_y - distance * math.sin(yaw), yaw

    def _near_nav_goal(self, nav_x, nav_y, nav_yaw):
        try:
            robot_x, robot_y, robot_yaw = self._get_robot_position()
        except RuntimeError as e:
            rospy.logwarn("Cannot verify navigation goal: %s", e)
            return False
        dist = math.hypot(robot_x - nav_x, robot_y - nav_y)
        yaw_err = abs(self._angle_diff(robot_yaw, nav_yaw))
        ok = dist <= self.nav_accept_xy_tolerance and yaw_err <= self.nav_accept_yaw_tolerance
        rospy.loginfo("Nav final error: dist=%.3f yaw=%.1fdeg ok=%s",
                      dist, math.degrees(yaw_err), ok)
        return ok

    def navigate_to_pose(self, nav_x, nav_y, nav_yaw, timeout=None):
        if timeout is None:
            timeout = self.nav_timeout
        self.state = 'NAVIGATING'
        goal = MoveBaseGoal()
        goal.target_pose.header.frame_id = 'map'
        goal.target_pose.header.stamp = rospy.Time.now()
        goal.target_pose.pose.position.x = nav_x
        goal.target_pose.pose.position.y = nav_y
        goal.target_pose.pose.orientation.z = math.sin(nav_yaw / 2.0)
        goal.target_pose.pose.orientation.w = math.cos(nav_yaw / 2.0)
        rospy.loginfo("Navigate to %.3f %.3f yaw=%.1f", nav_x, nav_y, math.degrees(nav_yaw))
        self.move_base_client.send_goal(goal)
        finished = self.move_base_client.wait_for_result(rospy.Duration(timeout))
        if not finished:
            self.move_base_client.cancel_goal()
            rospy.logwarn("Navigation timeout")
            self._publish_stop()
            return False
        state = self.move_base_client.get_state()
        self.move_base_client.cancel_all_goals()
        rospy.sleep(self.nav_release_delay)
        self._publish_stop()
        if state == actionlib.GoalStatus.SUCCEEDED:
            return True
        return self._near_nav_goal(nav_x, nav_y, nav_yaw)

    def navigate_to_table(self, table_x, table_y, for_place=False):
        nav_x, nav_y, nav_yaw = self._get_approach_position(table_x, table_y, for_place)
        return self.navigate_to_pose(nav_x, nav_y, nav_yaw)

    def _get_gripper_value(self, obj_type):
        return self.gripper_values.get(obj_type, 0.035)

    def _get_gripper_open_value(self, obj_type):
        return self.gripper_open_values.get(obj_type, 0.18)

    def grab_object(self, obj_type, x, y, z, timeout=90.0):
        self.state = 'GRABBING'
        self.grab_done = False
        self.grab_feedback = ''
        rospy.set_param('/wpb_home_grab_action/grab/grab_open_value',
                        self._get_gripper_open_value(obj_type))
        rospy.set_param('/wpb_home_grab_action/grab/grab_gripper_value',
                        self._get_gripper_value(obj_type))
        pose = Pose()
        pose.position.x = x
        pose.position.y = y
        pose.position.z = z
        self.grab_action_pub.publish(pose)
        rospy.loginfo("Grab action target base(%.3f, %.3f, %.3f) type=%s", x, y, z, obj_type)
        start = time.time()
        while not self.grab_done:
            if time.time() - start > timeout:
                stop = String()
                stop.data = 'grab stop'
                self.behavior_pub.publish(stop)
                rospy.logwarn("Grab timeout: %s", self.grab_feedback)
                return False
            rospy.sleep(self.action_poll_period)
        return self.grab_feedback != 'failed'

    def place_object(self, x, y, z, obj_type=None, timeout=None):
        if timeout is None:
            timeout = self.place_timeout
        self.state = 'PLACING'
        self.place_done = False
        self.place_feedback = ''
        self.place_command_time = time.time()
        if obj_type:
            rospy.set_param('/wpb_home_place_action/place_hold_gripper_value',
                            self._get_gripper_value(obj_type))
            rospy.set_param('/wpb_home_place_action/place_gripper_value',
                            self._get_gripper_open_value(obj_type))
        pose = Pose()
        pose.position.x = x
        pose.position.y = y
        pose.position.z = z
        pose.orientation.w = 1.0
        self.place_pub.publish(pose)
        rospy.loginfo("Place action target base_xy(%.3f, %.3f), z=%.3f type=%s release=%.3f",
                      x, y, z, obj_type or 'default',
                      self._get_gripper_open_value(obj_type) if obj_type else 0.18)
        start = time.time()
        while not self.place_done:
            if time.time() - start > timeout:
                rospy.logwarn("Place timeout: %s", self.place_feedback)
                self.behavior_pub.publish(String(data='place stop'))
                self._publish_stop()
                return False
            rospy.sleep(self.action_poll_period)
        return True

    def _publish_stats(self):
        stats = PalletizingStats()
        stats.total_objects = self.objects_processed + 1
        stats.success_count = self.objects_succeeded
        stats.fail_count = self.objects_failed
        stats.current_layer = (self.zones['hard'].current_layer +
                               self.zones['soft'].current_layer)
        stats.hard_zone_layers = self.zones['hard'].current_layer
        stats.soft_zone_layers = self.zones['soft'].current_layer
        stats.current_state = self.state
        stats.elapsed_time = time.time() - self.task_start_time if self.task_start_time else 0.0
        total_done = self.objects_succeeded + self.objects_failed
        stats.success_rate = (100.0 * self.objects_succeeded / total_done) if total_done else 0.0
        stats.avg_cycle_time = sum(self.cycle_times) / len(self.cycle_times) if self.cycle_times else 0.0
        self.stats_pub.publish(stats)

    def _publish_stats_timer(self, _event):
        self._publish_stats()

    def _speak(self, text):
        msg = SoundRequest()
        msg.sound = SoundRequest.SAY
        msg.command = SoundRequest.PLAY_ONCE
        msg.volume = 1.0
        msg.arg = text
        self.tts_pub.publish(msg)

    def _selected_grasp_points(self, objects, idx):
        obj_type = self._object_type(objects, idx)
        half = self._estimate_half_size(obj_type)
        edge_x = objects.x[idx] if idx < len(objects.x) else 0.0
        y = objects.y[idx] if idx < len(objects.y) else 0.0
        return obj_type, edge_x - half, y, self.grab_table_height + half

    def run(self):
        rospy.loginfo("Simplified palletizing flow starting")
        rospy.sleep(0.5)
        self.task_start_time = time.time()
        self.objects_processed = 0
        self.objects_succeeded = 0
        self.objects_failed = 0
        self.cycle_times = []

        self._prepare_arm_for_detection()
        if not self.navigate_to_table(self.source_table_x, self.source_table_y, for_place=False):
            rospy.logerr("Failed to reach source table")
            self.state = 'DONE'
            return

        while not rospy.is_shutdown():
            self.last_cycle_start = time.time()
            self._prepare_arm_for_detection()

            if not self.detect_with_retry():
                rospy.loginfo("No objects detected on source table; task complete")
                break

            sorted_indices = self._sort_objects(self.latest_objects)
            if not sorted_indices:
                rospy.loginfo("No sortable objects; task complete")
                break

            pick_idx = sorted_indices[0]
            obj_name = self.latest_objects.name[pick_idx]
            obj_type, grab_x, grab_y, grab_z = self._selected_grasp_points(
                self.latest_objects, pick_idx)
            obj_height = self._get_object_height(obj_type)
            material = self._material_name(obj_type)
            zone = self._zone_for_type(obj_type)
            self.current_object_type = obj_type
            rospy.loginfo("Selected %s idx=%d type=%s local_grab=(%.3f, %.3f, %.3f)",
                          obj_name, pick_idx, obj_type, grab_x, grab_y, grab_z)

            try:
                map_x, map_y, map_z = self._transform_point(
                    grab_x, grab_y, grab_z, self.object_frame, '/map')
                action_x, action_y, action_z = self._transform_point(
                    map_x, map_y, map_z, '/map', self.action_frame)
            except RuntimeError as e:
                rospy.logerr("Cannot transform selected object pose: %s", e)
                self.objects_failed += 1
                self.objects_processed += 1
                self._publish_stats()
                continue

            rospy.loginfo("Selected object absolute map=(%.3f, %.3f, %.3f)", map_x, map_y, map_z)
            self._speak("zhua {} qu".format(material))
            if not self.grab_object(obj_type, action_x, action_y, action_z):
                rospy.logerr("Grab failed for %s", obj_name)
                self.objects_failed += 1
                self.objects_processed += 1
                self.cycle_times.append(time.time() - self.last_cycle_start)
                self._publish_stats()
                continue

            self._raise_arm_keep_grip(obj_type)
            self._back_up_until_arm_exits_table(
                self.source_table_x, self.source_table_y,
                self.source_table_width, self.source_approach_yaw, 'source')

            if not self.navigate_to_table(self.dest_table_x, self.dest_table_y, for_place=True):
                rospy.logerr("Failed to reach destination table")
                self.objects_failed += 1
                self.objects_processed += 1
                self.cycle_times.append(time.time() - self.last_cycle_start)
                self._publish_stats()
                self._raise_arm_keep_grip(obj_type)
                break

            place_map_x, place_map_y, stack_top_z = zone.get_place_pose(obj_height)
            place_z = (stack_top_z + obj_height / 2.0 + self.place_stack_clearance +
                       (self.soft_place_offset if 'soft' in obj_type else 0.0))
            self._wait_robot_settled()
            try:
                place_x, place_y, _ = self._transform_point(
                    place_map_x, place_map_y, place_z, '/map', self.action_frame)
            except RuntimeError as e:
                rospy.logerr("Cannot transform place pose: %s", e)
                self.objects_failed += 1
                self.objects_processed += 1
                self.cycle_times.append(time.time() - self.last_cycle_start)
                self._publish_stats()
                self._raise_arm_keep_grip(obj_type)
                break

            if not self.place_object(place_x, place_y, place_z, obj_type):
                rospy.logerr("Place failed for %s", obj_name)
                self.objects_failed += 1
                self.objects_processed += 1
                self.cycle_times.append(time.time() - self.last_cycle_start)
                self._publish_stats()
                self._raise_arm_keep_grip(obj_type)
                break

            zone.mark_placed(obj_height)
            self.objects_succeeded += 1
            self.objects_processed += 1
            self.cycle_times.append(time.time() - self.last_cycle_start)
            self._publish_stats()
            rospy.loginfo("Placed %s into %s zone layer=%d cell=%d",
                          obj_name, material, zone.current_layer, zone.current_index)

            self._raise_arm()
            self._back_up_until_arm_exits_table(
                self.dest_table_x, self.dest_table_y,
                self.dest_table_width, self.dest_approach_yaw, 'destination')
            self._retract_arm()

            if not self.navigate_to_table(self.source_table_x, self.source_table_y, for_place=False):
                rospy.logerr("Failed to return to source table; stopping")
                break

        self.state = 'DONE'
        self._publish_stats()
        self._speak("ma duo wan cheng, cheng gong {} ge, shi bai {} ge".format(
            self.objects_succeeded, self.objects_failed))
        rospy.loginfo("Simplified palletizing done: success=%d failed=%d",
                      self.objects_succeeded, self.objects_failed)


if __name__ == '__main__':
    try:
        executor = PalletizingExecutor()
        rospy.spin()
    except rospy.ROSInterruptException:
        pass
