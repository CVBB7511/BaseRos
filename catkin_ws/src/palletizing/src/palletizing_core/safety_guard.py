# coding=utf-8
"""码垛机器人系统 - 安全防护模块。

提供紧急停机、速度清零、工作空间边界校验等安全原语，
供各执行层模块在异常或关闭场景中调用。
"""

import rospy
from geometry_msgs.msg import Twist, Point
from sensor_msgs.msg import JointState
from std_msgs.msg import String
from typing import Dict


class SafetyGuard:
    """安全防护器，封装所有与物理安全相关的操作。

    Attributes:
        _vel_pub: 底盘速度发布器
        _mani_pub: 机械臂控制发布器
        _behavior_pub: 底层厂家行为控制发布器
        _workspace: 工作空间边界字典
    """

    def __init__(self) -> None:
        self._vel_pub = rospy.Publisher("/cmd_vel", Twist, queue_size=1)
        self._mani_pub = rospy.Publisher(
            "/wpb_home/mani_ctrl", JointState, queue_size=1
        )
        self._behavior_pub = rospy.Publisher(
            "/wpb_home/behaviors", String, queue_size=10
        )
        self._workspace: Dict[str, float] = {
            "x_min": rospy.get_param("~manipulator/workspace/x_min", 0.3),
            "x_max": rospy.get_param("~manipulator/workspace/x_max", 1.2),
            "y_min": rospy.get_param("~manipulator/workspace/y_min", -0.5),
            "y_max": rospy.get_param("~manipulator/workspace/y_max", 0.5),
            "z_min": rospy.get_param("~manipulator/workspace/z_min", 0.3),
            "z_max": rospy.get_param("~manipulator/workspace/z_max", 1.2),
        }

    def stop_chassis(self) -> None:
        """立即向底盘发布零速度指令。"""
        self._vel_pub.publish(Twist())
        rospy.logwarn("[SafetyGuard] 底盘已停止")

    def stop_manipulator(self) -> None:
        """停止机械臂运动并收起至安全位置。"""
        msg = JointState()
        msg.name = ["lift", "gripper"]
        msg.position = [0.0, 0.1]
        msg.velocity = [0.5, 5.0]
        self._mani_pub.publish(msg)
        rospy.logwarn("[SafetyGuard] 机械臂已复位至安全姿态")

    def stop_grab_behavior(self) -> None:
        """终止底层厂家抓取动作。"""
        try:
            self._behavior_pub.publish(String(data="grab stop"))
            rospy.logwarn("[SafetyGuard] 已向厂家发送 grab stop 信号")
        except Exception as e:
            rospy.logerr("[SafetyGuard] 终止厂家抓取动作异常: %s", str(e))

    def stop_place_behavior(self) -> None:
        """终止底层厂家放置动作。"""
        try:
            self._behavior_pub.publish(String(data="place stop"))
            rospy.logwarn("[SafetyGuard] 已向厂家发送 place stop 信号")
        except Exception as e:
            rospy.logerr("[SafetyGuard] 终止厂家放置动作异常: %s", str(e))

    def emergency_stop(self) -> None:
        """紧急停机：同时停止底盘、机械臂与底层动作状态机。"""
        self.stop_chassis()
        self.stop_manipulator()
        self.stop_grab_behavior()
        self.stop_place_behavior()
        rospy.logerr("[SafetyGuard] ═══ 紧急停机已触发 ═══")

    def validate_workspace(self, position: Point) -> bool:
        """校验目标坐标是否在机械臂安全工作空间内。

        Args:
            position: base_link 坐标系下的目标三维点

        Returns:
            坐标是否在安全范围内

        Raises:
            无异常抛出，仅返回布尔值并记录警告日志
        """
        ws = self._workspace
        x_ok = ws["x_min"] <= position.x <= ws["x_max"]
        y_ok = ws["y_min"] <= position.y <= ws["y_max"]
        z_ok = ws["z_min"] <= position.z <= ws["z_max"]

        if not (x_ok and y_ok and z_ok):
            rospy.logwarn(
                "[SafetyGuard] 坐标 (%.3f, %.3f, %.3f) 超出工作空间: "
                "x[%.2f~%.2f] y[%.2f~%.2f] z[%.2f~%.2f]",
                position.x, position.y, position.z,
                ws["x_min"], ws["x_max"],
                ws["y_min"], ws["y_max"],
                ws["z_min"], ws["z_max"],
            )
            return False
        return True
