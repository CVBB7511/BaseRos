机器人餐厅数据库代码说明

一、版本说明

当前版本文件名：

robot_restaurant_database_code_order_complete.zip

本版本是在“数据库代码接口命名已与导航定位模块统一”的基础上继续补充完成的版本。

本版本重点补充了订单相关功能，包括：

1. 顾客下单
2. 顾客加菜
3. 顾客修改订单明细
4. 顾客删除订单中的某道菜
5. 顾客取消整个订单
6. 自动重新计算订单金额
7. 顾客结账结算
8. 按 session 查询完整账单详情
9. 按 table_1、table_2 等导航点名称查询某天历史订单
10. 按 table_1、table_2 等导航点名称查询某天历史账单结果


二、当前版本已经支持的主要功能

1. 机器人相关数据

支持：

- 机器人状态记录
- 机器人任务记录
- 机器人日志记录
- 机器人 /odom 位置信息写入数据库示例

对应文件：

src/database/repositories/robot_status_repository.py
src/database/repositories/robot_task_repository.py
src/database/repositories/robot_log_repository.py
src/navigation/odom_to_mysql.py


2. 餐厅地图管理

支持：

- 保存餐厅地图名称
- 保存餐厅地图版本
- 保存地图文件路径
- 查询当前启用地图
- 切换当前启用地图
- 更新地图信息

对应文件：

src/database/repositories/restaurant_map_repository.py


3. 餐桌管理

支持：

- 新增餐桌
- 查询所有餐桌
- 按导航点名称查询餐桌
- 更新餐桌状态
- 更新餐桌位置

统一命名后，餐桌名称与导航定位模块一致：

table_1
table_2
table_3
table_4

对应文件：

src/database/repositories/restaurant_table_repository.py


4. 菜单管理

支持：

- 新增菜单分类
- 查询菜单分类
- 新增菜品
- 查询全部菜品
- 按分类查询菜品
- 修改菜品价格
- 修改菜品是否可售

对应文件：

src/database/repositories/menu_repository.py


5. 餐桌用餐会话管理

支持：

- 开始一桌用餐
- 查询某桌当前用餐 session
- 按 session_id 查询用餐记录
- 关闭用餐 session
- 查询某桌历史用餐记录

说明：

同一张桌子在不同时间会产生不同 session_id。
订单和结账记录都绑定在 session_id 上，因此可以区分同一桌不同时间的历史订单。

对应文件：

src/database/repositories/table_session_repository.py


6. 订单管理

支持：

- 创建订单
- 同一桌多次加菜
- 查询某次用餐的所有订单
- 查询某个订单的菜品明细
- 查询某次用餐完整点单明细
- 修改订单中某道菜的数量
- 修改订单中某道菜的备注
- 删除订单中某道菜
- 向已有订单追加菜品
- 取消整个订单
- 重新计算订单总价
- 按 session 查询完整账单详情
- 按桌位导航点名称 + 日期查询完整历史订单

对应文件：

src/database/repositories/order_repository.py


7. 结账管理

支持：

- 自动计算账单总价
- 支持优惠金额
- 生成支付记录
- 结账后自动释放餐桌
- 结账后自动将订单状态改为 finished
- 按 session 查询支付记录
- 按 session 查询完整账单详情
- 按餐桌 id 查询历史结账记录
- 按导航点名称查询某桌历史结账记录
- 按导航点名称 + 日期查询某桌某天账单结果
- 查询某天总营业额

对应文件：

src/database/repositories/payment_repository.py


三、当前版本新增或重点增强的接口

文件位置：

src/database/repositories/order_repository.py

新增或增强接口：

1. create_order(session_id, items)

功能：

创建订单，并保存订单明细。

示例：

OrderRepository.create_order(
    session_id=session_id,
    items=[
        {"item_id": 1, "quantity": 2, "remark": "少辣"},
        {"item_id": 3, "quantity": 1}
    ],
)


2. add_order_item(order_id, item_id, quantity=1, remark=None)

功能：

向已有订单中追加一道菜。

示例：

OrderRepository.add_order_item(
    order_id=order_id,
    item_id=3,
    quantity=1,
    remark="正常"
)


3. update_order_item_quantity(order_item_id, quantity)

功能：

修改某个订单明细的菜品数量。

示例：

OrderRepository.update_order_item_quantity(
    order_item_id=order_item_id,
    quantity=2
)


4. update_order_item_remark(order_item_id, remark)

功能：

修改某个订单明细的备注。

示例：

OrderRepository.update_order_item_remark(
    order_item_id=order_item_id,
    remark="不要香菜"
)


5. remove_order_item(order_item_id)

功能：

删除订单中的某一道菜。

示例：

OrderRepository.remove_order_item(order_item_id)


6. cancel_order(order_id)

功能：

取消整个订单。

示例：

OrderRepository.cancel_order(order_id)


7. recalculate_order_total(order_id)

功能：

重新计算订单总价。

说明：

