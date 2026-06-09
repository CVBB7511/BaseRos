"""
机器人状态表 robot_status 的数据访问层。

主要负责：
1. 插入机器人状态
2. 查询机器人最新状态
3. 查询机器人历史状态
"""

from typing import List, Optional, Dict, Any

from src.database.database_manager import DatabaseManager


class RobotStatusRepository:
    """机器人状态 Repository。"""

    @staticmethod
    def insert_status(
        robot_name: str,
        battery: float,
        pos_x: float,
        pos_y: float,
        yaw: float,
        status: str,
    ) -> int:
        """
        插入一条机器人状态记录。

        Args:
            robot_name: 机器人名称
            battery: 电量
            pos_x: x 坐标
            pos_y: y 坐标
            yaw: 朝向角
            status: 当前状态，例如 idle、moving、serving、error

        Returns:
            int: 新插入记录的 id
        """
        sql = """
        INSERT INTO robot_status
        (robot_name, battery, pos_x, pos_y, yaw, status)
        VALUES (%s, %s, %s, %s, %s, %s)
        """

        connection = DatabaseManager.get_connection()
        try:
            with connection.cursor() as cursor:
                cursor.execute(
                    sql,
                    (robot_name, battery, pos_x, pos_y, yaw, status),
                )
                connection.commit()
                return cursor.lastrowid
        finally:
            connection.close()

    @staticmethod
    def get_latest_status(robot_name: str) -> Optional[Dict[str, Any]]:
        """
        查询指定机器人的最新状态。

        Args:
            robot_name: 机器人名称

        Returns:
            dict | None: 最新状态记录
        """
        sql = """
        SELECT *
        FROM robot_status
        WHERE robot_name = %s
        ORDER BY created_at DESC
        LIMIT 1
        """

        connection = DatabaseManager.get_connection()
        try:
            with connection.cursor() as cursor:
                cursor.execute(sql, (robot_name,))
                return cursor.fetchone()
        finally:
            connection.close()

    @staticmethod
    def get_status_history(robot_name: str, limit: int = 50) -> List[Dict[str, Any]]:
        """
        查询指定机器人的状态历史。

        Args:
            robot_name: 机器人名称
            limit: 查询数量限制

        Returns:
            list[dict]: 状态历史记录
        """
        sql = """
        SELECT *
        FROM robot_status
        WHERE robot_name = %s
        ORDER BY created_at DESC
        LIMIT %s
        """

        connection = DatabaseManager.get_connection()
        try:
            with connection.cursor() as cursor:
                cursor.execute(sql, (robot_name, limit))
                return cursor.fetchall()
        finally:
            connection.close()
