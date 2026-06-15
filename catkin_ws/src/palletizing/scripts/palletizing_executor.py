#!/usr/bin/env python3
"""Palletizing Executor - orchestrates pick-transport-place loop for stacking objects."""

import rospy
import os
import time
import math
import tf
import yaml
import threading
import actionlib
from std_msgs.msg import String, Float32
from geometry_msgs.msg import Pose, Twist
from sensor_msgs.msg import JointState
from move_base_msgs.msg import MoveBaseAction, MoveBaseGoal
from wpb_home_behaviors.msg import Coord
from palletizing.msg import PalletizingStats
from palletizing.srv import MarkZone, MarkZoneResponse
from palletizing.srv import StartTask, StartTaskResponse
from sound_play.msg import SoundRequest


class StackingState:
    """Base class for stacking strategies."""

    def __init__(self, table_x, table_y, table_z):
        self.table_x = table_x
        self.table_y = table_y
        self.table_z = table_z

    def get_place_pose(self, object_height=0.06):
        raise NotImplementedError

    def mark_placed(self, object_height=0.06):
        raise NotImplementedError

    @property
    def description(self):
        raise NotImplementedError


class CandidatePointStacking(StackingState):
    """Dynamic candidate-point stacking for mixed-size objects (10cm/15cm).

    Based on docs/候选点法.md. Generates placement candidates from placed-box
    boundaries (right, forward, above), checks constraints, scores by height+distance.
    """

    def __init__(self, table_x, table_y, table_z, grid_cols=2, grid_rows=3,
                 spacing_x=0.18, spacing_y=0.17,
                 zone_half_x=0.50, zone_half_y=0.25, max_height=0.80,
                 horizontal_gap=0.02, vertical_gap=0.01):
        super().__init__(table_x, table_y, table_z)
        self.zone_x_min = table_x - zone_half_x
        self.zone_x_max = table_x + zone_half_x
        self.zone_y_min = table_y - zone_half_y
        self.zone_y_max = table_y + zone_half_y
        self.max_height = max_height
        self.delta = horizontal_gap
        self.delta_z = vertical_gap
        self.placed_boxes = []  # list of (x, y, z, l, w, h)
        self._last_place = None  # (x, y, z) from most recent get_place_pose
        self.current_layer = 0
        self.current_index = 0

    @property
    def description(self):
        return "candidate-point zone %.1fx%.1f" % (
            self.zone_x_max - self.zone_x_min, self.zone_y_max - self.zone_y_min)

    def _box_overlaps(self, x, y, z, l, w, h):
        """Check if box at (x,y,z) with dims (l,w,h) overlaps any placed box."""
        for (bx, by, bz, bl, bw, bh) in self.placed_boxes:
            ox = abs(x - bx) < (l + bl) / 2.0
            oy = abs(y - by) < (w + bw) / 2.0
            oz = abs(z - bz) < (h + bh) / 2.0
            if ox and oy and oz:
                return True
        return False

    def _in_zone(self, x, y, z, l, w, h):
        """Check if box is fully within zone boundaries."""
        return (self.zone_x_min + l / 2.0 <= x <= self.zone_x_max - l / 2.0 and
                self.zone_y_min + w / 2.0 <= y <= self.zone_y_max - w / 2.0 and
                z - h / 2.0 >= self.table_z - 0.01 and
                z + h / 2.0 <= self.max_height)

    def _generate_candidates(self, l, w, h):
        """Generate candidate points from zone origin and placed boxes."""
        candidates = []

        # Initial point: center of zone at table level
        z_init = self.table_z + h / 2.0
        candidates.append((self.table_x, self.table_y, z_init))

        # From each placed box: right, forward, above
        for (bx, by, bz, bl, bw, bh) in self.placed_boxes:
            # Right side
            candidates.append((bx + bl / 2.0 + l / 2.0 + self.delta, by, bz))
            # Forward side
            candidates.append((bx, by + bw / 2.0 + w / 2.0 + self.delta, bz))
            # Above
            candidates.append((bx, by, bz + bh / 2.0 + h / 2.0 + self.delta_z))

        return candidates

    def _score(self, x, y, z, l, w, h):
        """Score a candidate: lower is better.

        Score = distance from zone origin + height penalty.
        Simplification of the full J(p) — sufficient for only 2 object sizes.
        """
        dist = math.hypot(x - self.table_x, y - self.table_y)
        height_norm = (z - self.table_z) / max(self.max_height - self.table_z, 0.01)
        return dist + 0.5 * height_norm

    def get_place_pose(self, object_height=0.06):
        l = w = h = object_height  # cubes

        # Find placement from placed boxes — if stack is empty, use initial position
        if not self.placed_boxes:
            x, y, z = self.table_x, self.table_y, self.table_z + h / 2.0
            self._last_place = (x, y, z)
            self.current_index = 0
            self.current_layer = 1
            return x, y, z

        candidates = self._generate_candidates(l, w, h)

        # Filter: in zone, no overlap
        valid = []
        for (cx, cy, cz) in candidates:
            if not self._in_zone(cx, cy, cz, l, w, h):
                continue
            if self._box_overlaps(cx, cy, cz, l, w, h):
                continue
            score = self._score(cx, cy, cz, l, w, h)
            valid.append((score, cx, cy, cz))

        if not valid:
            # Fallback: place at zone origin, stacked on highest box
            rospy.logwarn("[CandidatePoint] No valid candidates, using origin stack")
            max_z = max(b[2] + b[5] / 2.0 for b in self.placed_boxes)
            cx, cy, cz = self.table_x, self.table_y, max_z + h / 2.0 + self.delta_z
        else:
            valid.sort(key=lambda v: v[0])
            _, cx, cy, cz = valid[0]

        self._last_place = (cx, cy, cz)
        self.current_index = len(self.placed_boxes) + 1
        self.current_layer = int((cz - self.table_z) / max(h, 0.01)) + 1
        return cx, cy, cz

    def mark_placed(self, object_height=0.06):
        l = w = h = object_height
        if self._last_place:
            x, y, z = self._last_place
        else:
            x, y, z = self.table_x, self.table_y, self.table_z + h / 2.0
        self.placed_boxes.append((x, y, z, l, w, h))
        self._last_place = None


class AlignedStacking(StackingState):
    """Grid stacking: each layer aligned with the one below."""

    def __init__(self, table_x, table_y, table_z, grid_cols=2, grid_rows=3,
                 spacing_x=0.15, spacing_y=0.15):
        super().__init__(table_x, table_y, table_z)
        self.grid_cols = grid_cols
        self.grid_rows = grid_rows
        self.spacing_x = spacing_x
        self.spacing_y = spacing_y
        self.current_layer = 0
        self.current_index = 0
        self.layer_heights = []

    @property
    def description(self):
        return "aligned {}x{}".format(self.grid_cols, self.grid_rows)

    def get_place_pose(self, object_height=0.06):
        col = self.current_index % self.grid_cols
        row = self.current_index // self.grid_cols
        x = self.table_x - (self.grid_cols - 1) * self.spacing_x / 2.0 + col * self.spacing_x
        y = self.table_y - (self.grid_rows - 1) * self.spacing_y / 2.0 + row * self.spacing_y
        cell_idx = self.current_index
        if cell_idx >= len(self.layer_heights):
            self.layer_heights.append(self.table_z)
        z = self.layer_heights[cell_idx]
        self.current_index += 1
        if self.current_index >= self.grid_cols * self.grid_rows:
            self.current_index = 0
            self.current_layer += 1
        return x, y, z

    def mark_placed(self, object_height=0.06):
        cell_idx = self.current_index - 1
        if cell_idx < 0:
            cell_idx = self.grid_cols * self.grid_rows - 1
        if cell_idx < len(self.layer_heights):
            self.layer_heights[cell_idx] += object_height


