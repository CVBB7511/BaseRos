
(cl:in-package :asdf)

(defsystem "library_robot_interfaces-msg"
  :depends-on (:roslisp-msg-protocol :roslisp-utils :std_msgs-msg
)
  :components ((:file "_package")
    (:file "CameraFrameData" :depends-on ("_package_CameraFrameData"))
    (:file "_package_CameraFrameData" :depends-on ("_package"))
    (:file "RobotStatusCompressed" :depends-on ("_package_RobotStatusCompressed"))
    (:file "_package_RobotStatusCompressed" :depends-on ("_package"))
    (:file "TaskDirective" :depends-on ("_package_TaskDirective"))
    (:file "_package_TaskDirective" :depends-on ("_package"))
    (:file "TaskFeedback" :depends-on ("_package_TaskFeedback"))
    (:file "_package_TaskFeedback" :depends-on ("_package"))
  ))