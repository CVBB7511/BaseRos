# 实机部署与操作手册

本文档面向实验室 Ubuntu 20.04 / ROS Noetic 电脑，用于把当前仓储分拣码垛代码复制到实机环境并完成验证。
当天操作优先看 `warehouse_tuning/REAL_ROBOT_START_HERE.md`。那份文档包含完整复制、编译、启动和标定命令；本文只保留历史部署细节。

## 1. 需要复制什么

推荐复制的源码目录：

- `warehouse_sorting/`
- `warehouse_sorting_msgs/`
- `warehouse_tuning/`
- `.gitignore`

实验室机载电脑的默认工作空间 `~/catkin_ws` 已经导入启智机器人的官方工程包。
默认不要覆盖或修改这些官方包：

- `robot-tools-rec/wpb_home/`
- `robot-tools-rec/rplidar_ros/`
- `robot-tools-rec/iai_kinect2/`
- `robot-tools-rec/waterplus_map_tools/`

本仓库里的 `robot-tools-rec/` 主要用于本地参考和对照，不建议直接复制到机载电脑覆盖官方包。
如果确实发现机载电脑缺少某个官方包，先确认当前机器人/机载电脑是否配套，再单独补齐缺失包。

不要复制这些本机生成物：

- `build/`
- `devel/`
- `install/`
- `log/`
- `.catkin_workspace`
- 根目录自动生成的 `CMakeLists.txt`
- `data/`
- `.vscode/`
- `__pycache__/`

`data/` 只是本地任务资料和对话记录，不要放进 git，也不需要带到实验室电脑上。

## 2. 放到实验室电脑哪里

### 推荐方式：使用实验室默认 `~/catkin_ws`

实验室准则要求使用助教创建的默认工作空间，不要自行创建额外工作空间。
在机载电脑上推荐放到：

```text
~/catkin_ws/src/
  warehouse_sorting/
  warehouse_sorting_msgs/
  warehouse_tuning/
  wpb_home/              # 实验室已有，不覆盖
  rplidar_ros/           # 实验室已有，不覆盖
  iai_kinect2/           # 实验室已有，不覆盖
  waterplus_map_tools/   # 实验室已有，不覆盖
```

构建时在工作空间根目录执行：

```bash
cd ~/catkin_ws
source /opt/ros/noetic/setup.bash
catkin_make -DCATKIN_WHITELIST_PACKAGES=warehouse_sorting\;warehouse_sorting_msgs\;warehouse_tuning\;wpb_home_behaviors
source devel/setup.bash
```

如果实验室电脑已经编译过 `wpb_home_behaviors`，仍建议这次把它放进白名单再编一次。
`vision_node` 的 WPB 桥接需要 Python 能 import `wpb_home_behaviors.msg.Coord`。

检查：

```bash
rospack find warehouse_sorting
rospack find warehouse_tuning
rospack find wpb_home_behaviors
python3 -c "from wpb_home_behaviors.msg import Coord; print('Coord ok')"
```

### 备用方式：继续使用当前仓库布局

如果实验室电脑上也使用 `~/project-code`，复制后目录应类似：

```text
~/project-code/
  warehouse_sorting/
  warehouse_sorting_msgs/
  robot-tools-rec/
```

构建时使用 `--source .`：

```bash
cd ~/project-code
source /opt/ros/noetic/setup.bash
catkin_make --source . -DCATKIN_WHITELIST_PACKAGES=warehouse_sorting\;warehouse_sorting_msgs\;wpb_home_behaviors
source devel/setup.bash
```

这个方式只适合自己的电脑或临时验证。机载电脑优先使用 `~/catkin_ws`。

## 3. 上电前本机自测

先不要让机器人底盘运动，确认消息、服务和任务逻辑正常：

```bash
source devel/setup.bash
./src/warehouse_sorting/tools/dry_run_smoke_test.sh
./src/warehouse_sorting/tools/wpb_bridge_smoke_test.sh
./src/warehouse_sorting/tools/color_depth_smoke_test.sh
```

如果使用 `~/project-code` 布局，脚本路径是：

```bash
./warehouse_sorting/tools/dry_run_smoke_test.sh
./warehouse_sorting/tools/wpb_bridge_smoke_test.sh
./warehouse_sorting/tools/color_depth_smoke_test.sh
```

