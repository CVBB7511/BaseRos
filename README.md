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
[WARN] [1781851884.797699358]: [object_detect start] 
[INFO] [1781851884.927664284]: Planes: 30226
[INFO] [1781851884.943231785]: 0 - plana: 30226 points. height =0.70
[INFO] [1781851884.943275056]: Final plane: 30226 points. height =0.70
[WARN] [1781851885.071244906]: [reject_obj_0] xMin= 1.44 yMin= -0.45 yMax= -0.03 size=(0.06, 0.41, 0.17)
[WARN] [1781851885.071493371]: [reject_obj_1] xMin= 0.87 yMin= 0.30 yMax= 0.45 size=(0.20, 0.15, 0.07)
[Info] [DepthPacketStreamParser] 20 packets were lost
[INFO] [1781851885.435566145]: Planes: 30411
[INFO] [1781851885.455896675]: 0 - plana: 30411 points. height =0.70
[INFO] [1781851885.455936530]: Final plane: 30411 points. height =0.70
[WARN] [1781851885.663187672]: [reject_obj_0] xMin= 1.38 yMin= -0.47 yMax= -0.03 size=(0.12, 0.43, 0.17)
[WARN] [1781851885.663385502]: [reject_obj_1] xMin= 0.87 yMin= 0.30 yMax= 0.46 size=(0.21, 0.16, 0.08)
[WARN] [1781851885.663579987]: [reject_obj_2] xMin= 0.47 yMin= -0.05 yMax= 0.15 size=(0.13, 0.20, 0.07)
[INFO] [1781851886.022670727]: Planes: 30808
[INFO] [1781851886.041682898]: 0 - plana: 30808 points. height =0.70
[INFO] [1781851886.041715509]: Final plane: 30808 points. height =0.70
[Info] [CpuDepthPacketProcessor] avg. time: 74.2383ms -> ~13.4701Hz
[WARN] [1781851886.292669178]: [reject_obj_0] xMin= 1.41 yMin= -0.47 yMax= -0.03 size=(0.09, 0.44, 0.17)
[WARN] [1781851886.292909528]: [reject_obj_1] xMin= 0.44 yMin= -0.05 yMax= 0.16 size=(0.16, 0.21, 0.05)
[WARN] [1781851886.293170597]: [reject_obj_2] xMin= 0.87 yMin= 0.30 yMax= 0.45 size=(0.21, 0.16, 0.07)
[Info] [DepthPacketStreamParser] 20 packets were lost
[Info] [TurboJpegRgbPacketProcessor] avg. time: 9.10176ms -> ~109.869Hz
[INFO] [1781851886.411702928]: [Kinect2Bridge::main] depth processing: ~8.89786ms (~112.387Hz) publishing rate: ~9.99382Hz
[INFO] [1781851886.411749035]: [Kinect2Bridge::main] color processing: ~0.9997ms (~1000.3Hz) publishing rate: ~29.9815Hz
[INFO] [1781851886.529859846]: Planes: 31178
[INFO] [1781851886.545929946]: 0 - plana: 31178 points. height =0.70
[INFO] [1781851886.545968999]: Final plane: 31178 points. height =0.70
[WARN] [1781851886.708972880]: [reject_obj_0] xMin= 1.32 yMin= -0.47 yMax= -0.03 size=(0.18, 0.44, 0.17)
[WARN] [1781851886.709237536]: [reject_obj_1] xMin= 0.87 yMin= 0.30 yMax= 0.45 size=(0.21, 0.15, 0.07)
[WARN] [1781851886.709455955]: [reject_obj_2] xMin= 0.45 yMin= -0.05 yMax= 0.17 size=(0.15, 0.22, 0.06)
[INFO] [1781851887.056995714]: Planes: 31860
[INFO] [1781851887.069329266]: 0 - plana: 31860 points. height =0.70
[INFO] [1781851887.069387976]: Final plane: 31860 points. height =0.70
[WARN] [1781851887.215185586]: [reject_obj_0] xMin= 1.43 yMin= -0.45 yMax= -0.03 size=(0.07, 0.42, 0.17)
[WARN] [1781851887.215383958]: [reject_obj_1] xMin= 0.87 yMin= 0.30 yMax= 0.46 size=(0.21, 0.16, 0.08)
[INFO] [1781851887.559329423]: Planes: 32473
[INFO] [1781851887.569113810]: 0 - plana: 32473 points. height =0.70
[INFO] [1781851887.569157652]: Final plane: 32473 points. height =0.70
[WARN] [1781851887.669354217]: [reject_obj_0] xMin= 0.87 yMin= 0.30 yMax= 0.45 size=(0.21, 0.16, 0.07)
[WARN] [1781851887.669535247]: [reject_obj_1] xMin= 1.42 yMin= -0.39 yMax= -0.03 size=(0.08, 0.36, 0.18)
[Info] [DepthPacketStreamParser] 31 packets were lost
[INFO] [1781851888.152914329]: Planes: 31552
[INFO] [1781851888.169554968]: 0 - plana: 31552 points. height =0.70
[INFO] [1781851888.169597117]: Final plane: 31552 points. height =0.70
[WARN] [1781851888.306293648]: [reject_obj_0] xMin= 1.42 yMin= -0.46 yMax= -0.03 size=(0.08, 0.43, 0.17)
[WARN] [1781851888.306475379]: [reject_obj_1] xMin= 0.87 yMin= 0.30 yMax= 0.46 size=(0.21, 0.16, 0.07)
[INFO] [1781851888.652484466]: Planes: 31280
[INFO] [1781851888.664989018]: 0 - plana: 31280 points. height =0.70
[INFO] [1781851888.665025706]: Final plane: 31280 points. height =0.70
[WARN] [1781851888.798216690]: [reject_obj_0] xMin= 1.44 yMin= -0.45 yMax= -0.03 size=(0.06, 0.42, 0.17)
[WARN] [1781851888.798406316]: [obj_1] type=10cm_cube xMin= 0.87 yMin= 0.30 yMax= 0.45 size=(0.21, 0.15, 0.07)
[INFO] [1781851889.162999228]: Planes: 30988
[INFO] [1781851889.177566814]: 0 - plana: 30988 points. height =0.70
[INFO] [1781851889.177604444]: Final plane: 30988 points. height =0.70
[WARN] [1781851889.307140843]: [reject_obj_0] xMin= 1.41 yMin= -0.45 yMax= -0.03 size=(0.09, 0.41, 0.17)
[WARN] [1781851889.307373438]: [reject_obj_1] xMin= 0.87 yMin= 0.30 yMax= 0.45 size=(0.20, 0.15, 0.07)
[Info] [DepthPacketStreamParser] 30 packets were lost
[INFO] [1781851889.417000416]: [Kinect2Bridge::main] depth processing: ~8.79851ms (~113.656Hz) publishing rate: ~9.64962Hz
[INFO] [1781851889.417054517]: [Kinect2Bridge::main] color processing: ~1.05251ms (~950.11Hz) publishing rate: ~29.9471Hz
[Info] [TurboJpegRgbPacketProcessor] avg. time: 9.26914ms -> ~107.885Hz
[INFO] [1781851889.782176077]: Planes: 31245
[INFO] [1781851889.799665887]: 0 - plana: 31245 points. height =0.70
[INFO] [1781851889.799712725]: Final plane: 31245 points. height =0.70
[WARN] [1781851889.805710]: Object detection timed out: got 1/2 non-empty samples
[WARN] [1781851889.807589]: Detect attempt 1/2 failed
[WARN] [1781851889.926271676]: [reject_obj_0] xMin= 1.43 yMin= -0.47 yMax= -0.03 size=(0.07, 0.43, 0.18)
[WARN] [1781851889.926438018]: [reject_obj_1] xMin= 0.87 yMin= 0.30 yMax= 0.45 size=(0.21, 0.15, 0.07)
[WARN] [1781851889.927894085]: [object_detect stop] 
[WARN] [1781851890.459887881]: [object_detect start] 
[INFO] [1781851890.558870841]: Planes: 30752
[INFO] [1781851890.570938234]: 0 - plana: 30752 points. height =0.70
[INFO] [1781851890.570988929]: Final plane: 30752 points. height =0.70
[WARN] [1781851890.656809203]: [obj_0] type=10cm_cube xMin= 0.87 yMin= 0.30 yMax= 0.44 size=(0.20, 0.14, 0.07)
[WARN] [1781851890.656942784]: [reject_obj_1] xMin= 1.45 yMin= -0.25 yMax= -0.03 size=(0.04, 0.22, 0.17)
[Info] [DepthPacketStreamParser] 31 packets were lost
[INFO] [1781851891.119117925]: Planes: 30331
[INFO] [1781851891.130140652]: 0 - plana: 30331 points. height =0.70
[INFO] [1781851891.130180656]: Final plane: 30331 points. height =0.70
[WARN] [1781851891.233971258]: [reject_obj_0] xMin= 0.87 yMin= 0.30 yMax= 0.45 size=(0.21, 0.15, 0.07)
[WARN] [1781851891.234127731]: [reject_obj_1] xMin= 1.43 yMin= -0.39 yMax= -0.03 size=(0.07, 0.37, 0.17)
[WARN] [1781851891.302136894]: Joint state with name: "elbow_forearm" was received but not found in URDF
[INFO] [1781851891.650985419]: Planes: 30285
[INFO] [1781851891.661951268]: 0 - plana: 30285 points. height =0.70
[INFO] [1781851891.661988828]: Final plane: 30285 points. height =0.70
[WARN] [1781851891.786902175]: [reject_obj_0] xMin= 1.43 yMin= -0.45 yMax= -0.04 size=(0.07, 0.41, 0.17)
[WARN] [1781851891.787068917]: [reject_obj_1] xMin= 0.87 yMin= 0.30 yMax= 0.45 size=(0.20, 0.15, 0.07)
[INFO] [1781851892.245758082]: Planes: 30870
[INFO] [1781851892.257962622]: 0 - plana: 30870 points. height =0.70
[INFO] [1781851892.257999131]: Final plane: 30870 points. height =0.70
[WARN] [1781851892.357900948]: [reject_obj_0] xMin= 1.43 yMin= -0.40 yMax= -0.03 size=(0.06, 0.37, 0.17)
[WARN] [1781851892.358046872]: [reject_obj_1] xMin= 0.87 yMin= 0.30 yMax= 0.45 size=(0.20, 0.15, 0.07)
[INFO] [1781851892.423178755]: [Kinect2Bridge::main] depth processing: ~8.65596ms (~115.527Hz) publishing rate: ~9.9795Hz
[INFO] [1781851892.423240782]: [Kinect2Bridge::main] color processing: ~0.949777ms (~1052.88Hz) publishing rate: ~29.9385Hz
[Info] [DepthPacketStreamParser] 31 packets were lost
[INFO] [1781851892.752982513]: Planes: 31202
[INFO] [1781851892.765457449]: 0 - plana: 31202 points. height =0.70
[INFO] [1781851892.765500740]: Final plane: 31202 points. height =0.70
[WARN] [1781851892.859322079]: [reject_obj_0] xMin= 0.87 yMin= 0.30 yMax= 0.45 size=(0.21, 0.15, 0.07)
[WARN] [1781851892.859481888]: [reject_obj_1] xMin= 1.44 yMin= -0.40 yMax= -0.03 size=(0.06, 0.36, 0.17)
[Info] [TurboJpegRgbPacketProcessor] avg. time: 9.31829ms -> ~107.316Hz
[INFO] [1781851893.250384504]: Planes: 30999
[INFO] [1781851893.263301739]: 0 - plana: 30999 points. height =0.70
[INFO] [1781851893.263340421]: Final plane: 30999 points. height =0.70
[WARN] [1781851893.394599649]: [reject_obj_0] xMin= 1.42 yMin= -0.45 yMax= -0.03 size=(0.08, 0.41, 0.17)
[WARN] [1781851893.394869765]: [reject_obj_1] xMin= 0.87 yMin= 0.30 yMax= 0.45 size=(0.21, 0.15, 0.07)
[INFO] [1781851893.750878382]: Planes: 29525
[INFO] [1781851893.762600118]: 0 - plana: 29525 points. height =0.70
[INFO] [1781851893.762634041]: Final plane: 29525 points. height =0.70
[WARN] [1781851893.847482343]: [reject_obj_0] xMin= 0.87 yMin= 0.30 yMax= 0.45 size=(0.20, 0.15, 0.07)
[WARN] [1781851893.847602849]: [reject_obj_1] xMin= 1.43 yMin= -0.36 yMax= -0.03 size=(0.07, 0.32, 0.17)
[Info] [DepthPacketStreamParser] 30 packets were lost
[INFO] [1781851894.349493019]: Planes: 31300
[INFO] [1781851894.360916144]: 0 - plana: 31300 points. height =0.70
[INFO] [1781851894.360964805]: Final plane: 31300 points. height =0.70
[WARN] [1781851894.480251618]: [reject_obj_0] xMin= 1.44 yMin= -0.45 yMax= -0.03 size=(0.06, 0.42, 0.17)
[WARN] [1781851894.480421386]: [obj_1] type=10cm_cube xMin= 0.87 yMin= 0.30 yMax= 0.44 size=(0.20, 0.15, 0.07)
[INFO] [1781851894.576323]: Detected 1 objects
[WARN] [1781851894.576581544]: [object_detect stop] 
[INFO] [1781851894.578280]: Selected obj_0 idx=0 type=hard_cube local_grab=(1.019, 0.369, 0.750)
[INFO] [1781851894.579582]: Selected object absolute map=(-2.774, -1.191, 0.750)
[INFO] [1781851894.581355]: Grab action target base(1.019, 0.369, 0.750) type=hard_cube
[WARN] [1781851894.589279528]: [OBJ_TO_GRAB] x = 1.02 y= 0.37 ,z= 0.75 
[WARN] [1781851894.589382851]: [MOVE_TARGET] x = 0.02 y= 0.30 