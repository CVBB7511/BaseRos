"""
订单主表数据模型。

对应数据库表：
order_info

说明：
一次用餐 session 下可以有多次点单。
每次点单生成一个 order_info。
订单中的具体菜品放在 order_item。
"""

from dataclasses import dataclass
from datetime import datetime
from typing import Optional


@dataclass
class OrderInfo:
    """订单主表模型。"""

    session_id: int
    order_status: str = "created"
    total_amount: float = 0.0
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None
    id: Optional[int] = None
