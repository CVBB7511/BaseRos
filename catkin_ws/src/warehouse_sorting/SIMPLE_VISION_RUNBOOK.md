# Simple Vision Runbook

今天只验证一件事：Kinect 稳定出图，并输出物体相机坐标。

这条链路不启动任务管理、机械臂、导航、WPB 点云分割和网页。

## 启动

```bash
cd ~/catkin_ws
source devel/setup.bash
roslaunch warehouse_sorting simple_vision.launch
```

这个 launch 默认使用 `minimal_kinect2.launch`，不会启动官方默认的三路点云生成节点。
如果 Kinect 频率容易掉到 `0Hz`，先阅读 `KINECT_STABILITY_RUNBOOK.md`。

默认使用低分辨率 `sd` 话题，降低 Kinect 压力：

```text
/kinect2/sd/image_color_rect
/kinect2/sd/image_depth_rect
/kinect2/sd/camera_info
```

## 查看输出

检测结果位置：

```bash
rostopic echo /simple_vision/objects
```

调试信息：

```bash
rostopic echo /simple_vision/debug
```

调试图像：

```bash
rosrun image_view image_view image:=/simple_vision/debug_image
```

如果不想打开图像窗口，只看频率：

```bash
rostopic hz /simple_vision/objects
rostopic hz /simple_vision/debug
```

## 判断结果

`/simple_vision/debug` 中：

- `status: "waiting_rgb"`：没有收到彩色图。
- `status: "waiting_depth"`：没有收到深度图。
- `status: "waiting_camera_info"`：没有收到相机内参。
- `status: "ok", count: 0`：相机正常，但 HSV/面积/深度条件没有检测到物体。
- `status: "ok", count: N`：检测到 N 个物体。

`/simple_vision/objects` 是 `geometry_msgs/PoseArray`：

- `pose.position.x/y/z` 是相机坐标系下的米制坐标。
- `z` 大致是物体距离相机的深度。

## 现场调参

如果相机稳定但 `count: 0`：

1. 先确认物体在画面中间，距离相机约 `0.2m ~ 1.5m`。
2. 降低面积阈值：

```bash
roslaunch warehouse_sorting simple_vision.launch min_area:=300
```

3. 如果距离更远，放宽深度范围：

```bash
roslaunch warehouse_sorting simple_vision.launch max_depth:=3.0
```

4. 如果用的是 `qhd` 更清楚：

```bash
roslaunch warehouse_sorting simple_vision.launch \
  rgb_topic:=/kinect2/qhd/image_color_rect \
  depth_topic:=/kinect2/qhd/image_depth_rect \
  camera_info_topic:=/kinect2/qhd/camera_info
```

## 只接已有 Kinect

如果 Kinect 已经由别的终端启动，不要重复启动：

```bash
roslaunch warehouse_sorting simple_vision.launch start_kinect:=false
```
