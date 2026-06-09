"""
餐桌用餐会话 Repository。

主要负责：
1. 开始一次用餐
2. 查询某桌当前用餐
3. 结束一次用餐
4. 查询某桌历史用餐记录
"""

from typing import List, Optional, Dict, Any
from uuid import uuid4

from src.database.database_manager import DatabaseManager


class TableSessionRepository:
    """餐桌用餐会话数据访问层。"""

    @staticmethod
    def start_session(table_id: int, customer_count: int = 1) -> int:
        """
        开始一次用餐。

        会自动：
        1. 创建 table_session
        2. 将餐桌状态改为 occupied

        Args:
            table_id: 餐桌 id
            customer_count: 就餐人数

        Returns:
            int: 新 session id
        """
        session_code = f"S{uuid4().hex[:12].upper()}"

        connection = DatabaseManager.get_connection()
        try:
            with connection.cursor() as cursor:
                cursor.execute(
                    """
                    INSERT INTO table_session
                    (table_id, session_code, customer_count, status)
                    VALUES (%s, %s, %s, 'dining')
                    """,
                    (table_id, session_code, customer_count),
                )
                session_id = cursor.lastrowid

                cursor.execute(
                    """
                    UPDATE restaurant_table
                    SET status = 'occupied',
                        updated_at = CURRENT_TIMESTAMP
                    WHERE id = %s
                    """,
                    (table_id,),
                )

                connection.commit()
                return session_id
        finally:
            connection.close()

    @staticmethod
    def get_active_session_by_table(table_id: int) -> Optional[Dict[str, Any]]:
        """
        查询某张桌子的当前用餐记录。

        Args:
            table_id: 餐桌 id

        Returns:
            dict | None: 当前用餐记录
        """
        sql = """
        SELECT ts.*, rt.nav_point_name, rt.table_display_name
        FROM table_session ts
        JOIN restaurant_table rt ON ts.table_id = rt.id
        WHERE ts.table_id = %s
          AND ts.status = 'dining'
        ORDER BY ts.started_at DESC
        LIMIT 1
        """

        connection = DatabaseManager.get_connection()
        try:
            with connection.cursor() as cursor:
                cursor.execute(sql, (table_id,))
                return cursor.fetchone()
        finally:
            connection.close()

    @staticmethod
    def get_session_by_id(session_id: int) -> Optional[Dict[str, Any]]:
        """
        根据 session id 查询用餐记录。

        Args:
            session_id: 用餐会话 id

        Returns:
            dict | None: 用餐记录
        """
        sql = """
        SELECT ts.*, rt.nav_point_name, rt.table_display_name
        FROM table_session ts
        JOIN restaurant_table rt ON ts.table_id = rt.id
        WHERE ts.id = %s
        """

        connection = DatabaseManager.get_connection()
        try:
            with connection.cursor() as cursor:
                cursor.execute(sql, (session_id,))
                return cursor.fetchone()
        finally:
            connection.close()

    @staticmethod
    def close_session(session_id: int) -> None:
        """
        结束一次用餐。

        会自动：
        1. 将 table_session 状态改为 closed
        2. 写入 ended_at
        3. 将餐桌状态改为 available

        Args:
            session_id: 用餐会话 id
        """
        connection = DatabaseManager.get_connection()
        try:
            with connection.cursor() as cursor:
                cursor.execute(
                    """
                    SELECT table_id
                    FROM table_session
                    WHERE id = %s
                    """,
                    (session_id,),
                )
                session = cursor.fetchone()

                if session is None:
                    raise ValueError(f"session_id 不存在: {session_id}")

                table_id = session["table_id"]

                cursor.execute(
                    """
                    UPDATE table_session
                    SET status = 'closed',
                        ended_at = CURRENT_TIMESTAMP
                    WHERE id = %s
                    """,
                    (session_id,),
                )

                cursor.execute(
                    """
                    UPDATE restaurant_table
                    SET status = 'available',
                        updated_at = CURRENT_TIMESTAMP
                    WHERE id = %s
                    """,
                    (table_id,),
                )

                connection.commit()
        finally:
            connection.close()

    @staticmethod
    def get_sessions_by_table(table_id: int, limit: int = 50) -> List[Dict[str, Any]]:
        """
        查询某张桌子的历史用餐记录。

        Args:
            table_id: 餐桌 id
            limit: 查询数量限制

        Returns:
            list[dict]: 历史用餐记录
        """
        sql = """
        SELECT ts.*, rt.nav_point_name, rt.table_display_name
        FROM table_session ts
        JOIN restaurant_table rt ON ts.table_id = rt.id
        WHERE ts.table_id = %s
        ORDER BY ts.started_at DESC
        LIMIT %s
        """

        connection = DatabaseManager.get_connection()
        try:
            with connection.cursor() as cursor:
                cursor.execute(sql, (table_id, limit))
                return cursor.fetchall()
        finally:
            connection.close()
