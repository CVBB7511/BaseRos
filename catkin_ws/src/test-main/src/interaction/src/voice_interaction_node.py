#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
ROS 1 Noetic 餐厅语音交互节点。

功能：
1. 订阅 /speech_text，接收语音识别文本。
2. 从数据库读取菜单。
3. 支持顾客语音下单、加菜、修改数量、修改备注、删除菜品。
4. 确认下单后写入数据库 order_info / order_item。
5. 支持语音查询账单。
6. 支持语音结账，写入 payment_record。
7. 输出 /voice_cmd、/order_summary、/tts_speak、/voice_state。
8. 订阅 /restaurant/task_status，用于判断机器人当前是否处于导航或任务执行状态。

当前架构说明：
1. 本节点负责语音解析、点餐流程和语音播报。
2. 本节点不直接发布 /restaurant/task_name，不直接控制导航。
3. 迎宾带位和送餐指令统一通过 /voice_cmd 发送给 robot_controller。
4. robot_controller 负责创建 guide_table_x / deliver_table_x 任务。
5. task_dispatcher 负责任务路径拆解，navigation_manager 负责导航执行或 mock_navigation 模拟到达。
"""

import json
import re
import threading
from dataclasses import dataclass
from decimal import Decimal
from pathlib import Path
from typing import Optional

import rospy
import yaml
from std_msgs.msg import String

from database_order_adapter import DatabaseError, DatabaseOrderAdapter
from order_manager import OrderManager


@dataclass
class ParsedCommand:
    """语音解析结果。"""

    intent: str
    item_name: str = ""
    quantity: int = 0
    note: str = ""
    table_nav_point: str = ""
    customer_count: int = 0
    raw_text: str = ""


class VoiceInteractionNode:
    """语音交互节点。"""

    def __init__(self):
        rospy.init_node("voice_interaction_node", anonymous=False)

        self.database_config_file = Path(
            rospy.get_param("~database_config_file", "config/database_config.yaml")
        )
        self.alias_file = Path(
            rospy.get_param("~alias_file", "config/menu_aliases.yaml")
        )
        self.runtime_file = Path(
            rospy.get_param("~runtime_file", "config/runtime.yaml")
        )

        self.current_table = rospy.get_param("~default_table", "table_1")
        self.auto_start_session = self._to_bool(
            rospy.get_param("~auto_start_session", True)
        )
        self.default_customer_count = int(
            rospy.get_param("~default_customer_count", 1)
        )
        self.default_payment_method = rospy.get_param(
            "~default_payment_method", "wechat"
        )
        self.default_discount_amount = Decimal(
            str(rospy.get_param("~default_discount_amount", 0))
        )
        self.allow_keyboard_input = self._to_bool(
            rospy.get_param("~allow_keyboard_input", True)
        )

        self.runtime = self._load_yaml(self.runtime_file, default={})
        alias_data = self._load_yaml(self.alias_file, default={"aliases": {}})

        self.database_adapter = DatabaseOrderAdapter(str(self.database_config_file))
        self.database_adapter.health_check()
        self.order_manager = OrderManager(self.database_adapter, alias_data=alias_data)

        self.current_session_id = None
        self.last_order_id = None
        self.last_robot_state = ""
        self.retry_count = 0
        self.retry_limit = int(self._rt("params.retry_limit", 2))
        self.state_lock = threading.Lock()

        self.busy_mode_states = {
            "BUSY",
            "RUNNING",
            "NAVIGATING",
            "DELIVERING",
            "GUIDING",
            "DISPATCHING",
            "TASK_RUNNING",
        }

        self.ask_again_phrase = self._rt("phrases.ask_again", "没有听清，请再说一次。")
        self.busy_phrase = self._rt("phrases.busy", "当前任务进行中，请稍后再试。")
        self.greeting_phrase = self._rt("phrases.greeting", "您好，欢迎光临，请问需要带位还是点餐？")
        self.menu_intro = self._rt("phrases.menu_intro", "当前可售菜单如下：")
        self.confirm_ask = self._rt("phrases.confirm_ask", "请确认下单，回复确认下单或取消订单。")
        self.confirmed_phrase = self._rt("phrases.confirmed", "订单已确认，已写入数据库。")
        self.cancelled_phrase = self._rt("phrases.cancelled", "订单已取消。")

        self.voice_cmd_pub = rospy.Publisher("/voice_cmd", String, queue_size=10)
        self.order_summary_pub = rospy.Publisher("/order_summary", String, queue_size=10)
        self.tts_pub = rospy.Publisher("/tts_speak", String, queue_size=10)
        self.state_pub = rospy.Publisher("/voice_state", String, queue_size=10)
        self.seat_pub = rospy.Publisher("/seat_request", String, queue_size=10)
        self.queue_pub = rospy.Publisher("/queue_request", String, queue_size=10)

        # Deprecated:
        # 语音模块不再直接向 /restaurant/task_name 发布任务。
        # 后续由 src/core/robot_controller.py 订阅 /voice_cmd 后统一创建任务。
        # 当前先保留 publisher 定义，避免旧代码或 launch 文件引用时报错。
        self.restaurant_task_pub = rospy.Publisher(
            "/restaurant/task_name",
            String,
            queue_size=10
        )

        rospy.Subscriber("/speech_text", String, self._speech_callback)

        # 兼容旧接口：如果后续仍有模块发布 /robot_state，语音模块仍可接收。
        rospy.Subscriber("/robot_state", String, self._robot_state_callback)

        # 统一接口：任务调度模块发布的任务状态。
        # 语音模块主要根据该话题判断机器人是否忙碌。
        rospy.Subscriber("/restaurant/task_status", String, self._robot_state_callback)

        rospy.Subscriber("/restaurant/current_table", String, self._current_table_callback)

        self._publish_state(self._rt("state.idle", "IDLE"))
        self._speak(f"{self.greeting_phrase} 当前桌位为 {self.current_table}。")

        if self.allow_keyboard_input:
            threading.Thread(target=self._keyboard_loop, daemon=True).start()

        rospy.loginfo("voice_interaction_node database-connected version started.")

    def publish_voice_cmd(self, intent, slots=None, raw_text=""):
        """
        发布统一格式的语音指令。

                Args:
            intent: 指令意图，例如 seat_request、switch_order_mode、switch_delivery_mode、cancel_task
            slots: 指令参数，例如 table_nav_point、target_table、task_name、dish_name、count
            raw_text: 原始语音文本
        """
        if slots is None:
            slots = {}

        cmd = {
            "source": "voice",
            "intent": intent,
            "slots": slots,
            "raw_text": raw_text,
            "timestamp": rospy.Time.now().to_sec()
        }

        self.voice_cmd_pub.publish(
            String(data=json.dumps(cmd, ensure_ascii=False, default=str))
        )

        rospy.loginfo("Published voice command: %s", cmd)

    def _to_bool(self, value) -> bool:
        if isinstance(value, bool):
            return value
        return str(value).strip().lower() in {"true", "1", "yes", "y", "on"}

    def _load_yaml(self, path: Path, default):
        try:
            if path.exists():
                with path.open("r", encoding="utf-8") as f:
                    return yaml.safe_load(f) or default
        except Exception as exc:
            rospy.logwarn(f"Failed to load YAML {path}: {exc}")
        return default

    def _rt(self, dotted_key: str, default=None):
        cur = self.runtime
        for part in dotted_key.split("."):
            if not isinstance(cur, dict) or part not in cur:
                return default
            cur = cur[part]
        return cur

    def _publish_state(self, new_state: str):
        self.state_pub.publish(String(data=new_state))
        rospy.loginfo(f"[VOICE STATE] -> {new_state}")

    def _speak(self, text: str):
        self.tts_pub.publish(String(data=text))
        rospy.loginfo(f"[TTS] {text}")

    def _publish_cmd(self, intent: str, extra: dict = None):
        payload = {
            "intent": intent,
            "source": "voice",
            "table_nav_point": self.current_table,
            "session_id": self.current_session_id,
        }
        if extra:
            payload.update(extra)

        msg = json.dumps(payload, ensure_ascii=False, default=str)
        self.voice_cmd_pub.publish(String(data=msg))
        rospy.loginfo(f"[VOICE CMD] {msg}")

    def _publish_summary(self, summary: str):
        self.order_summary_pub.publish(String(data=summary))
        rospy.loginfo(f"[SUMMARY] {summary}")

    def _robot_state_callback(self, msg: String):
        """
        接收机器人或任务状态。

        兼容两类状态来源：
        1. /robot_state
        2. /restaurant/task_status

        状态字符串可能是 BUSY、NAVIGATING、FINISHED，
        也可能是 task_dispatcher 发布的更复杂文本。
        因此这里只做统一大写和去空格处理，具体忙碌判断交给 _robot_is_busy。
        """
        self.last_robot_state = (msg.data or "").strip().upper()
        rospy.loginfo(f"[ROBOT/TASK STATE] {self.last_robot_state}")

    def _current_table_callback(self, msg: String):
        table_name = msg.data.strip()
        if table_name:
            self._set_current_table(table_name, speak=False)

    def _speech_callback(self, msg: String):
        self.handle_text(msg.data)

    def _keyboard_loop(self):
        while not rospy.is_shutdown():
            try:
                text = input("请输入模拟语音指令：").strip()
                if text:
                    self.handle_text(text)
            except EOFError:
                break
            except Exception as exc:
                rospy.logwarn(f"keyboard input error: {exc}")

    def handle_text(self, text: str):
        text = (text or "").strip()

        if not text:
            self._handle_empty_input()
            return

        normalized = self._normalize(text)
        rospy.loginfo(f"Received: {text} | normalized: {normalized}")

        if self._robot_is_busy() and not self._is_recoverable_command(normalized):
            self._speak(self.busy_phrase)
            self._publish_cmd("busy")
            return

        parsed = self._parse_intent(normalized, raw_text=text)

        try:
            self._dispatch(parsed)
        except DatabaseError as exc:
            rospy.logerr(f"database error: {exc}")
            self._publish_state("EXCEPTION")
            self._publish_cmd("database_error", {"message": str(exc)})
            self._speak(f"数据库操作失败，原因是：{exc}")
        except Exception as exc:
            rospy.logerr(f"voice dispatch error: {exc}")
            self._publish_state("EXCEPTION")
            self._publish_cmd("system_error", {"message": str(exc)})
            self._speak("系统处理失败，请稍后重试。")

    def _handle_empty_input(self):
        with self.state_lock:
            self.retry_count += 1
            self._publish_state("EXCEPTION")
            if self.retry_count <= self.retry_limit:
                self._publish_cmd("repeat")
                self._speak(self.ask_again_phrase)
            else:
                self.retry_count = 0
                self._publish_cmd("fallback_to_button")
                self._speak("已切换到按钮输入。")

    def _normalize(self, text: str) -> str:
        text = text.lower()
        text = re.sub(r"\s+", "", text)
        text = text.replace("份儿", "份")
        text = text.replace("臺", "台")
        return text

    def _robot_is_busy(self) -> bool:
        """
        判断机器人当前是否忙碌。

        这里不用严格等值判断，而是采用包含判断，
        以兼容 RUNNING:guide_table_1、NAVIGATING_TO_TABLE_1 等状态格式。
        """
        state = self.last_robot_state or ""

        if not state:
            return False

        for busy_state in self.busy_mode_states:
            if busy_state in state:
                return True

        return False

    def _is_recoverable_command(self, text: str) -> bool:
        return any(k in text for k in ["取消", "重试", "再来一次", "返回", "停止", "接管", "确认", "结账"])

    def _parse_intent(self, text: str, raw_text: str = "") -> ParsedCommand:
        """
        解析语音文本意图。

        解析顺序很重要：
        1. 先解析明确的模式切换和任务类指令；
        2. 再解析迎宾带位；
        3. 再解析问候、菜单、订单等普通点餐指令；
        4. 最后解析菜品增删改。

        注意：
        “开始送餐” 中包含“开始”，不能先被识别成 greet。
        """
        table_nav_point = self._extract_table_nav_point(text)

        if table_nav_point and any(k in text for k in ["我是", "当前", "切换", "换到", "桌"]):
            return ParsedCommand(
                intent="set_table",
                table_nav_point=table_nav_point,
                raw_text=raw_text,
            )

        if "切换到点餐模式" in text or "点餐模式" in text:
            return ParsedCommand(intent="switch_order_mode", raw_text=raw_text)

        if "开始送餐" in text or "送餐模式" in text or "切换到送餐模式" in text:
            return ParsedCommand(intent="switch_delivery_mode", raw_text=raw_text)

        customer_count = self._extract_customer_count(text)
        seat_keywords = [
            "带位",
            "座位",
            "找个位置",
            "找一个位置",
            "安排位置",
            "安排座位",
            "安排餐桌",
            "我要入座",
            "我要坐",
            "请带我",
            "餐桌",
            "靠窗",
            "坐窗边",
            "安静一点",
            "大厅位置",
            "人桌",
        ]

        if customer_count > 0 or any(k in text for k in seat_keywords):
            return ParsedCommand(
                intent="seat_request",
                customer_count=customer_count,
                raw_text=raw_text,
            )

        if any(k in text for k in ["你好机器人", "小机器人", "唤醒", "hello", "开始服务"]):
            return ParsedCommand(intent="greet", raw_text=raw_text)

        if any(k in text for k in ["菜单", "看看菜单", "推荐一下", "有什么菜"]):
            return ParsedCommand(intent="show_menu", raw_text=raw_text)

        if any(k in text for k in ["确认下单", "提交订单", "确认订单"]):
            return ParsedCommand(intent="confirm_order", raw_text=raw_text)

        if any(k in text for k in ["取消订单", "整单取消", "不要这个订单"]):
            return ParsedCommand(intent="cancel_order", raw_text=raw_text)

        if any(k in text for k in ["账单", "多少钱", "算一下", "合计", "总价"]):
            return ParsedCommand(intent="calculate_bill", raw_text=raw_text)

        if any(k in text for k in ["结账", "买单", "付款", "确认支付"]):
            return ParsedCommand(intent="checkout", raw_text=raw_text)

        if any(k in text for k in ["等位", "排队", "需要等待吗"]):
            return ParsedCommand(intent="queue_request", raw_text=raw_text)

        m_del = re.search(r"(删掉|删除|去掉|不要)(.+)", text)
        if m_del:
            item_name = self._strip_noise_tokens(m_del.group(2))
            return ParsedCommand(
                intent="remove_item",
                item_name=item_name,
                raw_text=raw_text,
            )

        m_note = re.search(
            r"(.+?)(?:备注改成|备注改为|改成|改为)(少辣|微辣|中辣|不要葱|不要香菜|不要辣|加辣|打包|堂食)",
            text
        )
        if m_note:
            return ParsedCommand(
                intent="update_note",
                item_name=self._strip_noise_tokens(m_note.group(1)),
                note=m_note.group(2),
                raw_text=raw_text,
            )

        m_mod = re.search(r"(.+?)(?:改成|改为|变成)(\d+|一|二|两|三|四|五|六|七|八|九|十)份?", text)
        if m_mod:
            return ParsedCommand(
                intent="update_item",
                item_name=self._strip_noise_tokens(m_mod.group(1)),
                quantity=self._parse_quantity(m_mod.group(2)),
                raw_text=raw_text,
            )

        m = re.search(r"(.+?)(\d+|一|二|两|三|四|五|六|七|八|九|十)份?(.*)", text)
        if m:
            return ParsedCommand(
                intent="add_item",
                item_name=self._strip_noise_tokens(m.group(1)),
                quantity=self._parse_quantity(m.group(2)),
                note=self._extract_note(m.group(3)),
                raw_text=raw_text,
            )

        matched = self._match_menu_item(text)
        if matched:
            return ParsedCommand(
                intent="quantity_missing",
                item_name=matched,
                raw_text=raw_text,
            )

        return ParsedCommand(intent="unknown", raw_text=raw_text)

    def _parse_quantity(self, raw: str) -> int:
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
        if raw in mapping:
            return mapping[raw]
        return int(raw)

    def _extract_customer_count(self, text: str) -> int:
        """
        从语音文本中提取顾客人数。

        支持示例：
        1. 我们两个人
        2. 我要三人桌
        3. 四位
        4. 2个人
        """
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

        return 0

    def _extract_table_nav_point(self, text: str) -> str:
        m = re.search(r"(table_[1-4])", text)
        if m:
            return m.group(1)

        mapping = {
            "一": "table_1",
            "1": "table_1",
            "二": "table_2",
            "两": "table_2",
            "2": "table_2",
            "三": "table_3",
            "3": "table_3",
            "四": "table_4",
            "4": "table_4",
        }

        m = re.search(r"([一二两三四1234])号?桌", text)
        if m:
            return mapping.get(m.group(1), "")

        return ""

    def _strip_noise_tokens(self, text: str) -> str:
        for token in ["帮我", "我要", "来", "点", "一个", "一份", "份", "请", "把", "再来", "麻烦", "的"]:
            text = text.replace(token, "")
        return self._match_menu_item(text) or text

    def _extract_note(self, text: str) -> str:
        notes = []
        for kw in ["少辣", "微辣", "中辣", "不要葱", "不要香菜", "不要辣", "加辣", "打包", "堂食"]:
            if kw in text:
                notes.append(kw)
        return "、".join(notes)

    def _match_menu_item(self, text: str) -> Optional[str]:
        for item in self.order_manager.get_menu_items():
            candidates = [item["name"]] + item.get("aliases", [])
            for cand in candidates:
                if cand and cand.replace(" ", "") in text:
                    return item["name"]
        return None

    def _set_current_table(self, table_nav_point: str, speak: bool = True):
        table = self.database_adapter.get_table_by_nav_point(table_nav_point)
        if table is None:
            raise DatabaseError(f"数据库中没有该桌位: {table_nav_point}")

        self.current_table = table_nav_point
        session = self.database_adapter.get_active_session_by_table_nav_point(table_nav_point)
        self.current_session_id = session["id"] if session else None

        self._publish_cmd(
            "set_table",
            {
                "table_nav_point": table_nav_point,
                "session_id": self.current_session_id,
            },
        )

        if speak:
            self._speak(f"已切换到 {table_nav_point}。")

    def _ensure_session(self, auto_create: Optional[bool] = None) -> dict:
        if auto_create is None:
            auto_create = self.auto_start_session

        session = self.database_adapter.get_or_create_session(
            self.current_table,
            customer_count=self.default_customer_count,
            auto_create=auto_create,
        )
        self.current_session_id = session["id"]
        return session

    def _dispatch(self, cmd: ParsedCommand):
        if cmd.intent == "greet":
            self.retry_count = 0
            self._publish_cmd("greeting")
            self._publish_state(self._rt("state.greeting", "GREETING"))
            self._speak(f"{self.greeting_phrase} 当前桌位为 {self.current_table}。")
            return

        if cmd.intent == "set_table":
            self._set_current_table(cmd.table_nav_point, speak=True)
            return

        if cmd.intent == "show_menu":
            self.retry_count = 0
            self._publish_cmd("show_menu")
            self._publish_state(self._rt("state.ordering", "ORDERING"))
            menu_text = self.order_manager.format_menu_text()
            self._speak(f"{self.menu_intro}{menu_text}")
            self._publish_summary(menu_text)
            return

        if cmd.intent == "add_item":
            self.retry_count = 0
            result = self.order_manager.add_item(cmd.item_name, cmd.quantity, cmd.note)
            if not result["ok"]:
                self._publish_cmd("add_item_failed", {"item_name": cmd.item_name})
                self._speak(result["message"])
                return

            item = result.get("item", {})
            self._publish_cmd(
                "add_item",
                {
                    "item_id": item.get("item_id"),
                    "item_name": item.get("name"),
                    "quantity": cmd.quantity,
                    "note": cmd.note,
                },
            )
            self._publish_state(self._rt("state.ordering", "ORDERING"))
            summary = self.order_manager.format_order_summary()
            self._publish_summary(summary)
            self._speak(result["message"] + summary + self.confirm_ask)
            return

        if cmd.intent == "update_item":
            self.retry_count = 0

            if self.order_manager.has_items():
                result = self.order_manager.update_item(cmd.item_name, cmd.quantity)
                if not result["ok"]:
                    self._speak(result["message"])
                    return
                self._publish_cmd(
                    "update_item",
                    {
                        "item_name": cmd.item_name,
                        "quantity": cmd.quantity,
                        "target": "temp_order",
                    },
                )
                summary = self.order_manager.format_order_summary()
                self._publish_summary(summary)
                self._speak(result["message"] + summary)
                return

            session = self._ensure_session(auto_create=False)
            self.database_adapter.update_item_quantity_by_name(
                session_id=session["id"],
                item_name=cmd.item_name,
                quantity=cmd.quantity,
            )
            self._publish_cmd(
                "update_item",
                {
                    "item_name": cmd.item_name,
                    "quantity": cmd.quantity,
                    "target": "database_order",
                },
            )
            self._speak(f"已将 {cmd.item_name} 修改为 {cmd.quantity} 份。")
            return

        if cmd.intent == "update_note":
            self.retry_count = 0

            if self.order_manager.has_items():
                result = self.order_manager.update_item_note(cmd.item_name, cmd.note)
                if not result["ok"]:
                    self._speak(result["message"])
                    return
                self._publish_cmd(
                    "update_note",
                    {
                        "item_name": cmd.item_name,
                        "note": cmd.note,
                        "target": "temp_order",
                    },
                )
                summary = self.order_manager.format_order_summary()
                self._publish_summary(summary)
                self._speak(result["message"] + summary)
                return

            session = self._ensure_session(auto_create=False)
            self.database_adapter.update_item_remark_by_name(
                session_id=session["id"],
                item_name=cmd.item_name,
                remark=cmd.note,
            )
            self._publish_cmd(
                "update_note",
                {
                    "item_name": cmd.item_name,
                    "note": cmd.note,
                    "target": "database_order",
                },
            )
            self._speak(f"已将 {cmd.item_name} 备注改为 {cmd.note}。")
            return

        if cmd.intent == "remove_item":
            self.retry_count = 0

            if self.order_manager.has_items():
                result = self.order_manager.remove_item(cmd.item_name)
                if not result["ok"]:
                    self._speak(result["message"])
                    return
                self._publish_cmd(
                    "remove_item",
                    {
                        "item_name": cmd.item_name,
                        "target": "temp_order",
                    },
                )
                summary = self.order_manager.format_order_summary()
                self._publish_summary(summary)
                self._speak(result["message"] + summary)
                return

            session = self._ensure_session(auto_create=False)
            self.database_adapter.remove_item_by_name(
                session_id=session["id"],
                item_name=cmd.item_name,
            )
            self._publish_cmd(
                "remove_item",
                {
                    "item_name": cmd.item_name,
                    "target": "database_order",
                },
            )
            self._speak(f"已从当前订单中删除 {cmd.item_name}。")
            return

        if cmd.intent == "confirm_order":
            self.retry_count = 0
            if not self.order_manager.has_items():
                self._speak("当前没有待确认的菜品。")
                self._publish_cmd("confirm_order_empty")
                return

            session = self._ensure_session()
            items = self.order_manager.get_temp_order_items()
            order_id = self.database_adapter.create_order(session["id"], items)

            self.current_session_id = session["id"]
            self.last_order_id = order_id
            self.order_manager.clear_temp_order()

            self._publish_cmd(
                "confirm_order",
                {
                    "order_id": order_id,
                    "items": items,
                },
            )
            self._publish_state("FINISHED")
            self._speak(f"{self.confirmed_phrase} 订单编号为 {order_id}。")
            self._publish_summary(f"订单已写入数据库，order_id={order_id}")
            return

        if cmd.intent == "cancel_order":
            self.retry_count = 0

            if self.order_manager.has_items():
                self.order_manager.clear_temp_order()
                self._publish_cmd("cancel_temp_order")
                self._publish_state(self._rt("state.idle", "IDLE"))
                self._speak(self.cancelled_phrase)
                self._publish_summary("临时订单已取消。")
                return

            session = self._ensure_session(auto_create=False)
            order_id = self.database_adapter.cancel_latest_order(session["id"])

            if order_id is None:
                self._speak("当前没有可取消的订单。")
                return

            self._publish_cmd("cancel_order", {"order_id": order_id})
            self._speak(f"已取消最近一笔订单，订单编号 {order_id}。")
            return

        if cmd.intent == "calculate_bill":
            session = self._ensure_session(auto_create=False)
            bill = self.database_adapter.calculate_bill(
                session["id"],
                discount_amount=self.default_discount_amount,
            )
            text = (
                f"当前账单总额 {bill['total_amount']} 元，"
                f"优惠 {bill['discount_amount']} 元，"
                f"应付 {bill['final_amount']} 元。"
            )
            self._publish_cmd("calculate_bill", {"bill": bill})
            self._publish_summary(text)
            self._speak(text)
            return

        if cmd.intent == "checkout":
            session = self._ensure_session(auto_create=False)
            bill = self.database_adapter.calculate_bill(
                session["id"],
                discount_amount=self.default_discount_amount,
            )
            payment_id = self.database_adapter.create_payment(
                session_id=session["id"],
                payment_method=self.default_payment_method,
                discount_amount=self.default_discount_amount,
            )
            self._publish_cmd(
                "checkout",
                {
                    "payment_id": payment_id,
                    "bill": bill,
                    "payment_method": self.default_payment_method,
                },
            )
            self._publish_state("FINISHED")
            self._speak(
                f"结账完成，应付 {bill['final_amount']} 元，支付记录编号 {payment_id}。"
            )
            self.current_session_id = None
            self.last_order_id = None
            return

        if cmd.intent == "switch_order_mode":
            self._publish_cmd("switch_order_mode")
            self._publish_state(self._rt("state.ordering", "ORDERING"))
            self._speak("已切换到点餐模式。")
            return

        if cmd.intent == "switch_delivery_mode":
            if not self.current_table:
                self.publish_voice_cmd(
                    intent="switch_delivery_mode",
                    slots={
                        "error": "no_current_table"
                    },
                    raw_text=getattr(cmd, "raw_text", "")
                )
                self._speak("当前还没有确定目标餐桌，无法开始送餐。")
                return

            task_name = self.current_table.replace("table_", "deliver_table_")

            self.publish_voice_cmd(
                intent="switch_delivery_mode",
                slots={
                    "task_name": task_name,
                    "target_table": self.current_table
                },
                raw_text=getattr(cmd, "raw_text", "")
            )

            self._speak(f"已接收送餐指令，准备创建送餐任务：{task_name}。")
            return

        if cmd.intent == "seat_request":
            customer_count = cmd.customer_count or self.default_customer_count

            payload = {
                "intent": "seat_request",
                "raw_text": cmd.raw_text,
                "table_nav_point": self.current_table,
                "customer_count": customer_count,
            }

            self.seat_pub.publish(String(data=json.dumps(payload, ensure_ascii=False)))
            self._publish_cmd("seat_request", payload)
            self._publish_state(self._rt("state.seat_request", "SEAT_REQUEST"))
            self._speak(f"已收到您的座位需求，将为 {customer_count} 位顾客安排餐桌。")
            return

        if cmd.intent == "queue_request":
            payload = {
                "intent": "queue_request",
                "raw_text": cmd.raw_text,
                "table_nav_point": self.current_table,
            }
            self.queue_pub.publish(String(data=json.dumps(payload, ensure_ascii=False)))
            self._publish_cmd("queue_request", payload)
            self._publish_state(self._rt("state.waiting", "WAITING"))
            self._speak("已收到等位请求。")
            return

        if cmd.intent == "quantity_missing":
            self._publish_cmd("quantity_missing", {"item_name": cmd.item_name})
            self._speak(f"{cmd.item_name} 要几份？")
            return

        self.retry_count += 1
        self._publish_state("EXCEPTION")
        self._publish_cmd("unknown", {"raw_text": cmd.raw_text})
        self._speak(self.ask_again_phrase)


def main():
    VoiceInteractionNode()
    rospy.spin()


if __name__ == "__main__":
    main()
