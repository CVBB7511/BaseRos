# 前端嵌入工作总结

本文简要总结当前码垛机器人项目中的前端嵌入工作。

## 目标范围

前端用于辅助完成码垛流程中的设备启用、建图、地图保存/导入、桌面标定和开始码垛。地图、机器人位姿、路径等可视化不在前端绘制，统一交给 RViz 显示。

前端不包含导航操作界面，也不额外建立 `se_map`、`se_navigation` 等功能包。

## 前端界面

当前前端主要包括：

- ROS Bridge 连接区，以及运行环境选择和启停：连接实机 / 启用仿真。
- 建图控制：重新建图、保存地图；存在未保存建图进度时，重新建图前会要求用户确认。
- 底盘遥控：位于页面左下角，可直接使用 `W/S/A/D/Q/E` 调整移动速度，`Space` 急停；码垛任务执行期间自动锁定。
- 地图导入：选择地图所在文件夹并启动执行系统与 RViz。
- 桌面标定：选择取货桌 / 码垛桌，输入桌子长度、宽度/深度、高度、机器人到桌面中心距离。
- 码垛任务：开始或人为终止码垛，并显示当前任务状态和耗时；任务正常完成后自动写入一条带耗时的执行日志。
- 摄像头画面：连接 ROS Bridge 后自动订阅压缩图像话题并显示实时画面。
- 操作日志：在右侧滚动区域中以独立卡片显示前端服务调用结果或错误信息，记录操作时间并持久化到项目日志文件，前端重启后仍可查看；卡片支持长路径完整换行和手动清空，底部状态栏仅显示系统状态。
- 参数设置：顶部齿轮菜单的“机器人参数”页可配置相机零位、相机安装位姿和抓取补偿，并可恢复项目默认配置。

## ROS 对接

前端通过 rosbridge 调用后端 ROS 服务：

- `/frontend/environment`：启用、停用或查询真机/仿真运行环境；仿真模式由该服务维护唯一的常驻 Gazebo。
- `/frontend/start_mapping`：启动或重启建图流程。
- `/frontend/save_map`：调用 `map_saver` 保存地图，保存成功后关闭建图 RViz。
- `/frontend/import_map`：导入地图并启动执行系统与 RViz。
- `/frontend/calibrate_table`：读取机器人当前 TF，计算桌面中心和朝向，再调用 `/palletizing/mark_zone` 保存标定数据。
- `/frontend/start_palletizing`：调用 `/palletizing/start` 开始码垛。
- `/frontend/stop_palletizing`：调用 `/palletizing/stop`，取消导航和执行行为并停止本次任务。
- `/frontend/operation_logs`：追加、读取、导入或清空项目中的前端操作日志。
- `/frontend/robot_parameters`：读取、保存或恢复机器人参数；仅允许在仿真和实机均停用时写入。
- `/frontend/status`：查询建图/执行流程状态。

码垛状态通过订阅 `/palletizing/stats` 获取，前端显示当前状态和耗时。

## 统一启动与联调

仿真和真机共用同一个启动脚本：

```bash
bash scripts/start_frontend_system.sh
```

脚本只负责构建工作空间并启动公共基础设施：`roscore`、前端控制服务、ROS Bridge 和前端，不会预先启动 Gazebo 或真机驱动。打开前端并连接 ROS Bridge 后，在左侧“运行环境”选择：

- 选择“仿真”并点击“启用仿真”：后端启动一个常驻 Gazebo，建图和执行流程复用同一个窗口。
- 选择“实机”并点击“连接实机”：后端检查 `/dev/ftdi` 和 `/dev/rplidar`，检查通过后允许启动真机建图或执行流程。
- 切换模式前先停用当前环境；停用时会结束当前建图/执行流程，仿真模式还会关闭由前端启动的 Gazebo。

运行环境尚未启用、或页面模式与后端环境不一致时，建图、地图导入、标定和码垛按钮保持禁用。键盘遥控已集成到前端，不再额外打开遥控终端。

## 机器人参数

当前参数统一保存在：

```text
catkin_ws/src/wpb_home/wpb_home_bringup/config/wpb_home.yaml
```

其中 `zeros` 保存真机 Kinect 高度和俯仰零位，`camera_mount` 保存真机相机相对 `base_link` 的安装位置，`grab` 保存抓取补偿。`wpb_home.urdf` 通过 xacro 读取 `camera_mount`，因此修改相机参数后，下一次启动真机模型时生效；Gazebo 仍使用仿真模型中的固定相机位姿。

“恢复默认配置”使用项目文件 `wpb_home.defaults.yaml`，其内容是参数功能加入时的现有配置。每次保存或恢复前，后端还会将旧配置备份为 `wpb_home.yaml.bak`。

### 参数含义

