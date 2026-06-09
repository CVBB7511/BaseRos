;; Auto-generated. Do not edit!


(when (boundp 'warehouse_sorting_msgs::Cargo)
  (if (not (find-package "WAREHOUSE_SORTING_MSGS"))
    (make-package "WAREHOUSE_SORTING_MSGS"))
  (shadow 'Cargo (find-package "WAREHOUSE_SORTING_MSGS")))
(unless (find-package "WAREHOUSE_SORTING_MSGS::CARGO")
  (make-package "WAREHOUSE_SORTING_MSGS::CARGO"))

(in-package "ROS")
;;//! \htmlinclude Cargo.msg.html
(if (not (find-package "GEOMETRY_MSGS"))
  (ros::roseus-add-msgs "geometry_msgs"))


(defclass warehouse_sorting_msgs::Cargo
  :super ros::object
  :slots (_cargo_id _cargo_type _pose _size _volume _confidence _bbox_x _bbox_y _bbox_width _bbox_height ))

(defmethod warehouse_sorting_msgs::Cargo
  (:init
   (&key
    ((:cargo_id __cargo_id) "")
    ((:cargo_type __cargo_type) "")
    ((:pose __pose) (instance geometry_msgs::Pose :init))
    ((:size __size) (instance geometry_msgs::Vector3 :init))
    ((:volume __volume) 0.0)
    ((:confidence __confidence) 0.0)
    ((:bbox_x __bbox_x) 0)
    ((:bbox_y __bbox_y) 0)
    ((:bbox_width __bbox_width) 0)
    ((:bbox_height __bbox_height) 0)
    )
   (send-super :init)
   (setq _cargo_id (string __cargo_id))
   (setq _cargo_type (string __cargo_type))
   (setq _pose __pose)
   (setq _size __size)
   (setq _volume (float __volume))
   (setq _confidence (float __confidence))
   (setq _bbox_x (round __bbox_x))
   (setq _bbox_y (round __bbox_y))
   (setq _bbox_width (round __bbox_width))
   (setq _bbox_height (round __bbox_height))
   self)
  (:cargo_id
   (&optional __cargo_id)
   (if __cargo_id (setq _cargo_id __cargo_id)) _cargo_id)
  (:cargo_type
   (&optional __cargo_type)
   (if __cargo_type (setq _cargo_type __cargo_type)) _cargo_type)
  (:pose
   (&rest __pose)
   (if (keywordp (car __pose))
       (send* _pose __pose)
     (progn
       (if __pose (setq _pose (car __pose)))
       _pose)))
  (:size
   (&rest __size)
   (if (keywordp (car __size))
       (send* _size __size)
     (progn
       (if __size (setq _size (car __size)))
       _size)))
  (:volume
   (&optional __volume)
   (if __volume (setq _volume __volume)) _volume)
  (:confidence
   (&optional __confidence)
   (if __confidence (setq _confidence __confidence)) _confidence)
  (:bbox_x
   (&optional __bbox_x)
   (if __bbox_x (setq _bbox_x __bbox_x)) _bbox_x)
  (:bbox_y
   (&optional __bbox_y)
   (if __bbox_y (setq _bbox_y __bbox_y)) _bbox_y)
  (:bbox_width
   (&optional __bbox_width)
   (if __bbox_width (setq _bbox_width __bbox_width)) _bbox_width)
  (:bbox_height
   (&optional __bbox_height)
   (if __bbox_height (setq _bbox_height __bbox_height)) _bbox_height)
  (:serialization-length
   ()
   (+
    ;; string _cargo_id
    4 (length _cargo_id)
    ;; string _cargo_type
    4 (length _cargo_type)
    ;; geometry_msgs/Pose _pose
    (send _pose :serialization-length)
    ;; geometry_msgs/Vector3 _size
    (send _size :serialization-length)
    ;; float32 _volume
    4
    ;; float32 _confidence
    4
    ;; int32 _bbox_x
    4
    ;; int32 _bbox_y
    4
    ;; int32 _bbox_width
    4
    ;; int32 _bbox_height
    4
    ))
  (:serialize
   (&optional strm)
   (let ((s (if strm strm
              (make-string-output-stream (send self :serialization-length)))))
     ;; string _cargo_id
       (write-long (length _cargo_id) s) (princ _cargo_id s)
     ;; string _cargo_type
       (write-long (length _cargo_type) s) (princ _cargo_type s)
     ;; geometry_msgs/Pose _pose
       (send _pose :serialize s)
     ;; geometry_msgs/Vector3 _size
       (send _size :serialize s)
     ;; float32 _volume
       (sys::poke _volume (send s :buffer) (send s :count) :float) (incf (stream-count s) 4)
     ;; float32 _confidence
       (sys::poke _confidence (send s :buffer) (send s :count) :float) (incf (stream-count s) 4)
     ;; int32 _bbox_x
       (write-long _bbox_x s)
     ;; int32 _bbox_y
       (write-long _bbox_y s)
     ;; int32 _bbox_width
       (write-long _bbox_width s)
     ;; int32 _bbox_height
       (write-long _bbox_height s)
     ;;
     (if (null strm) (get-output-stream-string s))))
  (:deserialize
   (buf &optional (ptr- 0))
   ;; string _cargo_id
     (let (n) (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4) (setq _cargo_id (subseq buf ptr- (+ ptr- n))) (incf ptr- n))
   ;; string _cargo_type
     (let (n) (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4) (setq _cargo_type (subseq buf ptr- (+ ptr- n))) (incf ptr- n))
   ;; geometry_msgs/Pose _pose
     (send _pose :deserialize buf ptr-) (incf ptr- (send _pose :serialization-length))
   ;; geometry_msgs/Vector3 _size
     (send _size :deserialize buf ptr-) (incf ptr- (send _size :serialization-length))
   ;; float32 _volume
     (setq _volume (sys::peek buf ptr- :float)) (incf ptr- 4)
   ;; float32 _confidence
     (setq _confidence (sys::peek buf ptr- :float)) (incf ptr- 4)
   ;; int32 _bbox_x
     (setq _bbox_x (sys::peek buf ptr- :integer)) (incf ptr- 4)
   ;; int32 _bbox_y
     (setq _bbox_y (sys::peek buf ptr- :integer)) (incf ptr- 4)
   ;; int32 _bbox_width
     (setq _bbox_width (sys::peek buf ptr- :integer)) (incf ptr- 4)
   ;; int32 _bbox_height
     (setq _bbox_height (sys::peek buf ptr- :integer)) (incf ptr- 4)
   ;;
   self)
  )

(setf (get warehouse_sorting_msgs::Cargo :md5sum-) "f165e9d8fad2d5fab3540432824f5105")
(setf (get warehouse_sorting_msgs::Cargo :datatype-) "warehouse_sorting_msgs/Cargo")
(setf (get warehouse_sorting_msgs::Cargo :definition-)
      "string cargo_id
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



(provide :warehouse_sorting_msgs/Cargo "f165e9d8fad2d5fab3540432824f5105")


