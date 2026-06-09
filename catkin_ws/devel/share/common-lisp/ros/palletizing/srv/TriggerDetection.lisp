; Auto-generated. Do not edit!


(cl:in-package palletizing-srv)


;//! \htmlinclude TriggerDetection-request.msg.html

(cl:defclass <TriggerDetection-request> (roslisp-msg-protocol:ros-message)
  ((cargo_type
    :reader cargo_type
    :initarg :cargo_type
    :type cl:string
    :initform ""))
)

(cl:defclass TriggerDetection-request (<TriggerDetection-request>)
  ())

(cl:defmethod cl:initialize-instance :after ((m <TriggerDetection-request>) cl:&rest args)
  (cl:declare (cl:ignorable args))
  (cl:unless (cl:typep m 'TriggerDetection-request)
    (roslisp-msg-protocol:msg-deprecation-warning "using old message class name palletizing-srv:<TriggerDetection-request> is deprecated: use palletizing-srv:TriggerDetection-request instead.")))

(cl:ensure-generic-function 'cargo_type-val :lambda-list '(m))
(cl:defmethod cargo_type-val ((m <TriggerDetection-request>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader palletizing-srv:cargo_type-val is deprecated.  Use palletizing-srv:cargo_type instead.")
  (cargo_type m))
(cl:defmethod roslisp-msg-protocol:serialize ((msg <TriggerDetection-request>) ostream)
  "Serializes a message object of type '<TriggerDetection-request>"
  (cl:let ((__ros_str_len (cl:length (cl:slot-value msg 'cargo_type))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) __ros_str_len) ostream))
  (cl:map cl:nil #'(cl:lambda (c) (cl:write-byte (cl:char-code c) ostream)) (cl:slot-value msg 'cargo_type))
)
(cl:defmethod roslisp-msg-protocol:deserialize ((msg <TriggerDetection-request>) istream)
  "Deserializes a message object of type '<TriggerDetection-request>"
    (cl:let ((__ros_str_len 0))
      (cl:setf (cl:ldb (cl:byte 8 0) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:slot-value msg 'cargo_type) (cl:make-string __ros_str_len))
      (cl:dotimes (__ros_str_idx __ros_str_len msg)
        (cl:setf (cl:char (cl:slot-value msg 'cargo_type) __ros_str_idx) (cl:code-char (cl:read-byte istream)))))
  msg
)
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql '<TriggerDetection-request>)))
  "Returns string type for a service object of type '<TriggerDetection-request>"
  "palletizing/TriggerDetectionRequest")
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'TriggerDetection-request)))
  "Returns string type for a service object of type 'TriggerDetection-request"
  "palletizing/TriggerDetectionRequest")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql '<TriggerDetection-request>)))
  "Returns md5sum for a message object of type '<TriggerDetection-request>"
  "36866cc854ee48ffadf2fd965e06457e")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql 'TriggerDetection-request)))
  "Returns md5sum for a message object of type 'TriggerDetection-request"
  "36866cc854ee48ffadf2fd965e06457e")
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql '<TriggerDetection-request>)))
  "Returns full string definition for message of type '<TriggerDetection-request>"
  (cl:format cl:nil "# 触发单次视觉识别服务~%# 请求：货物类型~%string cargo_type~%~%~%"))
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql 'TriggerDetection-request)))
  "Returns full string definition for message of type 'TriggerDetection-request"
  (cl:format cl:nil "# 触发单次视觉识别服务~%# 请求：货物类型~%string cargo_type~%~%~%"))
(cl:defmethod roslisp-msg-protocol:serialization-length ((msg <TriggerDetection-request>))
  (cl:+ 0
     4 (cl:length (cl:slot-value msg 'cargo_type))
))
(cl:defmethod roslisp-msg-protocol:ros-message-to-list ((msg <TriggerDetection-request>))
  "Converts a ROS message object to a list"
  (cl:list 'TriggerDetection-request
    (cl:cons ':cargo_type (cargo_type msg))
))
;//! \htmlinclude TriggerDetection-response.msg.html

(cl:defclass <TriggerDetection-response> (roslisp-msg-protocol:ros-message)
  ((success
    :reader success
    :initarg :success
    :type cl:boolean
    :initform cl:nil)
   (message
    :reader message
    :initarg :message
    :type cl:string
    :initform "")
   (position
    :reader position
    :initarg :position
    :type geometry_msgs-msg:Point
    :initform (cl:make-instance 'geometry_msgs-msg:Point))
   (remaining_count
    :reader remaining_count
    :initarg :remaining_count
    :type cl:integer
    :initform 0))
)

(cl:defclass TriggerDetection-response (<TriggerDetection-response>)
  ())

(cl:defmethod cl:initialize-instance :after ((m <TriggerDetection-response>) cl:&rest args)
  (cl:declare (cl:ignorable args))
  (cl:unless (cl:typep m 'TriggerDetection-response)
    (roslisp-msg-protocol:msg-deprecation-warning "using old message class name palletizing-srv:<TriggerDetection-response> is deprecated: use palletizing-srv:TriggerDetection-response instead.")))

(cl:ensure-generic-function 'success-val :lambda-list '(m))
(cl:defmethod success-val ((m <TriggerDetection-response>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader palletizing-srv:success-val is deprecated.  Use palletizing-srv:success instead.")
  (success m))

(cl:ensure-generic-function 'message-val :lambda-list '(m))
(cl:defmethod message-val ((m <TriggerDetection-response>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader palletizing-srv:message-val is deprecated.  Use palletizing-srv:message instead.")
  (message m))

(cl:ensure-generic-function 'position-val :lambda-list '(m))
(cl:defmethod position-val ((m <TriggerDetection-response>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader palletizing-srv:position-val is deprecated.  Use palletizing-srv:position instead.")
  (position m))

(cl:ensure-generic-function 'remaining_count-val :lambda-list '(m))
(cl:defmethod remaining_count-val ((m <TriggerDetection-response>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader palletizing-srv:remaining_count-val is deprecated.  Use palletizing-srv:remaining_count instead.")
  (remaining_count m))
(cl:defmethod roslisp-msg-protocol:serialize ((msg <TriggerDetection-response>) ostream)
  "Serializes a message object of type '<TriggerDetection-response>"
  (cl:write-byte (cl:ldb (cl:byte 8 0) (cl:if (cl:slot-value msg 'success) 1 0)) ostream)
  (cl:let ((__ros_str_len (cl:length (cl:slot-value msg 'message))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) __ros_str_len) ostream))
  (cl:map cl:nil #'(cl:lambda (c) (cl:write-byte (cl:char-code c) ostream)) (cl:slot-value msg 'message))
  (roslisp-msg-protocol:serialize (cl:slot-value msg 'position) ostream)
  (cl:let* ((signed (cl:slot-value msg 'remaining_count)) (unsigned (cl:if (cl:< signed 0) (cl:+ signed 4294967296) signed)))
    (cl:write-byte (cl:ldb (cl:byte 8 0) unsigned) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) unsigned) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) unsigned) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) unsigned) ostream)
    )
)
(cl:defmethod roslisp-msg-protocol:deserialize ((msg <TriggerDetection-response>) istream)
  "Deserializes a message object of type '<TriggerDetection-response>"
    (cl:setf (cl:slot-value msg 'success) (cl:not (cl:zerop (cl:read-byte istream))))
    (cl:let ((__ros_str_len 0))
      (cl:setf (cl:ldb (cl:byte 8 0) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:slot-value msg 'message) (cl:make-string __ros_str_len))
      (cl:dotimes (__ros_str_idx __ros_str_len msg)
        (cl:setf (cl:char (cl:slot-value msg 'message) __ros_str_idx) (cl:code-char (cl:read-byte istream)))))
  (roslisp-msg-protocol:deserialize (cl:slot-value msg 'position) istream)
    (cl:let ((unsigned 0))
      (cl:setf (cl:ldb (cl:byte 8 0) unsigned) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) unsigned) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) unsigned) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) unsigned) (cl:read-byte istream))
      (cl:setf (cl:slot-value msg 'remaining_count) (cl:if (cl:< unsigned 2147483648) unsigned (cl:- unsigned 4294967296))))
  msg
)
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql '<TriggerDetection-response>)))
  "Returns string type for a service object of type '<TriggerDetection-response>"
  "palletizing/TriggerDetectionResponse")
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'TriggerDetection-response)))
  "Returns string type for a service object of type 'TriggerDetection-response"
  "palletizing/TriggerDetectionResponse")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql '<TriggerDetection-response>)))
  "Returns md5sum for a message object of type '<TriggerDetection-response>"
  "36866cc854ee48ffadf2fd965e06457e")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql 'TriggerDetection-response)))
  "Returns md5sum for a message object of type 'TriggerDetection-response"
  "36866cc854ee48ffadf2fd965e06457e")
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql '<TriggerDetection-response>)))
  "Returns full string definition for message of type '<TriggerDetection-response>"
  (cl:format cl:nil "# 响应：是否成功、目标在 base_link 坐标系下的三维坐标~%bool success~%string message~%geometry_msgs/Point position~%int32 remaining_count~%~%~%================================================================================~%MSG: geometry_msgs/Point~%# This contains the position of a point in free space~%float64 x~%float64 y~%float64 z~%~%~%"))
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql 'TriggerDetection-response)))
  "Returns full string definition for message of type 'TriggerDetection-response"
  (cl:format cl:nil "# 响应：是否成功、目标在 base_link 坐标系下的三维坐标~%bool success~%string message~%geometry_msgs/Point position~%int32 remaining_count~%~%~%================================================================================~%MSG: geometry_msgs/Point~%# This contains the position of a point in free space~%float64 x~%float64 y~%float64 z~%~%~%"))
(cl:defmethod roslisp-msg-protocol:serialization-length ((msg <TriggerDetection-response>))
  (cl:+ 0
     1
     4 (cl:length (cl:slot-value msg 'message))
     (roslisp-msg-protocol:serialization-length (cl:slot-value msg 'position))
     4
))
(cl:defmethod roslisp-msg-protocol:ros-message-to-list ((msg <TriggerDetection-response>))
  "Converts a ROS message object to a list"
  (cl:list 'TriggerDetection-response
    (cl:cons ':success (success msg))
    (cl:cons ':message (message msg))
    (cl:cons ':position (position msg))
    (cl:cons ':remaining_count (remaining_count msg))
))
(cl:defmethod roslisp-msg-protocol:service-request-type ((msg (cl:eql 'TriggerDetection)))
  'TriggerDetection-request)
(cl:defmethod roslisp-msg-protocol:service-response-type ((msg (cl:eql 'TriggerDetection)))
  'TriggerDetection-response)
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'TriggerDetection)))
  "Returns string type for a service object of type '<TriggerDetection>"
  "palletizing/TriggerDetection")