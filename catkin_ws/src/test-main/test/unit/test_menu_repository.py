"""
menu_repository 单元测试示例。
"""

from src.database.repositories.menu_repository import MenuRepository


def test_get_categories():
    categories = MenuRepository.get_categories()
    assert isinstance(categories, list)
