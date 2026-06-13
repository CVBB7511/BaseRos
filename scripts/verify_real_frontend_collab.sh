#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WS_DIR="$ROOT_DIR/catkin_ws"
MAP_NAME="${1:-real_map}"
MAP_FILE="$WS_DIR/src/se_map/maps/$MAP_NAME.yaml"
REAL_BRINGUP="${REAL_BRINGUP:-true}"
BASE_SERIAL_PORT="${BASE_SERIAL_PORT:-/dev/ftdi}"
LIDAR_SERIAL_PORT="${LIDAR_SERIAL_PORT:-/dev/rplidar}"
LIDAR_SERIAL_BAUDRATE="${LIDAR_SERIAL_BAUDRATE:-115200}"

mkdir -p "$ROOT_DIR/.ros"
export ROS_HOME="$ROOT_DIR/.ros"

"$ROOT_DIR/scripts/build_workspace.sh"

echo "[verify_real_frontend_collab] map name: $MAP_NAME"
echo "[verify_real_frontend_collab] real bringup: $REAL_BRINGUP"
echo "[verify_real_frontend_collab] base serial: $BASE_SERIAL_PORT"
echo "[verify_real_frontend_collab] lidar serial: $LIDAR_SERIAL_PORT @ $LIDAR_SERIAL_BAUDRATE"
echo "[verify_real_frontend_collab] If hardware is already running, use: REAL_BRINGUP=false bash scripts/verify_real_frontend_collab.sh $MAP_NAME"

"$ROOT_DIR/scripts/open_ros_terminal.sh" "Real Mapping + Bringup" \
  "cd '$WS_DIR' && export ROS_HOME='$ROS_HOME' && source /opt/ros/noetic/setup.bash && source devel/setup.bash && roslaunch se_map manual_mapping.launch sim:=false real_bringup:='$REAL_BRINGUP' keyboard:=false rviz:=false map_name:='$MAP_NAME' base_serial_port:='$BASE_SERIAL_PORT' lidar_serial_port:='$LIDAR_SERIAL_PORT' lidar_serial_baudrate:='$LIDAR_SERIAL_BAUDRATE'"

sleep 8

"$ROOT_DIR/scripts/open_ros_terminal.sh" "Keyboard Control" \
  "cd '$WS_DIR' && export ROS_HOME='$ROS_HOME' && source /opt/ros/noetic/setup.bash && source devel/setup.bash && rosrun wpr_simulation keyboard_vel_ctrl _save_map_name:='$MAP_NAME'"

"$ROOT_DIR/scripts/open_ros_terminal.sh" "ROS Bridge" \
  "cd '$ROOT_DIR' && bash scripts/start_rosbridge.sh"

"$ROOT_DIR/scripts/open_ros_terminal.sh" "Live Navigation Stack" \
  "cd '$WS_DIR' && export ROS_HOME='$ROS_HOME' && source /opt/ros/noetic/setup.bash && source devel/setup.bash && echo 'Starting real-robot live-map navigation stack. Keep mapping nodes running so /map and TF stay available.' && roslaunch se_navigation navigation.launch sim:=false real_bringup:=false live_map:=true rviz:=false map_manager:=false map_file:='$MAP_FILE'"

"$ROOT_DIR/scripts/open_ros_terminal.sh" "Frontend" \
  "cd '$ROOT_DIR' && bash scripts/start_frontend.sh"

echo "[verify_real_frontend_collab] opened real mapping/bringup, keyboard, rosbridge, live navigation, and frontend terminals."
echo "Use the frontend at http://localhost:5173/ and connect to ws://localhost:9090."
