#!/usr/bin/env python3

import sys
import time

import rospy
import rosservice
from rospy.msg import AnyMsg
from std_msgs.msg import String

from warehouse_sorting_msgs.srv import ScanRequest


class TopicCounter:
    def __init__(self, topic):
        self.topic = topic
        self.count = 0
        self.last_stamp = None
        self.subscriber = rospy.Subscriber(topic, AnyMsg, self._callback, queue_size=10)

    def _callback(self, _msg):
        self.count += 1
        self.last_stamp = rospy.Time.now()

    def stop(self):
        self.subscriber.unregister()


def log_ok(message):
    rospy.loginfo("[OK] %s", message)


def log_warn(message):
    rospy.logwarn("[WARN] %s", message)


def log_fail(message):
    rospy.logerr("[FAIL] %s", message)


def measure_topic_hz(topic, seconds, min_hz):
    counter = TopicCounter(topic)
    rospy.sleep(seconds)
    count = counter.count
    counter.stop()
    hz = count / max(seconds, 0.001)
    if hz >= min_hz:
        log_ok("%s %.2f Hz (%d messages in %.1fs)" % (topic, hz, count, seconds))
        return True, hz
    log_fail("%s %.2f Hz < %.2f Hz (%d messages in %.1fs)" % (topic, hz, min_hz, count, seconds))
    return False, hz


def wait_for_topic(topic, timeout):
    counter = TopicCounter(topic)
    deadline = time.time() + timeout
    while not rospy.is_shutdown() and time.time() < deadline:
        if counter.count > 0:
            counter.stop()
            log_ok("%s received a message" % topic)
            return True
        rospy.sleep(0.1)
    counter.stop()
    log_fail("%s did not publish within %.1fs" % (topic, timeout))
    return False


def check_tf(base_frame, sensor_frame, timeout):
    try:
        import tf
    except ImportError as exc:
        log_warn("tf check skipped: %s" % exc)
        return True

    listener = tf.TransformListener()
    try:
        listener.waitForTransform(base_frame, sensor_frame, rospy.Time(0), rospy.Duration(timeout))
        translation, rotation = listener.lookupTransform(base_frame, sensor_frame, rospy.Time(0))
    except Exception as exc:
        log_fail("tf %s <- %s unavailable: %s" % (base_frame, sensor_frame, exc))
        return False
    log_ok(
        "tf %s <- %s translation=(%.2f, %.2f, %.2f) rotation=(%.2f, %.2f, %.2f, %.2f)"
        % (
            base_frame,
            sensor_frame,
            translation[0],
            translation[1],
            translation[2],
            rotation[0],
            rotation[1],
            rotation[2],
            rotation[3],
        )
    )
    return True


def trigger_wpb_detection(timeout):
    behavior_topic = rospy.get_param("~behavior_topic", "/wpb_home/behaviors")
    object_topic = rospy.get_param("~object_topic", "/wpb_home/objects_3d")
    publisher = rospy.Publisher(behavior_topic, String, queue_size=10)
    rospy.sleep(0.5)
    log_ok("publishing object_detect start on %s" % behavior_topic)
    publisher.publish(String(data="object_detect start"))
    result = wait_for_topic(object_topic, timeout)
    publisher.publish(String(data="object_detect stop"))
    return result


def call_scan_service(timeout):
    service_name = rospy.get_param("~scan_service", "/vision/scan_request")
    if service_name not in rosservice.get_service_list():
        log_fail("%s service missing" % service_name)
        return False
    try:
        rospy.wait_for_service(service_name, timeout=timeout)
        response = rospy.ServiceProxy(service_name, ScanRequest)(True)
    except Exception as exc:
        log_fail("%s call failed: %s" % (service_name, exc))
        return False
    if response.success and response.detections.objects:
        log_ok("%s returned %d cargo objects" % (service_name, len(response.detections.objects)))
        for obj in response.detections.objects:
            rospy.loginfo(
                "  cargo=%s type=%s pose=(%.2f, %.2f, %.2f) confidence=%.2f",
                obj.cargo_id,
                obj.cargo_type,
                obj.pose.position.x,
                obj.pose.position.y,
                obj.pose.position.z,
                obj.confidence,
            )
        return True
    log_fail("%s returned no cargo objects: %s" % (service_name, response.message))
    return False


def main():
    rospy.init_node("warehouse_sorting_vision_doctor", anonymous=True)
    sample_seconds = float(rospy.get_param("~sample_seconds", 3.0))
    min_image_hz = float(rospy.get_param("~min_image_hz", 1.0))
    min_points_hz = float(rospy.get_param("~min_points_hz", 0.5))
    timeout = float(rospy.get_param("~timeout", 8.0))

    rgb_topic = rospy.get_param("~rgb_topic", "/kinect2/qhd/image_color_rect")
    depth_topic = rospy.get_param("~depth_topic", "/kinect2/qhd/image_depth_rect")
    points_topic = rospy.get_param("~points_topic", "/kinect2/qhd/points")
    base_frame = rospy.get_param("~base_frame", "/base_footprint")
    sensor_frame = rospy.get_param("~sensor_frame", "/kinect2_rgb_optical_frame")
    skip_tf = bool(rospy.get_param("~skip_tf", False))
    skip_wpb = bool(rospy.get_param("~skip_wpb", False))
    skip_scan = bool(rospy.get_param("~skip_scan", False))

    success = True
    rospy.loginfo("vision doctor started")
    for topic, threshold in [
        (rgb_topic, min_image_hz),
        (depth_topic, min_image_hz),
        (points_topic, min_points_hz),
    ]:
        ok, _hz = measure_topic_hz(topic, sample_seconds, threshold)
        success = ok and success

    if not skip_tf:
        success = check_tf(base_frame, sensor_frame, timeout) and success
    if not skip_wpb:
        success = trigger_wpb_detection(timeout) and success
    if not skip_scan:
        success = call_scan_service(timeout) and success

    if success:
        log_ok("vision doctor finished")
        return 0
    log_fail("vision doctor found blocking issues")
    return 1


if __name__ == "__main__":
    sys.exit(main())
