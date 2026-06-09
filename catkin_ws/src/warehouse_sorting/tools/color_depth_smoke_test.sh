#!/usr/bin/env bash
set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT=""
for candidate in "$SCRIPT_DIR/../.." "$SCRIPT_DIR/../../.."; do
  candidate="$(cd "$candidate" && pwd)"
  if [ -f "$candidate/devel/setup.bash" ]; then
    WORKSPACE_ROOT="$candidate"
    break
  fi
done

if [ -z "$WORKSPACE_ROOT" ]; then
  WORKSPACE_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
fi

cd "$WORKSPACE_ROOT"

if [ -f devel/setup.bash ]; then
  # shellcheck disable=SC1091
  source devel/setup.bash
elif [ -f /opt/ros/noetic/setup.bash ]; then
  # shellcheck disable=SC1091
  source /opt/ros/noetic/setup.bash
else
  echo "ROS Noetic setup.bash not found" >&2
  exit 1
fi

set -u

mkdir -p build
roslaunch warehouse_sorting color_depth_smoke.launch > build/color_depth_smoke_launch.log 2>&1 &
launch_pid=$!
trap 'kill "$launch_pid" 2>/dev/null || true' EXIT

sleep 5
rosservice call /vision/scan_request "force: true" > build/color_depth_smoke_scan.log
grep -q 'success: True' build/color_depth_smoke_scan.log
grep -q 'cargo_type: "natural"' build/color_depth_smoke_scan.log
grep -q 'cargo_type: "colored"' build/color_depth_smoke_scan.log

rostopic pub /task/command std_msgs/String "data: start" -1 >/dev/null
sleep 8
rostopic echo -n 1 /task/status > build/color_depth_smoke_status.log

grep -q 'status: "COMPLETED"' build/color_depth_smoke_status.log
grep -q 'completed_items: 4' build/color_depth_smoke_status.log
grep -q 'failed_items: 0' build/color_depth_smoke_status.log
grep -q 'sorted_natural: 2' build/color_depth_smoke_status.log
grep -q 'sorted_colored: 2' build/color_depth_smoke_status.log

if grep -E "(ERROR|Traceback|Exception)" build/color_depth_smoke_launch.log; then
  echo "Launch log contains an error" >&2
  exit 1
fi

cat build/color_depth_smoke_scan.log
cat build/color_depth_smoke_status.log
echo "color-depth smoke test passed"
