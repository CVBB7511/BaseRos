# 桌面标定与码垛流程说明

本文对应 `docs/pipeline.md` 的第 11 步和第 12 步，说明桌面标定如何工作、用户需要输入哪些数据、数据保存在哪里，以及点击“开始码垛”后系统如何执行任务。

## 第 11 步：桌面标定

桌面标定的目标是把取货桌 `source` 和码垛桌 `dest` 的位置写入 `/map` 坐标系。地图重建后，`/map` 坐标系可能变化，所以即使桌子物理位置没变，也建议重新标定。

原始命令行工具是：

```bash
rosrun palletizing mark_table_positions.py
```

它的交互流程是：

1. 用户先在 RViz 中完成 `2D Pose Estimate`，让 AMCL 定位收敛。
2. 用户把机器人移动到桌子正前方，并让机器人朝向桌面中心。
3. 工具询问标定区域：`source` 为取货桌，`dest` 为码垛桌。
4. 工具读取当前机器人在 `/map` 中的位置和朝向。
5. 用户输入桌子长度、桌子宽度/深度、桌面高度、机器人到桌面中心距离。
6. 工具计算桌面中心和桌面朝向，并调用 `/palletizing/mark_zone` 保存。

计算方式与前端一致：

```text
桌面中心 X = 机器人 X + 距离 * cos(机器人 yaw)
桌面中心 Y = 机器人 Y + 距离 * sin(机器人 yaw)
桌面 yaw   = 机器人 yaw + pi
```

其中“距离”默认可按：

```text
桌子宽度 / 2 + 0.70
```

例如当前仿真桌子的碰撞尺寸为 `1.2m x 0.5m`，宽度/深度为 `0.5m`，默认距离就是 `0.95m`。

当前 `gazebosim_demo/worlds/palletizing_test.world` 的仿真桌子参数建议使用：

```text
标定区域: source 或 dest
桌子长度: 1.20
桌子宽度/深度: 0.50
桌面高度: 0.765
机器人到桌面中心距离: 0.95
```

标定 `source` 时，让机器人在取货桌正前方并朝向取货桌中心；标定 `dest` 时，让机器人在码垛桌正前方并朝向码垛桌中心。

按上述输入保存后，当前仿真场景中 `palletizing_zones_sim.yaml` 应接近：

```yaml
source_x: -1.5
source_y: 0.0
source_z: 0.765
source_yaw: 3.1416
source_length: 1.2
source_width: 0.5
dest_x: 1.5
dest_y: 0.0
dest_z: 0.765
dest_yaw: 0.0
dest_length: 1.2
dest_width: 0.5
```

## 标定数据保存位置

标定最终由 `palletizing_executor.py` 的 `/palletizing/mark_zone` 服务保存。保存位置由执行系统启动参数 `zones_file` 决定。

仿真执行系统 `gazebosim_demo/launch/palletizing_execute.launch` 默认保存到：

```text
/home/yubowen/BaseRos/catkin_ws/src/gazebosim_demo/config/palletizing_zones_sim.yaml
```

真机执行系统 `gazebosim_demo/launch/palletizing_execute_real.launch` 未显式传 `zones_file` 时，`palletizing_executor.py` 会使用默认项目根目录：

```text
/home/yubowen/BaseRos/zones.yaml
```

也就是说，仿真联调时前端“保存标定”会修改 `palletizing_zones_sim.yaml`；真机流程默认修改 `zones.yaml`。

## `palletizing_zones_sim.yaml` 字段含义

`palletizing_zones_sim.yaml` 保存两张桌子的 `/map` 坐标、朝向和尺寸。字段分为 `source_*` 和 `dest_*` 两组：

```text
source_* = 取货桌，机器人从这里检测并抓取物体
dest_*   = 码垛桌，机器人把物体放到这里
```

各字段含义如下：

