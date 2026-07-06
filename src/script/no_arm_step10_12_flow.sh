#!/usr/bin/env bash
set -euo pipefail

BASE_ROS="/home/yubowen/BaseRos"
MAP_FILE="${1:-${BASE_ROS}/real_maps/real_map.yaml}"

cd "${BASE_ROS}"

echo "No-arm palletizing flow helper"
echo
echo "This opens the Step 10 launch terminal and a Step 12 service terminal."
echo "It does not run rosrun palletizing mark_table_positions.py."
echo "It starts mock behavior nodes that report object detection, grab, and place success."
echo
echo "Map file: ${MAP_FILE}"
echo

if command -v gnome-terminal >/dev/null 2>&1; then
  gnome-terminal --title="palletizing step 10 execute_real" -- \
    bash -lc "cd '${BASE_ROS}' && ./script/10_start_execute_real.sh '${MAP_FILE}'; exec bash"

  gnome-terminal --title="no-arm mock behaviors" -- \
    bash -lc "cd '${BASE_ROS}' && ./script/start_no_arm_mock_behaviors.sh; exec bash"

  gnome-terminal --title="palletizing step 12 start service" -- \
    bash -lc "cd '${BASE_ROS}' && echo 'Wait until RViz localization is set with 2D Pose Estimate.' && echo 'Confirm the no-arm mock terminal says ready.' && echo 'Then run:' && echo './script/12_call_palletizing_start.sh' && exec bash"
else
  echo "gnome-terminal was not found. Run these in two terminals:"
  echo
  echo "Terminal 1:"
  echo "  cd ${BASE_ROS}"
  echo "  ./script/10_start_execute_real.sh ${MAP_FILE}"
  echo
  echo "Terminal 2:"
  echo "  cd ${BASE_ROS}"
  echo "  ./script/start_no_arm_mock_behaviors.sh"
  echo
  echo "Terminal 3, after RViz 2D Pose Estimate and mock startup:"
  echo "  cd ${BASE_ROS}"
  echo "  ./script/12_call_palletizing_start.sh"
fi
