#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
餐厅服务机器人导航管理节点。

职责：
1. 订阅 /restaurant/nav_target，接收任务调度模块下发的导航目标点；
2. 根据 restaurant_nav_points.yaml 查询目标点坐标；
3. 在真实/仿真机器人模式下，通过 move_base 执行导航；
4. 在测试模式下，模拟导航到达，便于无机器人环境下完成系统链路测试；
5. 发布 /restaurant/nav_status，反馈导航状态。

支持两种运行方式：
1. 真实/仿真机器人模式：
   - mock_navigation=false
   - 需要 WPB-Home 仿真或真实机器人环境提供 /move_base action server

2. 测试模式：
   - mock_navigation=true
   - 不依赖 move_base
   - 收到目标点后延迟一段时间，自动发布 ARRIVED:<target>
"""

import os
import threading
from pathlib import Path

import rospy
import rospkg
import yaml
from std_msgs.msg import String, Bool

try:
    import actionlib
    from move_base_msgs.msg import MoveBaseAction, MoveBaseGoal
    from actionlib_msgs.msg import GoalStatus
    from tf.transformations import quaternion_from_euler

    MOVE_BASE_AVAILABLE = True
    MOVE_BASE_IMPORT_ERROR = None
except Exception as exc:
    actionlib = None
    MoveBaseAction = None
    MoveBaseGoal = None
    GoalStatus = None
    quaternion_from_euler = None

    MOVE_BASE_AVAILABLE = False
    MOVE_BASE_IMPORT_ERROR = exc


class NavigationManager:
    """餐厅服务机器人导航管理器。"""

    def __init__(self):
        rospy.init_node("navigation_manager", anonymous=False)

        self.package_name = rospy.get_param("~package_name", "wpr_simulation")
        self.config_rel_path = rospy.get_param(
            "~config_rel_path",
            "config/restaurant_nav_points.yaml"
        )

        # 测试模式：
        # true  表示不连接 move_base，只根据配置文件模拟导航到达；
        # false 表示真实调用 move_base，适合 WPB-Home 仿真或真实机器人。
        self.mock_navigation = self._to_bool(
            rospy.get_param("~mock_navigation", False)
        )

        self.mock_arrival_delay = float(
            rospy.get_param("~mock_arrival_delay", 1.0)
        )

        self.move_base_wait_timeout = float(
            rospy.get_param("~move_base_wait_timeout", 10.0)
        )

        self.navigation_timeout = float(
            rospy.get_param("~navigation_timeout", 120.0)
        )

        self.points = self.load_nav_points()

        self.status_pub = rospy.Publisher(
            "/restaurant/nav_status",
            String,
            queue_size=10
        )

        self.target_sub = rospy.Subscriber(
            "/restaurant/nav_target",
            String,
            self.target_callback
        )

        self.cancel_sub = rospy.Subscriber(
            "/restaurant/nav_cancel",
            Bool,
            self.cancel_callback
        )

        self.lock = threading.Lock()
        self.busy = False
        self.current_target = None
        self.cancel_requested = False
        self.client = None

        if self.mock_navigation:
            rospy.logwarn(
                "navigation_manager 当前处于 mock_navigation 测试模式："
                "不会连接 move_base，收到导航目标后将模拟到达。"
            )
        else:
            self.init_move_base_client()

        self.publish_status("IDLE")
        rospy.loginfo("navigation_manager 启动完成，当前状态：IDLE")

    @staticmethod
    def _to_bool(value) -> bool:
        if isinstance(value, bool):
            return value
        return str(value).strip().lower() in {"true", "1", "yes", "y", "on"}

    def resolve_yaml_path(self, rel_path: str) -> str:
        """
        解析导航点配置文件路径。

        优先级：
        1. 如果 rel_path 是绝对路径并且存在，直接使用；
        2. 尝试从 ROS package 中读取，例如 wpr_simulation/config/xxx.yaml；
        3. 如果当前代码还没有部署进 ROS package，则回退到 GitLab 项目结构 src/config/xxx.yaml。
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
            f"导航点配置文件不存在: rel_path={rel_path}, package={self.package_name}"
        )

    def load_nav_points(self):
        yaml_path = self.resolve_yaml_path(self.config_rel_path)

        with open(yaml_path, "r", encoding="utf-8") as file:
            data = yaml.safe_load(file) or {}

        if "nav_points" not in data:
            rospy.logerr("配置文件中缺少 nav_points 字段: %s", yaml_path)
            raise KeyError("nav_points")

        rospy.loginfo("已加载导航点配置文件: %s", yaml_path)
        rospy.loginfo("可用导航点: %s", list(data["nav_points"].keys()))
        return data["nav_points"]

    def init_move_base_client(self):
        """
        初始化 move_base action client。

        只有在 mock_navigation=false 时才调用。
        """
        if not MOVE_BASE_AVAILABLE:
            rospy.logerr("无法导入 move_base 相关依赖: %s", MOVE_BASE_IMPORT_ERROR)
            raise ImportError(
                "move_base 相关依赖不可用，请检查 ROS navigation / move_base_msgs / tf 是否安装。"
            )

        self.client = actionlib.SimpleActionClient("move_base", MoveBaseAction)
        rospy.loginfo("等待 move_base action server...")

        connected = self.client.wait_for_server(
            rospy.Duration(self.move_base_wait_timeout)
        )

        if not connected:
            rospy.logerr(
                "等待 move_base action server 超时，timeout=%.1f 秒。",
                self.move_base_wait_timeout
            )
            raise RuntimeError("move_base action server not available")

        rospy.loginfo("已连接 move_base action server。")

    def publish_status(self, text: str):
        self.status_pub.publish(String(data=text))
        rospy.loginfo("[nav_status] %s", text)

    def target_callback(self, msg: String):
        target_name = (msg.data or "").strip()

        if not target_name:
            self.publish_status("FAILED:EMPTY_TARGET")
            return

        with self.lock:
            if self.busy:
                self.publish_status(f"BUSY:{self.current_target}")
                return

            self.busy = True
            self.current_target = target_name
            self.cancel_requested = False

        worker = threading.Thread(
            target=self.navigate_to_target,
            args=(target_name,)
        )
        worker.daemon = True
        worker.start()

    def cancel_callback(self, msg: Bool):
        if not msg.data:
            return

        with self.lock:
            if not self.busy or self.current_target is None:
                self.publish_status("IDLE")
                return

            if self.cancel_requested:
                return

            self.cancel_requested = True
            target_name = self.current_target

        rospy.logwarn("收到取消请求，正在取消当前目标: %s", target_name)

        if not self.mock_navigation and self.client is not None:
            self.client.cancel_goal()

    def navigate_to_target(self, target_name: str):
        if self.mock_navigation:
            self.navigate_to_target_mock(target_name)
        else:
            self.navigate_to_target_real(target_name)

    def validate_target_point(self, target_name: str):
        """
        检查目标点是否存在以及字段是否完整。
        """
        if target_name not in self.points:
            return None, f"UNKNOWN_POINT:{target_name}"

        point = self.points[target_name]
        x = point.get("x")
        y = point.get("y")
        yaw = point.get("yaw")

        if x is None or y is None or yaw is None:
            return None, f"FAILED:INVALID_POINT:{target_name}"

        return point, None

    def navigate_to_target_mock(self, target_name: str):
        """
        测试模式导航。

        不调用 move_base，只模拟以下状态：
        NAVIGATING:<target>
        ARRIVED:<target>
        IDLE
        """
        final_status = None

        try:
            point, error_status = self.validate_target_point(target_name)
            if error_status is not None:
                final_status = error_status
                return

            x = point.get("x")
            y = point.get("y")
            yaw = point.get("yaw")

            self.publish_status(f"NAVIGATING:{target_name}")
            rospy.logwarn(
                "mock_navigation: 模拟导航到 %s, x=%s, y=%s, yaw=%s",
                target_name,
                x,
                y,
                yaw
            )

            start_time = rospy.Time.now()
            rate = rospy.Rate(10)

            while not rospy.is_shutdown():
                if self.cancel_requested:
                    final_status = f"CANCELED:{target_name}"
                    return

                elapsed = (rospy.Time.now() - start_time).to_sec()
                if elapsed >= self.mock_arrival_delay:
                    final_status = f"ARRIVED:{target_name}"
                    return

                rate.sleep()

        except Exception as exc:
            rospy.logerr("mock 导航过程异常: %s", str(exc))
            final_status = f"FAILED:{target_name}:EXCEPTION"

        finally:
            if final_status is not None:
                self.publish_status(final_status)

            with self.lock:
                self.busy = False
                self.current_target = None
                self.cancel_requested = False

            self.publish_status("IDLE")

    def navigate_to_target_real(self, target_name: str):
        """
        真实/仿真机器人导航。

        通过 move_base action server 执行导航。
        """
        final_status = None

        try:
            point, error_status = self.validate_target_point(target_name)
            if error_status is not None:
                final_status = error_status
                return

            x = point.get("x")
            y = point.get("y")
            yaw = point.get("yaw")

            goal = MoveBaseGoal()
            goal.target_pose.header.frame_id = "map"
            goal.target_pose.header.stamp = rospy.Time.now()

            goal.target_pose.pose.position.x = float(x)
            goal.target_pose.pose.position.y = float(y)
            goal.target_pose.pose.position.z = 0.0

            qx, qy, qz, qw = quaternion_from_euler(0.0, 0.0, float(yaw))
            goal.target_pose.pose.orientation.x = qx
            goal.target_pose.pose.orientation.y = qy
            goal.target_pose.pose.orientation.z = qz
            goal.target_pose.pose.orientation.w = qw

            self.publish_status(f"NAVIGATING:{target_name}")
            rospy.loginfo(
                "开始导航到目标点 %s: x=%s, y=%s, yaw=%s",
                target_name,
                x,
                y,
                yaw
            )

            self.client.send_goal(goal)

            finished = self.client.wait_for_result(
                rospy.Duration(self.navigation_timeout)
            )

            if not finished:
                if self.cancel_requested:
                    final_status = f"CANCELED:{target_name}"
                else:
                    self.client.cancel_goal()
                    final_status = f"FAILED:{target_name}:TIMEOUT"
                return

            state = self.client.get_state()

            if self.cancel_requested or state == GoalStatus.PREEMPTED:
                final_status = f"CANCELED:{target_name}"
            elif state == GoalStatus.SUCCEEDED:
                final_status = f"ARRIVED:{target_name}"
            else:
                final_status = f"FAILED:{target_name}:STATE_{state}"

        except Exception as exc:
            rospy.logerr("导航过程异常: %s", str(exc))
            final_status = f"FAILED:{target_name}:EXCEPTION"

        finally:
            if final_status is not None:
                self.publish_status(final_status)

            with self.lock:
                self.busy = False
                self.current_target = None
                self.cancel_requested = False

            self.publish_status("IDLE")


def main():
    NavigationManager()
    rospy.spin()


if __name__ == "__main__":
    try:
        main()
    except rospy.ROSInterruptException:
        pass
