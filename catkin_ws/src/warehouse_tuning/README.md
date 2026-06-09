# Warehouse Tuning

现场调参包，用来生成实机部署前需要的地图、A/B/C 区域位姿和小方块视觉参数。

实验室真机优先看：

```text
warehouse_tuning/REAL_ROBOT_START_HERE.md
```

那份文档从“解压 zip、编译、启动底层、建图、定位、标定、分拣”开始写完整命令，可以直接复制执行。

实机流程不依赖 Gazebo。现场只运行：

```text
warehouse_tuning field_robot_base.launch
warehouse_tuning field_calibration_wizard.py
arm_grab_task stack_sort_field.launch
```

文件名带 `sim`、`demo`、`acceptance` 的脚本/launch 只用于本机仿真验收，不要在真机上启动。

## 推荐：一条命令标定

先按 `REAL_ROBOT_START_HERE.md` 启动终端 1 的真机底层：

```bash
roslaunch warehouse_tuning field_robot_base.launch \
  start_core:=true start_lidar:=true start_kinect:=true start_joy:=true
```

然后在另一个终端运行向导：

```bash
source ~/catkin_ws/devel/setup.bash
rosrun warehouse_tuning field_calibration_wizard.py \
  --manage-stack \
  --keep-managed-stack \
  --rviz \
  --map-prefix $HOME/maps/lab \
  --zone-file $HOME/maps/abc_zones.yaml \
  --feature-file $HOME/maps/cargo_features.yaml \
  --table-height 0.78
```

向导需要读取键盘输入，建议用 `rosrun` 启动，不要把它作为普通 `roslaunch` node 挂到后台。实机分拣前不要关闭这个终端，它保留 AMCL 定位。

向导会按顺序完成：

1. 建图：终端持续显示地图尺寸、覆盖率和占用点数量；RViz 地图稳定后按回车保存。
2. 定位：自动重载刚保存的地图并启动 AMCL；在 RViz 用 `2D Pose Estimate` 设置初始位姿，终端收到 `/amcl_pose` 后才进入下一步。
3. A/B/C 区域：把机器人开到对应桌子前，按回车采集；终端会显示采到的 `x/y/yaw`。
4. 小方块特征：每次只放一种颜色到 ROI 中心，按回车采集；终端会显示 HSV 范围、估计尺寸和 debug 图路径。

如果地图已经建好，只重新做定位和标定：

```bash
rosrun warehouse_tuning field_calibration_wizard.py \
  --manage-stack \
  --keep-managed-stack \
  --skip-mapping \
  --rviz \
  --map-prefix $HOME/maps/lab \
  --zone-file $HOME/maps/abc_zones.yaml \
  --feature-file $HOME/maps/cargo_features.yaml
```

向导状态也会发布到：

```text
/warehouse_tuning/field_calibration_status
/warehouse_tuning/mapping_status
/warehouse_tuning/abc_zone_status_A
/warehouse_tuning/abc_zone_status_B
/warehouse_tuning/abc_zone_status_C
/warehouse_tuning/cargo_feature_status_green
/warehouse_tuning/cargo_feature_status_blue
```

标定完成后直接用生成文件启动实机分拣：

```bash
roslaunch arm_grab_task stack_sort_field.launch \
  use_field_override:=true field_override:=$HOME/maps/abc_zones.yaml \
  use_feature_override:=true feature_override:=$HOME/maps/cargo_features.yaml \
  rviz:=true
```

常用调整：

```bash
# 桌高
--table-height 0.76

# 堆叠点离机器人更远/更近
--stack-anchor-forward-offset 0.54

# 相机 ROI，比例坐标
--feature-roi-x 0.35 --feature-roi-y 0.30 --feature-roi-width 0.30 --feature-roi-height 0.35

# 如果相机 topic 不同
--rgb-topic /camera/color/image_raw --depth-topic /camera/depth/image_raw --camera-info-topic /camera/color/camera_info
```

交互按键：`回车` 确认，`r` 重做当前提示，`s` 跳过当前项，`q` 退出。

## 0. 仿真全链路验收

在实验室上机前，可以先跑完整流程：仿真建图、保存地图、重新加载地图定位、设置初始位姿、采集 A/B/C、采集小方块特征、加载生成配置并完成分拣。

真实仿真建图演示：机器人会发布 `/cmd_vel` 沿航点巡航，`slam_gmapping` 使用 `/scan` 和 `/odom` 更新 `/map`，再保存地图。`--box-layout jittered` 会按 seed 扰动 6 个箱子在 A 桌上的位置。

```bash
source ~/catkin_ws/devel/setup.bash
rosrun arm_grab_task run_stack_sort_field_tuning_acceptance.py \
  --mapping-mode gmapping \
  --mapping-route short_loop \
  --box-layout jittered \
  --box-seed 11 \
  --timeout 900 \
  --expected-per-color 3
```

复杂地图逻辑压测：这里使用 mock map 生成复杂占用栅格，用来压测地图保存、重载、定位、A/B/C 配置和分拣链路，不代表机器人真实绕场建图。

