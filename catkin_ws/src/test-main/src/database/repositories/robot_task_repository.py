"""
机器人任务表 robot_task 的数据访问层。

主要负责：
1. 创建任务
2. 查询待执行任务
3. 查询任务详情
4. 更新任务状态
"""

from typing import List, Optional, Dict, Any

from src.database.database_manager import DatabaseManager


class RobotTaskRepository:
    """机器人任务 Repository。"""

    @staticmethod
    def create_task(
        task_name: str,
        target_x: float,
        target_y: float,
        status: str = "pending",
    ) -> int:
        """
        创建一条机器人任务。

        Args:
            task_name: 任务名称，例如 welcome、order、delivery
            target_x: 目标点 x 坐标
            target_y: 目标点 y 坐标
            status: 任务状态，默认 pending

        Returns:
            int: 新任务 id
        """
        sql = """
        INSERT INTO robot_task
        (task_name, target_x, target_y, status)
        VALUES (%s, %s, %s, %s)
        """

        connection = DatabaseManager.get_connection()
        try:
            with connection.cursor() as cursor:
                cursor.execute(sql, (task_name, target_x, target_y, status))
                connection.commit()
                return cursor.lastrowid
        finally:
            connection.close()

    @staticmethod
    def get_task_by_id(task_id: int) -> Optional[Dict[str, Any]]:
        """
        根据任务 id 查询任务。

        Args:
            task_id: 任务 id

        Returns:
            dict | None: 任务记录
        """
        sql = """
        SELECT *
        FROM robot_task
        WHERE id = %s
        """

        connection = DatabaseManager.get_connection()
        try:
            with connection.cursor() as cursor:
                cursor.execute(sql, (task_id,))
                return cursor.fetchone()
        finally:
            connection.close()

    @staticmethod
    def get_pending_tasks() -> List[Dict[str, Any]]:
        """
        查询所有待执行任务。

        Returns:
            list[dict]: 待执行任务列表
        """
        sql = """
        SELECT *
        FROM robot_task
        WHERE status = 'pending'
        ORDER BY created_at ASC
        """

        connection = DatabaseManager.get_connection()
        try:
            with connection.cursor() as cursor:
                cursor.execute(sql)
                return cursor.fetchall()
        finally:
            connection.close()

    @staticmethod
    def update_task_status(task_id: int, status: str) -> None:
        """
        更新任务状态。

        当任务状态为 finished 时，自动写入 finished_at 时间。

        Args:
            task_id: 任务 id
            status: 新状态，例如 pending、running、finished、failed
        """
        sql = """
        UPDATE robot_task
        SET status = %s,
            finished_at = CASE
                WHEN %s = 'finished' THEN NOW()
                ELSE finished_at
            END
        WHERE id = %s
        """

        connection = DatabaseManager.get_connection()
        try:
            with connection.cursor() as cursor:
                cursor.execute(sql, (status, status, task_id))
                connection.commit()
        finally:
            connection.close()

    @staticmethod
    def delete_task(task_id: int) -> None:
        """
        删除指定任务。

        Args:
            task_id: 任务 id
        """
        sql = """
        DELETE FROM robot_task
        WHERE id = %s
        """

        connection = DatabaseManager.get_connection()
        try:
            with connection.cursor() as cursor:
                cursor.execute(sql, (task_id,))
                connection.commit()
        finally:
            connection.close()