这里的“相机零位”不是数值必须为零，也不是控制电机把相机移动到原点。由于真机相机安装关节没有向软件反馈实际位置，`wpb_home_core` 将 `zeros` 中的两个标定值当作相机当前固定关节位置，持续发布到 `/joint_states`；`robot_state_publisher` 再结合 URDF 生成相机坐标系 TF。因此，这两个数值描述的是软件认为相机所处的安装姿态，必须与真实安装高度和俯仰角一致。

| 前端名称 | 参数 | 单位 | 具体含义 |
|---|---|---|---|
| 相机高度 | `zeros.kinect_height` | m | 真机相机升降关节的固定位置。当前 URDF 将该关节方向布置为竖直方向，因此它决定软件 TF 中的主要相机高度；当前默认值为 `1.32`。 |
| 相机俯仰角 | `zeros.kinect_pitch` | rad | 真机相机俯仰关节的固定角度，默认 `-0.61rad`，约为 `-35°`。符号方向遵循 URDF 的关节轴定义。 |
| 前后位置 | `camera_mount.x` | m | 相机升降关节零位置相对 `base_link` 的 X 向安装偏移；ROS 约定 X 正方向朝机器人前方。 |
| 左右位置 | `camera_mount.y` | m | 相机升降关节零位置相对 `base_link` 的 Y 向安装偏移；ROS 约定 Y 正方向朝机器人左侧。 |
| 上下位置 | `camera_mount.z` | m | 相机升降关节零位置相对 `base_link` 的 Z 向安装偏移。当前结构中，相机最终高度近似为 `camera_mount.z + kinect_height`。 |
| 横向补偿 | `grab.grab_y_offset` | m | 抓取前底盘横向对准的附加修正量，直接加到目标 Y 位移；增大时向左修正，减小时向右修正。 |
| 抬升补偿 | `grab.grab_lift_offset` | m | 机械臂抬升目标相对识别物体高度的补偿；正值抬得更高，负值抬得更低。 |
| 前向补偿 | `grab.grab_forward_offset` | m | 机械臂抬起后，底盘向物体前进抓取距离的补偿；正值增加前进距离，负值减少。 |
| 默认夹爪闭合间距 | `grab.grab_gripper_value` | m | 执行抓取时两指闭合后的目标间距。当前码垛执行器会根据物体类型动态覆盖该 ROS 参数，因此 YAML 值主要作为默认值或独立抓取流程的配置。 |
| 抬臂稳定等待时间 | `grab.grab_hand_up_wait` | s | 机械臂抬到抓取高度后，在继续向前抓取前等待稳定的时间。 |

### 真机与仿真的区别

真机启动时，`wpb_home_core` 读取 `kinect_height` 和 `kinect_pitch`，并将其作为固定关节位置发布；`camera_mount.x/y/z` 则在启动时由 xacro 写入机器人 URDF。修改这些值不会让物理相机自动移动，而是改变软件中的相机 TF。若参数与真实安装不一致，点云、物体坐标和抓取位置会出现系统性偏差。

Gazebo 不读取上述相机参数。仿真相机在 `wpb_home_mani.model` 中使用 fixed joint，当前固定安装位置为 `0.145 -0.013 1.32`，俯仰配置也直接写在模型中。因此，修改前端的相机高度或相机安装位姿不会改变仿真模型，不是仅将该数值交给仿真后端计算，而是在仿真流程中完全不使用这组真机相机参数。若以后需要从前端同步修改仿真相机，需再将 Gazebo 模型改造成从统一配置生成。

## 仿真联调

仿真场景使用：

- 世界文件：`catkin_ws/src/gazebosim_demo/worlds/palletizing_test.world`
- 仿真标定文件：`catkin_ws/src/gazebosim_demo/config/palletizing_zones_sim.yaml`
- 默认地图：`catkin_ws/src/gazebosim_demo/maps/palletizing_map.yaml`

## 真机联调

运行统一脚本后，在前端选择“实机”并点击“连接实机”。设备检查通过后，按重新建图、保存地图、导入地图、RViz 中 `2D Pose Estimate`、保存标定、开始码垛的顺序联调；移动机器人时在前端启用“键盘控制”。

真机默认标定文件为项目根目录：

```text
/home/yubowen/BaseRos/zones.yaml
```

## 日志位置

前端操作结果会显示在页面右侧日志窗口，并以 JSON Lines 格式持久化到：

```text
/home/yubowen/BaseRos/logs/frontend_operations.log
```

文件每行对应一条日志，包含 `id`、`timestamp`、`level` 和 `message`。前端连接 ROS Bridge 后会从该文件恢复最近 100 条到卡片列表；浏览器 `localStorage` 仍作为日志服务暂时不可用时的本地副本。点击界面的清空按钮会同时清除项目日志文件与浏览器副本。

更详细的 ROS 输出在统一启动脚本打开的 “Frontend Control Services” 终端中，包括后端服务和由前端拉起的 launch 输出。

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
