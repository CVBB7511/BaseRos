#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WS_DIR="$ROOT_DIR/catkin_ws"
mkdir -p "$ROOT_DIR/.ros"
export ROS_HOME="$ROOT_DIR/.ros"

source /opt/ros/noetic/setup.bash
if [[ -f "$WS_DIR/devel/setup.bash" ]]; then
  source "$WS_DIR/devel/setup.bash"
fi

exec roslaunch rosbridge_server rosbridge_websocket.launch
