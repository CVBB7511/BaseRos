"""
机器人日志数据模型。

对应数据库表：
robot_log
"""

from dataclasses import dataclass
from datetime import datetime
from typing import Optional


@dataclass
class RobotLog:
    """机器人日志模型。"""

    robot_name: str
    log_level: str
    message: str
    created_at: Optional[datetime] = None
    id: Optional[int] = None
