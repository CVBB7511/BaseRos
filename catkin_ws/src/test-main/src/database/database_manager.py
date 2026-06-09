"""
数据库连接管理模块。

作用：
1. 统一创建 MySQL 数据库连接
2. 避免在不同业务模块中重复编写 pymysql.connect()
3. Repository 层统一通过 DatabaseManager.get_connection() 获取连接
"""

import pymysql

from src.config.database_config import DB_CONFIG


class DatabaseManager:
    """数据库连接管理类。"""

    @staticmethod
    def get_connection():
        """
        获取一个新的数据库连接。

        Returns:
            pymysql.connections.Connection: MySQL 数据库连接对象
        """
        return pymysql.connect(
            host=DB_CONFIG["host"],
            port=DB_CONFIG["port"],
            user=DB_CONFIG["user"],
            password=DB_CONFIG["password"],
            database=DB_CONFIG["database"],
            charset=DB_CONFIG["charset"],
            cursorclass=pymysql.cursors.DictCursor,
        )
