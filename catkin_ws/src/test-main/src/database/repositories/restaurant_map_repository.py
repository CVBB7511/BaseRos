"""
餐厅地图 Repository。

主要负责：
1. 新增地图版本
2. 更新地图信息
3. 启用某个地图版本
4. 查询当前正在使用的地图
"""

from typing import List, Optional, Dict, Any

from src.database.database_manager import DatabaseManager


class RestaurantMapRepository:
    """餐厅地图数据访问层。"""

    @staticmethod
    def create_map(
        map_name: str,
        version: str,
        map_file_path: str = None,
        map_data: str = None,
        is_active: bool = True,
    ) -> int:
        """
        新增一条餐厅地图记录。

        Args:
            map_name: 地图名称
            version: 地图版本，例如 v1、v2
            map_file_path: 地图文件路径
            map_data: 地图补充数据，可保存 JSON 字符串
            is_active: 是否启用该地图

        Returns:
            int: 新地图 id
        """
        connection = DatabaseManager.get_connection()
        try:
            with connection.cursor() as cursor:
                if is_active:
                    cursor.execute("UPDATE restaurant_map SET is_active = 0")

                sql = """
                INSERT INTO restaurant_map
                (map_name, version, map_file_path, map_data, is_active)
                VALUES (%s, %s, %s, %s, %s)
                """
                cursor.execute(
                    sql,
                    (map_name, version, map_file_path, map_data, int(is_active)),
                )
                connection.commit()
                return cursor.lastrowid
        finally:
            connection.close()

    @staticmethod
    def get_active_map() -> Optional[Dict[str, Any]]:
        """
        查询当前启用的地图。

        Returns:
            dict | None: 当前启用地图
        """
        sql = """
        SELECT *
        FROM restaurant_map
        WHERE is_active = 1
        ORDER BY updated_at DESC
        LIMIT 1
        """

        connection = DatabaseManager.get_connection()
        try:
            with connection.cursor() as cursor:
                cursor.execute(sql)
                return cursor.fetchone()
        finally:
            connection.close()

    @staticmethod
    def get_all_maps() -> List[Dict[str, Any]]:
        """
        查询所有地图版本。

        Returns:
            list[dict]: 地图列表
        """
        sql = """
        SELECT *
        FROM restaurant_map
        ORDER BY created_at DESC
        """

        connection = DatabaseManager.get_connection()
        try:
            with connection.cursor() as cursor:
                cursor.execute(sql)
                return cursor.fetchall()
        finally:
            connection.close()

    @staticmethod
    def set_active_map(map_id: int) -> None:
        """
        启用指定地图版本，并关闭其他地图版本。

        Args:
            map_id: 地图 id
        """
        connection = DatabaseManager.get_connection()
        try:
            with connection.cursor() as cursor:
                cursor.execute("UPDATE restaurant_map SET is_active = 0")
                cursor.execute(
                    """
                    UPDATE restaurant_map
                    SET is_active = 1,
                        updated_at = CURRENT_TIMESTAMP
                    WHERE id = %s
                    """,
                    (map_id,),
                )
                connection.commit()
        finally:
            connection.close()

    @staticmethod
    def update_map(
        map_id: int,
        map_name: str = None,
        version: str = None,
        map_file_path: str = None,
        map_data: str = None,
    ) -> None:
        """
        更新地图信息。

        Args:
            map_id: 地图 id
            map_name: 新地图名称
            version: 新版本号
            map_file_path: 新地图文件路径
            map_data: 新地图数据
        """
        fields = []
        values = []

        if map_name is not None:
            fields.append("map_name = %s")
            values.append(map_name)

        if version is not None:
            fields.append("version = %s")
            values.append(version)

        if map_file_path is not None:
            fields.append("map_file_path = %s")
            values.append(map_file_path)

        if map_data is not None:
            fields.append("map_data = %s")
            values.append(map_data)

        if not fields:
            return

        fields.append("updated_at = CURRENT_TIMESTAMP")
        values.append(map_id)

        sql = f"""
        UPDATE restaurant_map
        SET {", ".join(fields)}
        WHERE id = %s
        """

        connection = DatabaseManager.get_connection()
        try:
            with connection.cursor() as cursor:
                cursor.execute(sql, tuple(values))
                connection.commit()
        finally:
            connection.close()
