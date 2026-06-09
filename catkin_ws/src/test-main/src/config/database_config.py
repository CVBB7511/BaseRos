"""
数据库连接配置文件。

使用前请根据你的实际环境修改：
1. host：数据库所在虚拟机或服务器 IP
2. user：MySQL 用户名
3. password：MySQL 密码
4. database：数据库名
"""

DB_CONFIG = {
    "host": "127.0.0.1",
    "port": 3306,
    "user": "robot_user",
    "password": "your_password",
    "database": "robot_db",
    "charset": "utf8mb4",
}
