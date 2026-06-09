"""
餐厅地图数据模型。

对应数据库表：
restaurant_map

用途：
1. 保存餐厅地图名称
2. 保存地图文件路径
3. 保存地图版本
4. 标记当前启用地图
"""

from dataclasses import dataclass
from datetime import datetime
from typing import Optional


@dataclass
class RestaurantMap:
    """餐厅地图模型。"""

    map_name: str
    version: str
    map_file_path: Optional[str] = None
    map_data: Optional[str] = None
    is_active: bool = True
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None
    id: Optional[int] = None
