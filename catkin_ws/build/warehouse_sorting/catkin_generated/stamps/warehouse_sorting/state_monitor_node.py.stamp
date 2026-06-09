#!/usr/bin/env python3

import collections
import json
import math

import rospy
from actionlib_msgs.msg import GoalStatusArray
from geometry_msgs.msg import PoseWithCovarianceStamped
from nav_msgs.msg import Odometry
from sensor_msgs.msg import CameraInfo, Image, PointCloud2
from std_msgs.msg import String

from warehouse_sorting_msgs.msg import DetectedCargoArray, TaskStatus

try:
    from wpb_home_behaviors.msg import Coord
except ImportError:
    Coord = None


GOAL_STATUS = {
    0: "PENDING",
    1: "ACTIVE",
    2: "PREEMPTED",
    3: "SUCCEEDED",
    4: "ABORTED",
    5: "REJECTED",
    6: "PREEMPTING",
    7: "RECALLING",
    8: "RECALLED",
    9: "LOST",
}


class TopicTracker:
    def __init__(self, topic, stale_after=2.5):
        self.topic = topic
        self.stale_after = float(stale_after)
        self.samples = collections.deque(maxlen=40)
        self.last_seen = None
        self.count = 0

    def mark(self):
        now = rospy.Time.now().to_sec()
        self.samples.append(now)
        self.last_seen = now
        self.count += 1

    def snapshot(self, now):
        if self.last_seen is None:
            return {
                "topic": self.topic,
                "seen": False,
                "state": "missing",
                "hz": 0.0,
                "age": None,
                "count": self.count,
            }
        age = max(0.0, now - self.last_seen)
        hz = 0.0
        if len(self.samples) >= 2:
            span = self.samples[-1] - self.samples[0]
            if span > 0.0:
                hz = (len(self.samples) - 1) / span
        return {
            "topic": self.topic,
            "seen": True,
            "state": "ok" if age <= self.stale_after else "stale",
            "hz": round(hz, 2),
            "age": round(age, 2),
            "count": self.count,
        }


