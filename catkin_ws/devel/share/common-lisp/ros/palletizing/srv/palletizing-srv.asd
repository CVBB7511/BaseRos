
(cl:in-package :asdf)

(defsystem "palletizing-srv"
  :depends-on (:roslisp-msg-protocol :roslisp-utils :geometry_msgs-msg
)
  :components ((:file "_package")
    (:file "SystemReset" :depends-on ("_package_SystemReset"))
    (:file "_package_SystemReset" :depends-on ("_package"))
    (:file "TriggerDetection" :depends-on ("_package_TriggerDetection"))
    (:file "_package_TriggerDetection" :depends-on ("_package"))
  ))