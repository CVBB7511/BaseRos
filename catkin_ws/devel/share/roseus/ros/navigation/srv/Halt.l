;; Auto-generated. Do not edit!


(when (boundp 'navigation::Halt)
  (if (not (find-package "NAVIGATION"))
    (make-package "NAVIGATION"))
  (shadow 'Halt (find-package "NAVIGATION")))
(unless (find-package "NAVIGATION::HALT")
  (make-package "NAVIGATION::HALT"))
(unless (find-package "NAVIGATION::HALTREQUEST")
  (make-package "NAVIGATION::HALTREQUEST"))
(unless (find-package "NAVIGATION::HALTRESPONSE")
  (make-package "NAVIGATION::HALTRESPONSE"))

(in-package "ROS")





(defclass navigation::HaltRequest
  :super ros::object
  :slots ())

(defmethod navigation::HaltRequest
  (:init
   (&key
    )
   (send-super :init)
   self)
  (:serialization-length
   ()
   (+
    0
    ))
  (:serialize
   (&optional strm)
   (let ((s (if strm strm
              (make-string-output-stream (send self :serialization-length)))))
     ;;
     (if (null strm) (get-output-stream-string s))))
  (:deserialize
   (buf &optional (ptr- 0))
   ;;
   self)
  )

(defclass navigation::HaltResponse
  :super ros::object
  :slots (_success _message ))

(defmethod navigation::HaltResponse
  (:init
   (&key
    ((:success __success) nil)
    ((:message __message) "")
    )
   (send-super :init)
   (setq _success __success)
   (setq _message (string __message))
   self)
  (:success
   (&optional (__success :null))
   (if (not (eq __success :null)) (setq _success __success)) _success)
  (:message
   (&optional __message)
   (if __message (setq _message __message)) _message)
  (:serialization-length
   ()
   (+
    ;; bool _success
    1
    ;; string _message
    4 (length _message)
    ))
  (:serialize
   (&optional strm)
   (let ((s (if strm strm
              (make-string-output-stream (send self :serialization-length)))))
     ;; bool _success
       (if _success (write-byte -1 s) (write-byte 0 s))
     ;; string _message
       (write-long (length _message) s) (princ _message s)
     ;;
     (if (null strm) (get-output-stream-string s))))
  (:deserialize
   (buf &optional (ptr- 0))
   ;; bool _success
     (setq _success (not (= 0 (sys::peek buf ptr- :char)))) (incf ptr- 1)
   ;; string _message
     (let (n) (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4) (setq _message (subseq buf ptr- (+ ptr- n))) (incf ptr- n))
   ;;
   self)
  )

(defclass navigation::Halt
  :super ros::object
  :slots ())

(setf (get navigation::Halt :md5sum-) "937c9679a518e3a18d831e57125ea522")
(setf (get navigation::Halt :datatype-) "navigation/Halt")
(setf (get navigation::Halt :request) navigation::HaltRequest)
(setf (get navigation::Halt :response) navigation::HaltResponse)

(defmethod navigation::HaltRequest
  (:response () (instance navigation::HaltResponse :init)))

(setf (get navigation::HaltRequest :md5sum-) "937c9679a518e3a18d831e57125ea522")
(setf (get navigation::HaltRequest :datatype-) "navigation/HaltRequest")
(setf (get navigation::HaltRequest :definition-)
      "---
bool success
string message
")

(setf (get navigation::HaltResponse :md5sum-) "937c9679a518e3a18d831e57125ea522")
(setf (get navigation::HaltResponse :datatype-) "navigation/HaltResponse")
(setf (get navigation::HaltResponse :definition-)
      "---
bool success
string message
")



(provide :navigation/Halt "937c9679a518e3a18d831e57125ea522")


