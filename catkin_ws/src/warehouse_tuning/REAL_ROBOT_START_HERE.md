# 真机启动从这里开始

这份文档只写真机流程。不要运行任何 `sim_*`、`*_demo.launch`、`run_stack_sort_*acceptance.py`，这些只用于本机仿真。

当前包不需要 Gazebo。若出现 `gazebo_msgs` 相关编译或 import 错误，说明用的是旧包或旧环境缓存。

## 0. 复制源码并编译

假设 zip 已经放在 `~/Downloads/field_ready_sorting_src_20260602.zip`。

```bash
export SORTING_ZIP=$HOME/Downloads/field_ready_sorting_src_20260602.zip
mkdir -p ~/catkin_ws/src
cd ~/catkin_ws/src

STAMP=$(date +%Y%m%d_%H%M%S)
for d in arm_grab_task warehouse_sorting warehouse_sorting_msgs warehouse_tuning; do
  if [ -d "$d" ]; then mv "$d" "$d.bak.$STAMP"; fi
done

unzip -o "$SORTING_ZIP"

cd ~/catkin_ws
source /opt/ros/noetic/setup.bash
catkin_make -DCATKIN_WHITELIST_PACKAGES="wpb_home_behaviors;arm_grab_task;warehouse_sorting;warehouse_sorting_msgs;warehouse_tuning"
source devel/setup.bash
```

编译后检查包是否能找到：

```bash
for p in arm_grab_task warehouse_tuning warehouse_sorting warehouse_sorting_msgs \
         wpb_home_bringup wpb_home_tutorials wpb_home_behaviors rplidar_ros kinect2_bridge \
         gmapping map_server amcl rviz; do
  rospack find "$p" >/dev/null && echo "[OK] $p" || echo "[MISSING] $p"
done
```

必须全部是 `[OK]`。如果 `wpb_home_*`、`rplidar_ros`、`kinect2_bridge` 缺失，不要继续，这是实验室机器人基础包没有在当前工作空间里。

## 1. 终端 1：启动真机底层

这个终端不要关。它启动底盘、里程计、雷达、雷达滤波、Kinect 和手柄遥控。

```bash
cd ~/catkin_ws
source /opt/ros/noetic/setup.bash
source devel/setup.bash

roslaunch warehouse_tuning field_robot_base.launch \
  start_core:=true \
  start_lidar:=true \
  start_kinect:=true \
  start_joy:=true
```

另开一个终端检查基础 topic：

```bash
cd ~/catkin_ws
source /opt/ros/noetic/setup.bash
source devel/setup.bash

timeout 5 rostopic hz /odom
timeout 5 rostopic hz /scan
timeout 5 rostopic hz /kinect2/qhd/image_color_rect
timeout 5 rostopic hz /kinect2/qhd/image_depth_rect
```

期望现象：

- `/odom` 有数据：底盘在线。
- `/scan` 有数据：雷达在线。
- `/kinect2/qhd/image_color_rect` 有数据：彩色相机在线。
- `/kinect2/qhd/image_depth_rect` 有数据：深度在线。
- 手柄能发布 `/cmd_vel`：建图时可以遥控机器人绕场。

如果 Kinect 启动很慢，先等 10 秒再查。仍然没有图像时，先重启终端 1，不要进入标定。

## 2. 终端 2：建图、定位、标定

这个终端会交互提示。不要用 roslaunch 挂后台，不要关。一定带 `--keep-managed-stack`，否则标定完成后 AMCL 会被关掉，后面机器人又会不知道自己在地图里的位置。

```bash
cd ~/catkin_ws
source /opt/ros/noetic/setup.bash
source devel/setup.bash

mkdir -p $HOME/maps

rosrun warehouse_tuning field_calibration_wizard.py \
  --manage-stack \
  --keep-managed-stack \
  --rviz \
  --map-prefix $HOME/maps/lab \
  --zone-file $HOME/maps/abc_zones.yaml \
  --feature-file $HOME/maps/cargo_features.yaml \
  --debug-output-dir $HOME/maps/debug_images \
  --table-height 0.78
```

向导步骤：

1. 建图：向导会打开 RViz。用手柄遥控机器人绕 A/B/C 三张桌子和通道走一圈。RViz 里地图稳定后，在终端按回车保存。
2. 定位：向导会重载 `$HOME/maps/lab.yaml` 并启动 AMCL。必须在 RViz 点 `2D Pose Estimate`，把机器人箭头放到真实位置和朝向。终端显示收到 `/amcl_pose` 后才能继续。
3. A/B/C 区域：按提示把机器人开到 A 桌、B 桌、C 桌前，车头对准桌面中心，停稳后按回车。终端会打印每个区域的 `x/y/yaw`。
4. 小方块特征：每次只放一种颜色小方块到相机 ROI 中心，按回车。终端会打印 HSV、估计尺寸和 debug 图路径。

标定成功后应该生成：

