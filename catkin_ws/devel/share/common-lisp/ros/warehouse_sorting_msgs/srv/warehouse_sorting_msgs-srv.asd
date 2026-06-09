
(cl:in-package :asdf)

(defsystem "warehouse_sorting_msgs-srv"
  :depends-on (:roslisp-msg-protocol :roslisp-utils :geometry_msgs-msg
               :warehouse_sorting_msgs-msg
)
  :components ((:file "_package")
    (:file "ArmCommand" :depends-on ("_package_ArmCommand"))
    (:file "_package_ArmCommand" :depends-on ("_package"))
    (:file "ScanRequest" :depends-on ("_package_ScanRequest"))
    (:file "_package_ScanRequest" :depends-on ("_package"))
  ))