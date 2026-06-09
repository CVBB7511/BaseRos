"""
餐桌数据导入脚本。

运行方式：
python scripts/import_table_data.py

数据来源：
data/samples/sample_tables.json

命名约定：
餐桌的 nav_point_name 必须与导航定位模块中的导航点名称一致。
例如 table_1、table_2、table_3、table_4。
"""

from pathlib import Path
import json
import sys

PROJECT_ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(PROJECT_ROOT))

from src.database.repositories.restaurant_table_repository import RestaurantTableRepository  # noqa: E402


def import_table_data() -> None:
    """导入餐桌数据。"""
    table_file = PROJECT_ROOT / "data" / "samples" / "sample_tables.json"

    if not table_file.exists():
        raise FileNotFoundError(f"餐桌文件不存在: {table_file}")

    tables = json.loads(table_file.read_text(encoding="utf-8"))

    for table in tables:
        existing_table = RestaurantTableRepository.get_table_by_nav_point(
            table["nav_point_name"]
        )

        if existing_table:
            continue

        RestaurantTableRepository.create_table(
            nav_point_name=table["nav_point_name"],
            table_display_name=table["table_display_name"],
            capacity=table["capacity"],
            pos_x=table["pos_x"],
            pos_y=table["pos_y"],
            status=table.get("status", "available"),
        )

    print("餐桌数据导入完成")


if __name__ == "__main__":
    import_table_data()
