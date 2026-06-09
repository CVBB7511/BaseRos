#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
餐厅服务机器人任务调度节点。

职责：
1. 订阅 /restaurant/task_name，接收主控模块下发的业务任务名称；
2. 根据 restaurant_task_routes.yaml 将业务任务拆分为导航点序列；
3. 逐个向 /restaurant/nav_target 发布导航目标点；
4. 监听 /restaurant/nav_status，判断每个导航点是否到达；
5. 向 /restaurant/task_status 发布任务状态，供 robot_controller 和 voice_interaction_node 使用。

支持两种运行方式：
1. 真实/仿真机器人模式：需要定位完成后才能执行任务；
2. 测试模式：可跳过定位与自动回待命区，便于周一测试评审做 ROS 话题级集成测试。
"""

import os
import queue
import threading
from pathlib import Path

import rospy
import rospkg
import yaml
from std_msgs.msg import Bool, String


class TaskDispatcher:
    """业务任务调度器。"""

    def __init__(self):
        rospy.init_node("task_dispatcher", anonymous=False)

        self.package_name = rospy.get_param("~package_name", "wpr_simulation")
        self.nav_points_rel_path = rospy.get_param(
            "~nav_points_rel_path",
            "config/restaurant_nav_points.yaml"
        )
        self.task_routes_rel_path = rospy.get_param(
            "~task_routes_rel_path",
            "config/restaurant_task_routes.yaml"
        )

        # 测试模式：用于没有真实机器人、没有 move_base、没有手动 2D Pose Estimate 的情况下，
        # 先验证 voice_interaction_node -> robot_controller -> task_dispatcher 的话题链路。
        self.test_mode = self._to_bool(rospy.get_param("~test_mode", False))

        self.require_localization = self._to_bool(
            rospy.get_param("~require_localization", not self.test_mode)
        )
        self.auto_home_enabled = self._to_bool(
            rospy.get_param("~auto_home_enabled", not self.test_mode)
        )

        self.nav_points = self.load_yaml(self.nav_points_rel_path, "nav_points")
        self.task_routes = self.load_yaml(self.task_routes_rel_path, "task_routes")

        self.nav_target_pub = rospy.Publisher(
            "/restaurant/nav_target",
            String,
            queue_size=10
        )
        self.nav_cancel_pub = rospy.Publisher(
            "/restaurant/nav_cancel",
            Bool,
            queue_size=10
        )
        self.task_status_pub = rospy.Publisher(
            "/restaurant/task_status",
            String,
            queue_size=10
        )

        rospy.Subscriber("/restaurant/task_name", String, self.task_name_callback)
        rospy.Subscriber("/restaurant/task_cancel", Bool, self.task_cancel_callback)
        rospy.Subscriber("/restaurant/nav_status", String, self.nav_status_callback)
        rospy.Subscriber(
            "/restaurant/localization_ready",
            Bool,
            self.localization_ready_callback
        )

        self.lock = threading.Lock()
        self.busy = False
        self.current_task = None
        self.cancel_requested = False

        self.localization_ready = not self.require_localization
        self.system_ready = not self.require_localization
        self.homing_in_progress = False

        self.nav_status_queue = queue.Queue()

        self.publish_task_status("TASK_IDLE")

        if self.test_mode:
            self.publish_task_status("TEST_MODE")
            self.publish_task_status("SYSTEM_READY")
            rospy.logwarn(
                "task_dispatcher 当前处于测试模式：跳过定位检查和自动回待命区。"
            )
        elif self.require_localization:
            self.publish_task_status("WAIT_LOCALIZATION")
            rospy.loginfo(
                "当前状态：WAIT_LOCALIZATION。需要完成 2D Pose Estimate 后发布 "
                "/restaurant/localization_ready=true。"
            )
        else:
            self.publish_task_status("SYSTEM_READY")
            rospy.loginfo("当前状态：SYSTEM_READY。已关闭定位前置检查。")

        rospy.loginfo("task_dispatcher 启动完成")

    @staticmethod
    def _to_bool(value) -> bool:
        if isinstance(value, bool):
            return value
        return str(value).strip().lower() in {"true", "1", "yes", "y", "on"}

    def resolve_yaml_path(self, rel_path: str) -> str:
        """
        解析 YAML 配置文件路径。

        优先级：
        1. 如果 rel_path 本身是绝对路径，直接使用；
        2. 尝试从 ROS package 中读取，例如 wpr_simulation/config/xxx.yaml；
        3. 如果当前代码还没有部署到 ROS package，则回退到 GitLab 项目结构：src/config/xxx.yaml。
        """
        candidate = Path(rel_path)
        if candidate.is_absolute() and candidate.exists():
            return str(candidate)

        try:
            rospack = rospkg.RosPack()
            package_path = Path(rospack.get_path(self.package_name))
            package_candidate = package_path / rel_path
            if package_candidate.exists():
                return str(package_candidate)
        except Exception as exc:
            rospy.logwarn(
                "无法通过 rospack 定位 package %s: %s",
                self.package_name,
                str(exc)
            )

        project_root = Path(__file__).resolve().parents[2]
        fallback_candidates = [
            project_root / "src" / rel_path,
            project_root / rel_path,
            project_root / "src" / "config" / Path(rel_path).name,
        ]

        for fallback in fallback_candidates:
            if fallback.exists():
                return str(fallback)

        raise FileNotFoundError(
            f"配置文件不存在: rel_path={rel_path}, package={self.package_name}"
        )

    def load_yaml(self, rel_path: str, root_key: str):
        yaml_path = self.resolve_yaml_path(rel_path)

        with open(yaml_path, "r", encoding="utf-8") as file:
            data = yaml.safe_load(file) or {}

        if root_key not in data:
            rospy.logerr("配置文件中缺少 %s 字段: %s", root_key, yaml_path)
            raise KeyError(root_key)

        rospy.loginfo("已加载配置文件: %s", yaml_path)
        return data[root_key]

    def publish_task_status(self, text: str):
        self.task_status_pub.publish(String(data=text))
        rospy.loginfo("[task_status] %s", text)

    def nav_status_callback(self, msg: String):
        try:
            self.nav_status_queue.put_nowait(msg.data)
        except queue.Full:
            pass

    def localization_ready_callback(self, msg: Bool):
        if not self.require_localization:
            self.localization_ready = True
            self.system_ready = True
            self.publish_task_status("SYSTEM_READY")
            return

        ready = bool(msg.data)
        self.localization_ready = ready
        rospy.loginfo("定位确认状态更新为：%s", self.localization_ready)

        if ready:
            if not self.auto_home_enabled:
                self.system_ready = True
                self.publish_task_status("SYSTEM_READY")
                return

            with self.lock:
                if self.busy or self.homing_in_progress or self.system_ready:
                    return
                self.homing_in_progress = True

            worker = threading.Thread(target=self.auto_home_to_wait_area)
            worker.daemon = True
            worker.start()
        else:
            self.system_ready = False
            self.publish_task_status("WAIT_LOCALIZATION")

    def task_name_callback(self, msg: String):
        task_name = (msg.data or "").strip()

        if not task_name:
            self.publish_task_status("TASK_FAILED:EMPTY_TASK")
            return

        if self.require_localization and not self.localization_ready:
            self.publish_task_status(f"TASK_FAILED:{task_name}:LOCALIZATION_NOT_READY")
            return

        if self.require_localization and not self.system_ready:
            self.publish_task_status(f"TASK_FAILED:{task_name}:SYSTEM_NOT_READY")
            return

        with self.lock:
            if self.busy or self.homing_in_progress:
                busy_name = self.current_task if self.current_task else "SYSTEM_HOMING"
                self.publish_task_status(f"TASK_BUSY:{busy_name}")
                return

            self.busy = True
            self.current_task = task_name
            self.cancel_requested = False

        worker = threading.Thread(target=self.execute_task, args=(task_name,))
        worker.daemon = True
        worker.start()

    def task_cancel_callback(self, msg: Bool):
        if not msg.data:
            return

        with self.lock:
            if not self.busy and not self.homing_in_progress:
                self.publish_task_status("TASK_IDLE")
                return

            if self.cancel_requested:
                return

            self.cancel_requested = True
            current_name = self.current_task if self.current_task else "SYSTEM_HOMING"

        rospy.logwarn("收到任务取消请求: %s", current_name)
        self.nav_cancel_pub.publish(Bool(data=True))

    def resolve_task(self, task_name: str):
        if task_name not in self.task_routes:
            rospy.logerr("未知任务: %s", task_name)
            return None

        route = self.task_routes[task_name]
        if not isinstance(route, list) or len(route) == 0:
            rospy.logerr("任务路线为空或格式错误: %s", task_name)
            return None

        for point_name in route:
            if point_name not in self.nav_points:
                rospy.logerr("任务 %s 引用了不存在的导航点: %s", task_name, point_name)
                return None

        return route

    def clear_nav_status_queue(self):
        while not self.nav_status_queue.empty():
            try:
                self.nav_status_queue.get_nowait()
            except queue.Empty:
                break

    def wait_for_nav_result(self, expected_point: str):
        """
        等待 navigation_manager 返回指定导航点的结果。

        不能只等 ARRIVED:<point>，因为 navigation_manager 在发布 ARRIVED 后，
        还会再发布一次 IDLE，且内部 busy 标志是在这个收尾过程中才真正释放。
        所以这里必须等 ARRIVED 之后再等 IDLE，才能安全进入下一步。
        """
        arrived_seen = False

        while not rospy.is_shutdown():
            if self.cancel_requested:
                return "CANCELED"

            try:
                status = self.nav_status_queue.get(timeout=0.5)
            except queue.Empty:
                continue

            if status.startswith("NAVIGATING:"):
                continue

            if status == f"ARRIVED:{expected_point}":
                arrived_seen = True
                continue

            if arrived_seen and status == "IDLE":
                return "ARRIVED"

            if status.startswith("FAILED:"):
                return "FAILED"

            if status.startswith("CANCELED:"):
                return "CANCELED"

            if status.startswith("UNKNOWN_POINT:"):
                return "FAILED"

            if status.startswith("BUSY:"):
                if arrived_seen:
                    continue
                return "FAILED"

            if status == "IDLE":
                continue

    def auto_home_to_wait_area(self):
        try:
            self.publish_task_status("SYSTEM_HOMING:wait_area")
            self.clear_nav_status_queue()
            self.cancel_requested = False

            self.nav_target_pub.publish(String(data="wait_area"))
            result = self.wait_for_nav_result("wait_area")

            if result == "ARRIVED":
                self.system_ready = True
                self.publish_task_status("SYSTEM_READY")
            elif result == "CANCELED":
                self.system_ready = False
                self.publish_task_status("SYSTEM_HOMING_CANCELED")
            else:
                self.system_ready = False
                self.publish_task_status("SYSTEM_HOMING_FAILED")

        finally:
            with self.lock:
                self.homing_in_progress = False
                self.cancel_requested = False

            self.publish_task_status("TASK_IDLE")

    def execute_task(self, task_name: str):
        final_status = None

        try:
            route = self.resolve_task(task_name)

            if route is None:
                final_status = f"TASK_FAILED:UNKNOWN_TASK:{task_name}"
                return

            self.publish_task_status(f"TASK_START:{task_name}")

            total_steps = len(route)

            for index, point_name in enumerate(route, start=1):
                if self.cancel_requested:
                    final_status = f"TASK_CANCELED:{task_name}"
                    return

                self.publish_task_status(f"TASK_STEP:{index}/{total_steps}:{point_name}")

                self.clear_nav_status_queue()
                self.nav_target_pub.publish(String(data=point_name))

                result = self.wait_for_nav_result(point_name)

                if result == "ARRIVED":
                    continue

                if result == "CANCELED":
                    final_status = f"TASK_CANCELED:{task_name}"
                    return

                final_status = f"TASK_FAILED:{task_name}"
                return

            final_status = f"TASK_DONE:{task_name}"

        except Exception as exc:
            rospy.logerr("任务执行异常: %s", str(exc))
            final_status = f"TASK_FAILED:{task_name}:EXCEPTION"

        finally:
            if final_status is not None:
                self.publish_task_status(final_status)

            with self.lock:
                self.busy = False
                self.current_task = None
                self.cancel_requested = False

            self.publish_task_status("TASK_IDLE")


def main():
    TaskDispatcher()
    rospy.spin()


if __name__ == "__main__":
    try:
        main()
    except rospy.ROSInterruptException:
        pass
