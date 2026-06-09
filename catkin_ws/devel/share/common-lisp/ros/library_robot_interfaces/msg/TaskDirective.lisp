; Auto-generated. Do not edit!


(cl:in-package library_robot_interfaces-msg)


;//! \htmlinclude TaskDirective.msg.html

(cl:defclass <TaskDirective> (roslisp-msg-protocol:ros-message)
  ((header
    :reader header
    :initarg :header
    :type std_msgs-msg:Header
    :initform (cl:make-instance 'std_msgs-msg:Header))
   (command_type
    :reader command_type
    :initarg :command_type
    :type cl:string
    :initform "")
   (task_id_rails
    :reader task_id_rails
    :initarg :task_id_rails
    :type cl:string
    :initform "")
   (task_type_rails
    :reader task_type_rails
    :initarg :task_type_rails
    :type cl:string
    :initform "")
   (task_priority
    :reader task_priority
    :initarg :task_priority
    :type cl:integer
    :initform 0)
   (parameters_json
    :reader parameters_json
    :initarg :parameters_json
    :type cl:string
    :initform ""))
)

(cl:defclass TaskDirective (<TaskDirective>)
  ())

(cl:defmethod cl:initialize-instance :after ((m <TaskDirective>) cl:&rest args)
  (cl:declare (cl:ignorable args))
  (cl:unless (cl:typep m 'TaskDirective)
    (roslisp-msg-protocol:msg-deprecation-warning "using old message class name library_robot_interfaces-msg:<TaskDirective> is deprecated: use library_robot_interfaces-msg:TaskDirective instead.")))

(cl:ensure-generic-function 'header-val :lambda-list '(m))
(cl:defmethod header-val ((m <TaskDirective>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader library_robot_interfaces-msg:header-val is deprecated.  Use library_robot_interfaces-msg:header instead.")
  (header m))

(cl:ensure-generic-function 'command_type-val :lambda-list '(m))
(cl:defmethod command_type-val ((m <TaskDirective>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader library_robot_interfaces-msg:command_type-val is deprecated.  Use library_robot_interfaces-msg:command_type instead.")
  (command_type m))

(cl:ensure-generic-function 'task_id_rails-val :lambda-list '(m))
(cl:defmethod task_id_rails-val ((m <TaskDirective>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader library_robot_interfaces-msg:task_id_rails-val is deprecated.  Use library_robot_interfaces-msg:task_id_rails instead.")
  (task_id_rails m))

(cl:ensure-generic-function 'task_type_rails-val :lambda-list '(m))
(cl:defmethod task_type_rails-val ((m <TaskDirective>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader library_robot_interfaces-msg:task_type_rails-val is deprecated.  Use library_robot_interfaces-msg:task_type_rails instead.")
  (task_type_rails m))

(cl:ensure-generic-function 'task_priority-val :lambda-list '(m))
(cl:defmethod task_priority-val ((m <TaskDirective>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader library_robot_interfaces-msg:task_priority-val is deprecated.  Use library_robot_interfaces-msg:task_priority instead.")
  (task_priority m))

(cl:ensure-generic-function 'parameters_json-val :lambda-list '(m))
(cl:defmethod parameters_json-val ((m <TaskDirective>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader library_robot_interfaces-msg:parameters_json-val is deprecated.  Use library_robot_interfaces-msg:parameters_json instead.")
  (parameters_json m))
(cl:defmethod roslisp-msg-protocol:serialize ((msg <TaskDirective>) ostream)
  "Serializes a message object of type '<TaskDirective>"
  (roslisp-msg-protocol:serialize (cl:slot-value msg 'header) ostream)
  (cl:let ((__ros_str_len (cl:length (cl:slot-value msg 'command_type))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) __ros_str_len) ostream))
  (cl:map cl:nil #'(cl:lambda (c) (cl:write-byte (cl:char-code c) ostream)) (cl:slot-value msg 'command_type))
  (cl:let ((__ros_str_len (cl:length (cl:slot-value msg 'task_id_rails))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) __ros_str_len) ostream))
  (cl:map cl:nil #'(cl:lambda (c) (cl:write-byte (cl:char-code c) ostream)) (cl:slot-value msg 'task_id_rails))
  (cl:let ((__ros_str_len (cl:length (cl:slot-value msg 'task_type_rails))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) __ros_str_len) ostream))
  (cl:map cl:nil #'(cl:lambda (c) (cl:write-byte (cl:char-code c) ostream)) (cl:slot-value msg 'task_type_rails))
  (cl:let* ((signed (cl:slot-value msg 'task_priority)) (unsigned (cl:if (cl:< signed 0) (cl:+ signed 4294967296) signed)))
    (cl:write-byte (cl:ldb (cl:byte 8 0) unsigned) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) unsigned) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) unsigned) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) unsigned) ostream)
    )
  (cl:let ((__ros_str_len (cl:length (cl:slot-value msg 'parameters_json))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) __ros_str_len) ostream))
  (cl:map cl:nil #'(cl:lambda (c) (cl:write-byte (cl:char-code c) ostream)) (cl:slot-value msg 'parameters_json))
)
(cl:defmethod roslisp-msg-protocol:deserialize ((msg <TaskDirective>) istream)
  "Deserializes a message object of type '<TaskDirective>"
  (roslisp-msg-protocol:deserialize (cl:slot-value msg 'header) istream)
    (cl:let ((__ros_str_len 0))
      (cl:setf (cl:ldb (cl:byte 8 0) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:slot-value msg 'command_type) (cl:make-string __ros_str_len))
      (cl:dotimes (__ros_str_idx __ros_str_len msg)
        (cl:setf (cl:char (cl:slot-value msg 'command_type) __ros_str_idx) (cl:code-char (cl:read-byte istream)))))
    (cl:let ((__ros_str_len 0))
      (cl:setf (cl:ldb (cl:byte 8 0) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:slot-value msg 'task_id_rails) (cl:make-string __ros_str_len))
      (cl:dotimes (__ros_str_idx __ros_str_len msg)
        (cl:setf (cl:char (cl:slot-value msg 'task_id_rails) __ros_str_idx) (cl:code-char (cl:read-byte istream)))))
    (cl:let ((__ros_str_len 0))
      (cl:setf (cl:ldb (cl:byte 8 0) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:slot-value msg 'task_type_rails) (cl:make-string __ros_str_len))
      (cl:dotimes (__ros_str_idx __ros_str_len msg)
        (cl:setf (cl:char (cl:slot-value msg 'task_type_rails) __ros_str_idx) (cl:code-char (cl:read-byte istream)))))
    (cl:let ((unsigned 0))
      (cl:setf (cl:ldb (cl:byte 8 0) unsigned) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) unsigned) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) unsigned) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) unsigned) (cl:read-byte istream))
      (cl:setf (cl:slot-value msg 'task_priority) (cl:if (cl:< unsigned 2147483648) unsigned (cl:- unsigned 4294967296))))
    (cl:let ((__ros_str_len 0))
      (cl:setf (cl:ldb (cl:byte 8 0) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:slot-value msg 'parameters_json) (cl:make-string __ros_str_len))
      (cl:dotimes (__ros_str_idx __ros_str_len msg)
        (cl:setf (cl:char (cl:slot-value msg 'parameters_json) __ros_str_idx) (cl:code-char (cl:read-byte istream)))))
  msg
)
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql '<TaskDirective>)))
  "Returns string type for a message object of type '<TaskDirective>"
  "library_robot_interfaces/TaskDirective")
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'TaskDirective)))
  "Returns string type for a message object of type 'TaskDirective"
  "library_robot_interfaces/TaskDirective")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql '<TaskDirective>)))
  "Returns md5sum for a message object of type '<TaskDirective>"
  "d22fcfa77d7cca35dedf9ea427a99e6a")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql 'TaskDirective)))
  "Returns md5sum for a message object of type 'TaskDirective"
  "d22fcfa77d7cca35dedf9ea427a99e6a")
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql '<TaskDirective>)))
  "Returns full string definition for message of type '<TaskDirective>"
  (cl:format cl:nil "std_msgs/Header header~%string command_type          # 例如: \"TASK_EXECUTE\", \"TASK_CANCEL\", \"MOVE\", \"EMERGENCY_STOP\"~%string task_id_rails         # Rails Task ID (如果适用，对于即时命令可以为空或特定值)~%string task_type_rails       # 例如: \"MAP_BUILD_AUTO\", \"LOAD_MAP\", 或对于即时命令，同command_type~%int32 task_priority         # 任务优先级，0表示最低，10表示最高~%string parameters_json       # JSON字符串，包含任务或命令所需的参数~%================================================================================~%MSG: std_msgs/Header~%# Standard metadata for higher-level stamped data types.~%# This is generally used to communicate timestamped data ~%# in a particular coordinate frame.~%# ~%# sequence ID: consecutively increasing ID ~%uint32 seq~%#Two-integer timestamp that is expressed as:~%# * stamp.sec: seconds (stamp_secs) since epoch (in Python the variable is called 'secs')~%# * stamp.nsec: nanoseconds since stamp_secs (in Python the variable is called 'nsecs')~%# time-handling sugar is provided by the client library~%time stamp~%#Frame this data is associated with~%string frame_id~%~%~%"))
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql 'TaskDirective)))
  "Returns full string definition for message of type 'TaskDirective"
  (cl:format cl:nil "std_msgs/Header header~%string command_type          # 例如: \"TASK_EXECUTE\", \"TASK_CANCEL\", \"MOVE\", \"EMERGENCY_STOP\"~%string task_id_rails         # Rails Task ID (如果适用，对于即时命令可以为空或特定值)~%string task_type_rails       # 例如: \"MAP_BUILD_AUTO\", \"LOAD_MAP\", 或对于即时命令，同command_type~%int32 task_priority         # 任务优先级，0表示最低，10表示最高~%string parameters_json       # JSON字符串，包含任务或命令所需的参数~%================================================================================~%MSG: std_msgs/Header~%# Standard metadata for higher-level stamped data types.~%# This is generally used to communicate timestamped data ~%# in a particular coordinate frame.~%# ~%# sequence ID: consecutively increasing ID ~%uint32 seq~%#Two-integer timestamp that is expressed as:~%# * stamp.sec: seconds (stamp_secs) since epoch (in Python the variable is called 'secs')~%# * stamp.nsec: nanoseconds since stamp_secs (in Python the variable is called 'nsecs')~%# time-handling sugar is provided by the client library~%time stamp~%#Frame this data is associated with~%string frame_id~%~%~%"))
(cl:defmethod roslisp-msg-protocol:serialization-length ((msg <TaskDirective>))
  (cl:+ 0
     (roslisp-msg-protocol:serialization-length (cl:slot-value msg 'header))
     4 (cl:length (cl:slot-value msg 'command_type))
     4 (cl:length (cl:slot-value msg 'task_id_rails))
     4 (cl:length (cl:slot-value msg 'task_type_rails))
     4
     4 (cl:length (cl:slot-value msg 'parameters_json))
))
(cl:defmethod roslisp-msg-protocol:ros-message-to-list ((msg <TaskDirective>))
  "Converts a ROS message object to a list"
  (cl:list 'TaskDirective
    (cl:cons ':header (header msg))
    (cl:cons ':command_type (command_type msg))
    (cl:cons ':task_id_rails (task_id_rails msg))
    (cl:cons ':task_type_rails (task_type_rails msg))
    (cl:cons ':task_priority (task_priority msg))
    (cl:cons ':parameters_json (parameters_json msg))
))
