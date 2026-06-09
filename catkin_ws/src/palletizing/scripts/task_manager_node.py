#!/usr/bin/env python3
# coding=utf-8
"""码垛机器人系统 - 任务管理主控节点。

系统的中心调度器，维护核心有限状态机，协调导航、视觉、机械臂三大子模块。
所有控制流必须经过本节点，数据流 (相机图像、TF、关节状态) 由子模块直接订阅。
"""

from typing import Optional, Dict, Any
from collections import deque

import rospy
import actionlib
from std_msgs.msg import String
from geometry_msgs.msg import Point, Twist

from palletizing.msg import (
    NavigateAction,
    NavigateGoal,
    GrabAction,
    GrabGoal,
    PalletizeAction,
    PalletizeGoal,
)
from palletizing.srv import (
    TriggerDetection,
    TriggerDetectionRequest,
    SystemReset,
    SystemResetRequest,
    SystemResetResponse,
)
from palletizing_core.task_types import (
    TaskState,
    TaskCommand,
    TaskStatus,
    ErrorType,
    ErrorStrategy,
)
from palletizing_core.safety_guard import SafetyGuard


# ─── 子模块 Action/Service 的完整名称 ───
# launch 文件中，各节点的 name 分别为:
#   navigation_server, manipulator_server, vision_service
# 使用 ~ (私有命名空间) 后实际路径为:
#   /palletizing/navigation_server/navigate
#   /palletizing/manipulator_server/grab
#   /palletizing/manipulator_server/palletize
#   /palletizing/vision_service/trigger_detection
NAV_ACTION_NAME = "/palletizing/navigation_server/navigate"
GRAB_ACTION_NAME = "/palletizing/manipulator_server/grab"
PALLETIZE_ACTION_NAME = "/palletizing/manipulator_server/palletize"
VISION_SERVICE_NAME = "/palletizing/vision_service/trigger_detection"


class PlacementTracker:
    """码垛位置跟踪器，管理每个区域的当前码垛进度。

    记录每个区域的当前列号和层号，支持自动换列。
    """

    def __init__(self, zones_config: Dict[str, Any]) -> None:
        self._zones = zones_config
        # {zone_name: {"column": int, "layer": int}}
        self._progress: Dict[str, Dict[str, int]] = {}

    def get_current(self, zone: str) -> Dict[str, Any]:
        """获取指定区域当前码垛位置信息。

        Returns:
            包含 column, layer, max_layers 的字典
        """
        if zone not in self._progress:
            self._progress[zone] = {"column": 0, "layer": 0}

        placement = self._zones.get(zone, {}).get("placement", {})
        max_layers = placement.get("max_layers", 2)
        progress = self._progress[zone]

        return {
            "column": progress["column"],
            "layer": progress["layer"] + 1,  # 下一层 (1-indexed)
            "max_layers": max_layers,
            "default_step": placement.get("default_step", 0.15),
        }

    def advance(self, zone: str) -> None:
        """在放置成功后推进码垛进度。层满则换列。"""
        if zone not in self._progress:
            self._progress[zone] = {"column": 0, "layer": 0}

        placement = self._zones.get(zone, {}).get("placement", {})
        max_layers = placement.get("max_layers", 2)
        progress = self._progress[zone]

        progress["layer"] += 1
        if progress["layer"] >= max_layers:
            progress["column"] += 1
            progress["layer"] = 0
            rospy.loginfo(
                "[PlacementTracker] 区域 %s 第%d列已满, 切换到第%d列",
                zone, progress["column"] - 1, progress["column"],
            )

    def reset(self, zone: Optional[str] = None) -> None:
        """重置码垛进度。zone=None 时重置全部。"""
        if zone:
            self._progress.pop(zone, None)
        else:
            self._progress.clear()


