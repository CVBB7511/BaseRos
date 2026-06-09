"""
机器人任务数据模型。

对应数据库表：
robot_task
"""

from dataclasses import dataclass
from datetime import datetime
from typing import Optional


@dataclass
class RobotTask:
    """机器人任务模型。"""

    task_name: str
    target_x: float
    target_y: float
    status: str = "pending"
    created_at: Optional[datetime] = None
    finished_at: Optional[datetime] = None
    id: Optional[int] = None
