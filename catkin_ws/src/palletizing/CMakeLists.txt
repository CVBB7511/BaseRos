cmake_minimum_required(VERSION 3.0.2)
project(palletizing)

find_package(catkin REQUIRED COMPONENTS
  rospy
  roscpp
  std_msgs
  geometry_msgs
  actionlib_msgs
  message_generation
  pcl_ros
  pcl_conversions
  cv_bridge
  image_transport
  tf
  wpb_home_behaviors
)

find_package(PCL REQUIRED)
find_package(OpenCV REQUIRED)

include_directories(
  ${catkin_INCLUDE_DIRS}
  ${PCL_INCLUDE_DIRS}
  ${OpenCV_INCLUDE_DIRS}
)

# ─── 安装 Python 包 (palletizing_core) ───
catkin_python_setup()

# ─── 自定义 Service 文件 ───
add_service_files(
  FILES
  TriggerDetection.srv
  SystemReset.srv
)

# ─── 自定义 Action 文件 ───
add_action_files(
  FILES
  Navigate.action
  Grab.action
  Palletize.action
)

# ─── 生成消息/服务/动作 ───
generate_messages(
  DEPENDENCIES
  std_msgs
  geometry_msgs
  actionlib_msgs
)

catkin_package(
  CATKIN_DEPENDS
    rospy
    std_msgs
    geometry_msgs
    actionlib_msgs
    message_runtime
)

# ─── 安装所有可执行 Python 脚本 ───
catkin_install_python(PROGRAMS
  scripts/task_manager_node.py
  scripts/navigation_server.py
  scripts/manipulator_server.py
  scripts/vision_service.py
  scripts/spawn_blocks.py
  DESTINATION ${CATKIN_PACKAGE_BIN_DESTINATION}
)

# ─── 编译 C++ 节点 ───
add_executable(color_objects_3d src/color_objects_3d.cpp)
add_dependencies(color_objects_3d ${catkin_EXPORTED_TARGETS})
target_link_libraries(color_objects_3d
  ${catkin_LIBRARIES}
  ${PCL_LIBRARIES}
  ${OpenCV_LIBRARIES}
)

add_executable(custom_place_action src/custom_place_action.cpp)
add_dependencies(custom_place_action ${catkin_EXPORTED_TARGETS})
target_link_libraries(custom_place_action
  ${catkin_LIBRARIES}
)

add_executable(custom_grab_action src/custom_grab_action.cpp)
add_dependencies(custom_grab_action ${catkin_EXPORTED_TARGETS})
target_link_libraries(custom_grab_action
  ${catkin_LIBRARIES}
)
