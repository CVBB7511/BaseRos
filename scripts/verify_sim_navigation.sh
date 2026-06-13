#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WS_DIR="$ROOT_DIR/catkin_ws"
DEFAULT_MAP="$WS_DIR/src/se_map/maps/saved_map.yaml"
FALLBACK_MAP="$WS_DIR/src/wpr_simulation/maps/map.yaml"
MAP_FILE="${1:-$DEFAULT_MAP}"
mkdir -p "$ROOT_DIR/.ros"
export ROS_HOME="$ROOT_DIR/.ros"

"$ROOT_DIR/scripts/build_workspace.sh"

source /opt/ros/noetic/setup.bash
source "$WS_DIR/devel/setup.bash"

if [[ ! -f "$MAP_FILE" ]]; then
  echo "[verify_sim_navigation] map not found: $MAP_FILE"
  echo "[verify_sim_navigation] using fallback map: $FALLBACK_MAP"
  MAP_FILE="$FALLBACK_MAP"
fi

"$ROOT_DIR/scripts/open_ros_terminal.sh" "SE Navigation Launch" \
  "cd '$WS_DIR' && source /opt/ros/noetic/setup.bash && source devel/setup.bash && roslaunch se_navigation navigation.launch sim:=true map_file:='$MAP_FILE'"

sleep 20

"$ROOT_DIR/scripts/open_ros_terminal.sh" "Short Navigation Goal" \
  "cd '$WS_DIR' && source /opt/ros/noetic/setup.bash && source devel/setup.bash && rosrun se_navigation send_navigation_goal.py --goal-x 0.6 --goal-y 0.0 --timeout 90"

echo "[verify_sim_navigation] opened navigation terminals."
echo "[verify_sim_navigation] a short goal will be sent 20 seconds after navigation launch."
