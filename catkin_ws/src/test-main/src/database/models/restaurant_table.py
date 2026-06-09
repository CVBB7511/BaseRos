"""
餐桌数据模型。

对应数据库表：
restaurant_table

命名约定：
1. nav_point_name 必须与导航定位模块中的导航点名称保持一致，例如 table_1、table_2。
2. table_display_name 用于界面展示，例如 1号桌、2号桌。
"""

from dataclasses import dataclass
from datetime import datetime
from typing import Optional


@dataclass
class RestaurantTable:
    """餐桌模型。"""

    nav_point_name: str
    table_display_name: str
    capacity: int
    pos_x: float
    pos_y: float
    status: str = "available"
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None
    id: Optional[int] = None
