# Kinect Stability Runbook

## 结论

当前最大风险不是检测算法，而是 Kinect v2 与实验室旧电脑 USB/驱动链路不稳定。

如果电脑没有稳定 USB3，Kinect v2 无法通过软件彻底修复。`fps_limit`、`sd` 话题和低分辨率只能降低 ROS 处理压力，不能把 Kinect v2 对 USB 链路的基础要求变成 USB2 可承受。

今天的处理目标：

1. 尽量降低 ROS 侧负载。
2. 避免网页、点云和多订阅者触发掉流。
3. 一旦掉到 `0Hz`，用固定流程恢复。
4. 如果仍高频失败，必须换稳定 USB3 电脑或 USB3 控制器。

## 使用最小 Kinect 启动

不要用官方 `kinect2_bridge.launch` 默认配置开始调试。它会额外启动 `sd/qhd/hd` 三路点云 nodelet，负载很高。

本项目新增了最小启动：

```bash
roslaunch warehouse_sorting simple_vision.launch
```

它默认包含：

- `minimal_kinect2.launch`
- `fps_limit:=5.0`
- `use_nodelet:=false`
- `queue_size:=2`
- `bilateral_filter:=false`
- `edge_aware_filter:=false`
- `worker_threads:=2`
- 不启动点云生成
- 不启动 WPB 物体检测
- 不启动网页

如果 Kinect 已经由其它终端启动：

```bash
roslaunch warehouse_sorting simple_vision.launch start_kinect:=false
```

## 验证最小链路

```bash
rostopic hz /kinect2/sd/image_color_rect
rostopic hz /kinect2/sd/image_depth_rect
rostopic echo /simple_vision/debug
rostopic echo /simple_vision/objects
```

只在需要看框的时候打开：

```bash
rosrun image_view image_view image:=/simple_vision/debug_image
```

不要频繁开关 `image_view`，不要刷新网页视频。

## 禁用 USB 自动省电

临时禁用当前已连接 USB 设备省电：

```bash
for f in /sys/bus/usb/devices/*/power/control; do
  echo on | sudo tee "$f" >/dev/null
done
```

查看是否已关闭：

```bash
grep -H . /sys/bus/usb/devices/*/power/control | head
```

如果允许修改系统启动参数，可以永久关闭 USB autosuspend。编辑：

```bash
sudo nano /etc/default/grub
```

把 `usbcore.autosuspend=-1` 加到 `GRUB_CMDLINE_LINUX_DEFAULT` 的引号内，然后执行：

```bash
sudo update-grub
sudo reboot
```

## 掉到 0Hz 后的恢复流程

不要反复启动项目 launch。按固定流程：

```bash
rosnode kill -a
pkill -f kinect2_bridge
pkill -f nodelet
```

然后物理重新握手：

1. 拔 Kinect USB。
2. 拔 Kinect 电源。
3. 等 10 秒。
4. 先插 Kinect 电源。
5. 等 5 秒。
6. 再插 USB。
7. 等 5 秒。
8. 启动：

```bash
roslaunch warehouse_sorting simple_vision.launch
```

如果仍然 `0Hz`，重启电脑比反复启动 ROS 更有效，说明 USB 控制器或驱动状态已经卡死。

## 判断是否必须换硬件

如果满足以下任意条件，继续写代码意义不大，应换电脑或 USB3 控制器：

- `simple_vision.launch` 最小配置下仍频繁掉到 `0Hz`。
- 掉流后必须同时拔线和重启机器人/电脑才能恢复。
- 长时间只跑 `/kinect2/sd/image_color_rect` 也会停流。
- `dmesg` 中反复出现 USB reset、disconnect、timeout。

可行硬件方案：

- 使用更新的笔记本或台式机，必须有稳定 USB3。
- 台式机可加独立 PCIe USB3 控制器。
- 尽量不要让 Kinect v2 通过普通 USB Hub。
- Kinect 电源适配器必须单独稳定供电。

## 调试边界

在 Kinect 稳定前，不启动：

- `wpb_home_objects_3d`
- `/kinect2/*/points` 点云消费者
- `web_video_server`
- 多个 `image_view`
- 完整任务链路

先拿到一个稳定结果：

```text
/simple_vision/debug: {"status": "ok", "count": N, ...}
/simple_vision/objects: PoseArray with N poses
```
