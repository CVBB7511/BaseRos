# Warehouse Sorting

ROS Noetic packages for the warehouse cargo sorting and palletizing robot.

The implementation follows the project documents in `data/documents`: two cargo
types are detected, natural boxes are routed to zone B, colored boxes are routed
to zone C, each pallet zone supports at least two layers, task status is
published for a UI, and arm/navigation calls are isolated behind ROS services.

## Packages

- `warehouse_sorting_msgs`: cargo, detection, task status messages and arm/scan services.
- `warehouse_sorting`: `vision_node`, `arm_control`, `task_manager`, launch files, config, and pure Python unit tests.

For the lab robot, start from `FIELD_QUICKSTART.md`. It contains the current
mapping, cargo feature tuning, launch, and validation commands.
If Kinect has frames but no cargo is detected, start from `VISION_DEBUG_RUNBOOK.md`
and run `roslaunch warehouse_sorting vision_debug.launch` before testing the full
task pipeline.

## Local Dry Run

Use this when the robot, Gazebo, or ROS camera stack is unavailable:

```bash
roslaunch warehouse_sorting sorting_core.launch
rostopic pub /task/command std_msgs/String 'data: "{\"command\":\"start\",\"total_items\":4}"' -1
rostopic echo /task/status
```

In dry-run mode the vision node publishes mock cargo from `config/sorting.yaml`,
the arm node accepts service calls without moving hardware, and navigation is
simulated.

To exercise the real color/depth detector without robot hardware, run the
synthetic camera end-to-end smoke test:

```bash
warehouse_sorting/tools/color_depth_smoke_test.sh
```

This starts `color_depth_smoke.launch`, publishes synthetic RGB/depth frames,
calls `/vision/scan_request`, and then drives the task manager through a
four-item dry-run. A pass means the project-owned vision path can feed the full
pipeline before you go back to the lab.

## Robot Integration

When running on the lab robot or a full workspace containing `wpb_home`, start
the integration launch with the required lower-level stacks:

```bash
roslaunch warehouse_sorting robot_integration.launch start_navigation:=true start_behaviors:=true start_kinect:=true
```

Set `dry_run_arm:=true` or `dry_run_navigation:=true` to isolate one subsystem
during staged tests.

If you are testing the arm on the real robot without navigation, use:

```bash
roslaunch warehouse_sorting robot_integration.launch start_bringup:=true start_behaviors:=true start_kinect:=true dry_run_navigation:=true
```

If the visual detector is not publishing cargo coordinates yet, isolate it first:

```bash
roslaunch warehouse_sorting vision_debug.launch
roslaunch warehouse_sorting vision_doctor.launch
rosservice call /vision/scan_request "force: true"
rostopic echo /vision/debug
```

The task manager now navigates to `source_a` before every scan. `vision_node`
subscribes to RGB/depth only for that one-shot scan, then unregisters the camera
topics. Tune HSV, ROI, and depth limits in `config/sorting.yaml`.

The arm node defaults to tabletop-only lift/gripper sequences with workspace
checks. Legacy WPB `grab_action`/`place_action` forwarding is available only
when `use_wpb_home_actions:=true` is set explicitly.

`start_navigation:=true` already starts the WPB core through
`wpb_home_tutorials/launch/nav.launch`, so do not combine it with
`start_bringup:=true`.

## Debug Console

For live debugging, start the web bridge together with the robot stack:

```bash
roslaunch warehouse_sorting vision_debug.launch start_web:=true
```

or:

```bash
roslaunch warehouse_sorting robot_integration.launch start_bringup:=true start_behaviors:=true start_kinect:=true dry_run_navigation:=true start_web:=true
```

Then open `web/dashboard.html` in a browser. The page shows the camera stream,
detected cargo boxes, task status, vision debug messages, topic freshness,
AMCL/odom pose, and move_base state. It uses rosbridge directly and does not
need internet access.
