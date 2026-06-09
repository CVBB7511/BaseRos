cmake_minimum_required(VERSION 3.0.2)
project(restaurant_voice_interaction)

find_package(catkin REQUIRED COMPONENTS
  rospy
  std_msgs
)

catkin_package()

catkin_install_python(PROGRAMS
  src/voice_interaction_node.py
  src/order_manager.py
  src/database_order_adapter.py
  DESTINATION ${CATKIN_PACKAGE_BIN_DESTINATION}
)
