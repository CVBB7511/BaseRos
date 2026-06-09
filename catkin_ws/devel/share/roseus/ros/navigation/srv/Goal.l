;; Auto-generated. Do not edit!


(when (boundp 'navigation::Goal)
  (if (not (find-package "NAVIGATION"))
    (make-package "NAVIGATION"))
  (shadow 'Goal (find-package "NAVIGATION")))
(unless (find-package "NAVIGATION::GOAL")
  (make-package "NAVIGATION::GOAL"))
(unless (find-package "NAVIGATION::GOALREQUEST")
  (make-package "NAVIGATION::GOALREQUEST"))
(unless (find-package "NAVIGATION::GOALRESPONSE")
  (make-package "NAVIGATION::GOALRESPONSE"))

(in-package "ROS")





(defclass navigation::GoalRequest
  :super ros::object
  :slots (_px _py _oz ))

(defmethod navigation::GoalRequest
  (:init
   (&key
    ((:px __px) 0.0)
    ((:py __py) 0.0)
    ((:oz __oz) 0.0)
    )
   (send-super :init)
   (setq _px (float __px))
   (setq _py (float __py))
   (setq _oz (float __oz))
   self)
  (:px
   (&optional __px)
   (if __px (setq _px __px)) _px)
  (:py
   (&optional __py)
   (if __py (setq _py __py)) _py)
  (:oz
   (&optional __oz)
   (if __oz (setq _oz __oz)) _oz)
  (:serialization-length
   ()
   (+
    ;; float64 _px
    8
    ;; float64 _py
    8
    ;; float64 _oz
    8
    ))
  (:serialize
   (&optional strm)
   (let ((s (if strm strm
              (make-string-output-stream (send self :serialization-length)))))
     ;; float64 _px
       (sys::poke _px (send s :buffer) (send s :count) :double) (incf (stream-count s) 8)
     ;; float64 _py
       (sys::poke _py (send s :buffer) (send s :count) :double) (incf (stream-count s) 8)
     ;; float64 _oz
       (sys::poke _oz (send s :buffer) (send s :count) :double) (incf (stream-count s) 8)
     ;;
     (if (null strm) (get-output-stream-string s))))
  (:deserialize
   (buf &optional (ptr- 0))
   ;; float64 _px
     (setq _px (sys::peek buf ptr- :double)) (incf ptr- 8)
   ;; float64 _py
     (setq _py (sys::peek buf ptr- :double)) (incf ptr- 8)
   ;; float64 _oz
     (setq _oz (sys::peek buf ptr- :double)) (incf ptr- 8)
   ;;
   self)
  )

(defclass navigation::GoalResponse
  :super ros::object
  :slots (_success _message ))

(defmethod navigation::GoalResponse
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

(defclass navigation::Goal
  :super ros::object
  :slots ())

(setf (get navigation::Goal :md5sum-) "9ef9882ea5e1807374359bbbddadd9f1")
(setf (get navigation::Goal :datatype-) "navigation/Goal")
(setf (get navigation::Goal :request) navigation::GoalRequest)
(setf (get navigation::Goal :response) navigation::GoalResponse)

(defmethod navigation::GoalRequest
  (:response () (instance navigation::GoalResponse :init)))

(setf (get navigation::GoalRequest :md5sum-) "9ef9882ea5e1807374359bbbddadd9f1")
(setf (get navigation::GoalRequest :datatype-) "navigation/GoalRequest")
(setf (get navigation::GoalRequest :definition-)
      "float64 px
float64 py
float64 oz
---
bool success
string message
")

(setf (get navigation::GoalResponse :md5sum-) "9ef9882ea5e1807374359bbbddadd9f1")
(setf (get navigation::GoalResponse :datatype-) "navigation/GoalResponse")
(setf (get navigation::GoalResponse :definition-)
      "float64 px
float64 py
float64 oz
---
bool success
string message
")



(provide :navigation/Goal "9ef9882ea5e1807374359bbbddadd9f1")


