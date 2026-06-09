"""
菜单数据导入脚本。

运行方式：
python scripts/import_menu_data.py

数据来源：
data/menu/menu_data.json
"""

from pathlib import Path
import json
import sys

PROJECT_ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(PROJECT_ROOT))

from src.database.repositories.menu_repository import MenuRepository  # noqa: E402


def import_menu_data() -> None:
    """导入菜单分类和菜品。"""
    menu_file = PROJECT_ROOT / "data" / "menu" / "menu_data.json"

    if not menu_file.exists():
        raise FileNotFoundError(f"菜单文件不存在: {menu_file}")

    data = json.loads(menu_file.read_text(encoding="utf-8"))

    for category_index, category in enumerate(data["categories"], start=1):
        category_name = category["category_name"]
        existing_category = MenuRepository.get_category_by_name(category_name)

        if existing_category:
            category_id = existing_category["id"]
        else:
            category_id = MenuRepository.create_category(
                category_name=category_name,
                description=category.get("description"),
                display_order=category.get("display_order", category_index),
            )

        for item in category.get("items", []):
            MenuRepository.create_menu_item(
                category_id=category_id,
                item_name=item["item_name"],
                price=item["price"],
                description=item.get("description"),
                image_path=item.get("image_path"),
                is_available=item.get("is_available", True),
            )

    print("菜单数据导入完成")


if __name__ == "__main__":
    import_menu_data()
