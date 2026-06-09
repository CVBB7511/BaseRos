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

python3 - <<'PY'
from wpb_home_behaviors.msg import Coord
print("wpb_home_behaviors/Coord import ok")
PY

mkdir -p build
roslaunch warehouse_sorting sorting_core.launch use_wpb_home_objects:=true fallback_to_mock:=false use_camera:=false > build/wpb_bridge_smoke_launch.log 2>&1 &
launch_pid=$!
trap 'kill "$launch_pid" 2>/dev/null || true' EXIT

sleep 5
rosservice call /vision/scan_request "force: true" > build/wpb_bridge_smoke_scan.log &
scan_pid=$!
sleep 1
rostopic pub /wpb_home/objects_3d wpb_home_behaviors/Coord "{name: ['obj_0', 'obj_1'], x: [0.42, 0.44], y: [0.10, -0.12], z: [0.05, 0.05], probability: [0.98, 0.97]}" -1 >/dev/null
wait "$scan_pid"

grep -q 'success: True' build/wpb_bridge_smoke_scan.log
grep -q 'cargo_type: "natural"' build/wpb_bridge_smoke_scan.log
grep -q 'cargo_type: "colored"' build/wpb_bridge_smoke_scan.log

if grep -E "(ERROR|Traceback|Exception)" build/wpb_bridge_smoke_launch.log; then
  echo "Launch log contains an error" >&2
  exit 1
fi

cat build/wpb_bridge_smoke_scan.log
echo "wpb bridge smoke test passed"
