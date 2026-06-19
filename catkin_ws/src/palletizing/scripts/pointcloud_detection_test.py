#!/usr/bin/env python3
"""Point-cloud detection test node for source-table experiments.

This node keeps only the source-table observation navigation and the
wpb_home 3D object detection path.  It intentionally does not publish arm,
grab, place, or palletizing commands, so it can be used on a chassis without a
manipulator.

Services:
  /pointcloud_test/start          navigate to the source pose, then detect
  /pointcloud_test/detect_here    detect continuously at the current base pose
  /pointcloud_test/stop_detection stop detection and clear RViz markers

For manual base positioning, run the keyboard velocity controller in another
terminal and call /pointcloud_test/detect_here after the base is stable.
"""

import math
import threading

import actionlib
import rospy
from geometry_msgs.msg import Point, Twist
from move_base_msgs.msg import MoveBaseAction, MoveBaseGoal
from palletizing.srv import StartTask, StartTaskResponse
from palletizing_detection import ObjectDetectionMixin
from std_msgs.msg import String
from visualization_msgs.msg import Marker
from wpb_home_behaviors.msg import Coord


class PointCloudDetectionTest(ObjectDetectionMixin):
    PRISM_Z_OFFSET = 0.03

    def __init__(self):
        rospy.init_node('pointcloud_detection_test')

        self.source_table_x = rospy.get_param('~source_table_x', -1.5)
        self.source_table_y = rospy.get_param('~source_table_y', 0.0)
        self.source_table_yaw = rospy.get_param('~source_table_yaw', 0.0)
        self.source_table_width = rospy.get_param('~source_table_width', 0.5)
        self.table_half_depth = rospy.get_param('~table_half_depth', 0.25)
        self.approach_offset = rospy.get_param('~approach_offset', 0.70)
        self.cube_height = rospy.get_param('~cube_height', 0.06)
        self.hard_cube_height = rospy.get_param('~hard_cube_height', 0.10)
        self.soft_cube_height = rospy.get_param('~soft_cube_height', 0.15)
        self.sphere_height = rospy.get_param('~sphere_height', 0.15)

        self.nav_timeout = rospy.get_param('~nav_timeout', 120.0)
        self.nav_release_delay = rospy.get_param('~nav_release_delay', 0.15)
        self.robot_settle_time = rospy.get_param('~robot_settle_time', 0.40)
        self.navigate_to_source_on_start = rospy.get_param(
            '~navigate_to_source_on_start', True)
        self.require_nav_success = rospy.get_param('~require_nav_success', True)

        self._init_object_detection()
        self.continuous_detection = rospy.get_param('~continuous_detection', True)
        self.continuous_detection_interval = rospy.get_param(
            '~continuous_detection_interval', 0.20)

        self.nav_stop_publish_count = rospy.get_param('~nav_stop_publish_count', 3)
        self.nav_stop_publish_period = rospy.get_param(
            '~nav_stop_publish_period', 0.05)

        self.state = 'IDLE'
        self.run_lock = threading.Lock()
        self.stop_detection_event = threading.Event()

        self.behavior_pub = rospy.Publisher(
            '/wpb_home/behaviors', String, queue_size=10)
        self.cmd_vel_pub = rospy.Publisher('/cmd_vel', Twist, queue_size=10)
        self.fused_marker_pub = rospy.Publisher(
            '/pointcloud_test/fused_marker', Marker, queue_size=20)
        rospy.Subscriber('/wpb_home/objects_3d', Coord, self._objects_callback)

        self.move_base_client = actionlib.SimpleActionClient(
            'move_base', MoveBaseAction)
        rospy.loginfo("Waiting briefly for move_base action server...")
        if self.move_base_client.wait_for_server(rospy.Duration(3.0)):
            rospy.loginfo("move_base action server connected")
        else:
            rospy.logwarn("move_base is not available yet; /detect_here can still be used")

        rospy.Service('/pointcloud_test/start', StartTask, self._start_callback)
        rospy.Service('/pointcloud_test/detect_here', StartTask,
                      self._detect_here_callback)
        rospy.Service('/pointcloud_test/stop_detection', StartTask,
                      self._stop_detection_callback)
        rospy.on_shutdown(self._stop_detector)
        rospy.loginfo(
            "Point-cloud detection test ready (continuous_detection=%s)",
            self.continuous_detection)

    @staticmethod
    def _derive_approach_yaw(table_yaw):
        yaw = table_yaw + math.pi
        return math.atan2(math.sin(yaw), math.cos(yaw))

    def _get_object_height(self, obj_type):
        if obj_type == 'hard_cube':
            return self.hard_cube_height
        if obj_type == 'soft_cube':
            return self.soft_cube_height
        if 'sphere' in obj_type:
            return self.sphere_height
        return self.cube_height

    def _start_callback(self, _req):
        return self._launch_test(self.navigate_to_source_on_start)

    def _detect_here_callback(self, _req):
        return self._launch_test(False)

    def _stop_detection_callback(self, _req):
        with self.run_lock:
            if self.state not in ('DETECTING', 'CONTINUOUS_DETECTION'):
                return StartTaskResponse(
                    success=False,
                    message="Detection is not running (state: %s)" % self.state)
            self.stop_detection_event.set()
        self._stop_detector()
        self._clear_fused_markers()
        return StartTaskResponse(success=True, message="Detection stopped")

    def _launch_test(self, navigate_to_source):
        with self.run_lock:
            if self.state not in ('IDLE', 'DONE'):
                return StartTaskResponse(
                    success=False,
                    message="Test already running (state: %s)" % self.state)
            self.stop_detection_event.clear()
            self.state = 'STARTING'
        thread = threading.Thread(
            target=self.run, args=(navigate_to_source,), daemon=True)
        thread.start()
        mode = "source navigation + detection" if navigate_to_source else "manual-position detection"
        return StartTaskResponse(success=True, message="Started %s" % mode)

    def _publish_detection_command(self, command_text):
        command = String()
        command.data = command_text
        self.behavior_pub.publish(command)
        rospy.loginfo("[%s]", command_text)

    def _stop_detector(self):
        self._publish_detection_command('object_detect stop')

    def _clear_fused_markers(self):
        marker = Marker()
        marker.action = Marker.DELETEALL
        self.fused_marker_pub.publish(marker)

    @staticmethod
    def _box_edge_points(x_min, x_max, y_min, y_max, z_min, z_max):
        corners = [
            (x_min, y_min, z_min), (x_min, y_max, z_min),
            (x_max, y_max, z_min), (x_max, y_min, z_min),
            (x_min, y_min, z_max), (x_min, y_max, z_max),
            (x_max, y_max, z_max), (x_max, y_min, z_max),
        ]
        edges = [
            (0, 1), (1, 2), (2, 3), (3, 0),
            (4, 5), (5, 6), (6, 7), (7, 4),
            (0, 4), (1, 5), (2, 6), (3, 7),
        ]
        points = []
        for start, end in edges:
            points.append(Point(*corners[start]))
            points.append(Point(*corners[end]))
        return points

    def _publish_fused_markers(self, objects):
        self._clear_fused_markers()
        stamp = rospy.Time.now()
        for idx, name in enumerate(objects.name):
            if idx >= len(objects.x) or idx >= len(objects.y) or idx >= len(objects.z):
                continue
            obj_type = objects.type[idx] if idx < len(objects.type) else 'hard_cube'
            default_size = self._get_object_height(obj_type)
            size_x = objects.size_x[idx] if idx < len(objects.size_x) else default_size
            size_y = objects.size_y[idx] if idx < len(objects.size_y) else default_size
            size_z = objects.size_z[idx] if idx < len(objects.size_z) else default_size
            x_max = objects.x[idx]
            x_min = x_max - max(size_x, 0.01)
            y_min = objects.y[idx] - max(size_y, 0.01) / 2.0
            y_max = objects.y[idx] + max(size_y, 0.01) / 2.0
            z_min = objects.z[idx] - self.PRISM_Z_OFFSET
            z_max = z_min + max(size_z, 0.01)

            box = Marker()
            box.header.frame_id = 'base_footprint'
            box.header.stamp = stamp
            box.ns = 'fused_boxes'
            box.id = idx
            box.type = Marker.LINE_LIST
            box.action = Marker.ADD
            box.pose.orientation.w = 1.0
            box.scale.x = 0.008
            box.color.r = 0.0
            box.color.g = 0.9
            box.color.b = 1.0
            box.color.a = 1.0
            box.points = self._box_edge_points(
                x_min, x_max, y_min, y_max, z_min, z_max)
            self.fused_marker_pub.publish(box)

            label = Marker()
            label.header.frame_id = 'base_footprint'
            label.header.stamp = stamp
            label.ns = 'fused_labels'
            label.id = idx
            label.type = Marker.TEXT_VIEW_FACING
            label.action = Marker.ADD
            label.pose.orientation.w = 1.0
            label.pose.position.x = x_max
            label.pose.position.y = objects.y[idx]
            label.pose.position.z = z_max + 0.04
            label.scale.z = 0.05
            label.color.r = 0.0
            label.color.g = 0.9
            label.color.b = 1.0
            label.color.a = 1.0
            label.text = '%s %s' % (name, obj_type)
            self.fused_marker_pub.publish(label)

    def _source_approach_pose(self):
        yaw = self._derive_approach_yaw(self.source_table_yaw)
        half_depth = (
            self.source_table_width / 2.0
            if self.source_table_width > 0.01 else self.table_half_depth)
        distance = half_depth + self.approach_offset
        nav_x = self.source_table_x - distance * math.cos(yaw)
        nav_y = self.source_table_y - distance * math.sin(yaw)
        return nav_x, nav_y, yaw

    def _publish_stop(self):
        stop = Twist()
        for _ in range(self.nav_stop_publish_count):
            self.cmd_vel_pub.publish(stop)
            rospy.sleep(self.nav_stop_publish_period)

    def _wait_robot_settled(self, duration=None):
        if duration is None:
            duration = self.robot_settle_time
        self._publish_stop()
        if duration > 0.0:
            rospy.sleep(duration)

    def _navigate_to_source_desk(self):
        nav_x, nav_y, nav_yaw = self._source_approach_pose()
        self.state = 'NAVIGATING'
        goal = MoveBaseGoal()
        goal.target_pose.header.frame_id = 'map'
        goal.target_pose.header.stamp = rospy.Time.now()
        goal.target_pose.pose.position.x = nav_x
        goal.target_pose.pose.position.y = nav_y
        goal.target_pose.pose.orientation.z = math.sin(nav_yaw / 2.0)
        goal.target_pose.pose.orientation.w = math.cos(nav_yaw / 2.0)
        rospy.loginfo("Navigate to source observation pose: x=%.3f y=%.3f yaw=%.1fdeg",
                      nav_x, nav_y, math.degrees(nav_yaw))
        self.move_base_client.send_goal(goal)
        finished = self.move_base_client.wait_for_result(
            rospy.Duration(self.nav_timeout))
        if not finished:
            self.move_base_client.cancel_goal()
            self._publish_stop()
            rospy.logwarn("Navigation to source observation pose timed out")
            return False

        state = self.move_base_client.get_state()
        self.move_base_client.cancel_all_goals()
        rospy.sleep(self.nav_release_delay)
        self._publish_stop()
        ok = state == actionlib.GoalStatus.SUCCEEDED
        rospy.loginfo("Navigation result: state=%d success=%s", state, ok)
        return ok

    def _on_detection_success(self, attempt, attempts):
        if self.latest_objects is None:
            return

        objects = self.latest_objects
        rospy.loginfo("Detection report attempt %d/%d: stable_objects=%d raw_samples=%d",
                      attempt, attempts, len(objects.name),
                      len(self.detected_object_samples))
        for i, name in enumerate(objects.name):
            obj_type = objects.type[i] if i < len(objects.type) else 'unknown'
            x = objects.x[i] if i < len(objects.x) else 0.0
            y = objects.y[i] if i < len(objects.y) else 0.0
            z = objects.z[i] if i < len(objects.z) else 0.0
            prob = objects.probability[i] if i < len(objects.probability) else 0.0
            sx = objects.size_x[i] if i < len(objects.size_x) else 0.0
            sy = objects.size_y[i] if i < len(objects.size_y) else 0.0
            sz = objects.size_z[i] if i < len(objects.size_z) else 0.0
            rospy.loginfo(
                "  %s type=%s base=(%.3f, %.3f, %.3f) "
                "size=(%.3f, %.3f, %.3f) prob=%.2f",
                name, obj_type, x, y, z, sx, sy, sz, prob)
            if sx > 0.0 or sy > 0.0 or sz > 0.0:
                rospy.loginfo(
                    "    cube_check: fused_size_z=%.3f, "
                    "target candidates are 0.10m or 0.15m",
                    sz)

    def run(self, navigate_to_source):
        rospy.loginfo("Point-cloud detection test starting, navigate_to_source=%s",
                      navigate_to_source)
        rospy.sleep(0.3)
        if navigate_to_source:
            if not self._navigate_to_source_desk():
                if self.require_nav_success:
                    rospy.logerr("Failed to reach source observation pose")
                    self.state = 'DONE'
                    return
                rospy.logwarn("Navigation failed, continuing with current pose")
        else:
            rospy.loginfo("Manual mode: detecting at the current base pose")

        while not rospy.is_shutdown():
            if self.detect_with_retry() and self.latest_objects is not None:
                self._publish_fused_markers(self.latest_objects)
            if not self.continuous_detection or self.stop_detection_event.is_set():
                break
            if self.stop_detection_event.wait(
                    max(0.05, float(self.continuous_detection_interval))):
                break
        self.state = 'DONE'
        rospy.loginfo("Point-cloud detection test finished")


if __name__ == '__main__':
    try:
        node = PointCloudDetectionTest()
        rospy.spin()
    except rospy.ROSInterruptException:
        pass
