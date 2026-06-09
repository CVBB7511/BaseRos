# generated from genmsg/cmake/pkg-genmsg.cmake.em

message(STATUS "warehouse_sorting_msgs: 3 messages, 2 services")

set(MSG_I_FLAGS "-Iwarehouse_sorting_msgs:/home/robot6/catkin_ws/src/warehouse_sorting_msgs/msg;-Igeometry_msgs:/opt/ros/noetic/share/geometry_msgs/cmake/../msg;-Istd_msgs:/opt/ros/noetic/share/std_msgs/cmake/../msg")

# Find all generators
find_package(gencpp REQUIRED)
find_package(geneus REQUIRED)
find_package(genlisp REQUIRED)
find_package(gennodejs REQUIRED)
find_package(genpy REQUIRED)

add_custom_target(warehouse_sorting_msgs_generate_messages ALL)

# verify that message/service dependencies have not changed since configure



get_filename_component(_filename "/home/robot6/catkin_ws/src/warehouse_sorting_msgs/msg/Cargo.msg" NAME_WE)
add_custom_target(_warehouse_sorting_msgs_generate_messages_check_deps_${_filename}
  COMMAND ${CATKIN_ENV} ${PYTHON_EXECUTABLE} ${GENMSG_CHECK_DEPS_SCRIPT} "warehouse_sorting_msgs" "/home/robot6/catkin_ws/src/warehouse_sorting_msgs/msg/Cargo.msg" "geometry_msgs/Vector3:geometry_msgs/Pose:geometry_msgs/Point:geometry_msgs/Quaternion"
)

get_filename_component(_filename "/home/robot6/catkin_ws/src/warehouse_sorting_msgs/msg/DetectedCargoArray.msg" NAME_WE)
add_custom_target(_warehouse_sorting_msgs_generate_messages_check_deps_${_filename}
  COMMAND ${CATKIN_ENV} ${PYTHON_EXECUTABLE} ${GENMSG_CHECK_DEPS_SCRIPT} "warehouse_sorting_msgs" "/home/robot6/catkin_ws/src/warehouse_sorting_msgs/msg/DetectedCargoArray.msg" "std_msgs/Header:geometry_msgs/Point:warehouse_sorting_msgs/Cargo:geometry_msgs/Quaternion:geometry_msgs/Vector3:geometry_msgs/Pose"
)

get_filename_component(_filename "/home/robot6/catkin_ws/src/warehouse_sorting_msgs/msg/TaskStatus.msg" NAME_WE)
add_custom_target(_warehouse_sorting_msgs_generate_messages_check_deps_${_filename}
  COMMAND ${CATKIN_ENV} ${PYTHON_EXECUTABLE} ${GENMSG_CHECK_DEPS_SCRIPT} "warehouse_sorting_msgs" "/home/robot6/catkin_ws/src/warehouse_sorting_msgs/msg/TaskStatus.msg" "std_msgs/Header"
)

get_filename_component(_filename "/home/robot6/catkin_ws/src/warehouse_sorting_msgs/srv/ArmCommand.srv" NAME_WE)
add_custom_target(_warehouse_sorting_msgs_generate_messages_check_deps_${_filename}
  COMMAND ${CATKIN_ENV} ${PYTHON_EXECUTABLE} ${GENMSG_CHECK_DEPS_SCRIPT} "warehouse_sorting_msgs" "/home/robot6/catkin_ws/src/warehouse_sorting_msgs/srv/ArmCommand.srv" "geometry_msgs/Point:warehouse_sorting_msgs/Cargo:geometry_msgs/Quaternion:geometry_msgs/Vector3:geometry_msgs/Pose"
)

get_filename_component(_filename "/home/robot6/catkin_ws/src/warehouse_sorting_msgs/srv/ScanRequest.srv" NAME_WE)
add_custom_target(_warehouse_sorting_msgs_generate_messages_check_deps_${_filename}
  COMMAND ${CATKIN_ENV} ${PYTHON_EXECUTABLE} ${GENMSG_CHECK_DEPS_SCRIPT} "warehouse_sorting_msgs" "/home/robot6/catkin_ws/src/warehouse_sorting_msgs/srv/ScanRequest.srv" "std_msgs/Header:geometry_msgs/Point:warehouse_sorting_msgs/DetectedCargoArray:warehouse_sorting_msgs/Cargo:geometry_msgs/Quaternion:geometry_msgs/Vector3:geometry_msgs/Pose"
)