```text
source_x / dest_x:
  桌面中心点在 /map 坐标系下的 X 坐标，单位 m。

source_y / dest_y:
  桌面中心点在 /map 坐标系下的 Y 坐标，单位 m。

source_z / dest_z:
  桌面高度，即桌面表面离地高度，单位 m。

source_yaw / dest_yaw:
  桌面朝向，单位 rad。该值由机器人标定时的朝向自动计算：
  table_yaw = robot_yaw + pi。

source_length / dest_length:
  桌子长边长度，单位 m。仿真 table 模型推荐 1.20。

source_width / dest_width:
  桌子宽度/深度，单位 m。仿真 table 模型推荐 0.50。
```

文件内容示例：

```yaml
source_x: -1.5
source_y: 0.0
source_z: 0.765
source_yaw: 3.1416
source_length: 1.2
source_width: 0.5
dest_x: 1.5
dest_y: 0.0
dest_z: 0.765
dest_yaw: 0.0
dest_length: 1.2
dest_width: 0.5
```

执行系统启动时会加载该文件。前端“保存标定”成功后，后续点击“开始码垛”会使用最新标定位置。

如果当前文件中出现明显不符合模型尺寸的值，例如 `source_length: 1000000.0`，通常应重新标定或手动改回合理尺寸。当前仿真 table 模型的碰撞尺寸为 `1.2m x 0.5m`。

## 前端标定输入

前端只需要用户输入 `mark_table_positions.py` 交互模式所需的值：

- 标定区域：取货桌 `source` 或码垛桌 `dest`
- 桌子长度
- 桌子宽度/深度
- 桌面高度
- 机器人到桌面中心距离

前端不会要求用户手动输入 `/map` 坐标中的桌面中心 `x/y/yaw`。这些数据由后端读取 TF 后自动计算。

## 第 12 步：开始码垛

第 12 步对应命令：

```bash
rosservice call /palletizing/start "{}"
```

前端“开始码垛”按钮会调用 `/frontend/start_palletizing`，后端再调用原有的 `/palletizing/start` 服务。

开始后，`palletizing_executor.py` 会执行以下流程：

1. 读取当前执行系统 `zones_file` 指向的 YAML 文件中的取货桌和码垛桌标定数据。仿真默认是 `palletizing_zones_sim.yaml`，真机默认是项目根目录 `zones.yaml`。
2. 导航到取货桌前方的安全接近点。
3. 检测取货桌上的物体。
4. 选择一个物体并导航对齐。
5. 调用抓取行为抓起物体。
6. 导航到码垛桌前方的放置接近点。
7. 根据码垛策略计算放置点。
8. 调用放置行为放下物体。
9. 更新码垛状态并返回取货桌。
10. 重复上述流程，直到取货桌上没有可处理物体或任务失败终止。

任务过程中，执行器会发布统计信息到 `/palletizing/stats`，并在终端日志中输出导航、抓取、放置和成功/失败数量。

## 码垛状态与日志

前端会订阅 `/palletizing/stats`，在“码垛任务”区域显示当前状态和耗时。常见状态含义如下：

- `IDLE`：执行器已启动，等待“开始码垛”。
- `STARTING`：已收到开始命令，正在进入任务线程。
- `NAVIGATING`：正在通过 `move_base` 导航到取货桌或码垛桌。
- `DETECTING`：正在检测取货桌上的物体。
- `GRABBING`：正在执行抓取。
- `PLACING`：正在执行放置。
- `DONE`：任务结束。

如果需要查看详细日志，前端联调脚本启动的“Frontend Control Services”终端会显示后端控制服务以及由前端拉起的执行 launch 输出，其中包括 `palletizing_executor.py` 的导航、检测、抓取、放置日志。ROS 原生日志也会落在当前 `ROS_HOME` 下，例如联调脚本默认使用 `/home/yubowen/BaseRos/.ros/log`。

## 真实场景前端联调

真实机器人联调脚本为：

```bash
bash scripts/verify_real_frontend_palletizing.sh
```

该脚本会打开 roscore、前端控制服务、rosbridge、键盘遥控终端和前端终端，不会启动 Gazebo。前端中选择“真机”后，按正常流程点击“重新建图”“保存地图”“导入地图”“保存标定”“开始码垛”；导入地图后真机执行系统会启动 RViz、硬件驱动、AMCL、`move_base` 和 `palletizing_executor.py`。
