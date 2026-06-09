# Install script for directory: /home/robot6/catkin_ws/src/palletizing

# Set the install prefix
if(NOT DEFINED CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX "/home/robot6/catkin_ws/install")
endif()
string(REGEX REPLACE "/$" "" CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")

# Set the install configuration name.
if(NOT DEFINED CMAKE_INSTALL_CONFIG_NAME)
  if(BUILD_TYPE)
    string(REGEX REPLACE "^[^A-Za-z0-9_]+" ""
           CMAKE_INSTALL_CONFIG_NAME "${BUILD_TYPE}")
  else()
    set(CMAKE_INSTALL_CONFIG_NAME "")
  endif()
  message(STATUS "Install configuration: \"${CMAKE_INSTALL_CONFIG_NAME}\"")
endif()

# Set the component getting installed.
if(NOT CMAKE_INSTALL_COMPONENT)
  if(COMPONENT)
    message(STATUS "Install component: \"${COMPONENT}\"")
    set(CMAKE_INSTALL_COMPONENT "${COMPONENT}")
  else()
    set(CMAKE_INSTALL_COMPONENT)
  endif()
endif()

# Install shared libraries without execute permission?
if(NOT DEFINED CMAKE_INSTALL_SO_NO_EXE)
  set(CMAKE_INSTALL_SO_NO_EXE "1")
endif()

# Is this installation the result of a crosscompile?
if(NOT DEFINED CMAKE_CROSSCOMPILING)
  set(CMAKE_CROSSCOMPILING "FALSE")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  include("/home/robot6/catkin_ws/build/palletizing/catkin_generated/safe_execute_install.cmake")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/palletizing/srv" TYPE FILE FILES
    "/home/robot6/catkin_ws/src/palletizing/srv/TriggerDetection.srv"
    "/home/robot6/catkin_ws/src/palletizing/srv/SystemReset.srv"
    )
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/palletizing/action" TYPE FILE FILES
    "/home/robot6/catkin_ws/src/palletizing/action/Navigate.action"
    "/home/robot6/catkin_ws/src/palletizing/action/Grab.action"
    "/home/robot6/catkin_ws/src/palletizing/action/Palletize.action"
    )
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/palletizing/msg" TYPE FILE FILES
    "/home/robot6/catkin_ws/devel/share/palletizing/msg/NavigateAction.msg"
    "/home/robot6/catkin_ws/devel/share/palletizing/msg/NavigateActionGoal.msg"
    "/home/robot6/catkin_ws/devel/share/palletizing/msg/NavigateActionResult.msg"
    "/home/robot6/catkin_ws/devel/share/palletizing/msg/NavigateActionFeedback.msg"
    "/home/robot6/catkin_ws/devel/share/palletizing/msg/NavigateGoal.msg"
    "/home/robot6/catkin_ws/devel/share/palletizing/msg/NavigateResult.msg"
    "/home/robot6/catkin_ws/devel/share/palletizing/msg/NavigateFeedback.msg"
    )
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/palletizing/msg" TYPE FILE FILES
    "/home/robot6/catkin_ws/devel/share/palletizing/msg/GrabAction.msg"
    "/home/robot6/catkin_ws/devel/share/palletizing/msg/GrabActionGoal.msg"
    "/home/robot6/catkin_ws/devel/share/palletizing/msg/GrabActionResult.msg"
    "/home/robot6/catkin_ws/devel/share/palletizing/msg/GrabActionFeedback.msg"
    "/home/robot6/catkin_ws/devel/share/palletizing/msg/GrabGoal.msg"
    "/home/robot6/catkin_ws/devel/share/palletizing/msg/GrabResult.msg"
    "/home/robot6/catkin_ws/devel/share/palletizing/msg/GrabFeedback.msg"
    )
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/palletizing/msg" TYPE FILE FILES
    "/home/robot6/catkin_ws/devel/share/palletizing/msg/PalletizeAction.msg"
    "/home/robot6/catkin_ws/devel/share/palletizing/msg/PalletizeActionGoal.msg"
    "/home/robot6/catkin_ws/devel/share/palletizing/msg/PalletizeActionResult.msg"
    "/home/robot6/catkin_ws/devel/share/palletizing/msg/PalletizeActionFeedback.msg"
    "/home/robot6/catkin_ws/devel/share/palletizing/msg/PalletizeGoal.msg"
    "/home/robot6/catkin_ws/devel/share/palletizing/msg/PalletizeResult.msg"
    "/home/robot6/catkin_ws/devel/share/palletizing/msg/PalletizeFeedback.msg"
    )
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/palletizing/cmake" TYPE FILE FILES "/home/robot6/catkin_ws/build/palletizing/catkin_generated/installspace/palletizing-msg-paths.cmake")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include" TYPE DIRECTORY FILES "/home/robot6/catkin_ws/devel/include/palletizing")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/roseus/ros" TYPE DIRECTORY FILES "/home/robot6/catkin_ws/devel/share/roseus/ros/palletizing")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/common-lisp/ros" TYPE DIRECTORY FILES "/home/robot6/catkin_ws/devel/share/common-lisp/ros/palletizing")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/gennodejs/ros" TYPE DIRECTORY FILES "/home/robot6/catkin_ws/devel/share/gennodejs/ros/palletizing")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  execute_process(COMMAND "/usr/bin/python3" -m compileall "/home/robot6/catkin_ws/devel/lib/python3/dist-packages/palletizing")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib/python3/dist-packages" TYPE DIRECTORY FILES "/home/robot6/catkin_ws/devel/lib/python3/dist-packages/palletizing")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib/pkgconfig" TYPE FILE FILES "/home/robot6/catkin_ws/build/palletizing/catkin_generated/installspace/palletizing.pc")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/palletizing/cmake" TYPE FILE FILES "/home/robot6/catkin_ws/build/palletizing/catkin_generated/installspace/palletizing-msg-extras.cmake")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/palletizing/cmake" TYPE FILE FILES
    "/home/robot6/catkin_ws/build/palletizing/catkin_generated/installspace/palletizingConfig.cmake"
    "/home/robot6/catkin_ws/build/palletizing/catkin_generated/installspace/palletizingConfig-version.cmake"
    )
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/palletizing" TYPE FILE FILES "/home/robot6/catkin_ws/src/palletizing/package.xml")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib/palletizing" TYPE PROGRAM FILES "/home/robot6/catkin_ws/build/palletizing/catkin_generated/installspace/task_manager_node.py")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib/palletizing" TYPE PROGRAM FILES "/home/robot6/catkin_ws/build/palletizing/catkin_generated/installspace/navigation_server.py")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib/palletizing" TYPE PROGRAM FILES "/home/robot6/catkin_ws/build/palletizing/catkin_generated/installspace/manipulator_server.py")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib/palletizing" TYPE PROGRAM FILES "/home/robot6/catkin_ws/build/palletizing/catkin_generated/installspace/vision_service.py")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib/palletizing" TYPE PROGRAM FILES "/home/robot6/catkin_ws/build/palletizing/catkin_generated/installspace/spawn_blocks.py")
endif()

