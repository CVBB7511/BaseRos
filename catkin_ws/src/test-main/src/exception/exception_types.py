#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
餐厅服务机器人异常类型定义。

该文件不直接处理异常，只统一定义异常分类、严重级别和来源模块名称，
便于 robot_controller、task_dispatcher、navigation_manager 等模块使用统一格式上报异常。
"""


class ExceptionLevel:
    """异常严重级别。"""

    INFO = "INFO"
    WARNING = "WARNING"
    ERROR = "ERROR"
    CRITICAL = "CRITICAL"


class ExceptionSource:
    """异常来源模块。"""

    VOICE = "voice_interaction"
    CONTROLLER = "robot_controller"
    DISPATCHER = "task_dispatcher"
    NAVIGATION = "navigation_manager"
    DATABASE = "database"
    SYSTEM = "system"


class ExceptionType:
    """异常类型。"""

    # 语音与指令类异常
    INVALID_VOICE_COMMAND = "INVALID_VOICE_COMMAND"
    UNKNOWN_INTENT = "UNKNOWN_INTENT"
    MISSING_TARGET_TABLE = "MISSING_TARGET_TABLE"

    # 数据库类异常
    DATABASE_QUERY_FAILED = "DATABASE_QUERY_FAILED"
    DATABASE_WRITE_FAILED = "DATABASE_WRITE_FAILED"
    TABLE_NOT_FOUND = "TABLE_NOT_FOUND"
    SESSION_CREATE_FAILED = "SESSION_CREATE_FAILED"
    TASK_RECORD_CREATE_FAILED = "TASK_RECORD_CREATE_FAILED"
    TASK_STATUS_UPDATE_FAILED = "TASK_STATUS_UPDATE_FAILED"

    # 任务调度类异常
    EMPTY_TASK = "EMPTY_TASK"
    UNKNOWN_TASK = "UNKNOWN_TASK"
    TASK_BUSY = "TASK_BUSY"
    TASK_FAILED = "TASK_FAILED"
    TASK_CANCELED = "TASK_CANCELED"

    # 导航类异常
    UNKNOWN_NAV_POINT = "UNKNOWN_NAV_POINT"
    INVALID_NAV_POINT = "INVALID_NAV_POINT"
    NAVIGATION_TIMEOUT = "NAVIGATION_TIMEOUT"
    MOVE_BASE_UNAVAILABLE = "MOVE_BASE_UNAVAILABLE"

    # 系统类异常
    CONFIG_LOAD_FAILED = "CONFIG_LOAD_FAILED"
    MODULE_RUNTIME_ERROR = "MODULE_RUNTIME_ERROR"
