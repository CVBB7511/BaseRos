#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
餐厅服务机器人主控节点。

职责：
1. 订阅语音模块发布的 /voice_cmd；
2. 根据语音意图创建迎宾带位、点餐、送餐等业务任务；
3. 统一向 task_dispatcher 发布 /restaurant/task_name；
4. 监听 /restaurant/task_status，并将任务状态写入数据库；
5. 统一向 /tts_speak 输出提示语；
6. 维护当前餐桌，并发布 /restaurant/current_table；
7. 通过 ExceptionReporter 将关键异常发布到 /restaurant/exception_event。

模块关系：
voice_interaction_node
    ↓ /voice_cmd
robot_controller
    ↓ /restaurant/task_name
task_dispatcher
    ↓ /restaurant/nav_target
navigation_manager
"""

import json
import os
import re
import sys
from pathlib import Path
from typing import Any, Dict, Optional, Tuple

import rospy
from std_msgs.msg import Bool, String


def find_project_root() -> Path:
    """
    查找项目根目录，保证 ROS 启动节点时可以导入 src.database 等模块。

    兼容场景：
    1. 直接从 GitLab 项目结构运行：test-main/src/core/robot_controller.py；
    2. catkin 工作空间运行：catkin_ws/src/test-main/src/core/robot_controller.py；
    3. 通过环境变量 RESTAURANT_ROBOT_PROJECT_ROOT 指定项目根目录。
    """
    script_path = Path(__file__).resolve()

    for candidate in [script_path.parent] + list(script_path.parents):
        if (candidate / "src" / "database").is_dir() and \
           (candidate / "src" / "config").is_dir():
            return candidate

    env_root = os.environ.get("RESTAURANT_ROBOT_PROJECT_ROOT", "").strip()
    if env_root:
        candidate = Path(env_root).expanduser().resolve()
        if (candidate / "src" / "database").is_dir() and \
           (candidate / "src" / "config").is_dir():
            return candidate

    ros_package_path = os.environ.get("ROS_PACKAGE_PATH", "")
    for base_text in ros_package_path.split(os.pathsep):
        if not base_text:
            continue

        base = Path(base_text).expanduser().resolve()
        candidates = [base, base / "test-main", base / "test"]

        try:
            candidates.extend([child for child in base.iterdir() if child.is_dir()])
        except Exception:
            pass

        for candidate in candidates:
            if (candidate / "src" / "database").is_dir() and \
               (candidate / "src" / "config").is_dir():
                return candidate

    return script_path.parents[2]


PROJECT_ROOT = find_project_root()
if str(PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(PROJECT_ROOT))

from src.database.repositories.restaurant_table_repository import RestaurantTableRepository
from src.database.repositories.table_session_repository import TableSessionRepository
from src.database.repositories.robot_task_repository import RobotTaskRepository
from src.database.repositories.robot_log_repository import RobotLogRepository
from src.exception.exception_reporter import ExceptionReporter
from src.exception.exception_types import ExceptionLevel, ExceptionSource, ExceptionType


class RobotController:
    """餐厅服务机器人主控模块。"""

    def __init__(self):
        rospy.init_node("robot_controller", anonymous=False)

        self.robot_name = rospy.get_param("~robot_name", "robot_1")

        self.default_customer_count = int(
            rospy.get_param("~default_customer_count", 1)
        )

        self.auto_create_session = self._to_bool(
            rospy.get_param("~auto_create_session", True)
        )

        self.default_table = rospy.get_param("~default_table", "table_1")
        self.current_table = self.default_table

        # 测试结果评审阶段建议保持为 true：
        # 数据库任务记录失败时，仍继续发布 ROS 任务，避免系统链路测试被数据库问题卡死。
        self.allow_task_without_db = self._to_bool(
            rospy.get_param("~allow_task_without_db", True)
        )

        # 测试结果评审阶段建议保持为 true：
        # 数据库餐桌查询失败或无可用餐桌时，回退到 default_table。
        self.fallback_table_on_db_error = self._to_bool(
            rospy.get_param("~fallback_table_on_db_error", True)
        )

        # 是否在关键异常上报时同步发布 /robot_state=EXCEPTION。
        self.publish_exception_robot_state = self._to_bool(
            rospy.get_param("~publish_exception_robot_state", True)
        )

        # 记录当前任务名与数据库任务 id 的对应关系。
        self.task_db_ids: Dict[str, int] = {}

        self.task_name_pub = rospy.Publisher(
            "/restaurant/task_name",
            String,
            queue_size=10
        )

        self.task_cancel_pub = rospy.Publisher(
            "/restaurant/task_cancel",
            Bool,
            queue_size=10
        )

        self.current_table_pub = rospy.Publisher(
            "/restaurant/current_table",
            String,
            queue_size=10
        )

        self.tts_pub = rospy.Publisher(
            "/tts_speak",
            String,
            queue_size=10
        )

        self.robot_state_pub = rospy.Publisher(
            "/robot_state",
            String,
            queue_size=10
        )

        self.exception_reporter = ExceptionReporter(
            robot_name=self.robot_name,
            source=ExceptionSource.CONTROLLER,
            topic_name="/restaurant/exception_event"
        )

        rospy.Subscriber("/voice_cmd", String, self.voice_cmd_callback)
        rospy.Subscriber("/restaurant/task_status", String, self.task_status_callback)

        self.publish_current_table(self.current_table)
        self.publish_robot_state("IDLE")
        self.insert_log("INFO", "robot_controller started")

        rospy.loginfo("robot_controller started.")

    @staticmethod
    def _to_bool(value) -> bool:
        if isinstance(value, bool):
            return value
        return str(value).strip().lower() in {"true", "1", "yes", "y", "on"}

    def insert_log(self, level: str, message: str) -> None:
        """
        安全写入机器人日志。

        日志入库失败时，只输出 ROS 警告，不让主控节点崩溃。
        """
        try:
            RobotLogRepository.insert_log(
                robot_name=self.robot_name,
                log_level=level,
                message=message
            )
        except Exception as exc:
            rospy.logwarn("Failed to insert robot log: %s", str(exc))

    def report_exception(
        self,
        exception_type: str,
        message: str,
        level: str = ExceptionLevel.ERROR,
        context: Optional[Dict[str, Any]] = None,
        exc: Optional[Exception] = None,
        speak_text: Optional[str] = None,
        publish_robot_exception_state: bool = False,
        write_db: bool = True,
    ) -> None:
        """
        统一上报主控模块感知到的异常。

        该方法只做轻量接入：
        1. 发布 /restaurant/exception_event；
        2. 尝试写入 robot_log；
        3. 按需发布 /robot_state=EXCEPTION；
        4. 按需进行语音提示。

        异常上报本身失败时，不继续向外抛异常。
        """
        if context is None:
            context = {}

        try:
            self.exception_reporter.report(
                exception_type=exception_type,
                message=message,
                level=level,
                context=context,
                exc=exc,
                write_db=write_db,
            )
        except Exception as report_exc:
            rospy.logwarn(
                "ExceptionReporter failed: %s, original_type=%s, message=%s",
                str(report_exc),
                exception_type,
                message
            )
            self.insert_log(level, f"{exception_type}: {message}; report_error={report_exc}")

        if publish_robot_exception_state and self.publish_exception_robot_state:
            self.publish_robot_state("EXCEPTION")

        if speak_text:
            self.speak(speak_text)

    def speak(self, text: str) -> None:
        self.tts_pub.publish(String(data=text))
        rospy.loginfo("[TTS] %s", text)

    def publish_robot_state(self, state: str) -> None:
        self.robot_state_pub.publish(String(data=state))
        rospy.loginfo("[ROBOT STATE] %s", state)

    def publish_current_table(self, table_nav_point: str) -> None:
        if not table_nav_point:
            return

        self.current_table = table_nav_point
        self.current_table_pub.publish(String(data=table_nav_point))
        rospy.loginfo("[CURRENT TABLE] %s", table_nav_point)

    def voice_cmd_callback(self, msg: String) -> None:
        """
        处理语音模块发布的统一语音指令。
        """
        try:
            payload = json.loads(msg.data)
        except Exception as exc:
            rospy.logwarn("Invalid /voice_cmd JSON: %s, raw=%s", str(exc), msg.data)
            self.report_exception(
                exception_type=ExceptionType.INVALID_VOICE_COMMAND,
                message="invalid /voice_cmd json",
                level=ExceptionLevel.WARNING,
                context={"raw_message": msg.data},
                exc=exc,
                speak_text="语音指令格式错误，请重新输入。",
                publish_robot_exception_state=False,
            )
            return

        intent, slots, raw_text = self.normalize_voice_payload(payload)

        rospy.loginfo(
            "[VOICE CMD] intent=%s, slots=%s, raw_text=%s",
            intent,
            slots,
            raw_text
        )

        try:
            self.dispatch_intent(intent, slots, raw_text)
        except Exception as exc:
            rospy.logerr("robot_controller dispatch error: %s", str(exc))
            self.report_exception(
                exception_type=ExceptionType.MODULE_RUNTIME_ERROR,
                message="robot_controller dispatch intent failed",
                level=ExceptionLevel.ERROR,
                context={
                    "intent": intent,
                    "slots": slots,
                    "raw_text": raw_text,
                },
                exc=exc,
                speak_text="主控模块处理指令失败，请稍后重试。",
                publish_robot_exception_state=True,
            )

    @staticmethod
    def normalize_voice_payload(payload: Dict[str, Any]) -> Tuple[str, Dict[str, Any], str]:
        """
        兼容两种 /voice_cmd 格式。

        旧格式：
            {
                "intent": "seat_request",
                "table_nav_point": "table_1",
                "customer_count": 2
            }

        新格式：
            {
                "source": "voice",
                "intent": "switch_delivery_mode",
                "slots": {
                    "task_name": "deliver_table_1",
                    "target_table": "table_1"
                },
                "raw_text": "开始送餐"
            }
        """
        intent = str(payload.get("intent", "")).strip()
        raw_text = str(payload.get("raw_text", "")).strip()

        slots = payload.get("slots")
        if not isinstance(slots, dict):
            slots = {}

        # 兼容旧格式中的顶层字段。
        for key in [
            "table_nav_point",
            "session_id",
            "order_id",
            "items",
            "task_name",
            "target_table",
            "message",
            "customer_count",
            "people_count",
            "count",
        ]:
            if key in payload and key not in slots:
                slots[key] = payload[key]

        return intent, slots, raw_text

    def dispatch_intent(self, intent: str, slots: Dict[str, Any], raw_text: str) -> None:
        """
        根据语音意图分发主控动作。
        """
        if not intent:
            self.report_exception(
                exception_type=ExceptionType.UNKNOWN_INTENT,
                message="empty voice intent",
                level=ExceptionLevel.WARNING,
                context={"slots": slots, "raw_text": raw_text},
                speak_text="没有识别到有效指令，请重新输入。",
            )
            return

        if intent in {"greeting", "greet"}:
            self.insert_log("INFO", f"receive greeting: {raw_text}")
            self.speak("您好，欢迎光临。")
            return

        if intent == "set_table":
            table_nav_point = slots.get("table_nav_point") or slots.get("target_table")
            self.handle_set_table(table_nav_point)
            return

        if intent == "seat_request":
            self.handle_welcome_and_guide(slots, raw_text)
            return

        if intent == "switch_delivery_mode":
            self.handle_delivery(slots, raw_text)
            return

        if intent == "switch_order_mode":
            self.insert_log("INFO", "switch to order mode")
            self.publish_robot_state("ORDERING")
            self.speak("已进入点餐模式。")
            return

        if intent == "confirm_order":
            order_id = slots.get("order_id")
            self.insert_log("INFO", f"order confirmed: order_id={order_id}")
            self.speak("订单已确认，后续可创建送餐任务。")
            return

        if intent in {"cancel_task", "cancel", "stop"}:
            self.task_cancel_pub.publish(Bool(data=True))
            self.insert_log("WARNING", f"task cancel requested by voice: {raw_text}")
            self.speak("已请求取消当前任务。")
            return

        if intent in {"busy", "repeat", "fallback_to_button", "unknown"}:
            self.insert_log("INFO", f"voice special intent: {intent}, raw={raw_text}")
            return

        if intent in {"database_error", "system_error"}:
            message = slots.get("message", "")
            exception_type = (
                ExceptionType.DATABASE_WRITE_FAILED
                if intent == "database_error"
                else ExceptionType.MODULE_RUNTIME_ERROR
            )
            self.report_exception(
                exception_type=exception_type,
                message=f"voice module reported {intent}: {message}",
                level=ExceptionLevel.ERROR,
                context={"slots": slots, "raw_text": raw_text},
                publish_robot_exception_state=True,
            )
            return

        # 点餐相关意图主要由 voice_interaction_node 自己处理，
        # 主控模块这里只做日志记录，不重复写订单。
        if intent in {
            "show_menu",
            "add_item",
            "add_item_failed",
            "update_item",
            "update_note",
            "remove_item",
            "confirm_order_empty",
            "cancel_temp_order",
            "cancel_order",
            "calculate_bill",
            "checkout",
            "quantity_missing",
        }:
            self.insert_log("INFO", f"order intent observed: {intent}")
            return

        self.report_exception(
            exception_type=ExceptionType.UNKNOWN_INTENT,
            message=f"unhandled voice intent: {intent}",
            level=ExceptionLevel.WARNING,
            context={"intent": intent, "slots": slots, "raw_text": raw_text},
        )

    def safe_get_table_by_nav_point(self, table_nav_point: str) -> Optional[Dict[str, Any]]:
        """
        安全查询餐桌。

        数据库异常时返回 None，不让主控节点直接崩溃。
        """
        if not table_nav_point:
            return None

        try:
            return RestaurantTableRepository.get_table_by_nav_point(table_nav_point)
        except Exception as exc:
            rospy.logwarn("Failed to query table %s: %s", table_nav_point, str(exc))
            self.report_exception(
                exception_type=ExceptionType.DATABASE_QUERY_FAILED,
                message="failed to query table by nav point",
                level=ExceptionLevel.ERROR,
                context={"table_nav_point": table_nav_point},
                exc=exc,
            )
            return None

    def get_fallback_table(self, table_nav_point: Optional[str] = None) -> Dict[str, Any]:
        """
        构造一个兜底餐桌对象。

        该对象不写入数据库，只用于测试模式或数据库异常时继续发布 ROS 任务。
        """
        nav_point = table_nav_point or self.current_table or self.default_table or "table_1"

        return {
            "id": None,
            "nav_point_name": nav_point,
            "table_display_name": nav_point,
            "capacity": max(1, self.default_customer_count),
            "pos_x": 0.0,
            "pos_y": 0.0,
            "status": "available",
            "_fallback": True,
        }

    def handle_set_table(self, table_nav_point: Optional[str]) -> None:
        """
        设置当前餐桌。
        """
        if not table_nav_point:
            self.report_exception(
                exception_type=ExceptionType.MISSING_TARGET_TABLE,
                message="set_table requested without table_nav_point",
                level=ExceptionLevel.WARNING,
                context={"current_table": self.current_table},
                speak_text="没有识别到有效餐桌。",
            )
            return

        table = self.safe_get_table_by_nav_point(table_nav_point)
        if table is None and not self.fallback_table_on_db_error:
            self.report_exception(
                exception_type=ExceptionType.TABLE_NOT_FOUND,
                message="table not found when setting current table",
                level=ExceptionLevel.WARNING,
                context={"table_nav_point": table_nav_point},
                speak_text=f"数据库中没有找到 {table_nav_point}。",
            )
            return

        self.publish_current_table(table_nav_point)
        self.speak(f"当前餐桌已设置为 {table_nav_point}。")

    def handle_welcome_and_guide(self, slots: Dict[str, Any], raw_text: str) -> None:
        """
        迎宾带位模式。

        当前采用测试稳定优先策略：
        1. 优先从数据库选择可用餐桌；
        2. 如果数据库异常或没有可用餐桌，可回退到默认桌位；
        3. 能创建 session 就创建，不能创建时允许继续发布带位任务。
        """
        customer_count = self.extract_customer_count(slots, raw_text)
        table = self.select_available_table(customer_count)

        if table is None:
            if self.fallback_table_on_db_error:
                table = self.get_fallback_table(self.default_table)
                self.report_exception(
                    exception_type=ExceptionType.TABLE_NOT_FOUND,
                    message="no available table, fallback to default table",
                    level=ExceptionLevel.WARNING,
                    context={
                        "customer_count": customer_count,
                        "fallback_table": table["nav_point_name"],
                    },
                    write_db=True,
                )
            else:
                self.report_exception(
                    exception_type=ExceptionType.TABLE_NOT_FOUND,
                    message="no available table for customer count",
                    level=ExceptionLevel.WARNING,
                    context={"customer_count": customer_count},
                    speak_text="当前没有合适的空闲餐桌，请稍后等待。",
                )
                return

        table_nav_point = table.get("nav_point_name") or self.default_table
        table_id = table.get("id")

        if self.auto_create_session and table_id is not None:
            try:
                session_id = TableSessionRepository.start_session(
                    table_id=table_id,
                    customer_count=customer_count
                )
                self.insert_log(
                    "INFO",
                    f"start table session: session_id={session_id}, table={table_nav_point}"
                )
            except Exception as exc:
                self.report_exception(
                    exception_type=ExceptionType.SESSION_CREATE_FAILED,
                    message="failed to start table session",
                    level=ExceptionLevel.ERROR,
                    context={
                        "table_id": table_id,
                        "table_nav_point": table_nav_point,
                        "customer_count": customer_count,
                    },
                    exc=exc,
                    speak_text=(
                        "餐桌会话创建失败，无法带位。"
                        if not self.allow_task_without_db
                        else None
                    ),
                    publish_robot_exception_state=not self.allow_task_without_db,
                )

                if not self.allow_task_without_db:
                    return

                rospy.logwarn("会话创建失败，但允许测试模式继续发布带位任务。")

        self.publish_current_table(table_nav_point)

        task_name = self.table_to_task(table_nav_point, prefix="guide")
        if not task_name:
            self.report_exception(
                exception_type=ExceptionType.UNKNOWN_TASK,
                message="failed to generate guide task name",
                level=ExceptionLevel.ERROR,
                context={"table_nav_point": table_nav_point},
                speak_text="无法生成带位任务名称。",
                publish_robot_exception_state=True,
            )
            return

        published = self.create_and_publish_task(
            task_name=task_name,
            table_nav_point=table_nav_point,
            task_type="guide"
        )

        if published:
            self.speak(f"已为您分配 {table_nav_point}，现在开始带位。")

    def handle_delivery(self, slots: Dict[str, Any], raw_text: str) -> None:
        """
        送餐模式。

        当前采用测试稳定优先策略：
        1. 优先使用 slots 中的 task_name 或 target_table；
        2. 若未提供，则使用 current_table；
        3. 数据库查不到目标餐桌时，可回退到目标点名称继续测试。
        """
        task_name = slots.get("task_name")
        target_table = slots.get("target_table") or slots.get("table_nav_point")

        if not task_name:
            if not target_table:
                target_table = self.current_table

            if not target_table:
                self.report_exception(
                    exception_type=ExceptionType.MISSING_TARGET_TABLE,
                    message="delivery requested but no target table",
                    level=ExceptionLevel.WARNING,
                    context={"slots": slots, "raw_text": raw_text},
                    speak_text="当前没有确定目标餐桌，无法开始送餐。",
                )
                return

            task_name = self.table_to_task(target_table, prefix="deliver")

        if not target_table:
            target_table = self.task_to_table(task_name)

        if not target_table:
            self.report_exception(
                exception_type=ExceptionType.MISSING_TARGET_TABLE,
                message="cannot resolve target table from delivery task",
                level=ExceptionLevel.WARNING,
                context={"task_name": task_name, "slots": slots, "raw_text": raw_text},
                speak_text="无法识别送餐目标餐桌。",
            )
            return

        table = self.safe_get_table_by_nav_point(target_table)
        if table is None:
            if self.fallback_table_on_db_error:
                table = self.get_fallback_table(target_table)
                self.report_exception(
                    exception_type=ExceptionType.TABLE_NOT_FOUND,
                    message="delivery target table not found, fallback to target table",
                    level=ExceptionLevel.WARNING,
                    context={"target_table": target_table},
                )
            else:
                self.report_exception(
                    exception_type=ExceptionType.TABLE_NOT_FOUND,
                    message="delivery target table not found",
                    level=ExceptionLevel.WARNING,
                    context={"target_table": target_table},
                    speak_text=f"数据库中没有找到目标餐桌 {target_table}。",
                )
                return

        self.publish_current_table(target_table)

        published = self.create_and_publish_task(
            task_name=task_name,
            table_nav_point=target_table,
            task_type="delivery"
        )

        if published:
            self.speak(f"已创建送餐任务，目标餐桌为 {target_table}。")

    def create_and_publish_task(
        self,
        task_name: str,
        table_nav_point: str,
        task_type: str,
    ) -> bool:
        """
        创建数据库任务记录，并发布给 task_dispatcher。

        Returns:
            bool: 是否已经向 /restaurant/task_name 发布任务。
        """
        table = self.safe_get_table_by_nav_point(table_nav_point)
        if table is None:
            table = self.get_fallback_table(table_nav_point)

        db_task_created = False

        try:
            db_task_id = RobotTaskRepository.create_task(
                task_name=task_name,
                target_x=float(table.get("pos_x", 0)),
                target_y=float(table.get("pos_y", 0)),
                status="pending"
            )

            self.task_db_ids[task_name] = db_task_id
            db_task_created = True

            self.insert_log(
                "INFO",
                f"create {task_type} task: db_task_id={db_task_id}, task_name={task_name}"
            )

        except Exception as exc:
            self.report_exception(
                exception_type=ExceptionType.TASK_RECORD_CREATE_FAILED,
                message="failed to create db task record",
                level=ExceptionLevel.ERROR,
                context={
                    "task_name": task_name,
                    "table_nav_point": table_nav_point,
                    "task_type": task_type,
                },
                exc=exc,
                speak_text=(
                    "数据库任务记录创建失败，无法执行任务。"
                    if not self.allow_task_without_db
                    else None
                ),
                publish_robot_exception_state=not self.allow_task_without_db,
            )

            if not self.allow_task_without_db:
                return False

            rospy.logwarn(
                "数据库任务记录创建失败，但允许测试模式继续发布 ROS 任务: %s",
                task_name
            )

        self.publish_robot_state("DISPATCHING")
        self.task_name_pub.publish(String(data=task_name))
        rospy.loginfo("[TASK PUBLISH] %s", task_name)

        if not db_task_created:
            self.report_exception(
                exception_type=ExceptionType.TASK_RECORD_CREATE_FAILED,
                message="task published without db record",
                level=ExceptionLevel.WARNING,
                context={
                    "task_name": task_name,
                    "table_nav_point": table_nav_point,
                    "task_type": task_type,
                },
                write_db=True,
            )

        return True

    def task_status_callback(self, msg: String) -> None:
        """
        监听 task_dispatcher 的任务状态，并同步数据库任务状态。
        """
        status = (msg.data or "").strip()
        if not status:
            return

        rospy.loginfo("[TASK STATUS] %s", status)

        if status.startswith("TASK_START:"):
            task_name = status.split(":", 1)[1]
            self.update_db_task_status(task_name, "running")
            self.publish_robot_state("RUNNING")
            self.insert_log("INFO", f"task started: {task_name}")
            return

        if status.startswith("TASK_DONE:"):
            task_name = status.split(":", 1)[1]
            self.update_db_task_status(task_name, "finished")

            table_nav_point = self.task_to_table(task_name)
            if table_nav_point:
                self.publish_current_table(table_nav_point)

            self.publish_robot_state("IDLE")
            self.insert_log("INFO", f"task done: {task_name}")
            self.speak(f"任务已完成：{task_name}。")
            return

        if status.startswith("TASK_FAILED:"):
            task_name = self.extract_task_name_from_failed_status(status)
            self.update_db_task_status(task_name, "failed")
            self.report_exception(
                exception_type=ExceptionType.TASK_FAILED,
                message="task dispatcher reported task failed",
                level=ExceptionLevel.ERROR,
                context={"task_name": task_name, "status": status},
                speak_text="任务执行失败，请检查导航或目标点配置。",
                publish_robot_exception_state=True,
            )
            return

        if status.startswith("TASK_CANCELED:"):
            task_name = status.split(":", 1)[1] if ":" in status else ""
            self.update_db_task_status(task_name, "canceled")
            self.report_exception(
                exception_type=ExceptionType.TASK_CANCELED,
                message="task dispatcher reported task canceled",
                level=ExceptionLevel.WARNING,
                context={"task_name": task_name, "status": status},
                speak_text="任务已取消。",
                publish_robot_exception_state=False,
            )
            self.publish_robot_state("IDLE")
            return

        if status.startswith("TASK_BUSY:"):
            self.publish_robot_state("BUSY")
            self.report_exception(
                exception_type=ExceptionType.TASK_BUSY,
                message="task dispatcher reported busy state",
                level=ExceptionLevel.WARNING,
                context={"status": status},
                write_db=False,
            )
            return

        if status in {"TASK_IDLE", "SYSTEM_READY", "TEST_MODE"}:
            self.publish_robot_state("IDLE")
            return

        if status.startswith("WAIT_LOCALIZATION"):
            self.publish_robot_state("WAIT_LOCALIZATION")
            return

        if status.startswith("SYSTEM_HOMING"):
            self.publish_robot_state("NAVIGATING")
            return

        if status.startswith("TASK_STEP:"):
            self.publish_robot_state("RUNNING")
            return

    @staticmethod
    def extract_task_name_from_failed_status(status: str) -> str:
        """
        从 TASK_FAILED 状态中尽量提取任务名。

        支持：
        TASK_FAILED:deliver_table_1
        TASK_FAILED:deliver_table_1:EXCEPTION
        TASK_FAILED:UNKNOWN_TASK:deliver_table_1
        TASK_FAILED:EMPTY_TASK
        """
        parts = status.split(":")

        if len(parts) < 2:
            return ""

        if len(parts) >= 3 and parts[1] in {"UNKNOWN_TASK", "EMPTY_TASK"}:
            return parts[2]

        if parts[1] == "EMPTY_TASK":
            return ""

        return parts[1]

    def update_db_task_status(self, task_name: str, status: str) -> None:
        """
        根据 task_name 更新数据库任务状态。
        """
        if not task_name:
            return

        task_id = self.task_db_ids.get(task_name)
        if task_id is None:
            return

        try:
            RobotTaskRepository.update_task_status(task_id, status)
        except Exception as exc:
            self.report_exception(
                exception_type=ExceptionType.TASK_STATUS_UPDATE_FAILED,
                message="failed to update db task status",
                level=ExceptionLevel.ERROR,
                context={
                    "task_id": task_id,
                    "task_name": task_name,
                    "status": status,
                },
                exc=exc,
            )

    def select_available_table(self, customer_count: int) -> Optional[Dict[str, Any]]:
        """
        选择一张可用餐桌。

        策略：
        1. status 为 available；
        2. capacity 大于等于顾客人数；
        3. 容量最小优先，避免浪费大桌；
        4. 数据库异常时返回 None，由上层决定是否回退。
        """
        try:
            tables = RestaurantTableRepository.get_all_tables()
        except Exception as exc:
            self.report_exception(
                exception_type=ExceptionType.DATABASE_QUERY_FAILED,
                message="failed to query all tables",
                level=ExceptionLevel.ERROR,
                context={"customer_count": customer_count},
                exc=exc,
            )
            return None

        candidates = []

        for table in tables:
            status = str(table.get("status", "")).lower()
            capacity = int(table.get("capacity", 0))

            if status == "available" and capacity >= customer_count:
                candidates.append(table)

        if not candidates:
            return None

        candidates.sort(
            key=lambda item: (
                int(item.get("capacity", 0)),
                str(item.get("nav_point_name", ""))
            )
        )

        return candidates[0]

    def extract_customer_count(self, slots: Dict[str, Any], raw_text: str) -> int:
        """
        从语音 slots 或原始文本中提取顾客人数。
        """
        for key in ["customer_count", "people_count", "count"]:
            value = slots.get(key)
            if value is not None:
                try:
                    count = int(value)
                    return max(1, count)
                except Exception:
                    pass

        text = raw_text or ""

        mapping = {
            "一": 1,
            "二": 2,
            "两": 2,
            "三": 3,
            "四": 4,
            "五": 5,
            "六": 6,
            "七": 7,
            "八": 8,
            "九": 9,
            "十": 10,
        }

        m = re.search(r"(\d+|一|二|两|三|四|五|六|七|八|九|十)\s*(个人|人|位)", text)
        if m:
            value = m.group(1)
            if value in mapping:
                return mapping[value]
            return max(1, int(value))

        m = re.search(r"(\d+|一|二|两|三|四|五|六|七|八|九|十)\s*人桌", text)
        if m:
            value = m.group(1)
            if value in mapping:
                return mapping[value]
            return max(1, int(value))

        return self.default_customer_count

    @staticmethod
    def table_to_task(table_nav_point: str, prefix: str) -> str:
        """
        table_1 -> guide_table_1 / deliver_table_1
        """
        if not table_nav_point:
            return ""

        if not table_nav_point.startswith("table_"):
            return ""

        suffix = table_nav_point.replace("table_", "")
        return f"{prefix}_table_{suffix}"

    @staticmethod
    def task_to_table(task_name: str) -> str:
        """
        guide_table_1 / deliver_table_1 -> table_1。
        """
        if not task_name:
            return ""

        m = re.search(r"(?:guide|deliver)_table_([1-9]\d*)", task_name)
        if not m:
            return ""

        return f"table_{m.group(1)}"


def main():
    RobotController()
    rospy.spin()


if __name__ == "__main__":
    main()