修改菜品数量、删除菜品、追加菜品后，系统会自动重新计算订单金额。
这个接口也可以手动调用。

示例：

OrderRepository.recalculate_order_total(order_id)


8. get_session_full_detail(session_id)

功能：

按 session 查询完整账单详情。

返回内容包括：

- session 信息
- 餐桌信息
- 所有订单
- 每个订单的菜品明细
- 支付记录
- 当前账单金额

示例：

detail = OrderRepository.get_session_full_detail(session_id)


9. get_table_sessions_by_date(nav_point_name, date_str)

功能：

查询某张桌子某一天的所有用餐 session。

示例：

sessions = OrderRepository.get_table_sessions_by_date(
    nav_point_name="table_1",
    date_str="2026-05-27"
)


10. get_table_orders_by_date(nav_point_name, date_str)

功能：

按桌位导航点名称 + 日期查询完整历史订单明细。

示例：

orders = OrderRepository.get_table_orders_by_date(
    nav_point_name="table_1",
    date_str="2026-05-27"
)


四、结账接口说明

文件位置：

src/database/repositories/payment_repository.py

重点接口：

1. calculate_bill(session_id, discount_amount=0)

功能：

计算账单金额。

返回：

- total_amount：订单总金额
- discount_amount：优惠金额
- final_amount：最终实付金额

示例：

bill = PaymentRepository.calculate_bill(
    session_id=session_id,
    discount_amount=5
)


2. create_payment(session_id, payment_method="cash", discount_amount=0)

功能：

创建支付记录并完成结账。

结账时会自动执行：

- 计算订单总价
- 写入 payment_record
- 将 table_session 状态改为 paid
- 将对应餐桌状态改为 available
- 将订单状态改为 finished

示例：

payment_id = PaymentRepository.create_payment(
    session_id=session_id,
    payment_method="wechat",
    discount_amount=5
)


3. get_session_bill_detail(session_id)

功能：

按 session 查询完整账单详情。

示例：

detail = PaymentRepository.get_session_bill_detail(session_id)


4. get_table_payment_history_by_nav_point(nav_point_name, limit=50)

功能：

按导航点名称查询某桌历史结账记录。

示例：

history = PaymentRepository.get_table_payment_history_by_nav_point(
    nav_point_name="table_1"
)


5. get_table_bill_by_date(nav_point_name, date_str)

功能：

按桌位导航点名称 + 日期查询历史账单结果。

示例：

bills = PaymentRepository.get_table_bill_by_date(
    nav_point_name="table_1",
    date_str="2026-05-27"
)


6. get_daily_income(date_str)

功能：

查询某一天餐厅总营业额。

示例：

income = PaymentRepository.get_daily_income("2026-05-27")


五、订单修改规则

当前版本对订单修改做了限制，避免结账后数据被误改。

允许修改的情况：

1. 用餐 session 仍处于 dining 状态。
2. 订单没有被 cancelled。
3. 订单没有被 finished。
4. 餐桌还没有结账。

不允许修改的情况：

1. table_session 状态为 paid。
2. table_session 状态为 closed。
3. table_session 状态为 cancelled。
4. order_info 状态为 finished。
5. order_info 状态为 cancelled。

也就是说：

顾客还没结账前，可以修改订单。
顾客结账后，不允许继续修改订单。


六、按桌位和日期查询历史订单

由于代码接口命名已经和导航定位模块统一，餐桌统一使用：

table_1
table_2
table_3
table_4

而不是：

T01
T02
T03
T04

查询 table_1 在某一天的完整订单：

OrderRepository.get_table_orders_by_date(
    nav_point_name="table_1",
    date_str="2026-05-27"
)

返回内容包括：

- nav_point_name
- table_display_name
- session_id
- session_code
- customer_count
- session_status
- started_at
- ended_at
- order_id
- order_status
- order_total_amount
- order_created_at
- order_item_id
- item_id
- item_name
- quantity
- unit_price
- subtotal
- remark
- payment_id
- payment_total_amount
- discount_amount
- final_amount
- payment_method
- payment_status
- paid_at


七、按桌位和日期查询历史账单

查询 table_1 在某一天的账单结果：

PaymentRepository.get_table_bill_by_date(
    nav_point_name="table_1",
    date_str="2026-05-27"
)

适合用于餐厅日后查询：

1. 某张桌子某一天来了几批客人。
2. 每批客人从几点吃到几点。
3. 每次用餐订单总额是多少。
4. 每次用餐是否已结账。
5. 每次用餐优惠了多少钱。
6. 每次用餐最终实收多少钱。
7. 每次用餐使用了什么支付方式。


八、完整业务流程示例

1. 查询餐桌

table = RestaurantTableRepository.get_table_by_nav_point("table_1")


2. 开始用餐

session_id = TableSessionRepository.start_session(
    table_id=table["id"],
    customer_count=2
)


3. 查询菜单

menu_items = MenuRepository.get_all_menu_items(only_available=True)


4. 顾客下单

