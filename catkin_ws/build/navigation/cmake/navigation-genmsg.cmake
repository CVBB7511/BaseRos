# generated from genmsg/cmake/pkg-genmsg.cmake.em

message(STATUS "navigation: 7 messages, 3 services")

set(MSG_I_FLAGS "-Inavigation:/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg;-Istd_msgs:/opt/ros/noetic/share/std_msgs/cmake/../msg;-Iactionlib_msgs:/opt/ros/noetic/share/actionlib_msgs/cmake/../msg;-Igeometry_msgs:/opt/ros/noetic/share/geometry_msgs/cmake/../msg")

# Find all generators
find_package(gencpp REQUIRED)
find_package(geneus REQUIRED)
find_package(genlisp REQUIRED)
find_package(gennodejs REQUIRED)
find_package(genpy REQUIRED)

add_custom_target(navigation_generate_messages ALL)

# verify that message/service dependencies have not changed since configure



get_filename_component(_filename "/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateAction.msg" NAME_WE)
add_custom_target(_navigation_generate_messages_check_deps_${_filename}
  COMMAND ${CATKIN_ENV} ${PYTHON_EXECUTABLE} ${GENMSG_CHECK_DEPS_SCRIPT} "navigation" "/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateAction.msg" "actionlib_msgs/GoalID:navigation/NavigateResult:navigation/NavigateFeedback:navigation/NavigateActionGoal:actionlib_msgs/GoalStatus:geometry_msgs/Quaternion:geometry_msgs/Point:navigation/NavigateGoal:geometry_msgs/Pose:navigation/NavigateActionFeedback:std_msgs/Header:navigation/NavigateActionResult"
)

get_filename_component(_filename "/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateActionGoal.msg" NAME_WE)
add_custom_target(_navigation_generate_messages_check_deps_${_filename}
  COMMAND ${CATKIN_ENV} ${PYTHON_EXECUTABLE} ${GENMSG_CHECK_DEPS_SCRIPT} "navigation" "/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateActionGoal.msg" "actionlib_msgs/GoalID:geometry_msgs/Quaternion:geometry_msgs/Point:navigation/NavigateGoal:geometry_msgs/Pose:std_msgs/Header"
)

get_filename_component(_filename "/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateActionResult.msg" NAME_WE)
add_custom_target(_navigation_generate_messages_check_deps_${_filename}
  COMMAND ${CATKIN_ENV} ${PYTHON_EXECUTABLE} ${GENMSG_CHECK_DEPS_SCRIPT} "navigation" "/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateActionResult.msg" "actionlib_msgs/GoalID:std_msgs/Header:navigation/NavigateResult:actionlib_msgs/GoalStatus"
)

get_filename_component(_filename "/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateActionFeedback.msg" NAME_WE)
add_custom_target(_navigation_generate_messages_check_deps_${_filename}
  COMMAND ${CATKIN_ENV} ${PYTHON_EXECUTABLE} ${GENMSG_CHECK_DEPS_SCRIPT} "navigation" "/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateActionFeedback.msg" "actionlib_msgs/GoalID:navigation/NavigateFeedback:std_msgs/Header:actionlib_msgs/GoalStatus"
)

get_filename_component(_filename "/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateGoal.msg" NAME_WE)
add_custom_target(_navigation_generate_messages_check_deps_${_filename}
  COMMAND ${CATKIN_ENV} ${PYTHON_EXECUTABLE} ${GENMSG_CHECK_DEPS_SCRIPT} "navigation" "/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateGoal.msg" "geometry_msgs/Quaternion:geometry_msgs/Point:geometry_msgs/Pose"
)

get_filename_component(_filename "/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateResult.msg" NAME_WE)
add_custom_target(_navigation_generate_messages_check_deps_${_filename}
  COMMAND ${CATKIN_ENV} ${PYTHON_EXECUTABLE} ${GENMSG_CHECK_DEPS_SCRIPT} "navigation" "/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateResult.msg" ""
)

get_filename_component(_filename "/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateFeedback.msg" NAME_WE)
add_custom_target(_navigation_generate_messages_check_deps_${_filename}
  COMMAND ${CATKIN_ENV} ${PYTHON_EXECUTABLE} ${GENMSG_CHECK_DEPS_SCRIPT} "navigation" "/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateFeedback.msg" ""
)

get_filename_component(_filename "/home/yubowen/BaseRos/catkin_ws/src/navigation/srv/Start.srv" NAME_WE)
add_custom_target(_navigation_generate_messages_check_deps_${_filename}
  COMMAND ${CATKIN_ENV} ${PYTHON_EXECUTABLE} ${GENMSG_CHECK_DEPS_SCRIPT} "navigation" "/home/yubowen/BaseRos/catkin_ws/src/navigation/srv/Start.srv" ""
)

