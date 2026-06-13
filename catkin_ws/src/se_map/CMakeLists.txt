cmake_minimum_required(VERSION 3.0.2)
project(se_map)

find_package(catkin REQUIRED COMPONENTS
  geometry_msgs
  message_generation
  rospy
  std_msgs
)

add_service_files(
  FILES
  ClearMap.srv
  SaveMap.srv
  SetInitialPose.srv
)

generate_messages(
  DEPENDENCIES
  geometry_msgs
  std_msgs
)

catkin_package(
  CATKIN_DEPENDS
    geometry_msgs
    message_runtime
    rospy
    std_msgs
)

catkin_install_python(PROGRAMS
  scripts/map_manager.py
  DESTINATION ${CATKIN_PACKAGE_BIN_DESTINATION}
)

install(DIRECTORY launch maps
  DESTINATION ${CATKIN_PACKAGE_SHARE_DESTINATION}
)
