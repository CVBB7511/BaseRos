#!/usr/bin/env python3

import threading

import rospy
from geometry_msgs.msg import Pose
from sensor_msgs.msg import JointState
from std_msgs.msg import String

from warehouse_sorting.arm_sequences import TabletopArmPlanner
from warehouse_sorting.ros_conversions import pose_msg_to_dict
from warehouse_sorting_msgs.srv import ArmCommand, ArmCommandResponse


class ArmControlNode:
    def __init__(self):
        self.dry_run = bool(rospy.get_param("~dry_run", True))
        self.simulate_latency = float(rospy.get_param("~simulate_latency", 0.2))
        self.publish_wpb_home = bool(rospy.get_param("~publish_wpb_home_topics", False))
        arm_config = rospy.get_param("/warehouse_sorting/arm", {})
        self.tabletop_only = bool(rospy.get_param("~tabletop_only", arm_config.get("tabletop_only", True)))
        self.use_wpb_home_actions = bool(
            rospy.get_param("~use_wpb_home_actions", arm_config.get("use_wpb_home_actions", False))
        )
        self.wait_for_wpb_home_result = bool(rospy.get_param("~wait_for_wpb_home_result", False))
        self.result_timeout = float(rospy.get_param("~result_timeout", 25.0))
        self.lift_velocity = float(arm_config.get("lift", {}).get("velocity", 0.5))
        self.gripper_velocity = float(arm_config.get("gripper", {}).get("velocity", 5.0))
        self.planner = TabletopArmPlanner(arm_config)
        self.emergency_stopped = False
        self._result_events = {"pick": threading.Event(), "place": threading.Event()}
        self._last_results = {"pick": "", "place": ""}

        self.grab_pub = None
        self.place_pub = None
        self.mani_pub = None
        if self.publish_wpb_home:
            self.grab_pub = rospy.Publisher("/wpb_home/grab_action", Pose, queue_size=10)
            self.place_pub = rospy.Publisher("/wpb_home/place_action", Pose, queue_size=10)
            self.mani_pub = rospy.Publisher("/wpb_home/mani_ctrl", JointState, queue_size=10)
            rospy.Subscriber("/wpb_home/grab_result", String, self._on_grab_result, queue_size=10)
            rospy.Subscriber("/wpb_home/place_result", String, self._on_place_result, queue_size=10)

        rospy.Service("/arm/execute_pick", ArmCommand, self.handle_pick)
        rospy.Service("/arm/execute_place", ArmCommand, self.handle_place)
        rospy.Service("/arm/carry_pose", ArmCommand, self.handle_carry_pose)
        rospy.Service("/arm/reset_to_home", ArmCommand, self.handle_reset)
        rospy.Service("/arm/emergency_stop", ArmCommand, self.handle_emergency_stop)
        rospy.loginfo(
            "arm_control ready, dry_run=%s, tabletop_only=%s, use_wpb_home_actions=%s, publish_wpb_home_topics=%s",
            self.dry_run,
            self.tabletop_only,
            self.use_wpb_home_actions,
            self.publish_wpb_home,
        )

    def handle_pick(self, request):
        if self.emergency_stopped:
            return ArmCommandResponse(False, "arm is emergency stopped")
        return self._execute_arm_action("pick", request.cargo.pose, request.cargo.cargo_id)

    def handle_place(self, request):
        if self.emergency_stopped:
            return ArmCommandResponse(False, "arm is emergency stopped")
        return self._execute_arm_action("place", request.target_pose, request.cargo.cargo_id)

    def handle_carry_pose(self, _request):
        if self.emergency_stopped:
            return ArmCommandResponse(False, "arm is emergency stopped")
        self._sleep()
        self._publish_joint_state(lift=self.planner.carry_lift, gripper=self.planner.close_width)
        return ArmCommandResponse(True, "carry pose reached")

    def handle_reset(self, _request):
        self.emergency_stopped = False
        self._sleep()
        self._publish_joint_state(lift=self.planner.home_lift, gripper=self.planner.open_width)
        return ArmCommandResponse(True, "arm reset to home")

    def handle_emergency_stop(self, _request):
        self.emergency_stopped = True
        self._publish_joint_state(lift=self.planner.home_lift, gripper=self.planner.open_width)
        return ArmCommandResponse(True, "emergency stop accepted")

    def _execute_arm_action(self, action, pose_msg, cargo_id):
        pose = pose_msg_to_dict(pose_msg)
        if self.tabletop_only:
            try:
                steps = self.planner.plan(action, pose)
            except ValueError as exc:
                return ArmCommandResponse(False, str(exc))
            if self.dry_run:
                self._sleep()
                return ArmCommandResponse(
                    True,
                    "%s tabletop dry-run accepted for %s (%d steps)"
                    % (action, cargo_id, len(steps)),
                )
            if not self.mani_pub:
                return ArmCommandResponse(False, "tabletop arm output is not configured")
            for step in steps:
                rospy.loginfo(
                    "tabletop arm %s step=%s lift=%.3f gripper=%.3f",
                    action,
                    step.label,
                    step.lift,
                    step.gripper,
                )
                self._publish_joint_state(lift=step.lift, gripper=step.gripper)
                rospy.sleep(step.duration)
            return ArmCommandResponse(True, "%s tabletop sequence completed for %s" % (action, cargo_id))

        self._sleep()
        if self.use_wpb_home_actions:
            if action == "pick" and self.grab_pub:
                self._reset_result("pick")
                self.grab_pub.publish(pose_msg)
                if not self._wait_for_result("pick"):
                    return ArmCommandResponse(False, "pick result timeout")
            elif action == "place" and self.place_pub:
                self._reset_result("place")
                self.place_pub.publish(pose_msg)
                if not self._wait_for_result("place"):
                    return ArmCommandResponse(False, "place result timeout")
            elif not self.dry_run:
                return ArmCommandResponse(False, "legacy WPB action output is not configured")
        return ArmCommandResponse(True, "%s accepted for %s" % (action, cargo_id))

    def _sleep(self):
        if self.dry_run and self.simulate_latency > 0.0:
            rospy.sleep(self.simulate_latency)

    def _on_grab_result(self, msg):
        self._last_results["pick"] = msg.data
        if msg.data == "done":
            self._result_events["pick"].set()

    def _on_place_result(self, msg):
        self._last_results["place"] = msg.data
        if msg.data == "done":
            self._result_events["place"].set()

    def _reset_result(self, action):
        self._last_results[action] = ""
        self._result_events[action].clear()

    def _wait_for_result(self, action):
        if not self.wait_for_wpb_home_result:
            return True
        return self._result_events[action].wait(self.result_timeout)

    def _publish_joint_state(self, lift, gripper):
        if not self.mani_pub:
            return
        msg = JointState()
        msg.name = ["lift", "gripper"]
        msg.position = [float(lift), float(gripper)]
        msg.velocity = [self.lift_velocity, self.gripper_velocity]
        self.mani_pub.publish(msg)


if __name__ == "__main__":
    rospy.init_node("arm_control")
    ArmControlNode()
    rospy.spin()
