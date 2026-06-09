"""
数据库连接集成测试。

运行前需要先配置好数据库，并执行：
python scripts/init_database.py
"""

from src.database.database_manager import DatabaseManager


def test_database_connection():
    connection = DatabaseManager.get_connection()

    try:
        with connection.cursor() as cursor:
            cursor.execute("SELECT 1 AS result")
            row = cursor.fetchone()

        assert row["result"] == 1

    finally:
        connection.close()
