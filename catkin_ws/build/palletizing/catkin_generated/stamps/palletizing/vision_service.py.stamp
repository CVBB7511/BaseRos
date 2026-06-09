#!/usr/bin/env python3
# coding=utf-8
"""码垛机器人系统 - 视觉识别 Service Node (阶段一骨架)。

本模块在阶段一仅提供 TriggerDetection Service 的接口骨架，
内部调用厂家 3D 物体检测接口获取物体坐标，尚未集成 OpenCV 视觉识别。
阶段二将加入基于 HSV 的货物分类与 tf2 坐标转换。
"""

from typing import Optional
import threading

import rospy
from std_msgs.msg import String
from geometry_msgs.msg import Point
from wpb_home_behaviors.msg import Coord

from palletizing.srv import (
    TriggerDetection,
    TriggerDetectionRequest,
    TriggerDetectionResponse,
)


class VisionService:
    """视觉识别服务节点。

    通过厂家的 `/wpb_home/objects_3d` 话题获取 3D 物体检测结果，
    对上层暴露 `~trigger_detection` 同步服务。

    Attributes:
        _behaviors_pub: 厂家行为控制话题发布器
        _latest_objects: 最近一次物体检测结果缓存
        _detect_event: 检测完成事件
        _timeout: 单次检测超时时间 (秒)
    """

    def __init__(self) -> None:
        self._timeout: float = rospy.get_param(
            "~vision/detection_timeout_sec", 10.0
        )

        self._behaviors_pub = rospy.Publisher(
            "/wpb_home/behaviors", String, queue_size=10
        )
        self._latest_objects: Optional[Coord] = None
        self._detect_event = threading.Event()

        rospy.Subscriber(
            "/wpb_home/objects_3d", Coord,
            self._objects_cb, queue_size=1
        )

        rospy.Service(
            "~trigger_detection",
            TriggerDetection,
            self._handle_detection,
        )
        rospy.loginfo("[VisionService] TriggerDetection 服务已就绪")

    def _objects_cb(self, msg: Coord) -> None:
        """缓存最新的 3D 物体检测结果。"""
        self._latest_objects = msg
        self._detect_event.set()

    def _handle_detection(
        self, req: TriggerDetectionRequest
    ) -> TriggerDetectionResponse:
        """处理单次视觉识别请求。

        在超时窗口内持续等待有效的检测结果。C++ 节点逐帧处理点云，
        单帧可能因 TF 未就绪或 RANSAC 未收敛而返回空结果，
        因此需要容忍前几帧的失败，直到收到有效数据或超时。

        Args:
            req: 包含 cargo_type 的检测请求

        Returns:
            检测响应，包含成功标志和目标位置
        """
        resp = TriggerDetectionResponse()

        # 激活厂家物体检测
        self._detect_event.clear()
        self._latest_objects = None
        activate_msg = String()
        activate_msg.data = "object_detect start"
        self._behaviors_pub.publish(activate_msg)

        # 在超时窗口内循环等待有效结果
        deadline = rospy.Time.now() + rospy.Duration(self._timeout)
        objects = None
        while rospy.Time.now() < deadline:
            remaining = (deadline - rospy.Time.now()).to_sec()
            if remaining <= 0:
                break

            if not self._detect_event.wait(timeout=remaining):
                break

            candidate = self._latest_objects
            if candidate is not None and len(candidate.name) > 0:
                objects = candidate
                break

            # 收到了空结果（该帧未识别到物体），继续等待下一帧
            rospy.loginfo("[VisionService] 本帧未检测到物体，继续等待...")
            self._detect_event.clear()
            self._latest_objects = None

        self._stop_detection()

        if objects is None or len(objects.name) == 0:
            resp.success = False
            resp.message = "视觉检测超时或未检测到物体 (%.1fs)" % self._timeout
            rospy.logwarn("[VisionService] %s", resp.message)
            return resp

        # 打印所有检测到的物体
        n_objects = len(objects.name)
        rospy.loginfo(
            "[VisionService] 共检测到 %d 个物体: %s",
            n_objects, ", ".join(objects.name),
        )

        # 基于 cargo_type 进行过滤分类
        matched_indices = []
        for i in range(n_objects):
            if req.cargo_type in objects.name[i]:
                matched_indices.append(i)

        if not matched_indices:
            resp.success = False
            resp.message = "未找到目标类型的物体 (%s)" % req.cargo_type
            rospy.logwarn("[VisionService] %s", resp.message)
            return resp

        # 选取第一个匹配的物体
        selected_idx = matched_indices[0]
        resp.success = True
        resp.position = Point(
            x=objects.x[selected_idx],
            y=objects.y[selected_idx],
            z=objects.z[selected_idx],
        )
        resp.remaining_count = len(matched_indices) - 1

        resp.message = "检测到 %d 个目标 (%d 个备选), 选取 '%s' at (%.3f, %.3f, %.3f)" % (
            len(matched_indices),
            resp.remaining_count,
            objects.name[selected_idx],
            objects.x[selected_idx],
            objects.y[selected_idx],
            objects.z[selected_idx],
        )
        rospy.loginfo("[VisionService] %s", resp.message)
        return resp

    def _stop_detection(self) -> None:
        """停止厂家物体检测行为。"""
        stop_msg = String()
        stop_msg.data = "object_detect stop"
        self._behaviors_pub.publish(stop_msg)


def main() -> None:
    rospy.init_node("vision_service")
    _ = VisionService()
    rospy.spin()


if __name__ == "__main__":
    main()
