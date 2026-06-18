#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WS_DIR="$ROOT_DIR/catkin_ws"
mkdir -p "$ROOT_DIR/.ros" "$ROOT_DIR/real_maps"
export ROS_HOME="$ROOT_DIR/.ros"

"$ROOT_DIR/scripts/build_workspace.sh"

"$ROOT_DIR/scripts/open_ros_terminal.sh" "ROS Core" \
  "export ROS_HOME='$ROS_HOME' && source /opt/ros/noetic/setup.bash && roscore"

sleep 3

"$ROOT_DIR/scripts/open_ros_terminal.sh" "Frontend Control Services" \
  "cd '$WS_DIR' && export ROS_HOME='$ROS_HOME' && source /opt/ros/noetic/setup.bash && source devel/setup.bash && rosrun mapping frontend_control_server.py _root_dir:='$ROOT_DIR' _workspace_dir:='$WS_DIR' _default_map_dir:='$ROOT_DIR/real_maps'"

"$ROOT_DIR/scripts/open_ros_terminal.sh" "ROS Bridge" \
  "cd '$ROOT_DIR' && bash scripts/start_rosbridge.sh"

"$ROOT_DIR/scripts/open_ros_terminal.sh" "Keyboard Control" \
  "cd '$WS_DIR' && export ROS_HOME='$ROS_HOME' && source /opt/ros/noetic/setup.bash && source devel/setup.bash && echo 'Use W/S/A/D/Q/E and Space when the real robot mapping flow is active.' && rosrun gazebosim_demo vel_ctrl_node.py"

"$ROOT_DIR/scripts/open_ros_terminal.sh" "Frontend" \
  "cd '$ROOT_DIR' && bash scripts/start_frontend.sh"

echo "[verify_real_frontend_palletizing] opened roscore, frontend services, rosbridge, keyboard, and frontend."
echo "Open the frontend URL printed in the Frontend terminal, connect ROS Bridge, choose 真机, then use 重新建图 / 保存地图 / 导入地图 / 标定 / 开始码垛."
