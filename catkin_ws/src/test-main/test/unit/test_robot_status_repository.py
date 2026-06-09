"""
robot_status_repository 单元测试示例。

运行前需要先配置好数据库，并执行：
python scripts/init_database.py
"""

from src.database.repositories.robot_status_repository import RobotStatusRepository


def test_insert_and_get_latest_status():
    robot_name = "test_robot"

    RobotStatusRepository.insert_status(
        robot_name=robot_name,
        battery=88.0,
        pos_x=1.0,
        pos_y=2.0,
        yaw=0.1,
        status="testing",
    )

    latest_status = RobotStatusRepository.get_latest_status(robot_name)

    assert latest_status is not None
    assert latest_status["robot_name"] == robot_name
    assert latest_status["status"] == "testing"
