"""
餐桌用餐会话数据模型。

对应数据库表：
table_session

说明：
同一张桌子在不同时间会产生不同 session。
例如：
3号桌 11:00-12:00 是一次 session
3号桌 18:00-19:30 是另一次 session

这样可以区分同一桌不同时段的历史点单和结账记录。
"""

from dataclasses import dataclass
from datetime import datetime
from typing import Optional


@dataclass
class TableSession:
    """餐桌用餐会话模型。"""

    table_id: int
    session_code: str
    customer_count: int = 1
    status: str = "dining"
    started_at: Optional[datetime] = None
    ended_at: Optional[datetime] = None
    id: Optional[int] = None
