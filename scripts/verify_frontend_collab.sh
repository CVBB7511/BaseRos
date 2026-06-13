#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WS_DIR="$ROOT_DIR/catkin_ws"
MAP_NAME="${1:-saved_map}"
MAP_FILE="$WS_DIR/src/se_map/maps/$MAP_NAME.yaml"
mkdir -p "$ROOT_DIR/.ros"
export ROS_HOME="$ROOT_DIR/.ros"
GAZEBO_MODEL_PATH_VALUE="$WS_DIR/src/wpr_simulation/models${GAZEBO_MODEL_PATH:+:$GAZEBO_MODEL_PATH}"
GAZEBO_RESOURCE_PATH_VALUE="$WS_DIR/src/wpr_simulation${GAZEBO_RESOURCE_PATH:+:$GAZEBO_RESOURCE_PATH}"
IGN_FUEL_CONFIG="$ROOT_DIR/.ignition/fuel/config.yaml"
mkdir -p "$(dirname "$IGN_FUEL_CONFIG")"
printf 'servers: []\n' > "$IGN_FUEL_CONFIG"

"$ROOT_DIR/scripts/build_workspace.sh"

"$ROOT_DIR/scripts/open_ros_terminal.sh" "Gazebo Simulation" \
  "cd '$WS_DIR' && export ROS_HOME='$ROS_HOME' && export GAZEBO_MODEL_DATABASE_URI='' && export GAZEBO_MODEL_PATH='$GAZEBO_MODEL_PATH_VALUE' && export GAZEBO_RESOURCE_PATH='$GAZEBO_RESOURCE_PATH_VALUE' && export IGN_FUEL_CONFIG_PATH='$IGN_FUEL_CONFIG' && source /opt/ros/noetic/setup.bash && source devel/setup.bash && roslaunch wpr_simulation wpb_stage_robocup.launch"

sleep 20

"$ROOT_DIR/scripts/open_ros_terminal.sh" "SE Map Nodes" \
  "cd '$WS_DIR' && export ROS_HOME='$ROS_HOME' && source /opt/ros/noetic/setup.bash && source devel/setup.bash && roslaunch se_map manual_mapping.launch sim:=false keyboard:=false map_name:='$MAP_NAME'"

"$ROOT_DIR/scripts/open_ros_terminal.sh" "Keyboard Control" \
  "cd '$WS_DIR' && export ROS_HOME='$ROS_HOME' && source /opt/ros/noetic/setup.bash && source devel/setup.bash && rosrun wpr_simulation keyboard_vel_ctrl _save_map_name:='$MAP_NAME'"

"$ROOT_DIR/scripts/open_ros_terminal.sh" "ROS Bridge" \
  "cd '$ROOT_DIR' && bash scripts/start_rosbridge.sh"

"$ROOT_DIR/scripts/open_ros_terminal.sh" "Live Navigation Stack" \
  "cd '$WS_DIR' && export ROS_HOME='$ROS_HOME' && source /opt/ros/noetic/setup.bash && source devel/setup.bash && echo 'Starting live-map navigation stack. It will use the current /map from gmapping.' && roslaunch se_navigation navigation.launch sim:=false live_map:=true rviz:=false map_manager:=false map_file:='$MAP_FILE'"

"$ROOT_DIR/scripts/open_ros_terminal.sh" "Frontend" \
  "cd '$ROOT_DIR' && bash scripts/start_frontend.sh"

echo "[verify_frontend_collab] opened simulation, mapping, keyboard, rosbridge, live navigation, and frontend terminals."
echo "Use the frontend at http://localhost:5173/ and the keyboard terminal for manual mapping."
