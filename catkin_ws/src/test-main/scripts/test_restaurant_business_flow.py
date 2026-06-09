"""
餐厅业务流程测试脚本。

运行方式：
python scripts/test_restaurant_business_flow.py

测试流程：
1. 查询 1 号桌
2. 开始用餐 session
3. 查询菜单
4. 创建订单
5. 查询点单明细
6. 计算账单
7. 结账
8. 查询该桌历史结账记录

运行前请先执行：
python scripts/init_database.py
python scripts/import_table_data.py
python scripts/import_menu_data.py
"""

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
    """测试完整餐厅业务流程。"""
    table = RestaurantTableRepository.get_table_by_nav_point("table_1")
    if table is None:
        raise RuntimeError("请先运行 python scripts/import_table_data.py")

    session_id = TableSessionRepository.start_session(
        table_id=table["id"],
        customer_count=2,
    )
    print(f"开始用餐 session_id: {session_id}")

    menu_items = MenuRepository.get_all_menu_items(only_available=True)
    if len(menu_items) < 2:
        raise RuntimeError("请先运行 python scripts/import_menu_data.py，并至少准备两个菜品")

    order_id = OrderRepository.create_order(
        session_id=session_id,
        items=[
            {"item_id": menu_items[0]["id"], "quantity": 2, "remark": "少辣"},
            {"item_id": menu_items[1]["id"], "quantity": 1},
        ],
    )
    print(f"创建订单 order_id: {order_id}")

    order_detail = OrderRepository.get_session_order_detail(session_id)
    print("本次用餐点单明细:")
    for row in order_detail:
        print(row)

    bill = PaymentRepository.calculate_bill(session_id, discount_amount=5)
    print(f"账单金额: {bill}")

    payment_id = PaymentRepository.create_payment(
        session_id=session_id,
        payment_method="wechat",
        discount_amount=5,
    )
    print(f"结账完成 payment_id: {payment_id}")

    history = PaymentRepository.get_table_payment_history(table["id"])
    print("该桌历史结账记录:")
    for row in history:
        print(row)


if __name__ == "__main__":
    main()
