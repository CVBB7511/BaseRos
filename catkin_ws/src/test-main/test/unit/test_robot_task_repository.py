"""
robot_task_repository 单元测试示例。

运行前需要先配置好数据库，并执行：
python scripts/init_database.py
"""

from src.database.repositories.robot_task_repository import RobotTaskRepository


def test_create_and_update_task():
    task_id = RobotTaskRepository.create_task(
        task_name="test_task",
        target_x=1.0,
        target_y=2.0,
    )

    task = RobotTaskRepository.get_task_by_id(task_id)
    assert task is not None
    assert task["status"] == "pending"

    RobotTaskRepository.update_task_status(task_id, "finished")

    updated_task = RobotTaskRepository.get_task_by_id(task_id)
    assert updated_task["status"] == "finished"
