#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import sqlite3
import json
import uuid
import time
import os
from datetime import datetime
from typing import Dict, List, Optional, Tuple, Any

class DatabaseManager:
    """数据库管理器 - 实现SDD9中定义的所有数据表"""

    def __init__(self, db_path: str = None):
        """
        初始化数据库管理器

        Args:
            db_path: 数据库文件路径，默认为 ~/.ros/warehouse.db
        """
        if db_path is None:
            db_path = os.path.expanduser("~/catkin_ws/src/monday9/data/warehouse.db")

        # 确保目录存在
        db_dir = os.path.dirname(db_path)
        if db_dir and not os.path.exists(db_dir):
            os.makedirs(db_dir)

        self.db_path = db_path
        self.conn = None
        self._init_database()

    def _init_database(self):
        """初始化数据库，创建所有表"""
        self.conn = sqlite3.connect(self.db_path, check_same_thread=False)
        self.conn.row_factory = sqlite3.Row

        # 创建所有表
        self._create_task_table()
        self._create_cargo_type_table()
        self._create_cargo_record_table()
        self._create_exception_type_table()
        self._create_exception_log_table()
        self._create_pallet_slot_table()
        self._create_pallet_slot_state_table()

        # 初始化异常类型数据
        self._init_exception_types()

        # 初始化货物类型数据
        self._init_cargo_types()

        self.conn.commit()

    def _create_task_table(self):
        """创建任务表 (表3-1)"""
        self.conn.execute('''
            CREATE TABLE IF NOT EXISTS task (
                task_id TEXT PRIMARY KEY,
                total_count INTEGER NOT NULL,
                completed_count INTEGER DEFAULT 0,
                status TEXT NOT NULL,
                start_time INTEGER,
                end_time INTEGER,
                parameters TEXT
            )
        ''')

    def _create_cargo_type_table(self):
        """创建货物类型表 (表3-2)"""
        self.conn.execute('''
            CREATE TABLE IF NOT EXISTS cargo_type (
                type_id INTEGER PRIMARY KEY AUTOINCREMENT,
                type_name TEXT UNIQUE NOT NULL,
                default_length REAL,
                default_width REAL,
                default_height REAL
            )
        ''')

    def _create_cargo_record_table(self):
        """创建货物处理记录表 (表3-3)"""
        self.conn.execute('''
            CREATE TABLE IF NOT EXISTS cargo_record (
                record_id INTEGER PRIMARY KEY AUTOINCREMENT,
                task_id TEXT NOT NULL,
                type_id INTEGER NOT NULL,
                actual_length REAL,
                actual_width REAL,
                actual_height REAL,
                position_x REAL,
                position_y REAL,
                position_z REAL,
                final_status TEXT NOT NULL,
                process_timestamp INTEGER NOT NULL,
                retry_count INTEGER DEFAULT 0,
                FOREIGN KEY (task_id) REFERENCES task(task_id),
                FOREIGN KEY (type_id) REFERENCES cargo_type(type_id)
            )
        ''')

    def _create_exception_type_table(self):
        """创建异常类型表 (表3-4)"""
        self.conn.execute('''
            CREATE TABLE IF NOT EXISTS exception_type (
                exception_type_id INTEGER PRIMARY KEY AUTOINCREMENT,
                exception_name TEXT UNIQUE NOT NULL,
                default_action TEXT,
                severity_level INTEGER
            )
        ''')

    def _create_exception_log_table(self):
        """创建异常记录表 (表3-5)"""
        self.conn.execute('''
            CREATE TABLE IF NOT EXISTS exception_log (
                log_id INTEGER PRIMARY KEY AUTOINCREMENT,
                task_id TEXT,
                record_id INTEGER,
                exception_type_id INTEGER NOT NULL,
                exception_message TEXT,
                timestamp INTEGER NOT NULL,
                resolved INTEGER DEFAULT 0,
                resolved_timestamp INTEGER,
                FOREIGN KEY (task_id) REFERENCES task(task_id),
                FOREIGN KEY (record_id) REFERENCES cargo_record(record_id),
                FOREIGN KEY (exception_type_id) REFERENCES exception_type(exception_type_id)
            )
        ''')

    def _create_pallet_slot_table(self):
        """创建码垛位表 (表3-6)"""
        self.conn.execute('''
            CREATE TABLE IF NOT EXISTS pallet_slot (
                slot_id TEXT PRIMARY KEY,
                cargo_type_id INTEGER NOT NULL,
                position_x REAL NOT NULL,
                position_y REAL NOT NULL,
                position_z REAL NOT NULL,
                max_layer INTEGER NOT NULL,
                layer_offset_x REAL DEFAULT 0.0,
                layer_offset_y REAL DEFAULT 0.0,
                layer_offset_z REAL NOT NULL,
                FOREIGN KEY (cargo_type_id) REFERENCES cargo_type(type_id)
            )
        ''')

    def _create_pallet_slot_state_table(self):
        """创建码垛位状态表 (表3-7)"""
        self.conn.execute('''
            CREATE TABLE IF NOT EXISTS pallet_slot_state (
                state_id INTEGER PRIMARY KEY AUTOINCREMENT,
                slot_id TEXT NOT NULL,
                task_id TEXT NOT NULL,
                current_layer INTEGER DEFAULT 0,
                last_updated INTEGER NOT NULL,
                FOREIGN KEY (slot_id) REFERENCES pallet_slot(slot_id),
                FOREIGN KEY (task_id) REFERENCES task(task_id),
                UNIQUE(slot_id, task_id)
            )
        ''')

    def _init_exception_types(self):
        """初始化异常类型数据 (表6-1)"""
        exception_types = [
            (1, "识别失败", "暂停任务", 3),
            (2, "定位偏差过大", "暂停任务", 3),
            (3, "抓取失败", "跳过当前货物", 2),
            (4, "抓取途中滑落", "重新识别并处理", 2),
            (5, "路径不可达", "调整路径或跳过", 2),
            (6, "机械臂位姿不可达", "调整路径或跳过", 2),
            (7, "放置失败", "跳过当前货物", 2),
            (8, "码垛区已满", "暂停任务", 3),
            (9, "垛型坍塌", "紧急停止", 5),
            (10, "ROS节点通信超时", "尝试重连", 4),
            (11, "相机数据丢失", "暂停任务", 4),
            (12, "机械臂驱动故障", "紧急停止", 5),
            (13, "夹爪故障", "紧急停止", 5),
            (14, "紧急停止按钮触发", "立即断电", 5),
            (15, "电源电量不足", "完成当前动作后回零", 4),
            (16, "任务参数无效", "提示重新输入", 1),
            (17, "复位失败", "安全锁定", 5),
        ]

        for ex_id, name, action, severity in exception_types:
            self.conn.execute('''
                INSERT OR IGNORE INTO exception_type 
                (exception_type_id, exception_name, default_action, severity_level)
                VALUES (?, ?, ?, ?)
            ''', (ex_id, name, action, severity))

    def _init_cargo_types(self):
        """初始化货物类型数据"""
        cargo_types = [
            ("本色纸盒", 0.1, 0.1, 0.1),
            ("彩色纸箱", 0.1, 0.1, 0.1),
        ]

        for name, length, width, height in cargo_types:
            self.conn.execute('''
                INSERT OR IGNORE INTO cargo_type (type_name, default_length, default_width, default_height)
                VALUES (?, ?, ?, ?)
            ''', (name, length, width, height))

    # ==================== 任务管理方法 ====================

    def create_task(self, total_count: int, parameters: dict = None) -> str:
        """
        创建新任务

        Args:
            total_count: 计划分拣总数
            parameters: 任务参数（如垛型要求）

        Returns:
            task_id: 任务唯一标识
        """
        task_id = str(uuid.uuid4())
        params_json = json.dumps(parameters) if parameters else None

        self.conn.execute('''
            INSERT INTO task (task_id, total_count, status, parameters)
            VALUES (?, ?, ?, ?)
        ''', (task_id, total_count, "待启动", params_json))

        self.conn.commit()
        return task_id

    def start_task(self, task_id: str):
        """开始任务"""
        self.conn.execute('''
            UPDATE task 
            SET status = '执行中', start_time = ?
            WHERE task_id = ?
        ''', (int(time.time() * 1000), task_id))
        self.conn.commit()

    def update_task_progress(self, task_id: str, completed_count: int = None, status: str = None):
        """更新任务进度"""
        updates = []
        params = []

        if completed_count is not None:
            updates.append("completed_count = ?")
            params.append(completed_count)

        if status is not None:
            updates.append("status = ?")
            params.append(status)

        if updates:
            params.append(task_id)
            self.conn.execute(f'''
                UPDATE task SET {', '.join(updates)} WHERE task_id = ?
            ''', params)
            self.conn.commit()

    def complete_task(self, task_id: str):
        """完成任务"""
        self.conn.execute('''
            UPDATE task 
            SET status = '已完成', end_time = ?
            WHERE task_id = ?
        ''', (int(time.time() * 1000), task_id))
        self.conn.commit()

    def cancel_task(self, task_id: str):
        """取消任务"""
        self.conn.execute('''
            UPDATE task SET status = '已取消' WHERE task_id = ?
        ''', (task_id,))
        self.conn.commit()

    def get_task(self, task_id: str) -> dict:
        """获取任务信息"""
        cursor = self.conn.execute('SELECT * FROM task WHERE task_id = ?', (task_id,))
        row = cursor.fetchone()
        return dict(row) if row else None

    def get_all_tasks(self) -> List[dict]:
        """获取所有任务"""
        cursor = self.conn.execute('SELECT * FROM task ORDER BY start_time DESC')
        return [dict(row) for row in cursor.fetchall()]

    def get_task_statistics(self) -> dict:
        """获取任务统计信息"""
        cursor = self.conn.execute('''
            SELECT 
                COUNT(*) as total_tasks,
                SUM(CASE WHEN status = '已完成' THEN 1 ELSE 0 END) as completed_tasks,
                SUM(completed_count) as total_processed,
                SUM(total_count) as total_planned
            FROM task
        ''')
        row = cursor.fetchone()
        return dict(row) if row else {}

    # ==================== 货物记录方法 ====================

    def get_cargo_type_id(self, type_name: str) -> int:
        """根据类型名称获取类型ID"""
        cursor = self.conn.execute('SELECT type_id FROM cargo_type WHERE type_name = ?', (type_name,))
        row = cursor.fetchone()
        return row['type_id'] if row else None

    def get_cargo_type_name(self, type_id: int) -> str:
        """根据类型ID获取类型名称"""
        cursor = self.conn.execute('SELECT type_name FROM cargo_type WHERE type_id = ?', (type_id,))
        row = cursor.fetchone()
        return row['type_name'] if row else None

    def add_cargo_record(self, task_id: str, type_name: str, final_status: str,
                         actual_dimensions: dict = None, position: dict = None,
                         retry_count: int = 0) -> int:
        """
        添加货物处理记录

        Args:
            task_id: 关联的任务ID
            type_name: 货物类型名称
            final_status: 最终状态（已码垛/抓取失败/识别失败/跳过等）
            actual_dimensions: 实际尺寸 {'length': x, 'width': y, 'height': z}
            position: 抓取位置 {'x': x, 'y': y, 'z': z}
            retry_count: 重试次数

        Returns:
            record_id: 记录ID
        """
        type_id = self.get_cargo_type_id(type_name)
        if type_id is None:
            # 如果类型不存在，先创建
            self.conn.execute('''
                INSERT INTO cargo_type (type_name) VALUES (?)
            ''', (type_name,))
            self.conn.commit()
            type_id = self.get_cargo_type_id(type_name)

        cursor = self.conn.execute('''
            INSERT INTO cargo_record 
            (task_id, type_id, actual_length, actual_width, actual_height,
             position_x, position_y, position_z, final_status, process_timestamp, retry_count)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''', (
            task_id, type_id,
            actual_dimensions.get('length') if actual_dimensions else None,
            actual_dimensions.get('width') if actual_dimensions else None,
            actual_dimensions.get('height') if actual_dimensions else None,
            position.get('x') if position else None,
            position.get('y') if position else None,
            position.get('z') if position else None,
            final_status,
            int(time.time() * 1000),
            retry_count
        ))

        self.conn.commit()
        return cursor.lastrowid

    def update_cargo_record_status(self, record_id: int, final_status: str):
        """更新货物记录状态"""
        self.conn.execute('''
            UPDATE cargo_record SET final_status = ? WHERE record_id = ?
        ''', (final_status, record_id))
        self.conn.commit()

    def get_cargo_records_by_task(self, task_id: str) -> List[dict]:
        """获取任务的所有货物记录"""
        cursor = self.conn.execute('''
            SELECT r.*, t.type_name 
            FROM cargo_record r
            JOIN cargo_type t ON r.type_id = t.type_id
            WHERE r.task_id = ?
            ORDER BY r.process_timestamp
        ''', (task_id,))
        return [dict(row) for row in cursor.fetchall()]

    def get_cargo_statistics(self) -> dict:
        """获取货物统计信息"""
        cursor = self.conn.execute('''
            SELECT 
                t.type_name,
                COUNT(*) as total,
                SUM(CASE WHEN r.final_status = '已码垛' THEN 1 ELSE 0 END) as placed,
                SUM(CASE WHEN r.final_status = '抓取失败' THEN 1 ELSE 0 END) as pick_failed,
                SUM(CASE WHEN r.final_status = '识别失败' THEN 1 ELSE 0 END) as detect_failed
            FROM cargo_record r
            JOIN cargo_type t ON r.type_id = t.type_id
            GROUP BY t.type_id, t.type_name
        ''')
        return [dict(row) for row in cursor.fetchall()]
    
    def add_cargo_type(self, type_name, default_length=0.1, default_width=0.1, default_height=0.1):
        """添加货物类型"""
        cursor = self.conn.execute('''
            INSERT OR IGNORE INTO cargo_type (type_name, default_length, default_width, default_height)
            VALUES (?, ?, ?, ?)
        ''', (type_name, default_length, default_width, default_height))
        self.conn.commit()
        return cursor.lastrowid

    # ==================== 异常管理方法 ====================

    def log_exception(self, exception_name: str, exception_message: str,
                      task_id: str = None, record_id: int = None) -> int:
        """
        记录异常

        Args:
            exception_name: 异常类型名称
            exception_message: 异常详细信息
            task_id: 关联的任务ID
            record_id: 关联的货物记录ID

        Returns:
            log_id: 日志ID
        """
        # 获取异常类型ID
        cursor = self.conn.execute('''
            SELECT exception_type_id FROM exception_type WHERE exception_name = ?
        ''', (exception_name,))
        row = cursor.fetchone()

        if row is None:
            # 未知异常类型，使用默认
            exception_type_id = 1
        else:
            exception_type_id = row['exception_type_id']

        cursor = self.conn.execute('''
            INSERT INTO exception_log 
            (task_id, record_id, exception_type_id, exception_message, timestamp)
            VALUES (?, ?, ?, ?, ?)
        ''', (task_id, record_id, exception_type_id, exception_message, int(time.time() * 1000)))

        self.conn.commit()
        return cursor.lastrowid

    def resolve_exception(self, log_id: int):
        """标记异常已处理"""
        self.conn.execute('''
            UPDATE exception_log 
            SET resolved = 1, resolved_timestamp = ?
            WHERE log_id = ?
        ''', (int(time.time() * 1000), log_id))
        self.conn.commit()

    def get_unresolved_exceptions(self) -> List[dict]:
        """获取未处理的异常"""
        cursor = self.conn.execute('''
            SELECT e.*, t.exception_name, t.default_action, t.severity_level
            FROM exception_log e
            JOIN exception_type t ON e.exception_type_id = t.exception_type_id
            WHERE e.resolved = 0
            ORDER BY e.timestamp DESC
        ''')
        return [dict(row) for row in cursor.fetchall()]

    def get_exception_statistics(self) -> dict:
        """获取异常统计信息"""
        cursor = self.conn.execute('''
            SELECT 
                t.exception_name,
                COUNT(*) as count,
                t.severity_level
            FROM exception_log e
            JOIN exception_type t ON e.exception_type_id = t.exception_type_id
            GROUP BY t.exception_type_id, t.exception_name
            ORDER BY count DESC
        ''')
        return [dict(row) for row in cursor.fetchall()]

    # ==================== 码垛位管理方法 ====================

    def add_pallet_slot(self, slot_id: str, cargo_type_name: str,
                        position: dict, max_layer: int,
                        layer_offsets: dict) -> bool:
        """
        添加码垛位

        Args:
            slot_id: 码垛位ID
            cargo_type_name: 允许放置的货物类型
            position: 基准点坐标 {'x': x, 'y': y, 'z': z}
            max_layer: 最大允许层数
            layer_offsets: 层间偏移 {'x': dx, 'y': dy, 'z': dz}
        """
        type_id = self.get_cargo_type_id(cargo_type_name)
        if type_id is None and cargo_type_name != "待分配":
            return False

        self.conn.execute('''
            INSERT OR REPLACE INTO pallet_slot 
            (slot_id, cargo_type_id, position_x, position_y, position_z,
             max_layer, layer_offset_x, layer_offset_y, layer_offset_z)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''', (
            slot_id, type_id,
            position['x'], position['y'], position['z'],
            max_layer,
            layer_offsets.get('x', 0.0),
            layer_offsets.get('y', 0.0),
            layer_offsets['z']
        ))

        self.conn.commit()
        return True

    def get_pallet_slot(self, slot_id: str) -> dict:
        """获取码垛位信息"""
        cursor = self.conn.execute('''
            SELECT p.*, t.type_name as cargo_type_name
            FROM pallet_slot p
            JOIN cargo_type t ON p.cargo_type_id = t.type_id
            WHERE p.slot_id = ?
        ''', (slot_id,))
        row = cursor.fetchone()
        return dict(row) if row else None

    def get_all_pallet_slots(self) -> List[dict]:
        """获取所有码垛位"""
        cursor = self.conn.execute('''
            SELECT p.*, t.type_name as cargo_type_name
            FROM pallet_slot p
            JOIN cargo_type t ON p.cargo_type_id = t.type_id
        ''')
        return [dict(row) for row in cursor.fetchall()]

    def update_pallet_slot_state(self, slot_id: str, task_id: str, current_layer: int):
        """更新码垛位状态"""
        now = int(time.time() * 1000)
        self.conn.execute('''
            INSERT OR REPLACE INTO pallet_slot_state 
            (slot_id, task_id, current_layer, last_updated)
            VALUES (?, ?, ?, ?)
        ''', (slot_id, task_id, current_layer, now))
        self.conn.commit()

    def get_pallet_slot_state(self, slot_id: str, task_id: str) -> dict:
        """获取码垛位状态"""
        cursor = self.conn.execute('''
            SELECT s.*, p.max_layer, p.layer_offset_z
            FROM pallet_slot_state s
            JOIN pallet_slot p ON s.slot_id = p.slot_id
            WHERE s.slot_id = ? AND s.task_id = ?
        ''', (slot_id, task_id))
        row = cursor.fetchone()
        return dict(row) if row else None

    def get_next_place_position(self, slot_id: str, task_id: str) -> dict:
        """
        计算下一个放置位置

        Returns:
            dict: {'x': x, 'y': y, 'z': z, 'layer': layer}
        """
        # 获取码垛位配置
        slot = self.get_pallet_slot(slot_id)
        if not slot:
            return None

        # 获取当前状态
        state = self.get_pallet_slot_state(slot_id, task_id)
        current_layer = state['current_layer'] if state else 0

        if current_layer >= slot['max_layer']:
            return None  # 码垛位已满

        next_layer = current_layer + 1

        # 计算位置
        x = slot['position_x'] + slot['layer_offset_x'] * (next_layer - 1)
        y = slot['position_y'] + slot['layer_offset_y'] * (next_layer - 1)
        z = slot['position_z'] + slot['layer_offset_z'] * next_layer

        return {
            'x': x,
            'y': y,
            'z': z,
            'layer': next_layer
        }
    
    def update_pallet_slot_cargo_type(self, slot_id, cargo_type_id):
        """更新码垛位的货物类型"""
        self.conn.execute('''
            UPDATE pallet_slot SET cargo_type_id = ? WHERE slot_id = ?
        ''', (cargo_type_id, slot_id))
        self.conn.commit()

    # ==================== 辅助方法 ====================

    def close(self):
        """关闭数据库连接"""
        if self.conn:
            self.conn.close()

    def backup(self, backup_path: str):
        """备份数据库"""
        import shutil
        shutil.copy2(self.db_path, backup_path)

    def get_dashboard_data(self) -> dict:
        """获取仪表板数据"""
        return {
            'task_stats': self.get_task_statistics(),
            'cargo_stats': self.get_cargo_statistics(),
            'exception_stats': self.get_exception_statistics(),
            'recent_exceptions': self.get_unresolved_exceptions()[:10],
            'recent_tasks': self.get_all_tasks()[:10]
        }


