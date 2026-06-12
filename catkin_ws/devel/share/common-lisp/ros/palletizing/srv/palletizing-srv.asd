
(cl:in-package :asdf)

(defsystem "palletizing-srv"
  :depends-on (:roslisp-msg-protocol :roslisp-utils )
  :components ((:file "_package")
    (:file "MarkZone" :depends-on ("_package_MarkZone"))
    (:file "_package_MarkZone" :depends-on ("_package"))
    (:file "StartTask" :depends-on ("_package_StartTask"))
    (:file "_package_StartTask" :depends-on ("_package"))
  ))