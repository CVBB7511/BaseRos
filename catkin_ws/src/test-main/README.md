# 餐厅服务机器人项目

## 一、项目目标

本项目面向餐厅服务机器人场景，实现迎宾带位、语音点餐、送餐提醒、任务调度、导航执行、数据库记录和异常处理等功能。系统以 ROS 1 Noetic 为运行基础，通过语音交互模块、主控模块、任务调度模块、导航管理模块和数据库模块之间的协作，完成餐厅服务机器人的主要业务流程。

当前版本采用主控集中调度架构，不再单独维护 welcome_mode、order_mode、delivery_mode 三个独立模式目录。系统仍然支持迎宾带位、点餐和送餐三类服务模式，但服务模式由 `robot_controller.py` 统一协调。

## 二、当前系统架构

当前系统主链路如下：

```text
voice_interaction_node
  ↓ /voice_cmd
robot_controller
  ↓ /restaurant/task_name
task_dispatcher
  ↓ /restaurant/nav_target
navigation_manager
  ↓ /restaurant/nav_status
task_dispatcher
  ↓ /restaurant/task_status
robot_controller / voice_interaction_node



语音交互模块：
负责接收语音识别结果，解析用户指令，完成菜单展示、点餐、修改订单、取消订单、结账等点餐相关业务，并通过 /voice_cmd 向主控模块发布标准化指令。

主控模块：
负责统一接收 /voice_cmd，根据语音意图创建迎宾带位任务或送餐任务，维护当前餐桌状态，记录任务日志，并向任务调度模块发布 /restaurant/task_name。

任务调度模块：
负责将 guide_table_1、deliver_table_1 等业务任务拆解为具体导航点序列，并逐步向导航管理模块发布 /restaurant/nav_target。

导航管理模块：
负责根据导航点名称执行导航。在真实或仿真环境中调用 move_base；在测试环境中可启用 mock_navigation 模拟导航到达。

数据库模块：
负责记录机器人状态、任务、日志、餐桌、用餐 session、菜单、订单和支付记录，为系统运行和测试追溯提供数据支撑。

docs/                         项目文档，包括 SDP、SRS、SDD、STD/STR
records/                      项目过程记录、会议记录、GitLab 管理记录
slides/                       阶段评审和最终汇报 PPT

src/                          系统源代码
src/config/                   系统配置、地图配置、数据库配置和统一接口命名
src/core/                     主控与任务调度模块，包括 robot_controller.py、task_dispatcher.py
src/navigation/               导航管理模块，包括 navigation_manager.py、odom_to_mysql.py
src/interaction/              语音交互模块，包括语音输入、语音输出、点餐管理和订单适配
src/database/                 数据库管理模块
src/database/models/          数据模型定义
src/database/repositories/    数据访问层
src/exception/                异常处理与事件日志预留目录
src/utils/                    通用工具函数

test/                         测试代码
test/unit/                    单元测试
test/integration/             集成测试
test/system/                  系统测试

data/                         数据资源，包括地图、菜单、示例数据等
data/maps/                    用于存放餐厅地图相关资源
data/menu/                    用于存放餐厅菜单数据
data/samples/                 用于存放餐厅样例数据

scripts/                      初始化脚本、数据导入脚本、系统启动文件和演示测试脚本
