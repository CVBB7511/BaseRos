;; Auto-generated. Do not edit!


(when (boundp 'palletizing::TriggerDetection)
  (if (not (find-package "PALLETIZING"))
    (make-package "PALLETIZING"))
  (shadow 'TriggerDetection (find-package "PALLETIZING")))
(unless (find-package "PALLETIZING::TRIGGERDETECTION")
  (make-package "PALLETIZING::TRIGGERDETECTION"))
(unless (find-package "PALLETIZING::TRIGGERDETECTIONREQUEST")
  (make-package "PALLETIZING::TRIGGERDETECTIONREQUEST"))
(unless (find-package "PALLETIZING::TRIGGERDETECTIONRESPONSE")
  (make-package "PALLETIZING::TRIGGERDETECTIONRESPONSE"))

(in-package "ROS")



(if (not (find-package "GEOMETRY_MSGS"))
  (ros::roseus-add-msgs "geometry_msgs"))


(defclass palletizing::TriggerDetectionRequest
  :super ros::object
  :slots (_cargo_type ))

(defmethod palletizing::TriggerDetectionRequest
  (:init
   (&key
    ((:cargo_type __cargo_type) "")
    )
   (send-super :init)
   (setq _cargo_type (string __cargo_type))
   self)
  (:cargo_type
   (&optional __cargo_type)
   (if __cargo_type (setq _cargo_type __cargo_type)) _cargo_type)
  (:serialization-length
   ()
   (+
    ;; string _cargo_type
    4 (length _cargo_type)
    ))
  (:serialize
   (&optional strm)
   (let ((s (if strm strm
              (make-string-output-stream (send self :serialization-length)))))
     ;; string _cargo_type
       (write-long (length _cargo_type) s) (princ _cargo_type s)
     ;;
     (if (null strm) (get-output-stream-string s))))
  (:deserialize
   (buf &optional (ptr- 0))
   ;; string _cargo_type
     (let (n) (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4) (setq _cargo_type (subseq buf ptr- (+ ptr- n))) (incf ptr- n))
   ;;
   self)
  )

(defclass palletizing::TriggerDetectionResponse
  :super ros::object
  :slots (_success _message _position _remaining_count ))

(defmethod palletizing::TriggerDetectionResponse
  (:init
   (&key
    ((:success __success) nil)
    ((:message __message) "")
    ((:position __position) (instance geometry_msgs::Point :init))
    ((:remaining_count __remaining_count) 0)
    )
   (send-super :init)
   (setq _success __success)
   (setq _message (string __message))
   (setq _position __position)
   (setq _remaining_count (round __remaining_count))
   self)
  (:success
   (&optional (__success :null))
   (if (not (eq __success :null)) (setq _success __success)) _success)
  (:message
   (&optional __message)
   (if __message (setq _message __message)) _message)
  (:position
   (&rest __position)
   (if (keywordp (car __position))
       (send* _position __position)
     (progn
       (if __position (setq _position (car __position)))
       _position)))
  (:remaining_count
   (&optional __remaining_count)
   (if __remaining_count (setq _remaining_count __remaining_count)) _remaining_count)
  (:serialization-length
   ()
   (+
    ;; bool _success
    1
    ;; string _message
    4 (length _message)
    ;; geometry_msgs/Point _position
    (send _position :serialization-length)
    ;; int32 _remaining_count
    4
    ))
  (:serialize
   (&optional strm)
   (let ((s (if strm strm
              (make-string-output-stream (send self :serialization-length)))))
     ;; bool _success
       (if _success (write-byte -1 s) (write-byte 0 s))
     ;; string _message
       (write-long (length _message) s) (princ _message s)
     ;; geometry_msgs/Point _position
       (send _position :serialize s)
     ;; int32 _remaining_count
       (write-long _remaining_count s)
     ;;
     (if (null strm) (get-output-stream-string s))))
  (:deserialize
   (buf &optional (ptr- 0))
   ;; bool _success
     (setq _success (not (= 0 (sys::peek buf ptr- :char)))) (incf ptr- 1)
   ;; string _message
     (let (n) (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4) (setq _message (subseq buf ptr- (+ ptr- n))) (incf ptr- n))
   ;; geometry_msgs/Point _position
     (send _position :deserialize buf ptr-) (incf ptr- (send _position :serialization-length))
   ;; int32 _remaining_count
     (setq _remaining_count (sys::peek buf ptr- :integer)) (incf ptr- 4)
   ;;
   self)
  )

(defclass palletizing::TriggerDetection
  :super ros::object
  :slots ())

(setf (get palletizing::TriggerDetection :md5sum-) "36866cc854ee48ffadf2fd965e06457e")
(setf (get palletizing::TriggerDetection :datatype-) "palletizing/TriggerDetection")
(setf (get palletizing::TriggerDetection :request) palletizing::TriggerDetectionRequest)
(setf (get palletizing::TriggerDetection :response) palletizing::TriggerDetectionResponse)

(defmethod palletizing::TriggerDetectionRequest
  (:response () (instance palletizing::TriggerDetectionResponse :init)))

(setf (get palletizing::TriggerDetectionRequest :md5sum-) "36866cc854ee48ffadf2fd965e06457e")
(setf (get palletizing::TriggerDetectionRequest :datatype-) "palletizing/TriggerDetectionRequest")
(setf (get palletizing::TriggerDetectionRequest :definition-)
      "# 触发单次视觉识别服务
# 请求：货物类型
string cargo_type
---
# 响应：是否成功、目标在 base_link 坐标系下的三维坐标
bool success
string message
geometry_msgs/Point position
int32 remaining_count


================================================================================
MSG: geometry_msgs/Point
# This contains the position of a point in free space
float64 x
float64 y
float64 z
")

(setf (get palletizing::TriggerDetectionResponse :md5sum-) "36866cc854ee48ffadf2fd965e06457e")
(setf (get palletizing::TriggerDetectionResponse :datatype-) "palletizing/TriggerDetectionResponse")
(setf (get palletizing::TriggerDetectionResponse :definition-)
      "# 触发单次视觉识别服务
# 请求：货物类型
string cargo_type
---
# 响应：是否成功、目标在 base_link 坐标系下的三维坐标
bool success
string message
geometry_msgs/Point position
int32 remaining_count


================================================================================
MSG: geometry_msgs/Point
# This contains the position of a point in free space
float64 x
float64 y
float64 z
")



(provide :palletizing/TriggerDetection "36866cc854ee48ffadf2fd965e06457e")


