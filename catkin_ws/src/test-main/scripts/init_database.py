"""
数据库初始化脚本。

运行方式：
在项目根目录下执行：

python scripts/init_database.py

作用：
1. 创建 robot_db 数据库
2. 创建 robot_status 表
3. 创建 robot_task 表
4. 创建 robot_log 表
"""

from pathlib import Path
import sys

import pymysql

# 保证从项目根目录或 scripts 目录运行时，都能导入 src 包
PROJECT_ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(PROJECT_ROOT))

from src.config.database_config import DB_CONFIG  # noqa: E402


def split_sql_statements(sql_content: str):
    """
    简单拆分 SQL 语句。

    Args:
        sql_content: SQL 文件内容

    Returns:
        list[str]: SQL 语句列表
    """
    return [
        statement.strip()
        for statement in sql_content.split(";")
        if statement.strip()
    ]


def init_database() -> None:
    """
    初始化数据库和数据表。
    """
    connection = pymysql.connect(
        host=DB_CONFIG["host"],
        port=DB_CONFIG["port"],
        user=DB_CONFIG["user"],
        password=DB_CONFIG["password"],
        charset=DB_CONFIG["charset"],
    )

    sql_file = PROJECT_ROOT / "scripts" / "create_tables.sql"

    try:
        sql_content = sql_file.read_text(encoding="utf-8")
        sql_statements = split_sql_statements(sql_content)

        with connection.cursor() as cursor:
            for statement in sql_statements:
                cursor.execute(statement)

        connection.commit()
        print("数据库初始化完成")

    finally:
        connection.close()


if __name__ == "__main__":
    init_database()
