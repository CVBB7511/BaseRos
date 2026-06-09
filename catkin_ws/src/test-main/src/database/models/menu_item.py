"""
菜品数据模型。

对应数据库表：
menu_item
"""

from dataclasses import dataclass
from datetime import datetime
from typing import Optional


@dataclass
class MenuItem:
    """菜品模型。"""

    category_id: int
    item_name: str
    price: float
    description: Optional[str] = None
    image_path: Optional[str] = None
    is_available: bool = True
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None
    id: Optional[int] = None
