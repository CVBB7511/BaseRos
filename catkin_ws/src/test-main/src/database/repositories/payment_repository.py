"""
结账 Repository。

主要负责：
1. 计算账单
2. 生成支付记录
3. 查询某次用餐的支付记录
4. 查询某次用餐的完整账单详情
5. 查询某桌历史消费记录
6. 按桌号/导航点 + 日期查询账单结果
"""

from decimal import Decimal
from typing import Optional, Dict, Any, List

from src.database.database_manager import DatabaseManager


class PaymentRepository:
    """支付结账数据访问层。"""

    @staticmethod
    def calculate_bill(session_id: int, discount_amount=0) -> Dict[str, Decimal]:
        """
        计算账单金额。

        Args:
            session_id: 用餐会话 id
            discount_amount: 优惠金额

        Returns:
            dict: total_amount、discount_amount、final_amount
        """
        connection = DatabaseManager.get_connection()
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

    @staticmethod
    def create_payment(
        session_id: int,
        payment_method: str = "cash",
        discount_amount=0,
    ) -> int:
        """
        创建支付记录。

        会自动：
        1. 计算总价
        2. 写入 payment_record
        3. 将 table_session 状态改为 paid
        4. 将对应餐桌状态改为 available
        5. 将订单状态改为 finished

        Args:
            session_id: 用餐会话 id
            payment_method: 支付方式，例如 cash、wechat、alipay、card
            discount_amount: 优惠金额

        Returns:
            int: 支付记录 id
        """
        connection = DatabaseManager.get_connection()
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
                    raise ValueError(f"session_id 不存在: {session_id}")

                if session["status"] in ("paid", "closed", "cancelled"):
                    raise ValueError(f"当前用餐状态不允许重复结账: {session['status']}")

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

    @staticmethod
    def get_payment_by_session(session_id: int) -> Optional[Dict[str, Any]]:
        """
        查询某次用餐的支付记录。

        Args:
            session_id: 用餐会话 id

        Returns:
            dict | None: 支付记录
        """
        sql = """
        SELECT *
        FROM payment_record
        WHERE session_id = %s
        ORDER BY paid_at DESC
        LIMIT 1
        """

        connection = DatabaseManager.get_connection()
        try:
            with connection.cursor() as cursor:
                cursor.execute(sql, (session_id,))
                return cursor.fetchone()
        finally:
            connection.close()

    @staticmethod
    def get_session_bill_detail(session_id: int) -> Dict[str, Any]:
        """
        按 session 查询完整账单详情。

        Args:
            session_id: 用餐会话 id

        Returns:
            dict: session、orders、payment、bill
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
    def get_table_payment_history(table_id: int, limit: int = 50) -> List[Dict[str, Any]]:
        """
        查询某桌历史结账记录。

        Args:
            table_id: 餐桌 id
            limit: 查询数量限制

        Returns:
            list[dict]: 历史结账记录
        """
        sql = """
        SELECT rt.nav_point_name,
               rt.table_display_name,
               ts.id AS session_id,
               ts.session_code,
               ts.started_at,
               ts.ended_at,
               pr.total_amount,
               pr.discount_amount,
               pr.final_amount,
               pr.payment_method,
               pr.paid_at
        FROM payment_record pr
        JOIN table_session ts ON pr.session_id = ts.id
        JOIN restaurant_table rt ON ts.table_id = rt.id
        WHERE ts.table_id = %s
        ORDER BY pr.paid_at DESC
        LIMIT %s
        """

        connection = DatabaseManager.get_connection()
        try:
            with connection.cursor() as cursor:
                cursor.execute(sql, (table_id, limit))
                return cursor.fetchall()
        finally:
            connection.close()

    @staticmethod
    def get_table_payment_history_by_nav_point(
        nav_point_name: str,
        limit: int = 50,
    ) -> List[Dict[str, Any]]:
        """
        按导航点名称查询某桌历史结账记录。

        Args:
            nav_point_name: 与导航模块一致的桌位点名，例如 table_1
            limit: 查询数量限制

        Returns:
            list[dict]: 历史结账记录
        """
        sql = """
        SELECT rt.nav_point_name,
               rt.table_display_name,
               ts.id AS session_id,
               ts.session_code,
               ts.started_at,
               ts.ended_at,
               pr.total_amount,
               pr.discount_amount,
               pr.final_amount,
               pr.payment_method,
               pr.paid_at
        FROM payment_record pr
        JOIN table_session ts ON pr.session_id = ts.id
        JOIN restaurant_table rt ON ts.table_id = rt.id
        WHERE rt.nav_point_name = %s
        ORDER BY pr.paid_at DESC
        LIMIT %s
        """

        connection = DatabaseManager.get_connection()
        try:
            with connection.cursor() as cursor:
                cursor.execute(sql, (nav_point_name, limit))
                return cursor.fetchall()
        finally:
            connection.close()

    @staticmethod
    def get_table_bill_by_date(
        nav_point_name: str,
        date_str: str,
    ) -> List[Dict[str, Any]]:
        """
        按桌号/导航点 + 日期查询历史账单结果。

        Args:
            nav_point_name: 与导航模块一致的桌位点名，例如 table_1
            date_str: 日期字符串，例如 2026-05-27

        Returns:
            list[dict]: 指定桌位当天每次用餐的账单结果
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
               COALESCE(SUM(CASE
                   WHEN o.order_status <> 'cancelled' THEN o.total_amount
                   ELSE 0
               END), 0) AS order_total_amount,
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
        LEFT JOIN payment_record pr ON pr.session_id = ts.id
        WHERE rt.nav_point_name = %s
          AND DATE(ts.started_at) = %s
        GROUP BY rt.nav_point_name,
                 rt.table_display_name,
                 ts.id,
                 ts.session_code,
                 ts.customer_count,
                 ts.status,
                 ts.started_at,
                 ts.ended_at,
                 pr.id,
                 pr.total_amount,
                 pr.discount_amount,
                 pr.final_amount,
                 pr.payment_method,
                 pr.payment_status,
                 pr.paid_at
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
    def get_daily_income(date_str: str) -> Dict[str, Any]:
        """
        查询某一天营业额。

        Args:
            date_str: 日期字符串，例如 2026-05-27

        Returns:
            dict: 支付次数和总营业额
        """
        sql = """
        SELECT COUNT(*) AS payment_count,
               COALESCE(SUM(final_amount), 0) AS income
        FROM payment_record
        WHERE DATE(paid_at) = %s
          AND payment_status = 'paid'
        """

        connection = DatabaseManager.get_connection()
        try:
            with connection.cursor() as cursor:
                cursor.execute(sql, (date_str,))
                return cursor.fetchone()
        finally:
            connection.close()
