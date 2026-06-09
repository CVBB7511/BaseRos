;; Auto-generated. Do not edit!


(when (boundp 'library_robot_interfaces::CameraFrameData)
  (if (not (find-package "LIBRARY_ROBOT_INTERFACES"))
    (make-package "LIBRARY_ROBOT_INTERFACES"))
  (shadow 'CameraFrameData (find-package "LIBRARY_ROBOT_INTERFACES")))
(unless (find-package "LIBRARY_ROBOT_INTERFACES::CAMERAFRAMEDATA")
  (make-package "LIBRARY_ROBOT_INTERFACES::CAMERAFRAMEDATA"))

(in-package "ROS")
;;//! \htmlinclude CameraFrameData.msg.html
(if (not (find-package "STD_MSGS"))
  (ros::roseus-add-msgs "std_msgs"))


(defclass library_robot_interfaces::CameraFrameData
  :super ros::object
  :slots (_header _frame_id _format _width _height _data_base64 _data_size ))

(defmethod library_robot_interfaces::CameraFrameData
  (:init
   (&key
    ((:header __header) (instance std_msgs::Header :init))
    ((:frame_id __frame_id) 0)
    ((:format __format) "")
    ((:width __width) 0)
    ((:height __height) 0)
    ((:data_base64 __data_base64) "")
    ((:data_size __data_size) 0)
    )
   (send-super :init)
   (setq _header __header)
   (setq _frame_id (round __frame_id))
   (setq _format (string __format))
   (setq _width (round __width))
   (setq _height (round __height))
   (setq _data_base64 (string __data_base64))
   (setq _data_size (round __data_size))
   self)
  (:header
   (&rest __header)
   (if (keywordp (car __header))
       (send* _header __header)
     (progn
       (if __header (setq _header (car __header)))
       _header)))
  (:frame_id
   (&optional __frame_id)
   (if __frame_id (setq _frame_id __frame_id)) _frame_id)
  (:format
   (&optional __format)
   (if __format (setq _format __format)) _format)
  (:width
   (&optional __width)
   (if __width (setq _width __width)) _width)
  (:height
   (&optional __height)
   (if __height (setq _height __height)) _height)
  (:data_base64
   (&optional __data_base64)
   (if __data_base64 (setq _data_base64 __data_base64)) _data_base64)
  (:data_size
   (&optional __data_size)
   (if __data_size (setq _data_size __data_size)) _data_size)
  (:serialization-length
   ()
   (+
    ;; std_msgs/Header _header
    (send _header :serialization-length)
    ;; int32 _frame_id
    4
    ;; string _format
    4 (length _format)
    ;; int32 _width
    4
    ;; int32 _height
    4
    ;; string _data_base64
    4 (length _data_base64)
    ;; int32 _data_size
    4
    ))
  (:serialize
   (&optional strm)
   (let ((s (if strm strm
              (make-string-output-stream (send self :serialization-length)))))
     ;; std_msgs/Header _header
       (send _header :serialize s)
     ;; int32 _frame_id
       (write-long _frame_id s)
     ;; string _format
       (write-long (length _format) s) (princ _format s)
     ;; int32 _width
       (write-long _width s)
     ;; int32 _height
       (write-long _height s)
     ;; string _data_base64
       (write-long (length _data_base64) s) (princ _data_base64 s)
     ;; int32 _data_size
       (write-long _data_size s)
     ;;
     (if (null strm) (get-output-stream-string s))))
  (:deserialize
   (buf &optional (ptr- 0))
   ;; std_msgs/Header _header
     (send _header :deserialize buf ptr-) (incf ptr- (send _header :serialization-length))
   ;; int32 _frame_id
     (setq _frame_id (sys::peek buf ptr- :integer)) (incf ptr- 4)
   ;; string _format
     (let (n) (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4) (setq _format (subseq buf ptr- (+ ptr- n))) (incf ptr- n))
   ;; int32 _width
     (setq _width (sys::peek buf ptr- :integer)) (incf ptr- 4)
   ;; int32 _height
     (setq _height (sys::peek buf ptr- :integer)) (incf ptr- 4)
   ;; string _data_base64
     (let (n) (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4) (setq _data_base64 (subseq buf ptr- (+ ptr- n))) (incf ptr- n))
   ;; int32 _data_size
     (setq _data_size (sys::peek buf ptr- :integer)) (incf ptr- 4)
   ;;
   self)
  )

(setf (get library_robot_interfaces::CameraFrameData :md5sum-) "21126ab408dfc26931ec388ac082dc56")
(setf (get library_robot_interfaces::CameraFrameData :datatype-) "library_robot_interfaces/CameraFrameData")
(setf (get library_robot_interfaces::CameraFrameData :definition-)
      "std_msgs/Header header
int32 frame_id
string format          # e.g., \"jpeg\", \"png\"
int32 width
int32 height
string data_base64     # Base64编码的图像数据
int32 data_size        # 原始数据大小（字节） 
================================================================================
MSG: std_msgs/Header
# Standard metadata for higher-level stamped data types.
# This is generally used to communicate timestamped data 
# in a particular coordinate frame.
# 
# sequence ID: consecutively increasing ID 
uint32 seq
#Two-integer timestamp that is expressed as:
# * stamp.sec: seconds (stamp_secs) since epoch (in Python the variable is called 'secs')
# * stamp.nsec: nanoseconds since stamp_secs (in Python the variable is called 'nsecs')
# time-handling sugar is provided by the client library
time stamp
#Frame this data is associated with
string frame_id

")



(provide :library_robot_interfaces/CameraFrameData "21126ab408dfc26931ec388ac082dc56")


