# 现场快速使用

当前真机流程已经统一到：

```text
warehouse_tuning/REAL_ROBOT_START_HERE.md
```

请按那份文档执行，不要再使用旧的“手动 roslaunch + rosservice call”流程。

最短启动顺序：

```text
终端 1: roslaunch warehouse_tuning field_robot_base.launch start_core:=true start_lidar:=true start_kinect:=true start_joy:=true
终端 2: rosrun warehouse_tuning field_calibration_wizard.py --manage-stack --keep-managed-stack --rviz ...
终端 3: roslaunch arm_grab_task stack_sort_field.launch use_field_override:=true ... rviz:=true
```

终端 2 不要关。它保留 AMCL 定位，避免加载地图后机器人不知道自己在哪。
