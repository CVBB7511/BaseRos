#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WS_DIR="$ROOT_DIR/catkin_ws"
mkdir -p "$ROOT_DIR/.ros" "$ROOT_DIR/real_maps"
export ROS_HOME="$ROOT_DIR/.ros"
export GAZEBO_MODEL_DATABASE_URI=""
export IGN_FUEL_CONFIG_PATH="$WS_DIR/src/gazebosim_demo/config/ign_fuel_offline.yaml"
export GZ_FUEL_CONFIG_PATH="$WS_DIR/src/gazebosim_demo/config/ign_fuel_offline.yaml"

"$ROOT_DIR/scripts/build_workspace.sh"

"$ROOT_DIR/scripts/open_ros_terminal.sh" "ROS Core" \
  "export ROS_HOME='$ROS_HOME' && source /opt/ros/noetic/setup.bash && roscore"

sleep 3

if ! pgrep -af "roslaunch gazebosim_demo palletizing_sim_world.launch" >/dev/null 2>&1; then
  "$ROOT_DIR/scripts/open_ros_terminal.sh" "Gazebo Simulation" \
    "cd '$WS_DIR' && export ROS_HOME='$ROS_HOME' && export GAZEBO_MODEL_DATABASE_URI='' && export IGN_FUEL_CONFIG_PATH='$IGN_FUEL_CONFIG_PATH' && export GZ_FUEL_CONFIG_PATH='$GZ_FUEL_CONFIG_PATH' && source /opt/ros/noetic/setup.bash && source devel/setup.bash && roslaunch gazebosim_demo palletizing_sim_world.launch"
  sleep 12
else
  echo "[verify_sim_frontend_mapping] existing Gazebo simulation launch detected; reusing it."
fi

"$ROOT_DIR/scripts/open_ros_terminal.sh" "Frontend Control Services" \
  "cd '$WS_DIR' && export ROS_HOME='$ROS_HOME' && source /opt/ros/noetic/setup.bash && source devel/setup.bash && rosrun mapping frontend_control_server.py _root_dir:='$ROOT_DIR' _workspace_dir:='$WS_DIR' _default_map_dir:='$ROOT_DIR/real_maps'"

"$ROOT_DIR/scripts/open_ros_terminal.sh" "ROS Bridge" \
  "cd '$ROOT_DIR' && bash scripts/start_rosbridge.sh"

"$ROOT_DIR/scripts/open_ros_terminal.sh" "Frontend" \
  "cd '$ROOT_DIR' && bash scripts/start_frontend.sh"

echo "[verify_sim_frontend_mapping] opened roscore, one Gazebo simulation, frontend services, rosbridge, and frontend."
echo "Open the frontend URL, connect ROS Bridge, choose 仿真, click 重新建图, then enable 前端键盘控制."
