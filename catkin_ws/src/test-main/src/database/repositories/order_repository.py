"""
订单 Repository。

主要负责：
1. 创建订单
2. 保存每个订单的菜品明细
3. 修改订单明细
4. 取消订单
5. 查询某次用餐的所有订单
6. 查询某桌某天完整历史订单
7. 按 session 查询完整账单详情
8. 计算某次用餐的订单总额
"""

from decimal import Decimal
from typing import List, Dict, Any, Optional

from src.database.database_manager import DatabaseManager


class OrderRepository:
    """订单数据访问层。"""

    @staticmethod
    def create_order(session_id: int, items: List[Dict[str, Any]]) -> int:
        """
        创建订单。

        Args:
            session_id: 用餐会话 id
            items: 点单列表，例如：
                [
                    {"item_id": 1, "quantity": 2, "remark": "少辣"},
                    {"item_id": 3, "quantity": 1}
                ]

        Returns:
            int: 新订单 id
        """
        if not items:
            raise ValueError("items 不能为空")

        connection = DatabaseManager.get_connection()
        try:
            with connection.cursor() as cursor:
                cursor.execute(
                    """
                    SELECT id, status
                    FROM table_session
                    WHERE id = %s
                    """,
                    (session_id,),
                )
                session = cursor.fetchone()

                if session is None:
                    raise ValueError(f"session_id 不存在: {session_id}")

                if session["status"] in ("paid", "closed", "cancelled"):
                    raise ValueError(f"当前用餐状态不允许继续下单: {session['status']}")

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
                    remark = item.get("remark")

                    if quantity <= 0:
                        raise ValueError("quantity 必须大于 0")

                    menu_item = OrderRepository._get_available_menu_item_with_cursor(
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

    @staticmethod
    def add_order_item(
        order_id: int,
        item_id: int,
        quantity: int = 1,
        remark: Optional[str] = None,
    ) -> int:
        """
        向已有订单中追加一道菜。

        Args:
            order_id: 订单 id
            item_id: 菜品 id
            quantity: 数量
            remark: 备注

        Returns:
            int: 新增订单明细 id
        """
        if quantity <= 0:
            raise ValueError("quantity 必须大于 0")

        connection = DatabaseManager.get_connection()
        try:
            with connection.cursor() as cursor:
                OrderRepository._assert_order_editable_with_cursor(cursor, order_id)
                menu_item = OrderRepository._get_available_menu_item_with_cursor(
                    cursor,
                    item_id,
                )

                unit_price = Decimal(str(menu_item["price"]))
                subtotal = unit_price * Decimal(quantity)

                cursor.execute(
                    """
                    INSERT INTO order_item
                    (order_id, item_id, quantity, unit_price, subtotal, remark)
                    VALUES (%s, %s, %s, %s, %s, %s)
                    """,
                    (order_id, item_id, quantity, unit_price, subtotal, remark),
                )
                order_item_id = cursor.lastrowid

                OrderRepository._recalculate_order_total_with_cursor(cursor, order_id)

                connection.commit()
                return order_item_id
        except Exception:
            connection.rollback()
            raise
        finally:
            connection.close()

    @staticmethod
    def update_order_item_quantity(order_item_id: int, quantity: int) -> None:
        """
        修改某个订单明细的数量。

        Args:
            order_item_id: 订单明细 id
            quantity: 新数量
        """
        if quantity <= 0:
            raise ValueError("quantity 必须大于 0；如果要删除菜品，请使用 remove_order_item()")

        connection = DatabaseManager.get_connection()
        try:
            with connection.cursor() as cursor:
                order_item = OrderRepository._get_order_item_for_update_with_cursor(
                    cursor,
                    order_item_id,
                )
                order_id = order_item["order_id"]

                OrderRepository._assert_order_editable_with_cursor(cursor, order_id)

                unit_price = Decimal(str(order_item["unit_price"]))
                subtotal = unit_price * Decimal(quantity)

                cursor.execute(
                    """
                    UPDATE order_item
                    SET quantity = %s,
                        subtotal = %s
                    WHERE id = %s
                    """,
                    (quantity, subtotal, order_item_id),
                )

                OrderRepository._recalculate_order_total_with_cursor(cursor, order_id)

                connection.commit()
        except Exception:
            connection.rollback()
            raise
        finally:
            connection.close()

    @staticmethod
    def update_order_item_remark(order_item_id: int, remark: Optional[str]) -> None:
        """
        修改某个订单明细的备注。

        Args:
            order_item_id: 订单明细 id
            remark: 新备注
        """
        connection = DatabaseManager.get_connection()
        try:
            with connection.cursor() as cursor:
                order_item = OrderRepository._get_order_item_for_update_with_cursor(
                    cursor,
                    order_item_id,
                )
                order_id = order_item["order_id"]

                OrderRepository._assert_order_editable_with_cursor(cursor, order_id)

                cursor.execute(
                    """
                    UPDATE order_item
                    SET remark = %s
                    WHERE id = %s
                    """,
                    (remark, order_item_id),
                )

                connection.commit()
        except Exception:
            connection.rollback()
            raise
        finally:
            connection.close()

    @staticmethod
    def remove_order_item(order_item_id: int) -> None:
        """
        删除订单中的某一道菜。

        Args:
            order_item_id: 订单明细 id
        """
        connection = DatabaseManager.get_connection()
        try:
            with connection.cursor() as cursor:
                order_item = OrderRepository._get_order_item_for_update_with_cursor(
                    cursor,
                    order_item_id,
                )
                order_id = order_item["order_id"]

                OrderRepository._assert_order_editable_with_cursor(cursor, order_id)

                cursor.execute(
                    """
                    DELETE FROM order_item
                    WHERE id = %s
                    """,
                    (order_item_id,),
                )

                OrderRepository._recalculate_order_total_with_cursor(cursor, order_id)

                connection.commit()
        except Exception:
            connection.rollback()
            raise
        finally:
            connection.close()

    @staticmethod
    def cancel_order(order_id: int) -> None:
        """
        取消整个订单。

        Args:
            order_id: 订单 id
        """
        connection = DatabaseManager.get_connection()
        try:
            with connection.cursor() as cursor:
                OrderRepository._assert_order_editable_with_cursor(cursor, order_id)

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

                connection.commit()
        except Exception:
            connection.rollback()
            raise
        finally:
            connection.close()

    @staticmethod
    def recalculate_order_total(order_id: int) -> Decimal:
        """
        重新计算某个订单总价。

        Args:
            order_id: 订单 id

        Returns:
            Decimal: 重新计算后的订单总价
        """
        connection = DatabaseManager.get_connection()
        try:
            with connection.cursor() as cursor:
                total_amount = OrderRepository._recalculate_order_total_with_cursor(
                    cursor,
                    order_id,
                )
                connection.commit()
                return total_amount
        except Exception:
            connection.rollback()
            raise
        finally:
            connection.close()

    @staticmethod
    def get_orders_by_session(session_id: int) -> List[Dict[str, Any]]:
        """
        查询某次用餐的所有订单。

        Args:
            session_id: 用餐会话 id

        Returns:
            list[dict]: 订单列表
        """
        sql = """
        SELECT *
        FROM order_info
        WHERE session_id = %s
        ORDER BY created_at ASC
        """

        connection = DatabaseManager.get_connection()
        try:
            with connection.cursor() as cursor:
                cursor.execute(sql, (session_id,))
                return cursor.fetchall()
        finally:
            connection.close()

    @staticmethod
    def get_order_items(order_id: int) -> List[Dict[str, Any]]:
        """
        查询某个订单的菜品明细。

        Args:
            order_id: 订单 id

        Returns:
            list[dict]: 订单明细
        """
        sql = """
        SELECT oi.*,
               mi.item_name,
               mi.description,
               mi.image_path
        FROM order_item oi
        JOIN menu_item mi ON oi.item_id = mi.id
        WHERE oi.order_id = %s
        ORDER BY oi.id ASC
        """

        connection = DatabaseManager.get_connection()
        try:
            with connection.cursor() as cursor:
                cursor.execute(sql, (order_id,))
                return cursor.fetchall()
        finally:
            connection.close()

    @staticmethod
    def get_session_order_detail(session_id: int) -> List[Dict[str, Any]]:
        """
        查询某次用餐的完整点单明细。

        Args:
            session_id: 用餐会话 id

        Returns:
            list[dict]: 点单明细
        """
        sql = """
        SELECT o.id AS order_id,
               o.order_status,
               o.total_amount AS order_total_amount,
               o.created_at AS order_created_at,
               oi.id AS order_item_id,
               oi.item_id,
               mi.item_name,
               oi.quantity,
               oi.unit_price,
               oi.subtotal,
               oi.remark
        FROM order_info o
        JOIN order_item oi ON o.id = oi.order_id
        JOIN menu_item mi ON oi.item_id = mi.id
        WHERE o.session_id = %s
        ORDER BY o.created_at ASC, oi.id ASC
        """

        connection = DatabaseManager.get_connection()
        try:
            with connection.cursor() as cursor:
                cursor.execute(sql, (session_id,))
                return cursor.fetchall()
        finally:
            connection.close()

    @staticmethod
    def get_session_full_detail(session_id: int) -> Dict[str, Any]:
        """
        按 session 查询完整账单详情。

        返回内容包括：
        1. 用餐 session 信息
        2. 餐桌信息
        3. 所有订单
        4. 每个订单的菜品明细
        5. 支付记录
        6. 当前账单金额

        Args:
            session_id: 用餐会话 id

        Returns:
            dict: 完整账单详情
        """
        connection = DatabaseManager.get_connection()
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
                    raise ValueError(f"session_id 不存在: {session_id}")

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

                discount_amount = Decimal("0.00")
                final_amount = total_amount

                if payment:
                    discount_amount = Decimal(str(payment["discount_amount"]))
                    final_amount = Decimal(str(payment["final_amount"]))

                return {
                    "session": session,
                    "orders": orders,
                    "payment": payment,
                    "bill": {
                        "total_amount": total_amount,
                        "discount_amount": discount_amount,
                        "final_amount": final_amount,
                    },
                }
        finally:
            connection.close()

    @staticmethod
    def get_table_sessions_by_date(
        nav_point_name: str,
        date_str: str,
    ) -> List[Dict[str, Any]]:
        """
        查询某张桌子在某一天的所有用餐 session。

        Args:
            nav_point_name: 与导航模块一致的桌位点名，例如 table_1
            date_str: 日期字符串，例如 2026-05-27

        Returns:
            list[dict]: 用餐 session 列表
        """
        sql = """
        SELECT ts.*,
               rt.nav_point_name,
               rt.table_display_name
        FROM table_session ts
        JOIN restaurant_table rt ON ts.table_id = rt.id
        WHERE rt.nav_point_name = %s
          AND DATE(ts.started_at) = %s
        ORDER BY ts.started_at ASC
        """

        connection = DatabaseManager.get_connection()
        try:
            with connection.cursor() as cursor:
                cursor.execute(sql, (nav_point_name, date_str))
                return cursor.fetchall()
        finally:
            connection.close()

    @staticmethod
    def get_table_orders_by_date(
        nav_point_name: str,
        date_str: str,
    ) -> List[Dict[str, Any]]:
        """
        按桌号/导航点 + 日期查询完整历史订单明细。

        Args:
            nav_point_name: 与导航模块一致的桌位点名，例如 table_1
            date_str: 日期字符串，例如 2026-05-27

        Returns:
            list[dict]: 指定桌位当天所有订单明细
        """
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

        connection = DatabaseManager.get_connection()
        try:
            with connection.cursor() as cursor:
                cursor.execute(sql, (nav_point_name, date_str))
                return cursor.fetchall()
        finally:
            connection.close()

    @staticmethod
    def calculate_session_total(session_id: int) -> Decimal:
        """
        计算某次用餐的订单总额。

        Args:
            session_id: 用餐会话 id

        Returns:
            Decimal: 订单总额
        """
        sql = """
        SELECT COALESCE(SUM(total_amount), 0) AS total_amount
        FROM order_info
        WHERE session_id = %s
          AND order_status <> 'cancelled'
        """

        connection = DatabaseManager.get_connection()
        try:
            with connection.cursor() as cursor:
                cursor.execute(sql, (session_id,))
                row = cursor.fetchone()
                return Decimal(str(row["total_amount"]))
        finally:
            connection.close()

    @staticmethod
    def update_order_status(order_id: int, order_status: str) -> None:
        """
        更新订单状态。

        Args:
            order_id: 订单 id
            order_status: 新状态，例如 confirmed、cooking、served、finished、cancelled
        """
        sql = """
        UPDATE order_info
        SET order_status = %s,
            updated_at = CURRENT_TIMESTAMP
        WHERE id = %s
        """

        connection = DatabaseManager.get_connection()
        try:
            with connection.cursor() as cursor:
                cursor.execute(sql, (order_status, order_id))
                connection.commit()
        finally:
            connection.close()

    @staticmethod
    def _get_available_menu_item_with_cursor(cursor, item_id: int) -> Dict[str, Any]:
        """查询可售菜品。"""
        cursor.execute(
            """
            SELECT id, price, is_available
            FROM menu_item
            WHERE id = %s
            """,
            (item_id,),
        )
        menu_item = cursor.fetchone()

        if menu_item is None:
            raise ValueError(f"菜品不存在: item_id={item_id}")

        if not menu_item["is_available"]:
            raise ValueError(f"菜品当前不可售: item_id={item_id}")

        return menu_item

    @staticmethod
    def _get_order_item_for_update_with_cursor(cursor, order_item_id: int) -> Dict[str, Any]:
        """查询订单明细并加锁。"""
        cursor.execute(
            """
            SELECT *
            FROM order_item
            WHERE id = %s
            FOR UPDATE
            """,
            (order_item_id,),
        )
        order_item = cursor.fetchone()

        if order_item is None:
            raise ValueError(f"order_item_id 不存在: {order_item_id}")

        return order_item

    @staticmethod
    def _assert_order_editable_with_cursor(cursor, order_id: int) -> Dict[str, Any]:
        """
        检查订单是否允许修改。

        已取消、已完成、已结账或已关闭的订单不允许修改。
        """
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
            raise ValueError(f"order_id 不存在: {order_id}")

        if order["order_status"] in ("cancelled", "finished"):
            raise ValueError(f"当前订单状态不允许修改: {order['order_status']}")

        if order["session_status"] in ("paid", "closed", "cancelled"):
            raise ValueError(f"当前用餐状态不允许修改订单: {order['session_status']}")

        return order

    @staticmethod
    def _recalculate_order_total_with_cursor(cursor, order_id: int) -> Decimal:
        """
        使用当前 cursor 重新计算订单总额。
        """
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