```bash
ls -l $HOME/maps/lab.yaml $HOME/maps/lab.pgm
ls -l $HOME/maps/abc_zones.yaml
ls -l $HOME/maps/cargo_features.yaml
```

如果已经建过地图，只重新做定位、A/B/C 和颜色特征：

```bash
rosrun warehouse_tuning field_calibration_wizard.py \
  --manage-stack \
  --keep-managed-stack \
  --skip-mapping \
  --rviz \
  --map-prefix $HOME/maps/lab \
  --zone-file $HOME/maps/abc_zones.yaml \
  --feature-file $HOME/maps/cargo_features.yaml \
  --debug-output-dir $HOME/maps/debug_images \
  --table-height 0.78
```

## 3. 终端 3：启动分拣

确认终端 1 和终端 2 都还开着，再运行分拣。运行前把待分拣小方块放到 A 桌上，B/C 桌清空。

```bash
cd ~/catkin_ws
source /opt/ros/noetic/setup.bash
source devel/setup.bash

roslaunch arm_grab_task stack_sort_field.launch \
  use_field_override:=true \
  field_override:=$HOME/maps/abc_zones.yaml \
  use_feature_override:=true \
  feature_override:=$HOME/maps/cargo_features.yaml \
  rviz:=true
```

这个 launch 会让底盘和机械臂真实动作。启动前确认桌边没有人手，急停可触达。

## 4. 终端 4：看状态和日志

```bash
cd ~/catkin_ws
source /opt/ros/noetic/setup.bash
source devel/setup.bash

rostopic echo /stack_sort/status
```

标定状态：

```bash
rostopic echo /warehouse_tuning/field_calibration_status
rostopic echo /warehouse_tuning/mapping_status
rostopic echo /warehouse_tuning/abc_zone_status_A
rostopic echo /warehouse_tuning/abc_zone_status_B
rostopic echo /warehouse_tuning/abc_zone_status_C
rostopic echo /warehouse_tuning/cargo_feature_status_green
rostopic echo /warehouse_tuning/cargo_feature_status_blue
```

分拣日志重点看：

```text
[CONFIG]  参数是否加载了现场 yaml
[STATE]   当前流程状态
[PICK]    取货对准和夹取
[DROP]    放置目标和层数
[METRICS] 每次循环成功/失败原因
[REPORT]  测试报告路径
```

## 5. 立刻停止

先在终端 3 按 `Ctrl-C` 停分拣。再发一次零速度：

```bash
rostopic pub /cmd_vel geometry_msgs/Twist \
  '{linear: {x: 0.0, y: 0.0, z: 0.0}, angular: {x: 0.0, y: 0.0, z: 0.0}}' -1
```

然后按顺序关闭终端 2、终端 1。

## 6. 常见问题

`RLException: field_robot_base.launch not found`

```bash
cd ~/catkin_ws
source /opt/ros/noetic/setup.bash
source devel/setup.bash
rospack find warehouse_tuning
```

找不到就是包没放进 `~/catkin_ws/src` 或没有重新编译。

`No module named gazebo_msgs`

用的是旧包。当前真机包不需要 Gazebo。重新解压最新 zip，并确认 `arm_grab_task/launch/stack_sort_field.launch` 里有：

```text
gazebo_enable_helper=false
```

`/scan` 没数据

检查雷达设备：

```bash
ls -l /dev/rplidar
rosnode list | grep rplidar
```

`/amcl_pose` 没数据

RViz 里必须点 `2D Pose Estimate`。如果点了仍不动，轻微遥控机器人原地转一下，再点一次。

`tf lookup map -> base_footprint failed`

定位没成功或终端 2 被关了。重新运行第 2 节，或至少重新启动：

```bash
roslaunch warehouse_tuning field_localization.launch \
  map_file:=$HOME/maps/lab.yaml \
  rviz:=true
```

`no colored blob found in ROI`

只放一个样品到画面中心，查看 debug 图：

```bash
ls -lt $HOME/maps/debug_images | head
```

如果样品不在 ROI 中，重新跑向导并调整：

```bash
--feature-roi-x 0.30 --feature-roi-y 0.25 --feature-roi-width 0.40 --feature-roi-height 0.45
```

夹取位置偏差或桌高不对

重新跑第 2 节，修改桌高或堆叠点距离：

```bash
--table-height 0.76
--stack-anchor-forward-offset 0.54
```

## 7. 今天只需要记住

三个长期运行终端：

```text
终端 1: roslaunch warehouse_tuning field_robot_base.launch start_core:=true start_lidar:=true start_kinect:=true start_joy:=true
终端 2: rosrun warehouse_tuning field_calibration_wizard.py --manage-stack --keep-managed-stack --rviz ...
终端 3: roslaunch arm_grab_task stack_sort_field.launch use_field_override:=true ... rviz:=true
```

终端 2 不要关。它保留地图重载后的 AMCL，解决“加载地图后机器人不知道自己在哪”的问题。
