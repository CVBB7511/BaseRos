; Auto-generated. Do not edit!


(cl:in-package library_robot_interfaces-msg)


;//! \htmlinclude RobotStatusCompressed.msg.html

(cl:defclass <RobotStatusCompressed> (roslisp-msg-protocol:ros-message)
  ((header
    :reader header
    :initarg :header
    :type std_msgs-msg:Header
    :initform (cl:make-instance 'std_msgs-msg:Header))
   (pose_x
    :reader pose_x
    :initarg :pose_x
    :type cl:float
    :initform 0.0)
   (pose_y
    :reader pose_y
    :initarg :pose_y
    :type cl:float
    :initform 0.0)
   (pose_theta
    :reader pose_theta
    :initarg :pose_theta
    :type cl:float
    :initform 0.0)
   (velocity_linear
    :reader velocity_linear
    :initarg :velocity_linear
    :type cl:float
    :initform 0.0)
   (velocity_angular
    :reader velocity_angular
    :initarg :velocity_angular
    :type cl:float
    :initform 0.0)
   (battery_percentage
    :reader battery_percentage
    :initarg :battery_percentage
    :type cl:float
    :initform 0.0)
   (robot_state_str
    :reader robot_state_str
    :initarg :robot_state_str
    :type cl:string
    :initform "")
   (error_message
    :reader error_message
    :initarg :error_message
    :type cl:string
    :initform "")
   (is_emergency_stopped
    :reader is_emergency_stopped
    :initarg :is_emergency_stopped
    :type cl:boolean
    :initform cl:nil)
   (active_task_id_rails
    :reader active_task_id_rails
    :initarg :active_task_id_rails
    :type cl:integer
    :initform 0)
   (active_map
    :reader active_map
    :initarg :active_map
    :type cl:integer
    :initform 0))
)

(cl:defclass RobotStatusCompressed (<RobotStatusCompressed>)
  ())

(cl:defmethod cl:initialize-instance :after ((m <RobotStatusCompressed>) cl:&rest args)
  (cl:declare (cl:ignorable args))
  (cl:unless (cl:typep m 'RobotStatusCompressed)
    (roslisp-msg-protocol:msg-deprecation-warning "using old message class name library_robot_interfaces-msg:<RobotStatusCompressed> is deprecated: use library_robot_interfaces-msg:RobotStatusCompressed instead.")))

(cl:ensure-generic-function 'header-val :lambda-list '(m))
(cl:defmethod header-val ((m <RobotStatusCompressed>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader library_robot_interfaces-msg:header-val is deprecated.  Use library_robot_interfaces-msg:header instead.")
  (header m))

(cl:ensure-generic-function 'pose_x-val :lambda-list '(m))
(cl:defmethod pose_x-val ((m <RobotStatusCompressed>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader library_robot_interfaces-msg:pose_x-val is deprecated.  Use library_robot_interfaces-msg:pose_x instead.")
  (pose_x m))

(cl:ensure-generic-function 'pose_y-val :lambda-list '(m))
(cl:defmethod pose_y-val ((m <RobotStatusCompressed>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader library_robot_interfaces-msg:pose_y-val is deprecated.  Use library_robot_interfaces-msg:pose_y instead.")
  (pose_y m))

(cl:ensure-generic-function 'pose_theta-val :lambda-list '(m))
(cl:defmethod pose_theta-val ((m <RobotStatusCompressed>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader library_robot_interfaces-msg:pose_theta-val is deprecated.  Use library_robot_interfaces-msg:pose_theta instead.")
  (pose_theta m))

(cl:ensure-generic-function 'velocity_linear-val :lambda-list '(m))
(cl:defmethod velocity_linear-val ((m <RobotStatusCompressed>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader library_robot_interfaces-msg:velocity_linear-val is deprecated.  Use library_robot_interfaces-msg:velocity_linear instead.")
  (velocity_linear m))

(cl:ensure-generic-function 'velocity_angular-val :lambda-list '(m))
(cl:defmethod velocity_angular-val ((m <RobotStatusCompressed>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader library_robot_interfaces-msg:velocity_angular-val is deprecated.  Use library_robot_interfaces-msg:velocity_angular instead.")
  (velocity_angular m))

(cl:ensure-generic-function 'battery_percentage-val :lambda-list '(m))
(cl:defmethod battery_percentage-val ((m <RobotStatusCompressed>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader library_robot_interfaces-msg:battery_percentage-val is deprecated.  Use library_robot_interfaces-msg:battery_percentage instead.")
  (battery_percentage m))

(cl:ensure-generic-function 'robot_state_str-val :lambda-list '(m))
(cl:defmethod robot_state_str-val ((m <RobotStatusCompressed>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader library_robot_interfaces-msg:robot_state_str-val is deprecated.  Use library_robot_interfaces-msg:robot_state_str instead.")
  (robot_state_str m))

(cl:ensure-generic-function 'error_message-val :lambda-list '(m))
(cl:defmethod error_message-val ((m <RobotStatusCompressed>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader library_robot_interfaces-msg:error_message-val is deprecated.  Use library_robot_interfaces-msg:error_message instead.")
  (error_message m))

(cl:ensure-generic-function 'is_emergency_stopped-val :lambda-list '(m))
(cl:defmethod is_emergency_stopped-val ((m <RobotStatusCompressed>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader library_robot_interfaces-msg:is_emergency_stopped-val is deprecated.  Use library_robot_interfaces-msg:is_emergency_stopped instead.")
  (is_emergency_stopped m))

(cl:ensure-generic-function 'active_task_id_rails-val :lambda-list '(m))
(cl:defmethod active_task_id_rails-val ((m <RobotStatusCompressed>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader library_robot_interfaces-msg:active_task_id_rails-val is deprecated.  Use library_robot_interfaces-msg:active_task_id_rails instead.")
  (active_task_id_rails m))

(cl:ensure-generic-function 'active_map-val :lambda-list '(m))
(cl:defmethod active_map-val ((m <RobotStatusCompressed>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader library_robot_interfaces-msg:active_map-val is deprecated.  Use library_robot_interfaces-msg:active_map instead.")
  (active_map m))
(cl:defmethod roslisp-msg-protocol:serialize ((msg <RobotStatusCompressed>) ostream)
  "Serializes a message object of type '<RobotStatusCompressed>"
  (roslisp-msg-protocol:serialize (cl:slot-value msg 'header) ostream)
  (cl:let ((bits (roslisp-utils:encode-single-float-bits (cl:slot-value msg 'pose_x))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) bits) ostream))
  (cl:let ((bits (roslisp-utils:encode-single-float-bits (cl:slot-value msg 'pose_y))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) bits) ostream))
  (cl:let ((bits (roslisp-utils:encode-single-float-bits (cl:slot-value msg 'pose_theta))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) bits) ostream))
  (cl:let ((bits (roslisp-utils:encode-single-float-bits (cl:slot-value msg 'velocity_linear))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) bits) ostream))
  (cl:let ((bits (roslisp-utils:encode-single-float-bits (cl:slot-value msg 'velocity_angular))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) bits) ostream))
  (cl:let ((bits (roslisp-utils:encode-single-float-bits (cl:slot-value msg 'battery_percentage))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) bits) ostream))
  (cl:let ((__ros_str_len (cl:length (cl:slot-value msg 'robot_state_str))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) __ros_str_len) ostream))
  (cl:map cl:nil #'(cl:lambda (c) (cl:write-byte (cl:char-code c) ostream)) (cl:slot-value msg 'robot_state_str))
  (cl:let ((__ros_str_len (cl:length (cl:slot-value msg 'error_message))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) __ros_str_len) ostream))
  (cl:map cl:nil #'(cl:lambda (c) (cl:write-byte (cl:char-code c) ostream)) (cl:slot-value msg 'error_message))
  (cl:write-byte (cl:ldb (cl:byte 8 0) (cl:if (cl:slot-value msg 'is_emergency_stopped) 1 0)) ostream)
  (cl:let* ((signed (cl:slot-value msg 'active_task_id_rails)) (unsigned (cl:if (cl:< signed 0) (cl:+ signed 4294967296) signed)))
    (cl:write-byte (cl:ldb (cl:byte 8 0) unsigned) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) unsigned) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) unsigned) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) unsigned) ostream)
    )
  (cl:let* ((signed (cl:slot-value msg 'active_map)) (unsigned (cl:if (cl:< signed 0) (cl:+ signed 4294967296) signed)))
    (cl:write-byte (cl:ldb (cl:byte 8 0) unsigned) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) unsigned) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) unsigned) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) unsigned) ostream)
    )
)
(cl:defmethod roslisp-msg-protocol:deserialize ((msg <RobotStatusCompressed>) istream)
  "Deserializes a message object of type '<RobotStatusCompressed>"
  (roslisp-msg-protocol:deserialize (cl:slot-value msg 'header) istream)
    (cl:let ((bits 0))
      (cl:setf (cl:ldb (cl:byte 8 0) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) bits) (cl:read-byte istream))
    (cl:setf (cl:slot-value msg 'pose_x) (roslisp-utils:decode-single-float-bits bits)))
    (cl:let ((bits 0))
      (cl:setf (cl:ldb (cl:byte 8 0) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) bits) (cl:read-byte istream))
    (cl:setf (cl:slot-value msg 'pose_y) (roslisp-utils:decode-single-float-bits bits)))
    (cl:let ((bits 0))
      (cl:setf (cl:ldb (cl:byte 8 0) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) bits) (cl:read-byte istream))
    (cl:setf (cl:slot-value msg 'pose_theta) (roslisp-utils:decode-single-float-bits bits)))
    (cl:let ((bits 0))
      (cl:setf (cl:ldb (cl:byte 8 0) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) bits) (cl:read-byte istream))
    (cl:setf (cl:slot-value msg 'velocity_linear) (roslisp-utils:decode-single-float-bits bits)))
    (cl:let ((bits 0))
      (cl:setf (cl:ldb (cl:byte 8 0) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) bits) (cl:read-byte istream))
    (cl:setf (cl:slot-value msg 'velocity_angular) (roslisp-utils:decode-single-float-bits bits)))
    (cl:let ((bits 0))
      (cl:setf (cl:ldb (cl:byte 8 0) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) bits) (cl:read-byte istream))
    (cl:setf (cl:slot-value msg 'battery_percentage) (roslisp-utils:decode-single-float-bits bits)))
    (cl:let ((__ros_str_len 0))
      (cl:setf (cl:ldb (cl:byte 8 0) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:slot-value msg 'robot_state_str) (cl:make-string __ros_str_len))
      (cl:dotimes (__ros_str_idx __ros_str_len msg)
        (cl:setf (cl:char (cl:slot-value msg 'robot_state_str) __ros_str_idx) (cl:code-char (cl:read-byte istream)))))
    (cl:let ((__ros_str_len 0))
      (cl:setf (cl:ldb (cl:byte 8 0) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:slot-value msg 'error_message) (cl:make-string __ros_str_len))
      (cl:dotimes (__ros_str_idx __ros_str_len msg)
        (cl:setf (cl:char (cl:slot-value msg 'error_message) __ros_str_idx) (cl:code-char (cl:read-byte istream)))))
    (cl:setf (cl:slot-value msg 'is_emergency_stopped) (cl:not (cl:zerop (cl:read-byte istream))))
    (cl:let ((unsigned 0))
      (cl:setf (cl:ldb (cl:byte 8 0) unsigned) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) unsigned) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) unsigned) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) unsigned) (cl:read-byte istream))
      (cl:setf (cl:slot-value msg 'active_task_id_rails) (cl:if (cl:< unsigned 2147483648) unsigned (cl:- unsigned 4294967296))))
    (cl:let ((unsigned 0))
      (cl:setf (cl:ldb (cl:byte 8 0) unsigned) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) unsigned) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) unsigned) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) unsigned) (cl:read-byte istream))
      (cl:setf (cl:slot-value msg 'active_map) (cl:if (cl:< unsigned 2147483648) unsigned (cl:- unsigned 4294967296))))
  msg
)
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql '<RobotStatusCompressed>)))
  "Returns string type for a message object of type '<RobotStatusCompressed>"
  "library_robot_interfaces/RobotStatusCompressed")
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'RobotStatusCompressed)))
  "Returns string type for a message object of type 'RobotStatusCompressed"
  "library_robot_interfaces/RobotStatusCompressed")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql '<RobotStatusCompressed>)))
  "Returns md5sum for a message object of type '<RobotStatusCompressed>"
  "6fbfcb9ff0fd4a4ddc6e1fcb05506c41")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql 'RobotStatusCompressed)))
  "Returns md5sum for a message object of type 'RobotStatusCompressed"
  "6fbfcb9ff0fd4a4ddc6e1fcb05506c41")
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql '<RobotStatusCompressed>)))
  "Returns full string definition for message of type '<RobotStatusCompressed>"
  (cl:format cl:nil "std_msgs/Header header~%float32 pose_x~%float32 pose_y~%float32 pose_theta~%float32 velocity_linear~%float32 velocity_angular~%float32 battery_percentage  # 0.0 到 100.0~%string robot_state_str      # TaskManager维护的机器人状态字符串, e.g., \"idle\", \"mapping\", \"error_localization_lost\"~%string error_message        # 当前错误信息 (如果有)~%bool is_emergency_stopped~%int32 active_task_id_rails # 当前正在执行的Rails Task ID (0 如果没有)~%int32 active_map      # ROS中当前加载的地图的ID (0 如果没有)~%================================================================================~%MSG: std_msgs/Header~%# Standard metadata for higher-level stamped data types.~%# This is generally used to communicate timestamped data ~%# in a particular coordinate frame.~%# ~%# sequence ID: consecutively increasing ID ~%uint32 seq~%#Two-integer timestamp that is expressed as:~%# * stamp.sec: seconds (stamp_secs) since epoch (in Python the variable is called 'secs')~%# * stamp.nsec: nanoseconds since stamp_secs (in Python the variable is called 'nsecs')~%# time-handling sugar is provided by the client library~%time stamp~%#Frame this data is associated with~%string frame_id~%~%~%"))
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql 'RobotStatusCompressed)))
  "Returns full string definition for message of type 'RobotStatusCompressed"
  (cl:format cl:nil "std_msgs/Header header~%float32 pose_x~%float32 pose_y~%float32 pose_theta~%float32 velocity_linear~%float32 velocity_angular~%float32 battery_percentage  # 0.0 到 100.0~%string robot_state_str      # TaskManager维护的机器人状态字符串, e.g., \"idle\", \"mapping\", \"error_localization_lost\"~%string error_message        # 当前错误信息 (如果有)~%bool is_emergency_stopped~%int32 active_task_id_rails # 当前正在执行的Rails Task ID (0 如果没有)~%int32 active_map      # ROS中当前加载的地图的ID (0 如果没有)~%================================================================================~%MSG: std_msgs/Header~%# Standard metadata for higher-level stamped data types.~%# This is generally used to communicate timestamped data ~%# in a particular coordinate frame.~%# ~%# sequence ID: consecutively increasing ID ~%uint32 seq~%#Two-integer timestamp that is expressed as:~%# * stamp.sec: seconds (stamp_secs) since epoch (in Python the variable is called 'secs')~%# * stamp.nsec: nanoseconds since stamp_secs (in Python the variable is called 'nsecs')~%# time-handling sugar is provided by the client library~%time stamp~%#Frame this data is associated with~%string frame_id~%~%~%"))
(cl:defmethod roslisp-msg-protocol:serialization-length ((msg <RobotStatusCompressed>))
  (cl:+ 0
     (roslisp-msg-protocol:serialization-length (cl:slot-value msg 'header))
     4
     4
     4
     4
     4
     4
     4 (cl:length (cl:slot-value msg 'robot_state_str))
     4 (cl:length (cl:slot-value msg 'error_message))
     1
     4
     4
))
(cl:defmethod roslisp-msg-protocol:ros-message-to-list ((msg <RobotStatusCompressed>))
  "Converts a ROS message object to a list"
  (cl:list 'RobotStatusCompressed
    (cl:cons ':header (header msg))
    (cl:cons ':pose_x (pose_x msg))
    (cl:cons ':pose_y (pose_y msg))
    (cl:cons ':pose_theta (pose_theta msg))
    (cl:cons ':velocity_linear (velocity_linear msg))
    (cl:cons ':velocity_angular (velocity_angular msg))
    (cl:cons ':battery_percentage (battery_percentage msg))
    (cl:cons ':robot_state_str (robot_state_str msg))
    (cl:cons ':error_message (error_message msg))
    (cl:cons ':is_emergency_stopped (is_emergency_stopped msg))
    (cl:cons ':active_task_id_rails (active_task_id_rails msg))
    (cl:cons ':active_map (active_map msg))
))
