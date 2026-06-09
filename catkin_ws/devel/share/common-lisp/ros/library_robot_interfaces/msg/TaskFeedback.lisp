; Auto-generated. Do not edit!


(cl:in-package library_robot_interfaces-msg)


;//! \htmlinclude TaskFeedback.msg.html

(cl:defclass <TaskFeedback> (roslisp-msg-protocol:ros-message)
  ((header
    :reader header
    :initarg :header
    :type std_msgs-msg:Header
    :initform (cl:make-instance 'std_msgs-msg:Header))
   (feedback_action_rails
    :reader feedback_action_rails
    :initarg :feedback_action_rails
    :type cl:string
    :initform "")
   (feedback_payload_json
    :reader feedback_payload_json
    :initarg :feedback_payload_json
    :type cl:string
    :initform ""))
)

(cl:defclass TaskFeedback (<TaskFeedback>)
  ())

(cl:defmethod cl:initialize-instance :after ((m <TaskFeedback>) cl:&rest args)
  (cl:declare (cl:ignorable args))
  (cl:unless (cl:typep m 'TaskFeedback)
    (roslisp-msg-protocol:msg-deprecation-warning "using old message class name library_robot_interfaces-msg:<TaskFeedback> is deprecated: use library_robot_interfaces-msg:TaskFeedback instead.")))

(cl:ensure-generic-function 'header-val :lambda-list '(m))
(cl:defmethod header-val ((m <TaskFeedback>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader library_robot_interfaces-msg:header-val is deprecated.  Use library_robot_interfaces-msg:header instead.")
  (header m))

(cl:ensure-generic-function 'feedback_action_rails-val :lambda-list '(m))
(cl:defmethod feedback_action_rails-val ((m <TaskFeedback>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader library_robot_interfaces-msg:feedback_action_rails-val is deprecated.  Use library_robot_interfaces-msg:feedback_action_rails instead.")
  (feedback_action_rails m))

(cl:ensure-generic-function 'feedback_payload_json-val :lambda-list '(m))
(cl:defmethod feedback_payload_json-val ((m <TaskFeedback>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader library_robot_interfaces-msg:feedback_payload_json-val is deprecated.  Use library_robot_interfaces-msg:feedback_payload_json instead.")
  (feedback_payload_json m))
(cl:defmethod roslisp-msg-protocol:serialize ((msg <TaskFeedback>) ostream)
  "Serializes a message object of type '<TaskFeedback>"
  (roslisp-msg-protocol:serialize (cl:slot-value msg 'header) ostream)
  (cl:let ((__ros_str_len (cl:length (cl:slot-value msg 'feedback_action_rails))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) __ros_str_len) ostream))
  (cl:map cl:nil #'(cl:lambda (c) (cl:write-byte (cl:char-code c) ostream)) (cl:slot-value msg 'feedback_action_rails))
  (cl:let ((__ros_str_len (cl:length (cl:slot-value msg 'feedback_payload_json))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) __ros_str_len) ostream))
  (cl:map cl:nil #'(cl:lambda (c) (cl:write-byte (cl:char-code c) ostream)) (cl:slot-value msg 'feedback_payload_json))
)
(cl:defmethod roslisp-msg-protocol:deserialize ((msg <TaskFeedback>) istream)
  "Deserializes a message object of type '<TaskFeedback>"
  (roslisp-msg-protocol:deserialize (cl:slot-value msg 'header) istream)
    (cl:let ((__ros_str_len 0))
      (cl:setf (cl:ldb (cl:byte 8 0) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:slot-value msg 'feedback_action_rails) (cl:make-string __ros_str_len))
      (cl:dotimes (__ros_str_idx __ros_str_len msg)
        (cl:setf (cl:char (cl:slot-value msg 'feedback_action_rails) __ros_str_idx) (cl:code-char (cl:read-byte istream)))))
    (cl:let ((__ros_str_len 0))
      (cl:setf (cl:ldb (cl:byte 8 0) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:slot-value msg 'feedback_payload_json) (cl:make-string __ros_str_len))
      (cl:dotimes (__ros_str_idx __ros_str_len msg)
        (cl:setf (cl:char (cl:slot-value msg 'feedback_payload_json) __ros_str_idx) (cl:code-char (cl:read-byte istream)))))
  msg
)
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql '<TaskFeedback>)))
  "Returns string type for a message object of type '<TaskFeedback>"
  "library_robot_interfaces/TaskFeedback")
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'TaskFeedback)))
  "Returns string type for a message object of type 'TaskFeedback"
  "library_robot_interfaces/TaskFeedback")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql '<TaskFeedback>)))
  "Returns md5sum for a message object of type '<TaskFeedback>"
  "701107acf61196810ba751bfea18045a")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql 'TaskFeedback)))
  "Returns md5sum for a message object of type 'TaskFeedback"
  "701107acf61196810ba751bfea18045a")
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql '<TaskFeedback>)))
  "Returns full string definition for message of type '<TaskFeedback>"
  (cl:format cl:nil "std_msgs/Header header~%# string task_id_rails            # 此反馈相关的Rails Task ID (如果适用)~%string feedback_action_rails    # 要在Rails RobotFeedbackChannel上调用的方法名~%                                # 例如: \"update_task_progress\", \"report_map_preview\", \"report_task_completion\"~%string feedback_payload_json    # JSON字符串，作为上述Rails Channel方法的payload~%================================================================================~%MSG: std_msgs/Header~%# Standard metadata for higher-level stamped data types.~%# This is generally used to communicate timestamped data ~%# in a particular coordinate frame.~%# ~%# sequence ID: consecutively increasing ID ~%uint32 seq~%#Two-integer timestamp that is expressed as:~%# * stamp.sec: seconds (stamp_secs) since epoch (in Python the variable is called 'secs')~%# * stamp.nsec: nanoseconds since stamp_secs (in Python the variable is called 'nsecs')~%# time-handling sugar is provided by the client library~%time stamp~%#Frame this data is associated with~%string frame_id~%~%~%"))
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql 'TaskFeedback)))
  "Returns full string definition for message of type 'TaskFeedback"
  (cl:format cl:nil "std_msgs/Header header~%# string task_id_rails            # 此反馈相关的Rails Task ID (如果适用)~%string feedback_action_rails    # 要在Rails RobotFeedbackChannel上调用的方法名~%                                # 例如: \"update_task_progress\", \"report_map_preview\", \"report_task_completion\"~%string feedback_payload_json    # JSON字符串，作为上述Rails Channel方法的payload~%================================================================================~%MSG: std_msgs/Header~%# Standard metadata for higher-level stamped data types.~%# This is generally used to communicate timestamped data ~%# in a particular coordinate frame.~%# ~%# sequence ID: consecutively increasing ID ~%uint32 seq~%#Two-integer timestamp that is expressed as:~%# * stamp.sec: seconds (stamp_secs) since epoch (in Python the variable is called 'secs')~%# * stamp.nsec: nanoseconds since stamp_secs (in Python the variable is called 'nsecs')~%# time-handling sugar is provided by the client library~%time stamp~%#Frame this data is associated with~%string frame_id~%~%~%"))
(cl:defmethod roslisp-msg-protocol:serialization-length ((msg <TaskFeedback>))
  (cl:+ 0
     (roslisp-msg-protocol:serialization-length (cl:slot-value msg 'header))
     4 (cl:length (cl:slot-value msg 'feedback_action_rails))
     4 (cl:length (cl:slot-value msg 'feedback_payload_json))
))
(cl:defmethod roslisp-msg-protocol:ros-message-to-list ((msg <TaskFeedback>))
  "Converts a ROS message object to a list"
  (cl:list 'TaskFeedback
    (cl:cons ':header (header msg))
    (cl:cons ':feedback_action_rails (feedback_action_rails msg))
    (cl:cons ':feedback_payload_json (feedback_payload_json msg))
))
