
(cl:in-package :asdf)

(defsystem "navigation-srv"
  :depends-on (:roslisp-msg-protocol :roslisp-utils )
  :components ((:file "_package")
    (:file "Goal" :depends-on ("_package_Goal"))
    (:file "_package_Goal" :depends-on ("_package"))
    (:file "Halt" :depends-on ("_package_Halt"))
    (:file "_package_Halt" :depends-on ("_package"))
    (:file "Start" :depends-on ("_package_Start"))
    (:file "_package_Start" :depends-on ("_package"))
  ))