class StateMonitorNode:
    def __init__(self):
        self.publish_rate = float(rospy.get_param("~publish_rate", 1.0))
        self.trackers = {}
        self.task_status = {}
        self.detections = []
        self.vision_debug = {"message": "", "age": None}
        self.localization = {
            "amcl": {"seen": False},
            "odom": {"seen": False},
        }
        self.navigation = {"seen": False, "state": "UNKNOWN", "text": ""}
        self.wpb_objects = {"seen": False, "count": 0, "names": []}

        self.pub = rospy.Publisher("/debug/state", String, queue_size=1, latch=True)
        self._subscribe_topics()
        rospy.Timer(rospy.Duration(1.0 / max(self.publish_rate, 0.1)), self._publish)
        rospy.loginfo("state_monitor ready, publishing /debug/state")

    def _subscribe_topics(self):
        self._track_image("rgb", rospy.get_param("~rgb_topic", "/camera/rgb/image_raw"))
        self._track_image("depth", rospy.get_param("~depth_topic", "/camera/depth/image_raw"))
        self._track("camera_info", rospy.get_param("~camera_info_topic", "/camera/rgb/camera_info"), CameraInfo)
        self._track("pointcloud", rospy.get_param("~pointcloud_topic", "/kinect2/qhd/points"), PointCloud2)
        self._track(
            "task_status",
            rospy.get_param("~task_status_topic", "/task/status"),
            TaskStatus,
            callback=self._on_task_status,
        )
        self._track(
            "detections",
            rospy.get_param("~detections_topic", "/vision/detected_objects"),
            DetectedCargoArray,
            callback=self._on_detections,
        )
        self._track(
            "vision_debug",
            rospy.get_param("~vision_debug_topic", "/vision/debug"),
            String,
            callback=self._on_vision_debug,
        )
        self._track(
            "amcl",
            rospy.get_param("~amcl_topic", "/amcl_pose"),
            PoseWithCovarianceStamped,
            stale_after=5.0,
            callback=self._on_amcl,
        )
        self._track(
            "odom",
            rospy.get_param("~odom_topic", "/odom"),
            Odometry,
            stale_after=2.5,
            callback=self._on_odom,
        )
        self._track(
            "move_base",
            rospy.get_param("~move_base_status_topic", "/move_base/status"),
            GoalStatusArray,
            stale_after=5.0,
            callback=self._on_move_base,
        )
        if Coord is not None:
            self._track(
                "wpb_objects",
                rospy.get_param("~wpb_objects_topic", "/wpb_home/objects_3d"),
                Coord,
                stale_after=5.0,
                callback=self._on_wpb_objects,
            )

    def _track_image(self, label, topic):
        self._track(label, topic, Image)

    def _track(self, label, topic, msg_type, stale_after=2.5, callback=None):
        tracker = TopicTracker(topic, stale_after=stale_after)
        self.trackers[label] = tracker

        def on_message(msg):
            tracker.mark()
            if callback:
                callback(msg)

        rospy.Subscriber(topic, msg_type, on_message, queue_size=1)

    def _on_task_status(self, msg):
        self.task_status = {
            "task_id": msg.task_id,
            "status": msg.status,
            "total_items": msg.total_items,
            "completed_items": msg.completed_items,
            "failed_items": msg.failed_items,
            "sorted_natural": msg.sorted_natural,
            "sorted_colored": msg.sorted_colored,
            "progress": round(float(msg.progress), 3),
            "queue_size": msg.queue_size,
            "current_step": msg.current_step,
            "last_error": msg.last_error,
        }

    def _on_detections(self, msg):
        self.detections = []
        for item in msg.objects:
            self.detections.append(
                {
                    "cargo_id": item.cargo_id,
                    "cargo_type": item.cargo_type,
                    "confidence": round(float(item.confidence), 3),
                    "bbox": {
                        "x": item.bbox_x,
                        "y": item.bbox_y,
                        "width": item.bbox_width,
                        "height": item.bbox_height,
                    },
                    "pose": pose_to_dict(item.pose),
                }
            )

    def _on_vision_debug(self, msg):
        self.vision_debug = {
            "message": msg.data,
            "stamp": rospy.Time.now().to_sec(),
        }

    def _on_amcl(self, msg):
        self.localization["amcl"] = {
            "seen": True,
            "pose": pose_to_dict(msg.pose.pose),
            "covariance_x": round(float(msg.pose.covariance[0]), 4),
            "covariance_y": round(float(msg.pose.covariance[7]), 4),
        }

    def _on_odom(self, msg):
        self.localization["odom"] = {
            "seen": True,
            "pose": pose_to_dict(msg.pose.pose),
        }

    def _on_move_base(self, msg):
        if not msg.status_list:
            self.navigation = {"seen": True, "state": "IDLE", "text": ""}
            return
        status = msg.status_list[-1]
        self.navigation = {
            "seen": True,
            "state": GOAL_STATUS.get(status.status, str(status.status)),
            "text": status.text,
        }

    def _on_wpb_objects(self, msg):
        self.wpb_objects = {
            "seen": True,
            "count": len(msg.name),
            "names": list(msg.name[:6]),
        }

    def _publish(self, _event):
        now = rospy.Time.now().to_sec()
        vision_debug = dict(self.vision_debug)
        if vision_debug.get("stamp"):
            vision_debug["age"] = round(now - vision_debug["stamp"], 2)
        payload = {
            "stamp": now,
            "topics": {
                label: tracker.snapshot(now)
                for label, tracker in sorted(self.trackers.items())
            },
            "task": self.task_status,
            "detections": self.detections,
            "vision": vision_debug,
            "localization": self.localization,
            "navigation": self.navigation,
            "wpb_objects": self.wpb_objects,
        }
        self.pub.publish(String(data=json.dumps(payload, sort_keys=True)))


def pose_to_dict(msg):
    return {
        "x": round(float(msg.position.x), 3),
        "y": round(float(msg.position.y), 3),
        "z": round(float(msg.position.z), 3),
        "yaw": round(yaw_from_quaternion(msg.orientation), 1),
    }


def yaw_from_quaternion(q):
    siny_cosp = 2.0 * (q.w * q.z + q.x * q.y)
    cosy_cosp = 1.0 - 2.0 * (q.y * q.y + q.z * q.z)
    return math.degrees(math.atan2(siny_cosp, cosy_cosp))


if __name__ == "__main__":
    rospy.init_node("warehouse_sorting_state_monitor")
    StateMonitorNode()
    rospy.spin()
