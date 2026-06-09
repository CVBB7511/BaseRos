"""
机器人状态数据模型。

对应数据库表：
robot_status
"""

from dataclasses import dataclass
from datetime import datetime
from typing import Optional


@dataclass
class RobotStatus:
    """机器人状态模型。"""

    robot_name: str
    battery: float
    pos_x: float
    pos_y: float
    yaw: float
    status: str
    created_at: Optional[datetime] = None
    id: Optional[int] = None
