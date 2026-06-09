"""
菜单分类数据模型。

对应数据库表：
menu_category
"""

from dataclasses import dataclass
from datetime import datetime
from typing import Optional


@dataclass
class MenuCategory:
    """菜单分类模型。"""

    category_name: str
    description: Optional[str] = None
    display_order: int = 0
    is_active: bool = True
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None
    id: Optional[int] = None
