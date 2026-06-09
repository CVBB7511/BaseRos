#!/usr/bin/env python3

import sys

import rospy
import rospkg
import rosservice


def ok(message):
    rospy.loginfo("[OK] %s", message)


def warn(message):
    rospy.logwarn("[WARN] %s", message)


def fail(message):
    rospy.logerr("[FAIL] %s", message)


def package_exists(rospack, package_name):
    try:
        rospack.get_path(package_name)
        ok("package %s found" % package_name)
        return True
    except rospkg.ResourceNotFound:
        fail("package %s not found" % package_name)
        return False


def service_exists(service_name, services):
    if service_name in services:
        ok("service %s available" % service_name)
        return True
    fail("service %s missing" % service_name)
    return False


def topic_exists(topic_name, topics):
    if topic_name in topics:
        ok("topic %s published" % topic_name)
        return True
    warn("topic %s not currently published" % topic_name)
    return False


def main():
    rospy.init_node("warehouse_sorting_preflight", anonymous=True)
    check_robot = bool(rospy.get_param("~check_robot", False))
    wait_seconds = float(rospy.get_param("~wait_seconds", 2.0))
    rospy.sleep(wait_seconds)

    success = True
    rospack = rospkg.RosPack()
    for package in ["warehouse_sorting", "warehouse_sorting_msgs"]:
        success = package_exists(rospack, package) and success

    if check_robot:
        for package in ["wpb_home_bringup", "wpb_home_behaviors"]:
            success = package_exists(rospack, package) and success
        for package in ["kinect2_bridge", "move_base"]:
            package_exists(rospack, package)

    services = rosservice.get_service_list()
    for service in [
        "/vision/scan_request",
        "/arm/execute_pick",
        "/arm/execute_place",
        "/arm/carry_pose",
        "/arm/reset_to_home",
        "/arm/emergency_stop",
    ]:
        success = service_exists(service, services) and success

    topics = dict(rospy.get_published_topics())
    for topic in ["/task/status", "/vision/detected_objects"]:
        topic_exists(topic, topics)
    if check_robot:
        for topic in ["/wpb_home/objects_3d", "/wpb_home/grab_result", "/wpb_home/place_result"]:
            topic_exists(topic, topics)

    if success:
        ok("preflight finished")
        return 0
    fail("preflight found blocking issues")
    return 1


if __name__ == "__main__":
    sys.exit(main())
