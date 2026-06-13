cmake_minimum_required(VERSION 3.0.2)
project(se_navigation)

find_package(catkin REQUIRED COMPONENTS
  actionlib
  actionlib_msgs
  geometry_msgs
  message_generation
  move_base_msgs
  nav_msgs
  rospy
  std_msgs
)

add_action_files(
  FILES
  Navigate.action
)

generate_messages(
  DEPENDENCIES
  actionlib_msgs
  geometry_msgs
  std_msgs
)

catkin_package(
  CATKIN_DEPENDS
    actionlib
    actionlib_msgs
    geometry_msgs
    message_runtime
    move_base_msgs
    nav_msgs
    rospy
    std_msgs
)

catkin_install_python(PROGRAMS
  scripts/navigator.py
  scripts/send_navigation_goal.py
  DESTINATION ${CATKIN_PACKAGE_BIN_DESTINATION}
)

install(DIRECTORY launch
  DESTINATION ${CATKIN_PACKAGE_SHARE_DESTINATION}
)
