# Vision Debug Runbook

本文档记录 2026-05-07 晚上实机测试后的视觉问题拆解，并给出第二天优先验证的最小闭环。

## 结论

今晚不是任务调度优先问题，而是视觉链路还没有稳定输出货物坐标。

已观察到的问题按顺序是：

1. `no Kinect2 devices found`：Kinect 物理连接接触不良。
2. `LIBUSB_ERROR_TIMEOUT`：Kinect 已被识别，但 USB3 数据传输不稳定。
3. `packets were lost`：Kinect 已出流，但 USB 数据仍有丢包。
4. 彩色图、深度图曾经为 `0Hz`：Kinect bridge 启动但没有有效帧。
5. 后续有帧后，任务仍报检测 5 秒超时：`vision_node` 等不到 `/wpb_home/objects_3d` 的新消息。

因此明天不要一开始跑完整分拣任务。先独立跑通：

```text
/kinect2/qhd/points -> wpb_home_objects_3d -> /wpb_home/objects_3d -> /vision/scan_request
```

当前 `vision_node` 的默认检测顺序是：

```text
color_depth -> wpb_home_objects_3d -> mock
```

也就是先用 Kinect 彩色图做 HSV 分割、用深度图估计 3D 坐标；如果没有检测结果，再尝试 WPB 的桌面 grab 检测。

## 本地端到端检查

去现场前先跑一次合成相机 smoke：

```bash
source devel/setup.bash
warehouse_sorting/tools/color_depth_smoke_test.sh
```

它会启动 `color_depth_smoke.launch`，发布两块合成货物的 RGB/depth 图像，调用
`/vision/scan_request`，再让任务管理器完成 4 件货物的 dry-run 分拣。期望看到：

```text
color-depth smoke test passed
```

这一步通过，说明本项目内部的“相机帧 -> color_depth -> 任务 -> 抓放 -> 导航”主链路是通的。
如果现场失败，就优先看真实 Kinect 数据、光照/HSV、ROI、深度和 WPB 备用检测，而不是怀疑任务调度主流程。

## 最小启动

停止其它 launch，避免重复启动 Kinect 或 `wpb_home_objects_3d`。
在实验室机载电脑上使用默认工作空间：

```bash
cd ~/catkin_ws
source devel/setup.bash
```

```bash
source devel/setup.bash
roslaunch warehouse_sorting vision_debug.launch start_web:=true
```

这个 launch 只启动：

- `wpb_home_bringup/normal.launch`
- `kinect2_bridge`
- `wpb_home_objects_3d`
- `warehouse_sorting/scripts/vision_node.py`
- 可选的 rosbridge、web video 和 `/debug/state` 状态汇总节点

不会启动任务管理、机械臂动作服务和导航。

打开 `warehouse_sorting/web/dashboard.html` 后，优先看左侧相机画面和右侧 Topic Health。
如果 RGB、Depth、PointCloud 任意一个是 `missing` 或 `stale`，先处理 Kinect 数据流。
如果相机在线但 Vision 没有检测框，再看 `/vision/debug` 的 HSV、ROI、contours、accepted 信息。

## 第一关：Kinect 数据

```bash
rostopic hz /kinect2/qhd/image_color_rect
rostopic hz /kinect2/qhd/image_depth_rect
rostopic hz /kinect2/qhd/points
```

要求：三者都不是 `0Hz`。如果点云不稳定，先处理 USB3：

```bash
lsusb -t
```

Kinect 应在 `5000M` 链路上，而不是 `480M`。
如果一直 `0Hz` 或 USB 超时，关闭所有相关终端，重新拔插 Kinect 电源和 USB 后再测。
必要时重新执行官方 udev 规则：

```bash
cd $(rospack find wpb_home_bringup)/scripts
./create_udev_rules.sh
```

也可以直接运行自动体检：

```bash
roslaunch warehouse_sorting vision_doctor.launch skip_wpb:=true skip_scan:=true
```

这一步只检查 Kinect 图像、深度、点云和 TF。先让它全部 `[OK]`，再继续物体检测。

## 第二关：WPB 物体检测

```bash
rostopic echo /wpb_home/objects_3d
```

另开终端触发：

```bash
rostopic pub /wpb_home/behaviors std_msgs/String "data: 'object_detect start'" -1
```

成功时应看到：

```text
name: ["obj_0"]
x: [...]
y: [...]
z: [...]
probability: [1.0]
```

如果没有输出，看检测节点日志中的：

- `Planes: ...`
- `Final plane: ... height = ...`
- `[obj_0] ...`

## 现场摆放条件

`wpb_home_objects_3d` 的检测条件较硬：