get_filename_component(_filename "/home/yubowen/BaseRos/catkin_ws/src/navigation/srv/Goal.srv" NAME_WE)
add_custom_target(_navigation_generate_messages_check_deps_${_filename}
  COMMAND ${CATKIN_ENV} ${PYTHON_EXECUTABLE} ${GENMSG_CHECK_DEPS_SCRIPT} "navigation" "/home/yubowen/BaseRos/catkin_ws/src/navigation/srv/Goal.srv" ""
)

get_filename_component(_filename "/home/yubowen/BaseRos/catkin_ws/src/navigation/srv/Halt.srv" NAME_WE)
add_custom_target(_navigation_generate_messages_check_deps_${_filename}
  COMMAND ${CATKIN_ENV} ${PYTHON_EXECUTABLE} ${GENMSG_CHECK_DEPS_SCRIPT} "navigation" "/home/yubowen/BaseRos/catkin_ws/src/navigation/srv/Halt.srv" ""
)

#
#  langs = gencpp;geneus;genlisp;gennodejs;genpy
#

### Section generating for lang: gencpp
### Generating Messages
_generate_msg_cpp(navigation
  "/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateAction.msg"
  "${MSG_I_FLAGS}"
  "/opt/ros/noetic/share/actionlib_msgs/cmake/../msg/GoalID.msg;/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateResult.msg;/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateFeedback.msg;/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateActionGoal.msg;/opt/ros/noetic/share/actionlib_msgs/cmake/../msg/GoalStatus.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Quaternion.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Point.msg;/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateGoal.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Pose.msg;/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateActionFeedback.msg;/opt/ros/noetic/share/std_msgs/cmake/../msg/Header.msg;/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateActionResult.msg"
  ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/navigation
)
_generate_msg_cpp(navigation
  "/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateActionGoal.msg"
  "${MSG_I_FLAGS}"
  "/opt/ros/noetic/share/actionlib_msgs/cmake/../msg/GoalID.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Quaternion.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Point.msg;/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateGoal.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Pose.msg;/opt/ros/noetic/share/std_msgs/cmake/../msg/Header.msg"
  ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/navigation
)
_generate_msg_cpp(navigation
  "/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateActionResult.msg"
  "${MSG_I_FLAGS}"
  "/opt/ros/noetic/share/actionlib_msgs/cmake/../msg/GoalID.msg;/opt/ros/noetic/share/std_msgs/cmake/../msg/Header.msg;/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateResult.msg;/opt/ros/noetic/share/actionlib_msgs/cmake/../msg/GoalStatus.msg"
  ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/navigation
)
_generate_msg_cpp(navigation
  "/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateActionFeedback.msg"
  "${MSG_I_FLAGS}"
  "/opt/ros/noetic/share/actionlib_msgs/cmake/../msg/GoalID.msg;/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateFeedback.msg;/opt/ros/noetic/share/std_msgs/cmake/../msg/Header.msg;/opt/ros/noetic/share/actionlib_msgs/cmake/../msg/GoalStatus.msg"
  ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/navigation
)
_generate_msg_cpp(navigation
  "/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateGoal.msg"
  "${MSG_I_FLAGS}"
  "/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Quaternion.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Point.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Pose.msg"
  ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/navigation
)
_generate_msg_cpp(navigation
  "/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateResult.msg"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/navigation
)
_generate_msg_cpp(navigation
  "/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateFeedback.msg"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/navigation
)

### Generating Services
_generate_srv_cpp(navigation
  "/home/yubowen/BaseRos/catkin_ws/src/navigation/srv/Start.srv"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/navigation
)
_generate_srv_cpp(navigation
  "/home/yubowen/BaseRos/catkin_ws/src/navigation/srv/Goal.srv"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/navigation
)
_generate_srv_cpp(navigation
  "/home/yubowen/BaseRos/catkin_ws/src/navigation/srv/Halt.srv"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/navigation
)

### Generating Module File
_generate_module_cpp(navigation
  ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/navigation
  "${ALL_GEN_OUTPUT_FILES_cpp}"
)

add_custom_target(navigation_generate_messages_cpp
  DEPENDS ${ALL_GEN_OUTPUT_FILES_cpp}
)
add_dependencies(navigation_generate_messages navigation_generate_messages_cpp)

