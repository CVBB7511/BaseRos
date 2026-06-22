#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WS_DIR="$ROOT_DIR/catkin_ws"
mkdir -p "$ROOT_DIR/.ros" "$ROOT_DIR/real_maps" "$ROOT_DIR/logs"
export ROS_HOME="$ROOT_DIR/.ros"

"$ROOT_DIR/scripts/build_workspace.sh"

source /opt/ros/noetic/setup.bash
source "$WS_DIR/devel/setup.bash"

ros_node_exists() {
  rosnode list 2>/dev/null | grep -Fxq "$1"
}

if ! rosnode list >/dev/null 2>&1; then
  "$ROOT_DIR/scripts/open_ros_terminal.sh" "ROS Core" \
    "export ROS_HOME='$ROS_HOME' && source /opt/ros/noetic/setup.bash && roscore"
  sleep 3
else
  echo "[start_frontend_system] existing ROS Core detected; reusing it."
fi

if ! ros_node_exists "/frontend_control_server"; then
  "$ROOT_DIR/scripts/open_ros_terminal.sh" "Frontend Control Services" \
    "cd '$WS_DIR' && export ROS_HOME='$ROS_HOME' && source /opt/ros/noetic/setup.bash && source devel/setup.bash && rosrun mapping frontend_control_server.py _root_dir:='$ROOT_DIR' _workspace_dir:='$WS_DIR' _default_map_dir:='$ROOT_DIR/real_maps'"
  sleep 2
else
  echo "[start_frontend_system] existing frontend control server detected; reusing it."
fi

if ! ros_node_exists "/rosbridge_websocket"; then
  "$ROOT_DIR/scripts/open_ros_terminal.sh" "ROS Bridge" \
    "cd '$ROOT_DIR' && bash scripts/start_rosbridge.sh"
else
  echo "[start_frontend_system] existing ROS Bridge detected; reusing it."
fi

if ! pgrep -af "vite --host 0.0.0.0" >/dev/null 2>&1; then
  "$ROOT_DIR/scripts/open_ros_terminal.sh" "BaseRos Frontend" \
    "cd '$ROOT_DIR' && bash scripts/start_frontend.sh"
else
  echo "[start_frontend_system] existing frontend dev server detected; reusing it."
fi

echo
echo "BaseRos frontend system is ready."
echo "1. Open the URL shown in the BaseRos Frontend terminal (normally http://localhost:5173)."
echo "2. Connect ROS Bridge."
echo "3. Select 实机 and click 连接实机, or select 仿真 and click 启用仿真."
echo "4. Continue with mapping, map import, calibration, and palletizing from the frontend."
