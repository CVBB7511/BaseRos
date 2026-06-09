"""
订单明细数据模型。

对应数据库表：
order_item
"""

from dataclasses import dataclass
from datetime import datetime
from typing import Optional


@dataclass
class OrderItem:
    """订单明细模型。"""

    order_id: int
    item_id: int
    quantity: int
    unit_price: float
    subtotal: float
    remark: Optional[str] = None
    created_at: Optional[datetime] = None
    id: Optional[int] = None
