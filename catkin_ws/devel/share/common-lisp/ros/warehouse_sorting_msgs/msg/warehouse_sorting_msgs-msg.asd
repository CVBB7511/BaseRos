
(cl:in-package :asdf)

(defsystem "warehouse_sorting_msgs-msg"
  :depends-on (:roslisp-msg-protocol :roslisp-utils :geometry_msgs-msg
               :std_msgs-msg
)
  :components ((:file "_package")
    (:file "Cargo" :depends-on ("_package_Cargo"))
    (:file "_package_Cargo" :depends-on ("_package"))
    (:file "DetectedCargoArray" :depends-on ("_package_DetectedCargoArray"))
    (:file "_package_DetectedCargoArray" :depends-on ("_package"))
    (:file "TaskStatus" :depends-on ("_package_TaskStatus"))
    (:file "_package_TaskStatus" :depends-on ("_package"))
  ))