class TaskManager:
    """任务管理器，系统的中央调度枢纽。

    Attributes:
        _safety: 安全防护器
        _task_queue: 待执行任务队列
        _current_task: 当前正在执行的任务状态
        _placement_tracker: 码垛位置跟踪器
        _state_pub: 状态广播话题发布器
        _nav_client: 导航 Action 客户端
        _grab_client: 抓取 Action 客户端
        _palletize_client: 码垛 Action 客户端
        _vision_proxy: 视觉检测服务代理
        _error_config: 异常处理配置
    """

    def __init__(self) -> None:
        self._safety = SafetyGuard()
        self._task_queue: deque = deque()
        self._current_task: Optional[TaskStatus] = None

        zones_cfg: Dict[str, Any] = rospy.get_param("~zones", {})
        self._placement_tracker = PlacementTracker(zones_cfg)

        self._error_config: Dict[str, Any] = {
            "max_detection_retries": rospy.get_param(
                "~error_handling/max_detection_retries", 3
            ),
            "max_grab_retries": rospy.get_param(
                "~error_handling/max_grab_retries", 1
            ),
        }

        self._state_pub = rospy.Publisher(
            "~task_status", String, queue_size=10
        )

        # ─── Action 客户端初始化 ───
        rospy.loginfo("[TaskManager] 等待 Action Server 启动...")
        self._nav_client = actionlib.SimpleActionClient(
            NAV_ACTION_NAME, NavigateAction
        )
        self._grab_client = actionlib.SimpleActionClient(
            GRAB_ACTION_NAME, GrabAction
        )
        self._palletize_client = actionlib.SimpleActionClient(
            PALLETIZE_ACTION_NAME, PalletizeAction
        )

        # 实机环境 move_base / kinect2_bridge 等重量级节点需要更长时间初始化
        _AS_TIMEOUT = 120.0
        if not self._nav_client.wait_for_server(timeout=rospy.Duration(_AS_TIMEOUT)):
            rospy.logerr(
                "[TaskManager] 导航 Action Server 连接超时 (%.0fs)! 请确认 navigation_server 和 move_base 已正常启动。",
                _AS_TIMEOUT,
            )
            rospy.signal_shutdown("导航 Action Server 未就绪")
            return
        if not self._grab_client.wait_for_server(timeout=rospy.Duration(_AS_TIMEOUT)):
            rospy.logerr(
                "[TaskManager] 抓取 Action Server 连接超时 (%.0fs)! 请确认 manipulator_server 已正常启动。",
                _AS_TIMEOUT,
            )
            rospy.signal_shutdown("抓取 Action Server 未就绪")
            return
        if not self._palletize_client.wait_for_server(timeout=rospy.Duration(_AS_TIMEOUT)):
            rospy.logerr(
                "[TaskManager] 码垛 Action Server 连接超时 (%.0fs)! 请确认 manipulator_server 已正常启动。",
                _AS_TIMEOUT,
            )
            rospy.signal_shutdown("码垛 Action Server 未就绪")
            return
        rospy.loginfo("[TaskManager] 所有 Action Server 已连接")

        # ─── Service 代理初始化 ───
        rospy.loginfo("[TaskManager] 等待视觉检测服务...")
        try:
            rospy.wait_for_service(VISION_SERVICE_NAME, timeout=120.0)
        except rospy.ROSException:
            rospy.logerr(
                "[TaskManager] 视觉检测服务连接超时 (120s)! 请确认 vision_service 已正常启动。"
            )
            rospy.signal_shutdown("视觉检测服务未就绪")
            return
        self._vision_proxy = rospy.ServiceProxy(
            VISION_SERVICE_NAME, TriggerDetection
        )
        rospy.loginfo("[TaskManager] 视觉检测服务已连接")

        # ─── 对外服务 ───
        rospy.Service(
            "~system_reset",
            SystemReset,
            self._handle_system_reset,
        )

        rospy.Subscriber(
            "~add_task", String,
            self._add_task_cb, queue_size=10
        )
        rospy.Subscriber(
            "~set_state", String,
            self._set_state_cb, queue_size=1
        )

        rospy.loginfo("[TaskManager] ══════ 任务管理器已就绪 ══════")

    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    #  任务接收
    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    def _add_task_cb(self, msg: String) -> None:
        """解析并加入新任务指令。

        消息格式: "源区域,货物类型,目标区域"
        例: "A,red_box,B"

        Args:
            msg: 指令字符串
        """
        parts = msg.data.strip().split(",")
        if len(parts) != 3:
            rospy.logerr(
                "[TaskManager] 指令格式错误 (期望 '源区域,货物类型,目标区域'): %s",
                msg.data,
            )
            return

        cmd = TaskCommand(
            source_zone=parts[0].strip(),
            cargo_type=parts[1].strip(),
            target_zone=parts[2].strip(),
        )
        self._task_queue.append(cmd)
        rospy.loginfo(
            "[TaskManager] 新任务入队: %s -> %s (%s)，队列长度=%d",
            cmd.source_zone, cmd.target_zone, cmd.cargo_type,
            len(self._task_queue),
        )

    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    #  核心状态机循环
    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    def run(self) -> None:
        """主循环，按状态机逻辑调度各模块。"""
        rate = rospy.Rate(2)
        while not rospy.is_shutdown():
            if self._current_task is None:
                self._try_dequeue()
                self._publish_status()
                rate.sleep()
                continue

            state = self._current_task.state
            self._publish_status()

            if state == TaskState.EMERGENCY_STOP:
                # 紧急停机：不执行任何自主动作，仅在上面广播状态
                # /cmd_vel 未被锁定，允许键盘手动遥控
                rate.sleep()
                continue

            if state == TaskState.IDLE:
                self._transition_to(TaskState.NAVIGATING_TO_OBSERVE)

            elif state == TaskState.NAVIGATING_TO_OBSERVE:
                self._execute_navigate_to_observe()

            elif state == TaskState.DETECTING:
                self._execute_detection()

            elif state == TaskState.APPROACHING_AND_GRABBING:
                self._execute_grab()

            elif state == TaskState.NAVIGATING_TO_TARGET:
                self._execute_navigate_to_target()

            elif state == TaskState.PALLETIZING:
                self._execute_palletize()

            elif state == TaskState.RETURNING_TO_SOURCE:
                self._execute_return_to_source()

            elif state == TaskState.ERROR:
                self._handle_error()

            rate.sleep()

    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    #  各状态执行方法
    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    def _try_dequeue(self) -> None:
        """尝试从队列中取出下一条任务。"""
        if self._task_queue:
            cmd = self._task_queue.popleft()
            self._current_task = TaskStatus(command=cmd, state=TaskState.IDLE)
            rospy.loginfo(
                "[TaskManager] 开始执行任务: %s -> %s (%s)",
                cmd.source_zone, cmd.target_zone, cmd.cargo_type,
            )

    def _execute_navigate_to_observe(self) -> None:
        """驱动底盘导航至源区域观测点。"""
        cmd = self._current_task.command
        goal = NavigateGoal()
        goal.target_name = cmd.source_zone

        rospy.loginfo(
            "[TaskManager] 导航至观测点: 区域 %s", cmd.source_zone
        )
        self._nav_client.send_goal_and_wait(
            goal, rospy.Duration(120.0)
        )
        state = self._nav_client.get_state()

        if state == actionlib.GoalStatus.SUCCEEDED:
            self._transition_to(TaskState.DETECTING)
        elif state == actionlib.GoalStatus.PREEMPTED:
            # 手柄抢占: 立即触发全局紧急停机
            self._enter_emergency_stop("导航至观测点过程中被抢占")
        else:
            self._set_error(ErrorType.NAVIGATION_FAILURE, "导航至观测点失败")

    def _execute_detection(self) -> None:
        """调用视觉服务进行单次目标检测。"""
        cmd = self._current_task.command
        try:
            req = TriggerDetectionRequest()
            req.cargo_type = cmd.cargo_type
            resp = self._vision_proxy(req)
        except rospy.ServiceException as e:
            self._set_error(
                ErrorType.OBJECT_NOT_FOUND,
                "视觉服务调用异常: %s" % str(e),
            )
            return

        if resp.success:
            # 将检测到的位置暂存到 TaskStatus.message 中供抓取阶段使用
            self._current_task.message = "%.4f,%.4f,%.4f" % (
                resp.position.x, resp.position.y, resp.position.z,
            )
            self._transition_to(TaskState.APPROACHING_AND_GRABBING)
        else:
            self._set_error(ErrorType.OBJECT_NOT_FOUND, resp.message)

    def _execute_grab(self) -> None:
        """控制机械臂执行抓取动作。"""
        coords = self._current_task.message.split(",")
        goal = GrabGoal()
        goal.target_position = Point(
            x=float(coords[0]),
            y=float(coords[1]),
            z=float(coords[2]),
        )

        rospy.loginfo("[TaskManager] 开始抓取...")
        self._grab_client.send_goal_and_wait(
            goal, rospy.Duration(60.0)
        )
        state = self._grab_client.get_state()

        if state == actionlib.GoalStatus.SUCCEEDED:
            self._transition_to(TaskState.NAVIGATING_TO_TARGET)
        else:
            self._set_error(ErrorType.GRAB_FAILURE, "抓取动作失败")

    def _execute_navigate_to_target(self) -> None:
        """携带货物导航至目标区域的放置点。"""
        cmd = self._current_task.command
        goal = NavigateGoal()
        # 使用 __place 后缀, 导航到放置起始点
        goal.target_name = cmd.target_zone + "__place"

        rospy.loginfo(
            "[TaskManager] 导航至放置点: 区域 %s", cmd.target_zone
        )
        self._nav_client.send_goal_and_wait(
            goal, rospy.Duration(120.0)
        )
        state = self._nav_client.get_state()

        if state == actionlib.GoalStatus.SUCCEEDED:
            self._transition_to(TaskState.PALLETIZING)
        elif state == actionlib.GoalStatus.PREEMPTED:
            self._enter_emergency_stop("导航至放置点过程中被抢占")
        else:
            self._set_error(ErrorType.NAVIGATION_FAILURE, "导航至放置点失败")

    def _execute_palletize(self) -> None:
        """执行码垛放置动作，自动管理列号和层号。

        第一层：直接按计算位置放置。
        第二层及以上：调用视觉识别检测已放置的方块，选取距离
        理论位置最近的方块来修正水平坐标，保证精准堆叠。
        """
        cmd = self._current_task.command
        zone = cmd.target_zone
        info = self._placement_tracker.get_current(zone)

        goal = PalletizeGoal()
        goal.layer = info["layer"]

        import math
        # 1. 读取 zones 配置文件参数
        zones_cfg = rospy.get_param("~zones", {})
        zone_cfg = zones_cfg.get(zone, {})
        placement = zone_cfg.get("placement", {})
        obs = zone_cfg.get("observation_point", {})

        # 读取配置的参考系，默认为 "map"
        frame = placement.get("frame", "map")
        
        start_x = placement.get("start_x", 0.9)
        start_y = placement.get("start_y", 0.0)
        direction_x = placement.get("direction_x", 1.0)
        direction_y = placement.get("direction_y", 0.0)
        default_step = placement.get("default_step", 0.15)
        
        col = info["column"]

        if frame == "map":
            # 机器人观测点在全局 map 下的位姿
            obs_x = obs.get("x", 0.0)
            obs_y = obs.get("y", 0.0)
            yaw = obs.get("yaw", 0.0)

            # 2. 计算当前目标列在全局 map 坐标系下的绝对放置坐标
            map_target_x = start_x + col * default_step * direction_x
            map_target_y = start_y + col * default_step * direction_y

            # 3. 将 map 绝对坐标转换到机器人当前观测点 (base_footprint) 的局部相对坐标系下
            dx = map_target_x - obs_x
            dy = map_target_y - obs_y
            
            cos_y = math.cos(yaw)
            sin_y = math.sin(yaw)
            
            theoretical_x = dx * cos_y + dy * sin_y
            theoretical_y = -dx * sin_y + dy * cos_y
        else:
            # frame == "base_link": 参数原本就是配置在机器人前方和侧方的局部坐标
            # 因此方向向量也是指的机器人眼中的局部方向 (例如: 正前方 direction_x=1，正左方 direction_y=1)
            theoretical_x = start_x + col * default_step * direction_x
            theoretical_y = start_y + col * default_step * direction_y

        # 尝试调用视觉进行对齐
        # 注意：如果是 0 列 1 层 (即第一个物块)，则跳过识别，直接按理论坐标放置作为锚点
        if info["column"] == 0 and info["layer"] == 1:
            rospy.loginfo("[TaskManager] 首个物块，跳过视觉识别，使用理论锚点")
        else:
            try:
                req = TriggerDetectionRequest()
                req.cargo_type = ""  # 匹配桌面上任何已有的方块
                resp = self._vision_proxy(req)
                if resp.success:
                    # 发现已有方块，将其作为深度 (X) 基准，解决多列不平齐问题
                    best_x = resp.position.x
                    rospy.loginfo(
                        "[TaskManager] 视觉修正深度 (X): 理论 %.3f -> 视觉 %.3f",
                        theoretical_x, best_x,
                    )
                    theoretical_x = best_x

                    if info["layer"] >= 2:
                        # 二层及以上：同时修正水平 (Y) 基准实现精准对齐
                        best_y = resp.position.y
                        rospy.loginfo(
                            "[TaskManager] 视觉修正水平 (Y): 理论 %.3f -> 视觉 %.3f",
                            theoretical_y, best_y,
                        )
                        theoretical_y = best_y
                else:
                    rospy.loginfo("[TaskManager] 视觉未发现参照物，使用理论坐标")
            except rospy.ServiceException as e:
                rospy.logwarn("[TaskManager] 视觉服务不可用 (%s)，使用理论坐标", str(e))

        goal.place_position = Point(
            x=theoretical_x,
            y=theoretical_y,
            z=0.0,
        )

        rospy.loginfo(
            "[TaskManager] 码垛: 区域 %s, 第%d列 第%d层, 坐标(%.3f, %.3f)",
            zone, info["column"], info["layer"], theoretical_x, theoretical_y,
        )
        self._palletize_client.send_goal_and_wait(
            goal, rospy.Duration(60.0)
        )
        state = self._palletize_client.get_state()

        if state == actionlib.GoalStatus.SUCCEEDED:
            self._placement_tracker.advance(zone)
            # 放置成功后，返回源区域继续搬运（直到源区域无物品）
            self._transition_to(TaskState.RETURNING_TO_SOURCE)
        else:
            # 检查是否是运输途中掉落
            palletize_result = self._palletize_client.get_result()
            if palletize_result and "运输途中货物掉落" in palletize_result.message:
                self._set_error(ErrorType.CARGO_DROPPED, palletize_result.message)
            else:
                self._set_error(ErrorType.STACK_COLLAPSE, "码垛放置失败")

    def _execute_return_to_source(self) -> None:
        """放置完毕后返回源区域，重新检测并继续搬运。

        如果源区域已无物品，检测阶段会触发 OBJECT_NOT_FOUND，
        最终经由异常处理的 SKIP 策略结束任务。
        """
        cmd = self._current_task.command
        goal = NavigateGoal()
        goal.target_name = cmd.source_zone

        rospy.loginfo(
            "[TaskManager] 返回源区域: 区域 %s", cmd.source_zone
        )
        self._nav_client.send_goal_and_wait(
            goal, rospy.Duration(120.0)
        )
        state = self._nav_client.get_state()

        if state == actionlib.GoalStatus.SUCCEEDED:
            # 到达源区域，重置重试计数器并进入检测状态
            self._current_task.retry_count = 0
            self._transition_to(TaskState.DETECTING)
        elif state == actionlib.GoalStatus.PREEMPTED:
            self._enter_emergency_stop("返回源区域被手柄抢占")
        else:
            self._set_error(ErrorType.NAVIGATION_FAILURE, "返回源区域失败")

    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    #  异常处理
    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    def _handle_error(self) -> None:
        """根据异常类型决定处理策略。"""
        task = self._current_task
        error = task.error_type
        strategy = self._decide_error_strategy(error, task.retry_count)

        rospy.logwarn(
            "[TaskManager] 异常处理: %s, 策略: %s, 重试次数: %d",
            error.name if error else "UNKNOWN",
            strategy.name,
            task.retry_count,
        )

        if strategy == ErrorStrategy.RETRY:
            task.retry_count += 1
            # 检测失败 → 底盘微调后重新检测
            if error == ErrorType.OBJECT_NOT_FOUND:
                self._nudge_chassis()
                self._transition_to(TaskState.DETECTING)
            elif error == ErrorType.GRAB_FAILURE:
                self._safety.stop_manipulator()
                rospy.sleep(1.0)
                self._transition_to(TaskState.DETECTING)
            else:
                self._transition_to(TaskState.IDLE)

        elif strategy == ErrorStrategy.SKIP:
            self._safety.stop_manipulator()
            if error == ErrorType.CARGO_DROPPED:
                # 货物中途掉落：放弃该货物，返回源区域继续搬运其他
                rospy.logwarn("[TaskManager] 货物掉落，返回源区域继续搬运")
                self._current_task.retry_count = 0
                self._transition_to(TaskState.RETURNING_TO_SOURCE)
            elif error == ErrorType.OBJECT_NOT_FOUND:
                # 源区域无物品可检测：终止
                rospy.loginfo("[TaskManager] 源区域无目标物品，任务结束")
                self._current_task = None
            else:
                rospy.logwarn("[TaskManager] 跳过当前任务")
                self._current_task = None

        elif strategy == ErrorStrategy.EMERGENCY_STOP:
            self._enter_emergency_stop(f"遇到无法恢复的错误: {error.name if error else 'UNKNOWN'}")

    def _decide_error_strategy(
        self, error: Optional[ErrorType], retry_count: int
    ) -> ErrorStrategy:
        """根据异常类型与重试次数决定处理策略。

        Args:
            error: 异常类型
            retry_count: 当前已重试次数

        Returns:
            对应的处理策略
        """
        if error == ErrorType.OBJECT_NOT_FOUND:
            max_retries = self._error_config["max_detection_retries"]
            if retry_count < max_retries:
                return ErrorStrategy.RETRY
            return ErrorStrategy.SKIP

        if error == ErrorType.GRAB_FAILURE:
            max_retries = self._error_config["max_grab_retries"]
            if retry_count < max_retries:
                return ErrorStrategy.RETRY
            return ErrorStrategy.SKIP

        if error == ErrorType.NAVIGATION_FAILURE:
            return ErrorStrategy.EMERGENCY_STOP

        if error == ErrorType.CARGO_DROPPED:
            # 货物掉落：无法拾取地上物品，跳过该货物，继续搬运其他
            return ErrorStrategy.SKIP

        if error == ErrorType.STACK_COLLAPSE:
            return ErrorStrategy.SKIP

        return ErrorStrategy.EMERGENCY_STOP

    def _nudge_chassis(self) -> None:
        """底盘微调：小幅前移以改变观测角度。"""
        nudge = rospy.get_param("~vision/retry_nudge_distance", 0.05)
        vel_pub = rospy.Publisher("/cmd_vel", Twist, queue_size=1)
        vel_msg = Twist()
        vel_msg.linear.x = 0.05

        rate = rospy.Rate(10)
        duration = nudge / 0.05
        for _ in range(int(duration * 10)):
            vel_pub.publish(vel_msg)
            rate.sleep()
        vel_pub.publish(Twist())
        rospy.loginfo("[TaskManager] 底盘微调完成 (%.2fm)", nudge)

    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    #  手动状态控制
    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    def _set_state_cb(self, msg: String) -> None:
        """处理手动状态切换指令。"""
        cmd = msg.data.strip().upper()
        
        if cmd == "EMERGENCY_STOP":
            self._enter_emergency_stop("操作员手动触发")
            
        elif cmd == "IDLE":
            # 取消所有 Action
            self._nav_client.cancel_all_goals()
            self._grab_client.cancel_all_goals()
            self._palletize_client.cancel_all_goals()
            # 机械臂自动复位至安全姿态
            self._safety.stop_manipulator()
            # 清空当前任务（队列保留，如果之前有任务在执行，等于丢弃了当前正在做的这一步）
            self._current_task = None
            rospy.loginfo("[TaskManager] ══ 已恢复至 IDLE ══")

    def _enter_emergency_stop(self, reason: str) -> None:
        """执行全局紧急停机动作。"""
        if self._current_task is None:
            # 如果当前为空闲状态，创建一个占位任务来承载紧急停机状态
            self._current_task = TaskStatus(
                command=TaskCommand("-", "-", "-"),
                state=TaskState.EMERGENCY_STOP,
                message=reason
            )
        else:
            self._current_task.state = TaskState.EMERGENCY_STOP
            self._current_task.message = reason
            
        # 取消所有正在执行的 Action Goal
        self._nav_client.cancel_all_goals()
        self._grab_client.cancel_all_goals()
        self._palletize_client.cancel_all_goals()
        # 停止底盘和机械臂
        self._safety.emergency_stop()
        rospy.logerr("[TaskManager] ═══ 紧急停机: %s ═══", reason)

    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    #  状态转换与系统服务
    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    def _transition_to(self, new_state: TaskState) -> None:
        """执行状态转换。"""
        if self._current_task is None:
            return
        if self._current_task.state == TaskState.EMERGENCY_STOP:
            rospy.logwarn("[TaskManager] 紧急停机状态锁定，拒绝向 %s 转移", new_state.name)
            return

        old_state = self._current_task.state
        self._current_task.state = new_state
        self._current_task.error_type = None
        rospy.loginfo(
            "[TaskManager] 状态转换: %s -> %s",
            old_state.name, new_state.name,
        )

    def _set_error(self, error_type: ErrorType, message: str) -> None:
        """设置当前任务为错误状态。"""
        if self._current_task is None:
            return
        if self._current_task.state == TaskState.EMERGENCY_STOP:
            rospy.logwarn("[TaskManager] 紧急停机期间产生次生异常(%s)，忽略并保持死机锁定", error_type.name)
            return

        self._current_task.state = TaskState.ERROR
        self._current_task.error_type = error_type
        self._current_task.message = message
        rospy.logerr("[TaskManager] 错误: [%s] %s", error_type.name, message)

    def _publish_status(self) -> None:
        """广播当前任务状态，供 UI 层订阅。"""
        msg = String()
        if self._current_task is None:
            msg.data = "IDLE|||等待任务"
        else:
            task = self._current_task
            if task.state == TaskState.EMERGENCY_STOP:
                msg.data = f"EMERGENCY_STOP|||紧急停机中: {task.message}"
            else:
                msg.data = "%s|%s|%s->%s|%s" % (
                    task.state.name,
                    task.command.cargo_type,
                    task.command.source_zone,
                    task.command.target_zone,
                    task.message,
                )
        self._state_pub.publish(msg)

    def _handle_system_reset(
        self, req: SystemResetRequest
    ) -> SystemResetResponse:
        """处理系统复位请求。

        清空任务队列，停止当前动作，将机器人恢复到安全状态。

        Args:
            req: 复位请求 (无参数)

        Returns:
            复位结果
        """
        rospy.logwarn("[TaskManager] ══════ 系统复位 ══════")
        resp = SystemResetResponse()

        self._task_queue.clear()
        self._current_task = None
        self._placement_tracker.reset()

        # 取消所有正在执行的 Action
        self._nav_client.cancel_all_goals()
        self._grab_client.cancel_all_goals()
        self._palletize_client.cancel_all_goals()

        self._safety.emergency_stop()
        rospy.sleep(1.0)

        resp.success = True
        resp.message = "系统已复位至空闲状态"
        rospy.loginfo("[TaskManager] %s", resp.message)
        return resp


def main() -> None:
    rospy.init_node("task_manager_node")
    manager = TaskManager()
    rospy.on_shutdown(manager._safety.emergency_stop)
    manager.run()


if __name__ == "__main__":
    main()
