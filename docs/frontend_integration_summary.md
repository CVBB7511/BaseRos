# 前端嵌入工作总结

本文简要总结当前码垛机器人项目中的前端嵌入工作。

## 目标范围

前端用于辅助完成码垛流程中的设备启用、建图、地图保存/导入、桌面标定和开始码垛。地图、机器人位姿、路径等可视化不在前端绘制，统一交给 RViz 显示。

前端不包含导航操作界面，也不额外建立 `se_map`、`se_navigation` 等功能包。

## 前端界面

当前前端主要包括：

- ROS Bridge 连接区。
- 运行模式选择：真机 / 仿真。
- 建图控制：重新建图、保存地图。
- 地图导入：选择地图所在文件夹并启动执行系统与 RViz。
- 桌面标定：选择取货桌 / 码垛桌，输入桌子长度、宽度/深度、高度、机器人到桌面中心距离。
- 码垛任务：开始码垛，并显示当前任务状态和耗时。
- 摄像头画面：连接 ROS Bridge 后自动订阅压缩图像话题并显示实时画面。
- 操作日志：显示前端服务调用结果和错误信息。

## ROS 对接

前端通过 rosbridge 调用后端 ROS 服务：

- `/frontend/start_mapping`：启动或重启建图流程。
- `/frontend/save_map`：调用 `map_saver` 保存地图，保存成功后关闭建图 RViz。
- `/frontend/import_map`：导入地图并启动执行系统与 RViz。
- `/frontend/calibrate_table`：读取机器人当前 TF，计算桌面中心和朝向，再调用 `/palletizing/mark_zone` 保存标定数据。
- `/frontend/start_palletizing`：调用 `/palletizing/start` 开始码垛。
- `/frontend/status`：查询建图/执行流程状态。

码垛状态通过订阅 `/palletizing/stats` 获取，前端显示当前状态和耗时。

## 仿真联调

仿真联调脚本为：

```bash
bash scripts/verify_sim_frontend_mapping.sh
```

该脚本会启动 roscore、常驻 Gazebo 仿真、前端控制服务、rosbridge、键盘遥控终端和前端。Gazebo 仿真保持常开，建图和执行流程复用同一个仿真窗口，避免重复启动多个 Gazebo。

仿真场景使用：

- 世界文件：`catkin_ws/src/gazebosim_demo/worlds/palletizing_test.world`
- 仿真标定文件：`catkin_ws/src/gazebosim_demo/config/palletizing_zones_sim.yaml`
- 默认地图：`catkin_ws/src/gazebosim_demo/maps/palletizing_map.yaml`

## 真机联调

真实场景前端联调脚本为：

```bash
bash scripts/verify_real_frontend_palletizing.sh
```

该脚本会启动 roscore、前端控制服务、rosbridge、键盘遥控终端和前端，不启动 Gazebo。前端选择“真机”后，按重新建图、保存地图、导入地图、RViz 中 `2D Pose Estimate`、保存标定、开始码垛的顺序联调。

真机默认标定文件为项目根目录：

```text
/home/yubowen/BaseRos/zones.yaml
```

## 日志位置

前端操作结果会显示在页面右侧日志窗口。更详细的 ROS 输出在联调脚本打开的 “Frontend Control Services” 终端中，包括后端服务和由前端拉起的 launch 输出。

ROS 原生日志默认保存到：

```text
/home/yubowen/BaseRos/.ros/log
```

## 摄像头显示

前端已经支持摄像头画面显示。连接 ROS Bridge 后，页面中间的“摄像头画面”面板会自动订阅压缩图像话题并实时显示。

默认话题为：

```text
/kinect2/qhd/image_color_rect/compressed
```

界面中可以修改话题和显示帧率。为了保证控制界面不卡顿，前端采用以下策略：

- 只订阅 `sensor_msgs/CompressedImage`，不直接订阅原始 `sensor_msgs/Image`。
- 默认显示帧率为 8 fps，最高限制为 15 fps。
- ROS 订阅队列长度为 1，只显示最新帧，避免旧帧堆积。
- 图像数据不进入全局状态管理，只直接更新页面中的 `<img>`，减少 Vue 响应式开销。

如果实际相机没有发布压缩图像话题，建议在 ROS 侧启用 `image_transport` 的 compressed 插件，或增加单独的图像压缩/转发节点。
