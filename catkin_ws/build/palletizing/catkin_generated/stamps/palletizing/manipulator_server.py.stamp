#!/usr/bin/env python3
# coding=utf-8
"""码垛机器人系统 - 机械臂控制 Action Server。

封装启智机器人的 grab_action 和 place_action 厂家接口，
对上层暴露 Grab Action 和 Palletize Action 两个标准 Action 服务。

重要：厂家的 /wpb_home/grab_result 和 /wpb_home/place_result 是
**流式进度话题**，在动作执行过程中会持续发布中间状态消息：
  grab: "object x" → "hand up" → "forward" → "grab" → "object up" → "backward" → "done"
  place: "forward" → "place" → "backward" → "done"
只有收到 "done" 才表示动作成功完成。
"""

from typing import Optional
import threading
import math

import rospy
import actionlib
from geometry_msgs.msg import Pose, Point
from sensor_msgs.msg import JointState
from std_msgs.msg import String

from palletizing.msg import (
    GrabAction,
    GrabGoal,
    GrabFeedback,
    GrabResult,
    PalletizeAction,
    PalletizeGoal,
    PalletizeFeedback,
    PalletizeResult,
)
from palletizing_core.safety_guard import SafetyGuard

# 厂家 grab_result / place_result 的终态消息
_RESULT_DONE = "done"


