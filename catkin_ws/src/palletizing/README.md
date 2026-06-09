### 目录结构

```
~/catkin_ws
├── build/
├── devel/
└── src
    ├── CMakeLists.txt -> /opt/ros/noetic/share/catkin/cmake/toplevel.cmake
    ├── palletizing/
    ├── waterplus_map_tools/
    ├── wpb_home/
    └── wpr_simulation/
```

### 部署

clone 三个官方包和 `palletizing`，按如上目录结构组织，在 `catkin_ws` 下运行 `catkin_make`

### 仿真运行

保证各终端均运行过 `source devel/setup.bash`，以从 A 处向 B 处运送红色方块为例

- 终端 1: `roslaunch palletizing warehouse_sim.launch`
- 终端 2: `roslaunch palletizing palletizing.launch`
- 终端 3: `rostopic pub /palletizing/task_manager_node/add_task std_msgs/String "data: 'A,red_block,B'" --once`


`palletizing\config\palletizing_params.yaml` 中包括若干可调节参数，例如
- `spawner` 可以调节各区域的方块数量

### 实机运行

**环境准备**：
- 在 Windows 下打开 WSL Settings，将网络模式设置为 `Mirrored`，以保证 WSL 与主机共享 IP
- 使用移动热点连接两端设备，避免校园网的局域网隔离策略
- 笔记本端需关闭防火墙（至少放行机载电脑 IP），确保机载电脑可以 Ping 通笔记本
- 获取机载电脑 IP（下称 `ROBOT_IP`）和笔记本 IP（下称 `LAPTOP_IP`）

**代码同步**：
- 使用 `rsync` 命令将本地代码同步到机载电脑，例如：
    ```bash
    rsync -av --exclude='.git/' ./src/palletizing/ robot6@ROBOT_IP:~/catkin_ws/src/palletizing
    ```
- 或使用 `git` 获取代码

**环境变量配置**：
- 机载电脑终端：`export ROS_IP=ROBOT_IP`
- 笔记本所有终端：`export ROS_MASTER_URI=http://ROBOT_IP:11311` 且 `export ROS_IP=LAPTOP_IP`

**操作流程**：

**1. 远程建图**：
- 终端 1 (SSH 登录): `roslaunch palletizing warehouse_slam_real.launch`
- 终端 2 (本地终端): `rosrun rviz rviz -d $(rospack find wpb_home_tutorials)/rviz/slam.rviz`
- 终端 3 (SSH 登录): `rosrun palletizing keyboard_teleop.py` 控制移动
- 终端 4 (SSH 登录): 建图完成后运行 `rosrun map_server map_saver -f warehouse_real` 保存地图

**2. 任务执行**：
- 终端 1 (SSH 登录): `roslaunch palletizing warehouse_real.launch`
- 终端 2 (本地终端): `rosrun rviz rviz -d $(rospack find wpb_home_tutorials)/rviz/nav.rviz`
- 终端 3 (本地或 SSH):
    - 初始化定位：在笔记本 RViz 中点击 `2D Pose Estimate`
    - 下发命令：`rostopic pub /palletizing/task_manager_node/add_task std_msgs/String "data: 'A,red_block,B'" --once`

### 特殊说明

仿真环境存在若干bug，例如：
- 环境生成时，方块可能会穿模掉到桌子下，可以手动将方块移动到桌上
- 有时会出现方块正常显示但视觉识别模块检测不到的情况，手动将方块向上提一下，可能会触发某种刷新，从而使方块成功被识别。可以考虑运行码垛之前扰动一下任意一个方块，以避免该情况发生

### 图形化操作终端 (GUI)

本系统提供了一个免 rosbridge 依赖、基于 Python Tkinter 的原生图形化操作前端，方便在开发机上进行直观的操控、状态监视及图像反馈。

**1. 准备依赖**：
启动前请确保本地环境安装了 Tkinter 及其图片支持库：
```bash
sudo apt install python3-tk python3-pil python3-pil.imagetk
```

**2. 启动终端**：
在仿真或实机环境启动后（即 `task_manager_node` 在线），在本地终端运行：
```bash
rosrun palletizing gui_frontend.py
```
*注：若提示权限不足，请先执行 `chmod +x gui_frontend.py` 赋予其执行权限。*

**3. 模块功能及操作说明**：
- **系统状态监控**：
  - 实时显示系统当前的运行状态（如 `IDLE`、`NAVIGATING_TO_OBSERVE` 等）与任务的具体执行进度。
  - **🔴 紧急停机**：点击会立刻强制中断所有正在执行的自主 Action 并安全死停底盘和机械臂，同时锁定自主流程。此时不影响人工键盘遥控。
  - **🟢 恢复正常 (复位)**：点击后取消当前异常，机械臂自动安全复位至初始收纳姿态，系统重新就绪重归 `IDLE` 状态。
- **下发自动码垛任务**：
  - 支持下拉框卡片化选择“源区域”（A区/B区/C区）、“货物类型”（红色方块/绿色方块）和“目标区域”，默认预设为**红色方块从A区运送到B区**。
  - 点击“发送任务”即可直接指派码垛任务入队，免去了手动拼接并发布 `rostopic pub` 的繁琐过程。
- **键盘遥控底盘**：
  - 点击“开启遥控”按钮后激活按键捕获（控制速度已锁定为安全默认值：线速度 0.2 m/s，角速度 0.3 rad/s）。
  - 在控制终端窗口处于焦点时，按键盘 `W/S` 控制前后移动，`A/D` 控制左右平移，`Q/E` 控制原地旋转，按 `空格键` 紧急煞车。
  - 点击“关闭遥控”后会自动发布零速以平稳停车，并解除键盘监听事件。
- **视觉监控 (摄像头画面)**：
  - 提供了话题下拉菜单，支持选择 `/kinect2/qhd/image_color_rect` (默认) 和 `/kinect2/hd/image_color_rect`。
  - 点击“打开画面”可即时在右侧面板中渲染三维摄像头的实时彩色影像。
  - **⚡ 算力守护设计**：点击“关闭画面”后，系统不仅会隐藏显示，还会**在后台直接销毁注销 ROS Image 订阅器**，从而彻底断开图像传输连接，确保在不需要时为底盘算法与视觉识别释放宝贵的带宽和 CPU 算力。

