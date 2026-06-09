"""
餐厅业务数据库集成测试示例。
"""

from src.database.repositories.restaurant_table_repository import RestaurantTableRepository
from src.database.repositories.table_session_repository import TableSessionRepository
from src.database.repositories.menu_repository import MenuRepository
from src.database.repositories.order_repository import OrderRepository
from src.database.repositories.payment_repository import PaymentRepository


def test_restaurant_business_flow():
    table = RestaurantTableRepository.get_table_by_nav_point("table_1")
    menu_items = MenuRepository.get_all_menu_items(only_available=True)

    assert table is not None
    assert len(menu_items) >= 1

    session_id = TableSessionRepository.start_session(table["id"], customer_count=1)

    order_id = OrderRepository.create_order(
        session_id=session_id,
        items=[
            {
                "item_id": menu_items[0]["id"],
                "quantity": 1,
            }
        ],
    )

    assert order_id > 0

    bill = PaymentRepository.calculate_bill(session_id)
    assert bill["total_amount"] >= 0

    payment_id = PaymentRepository.create_payment(session_id, payment_method="cash")
    assert payment_id > 0
