#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
数据库订单适配器。

用途：
1. 将语音点餐模块与餐厅数据库模块对接。
2. 从数据库读取菜单。
3. 根据 table_1 / table_2 等导航点名称查找餐桌。
4. 自动创建或复用 table_session。
5. 将语音确认订单写入 order_info / order_item。
6. 支持修改数据库中的订单明细。
7. 支持结账并写入 payment_record。

说明：
本文件直接对接当前数据库表结构，不依赖额外 ROS 服务。
数据库表字段与 robot_restaurant_database_code_order_complete 版本保持一致。
"""

from datetime import datetime
from decimal import Decimal
from pathlib import Path
from typing import Any, Dict, List, Optional
from uuid import uuid4

import pymysql
import yaml


class DatabaseError(RuntimeError):
    """数据库适配器异常。"""


class DatabaseOrderAdapter:
    """语音点餐数据库适配器。"""

    def __init__(self, config_file: str):
        self.config_file = Path(config_file).expanduser()
        self.config = self._load_config(self.config_file)

    def _load_config(self, config_file: Path) -> Dict[str, Any]:
        if not config_file.exists():
            raise DatabaseError(f"数据库配置文件不存在: {config_file}")

        with config_file.open("r", encoding="utf-8") as f:
            data = yaml.safe_load(f) or {}

        db = data.get("database", data)

        required = ["host", "port", "user", "password", "database", "charset"]
        missing = [key for key in required if key not in db]
        if missing:
            raise DatabaseError(f"数据库配置缺少字段: {missing}")

        return db

    def get_connection(self):
        return pymysql.connect(
            host=self.config["host"],
            port=int(self.config["port"]),
            user=self.config["user"],
            password=self.config["password"],
            database=self.config["database"],
            charset=self.config.get("charset", "utf8mb4"),
            cursorclass=pymysql.cursors.DictCursor,
        )

    def health_check(self) -> bool:
        """检查数据库是否可连接。"""
        connection = self.get_connection()
        try:
            with connection.cursor() as cursor:
                cursor.execute("SELECT 1 AS ok")
                row = cursor.fetchone()
                return row["ok"] == 1
        finally:
            connection.close()

    def get_menu_items(self) -> List[Dict[str, Any]]:
        """
        从数据库读取可售菜单。

        Returns:
            list[dict]: 菜品列表
        """
        sql = """
        SELECT mi.id AS item_id,
               mi.item_name AS name,
               mi.price,
               mi.description,
               mi.image_path,
               mi.is_available AS available,
               mc.category_name AS category
        FROM menu_item mi
        LEFT JOIN menu_category mc ON mi.category_id = mc.id
        WHERE mi.is_available = 1
        ORDER BY mc.display_order ASC, mi.id ASC
        """

        connection = self.get_connection()
        try:
            with connection.cursor() as cursor:
                cursor.execute(sql)
                rows = cursor.fetchall()
                for row in rows:
                    row["price"] = float(row["price"])
                    row["aliases"] = [row["name"]]
                return rows
        finally:
            connection.close()

    def get_table_by_nav_point(self, nav_point_name: str) -> Optional[Dict[str, Any]]:
        """
        根据导航点名称查询餐桌。

        Args:
            nav_point_name: table_1 / table_2 / table_3 / table_4

        Returns:
            dict | None: 餐桌信息
        """
        sql = """
        SELECT *
        FROM restaurant_table
        WHERE nav_point_name = %s
        """

        connection = self.get_connection()
        try:
            with connection.cursor() as cursor:
                cursor.execute(sql, (nav_point_name,))
                return cursor.fetchone()
        finally:
            connection.close()

    def get_active_session_by_table_nav_point(
        self,
        nav_point_name: str,
    ) -> Optional[Dict[str, Any]]:
        """
        根据 table_1 等导航点名称查询当前用餐 session。

        Args:
            nav_point_name: 餐桌导航点名称

        Returns:
            dict | None: 当前用餐 session
        """
        sql = """
        SELECT ts.*,
               rt.nav_point_name,
               rt.table_display_name
        FROM table_session ts
        JOIN restaurant_table rt ON ts.table_id = rt.id
        WHERE rt.nav_point_name = %s
          AND ts.status = 'dining'
        ORDER BY ts.started_at DESC
        LIMIT 1
        """

        connection = self.get_connection()
        try:
            with connection.cursor() as cursor:
                cursor.execute(sql, (nav_point_name,))
                return cursor.fetchone()
        finally:
            connection.close()

    def get_or_create_session(
        self,
        nav_point_name: str,
        customer_count: int = 1,
        auto_create: bool = True,
    ) -> Dict[str, Any]:
        """
        获取当前桌位用餐 session，如果不存在则创建。

        Args:
            nav_point_name: table_1 / table_2 等
            customer_count: 就餐人数
            auto_create: 没有 session 时是否自动创建

        Returns:
            dict: session 信息
        """
        connection = self.get_connection()
        try:
            with connection.cursor() as cursor:
                cursor.execute(
                    """
                    SELECT ts.*,
                           rt.nav_point_name,
                           rt.table_display_name
                    FROM table_session ts
                    JOIN restaurant_table rt ON ts.table_id = rt.id
                    WHERE rt.nav_point_name = %s
                      AND ts.status = 'dining'
                    ORDER BY ts.started_at DESC
                    LIMIT 1
                    """,
                    (nav_point_name,),
                )
                session = cursor.fetchone()

                if session is not None:
                    return session

                if not auto_create:
                    raise DatabaseError(f"{nav_point_name} 当前没有正在用餐的 session")

                cursor.execute(
                    """
                    SELECT *
                    FROM restaurant_table
                    WHERE nav_point_name = %s
                    """,
                    (nav_point_name,),
                )
                table = cursor.fetchone()

                if table is None:
                    raise DatabaseError(f"数据库中不存在餐桌导航点: {nav_point_name}")

                session_code = f"S{uuid4().hex[:12].upper()}"

                cursor.execute(
                    """
                    INSERT INTO table_session
                    (table_id, session_code, customer_count, status)
                    VALUES (%s, %s, %s, 'dining')
                    """,
                    (table["id"], session_code, customer_count),
                )
                session_id = cursor.lastrowid

                cursor.execute(
                    """
                    UPDATE restaurant_table
                    SET status = 'occupied',
                        updated_at = CURRENT_TIMESTAMP
                    WHERE id = %s
                    """,
                    (table["id"],),
                )

                connection.commit()

                cursor.execute(
                    """
                    SELECT ts.*,
                           rt.nav_point_name,
                           rt.table_display_name
                    FROM table_session ts
                    JOIN restaurant_table rt ON ts.table_id = rt.id
                    WHERE ts.id = %s
                    """,
                    (session_id,),
                )
                return cursor.fetchone()
        except Exception:
            connection.rollback()
            raise
        finally:
            connection.close()

    def create_order(
        self,
        session_id: int,
        items: List[Dict[str, Any]],
    ) -> int:
        """
        创建订单并写入订单明细。

        Args:
            session_id: table_session.id
            items: 临时订单列表

        Returns:
            int: 新订单 id
        """
        if not items:
            raise DatabaseError("订单为空，不能提交")

        connection = self.get_connection()
        try:
            with connection.cursor() as cursor:
                cursor.execute(
                    """
                    SELECT id, status
                    FROM table_session
                    WHERE id = %s
                    FOR UPDATE
                    """,
                    (session_id,),
                )
                session = cursor.fetchone()

                if session is None:
                    raise DatabaseError(f"session_id 不存在: {session_id}")

                if session["status"] in ("paid", "closed", "cancelled"):
                    raise DatabaseError(f"当前用餐状态不允许下单: {session['status']}")

                cursor.execute(
                    """
                    INSERT INTO order_info
                    (session_id, order_status, total_amount)
                    VALUES (%s, 'created', 0)
                    """,
                    (session_id,),
                )
                order_id = cursor.lastrowid
                total_amount = Decimal("0.00")

                for item in items:
                    item_id = int(item["item_id"])
                    quantity = int(item.get("quantity", 1))
                    remark = item.get("note") or item.get("remark") or ""

                    if quantity <= 0:
                        raise DatabaseError("菜品数量必须大于 0")

                    menu_item = self._get_available_menu_item_with_cursor(
                        cursor,
                        item_id,
                    )

                    unit_price = Decimal(str(menu_item["price"]))
                    subtotal = unit_price * Decimal(quantity)
                    total_amount += subtotal

                    cursor.execute(
                        """
                        INSERT INTO order_item
                        (order_id, item_id, quantity, unit_price, subtotal, remark)
                        VALUES (%s, %s, %s, %s, %s, %s)
                        """,
                        (
                            order_id,
                            item_id,
                            quantity,
                            unit_price,
                            subtotal,
                            remark,
                        ),
                    )

                cursor.execute(
                    """
                    UPDATE order_info
                    SET order_status = 'confirmed',
                        total_amount = %s,
                        updated_at = CURRENT_TIMESTAMP
                    WHERE id = %s
                    """,
                    (total_amount, order_id),
                )

                connection.commit()
                return order_id
        except Exception:
            connection.rollback()
            raise
        finally:
            connection.close()

    def add_item_to_latest_order(
        self,
        session_id: int,
        item_id: int,
        quantity: int = 1,
        remark: str = "",
    ) -> int:
        """
        向当前 session 的最新可编辑订单追加菜品。
        如果当前 session 没有订单，则自动创建一个新订单。
        """
        latest_order = self.get_latest_editable_order(session_id)

        if latest_order is None:
            return self.create_order(
                session_id=session_id,
                items=[
                    {
                        "item_id": item_id,
                        "quantity": quantity,
                        "note": remark,
                    }
                ],
            )

        connection = self.get_connection()
        try:
            with connection.cursor() as cursor:
                self._assert_order_editable_with_cursor(cursor, latest_order["id"])
                menu_item = self._get_available_menu_item_with_cursor(cursor, item_id)

                unit_price = Decimal(str(menu_item["price"]))
                subtotal = unit_price * Decimal(quantity)

                cursor.execute(
                    """
                    INSERT INTO order_item
                    (order_id, item_id, quantity, unit_price, subtotal, remark)
                    VALUES (%s, %s, %s, %s, %s, %s)
                    """,
                    (
                        latest_order["id"],
                        item_id,
                        quantity,
                        unit_price,
                        subtotal,
                        remark,
                    ),
                )

                self._recalculate_order_total_with_cursor(cursor, latest_order["id"])
                connection.commit()
                return latest_order["id"]
        except Exception:
            connection.rollback()
            raise
        finally:
            connection.close()

    def update_item_quantity_by_name(
        self,
        session_id: int,
        item_name: str,
        quantity: int,
    ) -> None:
        """按菜名修改当前 session 中最近一条订单明细数量。"""
        if quantity <= 0:
            raise DatabaseError("数量必须大于 0")

        connection = self.get_connection()
        try:
            with connection.cursor() as cursor:
                order_item = self._find_order_item_by_name_with_cursor(
                    cursor,
                    session_id,
                    item_name,
                    for_update=True,
                )

                order_id = order_item["order_id"]
                self._assert_order_editable_with_cursor(cursor, order_id)

                unit_price = Decimal(str(order_item["unit_price"]))
                subtotal = unit_price * Decimal(quantity)

                cursor.execute(
                    """
                    UPDATE order_item
                    SET quantity = %s,
                        subtotal = %s
                    WHERE id = %s
                    """,
                    (quantity, subtotal, order_item["id"]),
                )

                self._recalculate_order_total_with_cursor(cursor, order_id)
                connection.commit()
        except Exception:
            connection.rollback()
            raise
        finally:
            connection.close()

    def update_item_remark_by_name(
        self,
        session_id: int,
        item_name: str,
        remark: str,
    ) -> None:
        """按菜名修改当前 session 中最近一条订单明细备注。"""
        connection = self.get_connection()
        try:
            with connection.cursor() as cursor:
                order_item = self._find_order_item_by_name_with_cursor(
                    cursor,
                    session_id,
                    item_name,
                    for_update=True,
                )

                order_id = order_item["order_id"]
                self._assert_order_editable_with_cursor(cursor, order_id)

                cursor.execute(
                    """
                    UPDATE order_item
                    SET remark = %s
                    WHERE id = %s
                    """,
                    (remark, order_item["id"]),
                )
                connection.commit()
        except Exception:
            connection.rollback()
            raise
        finally:
            connection.close()

    def remove_item_by_name(
        self,
        session_id: int,
        item_name: str,
    ) -> None:
        """按菜名删除当前 session 中最近一条订单明细。"""
        connection = self.get_connection()
        try:
            with connection.cursor() as cursor:
                order_item = self._find_order_item_by_name_with_cursor(
                    cursor,
                    session_id,
                    item_name,
                    for_update=True,
                )

                order_id = order_item["order_id"]
                self._assert_order_editable_with_cursor(cursor, order_id)

                cursor.execute(
                    """
                    DELETE FROM order_item
                    WHERE id = %s
                    """,
                    (order_item["id"],),
                )

                self._recalculate_order_total_with_cursor(cursor, order_id)
                connection.commit()
        except Exception:
            connection.rollback()
            raise
        finally:
            connection.close()

    def cancel_latest_order(self, session_id: int) -> Optional[int]:
        """
        取消当前 session 的最新可编辑订单。

        Returns:
            int | None: 被取消订单 id
        """
        latest_order = self.get_latest_editable_order(session_id)

        if latest_order is None:
            return None

        connection = self.get_connection()
        try:
            with connection.cursor() as cursor:
                self._assert_order_editable_with_cursor(cursor, latest_order["id"])
                cursor.execute(
                    """
                    UPDATE order_info
                    SET order_status = 'cancelled',
                        total_amount = 0,
                        updated_at = CURRENT_TIMESTAMP
                    WHERE id = %s
                    """,
                    (latest_order["id"],),
                )
                connection.commit()
                return latest_order["id"]
        except Exception:
            connection.rollback()
            raise
        finally:
            connection.close()

    def get_latest_editable_order(self, session_id: int) -> Optional[Dict[str, Any]]:
        """查询当前 session 最新的可编辑订单。"""
        sql = """
        SELECT *
        FROM order_info
        WHERE session_id = %s
          AND order_status NOT IN ('cancelled', 'finished')
        ORDER BY created_at DESC, id DESC
        LIMIT 1
        """

        connection = self.get_connection()
        try:
            with connection.cursor() as cursor:
                cursor.execute(sql, (session_id,))
                return cursor.fetchone()
        finally:
            connection.close()

    def calculate_bill(self, session_id: int, discount_amount=0) -> Dict[str, Decimal]:
        """计算账单。"""
        connection = self.get_connection()
        try:
            with connection.cursor() as cursor:
                cursor.execute(
                    """
                    SELECT COALESCE(SUM(total_amount), 0) AS total_amount
                    FROM order_info
                    WHERE session_id = %s
                      AND order_status <> 'cancelled'
                    """,
                    (session_id,),
                )
                row = cursor.fetchone()

                total_amount = Decimal(str(row["total_amount"]))
                discount = Decimal(str(discount_amount))
                final_amount = total_amount - discount

                if final_amount < Decimal("0.00"):
                    final_amount = Decimal("0.00")

                return {
                    "total_amount": total_amount,
                    "discount_amount": discount,
                    "final_amount": final_amount,
                }
        finally:
            connection.close()

    def create_payment(
        self,
        session_id: int,
        payment_method: str = "cash",
        discount_amount=0,
    ) -> int:
        """创建支付记录并完成结账。"""
        connection = self.get_connection()
        try:
            with connection.cursor() as cursor:
                cursor.execute(
                    """
                    SELECT id, table_id, status
                    FROM table_session
                    WHERE id = %s
                    FOR UPDATE
                    """,
                    (session_id,),
                )
                session = cursor.fetchone()

                if session is None:
                    raise DatabaseError(f"session_id 不存在: {session_id}")

                if session["status"] in ("paid", "closed", "cancelled"):
                    raise DatabaseError(f"当前用餐状态不允许重复结账: {session['status']}")

                cursor.execute(
                    """
                    SELECT COALESCE(SUM(total_amount), 0) AS total_amount
                    FROM order_info
                    WHERE session_id = %s
                      AND order_status <> 'cancelled'
                    """,
                    (session_id,),
                )
                row = cursor.fetchone()

                total_amount = Decimal(str(row["total_amount"]))
                discount = Decimal(str(discount_amount))
                final_amount = total_amount - discount

                if final_amount < Decimal("0.00"):
                    final_amount = Decimal("0.00")

                cursor.execute(
                    """
                    INSERT INTO payment_record
                    (session_id, total_amount, discount_amount, final_amount, payment_method, payment_status)
                    VALUES (%s, %s, %s, %s, %s, 'paid')
                    """,
                    (
                        session_id,
                        total_amount,
                        discount,
                        final_amount,
                        payment_method,
                    ),
                )
                payment_id = cursor.lastrowid

                cursor.execute(
                    """
                    UPDATE table_session
                    SET status = 'paid',
                        ended_at = CURRENT_TIMESTAMP
                    WHERE id = %s
                    """,
                    (session_id,),
                )

                cursor.execute(
                    """
                    UPDATE restaurant_table
                    SET status = 'available',
                        updated_at = CURRENT_TIMESTAMP
                    WHERE id = %s
                    """,
                    (session["table_id"],),
                )

                cursor.execute(
                    """
                    UPDATE order_info
                    SET order_status = 'finished',
                        updated_at = CURRENT_TIMESTAMP
                    WHERE session_id = %s
                      AND order_status <> 'cancelled'
                    """,
                    (session_id,),
                )

                connection.commit()
                return payment_id
        except Exception:
            connection.rollback()
            raise
        finally:
            connection.close()

    def get_session_bill_detail(self, session_id: int) -> Dict[str, Any]:
        """查询某次用餐完整账单。"""
        connection = self.get_connection()
        try:
            with connection.cursor() as cursor:
                cursor.execute(
                    """
                    SELECT ts.*,
                           rt.nav_point_name,
                           rt.table_display_name
                    FROM table_session ts
                    JOIN restaurant_table rt ON ts.table_id = rt.id
                    WHERE ts.id = %s
                    """,
                    (session_id,),
                )
                session = cursor.fetchone()

                if session is None:
                    raise DatabaseError(f"session_id 不存在: {session_id}")

                cursor.execute(
                    """
                    SELECT *
                    FROM order_info
                    WHERE session_id = %s
                    ORDER BY created_at ASC
                    """,
                    (session_id,),
                )
                orders = cursor.fetchall()

                for order in orders:
                    cursor.execute(
                        """
                        SELECT oi.*,
                               mi.item_name,
                               mi.description,
                               mi.image_path
                        FROM order_item oi
                        JOIN menu_item mi ON oi.item_id = mi.id
                        WHERE oi.order_id = %s
                        ORDER BY oi.id ASC
                        """,
                        (order["id"],),
                    )
                    order["items"] = cursor.fetchall()

                cursor.execute(
                    """
                    SELECT *
                    FROM payment_record
                    WHERE session_id = %s
                    ORDER BY paid_at DESC
                    LIMIT 1
                    """,
                    (session_id,),
                )
                payment = cursor.fetchone()

                bill = self.calculate_bill(session_id)

                if payment:
                    bill = {
                        "total_amount": Decimal(str(payment["total_amount"])),
                        "discount_amount": Decimal(str(payment["discount_amount"])),
                        "final_amount": Decimal(str(payment["final_amount"])),
                    }

                return {
                    "session": session,
                    "orders": orders,
                    "payment": payment,
                    "bill": bill,
                }
        finally:
            connection.close()

    def get_table_orders_by_date(
        self,
        nav_point_name: str,
        date_str: str,
    ) -> List[Dict[str, Any]]:
        """查询某桌某天完整订单明细。"""
        sql = """
        SELECT rt.nav_point_name,
               rt.table_display_name,
               ts.id AS session_id,
               ts.session_code,
               ts.customer_count,
               ts.status AS session_status,
               ts.started_at,
               ts.ended_at,
               o.id AS order_id,
               o.order_status,
               o.total_amount AS order_total_amount,
               o.created_at AS order_created_at,
               oi.id AS order_item_id,
               oi.item_id,
               mi.item_name,
               oi.quantity,
               oi.unit_price,
               oi.subtotal,
               oi.remark,
               pr.id AS payment_id,
               pr.total_amount AS payment_total_amount,
               pr.discount_amount,
               pr.final_amount,
               pr.payment_method,
               pr.payment_status,
               pr.paid_at
        FROM table_session ts
        JOIN restaurant_table rt ON ts.table_id = rt.id
        LEFT JOIN order_info o ON o.session_id = ts.id
        LEFT JOIN order_item oi ON oi.order_id = o.id
        LEFT JOIN menu_item mi ON mi.id = oi.item_id
        LEFT JOIN payment_record pr ON pr.session_id = ts.id
        WHERE rt.nav_point_name = %s
          AND DATE(ts.started_at) = %s
        ORDER BY ts.started_at ASC, o.created_at ASC, oi.id ASC
        """

        connection = self.get_connection()
        try:
            with connection.cursor() as cursor:
                cursor.execute(sql, (nav_point_name, date_str))
                return cursor.fetchall()
        finally:
            connection.close()

    def _get_available_menu_item_with_cursor(
        self,
        cursor,
        item_id: int,
    ) -> Dict[str, Any]:
        cursor.execute(
            """
            SELECT id, item_name, price, is_available
            FROM menu_item
            WHERE id = %s
            """,
            (item_id,),
        )
        menu_item = cursor.fetchone()

        if menu_item is None:
            raise DatabaseError(f"菜品不存在: item_id={item_id}")

        if not menu_item["is_available"]:
            raise DatabaseError(f"菜品当前不可售: {menu_item['item_name']}")

        return menu_item

    def _assert_order_editable_with_cursor(
        self,
        cursor,
        order_id: int,
    ) -> Dict[str, Any]:
        cursor.execute(
            """
            SELECT o.id,
                   o.order_status,
                   o.session_id,
                   ts.status AS session_status
            FROM order_info o
            JOIN table_session ts ON o.session_id = ts.id
            WHERE o.id = %s
            FOR UPDATE
            """,
            (order_id,),
        )
        order = cursor.fetchone()

        if order is None:
            raise DatabaseError(f"order_id 不存在: {order_id}")

        if order["order_status"] in ("cancelled", "finished"):
            raise DatabaseError(f"当前订单状态不允许修改: {order['order_status']}")

        if order["session_status"] in ("paid", "closed", "cancelled"):
            raise DatabaseError(f"当前用餐状态不允许修改订单: {order['session_status']}")

        return order

    def _find_order_item_by_name_with_cursor(
        self,
        cursor,
        session_id: int,
        item_name: str,
        for_update: bool = False,
    ) -> Dict[str, Any]:
        lock_sql = "FOR UPDATE" if for_update else ""

        cursor.execute(
            f"""
            SELECT oi.*,
                   mi.item_name
            FROM order_item oi
            JOIN order_info o ON oi.order_id = o.id
            JOIN menu_item mi ON oi.item_id = mi.id
            WHERE o.session_id = %s
              AND o.order_status NOT IN ('cancelled', 'finished')
              AND (mi.item_name LIKE %s OR %s LIKE CONCAT('%%', mi.item_name, '%%'))
            ORDER BY oi.id DESC
            LIMIT 1
            {lock_sql}
            """,
            (session_id, f"%{item_name}%", item_name),
        )

        order_item = cursor.fetchone()

        if order_item is None:
            raise DatabaseError(f"当前订单中没有找到菜品: {item_name}")

        return order_item

    def _recalculate_order_total_with_cursor(
        self,
        cursor,
        order_id: int,
    ) -> Decimal:
        cursor.execute(
            """
            SELECT COUNT(*) AS item_count,
                   COALESCE(SUM(subtotal), 0) AS total_amount
            FROM order_item
            WHERE order_id = %s
            """,
            (order_id,),
        )
        row = cursor.fetchone()

        item_count = int(row["item_count"])
        total_amount = Decimal(str(row["total_amount"]))

        if item_count == 0:
            cursor.execute(
                """
                UPDATE order_info
                SET order_status = 'cancelled',
                    total_amount = 0,
                    updated_at = CURRENT_TIMESTAMP
                WHERE id = %s
                """,
                (order_id,),
            )
        else:
            cursor.execute(
                """
                UPDATE order_info
                SET order_status = 'confirmed',
                    total_amount = %s,
                    updated_at = CURRENT_TIMESTAMP
                WHERE id = %s
                """,
                (total_amount, order_id),
            )

        return total_amount
