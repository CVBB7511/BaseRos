# 验证脚本总览

本文记录需要直接使用的验证脚本，以及启动后的人工验收流程。辅助脚本 `build_workspace.sh`、`open_ros_terminal.sh`、`start_rosbridge.sh`、`start_frontend.sh` 通常不需要单独运行。

## 脚本列表

| 脚本 | 用途 | 典型场景 |
| --- | --- | --- |
| `scripts/verify_sim_mapping.sh` | 仿真手工建图 | 只验证 gmapping、Gazebo、键盘控制和地图保存 |
| `scripts/verify_sim_navigation.sh` | 仿真静态地图导航 | 用已有地图验证 AMCL、move_base 和导航 action |
| `scripts/verify_frontend_collab.sh` | 仿真 + 前端联调 | 课程验收前最常用的完整流程 |
| `scripts/verify_real_frontend_collab.sh` | 实机 + 前端联调 | 实验室机器人验收 |

## 仿真建图

```bash
cd BaseRos
bash scripts/verify_sim_mapping.sh
```

脚本会编译工作空间，启动 `se_map/manual_mapping.launch sim:=true keyboard:=true`，再启动键盘控制终端。

人工验收：

1. 等待 Gazebo 中机器人和地图环境加载完成。
2. 在键盘控制终端用 `w/s/a/d/q/e` 小幅移动机器人，空格刹车。
3. 观察 `/map` 是否持续更新。
4. 按 `m` 或调用 `/se_map/save_map` 保存地图。
5. 确认 `catkin_ws/src/se_map/maps/` 下生成 `.yaml` 和 `.pgm`。

## 仿真导航

```bash
cd BaseRos
bash scripts/verify_sim_navigation.sh catkin_ws/src/se_map/maps/saved_map.yaml
```

如果未传入地图或地图不存在，脚本会临时使用 `wpr_simulation/maps/map.yaml`。脚本启动导航栈后会自动发送一个短距离目标：

```bash
rosrun se_navigation send_navigation_goal.py --goal-x 0.6 --goal-y 0.0 --timeout 90
```

人工验收：

1. 确认 RViz 或终端中 move_base、AMCL 没有持续报错。
2. 确认机器人开始向短距离目标移动。
3. 观察 action 结果是否返回成功或合理失败原因。

## 仿真前端联调

```bash
cd BaseRos
bash scripts/verify_frontend_collab.sh
```

脚本会打开多个终端：

1. Gazebo 仿真。
2. gmapping 建图和地图服务。
3. 键盘控制。
4. rosbridge。
5. live-map 导航栈。
6. 前端开发服务器。

人工验收流程：

1. 浏览器打开 `http://localhost:5173/`。
2. 前端连接 `ws://localhost:9090`。
3. 确认前端能看到地图、机器人位置和雷达点。
4. 在键盘控制终端移动机器人，确认前端地图和机器人姿态同步变化。
5. 在前端点击保存地图，确认提示成功。
6. 切换到导航界面，在地图上点击或拖动终点箭头。
7. 点击开始导航，确认状态不长时间停在 `sending`。
8. 观察机器人移动、全局路径更新、导航状态最终变为到达或失败。
9. 测试取消导航，确认机器人停止且前端状态恢复。

说明：该脚本不会在保存地图后关闭 gmapping。导航阶段继续使用当前建图会话发布的 `/map` 和 `map -> odom -> base_footprint` TF，因此前端只需要设置终点。脚本会为 Gazebo 设置本地模型路径和空 Fuel 配置，减少外网模型库连接超时导致的启动延迟。

## 实机前端联调

```bash
cd BaseRos
bash scripts/verify_real_frontend_collab.sh
```

指定地图名：

```bash
cd BaseRos
bash scripts/verify_real_frontend_collab.sh lab_map
```

默认硬件参数：

- 底盘串口：`/dev/ftdi`
- 雷达串口：`/dev/rplidar`
- 雷达波特率：`115200`

覆盖硬件参数：

```bash
cd BaseRos
BASE_SERIAL_PORT=/dev/ttyUSB0 \
LIDAR_SERIAL_PORT=/dev/ttyUSB1 \
LIDAR_SERIAL_BAUDRATE=115200 \
bash scripts/verify_real_frontend_collab.sh real_map
```

如果实验室电脑已经通过其他脚本启动底盘和雷达，避免重复占用串口：

```bash
cd BaseRos
REAL_BRINGUP=false bash scripts/verify_real_frontend_collab.sh real_map
```

人工验收流程：

1. 清空机器人附近障碍，确认急停可用，首次测试建议只给很近的目标。
2. 浏览器打开 `http://localhost:5173/` 并连接 `ws://localhost:9090`。
3. 确认前端收到 `/map`、`/scan`、`/tf`。
4. 在键盘控制终端小幅移动机器人，确认底盘响应和前端显示一致。
5. 保存地图，确认生成地图文件。
6. 切换导航界面，选择近距离终点并开始导航。
7. 观察机器人是否平滑移动，必要时立即取消导航或急停。

## 常用检查命令

查看关键 topic：

```bash
rostopic list | grep -E '/map|/scan|/tf|/amcl_pose|/move_base'
```

检查地图：

```bash
rostopic echo -n 1 /map/info
```

检查 rosbridge 端口：

```bash
ss -ltnp | grep 9090
```

检查导航 action：

```bash
rostopic echo /se_navigation/navigate/status
rostopic echo /move_base/status
```

如果前端长时间停在 `sending`，优先检查 rosbridge 是否连接、`/se_navigation/navigate` 是否存在、move_base 是否启动，以及终端中是否有串口或 Gazebo 模型加载错误。
