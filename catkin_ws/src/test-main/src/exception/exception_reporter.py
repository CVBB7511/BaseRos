#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
餐厅服务机器人统一异常上报工具。

功能：
1. 将异常转换为统一 JSON 格式；
2. 发布到 /restaurant/exception_event；
3. 尝试写入 robot_log 表；
4. 数据库写入失败时不继续抛出异常，避免异常处理本身导致节点崩溃。
"""

import json
import traceback
from typing import Any, Dict, Optional

import rospy
from std_msgs.msg import String

from src.database.repositories.robot_log_repository import RobotLogRepository
from src.exception.exception_types import ExceptionLevel


class ExceptionReporter:
    """统一异常上报器。"""

    def __init__(
        self,
        robot_name: str = "robot_1",
        source: str = "system",
        topic_name: str = "/restaurant/exception_event",
    ):
        self.robot_name = robot_name
        self.source = source
        self.topic_name = topic_name

        self.publisher = rospy.Publisher(
            topic_name,
            String,
            queue_size=10
        )

    def report(
        self,
        exception_type: str,
        message: str,
        level: str = ExceptionLevel.ERROR,
        context: Optional[Dict[str, Any]] = None,
        exc: Optional[Exception] = None,
        write_db: bool = True,
    ) -> Dict[str, Any]:
        """
        上报异常事件。

        Args:
            exception_type: 异常类型，例如 DATABASE_QUERY_FAILED。
            message: 异常说明。
            level: 异常级别。
            context: 附加上下文信息。
            exc: Python 异常对象。
            write_db: 是否尝试写入 robot_log 表。

        Returns:
            Dict[str, Any]: 已生成的异常事件字典。
        """
        if context is None:
            context = {}

        event = {
            "robot_name": self.robot_name,
            "source": self.source,
            "level": level,
            "exception_type": exception_type,
            "message": message,
            "context": context,
            "timestamp": rospy.Time.now().to_sec() if not rospy.is_shutdown() else 0,
        }

        if exc is not None:
            event["python_exception"] = str(exc)
            event["traceback"] = traceback.format_exc()

        self.publish_event(event)

        if write_db:
            self.write_log(event)

        return event

    def publish_event(self, event: Dict[str, Any]) -> None:
        """
        发布异常事件到 ROS 话题。
        """
        try:
            msg = json.dumps(event, ensure_ascii=False, default=str)
            self.publisher.publish(String(data=msg))
            rospy.logwarn("[EXCEPTION EVENT] %s", msg)
        except Exception as publish_exc:
            rospy.logwarn(
                "Failed to publish exception event: %s",
                str(publish_exc)
            )

    def write_log(self, event: Dict[str, Any]) -> None:
        """
        尝试写入 robot_log 表。

        注意：异常上报不能因为数据库失败而再次崩溃。
        """
        try:
            message = (
                f"[{event.get('source')}] "
                f"{event.get('exception_type')}: "
                f"{event.get('message')} "
                f"context={event.get('context')}"
            )

            RobotLogRepository.insert_log(
                robot_name=self.robot_name,
                log_level=event.get("level", ExceptionLevel.ERROR),
                message=message
            )
        except Exception as db_exc:
            rospy.logwarn(
                "Failed to write exception event into database: %s",
                str(db_exc)
            )
