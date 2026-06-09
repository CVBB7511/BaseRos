"""
菜单 Repository。

主要负责：
1. 新增菜单分类
2. 新增菜品
3. 查询完整菜单
4. 修改菜品价格
5. 修改菜品是否可售
"""

from decimal import Decimal
from typing import List, Optional, Dict, Any

from src.database.database_manager import DatabaseManager


class MenuRepository:
    """菜单数据访问层。"""

    @staticmethod
    def create_category(
        category_name: str,
        description: str = None,
        display_order: int = 0,
        is_active: bool = True,
    ) -> int:
        """
        新增菜单分类。

        Args:
            category_name: 分类名称
            description: 分类说明
            display_order: 显示顺序
            is_active: 是否启用

        Returns:
            int: 新分类 id
        """
        sql = """
        INSERT INTO menu_category
        (category_name, description, display_order, is_active)
        VALUES (%s, %s, %s, %s)
        """

        connection = DatabaseManager.get_connection()
        try:
            with connection.cursor() as cursor:
                cursor.execute(
                    sql,
                    (category_name, description, display_order, int(is_active)),
                )
                connection.commit()
                return cursor.lastrowid
        finally:
            connection.close()

    @staticmethod
    def get_category_by_name(category_name: str) -> Optional[Dict[str, Any]]:
        """
        根据分类名称查询分类。

        Args:
            category_name: 分类名称

        Returns:
            dict | None: 分类信息
        """
        sql = """
        SELECT *
        FROM menu_category
        WHERE category_name = %s
        """

        connection = DatabaseManager.get_connection()
        try:
            with connection.cursor() as cursor:
                cursor.execute(sql, (category_name,))
                return cursor.fetchone()
        finally:
            connection.close()

    @staticmethod
    def get_categories(only_active: bool = True) -> List[Dict[str, Any]]:
        """
        查询菜单分类。

        Args:
            only_active: 是否只查询启用分类

        Returns:
            list[dict]: 分类列表
        """
        sql = """
        SELECT *
        FROM menu_category
        """

        if only_active:
            sql += " WHERE is_active = 1 "

        sql += " ORDER BY display_order ASC, id ASC "

        connection = DatabaseManager.get_connection()
        try:
            with connection.cursor() as cursor:
                cursor.execute(sql)
                return cursor.fetchall()
        finally:
            connection.close()

    @staticmethod
    def create_menu_item(
        category_id: int,
        item_name: str,
        price,
        description: str = None,
        image_path: str = None,
        is_available: bool = True,
    ) -> int:
        """
        新增菜品。

        Args:
            category_id: 分类 id
            item_name: 菜品名称
            price: 单价
            description: 菜品说明
            image_path: 菜品图片路径
            is_available: 是否可售

        Returns:
            int: 新菜品 id
        """
        sql = """
        INSERT INTO menu_item
        (category_id, item_name, price, description, image_path, is_available)
        VALUES (%s, %s, %s, %s, %s, %s)
        """

        connection = DatabaseManager.get_connection()
        try:
            with connection.cursor() as cursor:
                cursor.execute(
                    sql,
                    (
                        category_id,
                        item_name,
                        Decimal(str(price)),
                        description,
                        image_path,
                        int(is_available),
                    ),
                )
                connection.commit()
                return cursor.lastrowid
        finally:
            connection.close()

    @staticmethod
    def get_item_by_id(item_id: int) -> Optional[Dict[str, Any]]:
        """
        根据 id 查询菜品。

        Args:
            item_id: 菜品 id

        Returns:
            dict | None: 菜品信息
        """
        sql = """
        SELECT mi.*, mc.category_name
        FROM menu_item mi
        LEFT JOIN menu_category mc ON mi.category_id = mc.id
        WHERE mi.id = %s
        """

        connection = DatabaseManager.get_connection()
        try:
            with connection.cursor() as cursor:
                cursor.execute(sql, (item_id,))
                return cursor.fetchone()
        finally:
            connection.close()

    @staticmethod
    def get_all_menu_items(only_available: bool = False) -> List[Dict[str, Any]]:
        """
        查询所有菜品。

        Args:
            only_available: 是否只查询可售菜品

        Returns:
            list[dict]: 菜品列表
        """
        sql = """
        SELECT mi.*, mc.category_name
        FROM menu_item mi
        LEFT JOIN menu_category mc ON mi.category_id = mc.id
        """

        if only_available:
            sql += " WHERE mi.is_available = 1 "

        sql += " ORDER BY mc.display_order ASC, mi.id ASC "

        connection = DatabaseManager.get_connection()
        try:
            with connection.cursor() as cursor:
                cursor.execute(sql)
                return cursor.fetchall()
        finally:
            connection.close()

    @staticmethod
    def get_menu_by_category(category_id: int, only_available: bool = True) -> List[Dict[str, Any]]:
        """
        根据分类查询菜品。

        Args:
            category_id: 分类 id
            only_available: 是否只查询可售菜品

        Returns:
            list[dict]: 菜品列表
        """
        sql = """
        SELECT *
        FROM menu_item
        WHERE category_id = %s
        """

        params = [category_id]

        if only_available:
            sql += " AND is_available = 1 "

        sql += " ORDER BY id ASC "

        connection = DatabaseManager.get_connection()
        try:
            with connection.cursor() as cursor:
                cursor.execute(sql, tuple(params))
                return cursor.fetchall()
        finally:
            connection.close()

    @staticmethod
    def update_item_price(item_id: int, price) -> None:
        """
        修改菜品价格。

        Args:
            item_id: 菜品 id
            price: 新价格
        """
        sql = """
        UPDATE menu_item
        SET price = %s,
            updated_at = CURRENT_TIMESTAMP
        WHERE id = %s
        """

        connection = DatabaseManager.get_connection()
        try:
            with connection.cursor() as cursor:
                cursor.execute(sql, (Decimal(str(price)), item_id))
                connection.commit()
        finally:
            connection.close()

    @staticmethod
    def update_item_availability(item_id: int, is_available: bool) -> None:
        """
        修改菜品是否可售。

        Args:
            item_id: 菜品 id
            is_available: 是否可售
        """
        sql = """
        UPDATE menu_item
        SET is_available = %s,
            updated_at = CURRENT_TIMESTAMP
        WHERE id = %s
        """

        connection = DatabaseManager.get_connection()
        try:
            with connection.cursor() as cursor:
                cursor.execute(sql, (int(is_available), item_id))
                connection.commit()
        finally:
            connection.close()