class ManipulatorServer:
    """机械臂 Action Server，提供抓取与码垛两个 Action 接口。

    抓取通过厂家 /wpb_home/grab_action 实现，
    放置通过厂家 /wpb_home/place_action 实现。
    """

    def __init__(self) -> None:
        self._safety = SafetyGuard()

        self._lift_speed: float = rospy.get_param(
            "~manipulator/lift_speed", 0.5
        )
        self._gripper_speed: float = rospy.get_param(
            "~manipulator/gripper_speed", 5.0
        )
        self._gripper_open: float = rospy.get_param(
            "~manipulator/gripper_open_width", 0.1
        )
        self._height_carry: float = rospy.get_param(
            "~manipulator/height_carry", 0.8
        )
        self._table_height: float = rospy.get_param(
            "~manipulator/table_height", 0.765
        )
        self._block_height: float = rospy.get_param(
            "~manipulator/block_height", 0.10
        )
        self._max_layers: int = rospy.get_param(
            "~manipulator/max_layers", 2
        )

        self._mani_pub = rospy.Publisher(
            "/wpb_home/mani_ctrl", JointState, queue_size=10
        )

        # 厂家抓取接口
        self._grab_pub = rospy.Publisher(
            "/wpb_home/grab_action", Pose, queue_size=1
        )
        self._grab_result: Optional[str] = None
        self._grab_done_event = threading.Event()
        rospy.Subscriber(
            "/wpb_home/grab_result", String,
            self._grab_result_cb, queue_size=10
        )

        # 厂家放置接口
        self._place_pub = rospy.Publisher(
            "/wpb_home/place_action", Pose, queue_size=1
        )
        self._place_result: Optional[str] = None
        self._place_done_event = threading.Event()
        rospy.Subscriber(
            "/wpb_home/place_result", String,
            self._place_result_cb, queue_size=10
        )

        # Grab Action Server
        self._grab_as = actionlib.SimpleActionServer(
            "~grab",
            GrabAction,
            execute_cb=self._grab_execute_cb,
            auto_start=False,
        )
        self._grab_as.start()

        # Palletize Action Server
        self._palletize_as = actionlib.SimpleActionServer(
            "~palletize",
            PalletizeAction,
            execute_cb=self._palletize_execute_cb,
            auto_start=False,
        )
        self._palletize_as.start()

        # 监听关节状态以验证夹爪是否闭合抓空
        self._gripper_position: float = -1.0  # 使用 -1.0 作为未收到数据的特殊标识
        # 兼容仿真话题
        rospy.Subscriber("/wpb_home/joint_states", JointState, self._joint_states_cb, queue_size=10)
        # 兼容实机话题 (wpb_home_core 实机底层固定发布在这个全局话题)
        rospy.Subscriber("/joint_states", JointState, self._joint_states_cb, queue_size=10)

        rospy.loginfo("[ManipulatorServer] Grab/Palletize Action Server 已启动")

    # ━━━ 厂家结果回调 ━━━

    def _joint_states_cb(self, msg: JointState) -> None:
        """监听关节状态，更新夹爪位置。"""
        try:
            # 兼容仿真环境中的关节名称
            if "palm_left_finger" in msg.name:
                idx = msg.name.index("palm_left_finger")
                angle = msg.position[idx]
                self._gripper_position = math.sin(angle) / 5.0 + 0.025
            # 兼容真实环境中的关节名称 (通常叫做 gripper 或者 forearm_left_finger)
            elif "gripper" in msg.name:
                idx = msg.name.index("gripper")
                self._gripper_position = msg.position[idx]
            elif "forearm_left_finger" in msg.name:
                idx = msg.name.index("forearm_left_finger")
                angle = msg.position[idx]
                self._gripper_position = math.sin(angle) / 5.0 + 0.025
        except (ValueError, IndexError):
            pass

    def _grab_result_cb(self, msg: String) -> None:
        """接收厂家抓取行为的流式进度消息。

        厂家 grab_result 话题在执行过程中持续发布:
          "object x" → "hand up" → "forward" → "grab" → "object up" → "backward" → "done"
        只有 "done" 表示完成。中间消息仅用于日志追踪。
        """
        phase = msg.data
        if self._grab_result != phase:
            self._grab_result = phase
            rospy.loginfo("[ManipulatorServer] 抓取进度: %s", phase)
        if phase == _RESULT_DONE:
            self._grab_done_event.set()

    def _place_result_cb(self, msg: String) -> None:
        """接收厂家放置行为的流式进度消息。

        厂家 place_result 话题在执行过程中持续发布:
          "forward" → "place" → "backward" → "done"
        只有 "done" 表示完成。
        """
        phase = msg.data
        if self._place_result != phase:
            self._place_result = phase
            rospy.loginfo("[ManipulatorServer] 放置进度: %s", phase)
        if phase == _RESULT_DONE:
            self._place_done_event.set()

    def _send_mani_cmd(self, lift: float, gripper: float) -> None:
        """发送机械臂控制指令。"""
        msg = JointState()
        msg.name = ["lift", "gripper"]
        msg.position = [lift, gripper]
        msg.velocity = [self._lift_speed, self._gripper_speed]
        self._mani_pub.publish(msg)

    def _sleep_and_check_preempt(self, duration: float, action_server) -> bool:
        """
        休眠指定时间，并持续检查是否被抢占。
        如果被抢占则返回 True，否则正常休眠完返回 False。
        """
        steps = int(duration / 0.1)
        for _ in range(steps):
            if action_server.is_preempt_requested():
                return True
            rospy.sleep(0.1)
        
        remainder = duration - (steps * 0.1)
        if remainder > 0:
            if action_server.is_preempt_requested(): return True
            rospy.sleep(remainder)
            
        return action_server.is_preempt_requested()

    # ━━━ 抓取 Action ━━━

    def _grab_execute_cb(self, goal: GrabGoal) -> None:
        """执行抓取动作：委派给厂家 grab_action 节点。

        流程:
        1. 校验坐标在工作空间内
        2. 发送目标到厂家 /wpb_home/grab_action
        3. 等待厂家完成 (监听 /wpb_home/grab_result 直到 "done")
        4. 抬升到搬运高度

        Args:
            goal: 抓取目标，包含 target_position (base_link 坐标系)
        """
        feedback = GrabFeedback()
        result = GrabResult()
        pos = goal.target_position

        if not self._safety.validate_workspace(pos):
            result.success = False
            result.message = "目标坐标超出安全工作空间"
            rospy.logerr("[ManipulatorServer] %s", result.message)
            self._grab_as.set_aborted(result)
            return

        # 发送抓取指令
        feedback.phase = "sending_grab"
        self._grab_as.publish_feedback(feedback)

        grab_msg = Pose()
        grab_msg.position.x = pos.x
        grab_msg.position.y = pos.y
        grab_msg.position.z = pos.z

        self._grab_done_event.clear()
        self._grab_result = None
        self._grab_pub.publish(grab_msg)
        rospy.loginfo(
            "[ManipulatorServer] 已发送抓取指令: (%.3f, %.3f, %.3f)",
            pos.x, pos.y, pos.z,
        )

        # 等待厂家抓取完成
        # 厂家内部流程: 对齐 → 抬臂 → 前进 → 闭爪 → 抬起 → 后退 → done
        # 整个过程约 30-60 秒
        feedback.phase = "waiting_vendor_grab"
        self._grab_as.publish_feedback(feedback)

        wait_success = False
        for _ in range(1200):  # 1200 * 0.1s = 120s
            if self._grab_as.is_preempt_requested():
                self._safety.stop_grab_behavior()
                self._safety.stop_manipulator()
                result.success = False
                result.message = "抓取动作被紧急中断"
                rospy.logwarn("[ManipulatorServer] %s", result.message)
                self._grab_as.set_preempted(result)
                return
            if self._grab_done_event.wait(timeout=0.1):
                wait_success = True
                break

        if not wait_success:
            self._safety.stop_grab_behavior()
            self._safety.stop_manipulator()
            result.success = False
            result.message = "抓取超时 (120s), 最后进度: %s" % self._grab_result
            rospy.logerr("[ManipulatorServer] %s", result.message)
            self._grab_as.set_aborted(result)
            return

        # 同步等待夹爪状态更新
        if self._sleep_and_check_preempt(0.5, self._grab_as):
            self._safety.stop_grab_behavior()
            self._safety.stop_manipulator()
            result.success = False
            result.message = "等待夹爪时被紧急中断"
            rospy.logwarn("[ManipulatorServer] %s", result.message)
            self._grab_as.set_preempted(result)
            return

        # 验证是否抓取成功 (夹爪完全闭合说明抓空)
        target_grip = rospy.get_param("/wpb_home_grab_action/grab/grab_gripper_value", 0.04)
        grip_tolerance = rospy.get_param("~manipulator/empty_grip_tolerance", 0.005)
        empty_grip_threshold = target_grip + grip_tolerance
        
        # 增加 0.0 <= self._gripper_position 判断：如果是 -1.0，说明没读到状态，直接忽略判空逻辑
        if 0.0 <= self._gripper_position <= empty_grip_threshold:
            self._safety.stop_grab_behavior()
            self._safety.stop_manipulator()
            result.success = False
            result.message = "夹爪完全闭合 (pos=%.3f <= %.3f)，未夹取到货物" % (
                self._gripper_position, empty_grip_threshold
            )
            rospy.logerr("[ManipulatorServer] %s", result.message)
            self._grab_as.set_aborted(result)
            return

        # 抬升到搬运高度
        feedback.phase = "lifting"
        self._grab_as.publish_feedback(feedback)
        self._send_mani_cmd(self._height_carry, target_grip) # 继续施加目标夹紧力，防止掉落
        if self._sleep_and_check_preempt(2.0, self._grab_as):
            self._safety.stop_grab_behavior()
            self._safety.stop_manipulator()
            result.success = False
            result.message = "抓取抬升阶段被紧急中断"
            rospy.logwarn("[ManipulatorServer] %s", result.message)
            self._grab_as.set_preempted(result)
            return

        result.success = True
        result.message = "抓取成功 (pos=%.3f)" % self._gripper_position
        rospy.loginfo("[ManipulatorServer] %s", result.message)
        self._grab_as.set_succeeded(result)

    # ━━━ 码垛放置 Action ━━━

    def _palletize_execute_cb(self, goal: PalletizeGoal) -> None:
        """执行码垛放置：委派给厂家 place_action 节点。

        放置高度 = 桌面高度 + (层数-1) * 积木高度

        Args:
            goal: 码垛目标，包含 layer (层数)
        """
        feedback = PalletizeFeedback()
        result = PalletizeResult()

        # 1. 放置前检测：确认货物在运输途中没有掉落
        # 如果因为颠簸等原因货物掉落，持续施加夹紧力的手指会瞬间完全闭合
        target_grip = rospy.get_param("/wpb_home_grab_action/grab/grab_gripper_value", 0.02)
        grip_tolerance = rospy.get_param("~manipulator/empty_grip_tolerance", 0.005)
        empty_grip_threshold = target_grip + grip_tolerance
        if 0.0 <= self._gripper_position <= empty_grip_threshold:
            self._safety.stop_manipulator()
            result.success = False
            result.message = "运输途中货物掉落 (pos=%.3f <= %.3f)，放弃放置" % (
                self._gripper_position, empty_grip_threshold
            )
            rospy.logerr("[ManipulatorServer] %s", result.message)
            self._palletize_as.set_aborted(result)
            return

        if goal.layer > self._max_layers:
            result.success = False
            result.message = "超出最大码垛层数 (%d)" % self._max_layers
            rospy.logerr("[ManipulatorServer] %s", result.message)
            self._palletize_as.set_aborted(result)
            return

        # 放置高度采用方块质心高度：底面高度 + 半个方块高度
        place_height = (
            self._table_height + (goal.layer - 1) * self._block_height + self._block_height / 2.0
        )
        # 第二层及以上增加 0.5cm 安全余量，避免下降时碰到已放置的方块
        if goal.layer >= 2:
            place_height += 0.005
        rospy.loginfo(
            "[ManipulatorServer] 码垛第%d层, 放置高度=%.3fm",
            goal.layer, place_height,
        )

        # 发送放置指令
        feedback.phase = "sending_place"
        self._palletize_as.publish_feedback(feedback)

        place_msg = Pose()
        default_place_x = rospy.get_param("~task_manager/default_place_x", 0.9)
        place_msg.position.x = goal.place_position.x if goal.place_position.x > 0.1 else default_place_x
        place_msg.position.y = goal.place_position.y
        place_msg.position.z = place_height

        self._place_done_event.clear()
        self._place_result = None
        self._place_pub.publish(place_msg)
        rospy.loginfo(
            "[ManipulatorServer] 已发送放置指令: (%.3f, %.3f, %.3f)",
            place_msg.position.x, place_msg.position.y, place_msg.position.z,
        )

        # 等待厂家放置完成
        feedback.phase = "waiting_vendor_place"
        self._palletize_as.publish_feedback(feedback)

        wait_success = False
        for _ in range(1200):  # 1200 * 0.1s = 120s
            if self._palletize_as.is_preempt_requested():
                self._safety.stop_place_behavior()
                self._safety.stop_manipulator()
                result.success = False
                result.message = "放置动作被紧急中断"
                rospy.logwarn("[ManipulatorServer] %s", result.message)
                self._palletize_as.set_preempted(result)
                return
            if self._place_done_event.wait(timeout=0.1):
                wait_success = True
                break

        if not wait_success:
            self._safety.stop_place_behavior()
            self._safety.stop_manipulator()
            result.success = False
            result.message = "码垛放置超时 (120s), 最后进度: %s" % self._place_result
            rospy.logerr("[ManipulatorServer] %s", result.message)
            self._palletize_as.set_aborted(result)
            return

        # 松手后先抬升机械臂至搬运高度，避免碰撞桌面和已放置的物品
        feedback.phase = "retracting"
        self._palletize_as.publish_feedback(feedback)
        self._send_mani_cmd(self._height_carry, self._gripper_open)
        if self._sleep_and_check_preempt(2.0, self._palletize_as):
            self._safety.stop_place_behavior()
            self._safety.stop_manipulator()
            result.success = False
            result.message = "放置抬升阶段被紧急中断"
            rospy.logwarn("[ManipulatorServer] %s", result.message)
            self._palletize_as.set_preempted(result)
            return

        result.success = True
        result.message = "码垛放置成功 (第%d层)" % goal.layer
        rospy.loginfo("[ManipulatorServer] %s", result.message)
        self._palletize_as.set_succeeded(result)


def main() -> None:
    rospy.init_node("manipulator_server")
    server = ManipulatorServer()
    rospy.on_shutdown(server._safety.emergency_stop)
    rospy.spin()


if __name__ == "__main__":
    main()