期望结果：

- `dry-run smoke test passed`
- `wpb bridge smoke test passed`
- `color-depth smoke test passed`
- 最终 `/task/status` 中 `status: "COMPLETED"`
- `completed_items: 4`
- `failed_items: 0`
- `sorted_natural: 2`
- `sorted_colored: 2`

`color_depth_smoke_test.sh` 使用合成 RGB/depth 相机，不依赖真实 Kinect。
它能确认“视觉检测 -> 任务调度 -> 抓放 dry-run -> 导航 dry-run”这条主流程已经打通。

## 4. 第一次实机启动：底盘不动

如果 Kinect 已经有帧，但物体一直检测不到，先不要进入完整任务链。
优先按 `VISION_DEBUG_RUNBOOK.md` 跑独立视觉测试：

```bash
source devel/setup.bash
roslaunch warehouse_sorting vision_debug.launch start_web:=true
rosservice call /vision/scan_request "force: true"
rostopic echo /vision/debug
```

打开 `warehouse_sorting/web/dashboard.html` 可以直接看到：

- Kinect RGB/depth 视频流。
- color-depth 检测框和货物坐标。
- `/vision/debug` 最新信息。
- RGB、Depth、PointCloud、检测结果、任务状态等 topic 是否在线和是否过期。
- AMCL、里程计和 `move_base` 当前状态。

也可以用自动体检脚本把视觉链路逐项检查出来：

```bash
roslaunch warehouse_sorting vision_doctor.launch
```

确认 `/wpb_home/objects_3d` 和 `/vision/detected_objects` 都有结果后，再继续本节。

如果 Kinect 视野覆盖不到桌面或货物，可以按实验室说明使用六角扳手微调 Kinect 俯仰角。
调角度前先确保机器人安全静止，不要带电硬掰机械臂或机械爪。

当前视觉优先使用本项目的 color-depth 检测：彩色图按 HSV 分割，本地深度图估计坐标。
WPB 的 `/wpb_home/objects_3d` 作为备用路径。现场如果 `color_depth` 误检，可以临时关闭：

```bash
roslaunch warehouse_sorting vision_debug.launch color_depth_enabled:=false
```

先只验证 Kinect、物体检测、抓取/放置 action、任务调度，不让导航驱动底盘移动：

```bash
source devel/setup.bash
roslaunch warehouse_sorting robot_integration.launch start_bringup:=true start_behaviors:=true start_kinect:=true dry_run_navigation:=true start_web:=true
```

另开一个终端：

```bash
source devel/setup.bash
roslaunch warehouse_sorting preflight.launch check_robot:=true
```

如果预检通过，再下发任务：

```bash
rostopic pub /task/command std_msgs/String "data: start" -1
rostopic echo /task/status
```

急停命令：

```bash
rostopic pub /task/command std_msgs/String "data: emergency_stop" -1
```

暂停/继续/终止：

```bash
rostopic pub /task/command std_msgs/String "data: pause" -1
rostopic pub /task/command std_msgs/String "data: resume" -1
rostopic pub /task/command std_msgs/String "data: stop" -1
```

## 5. 全流程启动：启用导航

确认上一步没问题后，再启用导航：

```bash
source devel/setup.bash
roslaunch warehouse_sorting robot_integration.launch start_navigation:=true start_behaviors:=true start_kinect:=true
```

注意：

- `start_navigation:=true` 会通过 `wpb_home_tutorials/launch/nav.launch` 启动 WPB core、雷达、地图、AMCL 和 `move_base`。
- 不要同时设置 `start_bringup:=true`，否则可能重复启动 `wpb_home_core`。
- 如果只想验证导航链路但不让机械臂动作，可以临时加 `dry_run_arm:=true`。

另开终端下发任务：

```bash
source devel/setup.bash
roslaunch warehouse_sorting preflight.launch check_robot:=true
rostopic pub /task/command std_msgs/String "data: start" -1
rostopic echo /task/status
```

全流程测试前确认：

- 机器人充电器已经拔除。
- 急停按钮弹起，且手边有人能随时按下。
- 机器人上电时不要人工推动底盘。
- 不要在充电状态下控制机器人运动。
- 不要人为掰动机械臂或机械爪。
- 不抓取刚性物体，优先用纸盒、塑料瓶等安全测试物。

