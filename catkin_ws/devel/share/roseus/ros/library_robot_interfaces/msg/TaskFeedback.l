;; Auto-generated. Do not edit!


(when (boundp 'library_robot_interfaces::TaskFeedback)
  (if (not (find-package "LIBRARY_ROBOT_INTERFACES"))
    (make-package "LIBRARY_ROBOT_INTERFACES"))
  (shadow 'TaskFeedback (find-package "LIBRARY_ROBOT_INTERFACES")))
(unless (find-package "LIBRARY_ROBOT_INTERFACES::TASKFEEDBACK")
  (make-package "LIBRARY_ROBOT_INTERFACES::TASKFEEDBACK"))

(in-package "ROS")
;;//! \htmlinclude TaskFeedback.msg.html
(if (not (find-package "STD_MSGS"))
  (ros::roseus-add-msgs "std_msgs"))


(defclass library_robot_interfaces::TaskFeedback
  :super ros::object
  :slots (_header _feedback_action_rails _feedback_payload_json ))

(defmethod library_robot_interfaces::TaskFeedback
  (:init
   (&key
    ((:header __header) (instance std_msgs::Header :init))
    ((:feedback_action_rails __feedback_action_rails) "")
    ((:feedback_payload_json __feedback_payload_json) "")
    )
   (send-super :init)
   (setq _header __header)
   (setq _feedback_action_rails (string __feedback_action_rails))
   (setq _feedback_payload_json (string __feedback_payload_json))
   self)
  (:header
   (&rest __header)
   (if (keywordp (car __header))
       (send* _header __header)
     (progn
       (if __header (setq _header (car __header)))
       _header)))
  (:feedback_action_rails
   (&optional __feedback_action_rails)
   (if __feedback_action_rails (setq _feedback_action_rails __feedback_action_rails)) _feedback_action_rails)
  (:feedback_payload_json
   (&optional __feedback_payload_json)
   (if __feedback_payload_json (setq _feedback_payload_json __feedback_payload_json)) _feedback_payload_json)
  (:serialization-length
   ()
   (+
    ;; std_msgs/Header _header
    (send _header :serialization-length)
    ;; string _feedback_action_rails
    4 (length _feedback_action_rails)
    ;; string _feedback_payload_json
    4 (length _feedback_payload_json)
    ))
  (:serialize
   (&optional strm)
   (let ((s (if strm strm
              (make-string-output-stream (send self :serialization-length)))))
     ;; std_msgs/Header _header
       (send _header :serialize s)
     ;; string _feedback_action_rails
       (write-long (length _feedback_action_rails) s) (princ _feedback_action_rails s)
     ;; string _feedback_payload_json
       (write-long (length _feedback_payload_json) s) (princ _feedback_payload_json s)
     ;;
     (if (null strm) (get-output-stream-string s))))
  (:deserialize
   (buf &optional (ptr- 0))
   ;; std_msgs/Header _header
     (send _header :deserialize buf ptr-) (incf ptr- (send _header :serialization-length))
   ;; string _feedback_action_rails
     (let (n) (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4) (setq _feedback_action_rails (subseq buf ptr- (+ ptr- n))) (incf ptr- n))
   ;; string _feedback_payload_json
     (let (n) (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4) (setq _feedback_payload_json (subseq buf ptr- (+ ptr- n))) (incf ptr- n))
   ;;
   self)
  )

(setf (get library_robot_interfaces::TaskFeedback :md5sum-) "701107acf61196810ba751bfea18045a")
(setf (get library_robot_interfaces::TaskFeedback :datatype-) "library_robot_interfaces/TaskFeedback")
(setf (get library_robot_interfaces::TaskFeedback :definition-)
      "std_msgs/Header header
# string task_id_rails            # 此反馈相关的Rails Task ID (如果适用)
string feedback_action_rails    # 要在Rails RobotFeedbackChannel上调用的方法名
                                # 例如: \"update_task_progress\", \"report_map_preview\", \"report_task_completion\"
string feedback_payload_json    # JSON字符串，作为上述Rails Channel方法的payload
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



(provide :library_robot_interfaces/TaskFeedback "701107acf61196810ba751bfea18045a")


