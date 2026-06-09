; Auto-generated. Do not edit!


(cl:in-package warehouse_sorting_msgs-msg)


;//! \htmlinclude TaskStatus.msg.html

(cl:defclass <TaskStatus> (roslisp-msg-protocol:ros-message)
  ((header
    :reader header
    :initarg :header
    :type std_msgs-msg:Header
    :initform (cl:make-instance 'std_msgs-msg:Header))
   (task_id
    :reader task_id
    :initarg :task_id
    :type cl:string
    :initform "")
   (status
    :reader status
    :initarg :status
    :type cl:string
    :initform "")
   (total_items
    :reader total_items
    :initarg :total_items
    :type cl:integer
    :initform 0)
   (completed_items
    :reader completed_items
    :initarg :completed_items
    :type cl:integer
    :initform 0)
   (failed_items
    :reader failed_items
    :initarg :failed_items
    :type cl:integer
    :initform 0)
   (sorted_natural
    :reader sorted_natural
    :initarg :sorted_natural
    :type cl:integer
    :initform 0)
   (sorted_colored
    :reader sorted_colored
    :initarg :sorted_colored
    :type cl:integer
    :initform 0)
   (progress
    :reader progress
    :initarg :progress
    :type cl:float
    :initform 0.0)
   (queue_size
    :reader queue_size
    :initarg :queue_size
    :type cl:integer
    :initform 0)
   (current_step
    :reader current_step
    :initarg :current_step
    :type cl:string
    :initform "")
   (last_error
    :reader last_error
    :initarg :last_error
    :type cl:string
    :initform ""))
)

(cl:defclass TaskStatus (<TaskStatus>)
  ())

(cl:defmethod cl:initialize-instance :after ((m <TaskStatus>) cl:&rest args)
  (cl:declare (cl:ignorable args))
  (cl:unless (cl:typep m 'TaskStatus)
    (roslisp-msg-protocol:msg-deprecation-warning "using old message class name warehouse_sorting_msgs-msg:<TaskStatus> is deprecated: use warehouse_sorting_msgs-msg:TaskStatus instead.")))

(cl:ensure-generic-function 'header-val :lambda-list '(m))
(cl:defmethod header-val ((m <TaskStatus>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader warehouse_sorting_msgs-msg:header-val is deprecated.  Use warehouse_sorting_msgs-msg:header instead.")
  (header m))

(cl:ensure-generic-function 'task_id-val :lambda-list '(m))
(cl:defmethod task_id-val ((m <TaskStatus>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader warehouse_sorting_msgs-msg:task_id-val is deprecated.  Use warehouse_sorting_msgs-msg:task_id instead.")
  (task_id m))

(cl:ensure-generic-function 'status-val :lambda-list '(m))
(cl:defmethod status-val ((m <TaskStatus>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader warehouse_sorting_msgs-msg:status-val is deprecated.  Use warehouse_sorting_msgs-msg:status instead.")
  (status m))

(cl:ensure-generic-function 'total_items-val :lambda-list '(m))
(cl:defmethod total_items-val ((m <TaskStatus>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader warehouse_sorting_msgs-msg:total_items-val is deprecated.  Use warehouse_sorting_msgs-msg:total_items instead.")
  (total_items m))

(cl:ensure-generic-function 'completed_items-val :lambda-list '(m))
(cl:defmethod completed_items-val ((m <TaskStatus>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader warehouse_sorting_msgs-msg:completed_items-val is deprecated.  Use warehouse_sorting_msgs-msg:completed_items instead.")
  (completed_items m))

(cl:ensure-generic-function 'failed_items-val :lambda-list '(m))
(cl:defmethod failed_items-val ((m <TaskStatus>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader warehouse_sorting_msgs-msg:failed_items-val is deprecated.  Use warehouse_sorting_msgs-msg:failed_items instead.")
  (failed_items m))

(cl:ensure-generic-function 'sorted_natural-val :lambda-list '(m))
(cl:defmethod sorted_natural-val ((m <TaskStatus>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader warehouse_sorting_msgs-msg:sorted_natural-val is deprecated.  Use warehouse_sorting_msgs-msg:sorted_natural instead.")
  (sorted_natural m))

(cl:ensure-generic-function 'sorted_colored-val :lambda-list '(m))
(cl:defmethod sorted_colored-val ((m <TaskStatus>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader warehouse_sorting_msgs-msg:sorted_colored-val is deprecated.  Use warehouse_sorting_msgs-msg:sorted_colored instead.")
  (sorted_colored m))

(cl:ensure-generic-function 'progress-val :lambda-list '(m))
(cl:defmethod progress-val ((m <TaskStatus>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader warehouse_sorting_msgs-msg:progress-val is deprecated.  Use warehouse_sorting_msgs-msg:progress instead.")
  (progress m))

(cl:ensure-generic-function 'queue_size-val :lambda-list '(m))
(cl:defmethod queue_size-val ((m <TaskStatus>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader warehouse_sorting_msgs-msg:queue_size-val is deprecated.  Use warehouse_sorting_msgs-msg:queue_size instead.")
  (queue_size m))

(cl:ensure-generic-function 'current_step-val :lambda-list '(m))
(cl:defmethod current_step-val ((m <TaskStatus>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader warehouse_sorting_msgs-msg:current_step-val is deprecated.  Use warehouse_sorting_msgs-msg:current_step instead.")
  (current_step m))

(cl:ensure-generic-function 'last_error-val :lambda-list '(m))
(cl:defmethod last_error-val ((m <TaskStatus>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader warehouse_sorting_msgs-msg:last_error-val is deprecated.  Use warehouse_sorting_msgs-msg:last_error instead.")
  (last_error m))
(cl:defmethod roslisp-msg-protocol:serialize ((msg <TaskStatus>) ostream)
  "Serializes a message object of type '<TaskStatus>"
  (roslisp-msg-protocol:serialize (cl:slot-value msg 'header) ostream)
  (cl:let ((__ros_str_len (cl:length (cl:slot-value msg 'task_id))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) __ros_str_len) ostream))
  (cl:map cl:nil #'(cl:lambda (c) (cl:write-byte (cl:char-code c) ostream)) (cl:slot-value msg 'task_id))
  (cl:let ((__ros_str_len (cl:length (cl:slot-value msg 'status))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) __ros_str_len) ostream))
  (cl:map cl:nil #'(cl:lambda (c) (cl:write-byte (cl:char-code c) ostream)) (cl:slot-value msg 'status))
  (cl:write-byte (cl:ldb (cl:byte 8 0) (cl:slot-value msg 'total_items)) ostream)
  (cl:write-byte (cl:ldb (cl:byte 8 8) (cl:slot-value msg 'total_items)) ostream)
  (cl:write-byte (cl:ldb (cl:byte 8 16) (cl:slot-value msg 'total_items)) ostream)
  (cl:write-byte (cl:ldb (cl:byte 8 24) (cl:slot-value msg 'total_items)) ostream)
  (cl:write-byte (cl:ldb (cl:byte 8 0) (cl:slot-value msg 'completed_items)) ostream)
  (cl:write-byte (cl:ldb (cl:byte 8 8) (cl:slot-value msg 'completed_items)) ostream)
  (cl:write-byte (cl:ldb (cl:byte 8 16) (cl:slot-value msg 'completed_items)) ostream)
  (cl:write-byte (cl:ldb (cl:byte 8 24) (cl:slot-value msg 'completed_items)) ostream)
  (cl:write-byte (cl:ldb (cl:byte 8 0) (cl:slot-value msg 'failed_items)) ostream)
  (cl:write-byte (cl:ldb (cl:byte 8 8) (cl:slot-value msg 'failed_items)) ostream)
  (cl:write-byte (cl:ldb (cl:byte 8 16) (cl:slot-value msg 'failed_items)) ostream)
  (cl:write-byte (cl:ldb (cl:byte 8 24) (cl:slot-value msg 'failed_items)) ostream)
  (cl:write-byte (cl:ldb (cl:byte 8 0) (cl:slot-value msg 'sorted_natural)) ostream)
  (cl:write-byte (cl:ldb (cl:byte 8 8) (cl:slot-value msg 'sorted_natural)) ostream)
  (cl:write-byte (cl:ldb (cl:byte 8 16) (cl:slot-value msg 'sorted_natural)) ostream)
  (cl:write-byte (cl:ldb (cl:byte 8 24) (cl:slot-value msg 'sorted_natural)) ostream)
  (cl:write-byte (cl:ldb (cl:byte 8 0) (cl:slot-value msg 'sorted_colored)) ostream)
  (cl:write-byte (cl:ldb (cl:byte 8 8) (cl:slot-value msg 'sorted_colored)) ostream)
  (cl:write-byte (cl:ldb (cl:byte 8 16) (cl:slot-value msg 'sorted_colored)) ostream)
  (cl:write-byte (cl:ldb (cl:byte 8 24) (cl:slot-value msg 'sorted_colored)) ostream)
  (cl:let ((bits (roslisp-utils:encode-single-float-bits (cl:slot-value msg 'progress))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) bits) ostream))
  (cl:write-byte (cl:ldb (cl:byte 8 0) (cl:slot-value msg 'queue_size)) ostream)
  (cl:write-byte (cl:ldb (cl:byte 8 8) (cl:slot-value msg 'queue_size)) ostream)
  (cl:write-byte (cl:ldb (cl:byte 8 16) (cl:slot-value msg 'queue_size)) ostream)
  (cl:write-byte (cl:ldb (cl:byte 8 24) (cl:slot-value msg 'queue_size)) ostream)
  (cl:let ((__ros_str_len (cl:length (cl:slot-value msg 'current_step))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) __ros_str_len) ostream))
  (cl:map cl:nil #'(cl:lambda (c) (cl:write-byte (cl:char-code c) ostream)) (cl:slot-value msg 'current_step))
  (cl:let ((__ros_str_len (cl:length (cl:slot-value msg 'last_error))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) __ros_str_len) ostream))
  (cl:map cl:nil #'(cl:lambda (c) (cl:write-byte (cl:char-code c) ostream)) (cl:slot-value msg 'last_error))
)
(cl:defmethod roslisp-msg-protocol:deserialize ((msg <TaskStatus>) istream)
  "Deserializes a message object of type '<TaskStatus>"
  (roslisp-msg-protocol:deserialize (cl:slot-value msg 'header) istream)
    (cl:let ((__ros_str_len 0))
      (cl:setf (cl:ldb (cl:byte 8 0) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:slot-value msg 'task_id) (cl:make-string __ros_str_len))
      (cl:dotimes (__ros_str_idx __ros_str_len msg)
        (cl:setf (cl:char (cl:slot-value msg 'task_id) __ros_str_idx) (cl:code-char (cl:read-byte istream)))))
    (cl:let ((__ros_str_len 0))
      (cl:setf (cl:ldb (cl:byte 8 0) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:slot-value msg 'status) (cl:make-string __ros_str_len))
      (cl:dotimes (__ros_str_idx __ros_str_len msg)
        (cl:setf (cl:char (cl:slot-value msg 'status) __ros_str_idx) (cl:code-char (cl:read-byte istream)))))
    (cl:setf (cl:ldb (cl:byte 8 0) (cl:slot-value msg 'total_items)) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 8) (cl:slot-value msg 'total_items)) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 16) (cl:slot-value msg 'total_items)) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 24) (cl:slot-value msg 'total_items)) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 0) (cl:slot-value msg 'completed_items)) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 8) (cl:slot-value msg 'completed_items)) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 16) (cl:slot-value msg 'completed_items)) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 24) (cl:slot-value msg 'completed_items)) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 0) (cl:slot-value msg 'failed_items)) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 8) (cl:slot-value msg 'failed_items)) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 16) (cl:slot-value msg 'failed_items)) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 24) (cl:slot-value msg 'failed_items)) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 0) (cl:slot-value msg 'sorted_natural)) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 8) (cl:slot-value msg 'sorted_natural)) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 16) (cl:slot-value msg 'sorted_natural)) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 24) (cl:slot-value msg 'sorted_natural)) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 0) (cl:slot-value msg 'sorted_colored)) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 8) (cl:slot-value msg 'sorted_colored)) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 16) (cl:slot-value msg 'sorted_colored)) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 24) (cl:slot-value msg 'sorted_colored)) (cl:read-byte istream))
    (cl:let ((bits 0))
      (cl:setf (cl:ldb (cl:byte 8 0) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) bits) (cl:read-byte istream))
    (cl:setf (cl:slot-value msg 'progress) (roslisp-utils:decode-single-float-bits bits)))
    (cl:setf (cl:ldb (cl:byte 8 0) (cl:slot-value msg 'queue_size)) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 8) (cl:slot-value msg 'queue_size)) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 16) (cl:slot-value msg 'queue_size)) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 24) (cl:slot-value msg 'queue_size)) (cl:read-byte istream))
    (cl:let ((__ros_str_len 0))
      (cl:setf (cl:ldb (cl:byte 8 0) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:slot-value msg 'current_step) (cl:make-string __ros_str_len))
      (cl:dotimes (__ros_str_idx __ros_str_len msg)
        (cl:setf (cl:char (cl:slot-value msg 'current_step) __ros_str_idx) (cl:code-char (cl:read-byte istream)))))
    (cl:let ((__ros_str_len 0))
      (cl:setf (cl:ldb (cl:byte 8 0) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:slot-value msg 'last_error) (cl:make-string __ros_str_len))
      (cl:dotimes (__ros_str_idx __ros_str_len msg)
        (cl:setf (cl:char (cl:slot-value msg 'last_error) __ros_str_idx) (cl:code-char (cl:read-byte istream)))))
  msg
)
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql '<TaskStatus>)))
  "Returns string type for a message object of type '<TaskStatus>"
  "warehouse_sorting_msgs/TaskStatus")
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'TaskStatus)))
  "Returns string type for a message object of type 'TaskStatus"
  "warehouse_sorting_msgs/TaskStatus")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql '<TaskStatus>)))
  "Returns md5sum for a message object of type '<TaskStatus>"
  "b784d483d6404417f2b1da231522b939")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql 'TaskStatus)))
  "Returns md5sum for a message object of type 'TaskStatus"
  "b784d483d6404417f2b1da231522b939")
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql '<TaskStatus>)))
  "Returns full string definition for message of type '<TaskStatus>"
  (cl:format cl:nil "std_msgs/Header header~%string task_id~%string status~%uint32 total_items~%uint32 completed_items~%uint32 failed_items~%uint32 sorted_natural~%uint32 sorted_colored~%float32 progress~%uint32 queue_size~%string current_step~%string last_error~%~%================================================================================~%MSG: std_msgs/Header~%# Standard metadata for higher-level stamped data types.~%# This is generally used to communicate timestamped data ~%# in a particular coordinate frame.~%# ~%# sequence ID: consecutively increasing ID ~%uint32 seq~%#Two-integer timestamp that is expressed as:~%# * stamp.sec: seconds (stamp_secs) since epoch (in Python the variable is called 'secs')~%# * stamp.nsec: nanoseconds since stamp_secs (in Python the variable is called 'nsecs')~%# time-handling sugar is provided by the client library~%time stamp~%#Frame this data is associated with~%string frame_id~%~%~%"))
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql 'TaskStatus)))
  "Returns full string definition for message of type 'TaskStatus"
  (cl:format cl:nil "std_msgs/Header header~%string task_id~%string status~%uint32 total_items~%uint32 completed_items~%uint32 failed_items~%uint32 sorted_natural~%uint32 sorted_colored~%float32 progress~%uint32 queue_size~%string current_step~%string last_error~%~%================================================================================~%MSG: std_msgs/Header~%# Standard metadata for higher-level stamped data types.~%# This is generally used to communicate timestamped data ~%# in a particular coordinate frame.~%# ~%# sequence ID: consecutively increasing ID ~%uint32 seq~%#Two-integer timestamp that is expressed as:~%# * stamp.sec: seconds (stamp_secs) since epoch (in Python the variable is called 'secs')~%# * stamp.nsec: nanoseconds since stamp_secs (in Python the variable is called 'nsecs')~%# time-handling sugar is provided by the client library~%time stamp~%#Frame this data is associated with~%string frame_id~%~%~%"))
(cl:defmethod roslisp-msg-protocol:serialization-length ((msg <TaskStatus>))
  (cl:+ 0
     (roslisp-msg-protocol:serialization-length (cl:slot-value msg 'header))
     4 (cl:length (cl:slot-value msg 'task_id))
     4 (cl:length (cl:slot-value msg 'status))
     4
     4
     4
     4
     4
     4
     4
     4 (cl:length (cl:slot-value msg 'current_step))
     4 (cl:length (cl:slot-value msg 'last_error))
))
(cl:defmethod roslisp-msg-protocol:ros-message-to-list ((msg <TaskStatus>))
  "Converts a ROS message object to a list"
  (cl:list 'TaskStatus
    (cl:cons ':header (header msg))
    (cl:cons ':task_id (task_id msg))
    (cl:cons ':status (status msg))
    (cl:cons ':total_items (total_items msg))
    (cl:cons ':completed_items (completed_items msg))
    (cl:cons ':failed_items (failed_items msg))
    (cl:cons ':sorted_natural (sorted_natural msg))
    (cl:cons ':sorted_colored (sorted_colored msg))
    (cl:cons ':progress (progress msg))
    (cl:cons ':queue_size (queue_size msg))
    (cl:cons ':current_step (current_step msg))
    (cl:cons ':last_error (last_error msg))
))
