#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
餐厅服务机器人系统链路测试脚本。

用途：
1. 不依赖真实语音识别；
2. 不依赖真实机器人；
3. 不依赖 move_base；
4. 通过发布 /voice_cmd，自动测试主控、任务调度、导航管理之间的话题链路。

测试前提：
1. restaurant_system.launch 已经启动；
2. task_dispatcher 的 test_mode=true；
3. navigation_manager 的 mock_navigation=true。

测试链路：
system_chain_test
    ↓ /voice_cmd
robot_controller
    ↓ /restaurant/task_name
task_dispatcher
    ↓ /restaurant/nav_target
navigation_manager
    ↓ /restaurant/nav_status
task_dispatcher
    ↓ /restaurant/task_status
robot_controller
"""

import json
import sys
import time
from typing import List

import rospy
from std_msgs.msg import String


class SystemChainTest:
    """系统链路测试器。"""

    def __init__(self):
        rospy.init_node("system_chain_test", anonymous=True)

        self.voice_cmd_pub = rospy.Publisher(
            "/voice_cmd",
            String,
            queue_size=10
        )

        self.received_task_status: List[str] = []
        self.received_nav_status: List[str] = []
        self.received_robot_state: List[str] = []
        self.received_tts: List[str] = []
        self.received_exception_events: List[str] = []

        rospy.Subscriber(
            "/restaurant/task_status",
            String,
            self.task_status_callback
        )

        rospy.Subscriber(
            "/restaurant/nav_status",
            String,
            self.nav_status_callback
        )

        rospy.Subscriber(
            "/robot_state",
            String,
            self.robot_state_callback
        )

        rospy.Subscriber(
            "/tts_speak",
            String,
            self.tts_callback
        )

        rospy.Subscriber(
            "/restaurant/exception_event",
            String,
            self.exception_event_callback
        )

        self.wait_for_subscribers()

    def wait_for_subscribers(self):
        """
        等待 ROS 话题连接建立。

        如果刚启动就发布消息，可能 robot_controller 还没来得及订阅 /voice_cmd。
        """
        rospy.loginfo("等待 /voice_cmd 订阅者连接...")

        start = time.time()
        while not rospy.is_shutdown():
            if self.voice_cmd_pub.get_num_connections() > 0:
                rospy.loginfo("/voice_cmd 已有订阅者，开始测试。")
                return

            if time.time() - start > 10:
                rospy.logwarn(
                    "等待 /voice_cmd 订阅者超时，仍继续测试。"
                )
                return

            rospy.sleep(0.2)

    def task_status_callback(self, msg: String):
        status = msg.data.strip()
        self.received_task_status.append(status)
        rospy.loginfo("[OBSERVE task_status] %s", status)

    def nav_status_callback(self, msg: String):
        status = msg.data.strip()
        self.received_nav_status.append(status)
        rospy.loginfo("[OBSERVE nav_status] %s", status)

    def robot_state_callback(self, msg: String):
        state = msg.data.strip()
        self.received_robot_state.append(state)
        rospy.loginfo("[OBSERVE robot_state] %s", state)

    def tts_callback(self, msg: String):
        text = msg.data.strip()
        self.received_tts.append(text)
        rospy.loginfo("[OBSERVE tts_speak] %s", text)

    def exception_event_callback(self, msg: String):
        event = msg.data.strip()
        self.received_exception_events.append(event)
        rospy.logwarn("[OBSERVE exception_event] %s", event)

    def publish_voice_cmd(self, intent: str, slots=None, raw_text: str = ""):
        if slots is None:
            slots = {}

        payload = {
            "source": "system_chain_test",
            "intent": intent,
            "slots": slots,
            "raw_text": raw_text,
            "timestamp": rospy.Time.now().to_sec()
        }

        msg = json.dumps(payload, ensure_ascii=False)
        rospy.loginfo("[PUBLISH voice_cmd] %s", msg)
        self.voice_cmd_pub.publish(String(data=msg))

    def wait_for_status(self, expected_prefix: str, timeout: float = 20.0) -> bool:
        """
        等待 /restaurant/task_status 出现指定前缀。

        例如：
        TASK_DONE:guide_table_1
        TASK_DONE:deliver_table_1
        """
        rospy.loginfo("等待任务状态：%s", expected_prefix)

        start = time.time()
        checked_index = 0

        while not rospy.is_shutdown():
            while checked_index < len(self.received_task_status):
                status = self.received_task_status[checked_index]
                checked_index += 1

                if status.startswith(expected_prefix):
                    rospy.loginfo("检测到期望状态：%s", status)
                    return True

                if status.startswith("TASK_FAILED"):
                    rospy.logerr("检测到任务失败状态：%s", status)
                    return False

            if time.time() - start > timeout:
                rospy.logerr("等待状态超时：%s", expected_prefix)
                return False

            rospy.sleep(0.2)

    def clear_observed_status(self):
        self.received_task_status.clear()
        self.received_nav_status.clear()
        self.received_robot_state.clear()
        self.received_tts.clear()
        self.received_exception_events.clear()

    def test_welcome_guide(self) -> bool:
        """
        测试迎宾带位链路。

        输入：
        seat_request，customer_count=2

        期望：
        robot_controller 创建 guide_table_1；
        task_dispatcher 执行该任务；
        navigation_manager 模拟到达；
        最终出现 TASK_DONE:guide_table_1。
        """
        rospy.loginfo("========== 开始测试：迎宾带位链路 ==========")
        self.clear_observed_status()

        self.publish_voice_cmd(
            intent="seat_request",
            slots={
                "customer_count": 2
            },
            raw_text="我要两人桌"
        )

        ok = self.wait_for_status(
            expected_prefix="TASK_DONE:guide_table_",
            timeout=30.0
        )

        if ok:
            rospy.loginfo("迎宾带位链路测试通过。")
        else:
            rospy.logerr("迎宾带位链路测试失败。")

        return ok

    def test_delivery(self) -> bool:
        """
        测试送餐链路。

        输入：
        switch_delivery_mode，target_table=table_1，task_name=deliver_table_1

        期望：
        robot_controller 创建 deliver_table_1；
        task_dispatcher 执行该任务；
        navigation_manager 模拟到达；
        最终出现 TASK_DONE:deliver_table_1。
        """
        rospy.loginfo("========== 开始测试：送餐链路 ==========")
        self.clear_observed_status()

        self.publish_voice_cmd(
            intent="switch_delivery_mode",
            slots={
                "target_table": "table_1",
                "task_name": "deliver_table_1"
            },
            raw_text="开始送餐"
        )

        ok = self.wait_for_status(
            expected_prefix="TASK_DONE:deliver_table_1",
            timeout=30.0
        )

        if ok:
            rospy.loginfo("送餐链路测试通过。")
        else:
            rospy.logerr("送餐链路测试失败。")

        return ok

    def print_summary(self, passed: bool):
        rospy.loginfo("")
        rospy.loginfo("========== 系统链路测试结果汇总 ==========")

        rospy.loginfo("接收到的 /restaurant/task_status：")
        for status in self.received_task_status:
            rospy.loginfo("  %s", status)

        rospy.loginfo("接收到的 /restaurant/exception_event：")
        if not self.received_exception_events:
            rospy.loginfo("  无异常事件。")
        else:
            for event in self.received_exception_events:
                rospy.logwarn("  %s", event)

        rospy.loginfo("接收到的 /restaurant/nav_status：")
        for status in self.received_nav_status:
            rospy.loginfo("  %s", status)

        rospy.loginfo("接收到的 /robot_state：")
        for state in self.received_robot_state:
            rospy.loginfo("  %s", state)

        rospy.loginfo("接收到的 /tts_speak：")
        for text in self.received_tts:
            rospy.loginfo("  %s", text)

        if passed:
            rospy.loginfo("最终结论：系统链路测试通过。")
        else:
            rospy.logerr("最终结论：系统链路测试未通过。")

    def run(self) -> bool:
        """
        顺序执行系统链路测试。
        """
        welcome_ok = self.test_welcome_guide()

        rospy.sleep(2.0)

        delivery_ok = self.test_delivery()

        passed = welcome_ok and delivery_ok
        self.print_summary(passed)

        return passed


def main():
    tester = SystemChainTest()
    passed = tester.run()

    if passed:
        sys.exit(0)

    sys.exit(1)


if __name__ == "__main__":
    try:
        main()
    except rospy.ROSInterruptException:
        pass