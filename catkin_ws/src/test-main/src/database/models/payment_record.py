"""
结账记录数据模型。

对应数据库表：
payment_record

用途：
1. 保存一次用餐的总价
2. 保存优惠金额
3. 保存实际支付金额
4. 保存支付方式和支付时间
"""

from dataclasses import dataclass
from datetime import datetime
from typing import Optional


@dataclass
class PaymentRecord:
    """支付结账记录模型。"""

    session_id: int
    total_amount: float
    discount_amount: float
    final_amount: float
    payment_method: str
    payment_status: str = "paid"
    paid_at: Optional[datetime] = None
    id: Optional[int] = None
