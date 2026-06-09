cmake_minimum_required(VERSION 3.0.2)
project(warehouse_sorting)

find_package(catkin REQUIRED COMPONENTS
  geometry_msgs
  rospy
  sensor_msgs
  std_msgs
  std_srvs
  warehouse_sorting_msgs
)

catkin_python_setup()

catkin_package(
  CATKIN_DEPENDS geometry_msgs rospy sensor_msgs std_msgs std_srvs warehouse_sorting_msgs
)

include_directories(
  ${catkin_INCLUDE_DIRS}
)

catkin_install_python(PROGRAMS
  scripts/arm_control_node.py
  scripts/preflight_check.py
  scripts/simple_object_detector.py
  scripts/state_monitor_node.py
  scripts/synthetic_camera_node.py
  scripts/task_manager_node.py
  scripts/vision_doctor.py
  scripts/vision_node.py
  DESTINATION ${CATKIN_PACKAGE_BIN_DESTINATION}
)

install(DIRECTORY config launch tools web
  DESTINATION ${CATKIN_PACKAGE_SHARE_DESTINATION}
)

if(CATKIN_ENABLE_TESTING)
  catkin_add_nosetests(test)
endif()
