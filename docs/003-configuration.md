# 配置信息

本文记录课程项目验收时需要复现的环境配置。建议提交时保留 `package.json`、`pnpm-lock.yaml`、`.nvmrc` 和 `.env.development`，不要提交 `node_modules/`、`dist/`、catkin 编译产物和临时地图。

## ROS 环境

目标环境：

- Ubuntu 20.04
- ROS Noetic
- Python 3.8
- catkin_make

常用系统依赖：

```bash
sudo apt-get update
sudo apt-get install ros-noetic-rosbridge-suite ros-noetic-slam-gmapping ros-noetic-map-server
```

每个 ROS 终端都需要加载环境：

```bash
source /opt/ros/noetic/setup.bash
cd BaseRos/catkin_ws
source devel/setup.bash
```

## 前端依赖方案

当前前端路径：`BaseRos/frontend`

已固定的复现入口：

- `.nvmrc`：`24`
- `package.json`：`packageManager` 为 `pnpm@10.12.1`
- `pnpm-lock.yaml`：锁定实际依赖版本

推荐安装流程：

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.5/install.sh | bash
source ~/.bashrc
nvm install 24
nvm use 24
corepack enable
corepack prepare pnpm@10.12.1 --activate
cd BaseRos/frontend
pnpm install --store-dir .pnpm-store
pnpm run build
```

当前 lockfile 中的主要版本：

- Vue：`3.5.38`
- Vite：`7.3.5`
- TypeScript：`5.9.3`
- Vuetify：`3.12.8`
- Pinia：`2.3.1`
- roslib：`1.4.1`
- `@vitejs/plugin-vue`：`6.0.7`
- `vite-plugin-vuetify`：`2.1.3`
- `vue-tsc`：`2.2.12`

启动前端：

```bash
cd BaseRos
bash scripts/start_frontend.sh
```

或者手动启动：

```bash
cd BaseRos/frontend
pnpm run dev --host 0.0.0.0
```

## 前端环境变量

当前 `.env.development` 和 `.env.production` 使用同一组默认值：

```env
VITE_ROSBRIDGE_URL=ws://localhost:9090
VITE_DEFAULT_MAP_FRAME=map
VITE_DEFAULT_BASE_FRAME=base_footprint
VITE_MAP_FIT_SCALE=18.0
VITE_ENABLE_DEBUG=false
```

如果前端运行在另一台电脑，`localhost` 应改为运行 ROS 和 rosbridge 的实验室电脑 IP，例如：

```env
VITE_ROSBRIDGE_URL=ws://192.168.1.20:9090
```

## ROS 关键参数

建图入口：

```bash
roslaunch se_map manual_mapping.launch sim:=true
roslaunch se_map manual_mapping.launch sim:=false real_bringup:=true
```

导航入口：

```bash
roslaunch se_navigation navigation.launch sim:=true map_file:=$(rospack find se_map)/maps/saved_map.yaml
roslaunch se_navigation navigation.launch sim:=false real_bringup:=true map_file:=$(rospack find se_map)/maps/saved_map.yaml
```

live-map 导航用于前端协同流程：

```bash
roslaunch se_navigation navigation.launch sim:=false live_map:=true rviz:=false
```

默认 frame：

- 地图：`map`
- 里程计：`odom`
- 机器人：`base_footprint`
- 雷达：由底盘和雷达 launch 发布

## 实机串口配置

默认值：

- `BASE_SERIAL_PORT=/dev/ftdi`
- `LIDAR_SERIAL_PORT=/dev/rplidar`
- `LIDAR_SERIAL_BAUDRATE=115200`

临时覆盖：

```bash
BASE_SERIAL_PORT=/dev/ttyUSB0 \
LIDAR_SERIAL_PORT=/dev/ttyUSB1 \
LIDAR_SERIAL_BAUDRATE=115200 \
bash scripts/verify_real_frontend_collab.sh real_map
```

如果实验室电脑使用 udev 规则提供 `/dev/ftdi` 和 `/dev/rplidar`，优先使用稳定别名，减少 USB 插拔顺序变化导致的问题。

## 地图与提交建议

默认地图保存目录：

```text
BaseRos/catkin_ws/src/se_map/maps/
```

手工建图生成的 `.pgm` 和 `.yaml` 通常是验收运行产物，不建议直接提交到主分支。需要保留示例地图时，应单独命名并确认体积合理。

## Gazebo 网络配置

仿真前端联调脚本会尽量使用本地模型路径和空 Fuel 配置，避免启动时访问：

- `fuel.ignitionrobotics.org`
- `fuel.gazebosim.org`

如果仍出现 `libcurl: (28)` 超时，只要 Gazebo 场景和机器人已经正常显示，一般不影响后续前端联调；如果模型缺失，则优先检查本地模型路径是否完整。