```bash
rosrun arm_grab_task run_stack_sort_field_tuning_acceptance.py \
  --mapping-mode mock \
  --map-profile complex_lab \
  --box-layout jittered \
  --box-seed 21 \
  --timeout 900 \
  --expected-per-color 3
```

通过后会输出 `PASS`，并生成：

```text
/tmp/warehouse_tuning_sim/lab.yaml
/tmp/warehouse_tuning_sim/abc_zones.yaml
/tmp/warehouse_tuning_sim/cargo_features.yaml
/tmp/warehouse_tuning_sim/debug_images/
```

定位验证看两行日志：`localization seed from current robot pose=(...)` 表示建图结束时机器人在地图中的初始估计，`initial pose verified` 表示 `/amcl_pose` 已接受该初始位姿。实机上这一步对应 RViz 的 `2D Pose Estimate`。

仿真采集小方块特征时，验收脚本会显式打开仿真回退参数。向导和手动服务的实机默认值都是 `allow_simulated_fallback:=false`，现场采集必须让样品进入相机 ROI。

## 手动排障流程

下面这些命令保留给排障使用。正常现场标定优先用上面的 `field_calibration_wizard.py`。

### 1. 建图

实机建图要让机器人实际走过 A/B/C 三张桌子的通道，不要只原地转。保存地图前确认 RViz 里地图边界、桌子/墙体轮廓已经稳定。

```bash
roslaunch warehouse_tuning mapping_session.launch map_prefix:=$HOME/maps/lab
rosservice call /warehouse_tuning/save_map
```

生成 `$HOME/maps/lab.yaml` 和 `$HOME/maps/lab.pgm`。如果已经手动启动 gmapping：

```bash
roslaunch warehouse_tuning mapping_session.launch start_gmapping:=false map_prefix:=$HOME/maps/lab
```

重新加载地图后，必须给初始位姿，否则机器人只知道地图，不知道自己在地图中的位置。实机如果用 AMCL，就在 RViz 用 `2D Pose Estimate`，或用等价的 `/initialpose` 发布工具。确认 `/amcl_pose` 已接近实际位置后，再采集 A/B/C。

### 2. 标定 A/B/C 区域

把机器人手动开到对应桌子前，车头朝向桌面中心。每次只开一个采集节点，然后调用服务。

```bash
roslaunch warehouse_tuning abc_zone_capture.launch zone_name:=A zone_role:=source table_height:=0.78 output_file:=$HOME/maps/abc_zones.yaml
rosservice call /warehouse_tuning/capture_abc_zone

roslaunch warehouse_tuning abc_zone_capture.launch zone_name:=B zone_role:=drop color:=green table_height:=0.78 output_file:=$HOME/maps/abc_zones.yaml
rosservice call /warehouse_tuning/capture_abc_zone

roslaunch warehouse_tuning abc_zone_capture.launch zone_name:=C zone_role:=drop color:=blue table_height:=0.78 output_file:=$HOME/maps/abc_zones.yaml
rosservice call /warehouse_tuning/capture_abc_zone
```

生成文件里的 `stack_sort_pipeline.tabletop_return_base_target`、`tabletop_drop_base_targets`、`tabletop_stack_anchors` 可以作为实机覆盖参数。
如果堆叠位置不在桌面中心，调整 `stack_anchor_forward_offset` 后重新采 B/C。

### 3. 采集小方块特征

把一种小方块单独放到画面中心 ROI 内，分别采集：

```bash
roslaunch warehouse_tuning cargo_feature_capture.launch cargo_type:=green output_file:=$HOME/maps/cargo_features.yaml
rosservice call /warehouse_tuning/capture_cargo_features

roslaunch warehouse_tuning cargo_feature_capture.launch cargo_type:=blue output_file:=$HOME/maps/cargo_features.yaml
rosservice call /warehouse_tuning/capture_cargo_features
```

生成文件会同时写入 `warehouse_sorting.cargo_types`、`stack_sort_pipeline.color_ranges` 和 `stack_sort_pipeline.field_dimensions.box_size`，可作为实机覆盖参数加载。
如果采集失败，启动时加 `save_debug_images:=true debug_output_dir:=$HOME/maps/debug_images`，先看截图里目标是否在 ROI 内，再调 ROI、灯光或 HSV padding。

### 4. 实机启动和观察

```bash
roslaunch arm_grab_task stack_sort_field.launch \
  use_field_override:=true field_override:=$HOME/maps/abc_zones.yaml \
  use_feature_override:=true feature_override:=$HOME/maps/cargo_features.yaml \
  rviz:=true
rostopic echo /stack_sort/status
```

RViz 看 `/stack_sort/markers`，终端看 `/stack_sort/status`。日志重点看 `[CONFIG]`、`[STATE]`、`[PICK]`、`[PHYS-GRASP]`、`[DROP]`、`[METRICS]`。

也可以把 A/B/C 位姿和小方块特征的两段 `stack_sort_pipeline` 合并到同一个现场覆盖文件，只加载一次。

常改参数在 `config/lab_tuning.yaml` 和 `arm_grab_task/config/stack_sort_abc_tabletop_params.yaml`：相机 topic、ROI、HSV padding、桌高、箱体尺寸、夹爪开合、取放高度、堆叠层高。
