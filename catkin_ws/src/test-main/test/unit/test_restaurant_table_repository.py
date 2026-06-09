"""
restaurant_table_repository 单元测试示例。
"""

from src.database.repositories.restaurant_table_repository import RestaurantTableRepository


def test_get_all_tables():
    tables = RestaurantTableRepository.get_all_tables()
    assert isinstance(tables, list)
