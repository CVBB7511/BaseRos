;; Auto-generated. Do not edit!


(when (boundp 'warehouse_sorting_msgs::ScanRequest)
  (if (not (find-package "WAREHOUSE_SORTING_MSGS"))
    (make-package "WAREHOUSE_SORTING_MSGS"))
  (shadow 'ScanRequest (find-package "WAREHOUSE_SORTING_MSGS")))
(unless (find-package "WAREHOUSE_SORTING_MSGS::SCANREQUEST")
  (make-package "WAREHOUSE_SORTING_MSGS::SCANREQUEST"))
(unless (find-package "WAREHOUSE_SORTING_MSGS::SCANREQUESTREQUEST")
  (make-package "WAREHOUSE_SORTING_MSGS::SCANREQUESTREQUEST"))
(unless (find-package "WAREHOUSE_SORTING_MSGS::SCANREQUESTRESPONSE")
  (make-package "WAREHOUSE_SORTING_MSGS::SCANREQUESTRESPONSE"))

(in-package "ROS")





(defclass warehouse_sorting_msgs::ScanRequestRequest
  :super ros::object
  :slots (_force ))

(defmethod warehouse_sorting_msgs::ScanRequestRequest
  (:init
   (&key
    ((:force __force) nil)
    )
   (send-super :init)
   (setq _force __force)
   self)
  (:force
   (&optional (__force :null))
   (if (not (eq __force :null)) (setq _force __force)) _force)
  (:serialization-length
   ()
   (+
    ;; bool _force
    1
    ))
  (:serialize
   (&optional strm)
   (let ((s (if strm strm
              (make-string-output-stream (send self :serialization-length)))))
     ;; bool _force
       (if _force (write-byte -1 s) (write-byte 0 s))
     ;;
     (if (null strm) (get-output-stream-string s))))
  (:deserialize
   (buf &optional (ptr- 0))
   ;; bool _force
     (setq _force (not (= 0 (sys::peek buf ptr- :char)))) (incf ptr- 1)
   ;;
   self)
  )

(defclass warehouse_sorting_msgs::ScanRequestResponse
  :super ros::object
  :slots (_success _message _detections ))

(defmethod warehouse_sorting_msgs::ScanRequestResponse
  (:init
   (&key
    ((:success __success) nil)
    ((:message __message) "")
    ((:detections __detections) (instance warehouse_sorting_msgs::DetectedCargoArray :init))
    )
   (send-super :init)
   (setq _success __success)
   (setq _message (string __message))
   (setq _detections __detections)
   self)
  (:success
   (&optional (__success :null))
   (if (not (eq __success :null)) (setq _success __success)) _success)
  (:message
   (&optional __message)
   (if __message (setq _message __message)) _message)
  (:detections
   (&rest __detections)
   (if (keywordp (car __detections))
       (send* _detections __detections)
     (progn
       (if __detections (setq _detections (car __detections)))
       _detections)))
  (:serialization-length
   ()
   (+
    ;; bool _success
    1
    ;; string _message
    4 (length _message)
    ;; warehouse_sorting_msgs/DetectedCargoArray _detections
    (send _detections :serialization-length)
    ))
  (:serialize
   (&optional strm)
   (let ((s (if strm strm
              (make-string-output-stream (send self :serialization-length)))))
     ;; bool _success
       (if _success (write-byte -1 s) (write-byte 0 s))
     ;; string _message
       (write-long (length _message) s) (princ _message s)
     ;; warehouse_sorting_msgs/DetectedCargoArray _detections
       (send _detections :serialize s)
     ;;
     (if (null strm) (get-output-stream-string s))))
  (:deserialize
   (buf &optional (ptr- 0))
   ;; bool _success
     (setq _success (not (= 0 (sys::peek buf ptr- :char)))) (incf ptr- 1)
   ;; string _message
     (let (n) (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4) (setq _message (subseq buf ptr- (+ ptr- n))) (incf ptr- n))
   ;; warehouse_sorting_msgs/DetectedCargoArray _detections
     (send _detections :deserialize buf ptr-) (incf ptr- (send _detections :serialization-length))
   ;;
   self)
  )

(defclass warehouse_sorting_msgs::ScanRequest
  :super ros::object
  :slots ())

(setf (get warehouse_sorting_msgs::ScanRequest :md5sum-) "c6db9a8beb3e4e03e56bddc308994352")
(setf (get warehouse_sorting_msgs::ScanRequest :datatype-) "warehouse_sorting_msgs/ScanRequest")
(setf (get warehouse_sorting_msgs::ScanRequest :request) warehouse_sorting_msgs::ScanRequestRequest)
(setf (get warehouse_sorting_msgs::ScanRequest :response) warehouse_sorting_msgs::ScanRequestResponse)

(defmethod warehouse_sorting_msgs::ScanRequestRequest
  (:response () (instance warehouse_sorting_msgs::ScanRequestResponse :init)))

(setf (get warehouse_sorting_msgs::ScanRequestRequest :md5sum-) "c6db9a8beb3e4e03e56bddc308994352")
(setf (get warehouse_sorting_msgs::ScanRequestRequest :datatype-) "warehouse_sorting_msgs/ScanRequestRequest")
(setf (get warehouse_sorting_msgs::ScanRequestRequest :definition-)
      "bool force
---
bool success
string message
warehouse_sorting_msgs/DetectedCargoArray detections


================================================================================
MSG: warehouse_sorting_msgs/DetectedCargoArray
std_msgs/Header header
warehouse_sorting_msgs/Cargo[] objects

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

================================================================================
MSG: warehouse_sorting_msgs/Cargo
string cargo_id
string cargo_type
geometry_msgs/Pose pose
geometry_msgs/Vector3 size
float32 volume
float32 confidence
int32 bbox_x
int32 bbox_y
int32 bbox_width
int32 bbox_height

================================================================================
MSG: geometry_msgs/Pose
# A representation of pose in free space, composed of position and orientation. 
Point position
Quaternion orientation

================================================================================
MSG: geometry_msgs/Point
# This contains the position of a point in free space
float64 x
float64 y
float64 z

================================================================================
MSG: geometry_msgs/Quaternion
# This represents an orientation in free space in quaternion form.

float64 x
float64 y
float64 z
float64 w

================================================================================
MSG: geometry_msgs/Vector3
# This represents a vector in free space. 
# It is only meant to represent a direction. Therefore, it does not
# make sense to apply a translation to it (e.g., when applying a 
# generic rigid transformation to a Vector3, tf2 will only apply the
# rotation). If you want your data to be translatable too, use the
# geometry_msgs/Point message instead.

float64 x
float64 y
")

(setf (get warehouse_sorting_msgs::ScanRequestResponse :md5sum-) "c6db9a8beb3e4e03e56bddc308994352")
(setf (get warehouse_sorting_msgs::ScanRequestResponse :datatype-) "warehouse_sorting_msgs/ScanRequestResponse")
(setf (get warehouse_sorting_msgs::ScanRequestResponse :definition-)
      "bool force
---
bool success
string message
warehouse_sorting_msgs/DetectedCargoArray detections


================================================================================
MSG: warehouse_sorting_msgs/DetectedCargoArray
std_msgs/Header header
warehouse_sorting_msgs/Cargo[] objects

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

================================================================================
MSG: warehouse_sorting_msgs/Cargo
string cargo_id
string cargo_type
geometry_msgs/Pose pose
geometry_msgs/Vector3 size
float32 volume
float32 confidence
int32 bbox_x
int32 bbox_y
int32 bbox_width
int32 bbox_height

================================================================================
MSG: geometry_msgs/Pose
# A representation of pose in free space, composed of position and orientation. 
Point position
Quaternion orientation

================================================================================
MSG: geometry_msgs/Point
# This contains the position of a point in free space
float64 x
float64 y
float64 z

================================================================================
MSG: geometry_msgs/Quaternion
# This represents an orientation in free space in quaternion form.

float64 x
float64 y
float64 z
float64 w

================================================================================
MSG: geometry_msgs/Vector3
# This represents a vector in free space. 
# It is only meant to represent a direction. Therefore, it does not
# make sense to apply a translation to it (e.g., when applying a 
# generic rigid transformation to a Vector3, tf2 will only apply the
# rotation). If you want your data to be translatable too, use the
# geometry_msgs/Point message instead.

float64 x
float64 y
")



(provide :warehouse_sorting_msgs/ScanRequest "c6db9a8beb3e4e03e56bddc308994352")


