"""
数据库插入测试脚本。

运行方式：
在项目根目录下执行：

python scripts/test_database_insert.py

作用：
测试数据库连接、插入状态、插入任务、插入日志是否正常。
"""

from pathlib import Path
import sys

PROJECT_ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(PROJECT_ROOT))

from src.database.repositories.robot_status_repository import RobotStatusRepository  # noqa: E402
from src.database.repositories.robot_task_repository import RobotTaskRepository  # noqa: E402
from src.database.repositories.robot_log_repository import RobotLogRepository  # noqa: E402


def main() -> None:
    """测试数据库插入和查询。"""
    robot_name = "robot_1"

    status_id = RobotStatusRepository.insert_status(
        robot_name=robot_name,
        battery=95.5,
        pos_x=1.2,
        pos_y=3.4,
        yaw=0.5,
        status="idle",
    )

    task_id = RobotTaskRepository.create_task(
        task_name="deliver_table_2",
        target_x=5.0,
        target_y=6.0,
    )

    log_id = RobotLogRepository.insert_log(
        robot_name=robot_name,
        log_level="INFO",
        message="database insert test",
    )

    latest_status = RobotStatusRepository.get_latest_status(robot_name)
    pending_tasks = RobotTaskRepository.get_pending_tasks()
    logs = RobotLogRepository.get_logs(robot_name)

    print(f"插入状态 id: {status_id}")
    print(f"插入任务 id: {task_id}")
    print(f"插入日志 id: {log_id}")
    print(f"最新状态: {latest_status}")
    print(f"待执行任务: {pending_tasks}")
    print(f"日志记录: {logs}")


if __name__ == "__main__":
    main()