# 测试代码
if __name__ == '__main__':
    db = DatabaseManager()

    # 测试创建任务
    task_id = db.create_task(10, {'pattern': {'l': 2, 'w': 2}})
    print(f"Created task: {task_id}")

    db.start_task(task_id)

    # 测试添加货物记录
    record_id = db.add_cargo_record(
        task_id, "本色纸盒", "已码垛",
        actual_dimensions={'length': 0.1, 'width': 0.1, 'height': 0.1},
        position={'x': 2.0, 'y': 1.5, 'z': 0.8}
    )
    print(f"Added cargo record: {record_id}")

    db.update_task_progress(task_id, completed_count=1)

    # 测试异常记录
    db.log_exception("抓取失败", "夹爪闭合后未检测到货物", task_id, record_id)
    print("Logged exception")

    # 测试码垛位
    db.add_pallet_slot(
        "pallet_B", "本色纸盒",
        position={'x': 3.0, 'y': 2.0, 'z': 0.5},
        max_layer=3,
        layer_offsets={'x': 0, 'y': 0, 'z': 0.1}
    )
    db.get_all_pallet_slots()

    pos = db.get_next_place_position("pallet_B", task_id)
    print(f"Next place position: {pos}")

    db.update_pallet_slot_state("pallet_B", task_id, 1)

    # 获取统计信息
    print("\n=== Dashboard Data ===")
    print(db.get_dashboard_data())

    db.close()