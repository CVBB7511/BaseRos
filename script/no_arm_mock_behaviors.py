#!/usr/bin/env python3
"""Mock palletizing behavior nodes for no-arm flow tests.

This node simulates object detection plus successful grab/place results so the
palletizing executor can run its navigation-level flow on a robot without an arm.
"""

import threading
import time

import rospy
from geometry_msgs.msg import Pose
from sensor_msgs.msg import JointState
from std_msgs.msg import String
from wpb_home_behaviors.msg import Coord


class NoArmMockBehaviors:
    def __init__(self):
        self.lock = threading.Lock()
        self.remaining = rospy.get_param("~objects", 2)
        self.object_x = rospy.get_param("~object_x", 0.95)
        self.object_y_step = rospy.get_param("~object_y_step", 0.12)
        self.object_z = rospy.get_param("~object_z", 0.83)
        self.detect_burst_count = rospy.get_param("~detect_burst_count", 8)
        self.detect_burst_period = rospy.get_param("~detect_burst_period", 0.10)
        self.grab_delay = rospy.get_param("~grab_delay", 0.70)
        self.place_delay = rospy.get_param("~place_delay", 0.80)

        self.objects_pub = rospy.Publisher("/wpb_home/objects_3d", Coord, queue_size=5)
        self.grab_result_pub = rospy.Publisher("/wpb_home/grab_result", String, queue_size=5)
        self.place_result_pub = rospy.Publisher("/wpb_home/place_result", String, queue_size=5)

        rospy.Subscriber("/wpb_home/behaviors", String, self._behavior_cb, queue_size=10)
        rospy.Subscriber("/wpb_home/grab_action", Pose, self._grab_cb, queue_size=10)
        rospy.Subscriber("/wpb_home/place_action", Pose, self._place_cb, queue_size=10)
        rospy.Subscriber("/wpb_home/mani_ctrl", JointState, self._mani_cb, queue_size=10)

        rospy.loginfo("No-arm mock behaviors ready: %d fake objects", self.remaining)

    def _make_objects(self):
        msg = Coord()
        with self.lock:
            count = self.remaining
        msg.name = ["mock_obj_{}".format(i) for i in range(count)]
        msg.x = [self.object_x + 0.08 * i for i in range(count)]
        center = (count - 1) / 2.0
        msg.y = [(i - center) * self.object_y_step for i in range(count)]
        msg.z = [self.object_z for _ in range(count)]
        msg.probability = [1.0 for _ in range(count)]
        return msg

    def _publish_detection_burst(self):
        for _ in range(self.detect_burst_count):
            if rospy.is_shutdown():
                return
            msg = self._make_objects()
            self.objects_pub.publish(msg)
            rospy.loginfo("Mock detect: published %d objects", len(msg.name))
            time.sleep(self.detect_burst_period)

    def _behavior_cb(self, msg):
        if msg.data == "object_detect start":
            threading.Thread(target=self._publish_detection_burst, daemon=True).start()

    def _grab_cb(self, pose):
        rospy.loginfo("Mock grab request: x=%.3f y=%.3f z=%.3f",
                      pose.position.x, pose.position.y, pose.position.z)
        threading.Thread(target=self._finish_grab, daemon=True).start()

    def _finish_grab(self):
        time.sleep(self.grab_delay)
        self.grab_result_pub.publish(String(data="done"))
        with self.lock:
            if self.remaining > 0:
                self.remaining -= 1
        rospy.loginfo("Mock grab result: done, remaining=%d", self.remaining)

    def _place_cb(self, pose):
        rospy.loginfo("Mock place request: x=%.3f y=%.3f z=%.3f",
                      pose.position.x, pose.position.y, pose.position.z)
        threading.Thread(target=self._finish_place, daemon=True).start()

    def _finish_place(self):
        self.place_result_pub.publish(String(data="release"))
        time.sleep(self.place_delay)
        self.place_result_pub.publish(String(data="done"))
        rospy.loginfo("Mock place result: done")

    def _mani_cb(self, msg):
        if msg.position:
            rospy.loginfo_throttle(2.0, "Mock mani_ctrl observed: %s", list(msg.position))


if __name__ == "__main__":
    rospy.init_node("no_arm_mock_behaviors")
    NoArmMockBehaviors()
    rospy.spin()
