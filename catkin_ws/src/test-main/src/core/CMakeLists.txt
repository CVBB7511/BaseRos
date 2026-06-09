cmake_minimum_required(VERSION 3.0.2)
project(restaurant_robot_core)

find_package(catkin REQUIRED COMPONENTS
  rospy
  std_msgs
)

catkin_package()

catkin_install_python(PROGRAMS
  robot_controller.py
  task_dispatcher.py
  DESTINATION ${CATKIN_PACKAGE_BIN_DESTINATION}
)
