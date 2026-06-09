;; Auto-generated. Do not edit!


(when (boundp 'library_robot_interfaces::TaskDirective)
  (if (not (find-package "LIBRARY_ROBOT_INTERFACES"))
    (make-package "LIBRARY_ROBOT_INTERFACES"))
  (shadow 'TaskDirective (find-package "LIBRARY_ROBOT_INTERFACES")))
(unless (find-package "LIBRARY_ROBOT_INTERFACES::TASKDIRECTIVE")
  (make-package "LIBRARY_ROBOT_INTERFACES::TASKDIRECTIVE"))

(in-package "ROS")
;;//! \htmlinclude TaskDirective.msg.html
(if (not (find-package "STD_MSGS"))
  (ros::roseus-add-msgs "std_msgs"))


(defclass library_robot_interfaces::TaskDirective
  :super ros::object
  :slots (_header _command_type _task_id_rails _task_type_rails _task_priority _parameters_json ))

(defmethod library_robot_interfaces::TaskDirective
  (:init
   (&key
    ((:header __header) (instance std_msgs::Header :init))
    ((:command_type __command_type) "")
    ((:task_id_rails __task_id_rails) "")
    ((:task_type_rails __task_type_rails) "")
    ((:task_priority __task_priority) 0)
    ((:parameters_json __parameters_json) "")
    )
   (send-super :init)
   (setq _header __header)
   (setq _command_type (string __command_type))
   (setq _task_id_rails (string __task_id_rails))
   (setq _task_type_rails (string __task_type_rails))
   (setq _task_priority (round __task_priority))
   (setq _parameters_json (string __parameters_json))
   self)
  (:header
   (&rest __header)
   (if (keywordp (car __header))
       (send* _header __header)
     (progn
       (if __header (setq _header (car __header)))
       _header)))
  (:command_type
   (&optional __command_type)
   (if __command_type (setq _command_type __command_type)) _command_type)
  (:task_id_rails
   (&optional __task_id_rails)
   (if __task_id_rails (setq _task_id_rails __task_id_rails)) _task_id_rails)
  (:task_type_rails
   (&optional __task_type_rails)
   (if __task_type_rails (setq _task_type_rails __task_type_rails)) _task_type_rails)
  (:task_priority
   (&optional __task_priority)
   (if __task_priority (setq _task_priority __task_priority)) _task_priority)
  (:parameters_json
   (&optional __parameters_json)
   (if __parameters_json (setq _parameters_json __parameters_json)) _parameters_json)
  (:serialization-length
   ()
   (+
    ;; std_msgs/Header _header
    (send _header :serialization-length)
    ;; string _command_type
    4 (length _command_type)
    ;; string _task_id_rails
    4 (length _task_id_rails)
    ;; string _task_type_rails
    4 (length _task_type_rails)
    ;; int32 _task_priority
    4
    ;; string _parameters_json
    4 (length _parameters_json)
    ))
  (:serialize
   (&optional strm)
   (let ((s (if strm strm
              (make-string-output-stream (send self :serialization-length)))))
     ;; std_msgs/Header _header
       (send _header :serialize s)
     ;; string _command_type
       (write-long (length _command_type) s) (princ _command_type s)
     ;; string _task_id_rails
       (write-long (length _task_id_rails) s) (princ _task_id_rails s)
     ;; string _task_type_rails
       (write-long (length _task_type_rails) s) (princ _task_type_rails s)
     ;; int32 _task_priority
       (write-long _task_priority s)
     ;; string _parameters_json
       (write-long (length _parameters_json) s) (princ _parameters_json s)
     ;;
     (if (null strm) (get-output-stream-string s))))
  (:deserialize
   (buf &optional (ptr- 0))
   ;; std_msgs/Header _header
     (send _header :deserialize buf ptr-) (incf ptr- (send _header :serialization-length))
   ;; string _command_type
     (let (n) (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4) (setq _command_type (subseq buf ptr- (+ ptr- n))) (incf ptr- n))
   ;; string _task_id_rails
     (let (n) (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4) (setq _task_id_rails (subseq buf ptr- (+ ptr- n))) (incf ptr- n))
   ;; string _task_type_rails
     (let (n) (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4) (setq _task_type_rails (subseq buf ptr- (+ ptr- n))) (incf ptr- n))
   ;; int32 _task_priority
     (setq _task_priority (sys::peek buf ptr- :integer)) (incf ptr- 4)
   ;; string _parameters_json
     (let (n) (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4) (setq _parameters_json (subseq buf ptr- (+ ptr- n))) (incf ptr- n))
   ;;
   self)
  )

(setf (get library_robot_interfaces::TaskDirective :md5sum-) "d22fcfa77d7cca35dedf9ea427a99e6a")
(setf (get library_robot_interfaces::TaskDirective :datatype-) "library_robot_interfaces/TaskDirective")
(setf (get library_robot_interfaces::TaskDirective :definition-)
      "std_msgs/Header header
string command_type          # 例如: \"TASK_EXECUTE\", \"TASK_CANCEL\", \"MOVE\", \"EMERGENCY_STOP\"
string task_id_rails         # Rails Task ID (如果适用，对于即时命令可以为空或特定值)
string task_type_rails       # 例如: \"MAP_BUILD_AUTO\", \"LOAD_MAP\", 或对于即时命令，同command_type
int32 task_priority         # 任务优先级，0表示最低，10表示最高
string parameters_json       # JSON字符串，包含任务或命令所需的参数
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



(provide :library_robot_interfaces/TaskDirective "d22fcfa77d7cca35dedf9ea427a99e6a")


