"""
餐厅地图版本更新脚本。

运行方式：
python scripts/update_map_version.py

这个脚本用于演示如何新增并启用一个地图版本。
真实项目中，你可以把 map_file_path 改成实际地图点位配置文件路径。
"""

from pathlib import Path
import sys

PROJECT_ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(PROJECT_ROOT))

from src.database.repositories.restaurant_map_repository import RestaurantMapRepository  # noqa: E402


def update_map_version() -> None:
    """新增并启用地图版本。"""
    map_id = RestaurantMapRepository.create_map(
        map_name="餐厅地图",
        version="v1",
        map_file_path="src/config/restaurant_nav_points.yaml",
        map_data=None,
        is_active=True,
    )

    print(f"地图版本已更新，当前启用地图 id: {map_id}")


if __name__ == "__main__":
    update_map_version()
