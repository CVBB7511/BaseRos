;; Auto-generated. Do not edit!


(when (boundp 'warehouse_sorting_msgs::ArmCommand)
  (if (not (find-package "WAREHOUSE_SORTING_MSGS"))
    (make-package "WAREHOUSE_SORTING_MSGS"))
  (shadow 'ArmCommand (find-package "WAREHOUSE_SORTING_MSGS")))
(unless (find-package "WAREHOUSE_SORTING_MSGS::ARMCOMMAND")
  (make-package "WAREHOUSE_SORTING_MSGS::ARMCOMMAND"))
(unless (find-package "WAREHOUSE_SORTING_MSGS::ARMCOMMANDREQUEST")
  (make-package "WAREHOUSE_SORTING_MSGS::ARMCOMMANDREQUEST"))
(unless (find-package "WAREHOUSE_SORTING_MSGS::ARMCOMMANDRESPONSE")
  (make-package "WAREHOUSE_SORTING_MSGS::ARMCOMMANDRESPONSE"))

(in-package "ROS")

(if (not (find-package "GEOMETRY_MSGS"))
  (ros::roseus-add-msgs "geometry_msgs"))




(defclass warehouse_sorting_msgs::ArmCommandRequest
  :super ros::object
  :slots (_cargo _target_pose _action ))

(defmethod warehouse_sorting_msgs::ArmCommandRequest
  (:init
   (&key
    ((:cargo __cargo) (instance warehouse_sorting_msgs::Cargo :init))
    ((:target_pose __target_pose) (instance geometry_msgs::Pose :init))
    ((:action __action) "")
    )
   (send-super :init)
   (setq _cargo __cargo)
   (setq _target_pose __target_pose)
   (setq _action (string __action))
   self)
  (:cargo
   (&rest __cargo)
   (if (keywordp (car __cargo))
       (send* _cargo __cargo)
     (progn
       (if __cargo (setq _cargo (car __cargo)))
       _cargo)))
  (:target_pose
   (&rest __target_pose)
   (if (keywordp (car __target_pose))
       (send* _target_pose __target_pose)
     (progn
       (if __target_pose (setq _target_pose (car __target_pose)))
       _target_pose)))
  (:action
   (&optional __action)
   (if __action (setq _action __action)) _action)
  (:serialization-length
   ()
   (+
    ;; warehouse_sorting_msgs/Cargo _cargo
    (send _cargo :serialization-length)
    ;; geometry_msgs/Pose _target_pose
    (send _target_pose :serialization-length)
    ;; string _action
    4 (length _action)
    ))
  (:serialize
   (&optional strm)
   (let ((s (if strm strm
              (make-string-output-stream (send self :serialization-length)))))
     ;; warehouse_sorting_msgs/Cargo _cargo
       (send _cargo :serialize s)
     ;; geometry_msgs/Pose _target_pose
       (send _target_pose :serialize s)
     ;; string _action
       (write-long (length _action) s) (princ _action s)
     ;;
     (if (null strm) (get-output-stream-string s))))
  (:deserialize
   (buf &optional (ptr- 0))
   ;; warehouse_sorting_msgs/Cargo _cargo
     (send _cargo :deserialize buf ptr-) (incf ptr- (send _cargo :serialization-length))
   ;; geometry_msgs/Pose _target_pose
     (send _target_pose :deserialize buf ptr-) (incf ptr- (send _target_pose :serialization-length))
   ;; string _action
     (let (n) (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4) (setq _action (subseq buf ptr- (+ ptr- n))) (incf ptr- n))
   ;;
   self)
  )

(defclass warehouse_sorting_msgs::ArmCommandResponse
  :super ros::object
  :slots (_success _message ))

(defmethod warehouse_sorting_msgs::ArmCommandResponse
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

(defclass warehouse_sorting_msgs::ArmCommand
  :super ros::object
  :slots ())

(setf (get warehouse_sorting_msgs::ArmCommand :md5sum-) "3846e631ba5aa8597f045fd2ffbc2e9a")
(setf (get warehouse_sorting_msgs::ArmCommand :datatype-) "warehouse_sorting_msgs/ArmCommand")
(setf (get warehouse_sorting_msgs::ArmCommand :request) warehouse_sorting_msgs::ArmCommandRequest)
(setf (get warehouse_sorting_msgs::ArmCommand :response) warehouse_sorting_msgs::ArmCommandResponse)

(defmethod warehouse_sorting_msgs::ArmCommandRequest
  (:response () (instance warehouse_sorting_msgs::ArmCommandResponse :init)))

(setf (get warehouse_sorting_msgs::ArmCommandRequest :md5sum-) "3846e631ba5aa8597f045fd2ffbc2e9a")
(setf (get warehouse_sorting_msgs::ArmCommandRequest :datatype-) "warehouse_sorting_msgs/ArmCommandRequest")
(setf (get warehouse_sorting_msgs::ArmCommandRequest :definition-)
      "warehouse_sorting_msgs/Cargo cargo
geometry_msgs/Pose target_pose
string action

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
---
bool success
string message

")

(setf (get warehouse_sorting_msgs::ArmCommandResponse :md5sum-) "3846e631ba5aa8597f045fd2ffbc2e9a")
(setf (get warehouse_sorting_msgs::ArmCommandResponse :datatype-) "warehouse_sorting_msgs/ArmCommandResponse")
(setf (get warehouse_sorting_msgs::ArmCommandResponse :definition-)
      "warehouse_sorting_msgs/Cargo cargo
geometry_msgs/Pose target_pose
string action

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
---
bool success
string message

")



(provide :warehouse_sorting_msgs/ArmCommand "3846e631ba5aa8597f045fd2ffbc2e9a")


