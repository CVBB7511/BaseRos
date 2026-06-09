cmake_minimum_required(VERSION 3.0.2)
project(restaurant_robot_navigation)

find_package(catkin REQUIRED COMPONENTS
  rospy
  std_msgs
  actionlib
  actionlib_msgs
  move_base_msgs
  tf
)

catkin_package()

catkin_install_python(PROGRAMS
  navigation_manager.py
  odom_to_mysql.py
  capture_nav_goal.py
  DESTINATION ${CATKIN_PACKAGE_BIN_DESTINATION}
)
