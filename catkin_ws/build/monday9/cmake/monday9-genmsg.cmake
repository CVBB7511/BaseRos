# generated from genmsg/cmake/pkg-genmsg.cmake.em

message(STATUS "monday9: 2 messages, 0 services")

set(MSG_I_FLAGS "-Imonday9:/home/robot6/catkin_ws/src/monday9/msg;-Istd_msgs:/opt/ros/noetic/share/std_msgs/cmake/../msg")

# Find all generators
find_package(gencpp REQUIRED)
find_package(geneus REQUIRED)
find_package(genlisp REQUIRED)
find_package(gennodejs REQUIRED)
find_package(genpy REQUIRED)

add_custom_target(monday9_generate_messages ALL)

# verify that message/service dependencies have not changed since configure



get_filename_component(_filename "/home/robot6/catkin_ws/src/monday9/msg/Coord.msg" NAME_WE)
add_custom_target(_monday9_generate_messages_check_deps_${_filename}
  COMMAND ${CATKIN_ENV} ${PYTHON_EXECUTABLE} ${GENMSG_CHECK_DEPS_SCRIPT} "monday9" "/home/robot6/catkin_ws/src/monday9/msg/Coord.msg" ""
)

get_filename_component(_filename "/home/robot6/catkin_ws/src/monday9/msg/Rect.msg" NAME_WE)
add_custom_target(_monday9_generate_messages_check_deps_${_filename}
  COMMAND ${CATKIN_ENV} ${PYTHON_EXECUTABLE} ${GENMSG_CHECK_DEPS_SCRIPT} "monday9" "/home/robot6/catkin_ws/src/monday9/msg/Rect.msg" ""
)

#
#  langs = gencpp;geneus;genlisp;gennodejs;genpy
#

### Section generating for lang: gencpp
### Generating Messages
_generate_msg_cpp(monday9
  "/home/robot6/catkin_ws/src/monday9/msg/Coord.msg"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/monday9
)
_generate_msg_cpp(monday9
  "/home/robot6/catkin_ws/src/monday9/msg/Rect.msg"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/monday9
)

### Generating Services

### Generating Module File
_generate_module_cpp(monday9
  ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/monday9
  "${ALL_GEN_OUTPUT_FILES_cpp}"
)

add_custom_target(monday9_generate_messages_cpp
  DEPENDS ${ALL_GEN_OUTPUT_FILES_cpp}
)
add_dependencies(monday9_generate_messages monday9_generate_messages_cpp)

