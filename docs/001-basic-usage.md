# BaseRos 基础说明

本文只保留项目运行所需的基础信息。验证脚本与人工验收流程见 `002-verification-scripts.md`，环境与依赖配置见 `003-configuration.md`。

## 目录结构

- `catkin_ws/`：ROS Noetic 工作空间。
- `catkin_ws/src/se_map/`：课程项目建图功能包。
- `catkin_ws/src/se_navigation/`：课程项目导航功能包。
- `frontend/`：Vue 3 + Vite 前端，通过 rosbridge 与 ROS 通信。
- `scripts/`：编译、启动和联调脚本。

项目新增包以薄封装为主，底层复用课程组和机器人已有能力：

- `wpr_simulation`：Gazebo 仿真、机器人模型、键盘控制、RViz 配置。
- `wpb_home_bringup`：实机底盘、雷达、机器人描述。
- `wpb_home_tutorials`：AMCL 和 move_base 参数。
- `wpbh_local_planner`：局部规划器。

## 编译

推荐使用脚本：

```bash
cd BaseRos
bash scripts/build_workspace.sh
source catkin_ws/devel/setup.bash
```

手动编译：

```bash
cd BaseRos/catkin_ws
source /opt/ros/noetic/setup.bash
catkin_make
source devel/setup.bash
```

如果 `build/`、`devel/` 来自其他电脑，可能包含旧路径。重新编译前可以清理：

```bash
cd BaseRos/catkin_ws
rm -rf build devel
catkin_make
```

## 建图功能包

包路径：`catkin_ws/src/se_map`

提供能力：

- 启动仿真或实机的手工建图流程。
- 使用 gmapping 发布实时 `/map` 和 `map -> odom` TF。
- 保存地图到 `catkin_ws/src/se_map/maps/`。
- 清理地图目录。
- 发布导航初始化位姿 `/initialpose`。

主要文件：

- `launch/manual_mapping.launch`：手工建图入口，支持 `sim`、`real_bringup`、`keyboard`、`rviz` 等参数。
- `scripts/map_manager.py`：提供保存、清理、初始位姿服务。
- `srv/SaveMap.srv`：`/se_map/save_map`
- `srv/ClearMap.srv`：`/se_map/clear_map`
- `srv/SetInitialPose.srv`：`/se_map/set_initial_pose`

常用命令：

```bash
roslaunch se_map manual_mapping.launch sim:=true
rosservice call /se_map/save_map "name: 'saved_map'"
rosservice call /se_map/clear_map "confirm: true"
```

实机建图：

```bash
roslaunch se_map manual_mapping.launch sim:=false real_bringup:=true
```

如果实验室电脑已经通过其他脚本启动底盘和雷达，避免重复占用串口：

```bash
roslaunch se_map manual_mapping.launch sim:=false real_bringup:=false
```

## 导航功能包

包路径：`catkin_ws/src/se_navigation`

提供能力：

- 启动仿真或实机导航链路。
- 使用 map_server 或当前 gmapping live-map 作为地图来源。
- 启动 AMCL、move_base 和已有局部规划器。
- 将前端导航请求封装为 `/se_navigation/navigate` action。
- 支持导航目标点朝向，前端拖动终点箭头后会发送完整 Pose。

主要文件：

- `launch/navigation.launch`：导航入口，支持 `sim`、`real_bringup`、`live_map`、`map_file` 等参数。
- `scripts/navigator.py`：连接 `/se_navigation/navigate` 与 `move_base`。
- `scripts/send_navigation_goal.py`：命令行导航目标测试工具。
- `action/Navigate.action`：导航 action 定义。

加载保存地图导航：

```bash
roslaunch se_navigation navigation.launch sim:=true map_file:=$(rospack find se_map)/maps/saved_map.yaml
rosrun se_navigation send_navigation_goal.py --goal-x 0.6 --goal-y 0.0
```

建图会话内直接导航：

```bash
roslaunch se_navigation navigation.launch sim:=false live_map:=true rviz:=false
```

实机导航：

```bash
roslaunch se_navigation navigation.launch sim:=false real_bringup:=true map_file:=$(rospack find se_map)/maps/saved_map.yaml
```

## 前端功能

前端路径：`frontend/`

提供能力：

- 连接 rosbridge，默认地址为 `ws://localhost:9090`。
- 显示 `/map`、机器人位置、雷达点、全局路径和导航终点。
- 建图模式调用 `/se_map/save_map`、`/se_map/clear_map`。
- 导航模式在地图上点击或拖动设置终点和朝向，并调用 `/se_navigation/navigate`。
- 订阅 action 状态，显示导航中的 planning、normal、reached、fail、cancel 等反馈。

启动方式：

```bash
cd BaseRos
bash scripts/start_frontend.sh
```