## 6. 现场观察话题

常用检查命令：

```bash
rostopic echo /task/status
rostopic echo /vision/detected_objects
rostopic echo /wpb_home/objects_3d
rostopic echo /wpb_home/grab_result
rostopic echo /wpb_home/place_result
rosservice list | grep -E '/vision|/arm'
rosnode list
```

任务正常时，应能看到：

- `/vision/scan_request` 服务存在。
- `/arm/execute_pick` 和 `/arm/execute_place` 服务存在。
- `/task/status` 从 `RUNNING` 变为 `COMPLETED`。
- `sorted_natural` 和 `sorted_colored` 有统计值。
- `failed_items` 为 0 或只在异常情况下增长。

## 7. 货物类别映射

`wpb_home_objects_3d` 输出坐标，但不输出“本色/彩色”语义类别。当前桥接逻辑按检测顺序映射：

```yaml
warehouse_sorting:
  wpb_home_type_sequence: [natural, colored]
```

如果现场发现类别反了，修改 `warehouse_sorting/config/sorting.yaml`：

```yaml
warehouse_sorting:
  wpb_home_type_sequence: [colored, natural]
```

修改后重新启动 launch 即可，不需要重新编译。

## 8. 常见问题

### 找不到 `warehouse_sorting`

没有 source 当前工作空间：

```bash
source devel/setup.bash
rospack find warehouse_sorting
```

### 找不到 `wpb_home_behaviors.msg.Coord`

重新编译 `wpb_home_behaviors`：

```bash
catkin_make --source . -DCATKIN_WHITELIST_PACKAGES=warehouse_sorting\;warehouse_sorting_msgs\;wpb_home_behaviors
source devel/setup.bash
python3 -c "from wpb_home_behaviors.msg import Coord; print('Coord ok')"
```

标准 `~/catkin_ws` 布局时去掉 `--source .`：

```bash
catkin_make -DCATKIN_WHITELIST_PACKAGES=warehouse_sorting\;warehouse_sorting_msgs\;wpb_home_behaviors
```

### Kinect 没有数据

检查：

```bash
rostopic list | grep kinect2
rostopic hz /kinect2/qhd/points
rostopic hz /kinect2/qhd/image_color_rect
```

如果没有话题，确认 `start_kinect:=true`，并检查 Kinect USB/电源。
如果话题存在但一直 `0Hz`，或出现 USB 超时/丢包：

1. 关闭所有相关终端，重新开终端后再测试。
2. 拔插 Kinect 电源和 USB，必要时更换 USB3 接口。
3. 确认没有重复启动多个 `kinect2_bridge`。
4. 检查 USB 链路速度：

   ```bash
   lsusb -t
   ```

   Kinect 应在 `5000M` 链路上，而不是 `480M`。

5. 重新设置设备权限：

   ```bash
   cd $(rospack find wpb_home_bringup)/scripts
   ./create_udev_rules.sh
   ```

真实机器人通过机载电脑、USB-HUB、传感器和控制器串接访问设备，接口偶发异常时重新拔插或换接口是有效排查动作。

### 没有检测结果

检查：

```bash
rostopic echo /wpb_home/objects_3d
rostopic pub /wpb_home/behaviors std_msgs/String "data: 'object_detect start'" -1
```

确认物体在相机视野内，距离在 `wpb_home_objects_3d` 的过滤范围内。

### Web 面板打不开

当前 WSL 验证环境未安装 `rosbridge_server` / `web_video_server`。实验室机载电脑如果也缺少，安装：

```bash
sudo apt install ros-noetic-rosbridge-server ros-noetic-web-video-server
```

安装后启动：

```bash
roslaunch warehouse_sorting robot_integration.launch start_web:=true
```

页面文件是：

```text
warehouse_sorting/web/dashboard.html
```

如果浏览器不在机器人机载电脑上，把页面顶部的 rosbridge 地址改成 `ws://机器人IP:9090`，视频地址改成 `http://机器人IP:8080`。
核心实机验证不依赖 Web 面板；如果临时打不开，仍可以用 `rostopic echo /debug/state` 和 `rostopic echo /task/status`。