class StaggeredStacking(StackingState):
    """Brick-wall stacking: odd layers offset by half spacing."""

    def __init__(self, table_x, table_y, table_z, grid_cols=2, grid_rows=3,
                 spacing_x=0.15, spacing_y=0.15):
        super().__init__(table_x, table_y, table_z)
        self.grid_cols = grid_cols
        self.grid_rows = grid_rows
        self.spacing_x = spacing_x
        self.spacing_y = spacing_y
        self.current_layer = 0
        self.current_index = 0
        self.layer_heights = []

    @property
    def description(self):
        return "staggered {}x{}".format(self.grid_cols, self.grid_rows)

    def get_place_pose(self, object_height=0.06):
        col = self.current_index % self.grid_cols
        row = self.current_index // self.grid_cols
        offset_x = (self.spacing_x / 2.0) if (self.current_layer % 2 == 1) else 0.0
        x = self.table_x - (self.grid_cols - 1) * self.spacing_x / 2.0 + col * self.spacing_x + offset_x
        y = self.table_y - (self.grid_rows - 1) * self.spacing_y / 2.0 + row * self.spacing_y
        cell_idx = self.current_index
        if cell_idx >= len(self.layer_heights):
            self.layer_heights.append(self.table_z)
        z = self.layer_heights[cell_idx]
        self.current_index += 1
        if self.current_index >= self.grid_cols * self.grid_rows:
            self.current_index = 0
            self.current_layer += 1
        return x, y, z

    def mark_placed(self, object_height=0.06):
        cell_idx = self.current_index - 1
        if cell_idx < 0:
            cell_idx = self.grid_cols * self.grid_rows - 1
        if cell_idx < len(self.layer_heights):
            self.layer_heights[cell_idx] += object_height


class PyramidStacking(StackingState):
    """Pyramid stacking: base 3x3 -> middle 2x2 -> top 1x1."""

    def __init__(self, table_x, table_y, table_z, base_size=3,
                 spacing_x=0.15, spacing_y=0.15):
        super().__init__(table_x, table_y, table_z)
        self.base_size = base_size
        self.spacing_x = spacing_x
        self.spacing_y = spacing_y
        self.current_layer = 0
        self.current_index = 0
        self.layer_heights = []

    @property
    def description(self):
        return "pyramid base {}".format(self.base_size)

    def _current_size(self):
        return max(1, self.base_size - self.current_layer)

    def get_place_pose(self, object_height=0.06):
        size = self._current_size()
        if size <= 0:
            self.current_layer = 0  # wrap
            size = self._current_size()
        col = self.current_index % size
        row = self.current_index // size
        x = self.table_x - (size - 1) * self.spacing_x / 2.0 + col * self.spacing_x
        y = self.table_y - (size - 1) * self.spacing_y / 2.0 + row * self.spacing_y
        cell_idx = self.current_index
        if cell_idx >= len(self.layer_heights):
            self.layer_heights.append(self.table_z)
        z = self.layer_heights[cell_idx]
        self.current_index += 1
        if self.current_index >= size * size:
            self.current_index = 0
            self.current_layer += 1
        return x, y, z

    def mark_placed(self, object_height=0.06):
        cell_idx = self.current_index - 1
        size = self._current_size()
        total = size * size
        if cell_idx < 0:
            cell_idx = total - 1
        if cell_idx < len(self.layer_heights):
            self.layer_heights[cell_idx] += object_height


def create_stacking(pattern, table_x, table_y, table_z, grid_cols, grid_rows,
                    spacing_x=0.15, spacing_y=0.15,
                    zone_half_x=0.50, zone_half_y=0.25, max_height=0.80,
                    horizontal_gap=0.02, vertical_gap=0.01):
    """Factory function for stacking strategies."""
    if pattern == 'candidate':
        return CandidatePointStacking(table_x, table_y, table_z, grid_cols, grid_rows,
                                       spacing_x, spacing_y,
                                       zone_half_x, zone_half_y, max_height,
                                       horizontal_gap, vertical_gap)
    elif pattern == 'staggered':
        return StaggeredStacking(table_x, table_y, table_z, grid_cols, grid_rows,
                                 spacing_x, spacing_y)
    elif pattern == 'pyramid':
        base = max(grid_cols, grid_rows)
        return PyramidStacking(table_x, table_y, table_z, base, spacing_x, spacing_y)
    else:  # default: aligned
        return AlignedStacking(table_x, table_y, table_z, grid_cols, grid_rows,
                               spacing_x, spacing_y)


