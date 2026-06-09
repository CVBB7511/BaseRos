from __future__ import annotations

from geometry_msgs.msg import Pose, Vector3

from warehouse_sorting.core import Cargo, make_pose_dict
from warehouse_sorting_msgs.msg import Cargo as CargoMsg
from warehouse_sorting_msgs.msg import TaskStatus


def pose_dict_to_msg(pose_dict):
    msg = Pose()
    msg.position.x = float(pose_dict.get("x", 0.0))
    msg.position.y = float(pose_dict.get("y", 0.0))
    msg.position.z = float(pose_dict.get("z", 0.0))
    msg.orientation.x = float(pose_dict.get("qx", 0.0))
    msg.orientation.y = float(pose_dict.get("qy", 0.0))
    msg.orientation.z = float(pose_dict.get("qz", 0.0))
    msg.orientation.w = float(pose_dict.get("qw", 1.0))
    return msg


def pose_msg_to_dict(msg):
    return make_pose_dict(
        x=msg.position.x,
        y=msg.position.y,
        z=msg.position.z,
        qx=msg.orientation.x,
        qy=msg.orientation.y,
        qz=msg.orientation.z,
        qw=msg.orientation.w,
    )


def cargo_to_msg(cargo):
    msg = CargoMsg()
    msg.cargo_id = cargo.cargo_id
    msg.cargo_type = cargo.cargo_type
    msg.pose = pose_dict_to_msg(cargo.pose)
    msg.size = Vector3(
        x=float(cargo.size.get("x", 0.0)),
        y=float(cargo.size.get("y", 0.0)),
        z=float(cargo.size.get("z", 0.0)),
    )
    msg.volume = cargo.volume
    msg.confidence = float(cargo.confidence)
    msg.bbox_x = int(cargo.bbox.get("x", 0))
    msg.bbox_y = int(cargo.bbox.get("y", 0))
    msg.bbox_width = int(cargo.bbox.get("width", 0))
    msg.bbox_height = int(cargo.bbox.get("height", 0))
    return msg


def msg_to_cargo(msg):
    return Cargo(
        cargo_id=msg.cargo_id,
        cargo_type=msg.cargo_type,
        pose=pose_msg_to_dict(msg.pose),
        size={"x": msg.size.x, "y": msg.size.y, "z": msg.size.z},
        confidence=msg.confidence,
        bbox={
            "x": msg.bbox_x,
            "y": msg.bbox_y,
            "width": msg.bbox_width,
            "height": msg.bbox_height,
        },
    )


def status_dict_to_msg(status):
    msg = TaskStatus()
    msg.task_id = status.get("task_id", "")
    msg.status = status.get("status", "")
    msg.total_items = int(status.get("total_items", 0))
    msg.completed_items = int(status.get("completed_items", 0))
    msg.failed_items = int(status.get("failed_items", 0))
    msg.sorted_natural = int(status.get("sorted_natural", 0))
    msg.sorted_colored = int(status.get("sorted_colored", 0))
    msg.progress = float(status.get("progress", 0.0))
    msg.queue_size = int(status.get("queue_size", 0))
    msg.current_step = status.get("current_step", "")
    msg.last_error = status.get("last_error", "")
    return msg
