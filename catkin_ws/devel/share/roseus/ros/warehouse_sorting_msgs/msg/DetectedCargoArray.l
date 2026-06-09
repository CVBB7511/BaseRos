;; Auto-generated. Do not edit!


(when (boundp 'warehouse_sorting_msgs::DetectedCargoArray)
  (if (not (find-package "WAREHOUSE_SORTING_MSGS"))
    (make-package "WAREHOUSE_SORTING_MSGS"))
  (shadow 'DetectedCargoArray (find-package "WAREHOUSE_SORTING_MSGS")))
(unless (find-package "WAREHOUSE_SORTING_MSGS::DETECTEDCARGOARRAY")
  (make-package "WAREHOUSE_SORTING_MSGS::DETECTEDCARGOARRAY"))

(in-package "ROS")
;;//! \htmlinclude DetectedCargoArray.msg.html
(if (not (find-package "STD_MSGS"))
  (ros::roseus-add-msgs "std_msgs"))


(defclass warehouse_sorting_msgs::DetectedCargoArray
  :super ros::object
  :slots (_header _objects ))

(defmethod warehouse_sorting_msgs::DetectedCargoArray
  (:init
   (&key
    ((:header __header) (instance std_msgs::Header :init))
    ((:objects __objects) ())
    )
   (send-super :init)
   (setq _header __header)
   (setq _objects __objects)
   self)
  (:header
   (&rest __header)
   (if (keywordp (car __header))
       (send* _header __header)
     (progn
       (if __header (setq _header (car __header)))
       _header)))
  (:objects
   (&rest __objects)
   (if (keywordp (car __objects))
       (send* _objects __objects)
     (progn
       (if __objects (setq _objects (car __objects)))
       _objects)))
  (:serialization-length
   ()
   (+
    ;; std_msgs/Header _header
    (send _header :serialization-length)
    ;; warehouse_sorting_msgs/Cargo[] _objects
    (apply #'+ (send-all _objects :serialization-length)) 4
    ))
  (:serialize
   (&optional strm)
   (let ((s (if strm strm
              (make-string-output-stream (send self :serialization-length)))))
     ;; std_msgs/Header _header
       (send _header :serialize s)
     ;; warehouse_sorting_msgs/Cargo[] _objects
     (write-long (length _objects) s)
     (dolist (elem _objects)
       (send elem :serialize s)
       )
     ;;
     (if (null strm) (get-output-stream-string s))))
  (:deserialize
   (buf &optional (ptr- 0))
   ;; std_msgs/Header _header
     (send _header :deserialize buf ptr-) (incf ptr- (send _header :serialization-length))
   ;; warehouse_sorting_msgs/Cargo[] _objects
   (let (n)
     (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4)
     (setq _objects (let (r) (dotimes (i n) (push (instance warehouse_sorting_msgs::Cargo :init) r)) r))
     (dolist (elem- _objects)
     (send elem- :deserialize buf ptr-) (incf ptr- (send elem- :serialization-length))
     ))
   ;;
   self)
  )

(setf (get warehouse_sorting_msgs::DetectedCargoArray :md5sum-) "753fda52a894cc2e000a484354dd94f2")
(setf (get warehouse_sorting_msgs::DetectedCargoArray :datatype-) "warehouse_sorting_msgs/DetectedCargoArray")
(setf (get warehouse_sorting_msgs::DetectedCargoArray :definition-)
      "std_msgs/Header header
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
float64 z
")



(provide :warehouse_sorting_msgs/DetectedCargoArray "753fda52a894cc2e000a484354dd94f2")


