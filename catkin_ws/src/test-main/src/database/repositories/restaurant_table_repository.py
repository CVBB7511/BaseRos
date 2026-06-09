"""
餐桌 Repository。

主要负责：
1. 新增餐桌
2. 查询餐桌
3. 更新餐桌状态
4. 更新餐桌位置

命名约定：
餐桌业务接口统一使用导航定位模块中的点位名称。
例如：
- table_1
- table_2
- table_3
- table_4

不要再使用 T01、T02 作为跨模块接口名称。
"""

from typing import List, Optional, Dict, Any

from src.database.database_manager import DatabaseManager


class RestaurantTableRepository:
    """餐桌数据访问层。"""

    @staticmethod
    def create_table(
        nav_point_name: str,
        table_display_name: str,
        capacity: int,
        pos_x: float,
        pos_y: float,
        status: str = "available",
    ) -> int:
        """
        新增餐桌。

        Args:
            nav_point_name: 导航点名称，必须与导航模块一致，例如 table_1
            table_display_name: 餐桌显示名称，例如 1号桌
            capacity: 可容纳人数
            pos_x: 餐桌 x 坐标
            pos_y: 餐桌 y 坐标
            status: 餐桌状态，默认 available

        Returns:
            int: 新餐桌 id
        """
        sql = """
        INSERT INTO restaurant_table
        (nav_point_name, table_display_name, capacity, pos_x, pos_y, status)
        VALUES (%s, %s, %s, %s, %s, %s)
        """

        connection = DatabaseManager.get_connection()
        try:
            with connection.cursor() as cursor:
                cursor.execute(
                    sql,
                    (nav_point_name, table_display_name, capacity, pos_x, pos_y, status),
                )
                connection.commit()
                return cursor.lastrowid
        finally:
            connection.close()

    @staticmethod
    def get_all_tables() -> List[Dict[str, Any]]:
        """
        查询所有餐桌。

        Returns:
            list[dict]: 餐桌列表
        """
        sql = """
        SELECT *
        FROM restaurant_table
        ORDER BY nav_point_name ASC
        """

        connection = DatabaseManager.get_connection()
        try:
            with connection.cursor() as cursor:
                cursor.execute(sql)
                return cursor.fetchall()
        finally:
            connection.close()

    @staticmethod
    def get_table_by_id(table_id: int) -> Optional[Dict[str, Any]]:
        """
        根据 id 查询餐桌。

        Args:
            table_id: 餐桌 id

        Returns:
            dict | None: 餐桌信息
        """
        sql = """
        SELECT *
        FROM restaurant_table
        WHERE id = %s
        """

        connection = DatabaseManager.get_connection()
        try:
            with connection.cursor() as cursor:
                cursor.execute(sql, (table_id,))
                return cursor.fetchone()
        finally:
            connection.close()

    @staticmethod
    def get_table_by_nav_point(nav_point_name: str) -> Optional[Dict[str, Any]]:
        """
        根据导航点名称查询餐桌。

        Args:
            nav_point_name: 导航点名称，例如 table_1、table_2

        Returns:
            dict | None: 餐桌信息
        """
        sql = """
        SELECT *
        FROM restaurant_table
        WHERE nav_point_name = %s
        """

        connection = DatabaseManager.get_connection()
        try:
            with connection.cursor() as cursor:
                cursor.execute(sql, (nav_point_name,))
                return cursor.fetchone()
        finally:
            connection.close()

    @staticmethod
    def get_table_by_number(table_number: str) -> Optional[Dict[str, Any]]:
        """
        兼容旧接口：根据餐桌编号查询餐桌。

        说明：
            为了与导航定位模块统一，新代码建议使用 get_table_by_nav_point()。
            这里保留旧方法名，内部按照 nav_point_name 查询。

        Args:
            table_number: 旧餐桌编号或导航点名称

        Returns:
            dict | None: 餐桌信息
        """
        return RestaurantTableRepository.get_table_by_nav_point(table_number)

    @staticmethod
    def update_table_status(table_id: int, status: str) -> None:
        """
        更新餐桌状态。

        Args:
            table_id: 餐桌 id
            status: 新状态，例如 available、occupied、reserved、cleaning
        """
        sql = """
        UPDATE restaurant_table
        SET status = %s,
            updated_at = CURRENT_TIMESTAMP
        WHERE id = %s
        """

        connection = DatabaseManager.get_connection()
        try:
            with connection.cursor() as cursor:
                cursor.execute(sql, (status, table_id))
                connection.commit()
        finally:
            connection.close()

    @staticmethod
    def update_table_position(table_id: int, pos_x: float, pos_y: float) -> None:
        """
        更新餐桌位置。

        Args:
            table_id: 餐桌 id
            pos_x: 新 x 坐标
            pos_y: 新 y 坐标
        """
        sql = """
        UPDATE restaurant_table
        SET pos_x = %s,
            pos_y = %s,
            updated_at = CURRENT_TIMESTAMP
        WHERE id = %s
        """

        connection = DatabaseManager.get_connection()
        try:
            with connection.cursor() as cursor:
                cursor.execute(sql, (pos_x, pos_y, table_id))
                connection.commit()
        finally:
            connection.close()
