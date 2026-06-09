; Auto-generated. Do not edit!


(cl:in-package warehouse_sorting_msgs-srv)


;//! \htmlinclude ArmCommand-request.msg.html

(cl:defclass <ArmCommand-request> (roslisp-msg-protocol:ros-message)
  ((cargo
    :reader cargo
    :initarg :cargo
    :type warehouse_sorting_msgs-msg:Cargo
    :initform (cl:make-instance 'warehouse_sorting_msgs-msg:Cargo))
   (target_pose
    :reader target_pose
    :initarg :target_pose
    :type geometry_msgs-msg:Pose
    :initform (cl:make-instance 'geometry_msgs-msg:Pose))
   (action
    :reader action
    :initarg :action
    :type cl:string
    :initform ""))
)

(cl:defclass ArmCommand-request (<ArmCommand-request>)
  ())

(cl:defmethod cl:initialize-instance :after ((m <ArmCommand-request>) cl:&rest args)
  (cl:declare (cl:ignorable args))
  (cl:unless (cl:typep m 'ArmCommand-request)
    (roslisp-msg-protocol:msg-deprecation-warning "using old message class name warehouse_sorting_msgs-srv:<ArmCommand-request> is deprecated: use warehouse_sorting_msgs-srv:ArmCommand-request instead.")))

(cl:ensure-generic-function 'cargo-val :lambda-list '(m))
(cl:defmethod cargo-val ((m <ArmCommand-request>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader warehouse_sorting_msgs-srv:cargo-val is deprecated.  Use warehouse_sorting_msgs-srv:cargo instead.")
  (cargo m))

(cl:ensure-generic-function 'target_pose-val :lambda-list '(m))
(cl:defmethod target_pose-val ((m <ArmCommand-request>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader warehouse_sorting_msgs-srv:target_pose-val is deprecated.  Use warehouse_sorting_msgs-srv:target_pose instead.")
  (target_pose m))

(cl:ensure-generic-function 'action-val :lambda-list '(m))
(cl:defmethod action-val ((m <ArmCommand-request>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader warehouse_sorting_msgs-srv:action-val is deprecated.  Use warehouse_sorting_msgs-srv:action instead.")
  (action m))
(cl:defmethod roslisp-msg-protocol:serialize ((msg <ArmCommand-request>) ostream)
  "Serializes a message object of type '<ArmCommand-request>"
  (roslisp-msg-protocol:serialize (cl:slot-value msg 'cargo) ostream)
  (roslisp-msg-protocol:serialize (cl:slot-value msg 'target_pose) ostream)
  (cl:let ((__ros_str_len (cl:length (cl:slot-value msg 'action))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) __ros_str_len) ostream))
  (cl:map cl:nil #'(cl:lambda (c) (cl:write-byte (cl:char-code c) ostream)) (cl:slot-value msg 'action))
)
(cl:defmethod roslisp-msg-protocol:deserialize ((msg <ArmCommand-request>) istream)
  "Deserializes a message object of type '<ArmCommand-request>"
  (roslisp-msg-protocol:deserialize (cl:slot-value msg 'cargo) istream)
  (roslisp-msg-protocol:deserialize (cl:slot-value msg 'target_pose) istream)
    (cl:let ((__ros_str_len 0))
      (cl:setf (cl:ldb (cl:byte 8 0) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:slot-value msg 'action) (cl:make-string __ros_str_len))
      (cl:dotimes (__ros_str_idx __ros_str_len msg)
        (cl:setf (cl:char (cl:slot-value msg 'action) __ros_str_idx) (cl:code-char (cl:read-byte istream)))))
  msg
)
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql '<ArmCommand-request>)))
  "Returns string type for a service object of type '<ArmCommand-request>"
  "warehouse_sorting_msgs/ArmCommandRequest")
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'ArmCommand-request)))
  "Returns string type for a service object of type 'ArmCommand-request"
  "warehouse_sorting_msgs/ArmCommandRequest")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql '<ArmCommand-request>)))
  "Returns md5sum for a message object of type '<ArmCommand-request>"
  "3846e631ba5aa8597f045fd2ffbc2e9a")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql 'ArmCommand-request)))
  "Returns md5sum for a message object of type 'ArmCommand-request"
  "3846e631ba5aa8597f045fd2ffbc2e9a")
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql '<ArmCommand-request>)))
  "Returns full string definition for message of type '<ArmCommand-request>"
  (cl:format cl:nil "warehouse_sorting_msgs/Cargo cargo~%geometry_msgs/Pose target_pose~%string action~%~%================================================================================~%MSG: warehouse_sorting_msgs/Cargo~%string cargo_id~%string cargo_type~%geometry_msgs/Pose pose~%geometry_msgs/Vector3 size~%float32 volume~%float32 confidence~%int32 bbox_x~%int32 bbox_y~%int32 bbox_width~%int32 bbox_height~%~%================================================================================~%MSG: geometry_msgs/Pose~%# A representation of pose in free space, composed of position and orientation. ~%Point position~%Quaternion orientation~%~%================================================================================~%MSG: geometry_msgs/Point~%# This contains the position of a point in free space~%float64 x~%float64 y~%float64 z~%~%================================================================================~%MSG: geometry_msgs/Quaternion~%# This represents an orientation in free space in quaternion form.~%~%float64 x~%float64 y~%float64 z~%float64 w~%~%================================================================================~%MSG: geometry_msgs/Vector3~%# This represents a vector in free space. ~%# It is only meant to represent a direction. Therefore, it does not~%# make sense to apply a translation to it (e.g., when applying a ~%# generic rigid transformation to a Vector3, tf2 will only apply the~%# rotation). If you want your data to be translatable too, use the~%# geometry_msgs/Point message instead.~%~%float64 x~%float64 y~%float64 z~%~%"))
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql 'ArmCommand-request)))
  "Returns full string definition for message of type 'ArmCommand-request"
  (cl:format cl:nil "warehouse_sorting_msgs/Cargo cargo~%geometry_msgs/Pose target_pose~%string action~%~%================================================================================~%MSG: warehouse_sorting_msgs/Cargo~%string cargo_id~%string cargo_type~%geometry_msgs/Pose pose~%geometry_msgs/Vector3 size~%float32 volume~%float32 confidence~%int32 bbox_x~%int32 bbox_y~%int32 bbox_width~%int32 bbox_height~%~%================================================================================~%MSG: geometry_msgs/Pose~%# A representation of pose in free space, composed of position and orientation. ~%Point position~%Quaternion orientation~%~%================================================================================~%MSG: geometry_msgs/Point~%# This contains the position of a point in free space~%float64 x~%float64 y~%float64 z~%~%================================================================================~%MSG: geometry_msgs/Quaternion~%# This represents an orientation in free space in quaternion form.~%~%float64 x~%float64 y~%float64 z~%float64 w~%~%================================================================================~%MSG: geometry_msgs/Vector3~%# This represents a vector in free space. ~%# It is only meant to represent a direction. Therefore, it does not~%# make sense to apply a translation to it (e.g., when applying a ~%# generic rigid transformation to a Vector3, tf2 will only apply the~%# rotation). If you want your data to be translatable too, use the~%# geometry_msgs/Point message instead.~%~%float64 x~%float64 y~%float64 z~%~%"))
(cl:defmethod roslisp-msg-protocol:serialization-length ((msg <ArmCommand-request>))
  (cl:+ 0
     (roslisp-msg-protocol:serialization-length (cl:slot-value msg 'cargo))
     (roslisp-msg-protocol:serialization-length (cl:slot-value msg 'target_pose))
     4 (cl:length (cl:slot-value msg 'action))
))
(cl:defmethod roslisp-msg-protocol:ros-message-to-list ((msg <ArmCommand-request>))
  "Converts a ROS message object to a list"
  (cl:list 'ArmCommand-request
    (cl:cons ':cargo (cargo msg))
    (cl:cons ':target_pose (target_pose msg))
    (cl:cons ':action (action msg))
))
;//! \htmlinclude ArmCommand-response.msg.html

(cl:defclass <ArmCommand-response> (roslisp-msg-protocol:ros-message)
  ((success
    :reader success
    :initarg :success
    :type cl:boolean
    :initform cl:nil)
   (message
    :reader message
    :initarg :message
    :type cl:string
    :initform ""))
)

(cl:defclass ArmCommand-response (<ArmCommand-response>)
  ())

(cl:defmethod cl:initialize-instance :after ((m <ArmCommand-response>) cl:&rest args)
  (cl:declare (cl:ignorable args))
  (cl:unless (cl:typep m 'ArmCommand-response)
    (roslisp-msg-protocol:msg-deprecation-warning "using old message class name warehouse_sorting_msgs-srv:<ArmCommand-response> is deprecated: use warehouse_sorting_msgs-srv:ArmCommand-response instead.")))

(cl:ensure-generic-function 'success-val :lambda-list '(m))
(cl:defmethod success-val ((m <ArmCommand-response>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader warehouse_sorting_msgs-srv:success-val is deprecated.  Use warehouse_sorting_msgs-srv:success instead.")
  (success m))

(cl:ensure-generic-function 'message-val :lambda-list '(m))
(cl:defmethod message-val ((m <ArmCommand-response>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader warehouse_sorting_msgs-srv:message-val is deprecated.  Use warehouse_sorting_msgs-srv:message instead.")
  (message m))
(cl:defmethod roslisp-msg-protocol:serialize ((msg <ArmCommand-response>) ostream)
  "Serializes a message object of type '<ArmCommand-response>"
  (cl:write-byte (cl:ldb (cl:byte 8 0) (cl:if (cl:slot-value msg 'success) 1 0)) ostream)
  (cl:let ((__ros_str_len (cl:length (cl:slot-value msg 'message))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) __ros_str_len) ostream))
  (cl:map cl:nil #'(cl:lambda (c) (cl:write-byte (cl:char-code c) ostream)) (cl:slot-value msg 'message))
)
(cl:defmethod roslisp-msg-protocol:deserialize ((msg <ArmCommand-response>) istream)
  "Deserializes a message object of type '<ArmCommand-response>"
    (cl:setf (cl:slot-value msg 'success) (cl:not (cl:zerop (cl:read-byte istream))))
    (cl:let ((__ros_str_len 0))
      (cl:setf (cl:ldb (cl:byte 8 0) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:slot-value msg 'message) (cl:make-string __ros_str_len))
      (cl:dotimes (__ros_str_idx __ros_str_len msg)
        (cl:setf (cl:char (cl:slot-value msg 'message) __ros_str_idx) (cl:code-char (cl:read-byte istream)))))
  msg
)
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql '<ArmCommand-response>)))
  "Returns string type for a service object of type '<ArmCommand-response>"
  "warehouse_sorting_msgs/ArmCommandResponse")
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'ArmCommand-response)))
  "Returns string type for a service object of type 'ArmCommand-response"
  "warehouse_sorting_msgs/ArmCommandResponse")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql '<ArmCommand-response>)))
  "Returns md5sum for a message object of type '<ArmCommand-response>"
  "3846e631ba5aa8597f045fd2ffbc2e9a")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql 'ArmCommand-response)))
  "Returns md5sum for a message object of type 'ArmCommand-response"
  "3846e631ba5aa8597f045fd2ffbc2e9a")
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql '<ArmCommand-response>)))
  "Returns full string definition for message of type '<ArmCommand-response>"
  (cl:format cl:nil "bool success~%string message~%~%~%~%"))
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql 'ArmCommand-response)))
  "Returns full string definition for message of type 'ArmCommand-response"
  (cl:format cl:nil "bool success~%string message~%~%~%~%"))
(cl:defmethod roslisp-msg-protocol:serialization-length ((msg <ArmCommand-response>))
  (cl:+ 0
     1
     4 (cl:length (cl:slot-value msg 'message))
))
(cl:defmethod roslisp-msg-protocol:ros-message-to-list ((msg <ArmCommand-response>))
  "Converts a ROS message object to a list"
  (cl:list 'ArmCommand-response
    (cl:cons ':success (success msg))
    (cl:cons ':message (message msg))
))
(cl:defmethod roslisp-msg-protocol:service-request-type ((msg (cl:eql 'ArmCommand)))
  'ArmCommand-request)
(cl:defmethod roslisp-msg-protocol:service-response-type ((msg (cl:eql 'ArmCommand)))
  'ArmCommand-response)
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'ArmCommand)))
  "Returns string type for a service object of type '<ArmCommand>"
  "warehouse_sorting_msgs/ArmCommand")