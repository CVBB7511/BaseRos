# generated from genmsg/cmake/pkg-genmsg.cmake.em

message(STATUS "vizanti: 0 messages, 7 services")

set(MSG_I_FLAGS "-Istd_msgs:/opt/ros/noetic/share/std_msgs/cmake/../msg")

# Find all generators
find_package(gencpp REQUIRED)
find_package(geneus REQUIRED)
find_package(genlisp REQUIRED)
find_package(gennodejs REQUIRED)
find_package(genpy REQUIRED)

add_custom_target(vizanti_generate_messages ALL)

# verify that message/service dependencies have not changed since configure



get_filename_component(_filename "/home/xyntera/baseRos/catkin_ws/src/vizanti/srv/GetNodeParameters.srv" NAME_WE)
add_custom_target(_vizanti_generate_messages_check_deps_${_filename}
  COMMAND ${CATKIN_ENV} ${PYTHON_EXECUTABLE} ${GENMSG_CHECK_DEPS_SCRIPT} "vizanti" "/home/xyntera/baseRos/catkin_ws/src/vizanti/srv/GetNodeParameters.srv" ""
)

get_filename_component(_filename "/home/xyntera/baseRos/catkin_ws/src/vizanti/srv/SaveMap.srv" NAME_WE)
add_custom_target(_vizanti_generate_messages_check_deps_${_filename}
  COMMAND ${CATKIN_ENV} ${PYTHON_EXECUTABLE} ${GENMSG_CHECK_DEPS_SCRIPT} "vizanti" "/home/xyntera/baseRos/catkin_ws/src/vizanti/srv/SaveMap.srv" ""
)

get_filename_component(_filename "/home/xyntera/baseRos/catkin_ws/src/vizanti/srv/LoadMap.srv" NAME_WE)
add_custom_target(_vizanti_generate_messages_check_deps_${_filename}
  COMMAND ${CATKIN_ENV} ${PYTHON_EXECUTABLE} ${GENMSG_CHECK_DEPS_SCRIPT} "vizanti" "/home/xyntera/baseRos/catkin_ws/src/vizanti/srv/LoadMap.srv" ""
)

get_filename_component(_filename "/home/xyntera/baseRos/catkin_ws/src/vizanti/srv/RecordRosbag.srv" NAME_WE)
add_custom_target(_vizanti_generate_messages_check_deps_${_filename}
  COMMAND ${CATKIN_ENV} ${PYTHON_EXECUTABLE} ${GENMSG_CHECK_DEPS_SCRIPT} "vizanti" "/home/xyntera/baseRos/catkin_ws/src/vizanti/srv/RecordRosbag.srv" ""
)

get_filename_component(_filename "/home/xyntera/baseRos/catkin_ws/src/vizanti/srv/ManageNode.srv" NAME_WE)
add_custom_target(_vizanti_generate_messages_check_deps_${_filename}
  COMMAND ${CATKIN_ENV} ${PYTHON_EXECUTABLE} ${GENMSG_CHECK_DEPS_SCRIPT} "vizanti" "/home/xyntera/baseRos/catkin_ws/src/vizanti/srv/ManageNode.srv" ""
)

get_filename_component(_filename "/home/xyntera/baseRos/catkin_ws/src/vizanti/srv/ListPackages.srv" NAME_WE)
add_custom_target(_vizanti_generate_messages_check_deps_${_filename}
  COMMAND ${CATKIN_ENV} ${PYTHON_EXECUTABLE} ${GENMSG_CHECK_DEPS_SCRIPT} "vizanti" "/home/xyntera/baseRos/catkin_ws/src/vizanti/srv/ListPackages.srv" ""
)

get_filename_component(_filename "/home/xyntera/baseRos/catkin_ws/src/vizanti/srv/ListExecutables.srv" NAME_WE)
add_custom_target(_vizanti_generate_messages_check_deps_${_filename}
  COMMAND ${CATKIN_ENV} ${PYTHON_EXECUTABLE} ${GENMSG_CHECK_DEPS_SCRIPT} "vizanti" "/home/xyntera/baseRos/catkin_ws/src/vizanti/srv/ListExecutables.srv" ""
)

#
#  langs = gencpp;geneus;genlisp;gennodejs;genpy
#

