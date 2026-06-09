"""
robot_log_repository 单元测试示例。

运行前需要先配置好数据库，并执行：
python scripts/init_database.py
"""

from src.database.repositories.robot_log_repository import RobotLogRepository


def test_insert_and_get_logs():
    robot_name = "test_robot"

    RobotLogRepository.insert_log(
        robot_name=robot_name,
        log_level="INFO",
        message="unit test log",
    )

    logs = RobotLogRepository.get_logs(robot_name)

    assert len(logs) > 0
    assert logs[0]["robot_name"] == robot_name