class PalletizingExecutor:
    """Main executor for the palletizing task."""

    # PCL prism filter clips points < 3 cm above the detected table plane
    # (setHeightLimits(-0.20, -0.03) with inverted normal).
    # Therefore objects.z (zMin from PCL) ≈ actual_bottom + 0.03.
    PRISM_Z_OFFSET = 0.03

    def __init__(self):
        rospy.init_node('palletizing_executor')

        # Parameters
        self.source_table_x = rospy.get_param('~source_table_x', -1.5)
        self.source_table_y = rospy.get_param('~source_table_y', 0.0)
        self.source_table_z = rospy.get_param('~source_table_z', 0.78)
        self.dest_table_x = rospy.get_param('~dest_table_x', 1.5)
        self.dest_table_y = rospy.get_param('~dest_table_y', 0.0)
        self.dest_table_z = rospy.get_param('~dest_table_z', 0.78)

        # Table orientation and dimensions
        # table_yaw: 桌面长边在 /map 坐标系中的方向 (radians).
        #            table_yaw=0 表示桌面长边与 map X 轴平行，正面朝向 +y.
        #            若未指定 (None), 则沿用旧版 source_approach_yaw / dest_approach_yaw.
        self.source_table_yaw = rospy.get_param('~source_table_yaw', None)
        self.dest_table_yaw = rospy.get_param('~dest_table_yaw', None)
        self.source_table_length = rospy.get_param('~source_table_length', 1.0)   # 桌面长边 (m)
        self.source_table_width = rospy.get_param('~source_table_width', 0.5)     # 桌面短边/深度 (m)
        self.dest_table_length = rospy.get_param('~dest_table_length', 1.0)
        self.dest_table_width = rospy.get_param('~dest_table_width', 0.5)

        self.grid_cols = rospy.get_param('~grid_cols', 2)
        self.grid_rows = rospy.get_param('~grid_rows', 3)
        self.cube_height = rospy.get_param('~cube_height', 0.06)  # fallback for unknown types
        self.hard_cube_height = rospy.get_param('~hard_cube_height', 0.10)
        self.soft_cube_height = rospy.get_param('~soft_cube_height', 0.15)
        self.sphere_height = rospy.get_param('~sphere_height', 0.15)  # 备用
        self.stacking_pattern = rospy.get_param('~stacking_pattern', 'aligned')
        self.spacing_x = rospy.get_param('~spacing_x', 0.15)
        self.spacing_y = rospy.get_param('~spacing_y', 0.15)
        self.zone_separation_y = rospy.get_param('~zone_separation_y', 0.35)

        # Candidate-point stacking params
        self.zone_half_x = rospy.get_param('~zone_half_x', 0.50)
        self.zone_half_y = rospy.get_param('~zone_half_y', 0.25)
        self.max_height = rospy.get_param('~max_height', 0.80)
        self.horizontal_gap = rospy.get_param('~horizontal_gap', 0.02)
        self.vertical_gap = rospy.get_param('~vertical_gap', 0.01)

        # Approach offset for grab (source table): robot stops this far from the edge
        self.approach_offset = rospy.get_param('~approach_offset', 0.70)
        # Approach offset for place (dest table): place_action has built-in forward
        # movement of (table_x - 0.65) m, so the robot must start further back.
        self.place_approach_offset = rospy.get_param('~place_approach_offset', 0.30)
        # Table half-depth (palletizing_test.world uses the standard table: 0.5m deep)
        self.table_half_depth = rospy.get_param('~table_half_depth', 0.25)

        # Approach yaw for each table (radians). Defaults match the legacy
        # layout: source at -x, dest at +x.  Set these in the launch file when
        # tables are placed at arbitrary positions and orientations.
        self.source_approach_yaw = rospy.get_param('~source_approach_yaw', math.pi)
        self.dest_approach_yaw = rospy.get_param('~dest_approach_yaw', 0.0)

        # Auto-derive approach_yaw from table_yaw when table_yaw is specified.
        # Robot should face the table → approach_yaw = table_yaw + π (normalized).
        # If table_yaw is not set (None), keep the explicit source/dest_approach_yaw above.
        if self.source_table_yaw is not None:
            self.source_approach_yaw = self._derive_approach_yaw(self.source_table_yaw)
            rospy.loginfo("source_approach_yaw auto-derived from source_table_yaw: %.2f°",
                          math.degrees(self.source_approach_yaw))
        if self.dest_table_yaw is not None:
            self.dest_approach_yaw = self._derive_approach_yaw(self.dest_table_yaw)
            rospy.loginfo("dest_approach_yaw auto-derived from dest_table_yaw: %.2f°",
                          math.degrees(self.dest_approach_yaw))
        # Extra backward compensation for place_action's built-in forward
        # movement.  Legacy default matches dest_table_x - 0.65 for the
        # standard +x-axis layout.  Set to 0 only for non-standard layouts
        # where place_action's forward distance has been recalibrated.
        self.place_forward_compensation = rospy.get_param(
            '~place_forward_compensation', self.dest_table_x - 0.65)

        # Soft object handling: placement offset for gentle stacking
        self.soft_place_offset = rospy.get_param('~soft_place_offset', 0.01)

        # Per-type gripper values (力反馈自适应夹爪)
        self.gripper_values = {
            'hard_cube': rospy.get_param('~gripper_hard_cube', 0.032),
            'soft_cube': rospy.get_param('~gripper_soft_cube', 0.046),
            'hard_sphere': rospy.get_param('~gripper_hard_sphere', 0.028),
            'soft_sphere': rospy.get_param('~gripper_soft_sphere', 0.040),
        }

        # Publishers
        self.behavior_pub = rospy.Publisher('/wpb_home/behaviors', String, queue_size=10)
        self.grab_action_pub = rospy.Publisher('/wpb_home/grab_action', Pose, queue_size=10)
        self.place_pub = rospy.Publisher('/wpb_home/place_action', Pose, queue_size=10)
        self.stats_pub = rospy.Publisher('/palletizing/stats', PalletizingStats, queue_size=10)
        self.tts_pub = rospy.Publisher('/robotsound', SoundRequest, queue_size=5)
        # Persistent cmd_vel publisher for releasing move_base control after nav
        self.cmd_vel_pub = rospy.Publisher('/cmd_vel', Twist, queue_size=10)

        self.state = 'IDLE'  # IDLE, DETECTING, GRABBING, PLACING, DONE
        self.latest_objects = None
        self.grab_done = False
        self.place_done = False
        self.grab_feedback = ""
        self.place_feedback = ""
        self.objects_processed = 0
        self.objects_total = 0
        self.current_object_type = ""
        self.objects_succeeded = 0
        self.objects_failed = 0
        self.cycle_times = []
        self.task_start_time = 0.0
        self.last_cycle_start = 0.0

        # Subscribers
        self.objects_sub = rospy.Subscriber(
            '/wpb_home/objects_3d', Coord, self._objects_callback)
        self.grab_result_sub = rospy.Subscriber(
            '/wpb_home/grab_result', String, self._grab_result_callback)
        self.place_result_sub = rospy.Subscriber(
            '/wpb_home/place_result', String, self._place_result_callback)

        # Navigation client (move_base)
        self.nav_timeout = rospy.get_param('~nav_timeout', 120.0)
        self.move_base_client = actionlib.SimpleActionClient('move_base', MoveBaseAction)
        rospy.loginfo("Waiting for move_base action server...")
        if self.move_base_client.wait_for_server(rospy.Duration(10.0)):
            rospy.loginfo("move_base action server connected")
        else:
            rospy.logwarn("move_base action server not available, navigation disabled")

        # Load saved zone positions from YAML (persisted by mark_zone service)
        self.zones_file = os.path.join(os.path.expanduser('~'), 'waterjet', 'zones.yaml')
        saved = self._load_zones()
        if saved:
            self.source_table_x = saved.get('source_x', self.source_table_x)
            self.source_table_y = saved.get('source_y', self.source_table_y)
            self.source_table_z = saved.get('source_z', self.source_table_z)
            self.dest_table_x = saved.get('dest_x', self.dest_table_x)
            self.dest_table_y = saved.get('dest_y', self.dest_table_y)
            self.dest_table_z = saved.get('dest_z', self.dest_table_z)
            # Load table orientation and dimensions from saved zones
            src_yaw = saved.get('source_yaw')
            if src_yaw is not None:
                self.source_table_yaw = src_yaw
                self.source_approach_yaw = self._derive_approach_yaw(src_yaw)
            dst_yaw = saved.get('dest_yaw')
            if dst_yaw is not None:
                self.dest_table_yaw = dst_yaw
                self.dest_approach_yaw = self._derive_approach_yaw(dst_yaw)
            self.source_table_length = saved.get('source_length', self.source_table_length)
            self.source_table_width = saved.get('source_width', self.source_table_width)
            self.dest_table_length = saved.get('dest_length', self.dest_table_length)
            self.dest_table_width = saved.get('dest_width', self.dest_table_width)
            rospy.loginfo("Loaded saved zones from %s", self.zones_file)

        # Derive per-table half-depth from table_width when dimensions are available.
        # Falls back to the global table_half_depth param if table_width is unset.
        self.source_table_half_depth = self.source_table_width / 2.0 if self.source_table_width > 0.01 else self.table_half_depth
        self.dest_table_half_depth = self.dest_table_width / 2.0 if self.dest_table_width > 0.01 else self.table_half_depth

        # Zone marking service — save current robot pose as source/dest table
        rospy.Service('/palletizing/mark_zone', MarkZone, self._mark_zone)
        rospy.loginfo("Zone marking service ready: /palletizing/mark_zone")

        # Start task service — trigger palletizing loop
        rospy.Service('/palletizing/start', StartTask, self._start_callback)
        rospy.loginfo("Palletizing start service ready: /palletizing/start")

        # Zone-based stacking: each material type gets its own zone on the dest table
        # hard objects → upper zone (+y), soft objects → lower zone (-y)
        self.zones = {}
        zone_offsets = {'hard': +self.zone_separation_y / 2.0,
                         'soft': -self.zone_separation_y / 2.0}
        for material, y_offset in zone_offsets.items():
            zone_y = self.dest_table_y + y_offset
            self.zones[material] = create_stacking(
                self.stacking_pattern,
                self.dest_table_x, zone_y, self.dest_table_z,
                self.grid_cols, self.grid_rows,
                self.spacing_x, self.spacing_y,
                self.zone_half_x, self.zone_half_y, self.max_height,
                self.horizontal_gap, self.vertical_gap)
            rospy.loginfo("Zone '%s': %s, y_offset=%.2f",
                          material, self.zones[material].description, y_offset)

        # TF listener for robot position lookup
        self.tf_listener = tf.TransformListener()

    def _load_zones(self):
        try:
            if os.path.exists(self.zones_file):
                with open(self.zones_file, 'r') as f:
                    return yaml.safe_load(f) or {}
        except Exception as e:
            rospy.logwarn("Failed to load zones: %s", e)
        return {}

    def _save_zones(self, data):
        os.makedirs(os.path.dirname(self.zones_file), exist_ok=True)
        try:
            with open(self.zones_file, 'w') as f:
                yaml.dump(data, f)
            rospy.loginfo("Zones saved to %s", self.zones_file)
            return True
        except Exception as e:
            rospy.logerr("Failed to save zones: %s", e)
            return False

    def _mark_zone(self, req):
        """Mark a source or dest zone position. Saves to YAML for persistence.

        yaw, length, width are always saved.  Use 0.0 for yaw if unknown
        (but note: yaw=0 means table long axis aligned with map X-axis).
        """
        saved = self._load_zones()
        yaw = req.yaw
        length = req.length if req.length > 0.01 else 1.0
        width = req.width if req.width > 0.01 else 0.5

        if req.zone_name == 'source':
            saved['source_x'] = req.x
            saved['source_y'] = req.y
            saved['source_z'] = req.z
            saved['source_yaw'] = yaw
            saved['source_length'] = length
            saved['source_width'] = width
            self.source_table_x = req.x
            self.source_table_y = req.y
            self.source_table_z = req.z
            self.source_table_yaw = yaw
            self.source_approach_yaw = self._derive_approach_yaw(yaw)
            self.source_table_length = length
            self.source_table_width = width
        elif req.zone_name == 'dest':
            saved['dest_x'] = req.x
            saved['dest_y'] = req.y
            saved['dest_z'] = req.z
            saved['dest_yaw'] = yaw
            saved['dest_length'] = length
            saved['dest_width'] = width
            self.dest_table_x = req.x
            self.dest_table_y = req.y
            self.dest_table_z = req.z
            self.dest_table_yaw = yaw
            self.dest_approach_yaw = self._derive_approach_yaw(yaw)
            self.dest_table_length = length
            self.dest_table_width = width
        else:
            return MarkZoneResponse(success=False)
        ok = self._save_zones(saved)
        rospy.loginfo("Zone '%s' marked: (%.2f, %.2f, %.2f, yaw=%.2f°, L=%.2f, W=%.2f)",
                      req.zone_name, req.x, req.y, req.z,
                      math.degrees(yaw), length, width)
        return MarkZoneResponse(success=ok)

    @staticmethod
    def _derive_approach_yaw(table_yaw):
        """Derive approach yaw from table yaw.

        The robot should face the table, so approach_yaw = table_yaw + π.
        Returns the yaw normalized to [-π, π].
        """
        if table_yaw is None:
            return None
        yaw = table_yaw + math.pi
        return math.atan2(math.sin(yaw), math.cos(yaw))

    def _objects_callback(self, msg):
        """Store latest classified objects."""
        if self.state == 'DETECTING':
            self.latest_objects = msg
            self.objects_total = len(msg.name)

    def _grab_result_callback(self, msg):
        self.grab_feedback = msg.data
        rospy.loginfo("[grab_result] %s", msg.data)
        if msg.data == 'done':
            self.grab_done = True

    def _place_result_callback(self, msg):
        self.place_feedback = msg.data
        rospy.loginfo("[place_result] %s", msg.data)
        if msg.data == 'done':
            self.place_done = True

    def _get_zone(self, obj_type):
        """Route object type to the correct stacking zone."""
        if 'hard' in obj_type:
            return self.zones['hard']
        elif 'soft' in obj_type:
            return self.zones['soft']
        return self.zones['hard']  # default fallback

    def _get_robot_position(self):
        """Get current robot base_link pose in /map frame.

        Returns (x, y, yaw) where yaw is extracted from the orientation
        quaternion.  Falls back to (source_table_x, source_table_y, π) when
        TF is unavailable.
        """
        try:
            (trans, rot) = self.tf_listener.lookupTransform(
                '/map', '/base_link', rospy.Time(0))
            # quaternion (x,y,z,w) → yaw (ZYX Euler)
            yaw = math.atan2(2.0 * (rot[3] * rot[2] + rot[0] * rot[1]),
                             1.0 - 2.0 * (rot[1]**2 + rot[2]**2))
            return trans[0], trans[1], yaw
        except (tf.LookupException, tf.ConnectivityException, tf.ExtrapolationException):
            rospy.logwarn("TF lookup failed, using source table as reference")
            return self.source_table_x, self.source_table_y, math.pi

    def _raise_arm(self):
        """Raise arm to a safe height above the table.

        object_detect and place_action can leave the arm low.  Call this
        after detection and before grab to avoid hitting the table edge.
        """
        mani_pub = rospy.Publisher('/wpb_home/mani_ctrl', JointState, queue_size=1)
        cmd = JointState()
        cmd.name = ['lift']
        cmd.position = [0.8]
        for _ in range(5):
            mani_pub.publish(cmd)
            rospy.sleep(0.2)

    def _estimate_half_size(self, obj_type):
        """Estimate object half-width/height from type (cubes: width≈height)."""
        h = self._get_object_height(obj_type)
        return h / 2.0

    def _compute_collision_risk(self, objects, sorted_indices):
        """Compute collision risk for each object considering 3D arm volume.

        The arm body extends ≥5cm above the grasp center. When reaching for
        a front object, the arm can collide with taller objects behind it.

        Returns (risk, blocked, y_nbrs, arm_blocked, z_top, edge_x,
                 arm_blockers, cx, cy, cz) per index.

        PCL data convention (from wpb_home_objects_3d.cpp):
          objects.x[i] = xMax  (farthest edge from robot in base_footprint)
          objects.z[i] = zMin  (bottom of object bounding box)
        """
        n = len(objects.name)
        # Gather object data
        half = []     # half-size per object (half of cube side)
        cx = []       # center X
        cy = []       # center Y
        cz = []       # center Z
        edge_x = []   # farthest edge X (xMax, = objects.x[i])
        z_top = []    # top Z
        z_bot = []    # bottom Z
        for i in range(n):
            obj_type = objects.type[i] if i < len(objects.type) else ""
            hsize = self._estimate_half_size(obj_type)
            half.append(hsize)
            ex = objects.x[i] if i < len(objects.x) else 999.0
            edge_x.append(ex)
            # objects.x = xMax (farthest edge), so center = xMax - half
            cx.append(ex - hsize)
            cy.append(objects.y[i] if i < len(objects.y) else 0.0)
            z_bottom = objects.z[i] if i < len(objects.z) else 0.0
            # objects.z = zMin (PCL), but prism clips bottom 3cm.
            # Actual bottom = zMin - PRISM_Z_OFFSET.
            z_bot.append(z_bottom - self.PRISM_Z_OFFSET)
            z_top.append(z_bottom - self.PRISM_Z_OFFSET + 2.0 * hsize)
            cz.append(z_bottom - self.PRISM_Z_OFFSET + hsize)

        GRIPPER_HALF = 0.04     # gripper finger half-width in Y (meters)
        ARM_BODY_H = 0.05       # arm/forearm body height above grasp center
        ARM_BODY_W = 0.06       # arm body half-width in Y
        LAYER_TOL = 0.03        # max Z gap to be considered same layer
        BLOCKED_PENALTY = 100.0

        risk = [0.0] * n
        blocked = [False] * n    # X-direction blocked by front object
        arm_blocked = [False] * n  # arm body would hit another object
        arm_blockers = [set() for _ in range(n)]  # which front objects block each rear object
        y_nbrs = [0] * n

        for i in range(n):
            for j in range(n):
                if i == j:
                    continue
                # Different layers (j far above i or far below): skip
                dz_center = abs(cz[i] - cz[j])
                if dz_center > (half[i] + half[j] + LAYER_TOL):
                    continue

                dx = abs(cx[i] - cx[j])
                dy = abs(cy[i] - cy[j])

                # --- X blocking: front object j blocks approach to rear i ---
                if dx < (half[i] + half[j]):
                    if edge_x[j] < edge_x[i]:  # j is closer to robot
                        blocked[i] = True

                # --- Y clearance: gripper side collision ---
                y_clear = dy - (half[i] + half[j])
                if y_clear < GRIPPER_HALF:
                    y_nbrs[i] += 1
                    risk[i] += 1.0 + max(0.0, GRIPPER_HALF - y_clear) * 20.0

                # --- Arm body vertical collision ---
                # The arm body occupies Z from cz[i] to cz[i]+ARM_BODY_H above
                # the grasp center. Check both directions: front→rear and rear→front.
                arm_top_i = cz[i] + ARM_BODY_H
                arm_top_j = cz[j] + ARM_BODY_H

                # Check Z overlap: does object j intersect the arm body for i?
                z_overlap_ij = (z_bot[j] < arm_top_i and z_top[j] > cz[i])
                # Check Z overlap: does object i intersect the arm body for j?
                z_overlap_ji = (z_bot[i] < arm_top_j and z_top[i] > cz[j])

                y_overlap = dy < (ARM_BODY_W + max(half[i], half[j]))

                if edge_x[j] > edge_x[i]:  # j is behind i
                    if z_overlap_ij and y_overlap:
                        # Grasping front i: arm body would brush rear j.
                        # Soft risk only — do NOT add hard dependency (would create
                        # a cycle: front needs rear gone, rear needs front gone).
                        arm_blocked[i] = True
                        intrusion = (z_top[j] - cz[i]) / max(ARM_BODY_H, 0.01)
                        risk[i] += 5.0 + intrusion * 15.0
                    if z_overlap_ji and y_overlap:
                        # Grasping rear j: arm passes THROUGH front i — HARD constraint.
                        # Front i MUST be removed before reaching for rear j.
                        arm_blocked[j] = True
                        arm_blockers[j].add(i)  # i (front) blocks j (rear)
                        intrusion = (z_top[i] - cz[j]) / max(ARM_BODY_H, 0.01)
                        risk[j] += 8.0 + intrusion * 20.0  # higher penalty

        # Apply blocking penalty AFTER base risk
        for i in range(n):
            if blocked[i]:
                risk[i] += BLOCKED_PENALTY
            if arm_blocked[i]:
                risk[i] += BLOCKED_PENALTY * 0.5  # severe but less than full block

        return risk, blocked, y_nbrs, arm_blocked, z_top, edge_x, arm_blockers, cx, cy, cz

    def _sort_objects(self, objects):
        """Collision-aware picking order with hard dependency constraints.

        Two-phase strategy:
        1. Hard constraint — if reaching for rear object A would cause the arm
           body to hit front object B, then B MUST be picked before A (arm_blockers
           form a dependency graph; iterative safe-set selection = topological sort).
        2. Within the safe set, sort by: top-first (Z), lowest-risk, closest-X.

        This prevents the arm from knocking over nearby front objects when
        reaching past them to grab a slightly-taller rear object.
        """
        n = len(objects.name)
        if n == 0:
            return []
        if n == 1:
            rospy.loginfo("Picking order (collision-aware): only 1 object")
            return [0]

        # Run risk analysis
        risk, blocked, y_nbrs, arm_blocked, z_arr, x_arr, arm_blockers, cx, cy, cz = \
            self._compute_collision_risk(objects, range(n))

        # --- Iterative safe-set selection ---
        # An object is "safe" to pick only when ALL its arm-blockers
        # (front objects that the arm would hit) have already been removed.
        remaining = set(range(n))
        sorted_indices = []

        while remaining:
            # Find objects whose arm-blockers are all gone
            safe = [i for i in remaining
                    if not (arm_blockers[i] & remaining)]

            if not safe:
                # Fallback: all remaining objects are mutually blocking
                # (should not happen with tabletop objects, but handle gracefully)
                rospy.logwarn("Circular arm-block dependency detected among %d objects; "
                              "falling back to risk-based sort", len(remaining))
                safe = list(remaining)

            # Within safe set, sort by: Z (highest first), risk (lowest first),
            # X edge (closest first = smallest xMax)
            safe.sort(key=lambda i: (-z_arr[i], risk[i], x_arr[i]))
            best = safe[0]
            sorted_indices.append(best)
            remaining.remove(best)

        # Log rationale
        n_types = len(objects.type)
        dep_counts = [len(arm_blockers[i]) for i in range(n)]
        rospy.loginfo("Picking order (collision-aware, hard-deps, arm_body>=5cm):")
        rospy.loginfo("  %4s %-8s %6s %6s %6s %6s %6s %6s %6s %6s %6s %6s %s",
                      "Rank", "Name", "cX", "cY", "cZ", "Risk", "XBlk",
                      "ArmBlk", "Deps", "YNbrs", "Xedge", "Ztop", "Type")
        for rank, idx in enumerate(sorted_indices):
            obj_type = objects.type[idx] if idx < n_types else "??"
            rospy.loginfo("  %4d %-8s %6.3f %6.3f %6.3f %6.1f %6s %6s %6d %6d %6.3f %6.3f %s",
                          rank + 1, objects.name[idx],
                          cx[idx], cy[idx], cz[idx], risk[idx],
                          "YES" if blocked[idx] else "no",
                          "YES" if arm_blocked[idx] else "no",
                          dep_counts[idx], y_nbrs[idx],
                          x_arr[idx], z_arr[idx], obj_type)

        return sorted_indices

    def _get_object_height(self, obj_type):
        if obj_type == 'hard_cube':
            return self.hard_cube_height
        elif obj_type == 'soft_cube':
            return self.soft_cube_height
        elif 'sphere' in obj_type:
            return self.sphere_height
        return self.cube_height

    def _publish_stats(self):
        """Publish production statistics."""
        stats = PalletizingStats()
        stats.total_objects = self.objects_processed + 1
        stats.success_count = self.objects_succeeded
        stats.fail_count = self.objects_failed
        stats.current_layer = (self.zones['hard'].current_layer +
                               self.zones['soft'].current_layer)
        stats.hard_zone_layers = self.zones['hard'].current_layer
        stats.soft_zone_layers = self.zones['soft'].current_layer
        stats.current_state = self.state
        stats.elapsed_time = time.time() - self.task_start_time if self.task_start_time > 0 else 0.0

        total_done = self.objects_succeeded + self.objects_failed
        if total_done > 0:
            stats.success_rate = float(self.objects_succeeded) / float(total_done) * 100.0
        else:
            stats.success_rate = 0.0

        if len(self.cycle_times) > 0:
            stats.avg_cycle_time = sum(self.cycle_times) / len(self.cycle_times)
        else:
            stats.avg_cycle_time = 0.0

        self.stats_pub.publish(stats)

    def _get_gripper_value(self, obj_type):
        """Get adaptive gripper value based on object type."""
        return self.gripper_values.get(obj_type, 0.035)

    def _get_place_z_offset(self, obj_type):
        """Extra Z offset for soft objects to avoid crushing."""
        if 'soft' in obj_type:
            return self.soft_place_offset
        return 0.0

    def _speak(self, text):
        """Publish TTS voice announcement."""
        msg = SoundRequest()
        msg.sound = SoundRequest.SAY
        msg.command = SoundRequest.PLAY_ONCE
        msg.volume = 1.0
        msg.arg = text
        self.tts_pub.publish(msg)
        rospy.loginfo("TTS: %s", text)

    def detect_objects(self, timeout=5.0):
        """Activate object detection and wait for results."""
        self.state = 'DETECTING'
        self.latest_objects = None

        msg = String()
        msg.data = 'object_detect start'
        self.behavior_pub.publish(msg)

        start = time.time()
        while self.latest_objects is None or len(self.latest_objects.name) == 0:
            if time.time() - start > timeout:
                rospy.logwarn("Object detection timed out")
                msg.data = 'object_detect stop'
                self.behavior_pub.publish(msg)
                return False
            rospy.sleep(0.2)

        msg.data = 'object_detect stop'
        self.behavior_pub.publish(msg)
        rospy.loginfo("Detected %d objects", len(self.latest_objects.name))
        return True

    def grab_object(self, obj_type="", target_x=0.0, target_y=0.0, target_z=0.0,
                    timeout=60.0):
        """Send target object Pose to grab_action and wait for completion.

        Unlike grab_server (which does its own PCL detection), grab_action
        grabs exactly at the specified coordinates — no mismatch between
        which object was selected and which one gets grabbed.
        """
        self.state = 'GRABBING'
        self.grab_done = False

        # Publish the target position to grab_action
        pose = Pose()
        pose.position.x = target_x
        pose.position.y = target_y
        pose.position.z = target_z
        self.grab_action_pub.publish(pose)
        rospy.loginfo("Grab target sent: (%.2f, %.2f, %.2f) type='%s'",
                      target_x, target_y, target_z, obj_type)

        start = time.time()
        while not self.grab_done:
            if time.time() - start > timeout:
                rospy.logwarn("Grab timed out (feedback: %s)", self.grab_feedback)
                msg = String()
                msg.data = 'grab stop'
                self.behavior_pub.publish(msg)
                return False
            rospy.sleep(0.5)

        rospy.loginfo("Grab completed")
        return True

    def place_object(self, x, y, z, timeout=60.0):
        """Send place pose and wait for completion."""
        self.state = 'PLACING'
        self.place_done = False

        pose = Pose()
        pose.position.x = x
        pose.position.y = y
        pose.position.z = z
        pose.orientation.w = 1.0
        self.place_pub.publish(pose)
        rospy.loginfo("Place pose sent: (%.2f, %.2f, %.2f)", x, y, z)

        start = time.time()
        while not self.place_done:
            if time.time() - start > timeout:
                rospy.logwarn("Place timed out (feedback: %s)", self.place_feedback)
                return False
            rospy.sleep(0.5)

        rospy.loginfo("Place completed")
        return True

    def _start_callback(self, req):
        """Service callback: trigger the palletizing task in a background thread."""
        if self.state not in ('IDLE', 'DONE'):
            return StartTaskResponse(success=False, message="Task already running (state: %s)" % self.state)
        self.state = 'STARTING'
        threading.Thread(target=self.run, daemon=True).start()
        return StartTaskResponse(success=True, message="Palletizing task started")

    def _get_approach_position(self, table_x, table_y, for_place=False):
        """Compute a safe approach position offset from the table center.

        Uses parameterized approach yaw (source_approach_yaw / dest_approach_yaw)
        so tables can be placed at arbitrary positions and orientations.

        When for_place is True, accounts for place_action's built-in forward
        movement via place_forward_compensation so the robot ends up at a safe
        distance from the table instead of crashing into it.

        The half-depth defaults to table_half_depth but can be overridden
        per-table via source_table_width/2 or dest_table_width/2 when table
        dimensions are configured.
        """
        if for_place:
            yaw = self.dest_approach_yaw
            half_depth = getattr(self, 'dest_table_half_depth', self.table_half_depth)
            distance = half_depth + self.place_approach_offset + self.place_forward_compensation
        else:
            yaw = self.source_approach_yaw
            half_depth = getattr(self, 'source_table_half_depth', self.table_half_depth)
            distance = half_depth + self.approach_offset

        # Robot faces 'yaw' (toward the table).  The table is in front of the
        # robot, so the approach point is offset backward from the table center
        # along the facing direction.
        approach_x = table_x - distance * math.cos(yaw)
        approach_y = table_y - distance * math.sin(yaw)
        return approach_x, approach_y, yaw

    def navigate_to_pose(self, nav_x, nav_y, nav_yaw, timeout=None):
        """Navigate to an explicit (x, y, yaw) in map frame."""
        if timeout is None:
            timeout = self.nav_timeout
        self.state = 'NAVIGATING'
        goal = MoveBaseGoal()
        goal.target_pose.header.frame_id = "map"
        goal.target_pose.header.stamp = rospy.Time.now()
        goal.target_pose.pose.position.x = nav_x
        goal.target_pose.pose.position.y = nav_y
        goal.target_pose.pose.position.z = 0.0
        goal.target_pose.pose.orientation.z = math.sin(nav_yaw / 2.0)
        goal.target_pose.pose.orientation.w = math.cos(nav_yaw / 2.0)
        rospy.loginfo("Navigating to pose (%.2f, %.2f, yaw=%.1f°)...",
                      nav_x, nav_y, math.degrees(nav_yaw))
        self.move_base_client.send_goal(goal)
        finished = self.move_base_client.wait_for_result(rospy.Duration(timeout))
        if not finished:
            self.move_base_client.cancel_goal()
            rospy.logwarn("Navigation timed out after %.1fs", timeout)
            return False
        state = self.move_base_client.get_state()
        self.move_base_client.cancel_all_goals()
        rospy.sleep(0.5)
        stop = Twist()
        stop.linear.x = 0.0; stop.linear.y = 0.0; stop.angular.z = 0.0
        for _ in range(5):
            self.cmd_vel_pub.publish(stop)
            rospy.sleep(0.1)
        if state == actionlib.GoalStatus.SUCCEEDED:
            rospy.loginfo("Navigation succeeded")
            return True
        else:
            rospy.logwarn("Navigation failed (state: %d)", state)
            return False

    def navigate_to_table(self, target_x, target_y, timeout=None, use_approach=True, for_place=False):
        """Navigate to target table position using move_base.

        If use_approach is True, stops at approach distance from table edge
        and faces the table, instead of driving to the table center.
        Set for_place=True when navigating to the destination table before
        executing place_action (which moves the robot forward internally).
        """
        if timeout is None:
            timeout = self.nav_timeout

        if use_approach:
            nav_x, nav_y, yaw = self._get_approach_position(target_x, target_y, for_place)
        else:
            nav_x, nav_y = target_x, target_y
            yaw = 0.0

        self.state = 'NAVIGATING'

        goal = MoveBaseGoal()
        goal.target_pose.header.frame_id = "map"
        goal.target_pose.header.stamp = rospy.Time.now()
        goal.target_pose.pose.position.x = nav_x
        goal.target_pose.pose.position.y = nav_y
        goal.target_pose.pose.position.z = 0.0
        # Convert yaw to quaternion
        goal.target_pose.pose.orientation.z = math.sin(yaw / 2.0)
        goal.target_pose.pose.orientation.w = math.cos(yaw / 2.0)

        rospy.loginfo("Navigating to (%.2f, %.2f, yaw=%.1f°) [table at (%.2f, %.2f)]...",
                      nav_x, nav_y, math.degrees(yaw), target_x, target_y)
        self.move_base_client.send_goal(goal)

        finished = self.move_base_client.wait_for_result(rospy.Duration(timeout))
        if not finished:
            self.move_base_client.cancel_goal()
            rospy.logwarn("Navigation timed out after %.1fs", timeout)
            return False

        state = self.move_base_client.get_state()
        # Cancel all goals to stop move_base from publishing to /cmd_vel,
        # otherwise it would override grab/place alignment commands.
        self.move_base_client.cancel_all_goals()
        rospy.sleep(0.5)  # let cancel propagate through the action pipeline
        stop = Twist()
        stop.linear.x = 0.0
        stop.linear.y = 0.0
        stop.angular.z = 0.0
        # Publish several times to ensure move_base fully releases /cmd_vel
        for _ in range(5):
            self.cmd_vel_pub.publish(stop)
            rospy.sleep(0.1)

        if state == actionlib.GoalStatus.SUCCEEDED:
            rospy.loginfo("Navigation succeeded")
            return True
        else:
            rospy.logwarn("Navigation failed (state: %d)", state)
            return False

    def run(self):
        """Main execution loop — smart picking order + zone-based classification stacking."""
        rospy.loginfo("Palletizing executor starting...")
        rospy.sleep(1.0)  # let subscribers and TF connect

        # Initialize stats
        self.task_start_time = time.time()
        self.objects_succeeded = 0
        self.objects_failed = 0
        self.cycle_times = []

        # Navigate to source table first
        rospy.loginfo("Navigating to source table...")
        if not self.navigate_to_table(self.source_table_x, self.source_table_y):
            rospy.logerr("Failed to reach source table. Aborting.")
            self.state = 'DONE'
            self._publish_stats()
            return

        # ── Re-detect loop: pick one object per iteration ──
        # Each iteration re-detects after navigation, so grab coordinates
        # are always fresh.  No coordinate-aging problems.
        while True:
            # ── Re-detect objects on source table ──
            if not self.detect_objects():
                rospy.loginfo("No objects remaining on source table.")
                break

            # Raise arm after detection — object_detect may have lowered it.
            self._raise_arm()

            # Fresh sort on fresh detection
            sorted_indices = self._sort_objects(self.latest_objects)
            best_idx = sorted_indices[0]  # pick the safest object

            self.last_cycle_start = time.time()
            obj_name = self.latest_objects.name[best_idx]
            obj_type = (self.latest_objects.type[best_idx]
                        if best_idx < len(self.latest_objects.type) else "")
            obj_height = self._get_object_height(obj_type)
            zone = self._get_zone(obj_type)
            zone_material = 'hard' if 'hard' in obj_type else 'soft'

            # Fresh PCL coordinates (base_footprint at current robot pose)
            obj_bf_x = self.latest_objects.x[best_idx] if best_idx < len(self.latest_objects.x) else 0.0
            obj_bf_y = self.latest_objects.y[best_idx] if best_idx < len(self.latest_objects.y) else 0.0
            obj_bf_z = self.latest_objects.z[best_idx] if best_idx < len(self.latest_objects.z) else 0.0

            rospy.loginfo("--- Picked %s (type: %s, zone: %s, h: %.2f, bf: %.3f,%.3f,%.3f) ---",
                          obj_name, obj_type, zone_material, obj_height,
                          obj_bf_x, obj_bf_y, obj_bf_z)
            self._speak("zhua {} qu".format(zone_material))

            # ── Navigate to source table, Y-compensated ──
            det_rx, det_ry, det_yaw = self._get_robot_position()
            # base_footprint → map coordinate transform (works for any yaw)
            cos_t = math.cos(det_yaw)
            sin_t = math.sin(det_yaw)
            obj_map_y = det_ry + obj_bf_x * sin_t + obj_bf_y * cos_t
            rospy.loginfo("Nav to source (det X=%.3f, comp Y=%.3f, yaw=%.1f°)",
                          det_rx, obj_map_y, math.degrees(det_yaw))
            if not self.navigate_to_pose(det_rx, obj_map_y, det_yaw):
                rospy.logerr("Nav to source failed for %s. Skipping.", obj_name)
                self.objects_failed += 1
                continue

            # ── Re-detect AFTER Y-compensated nav (fresh coords!) ──
            if not self.detect_objects():
                rospy.logwarn("Re-detect after nav failed. Trying grab anyway.")
                # Fall back to pre-nav coords with Y=0
                obj_half = obj_height / 2.0
                grab_x = obj_bf_x - obj_half
                grab_y = 0.0
                grab_z = obj_bf_z - self.PRISM_Z_OFFSET + obj_half
            else:
                # Find the object closest to Y≈0 (our target after Y-comp nav)
                best_dist = float('inf')
                pick_idx = 0
                for i in range(len(self.latest_objects.name)):
                    y = self.latest_objects.y[i] if i < len(self.latest_objects.y) else 0.0
                    dist = abs(y)  # after Y-comp nav, target is at Y≈0
                    if dist < best_dist:
                        best_dist = dist
                        pick_idx = i
                fresh_x = self.latest_objects.x[pick_idx] if pick_idx < len(self.latest_objects.x) else obj_bf_x
                fresh_y = self.latest_objects.y[pick_idx] if pick_idx < len(self.latest_objects.y) else 0.0
                fresh_z = self.latest_objects.z[pick_idx] if pick_idx < len(self.latest_objects.z) else obj_bf_z
                obj_half = obj_height / 2.0
                grab_x = fresh_x - obj_half
                grab_y = fresh_y
                grab_z = fresh_z - self.PRISM_Z_OFFSET + obj_half
                rospy.loginfo("Re-detect: fresh bf(%.3f, %.3f, %.3f) → grab(%.3f, %.3f, %.3f)",
                              fresh_x, fresh_y, fresh_z,
                              grab_x, grab_y, grab_z)

            # Raise arm before grab — re-detect may have lowered it.
            self._raise_arm()

            rospy.loginfo("Grab target: (%.3f, %.3f, %.3f) type='%s'",
                          grab_x, grab_y, grab_z, obj_type)
            if not self.grab_object(obj_type, grab_x, grab_y, grab_z, timeout=90.0):
                rospy.logerr("Grab failed for %s. Skipping.", obj_name)
                self._speak("zhua qu shi bai, tiao guo")
                self.objects_failed += 1
                self.objects_processed += 1
                self.cycle_times.append(time.time() - self.last_cycle_start)
                self._publish_stats()
                continue

            # Step 1.5: Back up slightly to clear table area before turning
            rospy.loginfo("Backing up to clear table area...")
            stop = Twist()
            back = Twist()
            back.linear.x = -0.15  # slow backward, ~0.3m total
            for _ in range(4):  # 4 * 0.5s = 2s, approx 0.3m backward
                self.cmd_vel_pub.publish(back)
                rospy.sleep(0.5)
            for _ in range(3):  # ensure full stop
                self.cmd_vel_pub.publish(stop)
                rospy.sleep(0.1)

            # Step 2: Navigate to dest table. Use for_place=True which
            # compensates for place_action's 0.85m built-in forward movement.
            rospy.loginfo("Navigating to dest table...")
            if not self.navigate_to_table(self.dest_table_x, self.dest_table_y, for_place=True):
                rospy.logerr("Navigation to dest table failed for %s. Skipping.", obj_name)
                self._speak("dao hang shi bai, tiao guo")
                self.objects_failed += 1
                self.objects_processed += 1
                self.cycle_times.append(time.time() - self.last_cycle_start)
                self._publish_stats()
                # Release gripper on failure to avoid carrying object back
                mani_ctrl_pub = rospy.Publisher('/wpb_home/mani_ctrl', JointState, queue_size=1)
                release_cmd = JointState()
                release_cmd.name = ['lift', 'gripper']
                release_cmd.position = [0.8, 0.15]  # safe height, open gripper
                for _ in range(10):
                    mani_ctrl_pub.publish(release_cmd)
                    rospy.sleep(0.2)
                continue
                self.cycle_times.append(time.time() - self.last_cycle_start)
                self._publish_stats()
                continue

            # Step 3: Calculate place position from the correct zone.
            # get_place_pose returns stack top (= bottom of next object).
            # place_action lifts arm to place_z + 0.03, then robot moves forward
            # toward the table.  The arm must clear objects already on the table,
            # so add the object height as clearance during approach.
            place_x, place_y, place_z = zone.get_place_pose(obj_height)
            place_z += obj_height  # clearance above stack top
            place_z += self._get_place_z_offset(obj_type)

            # Step 4: Place
            if not self.place_object(place_x, place_y, place_z):
                rospy.logerr("Place failed for %s. Releasing gripper.", obj_name)
                mani_ctrl_pub = rospy.Publisher('/wpb_home/mani_ctrl', JointState, queue_size=1)
                release_cmd = JointState()
                release_cmd.name = ['lift', 'gripper']
                release_cmd.position = [0.8, 0.15]
                for _ in range(10):
                    mani_ctrl_pub.publish(release_cmd)
                    rospy.sleep(0.2)
                self.objects_failed += 1
                self.objects_processed += 1
                self.cycle_times.append(time.time() - self.last_cycle_start)
                self._publish_stats()
                continue

            # Step 5: Update zone stacking state
            zone.mark_placed(obj_height)
            self.objects_processed += 1
            self.objects_succeeded += 1
            self.cycle_times.append(time.time() - self.last_cycle_start)
            self._publish_stats()

            rospy.loginfo("%s → zone '%s' layer %d, cell %d",
                          obj_name, zone_material, zone.current_layer, zone.current_index)

            # Raise arm after place — place_action leaves it low.
            self._raise_arm()

            # Step 6: Navigate back to source table for next object
            rospy.loginfo("Navigating back to source table...")
            if not self.navigate_to_table(self.source_table_x, self.source_table_y):
                rospy.logerr("Failed to return to source table. Aborting.")
                break

        self.state = 'DONE'
        self._publish_stats()
        self._speak("ma duo wan cheng, cheng gong {} ge, shi bai {} ge".format(
            self.objects_succeeded, self.objects_failed))

        # Zone summary
        for material, z in self.zones.items():
            rospy.loginfo("Zone '%s': %d layers, %d cells/layer",
                          material, z.current_layer, z.grid_cols * z.grid_rows)
        total = self.objects_succeeded + self.objects_failed
        rospy.loginfo("Palletizing complete! %d succeeded, %d failed (%.1f%%).",
                      self.objects_succeeded, self.objects_failed,
                      100.0 * self.objects_succeeded / max(total, 1))


if __name__ == '__main__':
    try:
        executor = PalletizingExecutor()
        rospy.loginfo("Palletizing executor ready. Call /palletizing/start to begin.")
        rospy.spin()
    except rospy.ROSInterruptException:
        pass