order_id = OrderRepository.create_order(
    session_id=session_id,
    items=[
        {"item_id": menu_items[0]["id"], "quantity": 1, "remark": "少辣"},
        {"item_id": menu_items[1]["id"], "quantity": 1}
    ]
)


5. 顾客修改数量

order_items = OrderRepository.get_order_items(order_id)

OrderRepository.update_order_item_quantity(
    order_item_id=order_items[0]["id"],
    quantity=2
)


6. 顾客修改备注

OrderRepository.update_order_item_remark(
    order_item_id=order_items[0]["id"],
    remark="不要香菜"
)


7. 顾客删除某道菜

OrderRepository.remove_order_item(order_items[1]["id"])


8. 顾客追加菜品

OrderRepository.add_order_item(
    order_id=order_id,
    item_id=menu_items[2]["id"],
    quantity=1,
    remark="正常"
)


9. 查询完整账单

detail = OrderRepository.get_session_full_detail(session_id)


10. 结账

payment_id = PaymentRepository.create_payment(
    session_id=session_id,
    payment_method="wechat",
    discount_amount=0
)


11. 查询历史订单

orders = OrderRepository.get_table_orders_by_date(
    nav_point_name="table_1",
    date_str="2026-05-27"
)


12. 查询历史账单

bills = PaymentRepository.get_table_bill_by_date(
    nav_point_name="table_1",
    date_str="2026-05-27"
)


九、测试脚本

本版本新增测试脚本：

scripts/test_order_modify_and_history.py

运行前需要先执行：

python scripts/init_database.py
python scripts/import_table_data.py
python scripts/import_menu_data.py

然后执行：

python scripts/test_order_modify_and_history.py

该测试脚本会自动测试：

1. 查询 table_1。
2. 开始用餐 session。
3. 创建订单。
4. 修改订单明细数量。
5. 修改订单明细备注。
6. 删除订单中的一道菜。
7. 追加一道菜。
8. 查询 session 完整账单详情。
9. 按 table_1 + 今天日期查询完整历史订单。
10. 结账。
11. 按 table_1 + 今天日期查询历史账单结果。


十、推荐运行顺序

第一次使用本版本时，建议执行：

pip install -r requirements.txt
python scripts/init_database.py
python scripts/import_table_data.py
python scripts/import_menu_data.py
python scripts/update_map_version.py
python scripts/test_database_insert.py
python scripts/test_restaurant_business_flow.py
python scripts/test_order_modify_and_history.py


十一、当前版本与上一版区别

上一版已经支持：

- 顾客下单
- 顾客加菜
- 自动计算账单
- 结账
- 查询某桌历史支付记录
- 查询某天总营业额

当前 order_complete 版本新增：

- 修改订单明细数量
- 修改订单明细备注
- 删除订单中的某道菜
- 向已有订单追加菜品
- 取消整个订单
- 修改后自动重新计算订单金额
- 按 session 查询完整账单详情
- 按 table_1 + 日期查询完整历史订单
- 按 table_1 + 日期查询历史账单结果


十二、当前版本是否满足订单业务需求

当前版本已经可以满足以下需求：

1. 顾客下单：支持。
2. 顾客加菜：支持。
3. 顾客修改订单：支持。
4. 顾客删除某道菜：支持。
5. 顾客取消订单：支持。
6. 结账结算：支持。
7. 结账后释放餐桌：支持。
8. 餐厅日后查询某桌某天订单结果：支持。
9. 餐厅日后查询某桌某天账单结果：支持。
10. 查询某天总营业额：支持。

注意：

当前版本的支付功能只是系统内部记录支付结果，不是真实接入微信、支付宝或银行卡支付平台。


十三、模块边界

本版本负责：

1. 订单数据保存。
2. 订单明细修改。
3. 订单金额重算。
4. 账单计算。
5. 支付记录保存。
6. 历史订单查询。
7. 历史账单查询。

本版本不负责：

1. 真实支付扣款。
2. 语音识别。
3. 触控屏界面。
4. 菜品制作流程。
5. 机器人导航控制。
6. 顾客身份识别。
7. 会员系统。
8. 优惠券系统。

后续如果需要继续扩展会员、优惠券、库存、菜品销量统计，可以继续在以下文件夹中补充：

src/database/models/
src/database/repositories/
scripts/create_tables.sql


十四、最终说明

robot_restaurant_database_code_order_complete.zip 是目前较完整的餐厅订单数据库版本。

它已经可以支撑机器人餐厅系统中的主要订单数据流程：

顾客入座
开始用餐
查看菜单
下单
加菜
修改订单
删除菜品
计算账单
结账
释放餐桌
查询同一桌历史订单
查询同一桌历史账单
查询每日营业额

当前系统采用主控集中调度架构。上层的 robot_controller、voice_interaction_node、order_manager、database_order_adapter 等模块不需要直接编写 SQL，只需要调用 src/database/repositories/ 中的接口即可。迎宾带位和送餐任务由主控模块创建并写入任务记录，点餐、订单和结账流程由语音交互模块与订单管理模块调用数据库接口完成。