# add dependencies to all check dependencies targets
get_filename_component(_filename "/home/robot6/catkin_ws/src/monday9/msg/Coord.msg" NAME_WE)
add_dependencies(monday9_generate_messages_cpp _monday9_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/robot6/catkin_ws/src/monday9/msg/Rect.msg" NAME_WE)
add_dependencies(monday9_generate_messages_cpp _monday9_generate_messages_check_deps_${_filename})

# target for backward compatibility
add_custom_target(monday9_gencpp)
add_dependencies(monday9_gencpp monday9_generate_messages_cpp)

# register target for catkin_package(EXPORTED_TARGETS)
list(APPEND ${PROJECT_NAME}_EXPORTED_TARGETS monday9_generate_messages_cpp)

### Section generating for lang: geneus
### Generating Messages
_generate_msg_eus(monday9
  "/home/robot6/catkin_ws/src/monday9/msg/Coord.msg"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${geneus_INSTALL_DIR}/monday9
)
_generate_msg_eus(monday9
  "/home/robot6/catkin_ws/src/monday9/msg/Rect.msg"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${geneus_INSTALL_DIR}/monday9
)

### Generating Services

### Generating Module File
_generate_module_eus(monday9
  ${CATKIN_DEVEL_PREFIX}/${geneus_INSTALL_DIR}/monday9
  "${ALL_GEN_OUTPUT_FILES_eus}"
)

add_custom_target(monday9_generate_messages_eus
  DEPENDS ${ALL_GEN_OUTPUT_FILES_eus}
)
add_dependencies(monday9_generate_messages monday9_generate_messages_eus)

# add dependencies to all check dependencies targets
get_filename_component(_filename "/home/robot6/catkin_ws/src/monday9/msg/Coord.msg" NAME_WE)
add_dependencies(monday9_generate_messages_eus _monday9_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/robot6/catkin_ws/src/monday9/msg/Rect.msg" NAME_WE)
add_dependencies(monday9_generate_messages_eus _monday9_generate_messages_check_deps_${_filename})

# target for backward compatibility
add_custom_target(monday9_geneus)
add_dependencies(monday9_geneus monday9_generate_messages_eus)

# register target for catkin_package(EXPORTED_TARGETS)
list(APPEND ${PROJECT_NAME}_EXPORTED_TARGETS monday9_generate_messages_eus)

### Section generating for lang: genlisp
### Generating Messages
_generate_msg_lisp(monday9
  "/home/robot6/catkin_ws/src/monday9/msg/Coord.msg"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${genlisp_INSTALL_DIR}/monday9
)
_generate_msg_lisp(monday9
  "/home/robot6/catkin_ws/src/monday9/msg/Rect.msg"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${genlisp_INSTALL_DIR}/monday9
)

### Generating Services

### Generating Module File
_generate_module_lisp(monday9
  ${CATKIN_DEVEL_PREFIX}/${genlisp_INSTALL_DIR}/monday9
  "${ALL_GEN_OUTPUT_FILES_lisp}"
)

add_custom_target(monday9_generate_messages_lisp
  DEPENDS ${ALL_GEN_OUTPUT_FILES_lisp}
)
add_dependencies(monday9_generate_messages monday9_generate_messages_lisp)

# add dependencies to all check dependencies targets
get_filename_component(_filename "/home/robot6/catkin_ws/src/monday9/msg/Coord.msg" NAME_WE)
add_dependencies(monday9_generate_messages_lisp _monday9_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/robot6/catkin_ws/src/monday9/msg/Rect.msg" NAME_WE)
add_dependencies(monday9_generate_messages_lisp _monday9_generate_messages_check_deps_${_filename})

# target for backward compatibility
add_custom_target(monday9_genlisp)
add_dependencies(monday9_genlisp monday9_generate_messages_lisp)

# register target for catkin_package(EXPORTED_TARGETS)
list(APPEND ${PROJECT_NAME}_EXPORTED_TARGETS monday9_generate_messages_lisp)

### Section generating for lang: gennodejs
### Generating Messages
_generate_msg_nodejs(monday9
  "/home/robot6/catkin_ws/src/monday9/msg/Coord.msg"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${gennodejs_INSTALL_DIR}/monday9
)
_generate_msg_nodejs(monday9
  "/home/robot6/catkin_ws/src/monday9/msg/Rect.msg"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${gennodejs_INSTALL_DIR}/monday9
)

### Generating Services

### Generating Module File
_generate_module_nodejs(monday9
  ${CATKIN_DEVEL_PREFIX}/${gennodejs_INSTALL_DIR}/monday9
  "${ALL_GEN_OUTPUT_FILES_nodejs}"
)

add_custom_target(monday9_generate_messages_nodejs
  DEPENDS ${ALL_GEN_OUTPUT_FILES_nodejs}
)
add_dependencies(monday9_generate_messages monday9_generate_messages_nodejs)

# add dependencies to all check dependencies targets
get_filename_component(_filename "/home/robot6/catkin_ws/src/monday9/msg/Coord.msg" NAME_WE)
add_dependencies(monday9_generate_messages_nodejs _monday9_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/robot6/catkin_ws/src/monday9/msg/Rect.msg" NAME_WE)
add_dependencies(monday9_generate_messages_nodejs _monday9_generate_messages_check_deps_${_filename})

# target for backward compatibility
add_custom_target(monday9_gennodejs)
add_dependencies(monday9_gennodejs monday9_generate_messages_nodejs)

# register target for catkin_package(EXPORTED_TARGETS)
list(APPEND ${PROJECT_NAME}_EXPORTED_TARGETS monday9_generate_messages_nodejs)

### Section generating for lang: genpy
### Generating Messages
_generate_msg_py(monday9
  "/home/robot6/catkin_ws/src/monday9/msg/Coord.msg"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${genpy_INSTALL_DIR}/monday9
)
_generate_msg_py(monday9
  "/home/robot6/catkin_ws/src/monday9/msg/Rect.msg"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${genpy_INSTALL_DIR}/monday9
)

### Generating Services

### Generating Module File
_generate_module_py(monday9
  ${CATKIN_DEVEL_PREFIX}/${genpy_INSTALL_DIR}/monday9
  "${ALL_GEN_OUTPUT_FILES_py}"
)

add_custom_target(monday9_generate_messages_py
  DEPENDS ${ALL_GEN_OUTPUT_FILES_py}
)
add_dependencies(monday9_generate_messages monday9_generate_messages_py)

# add dependencies to all check dependencies targets
get_filename_component(_filename "/home/robot6/catkin_ws/src/monday9/msg/Coord.msg" NAME_WE)
add_dependencies(monday9_generate_messages_py _monday9_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/robot6/catkin_ws/src/monday9/msg/Rect.msg" NAME_WE)
add_dependencies(monday9_generate_messages_py _monday9_generate_messages_check_deps_${_filename})

# target for backward compatibility
add_custom_target(monday9_genpy)
add_dependencies(monday9_genpy monday9_generate_messages_py)

# register target for catkin_package(EXPORTED_TARGETS)
list(APPEND ${PROJECT_NAME}_EXPORTED_TARGETS monday9_generate_messages_py)



if(gencpp_INSTALL_DIR AND EXISTS ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/monday9)
  # install generated code
  install(
    DIRECTORY ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/monday9
    DESTINATION ${gencpp_INSTALL_DIR}
  )
endif()
if(TARGET std_msgs_generate_messages_cpp)
  add_dependencies(monday9_generate_messages_cpp std_msgs_generate_messages_cpp)
endif()

if(geneus_INSTALL_DIR AND EXISTS ${CATKIN_DEVEL_PREFIX}/${geneus_INSTALL_DIR}/monday9)
  # install generated code
  install(
    DIRECTORY ${CATKIN_DEVEL_PREFIX}/${geneus_INSTALL_DIR}/monday9
    DESTINATION ${geneus_INSTALL_DIR}
  )
endif()
if(TARGET std_msgs_generate_messages_eus)
  add_dependencies(monday9_generate_messages_eus std_msgs_generate_messages_eus)
endif()

if(genlisp_INSTALL_DIR AND EXISTS ${CATKIN_DEVEL_PREFIX}/${genlisp_INSTALL_DIR}/monday9)
  # install generated code
  install(
    DIRECTORY ${CATKIN_DEVEL_PREFIX}/${genlisp_INSTALL_DIR}/monday9
    DESTINATION ${genlisp_INSTALL_DIR}
  )
endif()
if(TARGET std_msgs_generate_messages_lisp)
  add_dependencies(monday9_generate_messages_lisp std_msgs_generate_messages_lisp)
endif()

if(gennodejs_INSTALL_DIR AND EXISTS ${CATKIN_DEVEL_PREFIX}/${gennodejs_INSTALL_DIR}/monday9)
  # install generated code
  install(
    DIRECTORY ${CATKIN_DEVEL_PREFIX}/${gennodejs_INSTALL_DIR}/monday9
    DESTINATION ${gennodejs_INSTALL_DIR}
  )
endif()
if(TARGET std_msgs_generate_messages_nodejs)
  add_dependencies(monday9_generate_messages_nodejs std_msgs_generate_messages_nodejs)
endif()

if(genpy_INSTALL_DIR AND EXISTS ${CATKIN_DEVEL_PREFIX}/${genpy_INSTALL_DIR}/monday9)
  install(CODE "execute_process(COMMAND \"/usr/bin/python3\" -m compileall \"${CATKIN_DEVEL_PREFIX}/${genpy_INSTALL_DIR}/monday9\")")
  # install generated code
  install(
    DIRECTORY ${CATKIN_DEVEL_PREFIX}/${genpy_INSTALL_DIR}/monday9
    DESTINATION ${genpy_INSTALL_DIR}
  )
endif()
if(TARGET std_msgs_generate_messages_py)
  add_dependencies(monday9_generate_messages_py std_msgs_generate_messages_py)
endif()
