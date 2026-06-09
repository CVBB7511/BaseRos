
(cl:in-package :asdf)

(defsystem "fetch_server-srv"
  :depends-on (:roslisp-msg-protocol :roslisp-utils )
  :components ((:file "_package")
    (:file "Fetch" :depends-on ("_package_Fetch"))
    (:file "_package_Fetch" :depends-on ("_package"))
  ))