## Ros迭代开发说明
### 一、软件环境
1. 系统版本 Ubuntu20.04.6
2. Python 3.8
3. 有conda环境，但是没用
### 二、硬件环境
I5-10250U
8GB内存
### 三、需要启动的ROS模块
1. 1080p摄像头
2. 激光雷达
3. （可选）扬声器
4. 机械臂
5. 遥控手柄
### 四、可参考的官方脚本
1. catkin_ws\src\wpb_home\wpb_home_tutorials\launch 中的grab_*.launch, mani_ctrl.launch, obj_detect.launch
2. catkin_ws\src\wpb_home\wpb_home_bringup\launch中的js_ctrl.launch, kinect_test.launch ,lidar_test.launch
3. catkin_ws/src/wpb_home/wpb_home_behaviors/launch中的obj_3d.launch