"""
订单修改与历史查询测试脚本。

运行方式：
python scripts/test_order_modify_and_history.py

测试内容：
1. 查询 table_1
2. 开始用餐 session
3. 创建订单
4. 修改订单明细数量
5. 修改订单明细备注
6. 删除订单中的一道菜
7. 追加一道菜
8. 查询 session 完整账单详情
9. 按 table_1 + 今天日期查询完整历史订单
10. 结账
11. 按 table_1 + 今天日期查询历史账单结果

运行前请先执行：
python scripts/init_database.py
python scripts/import_table_data.py
python scripts/import_menu_data.py
"""

from datetime import date
from pathlib import Path
import sys

PROJECT_ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(PROJECT_ROOT))

from src.database.repositories.restaurant_table_repository import RestaurantTableRepository  # noqa: E402
from src.database.repositories.table_session_repository import TableSessionRepository  # noqa: E402
from src.database.repositories.menu_repository import MenuRepository  # noqa: E402
from src.database.repositories.order_repository import OrderRepository  # noqa: E402
from src.database.repositories.payment_repository import PaymentRepository  # noqa: E402


def main() -> None:
    """测试订单修改与历史查询能力。"""
    nav_point_name = "table_1"
    today = date.today().isoformat()

    table = RestaurantTableRepository.get_table_by_nav_point(nav_point_name)
    if table is None:
        raise RuntimeError("请先运行 python scripts/import_table_data.py")

    menu_items = MenuRepository.get_all_menu_items(only_available=True)
    if len(menu_items) < 3:
        raise RuntimeError("请先运行 python scripts/import_menu_data.py，并至少准备三个菜品")

    session_id = TableSessionRepository.start_session(
        table_id=table["id"],
        customer_count=2,
    )
    print(f"开始用餐 session_id: {session_id}")

    order_id = OrderRepository.create_order(
        session_id=session_id,
        items=[
            {"item_id": menu_items[0]["id"], "quantity": 1, "remark": "少辣"},
            {"item_id": menu_items[1]["id"], "quantity": 1},
        ],
    )
    print(f"创建订单 order_id: {order_id}")

    order_items = OrderRepository.get_order_items(order_id)
    first_order_item_id = order_items[0]["id"]
    second_order_item_id = order_items[1]["id"]

    OrderRepository.update_order_item_quantity(first_order_item_id, 2)
    print(f"已将订单明细 {first_order_item_id} 的数量改为 2")

    OrderRepository.update_order_item_remark(first_order_item_id, "不要香菜")
    print(f"已修改订单明细 {first_order_item_id} 的备注")

    OrderRepository.remove_order_item(second_order_item_id)
    print(f"已删除订单明细 {second_order_item_id}")

    added_item_id = OrderRepository.add_order_item(
        order_id=order_id,
        item_id=menu_items[2]["id"],
        quantity=1,
        remark="正常",
    )
    print(f"已追加订单明细 {added_item_id}")

    full_detail = OrderRepository.get_session_full_detail(session_id)
    print("按 session 查询完整账单详情：")
    print(full_detail)

    table_orders_today = OrderRepository.get_table_orders_by_date(
        nav_point_name=nav_point_name,
        date_str=today,
    )
    print(f"{nav_point_name} 今天的完整历史订单：")
    for row in table_orders_today:
        print(row)

    payment_id = PaymentRepository.create_payment(
        session_id=session_id,
        payment_method="wechat",
        discount_amount=0,
    )
    print(f"结账完成 payment_id: {payment_id}")

    bill_detail = PaymentRepository.get_session_bill_detail(session_id)
    print("结账后的 session 完整账单详情：")
    print(bill_detail)

    table_bill_today = PaymentRepository.get_table_bill_by_date(
        nav_point_name=nav_point_name,
        date_str=today,
    )
    print(f"{nav_point_name} 今天的历史账单结果：")
    for row in table_bill_today:
        print(row)


if __name__ == "__main__":
    main()