### Section generating for lang: gencpp
### Generating Messages

### Generating Services
_generate_srv_cpp(vizanti
  "/home/xyntera/baseRos/catkin_ws/src/vizanti/srv/GetNodeParameters.srv"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/vizanti
)
_generate_srv_cpp(vizanti
  "/home/xyntera/baseRos/catkin_ws/src/vizanti/srv/SaveMap.srv"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/vizanti
)
_generate_srv_cpp(vizanti
  "/home/xyntera/baseRos/catkin_ws/src/vizanti/srv/LoadMap.srv"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/vizanti
)
_generate_srv_cpp(vizanti
  "/home/xyntera/baseRos/catkin_ws/src/vizanti/srv/RecordRosbag.srv"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/vizanti
)
_generate_srv_cpp(vizanti
  "/home/xyntera/baseRos/catkin_ws/src/vizanti/srv/ManageNode.srv"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/vizanti
)
_generate_srv_cpp(vizanti
  "/home/xyntera/baseRos/catkin_ws/src/vizanti/srv/ListPackages.srv"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/vizanti
)
_generate_srv_cpp(vizanti
  "/home/xyntera/baseRos/catkin_ws/src/vizanti/srv/ListExecutables.srv"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/vizanti
)

### Generating Module File
_generate_module_cpp(vizanti
  ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/vizanti
  "${ALL_GEN_OUTPUT_FILES_cpp}"
)

add_custom_target(vizanti_generate_messages_cpp
  DEPENDS ${ALL_GEN_OUTPUT_FILES_cpp}
)
add_dependencies(vizanti_generate_messages vizanti_generate_messages_cpp)

