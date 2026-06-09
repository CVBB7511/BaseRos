"""
餐厅系统统一接口命名常量。

用途：
1. 统一数据库模块、主控模块、任务调度模块和导航管理模块中的导航点名称。
2. 统一上层业务任务名。
3. 统一 ROS 话题名称。
4. 避免 table_1 / T01 等命名混用。
5. 支持当前主控集中调度架构下的模块协作。

当前架构：
1. voice_interaction_node 负责语音解析、点餐流程和语音输出；
2. robot_controller 负责接收 /voice_cmd，创建迎宾带位和送餐任务；
3. task_dispatcher 负责将业务任务拆解为导航点序列；
4. navigation_manager 负责真实导航或 mock_navigation 模拟导航；
5. database 模块负责餐桌、任务、日志、订单和支付等数据记录。

命名来源：
导航定位模块接口说明中定义的导航点与任务名。
"""

# =========================
# ROS 话题名称
# =========================

TOPIC_SPEECH_TEXT = "/speech_text"
TOPIC_VOICE_CMD = "/voice_cmd"
TOPIC_TTS_SPEAK = "/tts_speak"
TOPIC_VOICE_STATE = "/voice_state"
TOPIC_ORDER_SUMMARY = "/order_summary"

TOPIC_RESTAURANT_TASK_NAME = "/restaurant/task_name"
TOPIC_RESTAURANT_TASK_CANCEL = "/restaurant/task_cancel"
TOPIC_RESTAURANT_TASK_STATUS = "/restaurant/task_status"
TOPIC_RESTAURANT_CURRENT_TABLE = "/restaurant/current_table"

TOPIC_RESTAURANT_NAV_TARGET = "/restaurant/nav_target"
TOPIC_RESTAURANT_NAV_CANCEL = "/restaurant/nav_cancel"
TOPIC_RESTAURANT_NAV_STATUS = "/restaurant/nav_status"
TOPIC_RESTAURANT_LOCALIZATION_READY = "/restaurant/localization_ready"

TOPIC_ROBOT_STATE = "/robot_state"

# =========================
# 导航点名称
# =========================

NAV_ENTRANCE = "entrance"
NAV_WAIT_AREA = "wait_area"
NAV_KITCHEN = "kitchen"
NAV_TABLE_1 = "table_1"
NAV_TABLE_2 = "table_2"
NAV_TABLE_3 = "table_3"
NAV_TABLE_4 = "table_4"
NAV_AISLE_MID_1 = "aisle_mid_1"

TABLE_NAV_POINTS = [
    NAV_TABLE_1,
    NAV_TABLE_2,
    NAV_TABLE_3,
    NAV_TABLE_4,
]

# =========================
# 单点任务名
# =========================

TASK_GO_ENTRANCE = "go_entrance"
TASK_GO_WAIT_AREA = "go_wait_area"
TASK_GO_KITCHEN = "go_kitchen"
TASK_GO_TABLE_1 = "go_table_1"
TASK_GO_TABLE_2 = "go_table_2"
TASK_GO_TABLE_3 = "go_table_3"
TASK_GO_TABLE_4 = "go_table_4"

POINT_TASKS = [
    TASK_GO_ENTRANCE,
    TASK_GO_WAIT_AREA,
    TASK_GO_KITCHEN,
    TASK_GO_TABLE_1,
    TASK_GO_TABLE_2,
    TASK_GO_TABLE_3,
    TASK_GO_TABLE_4,
]

# =========================
# 迎宾带位任务名
# =========================

TASK_GUIDE_TABLE_1 = "guide_table_1"
TASK_GUIDE_TABLE_2 = "guide_table_2"
TASK_GUIDE_TABLE_3 = "guide_table_3"
TASK_GUIDE_TABLE_4 = "guide_table_4"

GUIDE_TASKS = [
    TASK_GUIDE_TABLE_1,
    TASK_GUIDE_TABLE_2,
    TASK_GUIDE_TABLE_3,
    TASK_GUIDE_TABLE_4,
]

# =========================
# 送餐任务名
# =========================

TASK_DELIVER_TABLE_1 = "deliver_table_1"
TASK_DELIVER_TABLE_2 = "deliver_table_2"
TASK_DELIVER_TABLE_3 = "deliver_table_3"
TASK_DELIVER_TABLE_4 = "deliver_table_4"

DELIVERY_TASKS = [
    TASK_DELIVER_TABLE_1,
    TASK_DELIVER_TABLE_2,
    TASK_DELIVER_TABLE_3,
    TASK_DELIVER_TABLE_4,
]

# =========================
# 任务名到餐桌导航点的映射
# =========================

GUIDE_TASK_TO_TABLE = {
    TASK_GUIDE_TABLE_1: NAV_TABLE_1,
    TASK_GUIDE_TABLE_2: NAV_TABLE_2,
    TASK_GUIDE_TABLE_3: NAV_TABLE_3,
    TASK_GUIDE_TABLE_4: NAV_TABLE_4,
}

DELIVERY_TASK_TO_TABLE = {
    TASK_DELIVER_TABLE_1: NAV_TABLE_1,
    TASK_DELIVER_TABLE_2: NAV_TABLE_2,
    TASK_DELIVER_TABLE_3: NAV_TABLE_3,
    TASK_DELIVER_TABLE_4: NAV_TABLE_4,
}

TASK_TO_TABLE = {}
TASK_TO_TABLE.update(GUIDE_TASK_TO_TABLE)
TASK_TO_TABLE.update(DELIVERY_TASK_TO_TABLE)

# =========================
# 餐桌导航点到任务名的映射
# =========================

TABLE_TO_GUIDE_TASK = {
    NAV_TABLE_1: TASK_GUIDE_TABLE_1,
    NAV_TABLE_2: TASK_GUIDE_TABLE_2,
    NAV_TABLE_3: TASK_GUIDE_TABLE_3,
    NAV_TABLE_4: TASK_GUIDE_TABLE_4,
}

TABLE_TO_DELIVERY_TASK = {
    NAV_TABLE_1: TASK_DELIVER_TABLE_1,
    NAV_TABLE_2: TASK_DELIVER_TABLE_2,
    NAV_TABLE_3: TASK_DELIVER_TABLE_3,
    NAV_TABLE_4: TASK_DELIVER_TABLE_4,
}

# =========================
# 任务状态名称
# =========================

TASK_STATUS_IDLE = "TASK_IDLE"
TASK_STATUS_START_PREFIX = "TASK_START"
TASK_STATUS_STEP_PREFIX = "TASK_STEP"
TASK_STATUS_DONE_PREFIX = "TASK_DONE"
TASK_STATUS_FAILED_PREFIX = "TASK_FAILED"
TASK_STATUS_CANCELED_PREFIX = "TASK_CANCELED"
TASK_STATUS_BUSY_PREFIX = "TASK_BUSY"

# =========================
# 机器人状态名称
# =========================

ROBOT_STATE_IDLE = "IDLE"
ROBOT_STATE_RUNNING = "RUNNING"
ROBOT_STATE_BUSY = "BUSY"
ROBOT_STATE_DISPATCHING = "DISPATCHING"
ROBOT_STATE_NAVIGATING = "NAVIGATING"
ROBOT_STATE_ORDERING = "ORDERING"
ROBOT_STATE_EXCEPTION = "EXCEPTION"
ROBOT_STATE_WAIT_LOCALIZATION = "WAIT_LOCALIZATION"