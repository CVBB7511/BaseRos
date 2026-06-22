# 前端参数在旧版与现版流程中的使用方式

本文中的“旧版”特指加入前端参数配置服务 `/frontend/robot_parameters` 之前的上一版代码；“现版”指当前已经支持前端读取、保存和恢复机器人参数的代码。

## 参数来源

涉及的参数分为三组：

| 参数组 | 参数 | 主要使用者 |
|---|---|---|
| 相机零位 | `zeros.kinect_height`、`zeros.kinect_pitch` | 真机 `wpb_home_core` 和 `robot_state_publisher` |
| 相机安装位置 | `camera_mount.x/y/z` | 真机 URDF/xacro 和 `robot_state_publisher` |
| 抓取参数 | `grab_y_offset`、`grab_lift_offset`、`grab_forward_offset`、`grab_gripper_value`、`grab_hand_up_wait` | `wpb_home_grab_action` 和码垛执行器 |

相机零位和安装位置改变的是软件中的相机 TF，不会驱动物理相机移动。Gazebo 使用独立的 `wpb_home_mani.model`，其中相机高度和俯仰都是 fixed joint，不读取上述真机相机参数。

## 旧版流程

### 前端本身

旧版前端只保存“仿真/实机”模式，并在重新建图或导入地图时把 `sim` 布尔值交给后端。它不读取、不显示、也不写入 `wpb_home.yaml` 或 URDF，因此参数只能由开发人员直接修改文件。

### 旧版仿真

1. 启用仿真时，`palletizing_sim_world.launch` 直接用 `wpb_home_mani.model` 生成机器人。
2. 模型内的相机位姿固定为 `xyz="0.145 -0.013 1.32"` 和 `rpy="0 0.61 0"`。
3. `zeros.kinect_height`、`zeros.kinect_pitch` 以及真机 URDF 中的相机 `x/y/z` 均不参与 Gazebo 模型生成，也不进入仿真后端计算。
4. 导入地图后，仿真执行 launch 会把 `wpb_home.yaml` 加载到 `/wpb_home_grab_action` 的私有参数空间，抓取动作通过 `LoadGrabParams()` 读取这些参数。
5. 旧版仿真 launch 随后又覆盖 `grab_lift_offset=0.0`、`grab_forward_offset=0.0` 和 `grab_hand_up_wait=4.0`，所以这些字段的最终值优先采用 launch，而不一定采用 YAML。
6. 每次抓取前，`palletizing_executor.py` 还会按物体类型设置 `grab_open_value` 和 `grab_gripper_value`，因此 YAML 中的 `grab_gripper_value` 主要是默认值。

旧版仿真参数优先级可以概括为：

```text
Gazebo 相机：wpb_home_mani.model 固定值
普通抓取补偿：程序默认值 < wpb_home.yaml < launch 覆盖值
夹爪闭合间距：程序默认值 < wpb_home.yaml < 码垛执行器运行时值
```

### 旧版实机

1. 启动真机建图或执行流程时，launch 使用 xacro 加载 `wpb_home.urdf`。当时相机安装位置 `x=0.170、y=-0.100、z=0` 直接硬编码在 URDF 中，前端无法修改。
2. 同一个 launch 把 `wpb_home.yaml` 加载到 `/wpb_home_core` 的私有参数空间。
3. `wpb_home_core` 启动时读取 `zeros.kinect_height` 和 `zeros.kinect_pitch`，保存为相机两个关节的固定位置，并持续发布到 `/joint_states`。
4. `robot_state_publisher` 将硬编码的 URDF 安装位置和 `/joint_states` 中的高度、俯仰组合成相机 TF。视觉点云和物体坐标变换间接使用该 TF。
5. 在码垛执行阶段，`wpb_home.yaml` 还会加载到 `/wpb_home_grab_action`，但旧版真机 launch 随后覆盖 `grab_y_offset=0.0`、`grab_lift_offset=0.0`、`grab_forward_offset=0.0` 和 `grab_hand_up_wait=15.0`。
6. `grab_gripper_value` 仍会在每次抓取前被码垛执行器按物体类型动态设置。

因此旧版虽然存在 `wpb_home.yaml`，但它并不是所有抓取参数的最终唯一来源。例如 YAML 中的等待时间为 `4s`，旧版真机码垛实际采用的是 launch 覆盖后的 `15s`。