- 桌面平面高度约 `0.6m ~ 0.85m`。
- 物体在机器人前方，`x` 约 `0.0m ~ 1.5m`。
- 物体左右不要太偏，`y` 最好在 `-0.5m ~ 0.5m`。
- 物体应高出桌面约 `3cm ~ 20cm`。
- 先只放一个 8cm 到 15cm 左右的盒子。
- 物体不要贴边，不要被机械臂、线缆、桌沿遮挡。

如果日志一直找不到 `Final plane`，优先调整桌面高度、Kinect 俯仰角和机器人到桌子的距离。
实验室允许用六角扳手调节 Kinect 角度；不要通过移动或掰动机械臂来凑视野。

## 第三关：本项目视觉桥接

触发本项目扫描服务：

```bash
rosservice call /vision/scan_request "force: true"
rostopic echo /vision/detected_objects
rostopic echo /vision/debug
rostopic echo /debug/state
```

`/vision/debug` 会说明当前卡在哪一步，例如：

- 等待 `/wpb_home/objects_3d`
- 收到空检测
- 收到新检测并转换为货物
- 相机检测未收到 RGB 帧
- `color_depth natural/colored mask=... contours=... accepted=...`

如果 `color_depth` 的 `mask` 很大但 `accepted=0`，通常是 `min_area`、ROI 或形态学参数不合适。
如果 `mask=0`，优先调 `sorting.yaml` 里的 HSV 阈值。

## Color + Depth 参数

主要参数在 `warehouse_sorting/config/sorting.yaml`：

```yaml
warehouse_sorting:
  cargo_types:
    natural:
      hsv_lower: [10, 20, 60]
      hsv_upper: [35, 180, 230]
      min_area: 1200
    colored:
      hsv_lower: [90, 60, 50]
      hsv_upper: [135, 255, 255]
      min_area: 1200
  color_depth:
    roi: {x: 0.10, y: 0.15, width: 0.80, height: 0.70}
    min_depth: 0.20
    max_depth: 1.50
    depth_window: 7
    morph_kernel: 5
```

现场调参顺序：

1. 先调 Kinect 角度，让货物稳定出现在 ROI 内。
2. 如果 `/vision/debug` 中 `mask=0`，调 HSV。
3. 如果 `contours>0` 但 `accepted=0`，降低 `min_area` 或检查 ROI。
4. 如果位置深度明显不对，调 `min_depth`、`max_depth` 或 `depth_window`。

如果想临时只测 WPB 检测，可关闭 color-depth：

```bash
roslaunch warehouse_sorting vision_debug.launch color_depth_enabled:=false
```

完整视觉体检：

```bash
roslaunch warehouse_sorting vision_doctor.launch
```

它会依次检查：

1. `/kinect2/qhd/image_color_rect`
2. `/kinect2/qhd/image_depth_rect`
3. `/kinect2/qhd/points`
4. `/base_footprint <- /kinect2_rgb_optical_frame` TF
5. 触发 `/wpb_home/behaviors` 后 `/wpb_home/objects_3d` 是否有输出
6. `/vision/scan_request` 是否能返回货物

失败时先看第一个 `[FAIL]`，后面的失败往往只是连锁反应。

## 桥接自测

如果 `/wpb_home/objects_3d` 一直没有真实输出，可以先手动发布一条测试坐标，确认本项目视觉桥接没有问题。

终端 1：

```bash
source devel/setup.bash
roslaunch warehouse_sorting vision_debug.launch start_kinect:=false start_wpb_home_objects:=false start_bringup:=false wpb_home_accept_stale_objects:=true
```

终端 2：

```bash
source devel/setup.bash
rostopic pub /wpb_home/objects_3d wpb_home_behaviors/Coord "{name: ['obj_0'], x: [0.42], y: [0.10], z: [0.05], probability: [1.0]}" -1
rosservice call /vision/scan_request "force: true"
rostopic echo -n 1 /vision/detected_objects
```

如果这里能输出 `DetectedCargoArray`，说明 `warehouse_sorting` 侧桥接正常，剩下的问题就在 Kinect 点云、TF 或 `wpb_home_objects_3d` 的桌面/物体分割条件。

## 跑通后再接回任务

只有当下面两项都稳定后，才回到完整启动：

```bash
rostopic echo /wpb_home/objects_3d
rosservice call /vision/scan_request "force: true"
```

再启动：

```bash
roslaunch warehouse_sorting robot_integration.launch start_bringup:=true start_behaviors:=true start_kinect:=true dry_run_navigation:=true wpb_home_detection_timeout:=8.0
```

最后下发：

```bash
rostopic pub /task/command std_msgs/String "data: start" -1
rostopic echo /task/status
```
