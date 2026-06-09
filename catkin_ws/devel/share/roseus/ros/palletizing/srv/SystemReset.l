;; Auto-generated. Do not edit!


(when (boundp 'palletizing::SystemReset)
  (if (not (find-package "PALLETIZING"))
    (make-package "PALLETIZING"))
  (shadow 'SystemReset (find-package "PALLETIZING")))
(unless (find-package "PALLETIZING::SYSTEMRESET")
  (make-package "PALLETIZING::SYSTEMRESET"))
(unless (find-package "PALLETIZING::SYSTEMRESETREQUEST")
  (make-package "PALLETIZING::SYSTEMRESETREQUEST"))
(unless (find-package "PALLETIZING::SYSTEMRESETRESPONSE")
  (make-package "PALLETIZING::SYSTEMRESETRESPONSE"))

(in-package "ROS")





(defclass palletizing::SystemResetRequest
  :super ros::object
  :slots ())

(defmethod palletizing::SystemResetRequest
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

(defclass palletizing::SystemResetResponse
  :super ros::object
  :slots (_success _message ))

(defmethod palletizing::SystemResetResponse
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

(defclass palletizing::SystemReset
  :super ros::object
  :slots ())

(setf (get palletizing::SystemReset :md5sum-) "937c9679a518e3a18d831e57125ea522")
(setf (get palletizing::SystemReset :datatype-) "palletizing/SystemReset")
(setf (get palletizing::SystemReset :request) palletizing::SystemResetRequest)
(setf (get palletizing::SystemReset :response) palletizing::SystemResetResponse)

(defmethod palletizing::SystemResetRequest
  (:response () (instance palletizing::SystemResetResponse :init)))

(setf (get palletizing::SystemResetRequest :md5sum-) "937c9679a518e3a18d831e57125ea522")
(setf (get palletizing::SystemResetRequest :datatype-) "palletizing/SystemResetRequest")
(setf (get palletizing::SystemResetRequest :definition-)
      "# 系统复位服务
# 请求：无
---
# 响应：是否成功
bool success
string message

")

(setf (get palletizing::SystemResetResponse :md5sum-) "937c9679a518e3a18d831e57125ea522")
(setf (get palletizing::SystemResetResponse :datatype-) "palletizing/SystemResetResponse")
(setf (get palletizing::SystemResetResponse :definition-)
      "# 系统复位服务
# 请求：无
---
# 响应：是否成功
bool success
string message

")



(provide :palletizing/SystemReset "937c9679a518e3a18d831e57125ea522")


