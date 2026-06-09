
(cl:in-package :asdf)

(defsystem "arm_controller-srv"
  :depends-on (:roslisp-msg-protocol :roslisp-utils )
  :components ((:file "_package")
    (:file "Place" :depends-on ("_package_Place"))
    (:file "_package_Place" :depends-on ("_package"))
  ))