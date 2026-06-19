#!/usr/bin/env bash
set -euo pipefail

BASE_ROS="/home/yubowen/BaseRos"
CATKIN_WS="${BASE_ROS}/catkin_ws"
MAP_FILE="${1:-${BASE_ROS}/real_maps/real_map.yaml}"

cd "${BASE_ROS}"
source /opt/ros/noetic/setup.bash
source "${CATKIN_WS}/devel/setup.bash"

echo "[10] Starting real execution stack with map:"
echo "     ${MAP_FILE}"
echo
echo "After RViz opens, set the initial pose with '2D Pose Estimate'."
echo "This script does not run mark_table_positions.py."
echo

roslaunch gazebosim_demo palletizing_execute_real.launch \
  map_file:="${MAP_FILE}"