# add dependencies to all check dependencies targets
get_filename_component(_filename "/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateAction.msg" NAME_WE)
add_dependencies(navigation_generate_messages_cpp _navigation_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateActionGoal.msg" NAME_WE)
add_dependencies(navigation_generate_messages_cpp _navigation_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateActionResult.msg" NAME_WE)
add_dependencies(navigation_generate_messages_cpp _navigation_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateActionFeedback.msg" NAME_WE)
add_dependencies(navigation_generate_messages_cpp _navigation_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateGoal.msg" NAME_WE)
add_dependencies(navigation_generate_messages_cpp _navigation_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateResult.msg" NAME_WE)
add_dependencies(navigation_generate_messages_cpp _navigation_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateFeedback.msg" NAME_WE)
add_dependencies(navigation_generate_messages_cpp _navigation_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/yubowen/BaseRos/catkin_ws/src/navigation/srv/Start.srv" NAME_WE)
add_dependencies(navigation_generate_messages_cpp _navigation_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/yubowen/BaseRos/catkin_ws/src/navigation/srv/Goal.srv" NAME_WE)
add_dependencies(navigation_generate_messages_cpp _navigation_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/yubowen/BaseRos/catkin_ws/src/navigation/srv/Halt.srv" NAME_WE)
add_dependencies(navigation_generate_messages_cpp _navigation_generate_messages_check_deps_${_filename})

# target for backward compatibility
add_custom_target(navigation_gencpp)
add_dependencies(navigation_gencpp navigation_generate_messages_cpp)

# register target for catkin_package(EXPORTED_TARGETS)
list(APPEND ${PROJECT_NAME}_EXPORTED_TARGETS navigation_generate_messages_cpp)

### Section generating for lang: geneus
### Generating Messages
_generate_msg_eus(navigation
  "/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateAction.msg"
  "${MSG_I_FLAGS}"
  "/opt/ros/noetic/share/actionlib_msgs/cmake/../msg/GoalID.msg;/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateResult.msg;/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateFeedback.msg;/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateActionGoal.msg;/opt/ros/noetic/share/actionlib_msgs/cmake/../msg/GoalStatus.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Quaternion.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Point.msg;/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateGoal.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Pose.msg;/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateActionFeedback.msg;/opt/ros/noetic/share/std_msgs/cmake/../msg/Header.msg;/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateActionResult.msg"
  ${CATKIN_DEVEL_PREFIX}/${geneus_INSTALL_DIR}/navigation
)
_generate_msg_eus(navigation
  "/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateActionGoal.msg"
  "${MSG_I_FLAGS}"
  "/opt/ros/noetic/share/actionlib_msgs/cmake/../msg/GoalID.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Quaternion.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Point.msg;/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateGoal.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Pose.msg;/opt/ros/noetic/share/std_msgs/cmake/../msg/Header.msg"
  ${CATKIN_DEVEL_PREFIX}/${geneus_INSTALL_DIR}/navigation
)
_generate_msg_eus(navigation
  "/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateActionResult.msg"
  "${MSG_I_FLAGS}"
  "/opt/ros/noetic/share/actionlib_msgs/cmake/../msg/GoalID.msg;/opt/ros/noetic/share/std_msgs/cmake/../msg/Header.msg;/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateResult.msg;/opt/ros/noetic/share/actionlib_msgs/cmake/../msg/GoalStatus.msg"
  ${CATKIN_DEVEL_PREFIX}/${geneus_INSTALL_DIR}/navigation
)
_generate_msg_eus(navigation
  "/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateActionFeedback.msg"
  "${MSG_I_FLAGS}"
  "/opt/ros/noetic/share/actionlib_msgs/cmake/../msg/GoalID.msg;/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateFeedback.msg;/opt/ros/noetic/share/std_msgs/cmake/../msg/Header.msg;/opt/ros/noetic/share/actionlib_msgs/cmake/../msg/GoalStatus.msg"
  ${CATKIN_DEVEL_PREFIX}/${geneus_INSTALL_DIR}/navigation
)
_generate_msg_eus(navigation
  "/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateGoal.msg"
  "${MSG_I_FLAGS}"
  "/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Quaternion.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Point.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Pose.msg"
  ${CATKIN_DEVEL_PREFIX}/${geneus_INSTALL_DIR}/navigation
)
_generate_msg_eus(navigation
  "/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateResult.msg"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${geneus_INSTALL_DIR}/navigation
)
_generate_msg_eus(navigation
  "/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateFeedback.msg"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${geneus_INSTALL_DIR}/navigation
)

### Generating Services
_generate_srv_eus(navigation
  "/home/yubowen/BaseRos/catkin_ws/src/navigation/srv/Start.srv"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${geneus_INSTALL_DIR}/navigation
)
_generate_srv_eus(navigation
  "/home/yubowen/BaseRos/catkin_ws/src/navigation/srv/Goal.srv"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${geneus_INSTALL_DIR}/navigation
)
_generate_srv_eus(navigation
  "/home/yubowen/BaseRos/catkin_ws/src/navigation/srv/Halt.srv"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${geneus_INSTALL_DIR}/navigation
)

### Generating Module File
_generate_module_eus(navigation
  ${CATKIN_DEVEL_PREFIX}/${geneus_INSTALL_DIR}/navigation
  "${ALL_GEN_OUTPUT_FILES_eus}"
)

add_custom_target(navigation_generate_messages_eus
  DEPENDS ${ALL_GEN_OUTPUT_FILES_eus}
)
add_dependencies(navigation_generate_messages navigation_generate_messages_eus)

# add dependencies to all check dependencies targets
get_filename_component(_filename "/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateAction.msg" NAME_WE)
add_dependencies(navigation_generate_messages_eus _navigation_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateActionGoal.msg" NAME_WE)
add_dependencies(navigation_generate_messages_eus _navigation_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateActionResult.msg" NAME_WE)
add_dependencies(navigation_generate_messages_eus _navigation_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateActionFeedback.msg" NAME_WE)
add_dependencies(navigation_generate_messages_eus _navigation_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateGoal.msg" NAME_WE)
add_dependencies(navigation_generate_messages_eus _navigation_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateResult.msg" NAME_WE)
add_dependencies(navigation_generate_messages_eus _navigation_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateFeedback.msg" NAME_WE)
add_dependencies(navigation_generate_messages_eus _navigation_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/yubowen/BaseRos/catkin_ws/src/navigation/srv/Start.srv" NAME_WE)
add_dependencies(navigation_generate_messages_eus _navigation_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/yubowen/BaseRos/catkin_ws/src/navigation/srv/Goal.srv" NAME_WE)
add_dependencies(navigation_generate_messages_eus _navigation_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/yubowen/BaseRos/catkin_ws/src/navigation/srv/Halt.srv" NAME_WE)
add_dependencies(navigation_generate_messages_eus _navigation_generate_messages_check_deps_${_filename})

# target for backward compatibility
add_custom_target(navigation_geneus)
add_dependencies(navigation_geneus navigation_generate_messages_eus)

# register target for catkin_package(EXPORTED_TARGETS)
list(APPEND ${PROJECT_NAME}_EXPORTED_TARGETS navigation_generate_messages_eus)

### Section generating for lang: genlisp
### Generating Messages
_generate_msg_lisp(navigation
  "/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateAction.msg"
  "${MSG_I_FLAGS}"
  "/opt/ros/noetic/share/actionlib_msgs/cmake/../msg/GoalID.msg;/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateResult.msg;/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateFeedback.msg;/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateActionGoal.msg;/opt/ros/noetic/share/actionlib_msgs/cmake/../msg/GoalStatus.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Quaternion.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Point.msg;/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateGoal.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Pose.msg;/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateActionFeedback.msg;/opt/ros/noetic/share/std_msgs/cmake/../msg/Header.msg;/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateActionResult.msg"
  ${CATKIN_DEVEL_PREFIX}/${genlisp_INSTALL_DIR}/navigation
)
_generate_msg_lisp(navigation
  "/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateActionGoal.msg"
  "${MSG_I_FLAGS}"
  "/opt/ros/noetic/share/actionlib_msgs/cmake/../msg/GoalID.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Quaternion.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Point.msg;/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateGoal.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Pose.msg;/opt/ros/noetic/share/std_msgs/cmake/../msg/Header.msg"
  ${CATKIN_DEVEL_PREFIX}/${genlisp_INSTALL_DIR}/navigation
)
_generate_msg_lisp(navigation
  "/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateActionResult.msg"
  "${MSG_I_FLAGS}"
  "/opt/ros/noetic/share/actionlib_msgs/cmake/../msg/GoalID.msg;/opt/ros/noetic/share/std_msgs/cmake/../msg/Header.msg;/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateResult.msg;/opt/ros/noetic/share/actionlib_msgs/cmake/../msg/GoalStatus.msg"
  ${CATKIN_DEVEL_PREFIX}/${genlisp_INSTALL_DIR}/navigation
)
_generate_msg_lisp(navigation
  "/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateActionFeedback.msg"
  "${MSG_I_FLAGS}"
  "/opt/ros/noetic/share/actionlib_msgs/cmake/../msg/GoalID.msg;/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateFeedback.msg;/opt/ros/noetic/share/std_msgs/cmake/../msg/Header.msg;/opt/ros/noetic/share/actionlib_msgs/cmake/../msg/GoalStatus.msg"
  ${CATKIN_DEVEL_PREFIX}/${genlisp_INSTALL_DIR}/navigation
)
_generate_msg_lisp(navigation
  "/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateGoal.msg"
  "${MSG_I_FLAGS}"
  "/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Quaternion.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Point.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Pose.msg"
  ${CATKIN_DEVEL_PREFIX}/${genlisp_INSTALL_DIR}/navigation
)
_generate_msg_lisp(navigation
  "/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateResult.msg"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${genlisp_INSTALL_DIR}/navigation
)
_generate_msg_lisp(navigation
  "/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateFeedback.msg"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${genlisp_INSTALL_DIR}/navigation
)

### Generating Services
_generate_srv_lisp(navigation
  "/home/yubowen/BaseRos/catkin_ws/src/navigation/srv/Start.srv"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${genlisp_INSTALL_DIR}/navigation
)
_generate_srv_lisp(navigation
  "/home/yubowen/BaseRos/catkin_ws/src/navigation/srv/Goal.srv"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${genlisp_INSTALL_DIR}/navigation
)
_generate_srv_lisp(navigation
  "/home/yubowen/BaseRos/catkin_ws/src/navigation/srv/Halt.srv"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${genlisp_INSTALL_DIR}/navigation
)

### Generating Module File
_generate_module_lisp(navigation
  ${CATKIN_DEVEL_PREFIX}/${genlisp_INSTALL_DIR}/navigation
  "${ALL_GEN_OUTPUT_FILES_lisp}"
)

add_custom_target(navigation_generate_messages_lisp
  DEPENDS ${ALL_GEN_OUTPUT_FILES_lisp}
)
add_dependencies(navigation_generate_messages navigation_generate_messages_lisp)

# add dependencies to all check dependencies targets
get_filename_component(_filename "/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateAction.msg" NAME_WE)
add_dependencies(navigation_generate_messages_lisp _navigation_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateActionGoal.msg" NAME_WE)
add_dependencies(navigation_generate_messages_lisp _navigation_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateActionResult.msg" NAME_WE)
add_dependencies(navigation_generate_messages_lisp _navigation_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateActionFeedback.msg" NAME_WE)
add_dependencies(navigation_generate_messages_lisp _navigation_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateGoal.msg" NAME_WE)
add_dependencies(navigation_generate_messages_lisp _navigation_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateResult.msg" NAME_WE)
add_dependencies(navigation_generate_messages_lisp _navigation_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateFeedback.msg" NAME_WE)
add_dependencies(navigation_generate_messages_lisp _navigation_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/yubowen/BaseRos/catkin_ws/src/navigation/srv/Start.srv" NAME_WE)
add_dependencies(navigation_generate_messages_lisp _navigation_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/yubowen/BaseRos/catkin_ws/src/navigation/srv/Goal.srv" NAME_WE)
add_dependencies(navigation_generate_messages_lisp _navigation_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/yubowen/BaseRos/catkin_ws/src/navigation/srv/Halt.srv" NAME_WE)
add_dependencies(navigation_generate_messages_lisp _navigation_generate_messages_check_deps_${_filename})

# target for backward compatibility
add_custom_target(navigation_genlisp)
add_dependencies(navigation_genlisp navigation_generate_messages_lisp)

# register target for catkin_package(EXPORTED_TARGETS)
list(APPEND ${PROJECT_NAME}_EXPORTED_TARGETS navigation_generate_messages_lisp)

### Section generating for lang: gennodejs
### Generating Messages
_generate_msg_nodejs(navigation
  "/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateAction.msg"
  "${MSG_I_FLAGS}"
  "/opt/ros/noetic/share/actionlib_msgs/cmake/../msg/GoalID.msg;/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateResult.msg;/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateFeedback.msg;/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateActionGoal.msg;/opt/ros/noetic/share/actionlib_msgs/cmake/../msg/GoalStatus.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Quaternion.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Point.msg;/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateGoal.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Pose.msg;/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateActionFeedback.msg;/opt/ros/noetic/share/std_msgs/cmake/../msg/Header.msg;/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateActionResult.msg"
  ${CATKIN_DEVEL_PREFIX}/${gennodejs_INSTALL_DIR}/navigation
)
_generate_msg_nodejs(navigation
  "/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateActionGoal.msg"
  "${MSG_I_FLAGS}"
  "/opt/ros/noetic/share/actionlib_msgs/cmake/../msg/GoalID.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Quaternion.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Point.msg;/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateGoal.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Pose.msg;/opt/ros/noetic/share/std_msgs/cmake/../msg/Header.msg"
  ${CATKIN_DEVEL_PREFIX}/${gennodejs_INSTALL_DIR}/navigation
)
_generate_msg_nodejs(navigation
  "/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateActionResult.msg"
  "${MSG_I_FLAGS}"
  "/opt/ros/noetic/share/actionlib_msgs/cmake/../msg/GoalID.msg;/opt/ros/noetic/share/std_msgs/cmake/../msg/Header.msg;/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateResult.msg;/opt/ros/noetic/share/actionlib_msgs/cmake/../msg/GoalStatus.msg"
  ${CATKIN_DEVEL_PREFIX}/${gennodejs_INSTALL_DIR}/navigation
)
_generate_msg_nodejs(navigation
  "/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateActionFeedback.msg"
  "${MSG_I_FLAGS}"
  "/opt/ros/noetic/share/actionlib_msgs/cmake/../msg/GoalID.msg;/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateFeedback.msg;/opt/ros/noetic/share/std_msgs/cmake/../msg/Header.msg;/opt/ros/noetic/share/actionlib_msgs/cmake/../msg/GoalStatus.msg"
  ${CATKIN_DEVEL_PREFIX}/${gennodejs_INSTALL_DIR}/navigation
)
_generate_msg_nodejs(navigation
  "/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateGoal.msg"
  "${MSG_I_FLAGS}"
  "/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Quaternion.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Point.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Pose.msg"
  ${CATKIN_DEVEL_PREFIX}/${gennodejs_INSTALL_DIR}/navigation
)
_generate_msg_nodejs(navigation
  "/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateResult.msg"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${gennodejs_INSTALL_DIR}/navigation
)
_generate_msg_nodejs(navigation
  "/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateFeedback.msg"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${gennodejs_INSTALL_DIR}/navigation
)

### Generating Services
_generate_srv_nodejs(navigation
  "/home/yubowen/BaseRos/catkin_ws/src/navigation/srv/Start.srv"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${gennodejs_INSTALL_DIR}/navigation
)
_generate_srv_nodejs(navigation
  "/home/yubowen/BaseRos/catkin_ws/src/navigation/srv/Goal.srv"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${gennodejs_INSTALL_DIR}/navigation
)
_generate_srv_nodejs(navigation
  "/home/yubowen/BaseRos/catkin_ws/src/navigation/srv/Halt.srv"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${gennodejs_INSTALL_DIR}/navigation
)

### Generating Module File
_generate_module_nodejs(navigation
  ${CATKIN_DEVEL_PREFIX}/${gennodejs_INSTALL_DIR}/navigation
  "${ALL_GEN_OUTPUT_FILES_nodejs}"
)

add_custom_target(navigation_generate_messages_nodejs
  DEPENDS ${ALL_GEN_OUTPUT_FILES_nodejs}
)
add_dependencies(navigation_generate_messages navigation_generate_messages_nodejs)

# add dependencies to all check dependencies targets
get_filename_component(_filename "/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateAction.msg" NAME_WE)
add_dependencies(navigation_generate_messages_nodejs _navigation_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateActionGoal.msg" NAME_WE)
add_dependencies(navigation_generate_messages_nodejs _navigation_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateActionResult.msg" NAME_WE)
add_dependencies(navigation_generate_messages_nodejs _navigation_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateActionFeedback.msg" NAME_WE)
add_dependencies(navigation_generate_messages_nodejs _navigation_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateGoal.msg" NAME_WE)
add_dependencies(navigation_generate_messages_nodejs _navigation_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateResult.msg" NAME_WE)
add_dependencies(navigation_generate_messages_nodejs _navigation_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateFeedback.msg" NAME_WE)
add_dependencies(navigation_generate_messages_nodejs _navigation_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/yubowen/BaseRos/catkin_ws/src/navigation/srv/Start.srv" NAME_WE)
add_dependencies(navigation_generate_messages_nodejs _navigation_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/yubowen/BaseRos/catkin_ws/src/navigation/srv/Goal.srv" NAME_WE)
add_dependencies(navigation_generate_messages_nodejs _navigation_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/yubowen/BaseRos/catkin_ws/src/navigation/srv/Halt.srv" NAME_WE)
add_dependencies(navigation_generate_messages_nodejs _navigation_generate_messages_check_deps_${_filename})

# target for backward compatibility
add_custom_target(navigation_gennodejs)
add_dependencies(navigation_gennodejs navigation_generate_messages_nodejs)

# register target for catkin_package(EXPORTED_TARGETS)
list(APPEND ${PROJECT_NAME}_EXPORTED_TARGETS navigation_generate_messages_nodejs)

### Section generating for lang: genpy
### Generating Messages
_generate_msg_py(navigation
  "/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateAction.msg"
  "${MSG_I_FLAGS}"
  "/opt/ros/noetic/share/actionlib_msgs/cmake/../msg/GoalID.msg;/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateResult.msg;/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateFeedback.msg;/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateActionGoal.msg;/opt/ros/noetic/share/actionlib_msgs/cmake/../msg/GoalStatus.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Quaternion.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Point.msg;/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateGoal.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Pose.msg;/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateActionFeedback.msg;/opt/ros/noetic/share/std_msgs/cmake/../msg/Header.msg;/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateActionResult.msg"
  ${CATKIN_DEVEL_PREFIX}/${genpy_INSTALL_DIR}/navigation
)
_generate_msg_py(navigation
  "/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateActionGoal.msg"
  "${MSG_I_FLAGS}"
  "/opt/ros/noetic/share/actionlib_msgs/cmake/../msg/GoalID.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Quaternion.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Point.msg;/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateGoal.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Pose.msg;/opt/ros/noetic/share/std_msgs/cmake/../msg/Header.msg"
  ${CATKIN_DEVEL_PREFIX}/${genpy_INSTALL_DIR}/navigation
)
_generate_msg_py(navigation
  "/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateActionResult.msg"
  "${MSG_I_FLAGS}"
  "/opt/ros/noetic/share/actionlib_msgs/cmake/../msg/GoalID.msg;/opt/ros/noetic/share/std_msgs/cmake/../msg/Header.msg;/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateResult.msg;/opt/ros/noetic/share/actionlib_msgs/cmake/../msg/GoalStatus.msg"
  ${CATKIN_DEVEL_PREFIX}/${genpy_INSTALL_DIR}/navigation
)
_generate_msg_py(navigation
  "/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateActionFeedback.msg"
  "${MSG_I_FLAGS}"
  "/opt/ros/noetic/share/actionlib_msgs/cmake/../msg/GoalID.msg;/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateFeedback.msg;/opt/ros/noetic/share/std_msgs/cmake/../msg/Header.msg;/opt/ros/noetic/share/actionlib_msgs/cmake/../msg/GoalStatus.msg"
  ${CATKIN_DEVEL_PREFIX}/${genpy_INSTALL_DIR}/navigation
)
_generate_msg_py(navigation
  "/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateGoal.msg"
  "${MSG_I_FLAGS}"
  "/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Quaternion.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Point.msg;/opt/ros/noetic/share/geometry_msgs/cmake/../msg/Pose.msg"
  ${CATKIN_DEVEL_PREFIX}/${genpy_INSTALL_DIR}/navigation
)
_generate_msg_py(navigation
  "/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateResult.msg"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${genpy_INSTALL_DIR}/navigation
)
_generate_msg_py(navigation
  "/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateFeedback.msg"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${genpy_INSTALL_DIR}/navigation
)

### Generating Services
_generate_srv_py(navigation
  "/home/yubowen/BaseRos/catkin_ws/src/navigation/srv/Start.srv"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${genpy_INSTALL_DIR}/navigation
)
_generate_srv_py(navigation
  "/home/yubowen/BaseRos/catkin_ws/src/navigation/srv/Goal.srv"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${genpy_INSTALL_DIR}/navigation
)
_generate_srv_py(navigation
  "/home/yubowen/BaseRos/catkin_ws/src/navigation/srv/Halt.srv"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${genpy_INSTALL_DIR}/navigation
)

### Generating Module File
_generate_module_py(navigation
  ${CATKIN_DEVEL_PREFIX}/${genpy_INSTALL_DIR}/navigation
  "${ALL_GEN_OUTPUT_FILES_py}"
)

add_custom_target(navigation_generate_messages_py
  DEPENDS ${ALL_GEN_OUTPUT_FILES_py}
)
add_dependencies(navigation_generate_messages navigation_generate_messages_py)

# add dependencies to all check dependencies targets
get_filename_component(_filename "/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateAction.msg" NAME_WE)
add_dependencies(navigation_generate_messages_py _navigation_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateActionGoal.msg" NAME_WE)
add_dependencies(navigation_generate_messages_py _navigation_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateActionResult.msg" NAME_WE)
add_dependencies(navigation_generate_messages_py _navigation_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateActionFeedback.msg" NAME_WE)
add_dependencies(navigation_generate_messages_py _navigation_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateGoal.msg" NAME_WE)
add_dependencies(navigation_generate_messages_py _navigation_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateResult.msg" NAME_WE)
add_dependencies(navigation_generate_messages_py _navigation_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/yubowen/BaseRos/catkin_ws/devel/share/navigation/msg/NavigateFeedback.msg" NAME_WE)
add_dependencies(navigation_generate_messages_py _navigation_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/yubowen/BaseRos/catkin_ws/src/navigation/srv/Start.srv" NAME_WE)
add_dependencies(navigation_generate_messages_py _navigation_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/yubowen/BaseRos/catkin_ws/src/navigation/srv/Goal.srv" NAME_WE)
add_dependencies(navigation_generate_messages_py _navigation_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/yubowen/BaseRos/catkin_ws/src/navigation/srv/Halt.srv" NAME_WE)
add_dependencies(navigation_generate_messages_py _navigation_generate_messages_check_deps_${_filename})

# target for backward compatibility
add_custom_target(navigation_genpy)
add_dependencies(navigation_genpy navigation_generate_messages_py)

# register target for catkin_package(EXPORTED_TARGETS)
list(APPEND ${PROJECT_NAME}_EXPORTED_TARGETS navigation_generate_messages_py)



if(gencpp_INSTALL_DIR AND EXISTS ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/navigation)
  # install generated code
  install(
    DIRECTORY ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/navigation
    DESTINATION ${gencpp_INSTALL_DIR}
  )
endif()
if(TARGET std_msgs_generate_messages_cpp)
  add_dependencies(navigation_generate_messages_cpp std_msgs_generate_messages_cpp)
endif()
if(TARGET actionlib_msgs_generate_messages_cpp)
  add_dependencies(navigation_generate_messages_cpp actionlib_msgs_generate_messages_cpp)
endif()
if(TARGET geometry_msgs_generate_messages_cpp)
  add_dependencies(navigation_generate_messages_cpp geometry_msgs_generate_messages_cpp)
endif()

if(geneus_INSTALL_DIR AND EXISTS ${CATKIN_DEVEL_PREFIX}/${geneus_INSTALL_DIR}/navigation)
  # install generated code
  install(
    DIRECTORY ${CATKIN_DEVEL_PREFIX}/${geneus_INSTALL_DIR}/navigation
    DESTINATION ${geneus_INSTALL_DIR}
  )
endif()
if(TARGET std_msgs_generate_messages_eus)
  add_dependencies(navigation_generate_messages_eus std_msgs_generate_messages_eus)
endif()
if(TARGET actionlib_msgs_generate_messages_eus)
  add_dependencies(navigation_generate_messages_eus actionlib_msgs_generate_messages_eus)
endif()
if(TARGET geometry_msgs_generate_messages_eus)
  add_dependencies(navigation_generate_messages_eus geometry_msgs_generate_messages_eus)
endif()

if(genlisp_INSTALL_DIR AND EXISTS ${CATKIN_DEVEL_PREFIX}/${genlisp_INSTALL_DIR}/navigation)
  # install generated code
  install(
    DIRECTORY ${CATKIN_DEVEL_PREFIX}/${genlisp_INSTALL_DIR}/navigation
    DESTINATION ${genlisp_INSTALL_DIR}
  )
endif()
if(TARGET std_msgs_generate_messages_lisp)
  add_dependencies(navigation_generate_messages_lisp std_msgs_generate_messages_lisp)
endif()
if(TARGET actionlib_msgs_generate_messages_lisp)
  add_dependencies(navigation_generate_messages_lisp actionlib_msgs_generate_messages_lisp)
endif()
if(TARGET geometry_msgs_generate_messages_lisp)
  add_dependencies(navigation_generate_messages_lisp geometry_msgs_generate_messages_lisp)
endif()

if(gennodejs_INSTALL_DIR AND EXISTS ${CATKIN_DEVEL_PREFIX}/${gennodejs_INSTALL_DIR}/navigation)
  # install generated code
  install(
    DIRECTORY ${CATKIN_DEVEL_PREFIX}/${gennodejs_INSTALL_DIR}/navigation
    DESTINATION ${gennodejs_INSTALL_DIR}
  )
endif()
if(TARGET std_msgs_generate_messages_nodejs)
  add_dependencies(navigation_generate_messages_nodejs std_msgs_generate_messages_nodejs)
endif()
if(TARGET actionlib_msgs_generate_messages_nodejs)
  add_dependencies(navigation_generate_messages_nodejs actionlib_msgs_generate_messages_nodejs)
endif()
if(TARGET geometry_msgs_generate_messages_nodejs)
  add_dependencies(navigation_generate_messages_nodejs geometry_msgs_generate_messages_nodejs)
endif()

if(genpy_INSTALL_DIR AND EXISTS ${CATKIN_DEVEL_PREFIX}/${genpy_INSTALL_DIR}/navigation)
  install(CODE "execute_process(COMMAND \"/usr/bin/python3\" -m compileall \"${CATKIN_DEVEL_PREFIX}/${genpy_INSTALL_DIR}/navigation\")")
  # install generated code
  install(
    DIRECTORY ${CATKIN_DEVEL_PREFIX}/${genpy_INSTALL_DIR}/navigation
    DESTINATION ${genpy_INSTALL_DIR}
  )
endif()
if(TARGET std_msgs_generate_messages_py)
  add_dependencies(navigation_generate_messages_py std_msgs_generate_messages_py)
endif()
if(TARGET actionlib_msgs_generate_messages_py)
  add_dependencies(navigation_generate_messages_py actionlib_msgs_generate_messages_py)
endif()
if(TARGET geometry_msgs_generate_messages_py)
  add_dependencies(navigation_generate_messages_py geometry_msgs_generate_messages_py)
endif()
