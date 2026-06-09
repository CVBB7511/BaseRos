# restaurant_voice_interaction 数据库联动版

## 一、模块说明

本模块是 ROS 1 Noetic 餐厅服务机器人语音点单模块，已经与餐厅数据库代码对接。

当前版本不再把订单保存到 `orders.json`，而是直接写入数据库：

- `table_session`
- `order_info`
- `order_item`
- `payment_record`
- `menu_item`
- `restaurant_table`

## 二、主要功能

支持：

1. 从数据库读取菜单。
2. 语音添加菜品。
3. 语音修改菜品数量。
4. 语音修改菜品备注。
5. 语音删除菜品。
6. 语音确认下单，并写入数据库。
7. 语音取消临时订单或取消数据库中最近订单。
8. 语音查询账单。
9. 语音结账，并写入 `payment_record`。
10. 结账后自动释放餐桌。
11. 可发布送餐任务到 `/restaurant/task_name`。

## 三、ROS Topic

| Topic | 类型 | 方向 | 功能 |
|---|---|---|---|
| `/speech_text` | `std_msgs/String` | 输入 | ASR 语音识别文本 |
| `/restaurant/current_table` | `std_msgs/String` | 输入 | 当前桌位，例如 `table_1` |
| `/robot_state` | `std_msgs/String` | 输入 | 机器人忙闲状态 |
| `/voice_cmd` | `std_msgs/String(JSON)` | 输出 | 结构化语音指令 |
| `/order_summary` | `std_msgs/String` | 输出 | 当前订单摘要 |
| `/tts_speak` | `std_msgs/String` | 输出 | TTS 播报文本 |
| `/voice_state` | `std_msgs/String` | 输出 | 语音模块状态 |
| `/seat_request` | `std_msgs/String(JSON)` | 输出 | 座位需求 |
| `/queue_request` | `std_msgs/String(JSON)` | 输出 | 等位需求 |
| `/restaurant/task_name` | `std_msgs/String` | 输出 | 送餐任务名，例如 `deliver_table_1` |

## 四、数据库配置

修改：

```text
config/database_config.yaml
```

示例：

```yaml
database:
  host: "127.0.0.1"
  port: 3306
  user: "robot_user"
  password: "your_password"
  database: "robot_db"
  charset: "utf8mb4"
```

该配置需要与数据库代码包中的 `src/config/database_config.py` 保持一致。

## 五、数据库前置要求

运行本语音模块前，请先完成数据库初始化：

```bash
python scripts/init_database.py
python scripts/import_table_data.py
python scripts/import_menu_data.py
```

数据库中需要存在：

```text
restaurant_table.nav_point_name = table_1 / table_2 / table_3 / table_4
menu_item
menu_category
table_session
order_info
order_item
payment_record
```

## 六、安装依赖

在 ROS 1 Noetic 环境中安装：

```bash
sudo apt update
sudo apt install python3-pymysql python3-yaml
```

也可以使用：

```bash
pip3 install pymysql pyyaml
```

## 七、放入工作空间

建议放到：

```text
~/catkin_ws/src/restaurant_voice_interaction
```

然后执行：

```bash
cd ~/catkin_ws
catkin_make
source devel/setup.bash
```

如有权限问题，执行：

```bash
chmod +x ~/catkin_ws/src/restaurant_voice_interaction/src/*.py
```

## 八、启动方式

默认 table_1：

```bash
roslaunch restaurant_voice_interaction voice_interaction.launch
```

指定 table_2：

```bash
roslaunch restaurant_voice_interaction voice_interaction.launch default_table:=table_2
```

## 九、测试方式

另开终端：

```bash
source ~/catkin_ws/devel/setup.bash
rostopic echo /tts_speak
```

再开一个终端发布语音文本：

```bash
rostopic pub -1 /speech_text std_msgs/String "data: '看看菜单'"
rostopic pub -1 /speech_text std_msgs/String "data: '牛肉面两份少辣'"
rostopic pub -1 /speech_text std_msgs/String "data: '可乐一份'"
rostopic pub -1 /speech_text std_msgs/String "data: '确认下单'"
rostopic pub -1 /speech_text std_msgs/String "data: '算一下多少钱'"
rostopic pub -1 /speech_text std_msgs/String "data: '结账'"
```

切换桌位：

```bash
rostopic pub -1 /speech_text std_msgs/String "data: '我是二号桌'"
```

或：

```bash
rostopic pub -1 /restaurant/current_table std_msgs/String "data: 'table_2'"
```

## 十、支持的语音示例

### 菜单

```text
看看菜单
有什么菜
推荐一下
```

### 下单

```text
牛肉面两份
蛋炒饭一份
炸鸡块一份少辣
可乐两份
```

### 修改临时订单

```text
牛肉面改成三份
炸鸡块改成不要辣
删除可乐
```

### 确认下单

```text
确认下单
提交订单
确认订单
```

### 修改数据库中已确认但未结账订单

```text
牛肉面改成一份
删除炸鸡块
可乐改成不要冰
```

说明：如果当前没有临时订单，这些修改会作用于当前桌位未结账 session 中最近的可编辑订单。

### 账单与结账

```text
算一下多少钱
账单
结账
买单
付款
```

### 送餐

```text
开始送餐
送餐模式
```

系统会根据当前桌位发布：

```text
table_1 -> deliver_table_1
table_2 -> deliver_table_2
table_3 -> deliver_table_3
table_4 -> deliver_table_4
```

到：

```text
/restaurant/task_name
```

## 十一、与数据库表的匹配关系

| 语音功能 | 数据库表 |
|---|---|
| 当前桌位 | `restaurant_table` |
| 当前用餐 | `table_session` |
| 菜单读取 | `menu_category`, `menu_item` |
| 确认下单 | `order_info`, `order_item` |
| 修改订单 | `order_info`, `order_item` |
| 查询账单 | `order_info`, `order_item` |
| 结账 | `payment_record`, `table_session`, `restaurant_table` |

## 十二、当前版本边界

本模块负责：

1. 语音文本解析。
2. 菜单查询。
3. 临时订单维护。
4. 数据库下单。
5. 数据库订单修改。
6. 数据库结账。
7. TTS 文本输出。
8. 送餐任务名发布。

本模块不负责：

1. 真实语音识别 ASR。
2. 真实语音合成 TTS。
3. 真实支付扣款。
4. 导航路径规划。
5. 菜品制作流程。
6. 触控屏界面。
