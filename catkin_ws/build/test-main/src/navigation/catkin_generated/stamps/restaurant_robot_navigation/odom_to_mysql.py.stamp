#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
ROS1 里程计数据写入 MySQL 节点。

功能：
1. 订阅 /odom 话题；
2. 读取机器人当前位置与朝向；
3. 将机器人状态写入 robot_status 表；
4. 将节点启动、数据库写入异常等事件写入 robot_log 表。

说明：
原始版本使用 rclpy，是 ROS2 写法。
当前项目文档和运行环境以 ROS1 Noetic / Melodic 为主，因此改为 rospy 写法。
"""

import math
import os
import sys
import time
from pathlib import Path

import rospy
from nav_msgs.msg import Odometry


def find_project_root() -> Path:
    """
    查找项目根目录，保证 ROS 启动节点时可以导入 src.database 等模块。
    """
    script_path = Path(__file__).resolve()

    for candidate in [script_path.parent] + list(script_path.parents):
        if (candidate / "src" / "database").is_dir() and \
           (candidate / "src" / "config").is_dir():
            return candidate

    env_root = os.environ.get("RESTAURANT_ROBOT_PROJECT_ROOT", "").strip()
    if env_root:
        candidate = Path(env_root).expanduser().resolve()
        if (candidate / "src" / "database").is_dir() and \
           (candidate / "src" / "config").is_dir():
            return candidate

    ros_package_path = os.environ.get("ROS_PACKAGE_PATH", "")
    for base_text in ros_package_path.split(os.pathsep):
        if not base_text:
            continue

        base = Path(base_text).expanduser().resolve()
        candidates = [base, base / "test-main", base / "test"]

        try:
            candidates.extend([child for child in base.iterdir() if child.is_dir()])
        except Exception:
            pass

        for candidate in candidates:
            if (candidate / "src" / "database").is_dir() and \
               (candidate / "src" / "config").is_dir():
                return candidate

    return script_path.parents[2]


PROJECT_ROOT = find_project_root()
if str(PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(PROJECT_ROOT))

from src.database.repositories.robot_status_repository import RobotStatusRepository
from src.database.repositories.robot_log_repository import RobotLogRepository


def quaternion_to_yaw(x: float, y: float, z: float, w: float) -> float:
    """
    将四元数转换为 yaw 角。

    Args:
        x: 四元数 x
        y: 四元数 y
        z: 四元数 z
        w: 四元数 w

    Returns:
        float: yaw 角，单位为弧度
    """
    siny_cosp = 2.0 * (w * z + x * y)
    cosy_cosp = 1.0 - 2.0 * (y * y + z * z)
    return math.atan2(siny_cosp, cosy_cosp)


class OdomToMySQLNode:
    """
    ROS1 里程计入库节点。

    该节点订阅 /odom，将机器人位置周期性写入数据库。
    由于 /odom 频率通常较高，如果每一帧都写数据库，会造成数据库压力过大。
    因此这里通过 write_interval 控制写入频率，默认每 1 秒最多写一次。
    """

    def __init__(self):
        self.robot_name = rospy.get_param("~robot_name", "robot_1")
        self.battery = float(rospy.get_param("~battery", 100.0))
        self.odom_topic = rospy.get_param("~odom_topic", "/odom")
        self.write_interval = float(rospy.get_param("~write_interval", 1.0))

        self.last_write_time = 0.0

        self.odom_subscriber = rospy.Subscriber(
            self.odom_topic,
            Odometry,
            self.odom_callback,
            queue_size=10
        )

        self._insert_log_safe(
            "INFO",
            "odom_to_mysql_node started. "
            f"robot_name={self.robot_name}, odom_topic={self.odom_topic}, "
            f"write_interval={self.write_interval}"
        )

        rospy.loginfo(
            "odom_to_mysql_node started. robot_name=%s, odom_topic=%s, write_interval=%.2f",
            self.robot_name,
            self.odom_topic,
            self.write_interval
        )

    def _insert_log_safe(self, log_level: str, message: str) -> None:
        """
        安全写入日志。

        数据库日志写入失败时，只在 ROS 控制台输出警告，避免节点直接崩溃。
        """
        try:
            RobotLogRepository.insert_log(
                robot_name=self.robot_name,
                log_level=log_level,
                message=message
            )
        except Exception as exc:
            rospy.logwarn("Failed to insert robot log into database: %s", str(exc))

    def odom_callback(self, msg: Odometry) -> None:
        """
        /odom 回调函数。

        Args:
            msg: nav_msgs/Odometry 消息
        """
        current_time = time.time()

        if current_time - self.last_write_time < self.write_interval:
            return

        self.last_write_time = current_time

        pos_x = msg.pose.pose.position.x
        pos_y = msg.pose.pose.position.y

        q = msg.pose.pose.orientation
        yaw = quaternion_to_yaw(q.x, q.y, q.z, q.w)

        try:
            RobotStatusRepository.insert_status(
                robot_name=self.robot_name,
                battery=self.battery,
                pos_x=pos_x,
                pos_y=pos_y,
                yaw=yaw,
                status="moving"
            )

            rospy.loginfo(
                "Saved odom to database: robot=%s, x=%.2f, y=%.2f, yaw=%.2f",
                self.robot_name,
                pos_x,
                pos_y,
                yaw
            )

        except Exception as exc:
            error_message = f"Failed to save odom to database: {exc}"
            rospy.logerr(error_message)
            self._insert_log_safe("ERROR", error_message)


def main():
    """
    ROS1 节点入口。
    """
    rospy.init_node("odom_to_mysql_node", anonymous=False)

    OdomToMySQLNode()

    rospy.loginfo("odom_to_mysql_node is running.")
    rospy.spin()


if __name__ == "__main__":
    main()
