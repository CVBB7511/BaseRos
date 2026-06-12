
(cl:in-package :asdf)

(defsystem "palletizing-msg"
  :depends-on (:roslisp-msg-protocol :roslisp-utils )
  :components ((:file "_package")
    (:file "PalletizingStats" :depends-on ("_package_PalletizingStats"))
    (:file "_package_PalletizingStats" :depends-on ("_package"))
    (:file "SafetyStatus" :depends-on ("_package_SafetyStatus"))
    (:file "_package_SafetyStatus" :depends-on ("_package"))
  ))