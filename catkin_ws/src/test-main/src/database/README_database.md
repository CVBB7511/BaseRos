# 数据库模块使用说明

## 1. 修改数据库配置

打开：

```text
src/config/database_config.py
```

修改以下内容：

```python
DB_CONFIG = {
    "host": "你的数据库IP",
    "port": 3306,
    "user": "robot_user",
    "password": "你的数据库密码",
    "database": "robot_db",
    "charset": "utf8mb4",
}
```

## 2. 安装依赖

```bash
pip install -r requirements.txt
```

如果你在 ROS 2 环境中使用，请确保当前 Python 环境能使用 pymysql。

## 3. 初始化数据库

在项目根目录运行：

```bash
python scripts/init_database.py
```

## 4. 测试插入数据

```bash
python scripts/test_database_insert.py
```

## 5. 在业务代码中使用

```python
from src.database.repositories.robot_task_repository import RobotTaskRepository

task_id = RobotTaskRepository.create_task(
    task_name="delivery",
    target_x=5.0,
    target_y=6.0,
)
```

```python
from src.database.repositories.robot_status_repository import RobotStatusRepository

RobotStatusRepository.insert_status(
    robot_name="robot_1",
    battery=95.0,
    pos_x=1.2,
    pos_y=3.4,
    yaw=0.5,
    status="moving",
)
```

```python
from src.database.repositories.robot_log_repository import RobotLogRepository

RobotLogRepository.insert_log(
    robot_name="robot_1",
    log_level="INFO",
    message="robot started",
)
```

## 6. 文件位置说明

```text
src/config/database_config.py
数据库连接配置

src/database/database_manager.py
数据库连接管理

src/database/models/
数据模型

src/database/repositories/
数据库增删改查代码

scripts/create_tables.sql
建表 SQL

scripts/init_database.py
初始化数据库脚本

scripts/test_database_insert.py
数据库插入测试脚本
```
