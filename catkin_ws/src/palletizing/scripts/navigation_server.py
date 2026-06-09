#!/usr/bin/env python3
# coding=utf-8
"""码垛机器人系统 - 导航 Action Server。

封装底层 move_base Action 客户端，对上层暴露统一的 Navigate Action 接口。
支持通过航点名称或直接位姿两种方式指定导航目标。
"""

import math
from typing import Dict, Any, Optional

import rospy
import actionlib
from move_base_msgs.msg import MoveBaseAction, MoveBaseGoal
from geometry_msgs.msg import Pose
from nav_msgs.msg import Odometry
from tf.transformations import quaternion_from_euler

from palletizing.msg import (
    NavigateAction,
    NavigateGoal,
    NavigateFeedback,
    NavigateResult,
)
from palletizing_core.safety_guard import SafetyGuard


class NavigationServer:
    """导航 Action Server，桥接上层任务管理与底层 move_base。

    Attributes:
        _as: Navigate Action 服务端
        _move_base_client: move_base Action 客户端
        _safety: 安全防护器
        _zones: 已注册的区域航点配置
        _current_pose: 机器人当前位姿 (来自里程计)
        _nav_timeout: 导航超时时间 (秒)
    """

    def __init__(self) -> None:
        self._safety = SafetyGuard()
        self._nav_timeout: float = rospy.get_param(
            "~navigation/timeout_sec", 60.0
        )
        self._zones: Dict[str, Dict[str, Any]] = rospy.get_param("~zones", {})
        self._current_pose: Optional[Pose] = None

        self._odom_sub = rospy.Subscriber(
            "/odom", Odometry, self._odom_callback, queue_size=1
        )

        # move_base 在全局命名空间
        self._move_base_client = actionlib.SimpleActionClient(
            "/move_base", MoveBaseAction
        )
        rospy.loginfo("[NavigationServer] 等待 move_base 服务...")
        self._move_base_client.wait_for_server(
            timeout=rospy.Duration(30.0)
        )
        rospy.loginfo("[NavigationServer] move_base 已连接")

        self._as = actionlib.SimpleActionServer(
            "~navigate",
            NavigateAction,
            execute_cb=self._execute_cb,
            auto_start=False,
        )
        self._as.start()
        rospy.loginfo("[NavigationServer] Navigate Action Server 已启动")

    def _odom_callback(self, msg: Odometry) -> None:
        """缓存当前里程计位姿，用于计算导航剩余距离。"""
        self._current_pose = msg.pose.pose

    def _execute_cb(self, goal: NavigateGoal) -> None:
        """处理导航请求的核心回调。

        Args:
            goal: 导航目标，可通过 target_name (航点名) 或 target_pose (位姿) 指定
        """
        feedback = NavigateFeedback()
        result = NavigateResult()

        target_pose = self._resolve_target(goal)
        if target_pose is None:
            result.success = False
            result.message = "无法解析导航目标: name='%s'" % goal.target_name
            rospy.logerr("[NavigationServer] %s", result.message)
            self._as.set_aborted(result)
            return

        mb_goal = MoveBaseGoal()
        mb_goal.target_pose.header.frame_id = "map"
        mb_goal.target_pose.header.stamp = rospy.Time.now()
        mb_goal.target_pose.pose = target_pose

        rospy.loginfo(
            "[NavigationServer] 导航目标: (%.2f, %.2f)",
            target_pose.position.x,
            target_pose.position.y,
        )
        self._move_base_client.send_goal(mb_goal)

        rate = rospy.Rate(2)
        start_time = rospy.Time.now()

        while not rospy.is_shutdown():
            if self._as.is_preempt_requested():
                self._move_base_client.cancel_goal()
                self._safety.stop_chassis()
                result.success = False
                result.message = "导航被取消"
                rospy.logwarn("[NavigationServer] %s", result.message)
                self._as.set_preempted(result)
                return

            elapsed = (rospy.Time.now() - start_time).to_sec()
            if elapsed > self._nav_timeout:
                self._move_base_client.cancel_goal()
                self._safety.emergency_stop()
                result.success = False
                result.message = "导航超时 (%.1fs)" % elapsed
                rospy.logerr("[NavigationServer] %s", result.message)
                self._as.set_aborted(result)
                return

            state = self._move_base_client.get_state()
            if state == actionlib.GoalStatus.SUCCEEDED:
                result.success = True
                result.message = "导航成功"
                rospy.loginfo("[NavigationServer] %s", result.message)
                self._as.set_succeeded(result)
                return

            if state in (
                actionlib.GoalStatus.ABORTED,
                actionlib.GoalStatus.REJECTED,
            ):
                self._safety.stop_chassis()
                result.success = False
                result.message = "move_base 报告失败 (state=%d)" % state
                rospy.logerr("[NavigationServer] %s", result.message)
                self._as.set_aborted(result)
                return

            if state == actionlib.GoalStatus.PREEMPTED:
                # move_base 被外部取消 (如手柄抢占)
                result.success = False
                result.message = "导航被外部取消 (手柄抢占)"
                rospy.logwarn("[NavigationServer] %s", result.message)
                self._as.set_preempted(result)
                return

            feedback.distance_remaining = self._calc_distance(target_pose)
            feedback.status = "navigating"
            self._as.publish_feedback(feedback)
            rate.sleep()

    def _resolve_target(self, goal: NavigateGoal) -> Optional[Pose]:
        """将导航目标解析为 Pose。

        命名规则:
          - "A"        → 区域A的观测点 (observation_point)
          - "A__place"  → 区域A的放置起始点 (placement.start_x/y)
          - 空名称       → 使用 goal 中直接携带的 target_pose

        Args:
            goal: 导航目标

        Returns:
            解析后的 Pose，或 None (解析失败)
        """
        if goal.target_name:
            place_suffix = "__place"
            is_place = goal.target_name.endswith(place_suffix)
            zone_key = (
                goal.target_name[: -len(place_suffix)]
                if is_place
                else goal.target_name
            )

            zone_cfg = self._zones.get(zone_key)
            if zone_cfg is None:
                return None

            # 无论是观测还是放置，机器人都站立在同一个点 (观测点)
            # 因为码垛偏移量会在 manipulator 阶段通过相对于 base_link 的坐标进行处理
            obs = zone_cfg.get("observation_point")
            if obs is None:
                return None

            pose = Pose()
            pose.position.x = obs["x"]
            pose.position.y = obs["y"]
            pose.position.z = obs.get("z", 0.0)
            yaw = obs.get("yaw", 0.0)

            q = quaternion_from_euler(0, 0, yaw)
            pose.orientation.x = q[0]
            pose.orientation.y = q[1]
            pose.orientation.z = q[2]
            pose.orientation.w = q[3]
            return pose

        # 回退到直接使用 goal 中携带的位姿
        if goal.target_pose.position.x == 0.0 and \
           goal.target_pose.position.y == 0.0:
            return None
        return goal.target_pose

    def _calc_distance(self, target: Pose) -> float:
        """计算当前位置到目标的平面欧氏距离。"""
        if self._current_pose is None:
            return float("inf")
        dx = target.position.x - self._current_pose.position.x
        dy = target.position.y - self._current_pose.position.y
        return math.hypot(dx, dy)


def main() -> None:
    rospy.init_node("navigation_server")
    server = NavigationServer()
    rospy.on_shutdown(server._safety.stop_chassis)
    rospy.spin()


if __name__ == "__main__":
    main()