#
#  langs = gencpp;geneus;genlisp;gennodejs;genpy
#

### Section generating for lang: gencpp
### Generating Messages
_generate_msg_cpp(warehouse_sorting_msgs
  "/home/robot6/catkin_ws/src/warehouse_sorting_msgs/msg/Cargo.msg"
  "${MSG_I_FLAGS}"
  "/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Vector3.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Pose.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Point.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Quaternion.msg"
  ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/warehouse_sorting_msgs
)
_generate_msg_cpp(warehouse_sorting_msgs
  "/home/robot6/catkin_ws/src/warehouse_sorting_msgs/msg/DetectedCargoArray.msg"
  "${MSG_I_FLAGS}"
  "/opt/ros/noetic/share/std_msgs/cmake/../msg/Header.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Point.msg;/home/robot6/catkin_ws/src/warehouse_sorting_msgs/msg/Cargo.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Quaternion.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Vector3.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Pose.msg"
  ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/warehouse_sorting_msgs
)
_generate_msg_cpp(warehouse_sorting_msgs
  "/home/robot6/catkin_ws/src/warehouse_sorting_msgs/msg/TaskStatus.msg"
  "${MSG_I_FLAGS}"
  "/opt/ros/noetic/share/std_msgs/cmake/../msg/Header.msg"
  ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/warehouse_sorting_msgs
)

### Generating Services
_generate_srv_cpp(warehouse_sorting_msgs
  "/home/robot6/catkin_ws/src/warehouse_sorting_msgs/srv/ArmCommand.srv"
  "${MSG_I_FLAGS}"
  "/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Point.msg;/home/robot6/catkin_ws/src/warehouse_sorting_msgs/msg/Cargo.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Quaternion.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Vector3.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Pose.msg"
  ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/warehouse_sorting_msgs
)
_generate_srv_cpp(warehouse_sorting_msgs
  "/home/robot6/catkin_ws/src/warehouse_sorting_msgs/srv/ScanRequest.srv"
  "${MSG_I_FLAGS}"
  "/opt/ros/noetic/share/std_msgs/cmake/../msg/Header.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Point.msg;/home/robot6/catkin_ws/src/warehouse_sorting_msgs/msg/DetectedCargoArray.msg;/home/robot6/catkin_ws/src/warehouse_sorting_msgs/msg/Cargo.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Quaternion.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Vector3.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Pose.msg"
  ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/warehouse_sorting_msgs
)

### Generating Module File
_generate_module_cpp(warehouse_sorting_msgs
  ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/warehouse_sorting_msgs
  "${ALL_GEN_OUTPUT_FILES_cpp}"
)

add_custom_target(warehouse_sorting_msgs_generate_messages_cpp
  DEPENDS ${ALL_GEN_OUTPUT_FILES_cpp}
)
add_dependencies(warehouse_sorting_msgs_generate_messages warehouse_sorting_msgs_generate_messages_cpp)

