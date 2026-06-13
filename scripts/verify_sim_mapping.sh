#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WS_DIR="$ROOT_DIR/catkin_ws"
MAP_NAME="${1:-saved_map}"
mkdir -p "$ROOT_DIR/.ros"
export ROS_HOME="$ROOT_DIR/.ros"

"$ROOT_DIR/scripts/build_workspace.sh"

source /opt/ros/noetic/setup.bash
source "$WS_DIR/devel/setup.bash"

"$ROOT_DIR/scripts/open_ros_terminal.sh" "SE Map Launch" \
  "cd '$WS_DIR' && source /opt/ros/noetic/setup.bash && source devel/setup.bash && roslaunch se_map manual_mapping.launch sim:=true keyboard:=true map_name:='$MAP_NAME'"

sleep 20

"$ROOT_DIR/scripts/open_ros_terminal.sh" "Keyboard Control" \
  "cd '$WS_DIR' && source /opt/ros/noetic/setup.bash && source devel/setup.bash && rosrun wpr_simulation keyboard_vel_ctrl _save_map_name:='$MAP_NAME'"

echo "[verify_sim_mapping] opened mapping terminals."
echo "[verify_sim_mapping] keyboard_vel_ctrl starts 20 seconds after Gazebo launch."
echo "Use the keyboard terminal to drive the robot. Press 'm' in keyboard_vel_ctrl to save the map."
