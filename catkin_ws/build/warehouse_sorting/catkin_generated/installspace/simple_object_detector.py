#!/usr/bin/env python3

import json
import threading

import cv2
import numpy as np
import rospy
from cv_bridge import CvBridge, CvBridgeError
from geometry_msgs.msg import Pose, PoseArray
from sensor_msgs.msg import CameraInfo, Image
from std_msgs.msg import String


class SimpleObjectDetector:
    def __init__(self):
        self.rgb_topic = rospy.get_param("~rgb_topic", "/kinect2/qhd/image_color_rect")
        self.depth_topic = rospy.get_param("~depth_topic", "/kinect2/qhd/image_depth_rect")
        self.camera_info_topic = rospy.get_param("~camera_info_topic", "/kinect2/qhd/camera_info")
        self.output_frame = rospy.get_param("~output_frame", "")
        self.process_hz = float(rospy.get_param("~process_hz", 5.0))
        self.min_area = float(rospy.get_param("~min_area", 1000.0))
        self.min_extent = int(rospy.get_param("~min_extent", 10))
        self.depth_window = int(rospy.get_param("~depth_window", 7))
        self.min_depth = float(rospy.get_param("~min_depth", 0.15))
        self.max_depth = float(rospy.get_param("~max_depth", 2.0))
        self.roi = rospy.get_param("~roi", {"x": 0.0, "y": 0.0, "width": 1.0, "height": 1.0})
        self.kernel_size = int(rospy.get_param("~morph_kernel", 5))
        self.publish_debug_image = bool(rospy.get_param("~publish_debug_image", True))

        self.targets = rospy.get_param(
            "~targets",
            [
                {
                    "name": "natural",
                    "hsv_lower": [10, 20, 60],
                    "hsv_upper": [35, 180, 230],
                },
                {
                    "name": "colored",
                    "hsv_lower": [90, 60, 50],
                    "hsv_upper": [135, 255, 255],
                },
            ],
        )

        self.bridge = CvBridge()
        self.lock = threading.Lock()
        self.rgb_msg = None
        self.depth_msg = None
        self.camera_info = None

        self.objects_pub = rospy.Publisher("/simple_vision/objects", PoseArray, queue_size=1)
        self.debug_pub = rospy.Publisher("/simple_vision/debug", String, queue_size=10)
        self.debug_image_pub = rospy.Publisher(
            "/simple_vision/debug_image", Image, queue_size=1
        )

        rospy.Subscriber(self.rgb_topic, Image, self._on_rgb, queue_size=1)
        rospy.Subscriber(self.depth_topic, Image, self._on_depth, queue_size=1)
        rospy.Subscriber(self.camera_info_topic, CameraInfo, self._on_camera_info, queue_size=1)
        rospy.Timer(rospy.Duration(1.0 / max(self.process_hz, 0.1)), self._on_timer)

        rospy.loginfo(
            "simple_object_detector ready rgb=%s depth=%s camera_info=%s",
            self.rgb_topic,
            self.depth_topic,
            self.camera_info_topic,
        )

    def _on_rgb(self, msg):
        with self.lock:
            self.rgb_msg = msg

    def _on_depth(self, msg):
        with self.lock:
            self.depth_msg = msg

    def _on_camera_info(self, msg):
        with self.lock:
            self.camera_info = msg

    def _on_timer(self, _event):
        with self.lock:
            rgb_msg = self.rgb_msg
            depth_msg = self.depth_msg
            camera_info = self.camera_info
        if rgb_msg is None:
            self._publish_debug({"status": "waiting_rgb", "rgb_topic": self.rgb_topic})
            return
        if depth_msg is None:
            self._publish_debug({"status": "waiting_depth", "depth_topic": self.depth_topic})
            return
        if camera_info is None:
            self._publish_debug(
                {"status": "waiting_camera_info", "camera_info_topic": self.camera_info_topic}
            )
            return

        try:
            bgr = self._rgb_to_bgr(rgb_msg)
            depth = self._depth_to_meters(depth_msg)
        except CvBridgeError as exc:
            self._publish_debug({"status": "cv_bridge_error", "error": str(exc)})
            return

        detections, debug_image = self._detect(bgr, depth, camera_info)
        pose_array = PoseArray()
        pose_array.header.stamp = rospy.Time.now()
        pose_array.header.frame_id = self.output_frame or camera_info.header.frame_id or rgb_msg.header.frame_id
        for item in detections:
            pose = Pose()
            pose.position.x = item["x"]
            pose.position.y = item["y"]
            pose.position.z = item["z"]
            pose.orientation.w = 1.0
            pose_array.poses.append(pose)
        self.objects_pub.publish(pose_array)
        self._publish_debug({"status": "ok", "count": len(detections), "objects": detections})
        if self.publish_debug_image:
            self.debug_image_pub.publish(self.bridge.cv2_to_imgmsg(debug_image, encoding="bgr8"))

    def _rgb_to_bgr(self, msg):
        if msg.encoding in ("bgr8", "8UC3"):
            return self.bridge.imgmsg_to_cv2(msg, desired_encoding="bgr8")
        if msg.encoding == "rgb8":
            rgb = self.bridge.imgmsg_to_cv2(msg, desired_encoding="rgb8")
            return cv2.cvtColor(rgb, cv2.COLOR_RGB2BGR)
        return self.bridge.imgmsg_to_cv2(msg, desired_encoding="bgr8")

    def _depth_to_meters(self, msg):
        depth = self.bridge.imgmsg_to_cv2(msg, desired_encoding="passthrough")
        depth = np.asarray(depth)
        if msg.encoding == "16UC1" or depth.dtype == np.uint16:
            return depth.astype(np.float32) / 1000.0
        return depth.astype(np.float32)

    def _detect(self, bgr, depth, camera_info):
        height, width = bgr.shape[:2]
        x0, y0, x1, y1 = self._roi_pixels(width, height)
        hsv = cv2.cvtColor(bgr, cv2.COLOR_BGR2HSV)
        debug_image = bgr.copy()
        cv2.rectangle(debug_image, (x0, y0), (x1, y1), (190, 190, 190), 1)

        kernel = None
        if self.kernel_size > 1:
            kernel = np.ones((self.kernel_size, self.kernel_size), np.uint8)

        detections = []
        fx = camera_info.K[0]
        fy = camera_info.K[4]
        cx = camera_info.K[2]
        cy = camera_info.K[5]
        if fx == 0.0 or fy == 0.0:
            return detections, debug_image

        for target in self.targets:
            name = str(target.get("name", "object"))
            lower = np.array(target.get("hsv_lower", [0, 0, 0]), dtype=np.uint8)
            upper = np.array(target.get("hsv_upper", [179, 255, 255]), dtype=np.uint8)
            mask = cv2.inRange(hsv, lower, upper)
            roi_mask = np.zeros_like(mask)
            roi_mask[y0:y1, x0:x1] = 255
            mask = cv2.bitwise_and(mask, roi_mask)
            if kernel is not None:
                mask = cv2.morphologyEx(mask, cv2.MORPH_OPEN, kernel)
                mask = cv2.morphologyEx(mask, cv2.MORPH_CLOSE, kernel)

            contours, _ = cv2.findContours(mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
            contours = sorted(contours, key=cv2.contourArea, reverse=True)
            for contour in contours[:3]:
                area = cv2.contourArea(contour)
                if area < self.min_area:
                    continue
                x, y, w, h = cv2.boundingRect(contour)
                if w < self.min_extent or h < self.min_extent:
                    continue
                u = int(x + w / 2)
                v = int(y + h / 2)
                z = self._median_depth(depth, u, v)
                if z is None:
                    continue
                px = (u - cx) * z / fx
                py = (v - cy) * z / fy
                detections.append(
                    {
                        "name": name,
                        "x": round(float(px), 4),
                        "y": round(float(py), 4),
                        "z": round(float(z), 4),
                        "u": int(u),
                        "v": int(v),
                        "area": round(float(area), 1),
                    }
                )
                color = (0, 0, 255) if name == "colored" else (255, 0, 0)
                cv2.rectangle(debug_image, (x, y), (x + w, y + h), color, 2)
                cv2.circle(debug_image, (u, v), 4, color, -1)
                cv2.putText(
                    debug_image,
                    "%s %.2fm" % (name, z),
                    (x, max(18, y - 6)),
                    cv2.FONT_HERSHEY_SIMPLEX,
                    0.55,
                    color,
                    2,
                    cv2.LINE_AA,
                )
        return detections, debug_image

    def _roi_pixels(self, width, height):
        x = float(self.roi.get("x", 0.0))
        y = float(self.roi.get("y", 0.0))
        w = float(self.roi.get("width", 1.0))
        h = float(self.roi.get("height", 1.0))
        if 0.0 <= x <= 1.0 and 0.0 < w <= 1.0:
            x0 = int(x * width)
            x1 = int((x + w) * width)
        else:
            x0 = int(x)
            x1 = int(x + w)
        if 0.0 <= y <= 1.0 and 0.0 < h <= 1.0:
            y0 = int(y * height)
            y1 = int((y + h) * height)
        else:
            y0 = int(y)
            y1 = int(y + h)
        return (
            max(0, min(width - 1, x0)),
            max(0, min(height - 1, y0)),
            max(1, min(width, x1)),
            max(1, min(height, y1)),
        )

    def _median_depth(self, depth, u, v):
        radius = max(1, self.depth_window // 2)
        y0 = max(0, v - radius)
        y1 = min(depth.shape[0], v + radius + 1)
        x0 = max(0, u - radius)
        x1 = min(depth.shape[1], u + radius + 1)
        values = depth[y0:y1, x0:x1].reshape(-1)
        values = values[np.isfinite(values)]
        values = values[(values >= self.min_depth) & (values <= self.max_depth)]
        if values.size == 0:
            return None
        return float(np.median(values))

    def _publish_debug(self, payload):
        self.debug_pub.publish(String(data=json.dumps(payload, ensure_ascii=False, sort_keys=True)))


if __name__ == "__main__":
    rospy.init_node("simple_object_detector")
    SimpleObjectDetector()
    rospy.spin()