# add dependencies to all check dependencies targets
get_filename_component(_filename "/home/xyntera/baseRos/catkin_ws/src/vizanti/srv/GetNodeParameters.srv" NAME_WE)
add_dependencies(vizanti_generate_messages_cpp _vizanti_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/xyntera/baseRos/catkin_ws/src/vizanti/srv/SaveMap.srv" NAME_WE)
add_dependencies(vizanti_generate_messages_cpp _vizanti_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/xyntera/baseRos/catkin_ws/src/vizanti/srv/LoadMap.srv" NAME_WE)
add_dependencies(vizanti_generate_messages_cpp _vizanti_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/xyntera/baseRos/catkin_ws/src/vizanti/srv/RecordRosbag.srv" NAME_WE)
add_dependencies(vizanti_generate_messages_cpp _vizanti_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/xyntera/baseRos/catkin_ws/src/vizanti/srv/ManageNode.srv" NAME_WE)
add_dependencies(vizanti_generate_messages_cpp _vizanti_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/xyntera/baseRos/catkin_ws/src/vizanti/srv/ListPackages.srv" NAME_WE)
add_dependencies(vizanti_generate_messages_cpp _vizanti_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/xyntera/baseRos/catkin_ws/src/vizanti/srv/ListExecutables.srv" NAME_WE)
add_dependencies(vizanti_generate_messages_cpp _vizanti_generate_messages_check_deps_${_filename})

# target for backward compatibility
add_custom_target(vizanti_gencpp)
add_dependencies(vizanti_gencpp vizanti_generate_messages_cpp)

# register target for catkin_package(EXPORTED_TARGETS)
list(APPEND ${PROJECT_NAME}_EXPORTED_TARGETS vizanti_generate_messages_cpp)

### Section generating for lang: geneus
### Generating Messages

### Generating Services
_generate_srv_eus(vizanti
  "/home/xyntera/baseRos/catkin_ws/src/vizanti/srv/GetNodeParameters.srv"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${geneus_INSTALL_DIR}/vizanti
)
_generate_srv_eus(vizanti
  "/home/xyntera/baseRos/catkin_ws/src/vizanti/srv/SaveMap.srv"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${geneus_INSTALL_DIR}/vizanti
)
_generate_srv_eus(vizanti
  "/home/xyntera/baseRos/catkin_ws/src/vizanti/srv/LoadMap.srv"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${geneus_INSTALL_DIR}/vizanti
)
_generate_srv_eus(vizanti
  "/home/xyntera/baseRos/catkin_ws/src/vizanti/srv/RecordRosbag.srv"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${geneus_INSTALL_DIR}/vizanti
)
_generate_srv_eus(vizanti
  "/home/xyntera/baseRos/catkin_ws/src/vizanti/srv/ManageNode.srv"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${geneus_INSTALL_DIR}/vizanti
)
_generate_srv_eus(vizanti
  "/home/xyntera/baseRos/catkin_ws/src/vizanti/srv/ListPackages.srv"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${geneus_INSTALL_DIR}/vizanti
)
_generate_srv_eus(vizanti
  "/home/xyntera/baseRos/catkin_ws/src/vizanti/srv/ListExecutables.srv"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${geneus_INSTALL_DIR}/vizanti
)

### Generating Module File
_generate_module_eus(vizanti
  ${CATKIN_DEVEL_PREFIX}/${geneus_INSTALL_DIR}/vizanti
  "${ALL_GEN_OUTPUT_FILES_eus}"
)

add_custom_target(vizanti_generate_messages_eus
  DEPENDS ${ALL_GEN_OUTPUT_FILES_eus}
)
add_dependencies(vizanti_generate_messages vizanti_generate_messages_eus)

# add dependencies to all check dependencies targets
get_filename_component(_filename "/home/xyntera/baseRos/catkin_ws/src/vizanti/srv/GetNodeParameters.srv" NAME_WE)
add_dependencies(vizanti_generate_messages_eus _vizanti_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/xyntera/baseRos/catkin_ws/src/vizanti/srv/SaveMap.srv" NAME_WE)
add_dependencies(vizanti_generate_messages_eus _vizanti_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/xyntera/baseRos/catkin_ws/src/vizanti/srv/LoadMap.srv" NAME_WE)
add_dependencies(vizanti_generate_messages_eus _vizanti_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/xyntera/baseRos/catkin_ws/src/vizanti/srv/RecordRosbag.srv" NAME_WE)
add_dependencies(vizanti_generate_messages_eus _vizanti_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/xyntera/baseRos/catkin_ws/src/vizanti/srv/ManageNode.srv" NAME_WE)
add_dependencies(vizanti_generate_messages_eus _vizanti_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/xyntera/baseRos/catkin_ws/src/vizanti/srv/ListPackages.srv" NAME_WE)
add_dependencies(vizanti_generate_messages_eus _vizanti_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/xyntera/baseRos/catkin_ws/src/vizanti/srv/ListExecutables.srv" NAME_WE)
add_dependencies(vizanti_generate_messages_eus _vizanti_generate_messages_check_deps_${_filename})

# target for backward compatibility
add_custom_target(vizanti_geneus)
add_dependencies(vizanti_geneus vizanti_generate_messages_eus)

# register target for catkin_package(EXPORTED_TARGETS)
list(APPEND ${PROJECT_NAME}_EXPORTED_TARGETS vizanti_generate_messages_eus)

### Section generating for lang: genlisp
### Generating Messages

### Generating Services
_generate_srv_lisp(vizanti
  "/home/xyntera/baseRos/catkin_ws/src/vizanti/srv/GetNodeParameters.srv"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${genlisp_INSTALL_DIR}/vizanti
)
_generate_srv_lisp(vizanti
  "/home/xyntera/baseRos/catkin_ws/src/vizanti/srv/SaveMap.srv"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${genlisp_INSTALL_DIR}/vizanti
)
_generate_srv_lisp(vizanti
  "/home/xyntera/baseRos/catkin_ws/src/vizanti/srv/LoadMap.srv"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${genlisp_INSTALL_DIR}/vizanti
)
_generate_srv_lisp(vizanti
  "/home/xyntera/baseRos/catkin_ws/src/vizanti/srv/RecordRosbag.srv"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${genlisp_INSTALL_DIR}/vizanti
)
_generate_srv_lisp(vizanti
  "/home/xyntera/baseRos/catkin_ws/src/vizanti/srv/ManageNode.srv"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${genlisp_INSTALL_DIR}/vizanti
)
_generate_srv_lisp(vizanti
  "/home/xyntera/baseRos/catkin_ws/src/vizanti/srv/ListPackages.srv"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${genlisp_INSTALL_DIR}/vizanti
)
_generate_srv_lisp(vizanti
  "/home/xyntera/baseRos/catkin_ws/src/vizanti/srv/ListExecutables.srv"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${genlisp_INSTALL_DIR}/vizanti
)

### Generating Module File
_generate_module_lisp(vizanti
  ${CATKIN_DEVEL_PREFIX}/${genlisp_INSTALL_DIR}/vizanti
  "${ALL_GEN_OUTPUT_FILES_lisp}"
)

add_custom_target(vizanti_generate_messages_lisp
  DEPENDS ${ALL_GEN_OUTPUT_FILES_lisp}
)
add_dependencies(vizanti_generate_messages vizanti_generate_messages_lisp)

# add dependencies to all check dependencies targets
get_filename_component(_filename "/home/xyntera/baseRos/catkin_ws/src/vizanti/srv/GetNodeParameters.srv" NAME_WE)
add_dependencies(vizanti_generate_messages_lisp _vizanti_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/xyntera/baseRos/catkin_ws/src/vizanti/srv/SaveMap.srv" NAME_WE)
add_dependencies(vizanti_generate_messages_lisp _vizanti_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/xyntera/baseRos/catkin_ws/src/vizanti/srv/LoadMap.srv" NAME_WE)
add_dependencies(vizanti_generate_messages_lisp _vizanti_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/xyntera/baseRos/catkin_ws/src/vizanti/srv/RecordRosbag.srv" NAME_WE)
add_dependencies(vizanti_generate_messages_lisp _vizanti_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/xyntera/baseRos/catkin_ws/src/vizanti/srv/ManageNode.srv" NAME_WE)
add_dependencies(vizanti_generate_messages_lisp _vizanti_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/xyntera/baseRos/catkin_ws/src/vizanti/srv/ListPackages.srv" NAME_WE)
add_dependencies(vizanti_generate_messages_lisp _vizanti_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/xyntera/baseRos/catkin_ws/src/vizanti/srv/ListExecutables.srv" NAME_WE)
add_dependencies(vizanti_generate_messages_lisp _vizanti_generate_messages_check_deps_${_filename})

# target for backward compatibility
add_custom_target(vizanti_genlisp)
add_dependencies(vizanti_genlisp vizanti_generate_messages_lisp)

# register target for catkin_package(EXPORTED_TARGETS)
list(APPEND ${PROJECT_NAME}_EXPORTED_TARGETS vizanti_generate_messages_lisp)

### Section generating for lang: gennodejs
### Generating Messages

### Generating Services
_generate_srv_nodejs(vizanti
  "/home/xyntera/baseRos/catkin_ws/src/vizanti/srv/GetNodeParameters.srv"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${gennodejs_INSTALL_DIR}/vizanti
)
_generate_srv_nodejs(vizanti
  "/home/xyntera/baseRos/catkin_ws/src/vizanti/srv/SaveMap.srv"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${gennodejs_INSTALL_DIR}/vizanti
)
_generate_srv_nodejs(vizanti
  "/home/xyntera/baseRos/catkin_ws/src/vizanti/srv/LoadMap.srv"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${gennodejs_INSTALL_DIR}/vizanti
)
_generate_srv_nodejs(vizanti
  "/home/xyntera/baseRos/catkin_ws/src/vizanti/srv/RecordRosbag.srv"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${gennodejs_INSTALL_DIR}/vizanti
)
_generate_srv_nodejs(vizanti
  "/home/xyntera/baseRos/catkin_ws/src/vizanti/srv/ManageNode.srv"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${gennodejs_INSTALL_DIR}/vizanti
)
_generate_srv_nodejs(vizanti
  "/home/xyntera/baseRos/catkin_ws/src/vizanti/srv/ListPackages.srv"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${gennodejs_INSTALL_DIR}/vizanti
)
_generate_srv_nodejs(vizanti
  "/home/xyntera/baseRos/catkin_ws/src/vizanti/srv/ListExecutables.srv"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${gennodejs_INSTALL_DIR}/vizanti
)

### Generating Module File
_generate_module_nodejs(vizanti
  ${CATKIN_DEVEL_PREFIX}/${gennodejs_INSTALL_DIR}/vizanti
  "${ALL_GEN_OUTPUT_FILES_nodejs}"
)

add_custom_target(vizanti_generate_messages_nodejs
  DEPENDS ${ALL_GEN_OUTPUT_FILES_nodejs}
)
add_dependencies(vizanti_generate_messages vizanti_generate_messages_nodejs)

# add dependencies to all check dependencies targets
get_filename_component(_filename "/home/xyntera/baseRos/catkin_ws/src/vizanti/srv/GetNodeParameters.srv" NAME_WE)
add_dependencies(vizanti_generate_messages_nodejs _vizanti_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/xyntera/baseRos/catkin_ws/src/vizanti/srv/SaveMap.srv" NAME_WE)
add_dependencies(vizanti_generate_messages_nodejs _vizanti_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/xyntera/baseRos/catkin_ws/src/vizanti/srv/LoadMap.srv" NAME_WE)
add_dependencies(vizanti_generate_messages_nodejs _vizanti_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/xyntera/baseRos/catkin_ws/src/vizanti/srv/RecordRosbag.srv" NAME_WE)
add_dependencies(vizanti_generate_messages_nodejs _vizanti_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/xyntera/baseRos/catkin_ws/src/vizanti/srv/ManageNode.srv" NAME_WE)
add_dependencies(vizanti_generate_messages_nodejs _vizanti_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/xyntera/baseRos/catkin_ws/src/vizanti/srv/ListPackages.srv" NAME_WE)
add_dependencies(vizanti_generate_messages_nodejs _vizanti_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/xyntera/baseRos/catkin_ws/src/vizanti/srv/ListExecutables.srv" NAME_WE)
add_dependencies(vizanti_generate_messages_nodejs _vizanti_generate_messages_check_deps_${_filename})

# target for backward compatibility
add_custom_target(vizanti_gennodejs)
add_dependencies(vizanti_gennodejs vizanti_generate_messages_nodejs)

# register target for catkin_package(EXPORTED_TARGETS)
list(APPEND ${PROJECT_NAME}_EXPORTED_TARGETS vizanti_generate_messages_nodejs)

### Section generating for lang: genpy
### Generating Messages

### Generating Services
_generate_srv_py(vizanti
  "/home/xyntera/baseRos/catkin_ws/src/vizanti/srv/GetNodeParameters.srv"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${genpy_INSTALL_DIR}/vizanti
)
_generate_srv_py(vizanti
  "/home/xyntera/baseRos/catkin_ws/src/vizanti/srv/SaveMap.srv"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${genpy_INSTALL_DIR}/vizanti
)
_generate_srv_py(vizanti
  "/home/xyntera/baseRos/catkin_ws/src/vizanti/srv/LoadMap.srv"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${genpy_INSTALL_DIR}/vizanti
)
_generate_srv_py(vizanti
  "/home/xyntera/baseRos/catkin_ws/src/vizanti/srv/RecordRosbag.srv"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${genpy_INSTALL_DIR}/vizanti
)
_generate_srv_py(vizanti
  "/home/xyntera/baseRos/catkin_ws/src/vizanti/srv/ManageNode.srv"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${genpy_INSTALL_DIR}/vizanti
)
_generate_srv_py(vizanti
  "/home/xyntera/baseRos/catkin_ws/src/vizanti/srv/ListPackages.srv"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${genpy_INSTALL_DIR}/vizanti
)
_generate_srv_py(vizanti
  "/home/xyntera/baseRos/catkin_ws/src/vizanti/srv/ListExecutables.srv"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${genpy_INSTALL_DIR}/vizanti
)

### Generating Module File
_generate_module_py(vizanti
  ${CATKIN_DEVEL_PREFIX}/${genpy_INSTALL_DIR}/vizanti
  "${ALL_GEN_OUTPUT_FILES_py}"
)

add_custom_target(vizanti_generate_messages_py
  DEPENDS ${ALL_GEN_OUTPUT_FILES_py}
)
add_dependencies(vizanti_generate_messages vizanti_generate_messages_py)

# add dependencies to all check dependencies targets
get_filename_component(_filename "/home/xyntera/baseRos/catkin_ws/src/vizanti/srv/GetNodeParameters.srv" NAME_WE)
add_dependencies(vizanti_generate_messages_py _vizanti_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/xyntera/baseRos/catkin_ws/src/vizanti/srv/SaveMap.srv" NAME_WE)
add_dependencies(vizanti_generate_messages_py _vizanti_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/xyntera/baseRos/catkin_ws/src/vizanti/srv/LoadMap.srv" NAME_WE)
add_dependencies(vizanti_generate_messages_py _vizanti_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/xyntera/baseRos/catkin_ws/src/vizanti/srv/RecordRosbag.srv" NAME_WE)
add_dependencies(vizanti_generate_messages_py _vizanti_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/xyntera/baseRos/catkin_ws/src/vizanti/srv/ManageNode.srv" NAME_WE)
add_dependencies(vizanti_generate_messages_py _vizanti_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/xyntera/baseRos/catkin_ws/src/vizanti/srv/ListPackages.srv" NAME_WE)
add_dependencies(vizanti_generate_messages_py _vizanti_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/xyntera/baseRos/catkin_ws/src/vizanti/srv/ListExecutables.srv" NAME_WE)
add_dependencies(vizanti_generate_messages_py _vizanti_generate_messages_check_deps_${_filename})

# target for backward compatibility
add_custom_target(vizanti_genpy)
add_dependencies(vizanti_genpy vizanti_generate_messages_py)

# register target for catkin_package(EXPORTED_TARGETS)
list(APPEND ${PROJECT_NAME}_EXPORTED_TARGETS vizanti_generate_messages_py)



if(gencpp_INSTALL_DIR AND EXISTS ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/vizanti)
  # install generated code
  install(
    DIRECTORY ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/vizanti
    DESTINATION ${gencpp_INSTALL_DIR}
  )
endif()
if(TARGET std_msgs_generate_messages_cpp)
  add_dependencies(vizanti_generate_messages_cpp std_msgs_generate_messages_cpp)
endif()

if(geneus_INSTALL_DIR AND EXISTS ${CATKIN_DEVEL_PREFIX}/${geneus_INSTALL_DIR}/vizanti)
  # install generated code
  install(
    DIRECTORY ${CATKIN_DEVEL_PREFIX}/${geneus_INSTALL_DIR}/vizanti
    DESTINATION ${geneus_INSTALL_DIR}
  )
endif()
if(TARGET std_msgs_generate_messages_eus)
  add_dependencies(vizanti_generate_messages_eus std_msgs_generate_messages_eus)
endif()

if(genlisp_INSTALL_DIR AND EXISTS ${CATKIN_DEVEL_PREFIX}/${genlisp_INSTALL_DIR}/vizanti)
  # install generated code
  install(
    DIRECTORY ${CATKIN_DEVEL_PREFIX}/${genlisp_INSTALL_DIR}/vizanti
    DESTINATION ${genlisp_INSTALL_DIR}
  )
endif()
if(TARGET std_msgs_generate_messages_lisp)
  add_dependencies(vizanti_generate_messages_lisp std_msgs_generate_messages_lisp)
endif()

if(gennodejs_INSTALL_DIR AND EXISTS ${CATKIN_DEVEL_PREFIX}/${gennodejs_INSTALL_DIR}/vizanti)
  # install generated code
  install(
    DIRECTORY ${CATKIN_DEVEL_PREFIX}/${gennodejs_INSTALL_DIR}/vizanti
    DESTINATION ${gennodejs_INSTALL_DIR}
  )
endif()
if(TARGET std_msgs_generate_messages_nodejs)
  add_dependencies(vizanti_generate_messages_nodejs std_msgs_generate_messages_nodejs)
endif()

if(genpy_INSTALL_DIR AND EXISTS ${CATKIN_DEVEL_PREFIX}/${genpy_INSTALL_DIR}/vizanti)
  install(CODE "execute_process(COMMAND \"/usr/bin/python3\" -m compileall \"${CATKIN_DEVEL_PREFIX}/${genpy_INSTALL_DIR}/vizanti\")")
  # install generated code
  install(
    DIRECTORY ${CATKIN_DEVEL_PREFIX}/${genpy_INSTALL_DIR}/vizanti
    DESTINATION ${genpy_INSTALL_DIR}
  )
endif()
if(TARGET std_msgs_generate_messages_py)
  add_dependencies(vizanti_generate_messages_py std_msgs_generate_messages_py)
endif()