### 旧版 `palletizing_execute_real.launch` 命令展开

旧版前端在实机执行阶段使用的核心命令为：

```bash
roslaunch gazebosim_demo palletizing_execute_real.launch \
  map_file:=/home/yubowen/BaseRos/real_maps/real_map.yaml
```

这里的反斜杠只是 Shell 的换行续写符，`map_file` 是传给 launch 的参数。该命令虽然从 `gazebosim_demo` 包中寻找 launch 文件，但启动文件本身明确是**真机执行流程**：它不启动 Gazebo、不设置 `/use_sim_time`，而是直接启动 `/dev/ftdi` 底盘与机械臂驱动、`/dev/rplidar` 激光雷达和 Kinect2 驱动。因此，它的参数使用方式与本章所述“旧版实机”相同，而不是旧版仿真。

启动和参数传递过程如下：

1. `roslaunch` 解析 `palletizing_execute_real.launch`，将命令行中的地图路径赋给 launch 参数 `map_file`。
2. `map_server` 以 `args="$(arg map_file)"` 启动，读取 `real_map.yaml` 及其中引用的图像文件并发布 `/map`。`map_file` 只决定定位所用地图，不会修改 `wpb_home.yaml`，也不会影响相机和抓取参数。
3. launch 读取旧版 `wpb_home.urdf` 生成 `/robot_description`，再启动 `robot_state_publisher`。当时相机安装偏移 `x=0.170、y=-0.100、z=0` 硬编码在 URDF 的 `kinect_height` 关节原点中。
4. launch 启动真机节点 `wpb_home_core`，并在其私有参数空间加载整份 `wpb_home.yaml`。核心节点实际读取 `/wpb_home_core/zeros/kinect_height` 和 `/wpb_home_core/zeros/kinect_pitch`，将它们作为没有位置反馈的相机关节值持续发布到 `/joint_states`。
5. `robot_state_publisher` 将 `/robot_description` 中硬编码的相机安装偏移与 `/joint_states` 中的相机高度、俯仰组合，发布相机坐标系 TF。Kinect 点云识别和物体坐标变换通过 TF 间接使用这些相机参数。
6. launch 启动 `wpb_home_grab_action`，再次把同一份 `wpb_home.yaml` 加载到该节点的私有参数空间。这里使用的是 `/wpb_home_grab_action/grab/*`，与 `wpb_home_core` 的私有参数副本互不共享。
7. YAML 加载之后，旧版 launch 又写入 `grab_y_offset=0.0`、`grab_lift_offset=0.0`、`grab_forward_offset=0.0` 和 `grab_hand_up_wait=15.0`，覆盖 YAML 中的同名字段。`grab_align_timeout=15.0` 则只在 launch 中配置。
8. `palletizing_executor.py`、AMCL、`move_base`、物体检测及抓放节点随后启动。用户在 RViz 完成 `2D Pose Estimate` 后，AMCL 使用地图和传感器数据定位；开始码垛时，执行器导航到桌面、触发点云检测并调用抓放动作。
9. 每次抓取前，码垛执行器还会按识别到的物体类型动态写入 `/wpb_home_grab_action/grab/grab_open_value` 和 `grab_gripper_value`。因此夹爪间距最终采用运行时值，而不是 YAML 中的初始值。

这条旧版命令中相关参数的最终来源可概括为：

```text
定位地图：命令行 map_file -> map_server -> /map
相机安装 x/y/z：旧版 wpb_home.urdf 硬编码值
相机高度/俯仰零位：wpb_home.yaml -> wpb_home_core -> /joint_states -> TF
抓取横移/抬升/前移/等待：wpb_home.yaml -> launch 同名参数覆盖
夹爪闭合间距：wpb_home.yaml -> palletizing_executor.py 运行时覆盖
```

需要特别区分的是，旧版仿真会由 Gazebo 的 `wpb_home_mani.model` 生成机器人，相机位姿直接取模型中的 fixed joint，也不会启动 `wpb_home_core`、真实雷达或 Kinect2 驱动。二者可能复用相同的抓取、导航和码垛节点，但相机模型、硬件驱动、时间源及参数生效链路不同。

## 现版流程

### 前端保存阶段

