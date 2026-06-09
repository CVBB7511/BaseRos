;; Auto-generated. Do not edit!


(when (boundp 'library_robot_interfaces::RobotStatusCompressed)
  (if (not (find-package "LIBRARY_ROBOT_INTERFACES"))
    (make-package "LIBRARY_ROBOT_INTERFACES"))
  (shadow 'RobotStatusCompressed (find-package "LIBRARY_ROBOT_INTERFACES")))
(unless (find-package "LIBRARY_ROBOT_INTERFACES::ROBOTSTATUSCOMPRESSED")
  (make-package "LIBRARY_ROBOT_INTERFACES::ROBOTSTATUSCOMPRESSED"))

(in-package "ROS")
;;//! \htmlinclude RobotStatusCompressed.msg.html
(if (not (find-package "STD_MSGS"))
  (ros::roseus-add-msgs "std_msgs"))


(defclass library_robot_interfaces::RobotStatusCompressed
  :super ros::object
  :slots (_header _pose_x _pose_y _pose_theta _velocity_linear _velocity_angular _battery_percentage _robot_state_str _error_message _is_emergency_stopped _active_task_id_rails _active_map ))

(defmethod library_robot_interfaces::RobotStatusCompressed
  (:init
   (&key
    ((:header __header) (instance std_msgs::Header :init))
    ((:pose_x __pose_x) 0.0)
    ((:pose_y __pose_y) 0.0)
    ((:pose_theta __pose_theta) 0.0)
    ((:velocity_linear __velocity_linear) 0.0)
    ((:velocity_angular __velocity_angular) 0.0)
    ((:battery_percentage __battery_percentage) 0.0)
    ((:robot_state_str __robot_state_str) "")
    ((:error_message __error_message) "")
    ((:is_emergency_stopped __is_emergency_stopped) nil)
    ((:active_task_id_rails __active_task_id_rails) 0)
    ((:active_map __active_map) 0)
    )
   (send-super :init)
   (setq _header __header)
   (setq _pose_x (float __pose_x))
   (setq _pose_y (float __pose_y))
   (setq _pose_theta (float __pose_theta))
   (setq _velocity_linear (float __velocity_linear))
   (setq _velocity_angular (float __velocity_angular))
   (setq _battery_percentage (float __battery_percentage))
   (setq _robot_state_str (string __robot_state_str))
   (setq _error_message (string __error_message))
   (setq _is_emergency_stopped __is_emergency_stopped)
   (setq _active_task_id_rails (round __active_task_id_rails))
   (setq _active_map (round __active_map))
   self)
  (:header
   (&rest __header)
   (if (keywordp (car __header))
       (send* _header __header)
     (progn
       (if __header (setq _header (car __header)))
       _header)))
  (:pose_x
   (&optional __pose_x)
   (if __pose_x (setq _pose_x __pose_x)) _pose_x)
  (:pose_y
   (&optional __pose_y)
   (if __pose_y (setq _pose_y __pose_y)) _pose_y)
  (:pose_theta
   (&optional __pose_theta)
   (if __pose_theta (setq _pose_theta __pose_theta)) _pose_theta)
  (:velocity_linear
   (&optional __velocity_linear)
   (if __velocity_linear (setq _velocity_linear __velocity_linear)) _velocity_linear)
  (:velocity_angular
   (&optional __velocity_angular)
   (if __velocity_angular (setq _velocity_angular __velocity_angular)) _velocity_angular)
  (:battery_percentage
   (&optional __battery_percentage)
   (if __battery_percentage (setq _battery_percentage __battery_percentage)) _battery_percentage)
  (:robot_state_str
   (&optional __robot_state_str)
   (if __robot_state_str (setq _robot_state_str __robot_state_str)) _robot_state_str)
  (:error_message
   (&optional __error_message)
   (if __error_message (setq _error_message __error_message)) _error_message)
  (:is_emergency_stopped
   (&optional (__is_emergency_stopped :null))
   (if (not (eq __is_emergency_stopped :null)) (setq _is_emergency_stopped __is_emergency_stopped)) _is_emergency_stopped)
  (:active_task_id_rails
   (&optional __active_task_id_rails)
   (if __active_task_id_rails (setq _active_task_id_rails __active_task_id_rails)) _active_task_id_rails)
  (:active_map
   (&optional __active_map)
   (if __active_map (setq _active_map __active_map)) _active_map)
  (:serialization-length
   ()
   (+
    ;; std_msgs/Header _header
    (send _header :serialization-length)
    ;; float32 _pose_x
    4
    ;; float32 _pose_y
    4
    ;; float32 _pose_theta
    4
    ;; float32 _velocity_linear
    4
    ;; float32 _velocity_angular
    4
    ;; float32 _battery_percentage
    4
    ;; string _robot_state_str
    4 (length _robot_state_str)
    ;; string _error_message
    4 (length _error_message)
    ;; bool _is_emergency_stopped
    1
    ;; int32 _active_task_id_rails
    4
    ;; int32 _active_map
    4
    ))
  (:serialize
   (&optional strm)
   (let ((s (if strm strm
              (make-string-output-stream (send self :serialization-length)))))
     ;; std_msgs/Header _header
       (send _header :serialize s)
     ;; float32 _pose_x
       (sys::poke _pose_x (send s :buffer) (send s :count) :float) (incf (stream-count s) 4)
     ;; float32 _pose_y
       (sys::poke _pose_y (send s :buffer) (send s :count) :float) (incf (stream-count s) 4)
     ;; float32 _pose_theta
       (sys::poke _pose_theta (send s :buffer) (send s :count) :float) (incf (stream-count s) 4)
     ;; float32 _velocity_linear
       (sys::poke _velocity_linear (send s :buffer) (send s :count) :float) (incf (stream-count s) 4)
     ;; float32 _velocity_angular
       (sys::poke _velocity_angular (send s :buffer) (send s :count) :float) (incf (stream-count s) 4)
     ;; float32 _battery_percentage
       (sys::poke _battery_percentage (send s :buffer) (send s :count) :float) (incf (stream-count s) 4)
     ;; string _robot_state_str
       (write-long (length _robot_state_str) s) (princ _robot_state_str s)
     ;; string _error_message
       (write-long (length _error_message) s) (princ _error_message s)
     ;; bool _is_emergency_stopped
       (if _is_emergency_stopped (write-byte -1 s) (write-byte 0 s))
     ;; int32 _active_task_id_rails
       (write-long _active_task_id_rails s)
     ;; int32 _active_map
       (write-long _active_map s)
     ;;
     (if (null strm) (get-output-stream-string s))))
  (:deserialize
   (buf &optional (ptr- 0))
   ;; std_msgs/Header _header
     (send _header :deserialize buf ptr-) (incf ptr- (send _header :serialization-length))
   ;; float32 _pose_x
     (setq _pose_x (sys::peek buf ptr- :float)) (incf ptr- 4)
   ;; float32 _pose_y
     (setq _pose_y (sys::peek buf ptr- :float)) (incf ptr- 4)
   ;; float32 _pose_theta
     (setq _pose_theta (sys::peek buf ptr- :float)) (incf ptr- 4)
   ;; float32 _velocity_linear
     (setq _velocity_linear (sys::peek buf ptr- :float)) (incf ptr- 4)
   ;; float32 _velocity_angular
     (setq _velocity_angular (sys::peek buf ptr- :float)) (incf ptr- 4)
   ;; float32 _battery_percentage
     (setq _battery_percentage (sys::peek buf ptr- :float)) (incf ptr- 4)
   ;; string _robot_state_str
     (let (n) (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4) (setq _robot_state_str (subseq buf ptr- (+ ptr- n))) (incf ptr- n))
   ;; string _error_message
     (let (n) (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4) (setq _error_message (subseq buf ptr- (+ ptr- n))) (incf ptr- n))
   ;; bool _is_emergency_stopped
     (setq _is_emergency_stopped (not (= 0 (sys::peek buf ptr- :char)))) (incf ptr- 1)
   ;; int32 _active_task_id_rails
     (setq _active_task_id_rails (sys::peek buf ptr- :integer)) (incf ptr- 4)
   ;; int32 _active_map
     (setq _active_map (sys::peek buf ptr- :integer)) (incf ptr- 4)
   ;;
   self)
  )

(setf (get library_robot_interfaces::RobotStatusCompressed :md5sum-) "6fbfcb9ff0fd4a4ddc6e1fcb05506c41")
(setf (get library_robot_interfaces::RobotStatusCompressed :datatype-) "library_robot_interfaces/RobotStatusCompressed")
(setf (get library_robot_interfaces::RobotStatusCompressed :definition-)
      "std_msgs/Header header
float32 pose_x
float32 pose_y
float32 pose_theta
float32 velocity_linear
float32 velocity_angular
float32 battery_percentage  # 0.0 到 100.0
string robot_state_str      # TaskManager维护的机器人状态字符串, e.g., \"idle\", \"mapping\", \"error_localization_lost\"
string error_message        # 当前错误信息 (如果有)
bool is_emergency_stopped
int32 active_task_id_rails # 当前正在执行的Rails Task ID (0 如果没有)
int32 active_map      # ROS中当前加载的地图的ID (0 如果没有)
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



(provide :library_robot_interfaces/RobotStatusCompressed "6fbfcb9ff0fd4a4ddc6e1fcb05506c41")


