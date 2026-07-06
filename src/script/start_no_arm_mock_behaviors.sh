#!/usr/bin/env bash
set -euo pipefail

BASE_ROS="/home/yubowen/BaseRos"
CATKIN_WS="${BASE_ROS}/catkin_ws"

cd "${BASE_ROS}"
source /opt/ros/noetic/setup.bash
source "${CATKIN_WS}/devel/setup.bash"

echo "Waiting for ROS master..."
until rostopic list >/dev/null 2>&1; do
  sleep 1
done

echo "Stopping real behavior nodes that would control the arm/base during mock flow..."
for _ in $(seq 1 20); do
  rosnode kill /wpb_home_grab_action >/dev/null 2>&1 || true
  rosnode kill /wpb_home_place_action >/dev/null 2>&1 || true
  rosnode kill /wpb_home_objects_3d >/dev/null 2>&1 || true
  sleep 1
done

echo "Starting no-arm mock behaviors."
echo "Parameters can be overridden with rosparam if needed:"
echo "  _objects:=2 _object_x:=0.95 _object_z:=0.83"
echo

python3 "${BASE_ROS}/script/no_arm_mock_behaviors.py" "$@"