1. 用户连接 ROS Bridge，打开顶部设置窗口的“机器人参数”页。
2. 前端调用 `/frontend/robot_parameters` 的 `get` 操作，后端从 `wpb_home.yaml` 读取当前值。
3. 用户保存时，前端发送 `save`；恢复默认时发送 `restore`，默认值来自 `wpb_home.defaults.yaml`。
4. 后端只允许在仿真和实机均停用、且没有建图或执行进程时写入。
5. 后端校验数值范围，先备份旧文件为 `wpb_home.yaml.bak`，再通过临时文件和原子替换更新 `wpb_home.yaml`。
6. 参数不会热更新到已经启动的节点，保存结果在下一次启用实机或启动对应任务时生效。

### 现版仿真

1. Gazebo 相机仍由 `wpb_home_mani.model` 的 fixed joint 决定。
2. 修改 `kinect_height`、`kinect_pitch` 或 `camera_mount.x/y/z` 不会改变 Gazebo 中的相机，也不会进入仿真后端计算。
3. 启动仿真执行流程时，`wpb_home.yaml` 会加载到 `/wpb_home_grab_action`。
4. 现版已经移除 launch 对 YAML 抓取字段的重复覆盖，因此横向、抬升、前向和等待时间均以 YAML 为配置来源。
5. `grab_gripper_value` 仍会被码垛执行器按物体类型动态覆盖，这是任务逻辑有意保留的行为。

现版仿真参数优先级为：

```text
Gazebo 相机：wpb_home_mani.model 固定值
普通抓取补偿：程序默认值 < wpb_home.yaml
夹爪闭合间距：程序默认值 < wpb_home.yaml < 码垛执行器运行时值
```

### 现版实机

1. `camera_mount.x/y/z` 已从 URDF 硬编码迁入 `wpb_home.yaml`。
2. 真机 launch 启动时运行 xacro；`wpb_home.urdf` 读取 `camera_mount` 并生成 `robot_description`。
3. launch 同时把 YAML 加载到 `/wpb_home_core`。核心节点读取相机高度和俯仰零位，持续发布对应 `/joint_states`。
4. `robot_state_publisher` 组合 `camera_mount`、`kinect_height` 和 `kinect_pitch`，生成最终相机 TF。
5. 执行流程把同一份 YAML 加载到 `/wpb_home_grab_action`。现版 launch 不再覆盖前端可配置的抓取字段，所以 YAML 是这些参数的统一持久化来源。
6. 开始抓取后，动作节点在每次抓取回调开始时从 ROS 参数服务器读取抓取参数；夹爪闭合间距仍可能先被执行器按物体类型更新。

现版实机参数优先级为：

```text
相机安装位置：wpb_home.yaml -> xacro/URDF -> robot_description
相机零位：wpb_home.yaml -> wpb_home_core -> /joint_states
最终相机位姿：robot_description + /joint_states -> robot_state_publisher -> TF
普通抓取补偿：程序默认值 < wpb_home.yaml
夹爪闭合间距：程序默认值 < wpb_home.yaml < 码垛执行器运行时值
```

## 前后版本对比

| 参数/行为 | 旧版仿真 | 旧版实机 | 现版仿真 | 现版实机 |
|---|---|---|---|---|
| 前端读取和保存参数 | 不支持 | 不支持 | 支持 | 支持 |
| 相机零位生效 | 不生效 | 通过 `/joint_states` 生效 | 不生效 | 通过 `/joint_states` 生效 |
| 相机安装 `x/y/z` | 仿真模型固定 | URDF 硬编码 | 仿真模型固定 | YAML 经 xacro 写入 URDF |
| 抓取补偿来源 | YAML 后可能被 launch 覆盖 | YAML 后可能被 launch 覆盖 | YAML | YAML |
| 夹爪闭合间距 | 执行器可动态覆盖 | 执行器可动态覆盖 | 执行器可动态覆盖 | 执行器可动态覆盖 |
| 恢复默认配置 | 不支持 | 不支持 | 支持 | 支持 |

## 生效时机

- 相机安装位置由 xacro 在 launch 启动时写入 `robot_description`，必须重新启动真机流程才会更新。
- 相机零位由 `wpb_home_core` 在启动时读取，必须重新启动该节点才会更新。
- 抓取 YAML 由 launch 加载到 ROS 参数服务器，修改文件后必须重新启动执行流程；仅修改文件不会自动更新正在运行的 ROS 参数。
- 前端为避免“文件已修改、节点仍使用旧值”的混合状态，在运行环境启用期间禁止保存或恢复参数。
