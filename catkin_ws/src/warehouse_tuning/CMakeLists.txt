cmake_minimum_required(VERSION 3.0.2)
project(warehouse_tuning)

find_package(catkin REQUIRED COMPONENTS
  geometry_msgs
  nav_msgs
  rospy
  sensor_msgs
  std_msgs
  std_srvs
  tf
)

catkin_package(
  CATKIN_DEPENDS geometry_msgs nav_msgs rospy sensor_msgs std_msgs std_srvs tf
)

catkin_install_python(PROGRAMS
  scripts/abc_zone_capture.py
  scripts/cargo_feature_capture.py
  scripts/field_calibration_wizard.py
  scripts/initial_pose_setter.py
  scripts/mapping_session_node.py
  scripts/sim_mapping_drive.py
  scripts/sim_localization_node.py
  scripts/sim_map_publisher.py
  DESTINATION ${CATKIN_PACKAGE_BIN_DESTINATION}
)

install(DIRECTORY config launch
  DESTINATION ${CATKIN_PACKAGE_SHARE_DESTINATION}
)
