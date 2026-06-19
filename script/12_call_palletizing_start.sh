#!/usr/bin/env bash
set -euo pipefail

BASE_ROS="/home/yubowen/BaseRos"
CATKIN_WS="${BASE_ROS}/catkin_ws"

cd "${BASE_ROS}"
source /opt/ros/noetic/setup.bash
source "${CATKIN_WS}/devel/setup.bash"

echo "[12] Waiting for /palletizing/start ..."
rosservice list | grep -q '^/palletizing/start$' || {
  echo "Service /palletizing/start is not available yet."
  echo "Start script/10_start_execute_real.sh first, then set RViz 2D Pose Estimate."
  exit 1
}

echo
echo "WARNING: This triggers the full palletizing executor."
echo "On a robot without an arm, use this only to test that the service flow starts."
echo "Press Enter to call /palletizing/start, or Ctrl+C to cancel."
read -r _

rosservice call /palletizing/start "{}"