# add dependencies to all check dependencies targets
get_filename_component(_filename "/home/robot6/catkin_ws/src/warehouse_sorting_msgs/msg/Cargo.msg" NAME_WE)
add_dependencies(warehouse_sorting_msgs_generate_messages_cpp _warehouse_sorting_msgs_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/robot6/catkin_ws/src/warehouse_sorting_msgs/msg/DetectedCargoArray.msg" NAME_WE)
add_dependencies(warehouse_sorting_msgs_generate_messages_cpp _warehouse_sorting_msgs_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/robot6/catkin_ws/src/warehouse_sorting_msgs/msg/TaskStatus.msg" NAME_WE)
add_dependencies(warehouse_sorting_msgs_generate_messages_cpp _warehouse_sorting_msgs_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/robot6/catkin_ws/src/warehouse_sorting_msgs/srv/ArmCommand.srv" NAME_WE)
add_dependencies(warehouse_sorting_msgs_generate_messages_cpp _warehouse_sorting_msgs_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/robot6/catkin_ws/src/warehouse_sorting_msgs/srv/ScanRequest.srv" NAME_WE)
add_dependencies(warehouse_sorting_msgs_generate_messages_cpp _warehouse_sorting_msgs_generate_messages_check_deps_${_filename})

# target for backward compatibility
add_custom_target(warehouse_sorting_msgs_gencpp)
add_dependencies(warehouse_sorting_msgs_gencpp warehouse_sorting_msgs_generate_messages_cpp)

# register target for catkin_package(EXPORTED_TARGETS)
list(APPEND ${PROJECT_NAME}_EXPORTED_TARGETS warehouse_sorting_msgs_generate_messages_cpp)

### Section generating for lang: geneus
### Generating Messages
_generate_msg_eus(warehouse_sorting_msgs
  "/home/robot6/catkin_ws/src/warehouse_sorting_msgs/msg/Cargo.msg"
  "${MSG_I_FLAGS}"
  "/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Vector3.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Pose.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Point.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Quaternion.msg"
  ${CATKIN_DEVEL_PREFIX}/${geneus_INSTALL_DIR}/warehouse_sorting_msgs
)
_generate_msg_eus(warehouse_sorting_msgs
  "/home/robot6/catkin_ws/src/warehouse_sorting_msgs/msg/DetectedCargoArray.msg"
  "${MSG_I_FLAGS}"
  "/opt/ros/noetic/share/std_msgs/cmake/../msg/Header.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Point.msg;/home/robot6/catkin_ws/src/warehouse_sorting_msgs/msg/Cargo.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Quaternion.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Vector3.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Pose.msg"
  ${CATKIN_DEVEL_PREFIX}/${geneus_INSTALL_DIR}/warehouse_sorting_msgs
)
_generate_msg_eus(warehouse_sorting_msgs
  "/home/robot6/catkin_ws/src/warehouse_sorting_msgs/msg/TaskStatus.msg"
  "${MSG_I_FLAGS}"
  "/opt/ros/noetic/share/std_msgs/cmake/../msg/Header.msg"
  ${CATKIN_DEVEL_PREFIX}/${geneus_INSTALL_DIR}/warehouse_sorting_msgs
)

### Generating Services
_generate_srv_eus(warehouse_sorting_msgs
  "/home/robot6/catkin_ws/src/warehouse_sorting_msgs/srv/ArmCommand.srv"
  "${MSG_I_FLAGS}"
  "/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Point.msg;/home/robot6/catkin_ws/src/warehouse_sorting_msgs/msg/Cargo.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Quaternion.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Vector3.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Pose.msg"
  ${CATKIN_DEVEL_PREFIX}/${geneus_INSTALL_DIR}/warehouse_sorting_msgs
)
_generate_srv_eus(warehouse_sorting_msgs
  "/home/robot6/catkin_ws/src/warehouse_sorting_msgs/srv/ScanRequest.srv"
  "${MSG_I_FLAGS}"
  "/opt/ros/noetic/share/std_msgs/cmake/../msg/Header.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Point.msg;/home/robot6/catkin_ws/src/warehouse_sorting_msgs/msg/DetectedCargoArray.msg;/home/robot6/catkin_ws/src/warehouse_sorting_msgs/msg/Cargo.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Quaternion.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Vector3.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Pose.msg"
  ${CATKIN_DEVEL_PREFIX}/${geneus_INSTALL_DIR}/warehouse_sorting_msgs
)

### Generating Module File
_generate_module_eus(warehouse_sorting_msgs
  ${CATKIN_DEVEL_PREFIX}/${geneus_INSTALL_DIR}/warehouse_sorting_msgs
  "${ALL_GEN_OUTPUT_FILES_eus}"
)

add_custom_target(warehouse_sorting_msgs_generate_messages_eus
  DEPENDS ${ALL_GEN_OUTPUT_FILES_eus}
)
add_dependencies(warehouse_sorting_msgs_generate_messages warehouse_sorting_msgs_generate_messages_eus)

# add dependencies to all check dependencies targets
get_filename_component(_filename "/home/robot6/catkin_ws/src/warehouse_sorting_msgs/msg/Cargo.msg" NAME_WE)
add_dependencies(warehouse_sorting_msgs_generate_messages_eus _warehouse_sorting_msgs_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/robot6/catkin_ws/src/warehouse_sorting_msgs/msg/DetectedCargoArray.msg" NAME_WE)
add_dependencies(warehouse_sorting_msgs_generate_messages_eus _warehouse_sorting_msgs_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/robot6/catkin_ws/src/warehouse_sorting_msgs/msg/TaskStatus.msg" NAME_WE)
add_dependencies(warehouse_sorting_msgs_generate_messages_eus _warehouse_sorting_msgs_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/robot6/catkin_ws/src/warehouse_sorting_msgs/srv/ArmCommand.srv" NAME_WE)
add_dependencies(warehouse_sorting_msgs_generate_messages_eus _warehouse_sorting_msgs_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/robot6/catkin_ws/src/warehouse_sorting_msgs/srv/ScanRequest.srv" NAME_WE)
add_dependencies(warehouse_sorting_msgs_generate_messages_eus _warehouse_sorting_msgs_generate_messages_check_deps_${_filename})

# target for backward compatibility
add_custom_target(warehouse_sorting_msgs_geneus)
add_dependencies(warehouse_sorting_msgs_geneus warehouse_sorting_msgs_generate_messages_eus)

# register target for catkin_package(EXPORTED_TARGETS)
list(APPEND ${PROJECT_NAME}_EXPORTED_TARGETS warehouse_sorting_msgs_generate_messages_eus)

### Section generating for lang: genlisp
### Generating Messages
_generate_msg_lisp(warehouse_sorting_msgs
  "/home/robot6/catkin_ws/src/warehouse_sorting_msgs/msg/Cargo.msg"
  "${MSG_I_FLAGS}"
  "/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Vector3.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Pose.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Point.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Quaternion.msg"
  ${CATKIN_DEVEL_PREFIX}/${genlisp_INSTALL_DIR}/warehouse_sorting_msgs
)
_generate_msg_lisp(warehouse_sorting_msgs
  "/home/robot6/catkin_ws/src/warehouse_sorting_msgs/msg/DetectedCargoArray.msg"
  "${MSG_I_FLAGS}"
  "/opt/ros/noetic/share/std_msgs/cmake/../msg/Header.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Point.msg;/home/robot6/catkin_ws/src/warehouse_sorting_msgs/msg/Cargo.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Quaternion.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Vector3.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Pose.msg"
  ${CATKIN_DEVEL_PREFIX}/${genlisp_INSTALL_DIR}/warehouse_sorting_msgs
)
_generate_msg_lisp(warehouse_sorting_msgs
  "/home/robot6/catkin_ws/src/warehouse_sorting_msgs/msg/TaskStatus.msg"
  "${MSG_I_FLAGS}"
  "/opt/ros/noetic/share/std_msgs/cmake/../msg/Header.msg"
  ${CATKIN_DEVEL_PREFIX}/${genlisp_INSTALL_DIR}/warehouse_sorting_msgs
)

### Generating Services
_generate_srv_lisp(warehouse_sorting_msgs
  "/home/robot6/catkin_ws/src/warehouse_sorting_msgs/srv/ArmCommand.srv"
  "${MSG_I_FLAGS}"
  "/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Point.msg;/home/robot6/catkin_ws/src/warehouse_sorting_msgs/msg/Cargo.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Quaternion.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Vector3.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Pose.msg"
  ${CATKIN_DEVEL_PREFIX}/${genlisp_INSTALL_DIR}/warehouse_sorting_msgs
)
_generate_srv_lisp(warehouse_sorting_msgs
  "/home/robot6/catkin_ws/src/warehouse_sorting_msgs/srv/ScanRequest.srv"
  "${MSG_I_FLAGS}"
  "/opt/ros/noetic/share/std_msgs/cmake/../msg/Header.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Point.msg;/home/robot6/catkin_ws/src/warehouse_sorting_msgs/msg/DetectedCargoArray.msg;/home/robot6/catkin_ws/src/warehouse_sorting_msgs/msg/Cargo.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Quaternion.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Vector3.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Pose.msg"
  ${CATKIN_DEVEL_PREFIX}/${genlisp_INSTALL_DIR}/warehouse_sorting_msgs
)

### Generating Module File
_generate_module_lisp(warehouse_sorting_msgs
  ${CATKIN_DEVEL_PREFIX}/${genlisp_INSTALL_DIR}/warehouse_sorting_msgs
  "${ALL_GEN_OUTPUT_FILES_lisp}"
)

add_custom_target(warehouse_sorting_msgs_generate_messages_lisp
  DEPENDS ${ALL_GEN_OUTPUT_FILES_lisp}
)
add_dependencies(warehouse_sorting_msgs_generate_messages warehouse_sorting_msgs_generate_messages_lisp)

# add dependencies to all check dependencies targets
get_filename_component(_filename "/home/robot6/catkin_ws/src/warehouse_sorting_msgs/msg/Cargo.msg" NAME_WE)
add_dependencies(warehouse_sorting_msgs_generate_messages_lisp _warehouse_sorting_msgs_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/robot6/catkin_ws/src/warehouse_sorting_msgs/msg/DetectedCargoArray.msg" NAME_WE)
add_dependencies(warehouse_sorting_msgs_generate_messages_lisp _warehouse_sorting_msgs_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/robot6/catkin_ws/src/warehouse_sorting_msgs/msg/TaskStatus.msg" NAME_WE)
add_dependencies(warehouse_sorting_msgs_generate_messages_lisp _warehouse_sorting_msgs_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/robot6/catkin_ws/src/warehouse_sorting_msgs/srv/ArmCommand.srv" NAME_WE)
add_dependencies(warehouse_sorting_msgs_generate_messages_lisp _warehouse_sorting_msgs_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/robot6/catkin_ws/src/warehouse_sorting_msgs/srv/ScanRequest.srv" NAME_WE)
add_dependencies(warehouse_sorting_msgs_generate_messages_lisp _warehouse_sorting_msgs_generate_messages_check_deps_${_filename})

# target for backward compatibility
add_custom_target(warehouse_sorting_msgs_genlisp)
add_dependencies(warehouse_sorting_msgs_genlisp warehouse_sorting_msgs_generate_messages_lisp)

# register target for catkin_package(EXPORTED_TARGETS)
list(APPEND ${PROJECT_NAME}_EXPORTED_TARGETS warehouse_sorting_msgs_generate_messages_lisp)

### Section generating for lang: gennodejs
### Generating Messages
_generate_msg_nodejs(warehouse_sorting_msgs
  "/home/robot6/catkin_ws/src/warehouse_sorting_msgs/msg/Cargo.msg"
  "${MSG_I_FLAGS}"
  "/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Vector3.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Pose.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Point.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Quaternion.msg"
  ${CATKIN_DEVEL_PREFIX}/${gennodejs_INSTALL_DIR}/warehouse_sorting_msgs
)
_generate_msg_nodejs(warehouse_sorting_msgs
  "/home/robot6/catkin_ws/src/warehouse_sorting_msgs/msg/DetectedCargoArray.msg"
  "${MSG_I_FLAGS}"
  "/opt/ros/noetic/share/std_msgs/cmake/../msg/Header.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Point.msg;/home/robot6/catkin_ws/src/warehouse_sorting_msgs/msg/Cargo.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Quaternion.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Vector3.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Pose.msg"
  ${CATKIN_DEVEL_PREFIX}/${gennodejs_INSTALL_DIR}/warehouse_sorting_msgs
)
_generate_msg_nodejs(warehouse_sorting_msgs
  "/home/robot6/catkin_ws/src/warehouse_sorting_msgs/msg/TaskStatus.msg"
  "${MSG_I_FLAGS}"
  "/opt/ros/noetic/share/std_msgs/cmake/../msg/Header.msg"
  ${CATKIN_DEVEL_PREFIX}/${gennodejs_INSTALL_DIR}/warehouse_sorting_msgs
)

### Generating Services
_generate_srv_nodejs(warehouse_sorting_msgs
  "/home/robot6/catkin_ws/src/warehouse_sorting_msgs/srv/ArmCommand.srv"
  "${MSG_I_FLAGS}"
  "/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Point.msg;/home/robot6/catkin_ws/src/warehouse_sorting_msgs/msg/Cargo.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Quaternion.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Vector3.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Pose.msg"
  ${CATKIN_DEVEL_PREFIX}/${gennodejs_INSTALL_DIR}/warehouse_sorting_msgs
)
_generate_srv_nodejs(warehouse_sorting_msgs
  "/home/robot6/catkin_ws/src/warehouse_sorting_msgs/srv/ScanRequest.srv"
  "${MSG_I_FLAGS}"
  "/opt/ros/noetic/share/std_msgs/cmake/../msg/Header.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Point.msg;/home/robot6/catkin_ws/src/warehouse_sorting_msgs/msg/DetectedCargoArray.msg;/home/robot6/catkin_ws/src/warehouse_sorting_msgs/msg/Cargo.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Quaternion.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Vector3.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Pose.msg"
  ${CATKIN_DEVEL_PREFIX}/${gennodejs_INSTALL_DIR}/warehouse_sorting_msgs
)

### Generating Module File
_generate_module_nodejs(warehouse_sorting_msgs
  ${CATKIN_DEVEL_PREFIX}/${gennodejs_INSTALL_DIR}/warehouse_sorting_msgs
  "${ALL_GEN_OUTPUT_FILES_nodejs}"
)

add_custom_target(warehouse_sorting_msgs_generate_messages_nodejs
  DEPENDS ${ALL_GEN_OUTPUT_FILES_nodejs}
)
add_dependencies(warehouse_sorting_msgs_generate_messages warehouse_sorting_msgs_generate_messages_nodejs)

# add dependencies to all check dependencies targets
get_filename_component(_filename "/home/robot6/catkin_ws/src/warehouse_sorting_msgs/msg/Cargo.msg" NAME_WE)
add_dependencies(warehouse_sorting_msgs_generate_messages_nodejs _warehouse_sorting_msgs_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/robot6/catkin_ws/src/warehouse_sorting_msgs/msg/DetectedCargoArray.msg" NAME_WE)
add_dependencies(warehouse_sorting_msgs_generate_messages_nodejs _warehouse_sorting_msgs_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/robot6/catkin_ws/src/warehouse_sorting_msgs/msg/TaskStatus.msg" NAME_WE)
add_dependencies(warehouse_sorting_msgs_generate_messages_nodejs _warehouse_sorting_msgs_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/robot6/catkin_ws/src/warehouse_sorting_msgs/srv/ArmCommand.srv" NAME_WE)
add_dependencies(warehouse_sorting_msgs_generate_messages_nodejs _warehouse_sorting_msgs_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/robot6/catkin_ws/src/warehouse_sorting_msgs/srv/ScanRequest.srv" NAME_WE)
add_dependencies(warehouse_sorting_msgs_generate_messages_nodejs _warehouse_sorting_msgs_generate_messages_check_deps_${_filename})

# target for backward compatibility
add_custom_target(warehouse_sorting_msgs_gennodejs)
add_dependencies(warehouse_sorting_msgs_gennodejs warehouse_sorting_msgs_generate_messages_nodejs)

# register target for catkin_package(EXPORTED_TARGETS)
list(APPEND ${PROJECT_NAME}_EXPORTED_TARGETS warehouse_sorting_msgs_generate_messages_nodejs)

### Section generating for lang: genpy
### Generating Messages
_generate_msg_py(warehouse_sorting_msgs
  "/home/robot6/catkin_ws/src/warehouse_sorting_msgs/msg/Cargo.msg"
  "${MSG_I_FLAGS}"
  "/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Vector3.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Pose.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Point.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Quaternion.msg"
  ${CATKIN_DEVEL_PREFIX}/${genpy_INSTALL_DIR}/warehouse_sorting_msgs
)
_generate_msg_py(warehouse_sorting_msgs
  "/home/robot6/catkin_ws/src/warehouse_sorting_msgs/msg/DetectedCargoArray.msg"
  "${MSG_I_FLAGS}"
  "/opt/ros/noetic/share/std_msgs/cmake/../msg/Header.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Point.msg;/home/robot6/catkin_ws/src/warehouse_sorting_msgs/msg/Cargo.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Quaternion.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Vector3.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Pose.msg"
  ${CATKIN_DEVEL_PREFIX}/${genpy_INSTALL_DIR}/warehouse_sorting_msgs
)
_generate_msg_py(warehouse_sorting_msgs
  "/home/robot6/catkin_ws/src/warehouse_sorting_msgs/msg/TaskStatus.msg"
  "${MSG_I_FLAGS}"
  "/opt/ros/noetic/share/std_msgs/cmake/../msg/Header.msg"
  ${CATKIN_DEVEL_PREFIX}/${genpy_INSTALL_DIR}/warehouse_sorting_msgs
)

### Generating Services
_generate_srv_py(warehouse_sorting_msgs
  "/home/robot6/catkin_ws/src/warehouse_sorting_msgs/srv/ArmCommand.srv"
  "${MSG_I_FLAGS}"
  "/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Point.msg;/home/robot6/catkin_ws/src/warehouse_sorting_msgs/msg/Cargo.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Quaternion.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Vector3.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Pose.msg"
  ${CATKIN_DEVEL_PREFIX}/${genpy_INSTALL_DIR}/warehouse_sorting_msgs
)
_generate_srv_py(warehouse_sorting_msgs
  "/home/robot6/catkin_ws/src/warehouse_sorting_msgs/srv/ScanRequest.srv"
  "${MSG_I_FLAGS}"
  "/opt/ros/noetic/share/std_msgs/cmake/../msg/Header.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Point.msg;/home/robot6/catkin_ws/src/warehouse_sorting_msgs/msg/DetectedCargoArray.msg;/home/robot6/catkin_ws/src/warehouse_sorting_msgs/msg/Cargo.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Quaternion.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Vector3.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Pose.msg"
  ${CATKIN_DEVEL_PREFIX}/${genpy_INSTALL_DIR}/warehouse_sorting_msgs
)

### Generating Module File
_generate_module_py(warehouse_sorting_msgs
  ${CATKIN_DEVEL_PREFIX}/${genpy_INSTALL_DIR}/warehouse_sorting_msgs
  "${ALL_GEN_OUTPUT_FILES_py}"
)

add_custom_target(warehouse_sorting_msgs_generate_messages_py
  DEPENDS ${ALL_GEN_OUTPUT_FILES_py}
)
add_dependencies(warehouse_sorting_msgs_generate_messages warehouse_sorting_msgs_generate_messages_py)

# add dependencies to all check dependencies targets
get_filename_component(_filename "/home/robot6/catkin_ws/src/warehouse_sorting_msgs/msg/Cargo.msg" NAME_WE)
add_dependencies(warehouse_sorting_msgs_generate_messages_py _warehouse_sorting_msgs_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/robot6/catkin_ws/src/warehouse_sorting_msgs/msg/DetectedCargoArray.msg" NAME_WE)
add_dependencies(warehouse_sorting_msgs_generate_messages_py _warehouse_sorting_msgs_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/robot6/catkin_ws/src/warehouse_sorting_msgs/msg/TaskStatus.msg" NAME_WE)
add_dependencies(warehouse_sorting_msgs_generate_messages_py _warehouse_sorting_msgs_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/robot6/catkin_ws/src/warehouse_sorting_msgs/srv/ArmCommand.srv" NAME_WE)
add_dependencies(warehouse_sorting_msgs_generate_messages_py _warehouse_sorting_msgs_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/robot6/catkin_ws/src/warehouse_sorting_msgs/srv/ScanRequest.srv" NAME_WE)
add_dependencies(warehouse_sorting_msgs_generate_messages_py _warehouse_sorting_msgs_generate_messages_check_deps_${_filename})

# target for backward compatibility
add_custom_target(warehouse_sorting_msgs_genpy)
add_dependencies(warehouse_sorting_msgs_genpy warehouse_sorting_msgs_generate_messages_py)

# register target for catkin_package(EXPORTED_TARGETS)
list(APPEND ${PROJECT_NAME}_EXPORTED_TARGETS warehouse_sorting_msgs_generate_messages_py)



if(gencpp_INSTALL_DIR AND EXISTS ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/warehouse_sorting_msgs)
  # install generated code
  install(
    DIRECTORY ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/warehouse_sorting_msgs
    DESTINATION ${gencpp_INSTALL_DIR}
  )
endif()
if(TARGET geometry_msgs_generate_messages_cpp)
  add_dependencies(warehouse_sorting_msgs_generate_messages_cpp geometry_msgs_generate_messages_cpp)
endif()
if(TARGET std_msgs_generate_messages_cpp)
  add_dependencies(warehouse_sorting_msgs_generate_messages_cpp std_msgs_generate_messages_cpp)
endif()

if(geneus_INSTALL_DIR AND EXISTS ${CATKIN_DEVEL_PREFIX}/${geneus_INSTALL_DIR}/warehouse_sorting_msgs)
  # install generated code
  install(
    DIRECTORY ${CATKIN_DEVEL_PREFIX}/${geneus_INSTALL_DIR}/warehouse_sorting_msgs
    DESTINATION ${geneus_INSTALL_DIR}
  )
endif()
if(TARGET geometry_msgs_generate_messages_eus)
  add_dependencies(warehouse_sorting_msgs_generate_messages_eus geometry_msgs_generate_messages_eus)
endif()
if(TARGET std_msgs_generate_messages_eus)
  add_dependencies(warehouse_sorting_msgs_generate_messages_eus std_msgs_generate_messages_eus)
endif()

if(genlisp_INSTALL_DIR AND EXISTS ${CATKIN_DEVEL_PREFIX}/${genlisp_INSTALL_DIR}/warehouse_sorting_msgs)
  # install generated code
  install(
    DIRECTORY ${CATKIN_DEVEL_PREFIX}/${genlisp_INSTALL_DIR}/warehouse_sorting_msgs
    DESTINATION ${genlisp_INSTALL_DIR}
  )
endif()
if(TARGET geometry_msgs_generate_messages_lisp)
  add_dependencies(warehouse_sorting_msgs_generate_messages_lisp geometry_msgs_generate_messages_lisp)
endif()
if(TARGET std_msgs_generate_messages_lisp)
  add_dependencies(warehouse_sorting_msgs_generate_messages_lisp std_msgs_generate_messages_lisp)
endif()

if(gennodejs_INSTALL_DIR AND EXISTS ${CATKIN_DEVEL_PREFIX}/${gennodejs_INSTALL_DIR}/warehouse_sorting_msgs)
  # install generated code
  install(
    DIRECTORY ${CATKIN_DEVEL_PREFIX}/${gennodejs_INSTALL_DIR}/warehouse_sorting_msgs
    DESTINATION ${gennodejs_INSTALL_DIR}
  )
endif()
if(TARGET geometry_msgs_generate_messages_nodejs)
  add_dependencies(warehouse_sorting_msgs_generate_messages_nodejs geometry_msgs_generate_messages_nodejs)
endif()
if(TARGET std_msgs_generate_messages_nodejs)
  add_dependencies(warehouse_sorting_msgs_generate_messages_nodejs std_msgs_generate_messages_nodejs)
endif()

if(genpy_INSTALL_DIR AND EXISTS ${CATKIN_DEVEL_PREFIX}/${genpy_INSTALL_DIR}/warehouse_sorting_msgs)
  install(CODE "execute_process(COMMAND \"/usr/bin/python3\" -m compileall \"${CATKIN_DEVEL_PREFIX}/${genpy_INSTALL_DIR}/warehouse_sorting_msgs\")")
  # install generated code
  install(
    DIRECTORY ${CATKIN_DEVEL_PREFIX}/${genpy_INSTALL_DIR}/warehouse_sorting_msgs
    DESTINATION ${genpy_INSTALL_DIR}
  )
endif()
if(TARGET geometry_msgs_generate_messages_py)
  add_dependencies(warehouse_sorting_msgs_generate_messages_py geometry_msgs_generate_messages_py)
endif()
if(TARGET std_msgs_generate_messages_py)
  add_dependencies(warehouse_sorting_msgs_generate_messages_py std_msgs_generate_messages_py)
endif()
