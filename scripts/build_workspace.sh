#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WS_DIR="$ROOT_DIR/catkin_ws"

cd "$WS_DIR"
source /opt/ros/noetic/setup.bash
catkin_make

echo
echo "Build finished. Before running ROS commands, use:"
echo "  source $WS_DIR/devel/setup.bash"
