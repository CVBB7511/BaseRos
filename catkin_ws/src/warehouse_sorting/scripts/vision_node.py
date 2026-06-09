#!/usr/bin/env python3

import itertools

import rospy
from std_msgs.msg import String
from sensor_msgs.msg import CameraInfo, Image

from warehouse_sorting.core import Cargo, make_pose_dict, normalize_cargo_type
from warehouse_sorting.ros_conversions import cargo_to_msg
from warehouse_sorting.vision_algorithms import ColorDepthDetector
from warehouse_sorting_msgs.msg import DetectedCargoArray
from warehouse_sorting_msgs.srv import ScanRequest, ScanRequestResponse


class VisionNode:
    def __init__(self):
        self._load_params()
        self._init_state()
        self._advertise_interfaces()
        self._subscribe_camera_inputs()
        self._setup_wpb_home_bridge()
        self._log_ready()

    def _load_params(self):
        self.frame_id = rospy.get_param("~frame_id", "base_link")
        self.use_camera = bool(rospy.get_param("~use_camera", False))
        self.use_wpb_home_objects = bool(rospy.get_param("~use_wpb_home_objects", False))
        self.fallback_to_mock = bool(rospy.get_param("~fallback_to_mock", True))
        self.default_depth = float(rospy.get_param("~default_depth", 0.45))
        self.camera_on_demand = bool(rospy.get_param("~camera_on_demand", True))
        self.camera_warmup_timeout = float(rospy.get_param("~camera_warmup_timeout", 2.5))
        self.camera_require_depth = bool(rospy.get_param("~camera_require_depth", False))
        self.camera_require_info = bool(rospy.get_param("~camera_require_info", False))
        self.wpb_home_detection_timeout = float(rospy.get_param("~wpb_home_detection_timeout", 5.0))
        self.wpb_home_min_probability = float(rospy.get_param("~wpb_home_min_probability", 0.0))
        self.wpb_home_accept_stale_objects = bool(
            rospy.get_param("~wpb_home_accept_stale_objects", False)
        )
        self.camera_min_detections = int(rospy.get_param("~camera_min_detections", 1))
        self.color_depth_enabled = bool(rospy.get_param("~color_depth_enabled", True))
        self.color_depth_options = rospy.get_param("/warehouse_sorting/color_depth", {})
        self.wpb_home_type_sequence = rospy.get_param(
            "/warehouse_sorting/wpb_home_type_sequence", ["natural", "colored"]
        )
        self.rgb_topic = rospy.get_param("~rgb_topic", "/camera/rgb/image_raw")
        self.depth_topic = rospy.get_param("~depth_topic", "/camera/depth/image_raw")
        self.camera_info_topic = rospy.get_param("~camera_info_topic", "/camera/rgb/camera_info")

    def _init_state(self):
        self.rgb_image = None
        self.depth_image = None
        self.camera_info = None
        self.camera_subscribers = []
        self.wpb_home_objects = None
        self.wpb_home_objects_stamp = rospy.Time(0)
        self._counter = itertools.count(1)

    def _advertise_interfaces(self):
        self.publisher = rospy.Publisher(
            "/vision/detected_objects", DetectedCargoArray, queue_size=10, latch=True
        )
        self.debug_pub = rospy.Publisher("/vision/debug", String, queue_size=10, latch=True)
        self.service = rospy.Service(
            "/vision/scan_request", ScanRequest, self.handle_scan_request
        )

    def _subscribe_camera_inputs(self):
        if self.use_camera and not self.camera_on_demand:
            self._open_camera_inputs()

    def _setup_wpb_home_bridge(self):
        if self.use_wpb_home_objects:
            try:
                from wpb_home_behaviors.msg import Coord
            except ImportError as exc:
                rospy.logwarn("wpb_home object bridge unavailable: %s", exc)
                self.use_wpb_home_objects = False
            else:
                self.behaviors_pub = rospy.Publisher("/wpb_home/behaviors", String, queue_size=10)
                rospy.Subscriber("/wpb_home/objects_3d", Coord, self._on_wpb_home_objects, queue_size=1)

    def _log_ready(self):
        rospy.loginfo(
            "vision_node ready, use_camera=%s, camera_on_demand=%s, use_wpb_home_objects=%s",
            self.use_camera,
            self.camera_on_demand,
            self.use_wpb_home_objects,
        )
        self._debug(
            "ready use_camera=%s camera_on_demand=%s use_wpb_home_objects=%s fallback_to_mock=%s timeout=%.1fs accept_stale=%s color_depth=%s"
            % (
                self.use_camera,
                self.camera_on_demand,
                self.use_wpb_home_objects,
                self.fallback_to_mock,
                self.wpb_home_detection_timeout,
                self.wpb_home_accept_stale_objects,
                self.color_depth_enabled,
            )
        )

    def _on_rgb(self, msg):
        self.rgb_image = msg

    def _on_depth(self, msg):
        self.depth_image = msg

    def _on_camera_info(self, msg):
        self.camera_info = msg

    def _on_wpb_home_objects(self, msg):
        self.wpb_home_objects = msg
        self.wpb_home_objects_stamp = rospy.Time.now()

    def handle_scan_request(self, _request):
        self._debug("scan requested")
        try:
            if self.use_camera and self.camera_on_demand:
                self._open_camera_inputs()
                self._wait_for_camera_frames()
            cargos = self.detect_cargo()
        finally:
            if self.use_camera and self.camera_on_demand:
                self._close_camera_inputs()
        array_msg = self._build_array(cargos)
        self.publisher.publish(array_msg)
        self._debug("scan finished with %d cargo objects" % len(cargos))
        return ScanRequestResponse(
            success=True,
            message="detected %d cargo objects" % len(cargos),
            detections=array_msg,
        )

    def _open_camera_inputs(self):
        if self.camera_subscribers:
            return
        self.rgb_image = None
        self.depth_image = None
        self.camera_info = None
        self.camera_subscribers = [
            rospy.Subscriber(self.rgb_topic, Image, self._on_rgb, queue_size=1),
            rospy.Subscriber(self.depth_topic, Image, self._on_depth, queue_size=1),
            rospy.Subscriber(self.camera_info_topic, CameraInfo, self._on_camera_info, queue_size=1),
        ]
        self._debug("camera subscribers opened")

    def _close_camera_inputs(self):
        for subscriber in self.camera_subscribers:
            try:
                subscriber.unregister()
            except Exception as exc:
                rospy.logwarn("camera subscriber unregister failed: %s", exc)
        self.camera_subscribers = []
        self.rgb_image = None
        self.depth_image = None
        self.camera_info = None
        self._debug("camera subscribers closed")

    def _wait_for_camera_frames(self):
        deadline = rospy.Time.now() + rospy.Duration(self.camera_warmup_timeout)
        rate = rospy.Rate(20)
        while not rospy.is_shutdown() and rospy.Time.now() < deadline:
            if self._camera_ready_for_scan():
                self._debug("camera frame ready for one-shot scan")
                return True
            rate.sleep()
        self._debug("camera warmup timed out after %.1fs" % self.camera_warmup_timeout)
        return False

    def _camera_ready_for_scan(self):
        if self.rgb_image is None:
            return False
        if self.camera_require_depth and self.depth_image is None:
            return False
        if self.camera_require_info and self.camera_info is None:
            return False
        return True

    def detect_cargo(self):
        if self.use_camera and self.rgb_image is not None and self.color_depth_enabled:
            detected = self._detect_from_color_depth()
            if len(detected) >= self.camera_min_detections:
                return detected
            self._debug("camera detection returned %d cargo objects" % len(detected))
        elif self.use_camera and self.color_depth_enabled:
            self._debug("camera detection skipped: no rgb frame received")
        if self.use_wpb_home_objects:
            detected = self._detect_from_wpb_home()
            if detected:
                return detected
            self._debug("wpb_home detection returned no cargo")
        if self.fallback_to_mock:
            self._debug("using mock cargo fallback")
            return self._mock_cargo()
        self._debug("no cargo detected and mock fallback disabled")
        return []

    def _detect_from_wpb_home(self):
        start_time = rospy.Time.now()
        previous_stamp = self.wpb_home_objects_stamp
        if self.wpb_home_objects:
            self._debug(
                "last wpb_home objects before scan: %s"
                % self._summarize_wpb_home_objects(self.wpb_home_objects)
            )
        else:
            self._debug("no previous wpb_home objects before scan")
        if self.wpb_home_accept_stale_objects and self.wpb_home_objects:
            cargos = self._wpb_home_coord_to_cargo(self.wpb_home_objects)
            if cargos:
                self._debug(
                    "using existing wpb_home objects because accept_stale is true: %s"
                    % self._summarize_wpb_home_objects(self.wpb_home_objects)
                )
                return cargos
        self.behaviors_pub.publish(String(data="object_detect start"))
        try:
            deadline = rospy.Time.now() + rospy.Duration(self.wpb_home_detection_timeout)
            rate = rospy.Rate(10)
            next_log_time = rospy.Time.now() + rospy.Duration(1.0)
            seen_stamp = previous_stamp
            while not rospy.is_shutdown() and rospy.Time.now() < deadline:
                if (
                    self.wpb_home_objects
                    and self.wpb_home_objects_stamp >= start_time
                    and self.wpb_home_objects_stamp > seen_stamp
                ):
                    seen_stamp = self.wpb_home_objects_stamp
                    cargos = self._wpb_home_coord_to_cargo(self.wpb_home_objects)
                    if cargos:
                        self._debug(
                            "received fresh wpb_home objects: %s"
                            % self._summarize_wpb_home_objects(self.wpb_home_objects)
                        )
                        return cargos
                    self._debug(
                        "received fresh empty wpb_home result: %s"
                        % self._summarize_wpb_home_objects(self.wpb_home_objects)
                    )
                if rospy.Time.now() >= next_log_time:
                    if self.wpb_home_objects_stamp > previous_stamp:
                        self._debug("wpb_home objects updated, waiting for fresh scan result")
                    else:
                        self._debug("waiting for /wpb_home/objects_3d after object_detect start")
                    next_log_time = rospy.Time.now() + rospy.Duration(1.0)
                rate.sleep()
            rospy.logwarn(
                "wpb_home object detection timed out after %.1fs",
                self.wpb_home_detection_timeout,
            )
            self._debug(
                "wpb_home timeout after %.1fs; last objects: %s"
                % (
                    self.wpb_home_detection_timeout,
                    self._summarize_wpb_home_objects(self.wpb_home_objects),
                )
            )
            return []
        finally:
            self.behaviors_pub.publish(String(data="object_detect stop"))

    def _wpb_home_coord_to_cargo(self, msg):
        cargos = []
        type_sizes = rospy.get_param("/warehouse_sorting/cargo_types", {})
        for index, name in enumerate(msg.name):
            label = normalize_cargo_type(name)
            if label not in ("natural", "colored"):
                sequence = self.wpb_home_type_sequence or ["natural", "colored"]
                label = sequence[index % len(sequence)]
            size = type_sizes.get(label, {}).get("size", {"x": 0.12, "y": 0.12, "z": 0.10})
            confidence = msg.probability[index] if index < len(msg.probability) else 1.0
            if confidence < self.wpb_home_min_probability:
                continue
            cargos.append(
                Cargo(
                    cargo_id=name or "wpb-cargo-%03d" % next(self._counter),
                    cargo_type=label,
                    pose=make_pose_dict(x=msg.x[index], y=msg.y[index], z=msg.z[index]),
                    size=size,
                    confidence=confidence,
                )
            )
        return cargos

    def _summarize_wpb_home_objects(self, msg):
        if msg is None:
            return "none"
        names = list(msg.name)
        if not names:
            return "empty"
        parts = []
        for index, name in enumerate(names[:4]):
            x = msg.x[index] if index < len(msg.x) else 0.0
            y = msg.y[index] if index < len(msg.y) else 0.0
            z = msg.z[index] if index < len(msg.z) else 0.0
            probability = msg.probability[index] if index < len(msg.probability) else 1.0
            parts.append("%s(x=%.2f,y=%.2f,z=%.2f,p=%.2f)" % (name, x, y, z, probability))
        if len(names) > 4:
            parts.append("...+%d" % (len(names) - 4))
        return ", ".join(parts)

    def _debug(self, message):
        rospy.loginfo("[vision] %s", message)
        self.debug_pub.publish(String(data=message))

    def _mock_cargo(self):
        raw_items = rospy.get_param("/warehouse_sorting/mock_cargo", [])
        if not raw_items:
            raw_items = [
                {
                    "cargo_id": "mock-natural",
                    "cargo_type": "natural",
                    "pose": {"x": 0.42, "y": 0.10, "z": 0.05},
                    "bbox": {"x": 120, "y": 180, "width": 80, "height": 70},
                },
                {
                    "cargo_id": "mock-colored",
                    "cargo_type": "colored",
                    "pose": {"x": 0.44, "y": -0.12, "z": 0.05},
                    "bbox": {"x": 310, "y": 170, "width": 78, "height": 72},
                },
            ]
        cargos = []
        for item in raw_items:
            pose = make_pose_dict(**item.get("pose", {}))
            size = item.get("size", {"x": 0.12, "y": 0.12, "z": 0.10})
            bbox = item.get("bbox", {"x": 0, "y": 0, "width": 0, "height": 0})
            cargo_id = item.get("cargo_id") or "cargo-%03d" % next(self._counter)
            cargos.append(
                Cargo(
                    cargo_id=cargo_id,
                    cargo_type=item.get("cargo_type", "natural"),
                    pose=pose,
                    size=size,
                    confidence=float(item.get("confidence", 1.0)),
                    bbox=bbox,
                )
            )
        return cargos

    def _detect_from_color_depth(self):
        try:
            from cv_bridge import CvBridge
        except ImportError as exc:
            rospy.logwarn_throttle(10.0, "camera detection unavailable: %s", exc)
            return []

        bridge = CvBridge()
        image = bridge.imgmsg_to_cv2(self.rgb_image, desired_encoding="bgr8")
        depth = None
        if self.depth_image is not None:
            depth = bridge.imgmsg_to_cv2(self.depth_image, desired_encoding="passthrough")
        specs = rospy.get_param("/warehouse_sorting/cargo_types", {})
        options = dict(self.color_depth_options or {})
        options.setdefault("default_depth", self.default_depth)
        detector = ColorDepthDetector(specs, options)
        camera_matrix = self.camera_info.K if self.camera_info else None
        cargos, debug = detector.detect(image, depth, camera_matrix)
        for item in debug:
            if item.rejected:
                rejected = "; ".join(item.rejected[:3])
            else:
                rejected = "none"
            self._debug(
                "color_depth %s mask=%d contours=%d accepted=%d rejected=%s"
                % (item.cargo_type, item.mask_pixels, item.contours, item.accepted, rejected)
            )
        return cargos

    def _build_array(self, cargos):
        msg = DetectedCargoArray()
        msg.header.stamp = rospy.Time.now()
        msg.header.frame_id = self.frame_id
        msg.objects = [cargo_to_msg(cargo) for cargo in cargos]
        return msg


if __name__ == "__main__":
    rospy.init_node("vision_node")
    VisionNode()
    rospy.spin()
