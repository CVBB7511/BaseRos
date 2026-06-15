cmake_minimum_required(VERSION 3.0.2)
project(palletizing)

find_package(catkin REQUIRED COMPONENTS
  message_generation
  rospy
  std_msgs
  geometry_msgs
  sensor_msgs
  sound_play
  move_base_msgs
  wpb_home_behaviors
)

add_service_files(
  FILES
  MarkZone.srv
  StartTask.srv
)

add_message_files(
  FILES
  PalletizingStats.msg
  SafetyStatus.msg
)

generate_messages(
  DEPENDENCIES
  std_msgs
)

catkin_package(
  CATKIN_DEPENDS message_runtime rospy std_msgs
)

catkin_install_python(PROGRAMS
  scripts/palletizing_executor.py
  scripts/mark_table_positions.py
  DESTINATION ${CATKIN_PACKAGE_BIN_DESTINATION}
)

install(DIRECTORY launch/
  DESTINATION ${CATKIN_PACKAGE_SHARE_DESTINATION}/launch
)
