可以。你现在 RViz/AMCL 无法收敛，重新建图应从**真机建图流程**开始。下面全部按你实际目录：

```bash
/home/yubowen/BaseRos
```

来写。

**0. 先关闭旧 ROS 进程**

所有 ROS 终端里按 `Ctrl+C`。然后可选清理：

```bash
pkill -f roslaunch
pkill -f roscore
pkill -f rosmaster
```

**1. 检查设备**

```bash
ls /dev/ftdi
ls /dev/rplidar
ls /dev/input/js0
```

必须有：

```bash
/dev/ftdi
/dev/rplidar
```

`/dev/input/js0` 只有用手柄时需要。

**2. 编译工作空间**

```bash
cd /home/yubowen/BaseRos/catkin_ws

source /opt/ros/noetic/setup.bash
catkin_make -j4 -DPYTHON_EXECUTABLE=/usr/bin/python3

source /home/yubowen/BaseRos/catkin_ws/devel/setup.bash
```

**3. 终端 1：启动 roscore**

```bash
source /opt/ros/noetic/setup.bash
roscore
```

保持这个终端不要关。

**4. 终端 2：启动真机建图**

```bash
source /opt/ros/noetic/setup.bash
source /home/yubowen/BaseRos/catkin_ws/devel/setup.bash

roslaunch gazebosim_demo palletizing_mapping_real.launch
```

这个会启动真机底盘、雷达、Kinect、SLAM 和 RViz。

**5. 终端 3：遥控机器人扫描环境**

键盘遥控：

```bash
source /opt/ros/noetic/setup.bash
source /home/yubowen/BaseRos/catkin_ws/devel/setup.bash

rosrun gazebosim_demo vel_ctrl_node.py
```

控制方式：

```text
W/S：前进/后退
A/D：左移/右移
Q/E：左转/右转
Space：急停
```

如果你要用手柄：

```bash
source /opt/ros/noetic/setup.bash
source /home/yubowen/BaseRos/catkin_ws/devel/setup.bash

roslaunch wpb_home_bringup js_ctrl.launch
```

**6. 建图时怎么走**

让机器人慢速移动，把之后要运行的区域完整扫一遍：

```text
1. 先原地慢慢转一圈
2. 沿场地边界走一圈
3. 到取货桌附近扫一遍
4. 到码垛桌附近扫一遍
5. 回到起点附近
```

RViz 里地图稳定、墙体/障碍物轮廓清楚后再保存。

**7. 备份旧地图**

新开终端：

```bash
mkdir -p /home/yubowen/BaseRos/real_maps/backup

cp /home/yubowen/BaseRos/real_maps/real_map.yaml \
   /home/yubowen/BaseRos/real_maps/backup/real_map_old.yaml

cp /home/yubowen/BaseRos/real_maps/real_map.pgm \
   /home/yubowen/BaseRos/real_maps/backup/real_map_old.pgm
```

如果旧地图不存在，`cp` 报错可以忽略。

**8. 保存新地图**

```bash
source /opt/ros/noetic/setup.bash
source /home/yubowen/BaseRos/catkin_ws/devel/setup.bash

rosrun map_server map_saver -f /home/yubowen/BaseRos/real_maps/real_map
```

注意这里不要写成目录，要写成：

```bash
/home/yubowen/BaseRos/real_maps/real_map
```

它会生成：

```bash
/home/yubowen/BaseRos/real_maps/real_map.yaml
/home/yubowen/BaseRos/real_maps/real_map.pgm
```

**9. 检查地图 YAML**

```bash
cat /home/yubowen/BaseRos/real_maps/real_map.yaml
```

确认里面类似：

```yaml
image: /home/yubowen/BaseRos/real_maps/real_map.pgm
resolution: 0.050000
origin: [...]
negate: 0
occupied_thresh: 0.65
free_thresh: 0.196
```

如果 `image:` 不是这个路径，修正：

```bash
sed -i 's#^image: .*#image: /home/yubowen/BaseRos/real_maps/real_map.pgm#' \
  /home/yubowen/BaseRos/real_maps/real_map.yaml
```

**10. 用新地图启动执行系统**

先关闭建图相关终端，然后重新启动：

终端 1：

```bash
source /opt/ros/noetic/setup.bash
roscore
```

终端 2：

```bash
source /opt/ros/noetic/setup.bash
source /home/yubowen/BaseRos/catkin_ws/devel/setup.bash

roslaunch gazebosim_demo palletizing_execute_real.launch \
  map_file:=/home/yubowen/BaseRos/real_maps/real_map.yaml
```

RViz 里重新点：

```text
2D Pose Estimate
```

这次应该基于新地图收敛。

**11. 重新标定桌子**

因为地图重建后 `/map` 坐标系可能变化，旧的：

```bash
/home/yubowen/waterjet/zones.yaml
```

大概率不能再用了。需要重新标定 source/dest。

详细标定过程、前端输入含义和保存位置见：

```text
docs/table_calibration_and_palletizing.md
```

启动执行系统并完成定位后：

```bash
source /opt/ros/noetic/setup.bash
source /home/yubowen/BaseRos/catkin_ws/devel/setup.bash

rosrun palletizing mark_table_positions.py
```

先选：

```text
s
```

标定取货桌。

再运行一次：

```bash
rosrun palletizing mark_table_positions.py
```

选：

```text
d
```

标定码垛桌。

**12. 最后触发任务**

```bash
source /opt/ros/noetic/setup.bash
source /home/yubowen/BaseRos/catkin_ws/devel/setup.bash

rosservice call /palletizing/start "{}"
```

码垛执行流程说明见：

```text
docs/table_calibration_and_palletizing.md
```

最关键的是：重新建图后一定要重新做 `2D Pose Estimate`，并且建议重新标定 source/dest 桌面位置。否则地图能收敛了，机器人也可能仍然去错桌子。 执行第10步和第12步




