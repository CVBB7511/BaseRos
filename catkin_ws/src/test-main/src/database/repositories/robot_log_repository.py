"""
机器人日志表 robot_log 的数据访问层。

主要负责：
1. 插入运行日志
2. 查询日志
"""

from typing import List, Dict, Any

from src.database.database_manager import DatabaseManager


class RobotLogRepository:
    """机器人日志 Repository。"""

    @staticmethod
    def insert_log(robot_name: str, log_level: str, message: str) -> int:
        """
        插入一条日志记录。

        Args:
            robot_name: 机器人名称
            log_level: 日志级别，例如 INFO、WARNING、ERROR
            message: 日志内容

        Returns:
            int: 新日志 id
        """
        sql = """
        INSERT INTO robot_log
        (robot_name, log_level, message)
        VALUES (%s, %s, %s)
        """

        connection = DatabaseManager.get_connection()
        try:
            with connection.cursor() as cursor:
                cursor.execute(sql, (robot_name, log_level, message))
                connection.commit()
                return cursor.lastrowid
        finally:
            connection.close()

    @staticmethod
    def get_logs(robot_name: str, limit: int = 50) -> List[Dict[str, Any]]:
        """
        查询指定机器人的日志。

        Args:
            robot_name: 机器人名称
            limit: 查询数量限制

        Returns:
            list[dict]: 日志记录列表
        """
        sql = """
        SELECT *
        FROM robot_log
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

    @staticmethod
    def get_error_logs(robot_name: str, limit: int = 50) -> List[Dict[str, Any]]:
        """
        查询指定机器人的错误日志。

        Args:
            robot_name: 机器人名称
            limit: 查询数量限制

        Returns:
            list[dict]: 错误日志记录列表
        """
        sql = """
        SELECT *
        FROM robot_log
        WHERE robot_name = %s
          AND log_level = 'ERROR'
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
