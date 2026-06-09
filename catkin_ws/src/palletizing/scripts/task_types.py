#!/usr/bin/env python3
# coding=utf-8
"""码垛机器人系统 - 数据类型与枚举定义模块。

定义系统各模块共享的枚举类型与数据结构，确保跨模块通信语义一致。
"""

from enum import Enum, auto
from dataclasses import dataclass, field
from typing import Optional


class TaskState(Enum):
    """核心业务状态机的全部状态。"""
    IDLE = auto()
    NAVIGATING_TO_OBSERVE = auto()
    DETECTING = auto()
    APPROACHING_AND_GRABBING = auto()
    NAVIGATING_TO_TARGET = auto()
    PALLETIZING = auto()
    COMPLETED = auto()
    ERROR = auto()
    EMERGENCY_STOP = auto()


class ErrorType(Enum):
    """系统可处理的五类核心异常。"""
    INVALID_COMMAND = auto()
    OBJECT_NOT_FOUND = auto()
    NAVIGATION_FAILURE = auto()
    GRAB_FAILURE = auto()
    STACK_COLLAPSE = auto()


class ErrorStrategy(Enum):
    """异常处理策略。"""
    RETRY = auto()
    SKIP = auto()
    EMERGENCY_STOP = auto()


@dataclass
class TaskCommand:
    """单条码垛任务指令。

    Attributes:
        source_zone: 源区域标识 (如 'A', 'B', 'C')
        cargo_type: 货物类型 (如 'red_box', 'color_box')
        target_zone: 目标区域标识
        priority: 任务优先级，数值越小优先级越高
    """
    source_zone: str
    cargo_type: str
    target_zone: str
    priority: int = 0


@dataclass
class TaskStatus:
    """单条任务的实时执行状态。

    Attributes:
        command: 任务指令
        state: 当前状态
        error_type: 当前错误类型 (如有)
        retry_count: 已重试次数
        message: 人类可读的状态描述
    """
    command: TaskCommand
    state: TaskState = TaskState.IDLE
    error_type: Optional[ErrorType] = None
    retry_count: int = 0
    message: str = ""
