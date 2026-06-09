; Auto-generated. Do not edit!


(cl:in-package palletizing-srv)


;//! \htmlinclude SystemReset-request.msg.html

(cl:defclass <SystemReset-request> (roslisp-msg-protocol:ros-message)
  ()
)

(cl:defclass SystemReset-request (<SystemReset-request>)
  ())

(cl:defmethod cl:initialize-instance :after ((m <SystemReset-request>) cl:&rest args)
  (cl:declare (cl:ignorable args))
  (cl:unless (cl:typep m 'SystemReset-request)
    (roslisp-msg-protocol:msg-deprecation-warning "using old message class name palletizing-srv:<SystemReset-request> is deprecated: use palletizing-srv:SystemReset-request instead.")))
(cl:defmethod roslisp-msg-protocol:serialize ((msg <SystemReset-request>) ostream)
  "Serializes a message object of type '<SystemReset-request>"
)
(cl:defmethod roslisp-msg-protocol:deserialize ((msg <SystemReset-request>) istream)
  "Deserializes a message object of type '<SystemReset-request>"
  msg
)
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql '<SystemReset-request>)))
  "Returns string type for a service object of type '<SystemReset-request>"
  "palletizing/SystemResetRequest")
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'SystemReset-request)))
  "Returns string type for a service object of type 'SystemReset-request"
  "palletizing/SystemResetRequest")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql '<SystemReset-request>)))
  "Returns md5sum for a message object of type '<SystemReset-request>"
  "937c9679a518e3a18d831e57125ea522")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql 'SystemReset-request)))
  "Returns md5sum for a message object of type 'SystemReset-request"
  "937c9679a518e3a18d831e57125ea522")
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql '<SystemReset-request>)))
  "Returns full string definition for message of type '<SystemReset-request>"
  (cl:format cl:nil "# 系统复位服务~%# 请求：无~%~%~%"))
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql 'SystemReset-request)))
  "Returns full string definition for message of type 'SystemReset-request"
  (cl:format cl:nil "# 系统复位服务~%# 请求：无~%~%~%"))
(cl:defmethod roslisp-msg-protocol:serialization-length ((msg <SystemReset-request>))
  (cl:+ 0
))
(cl:defmethod roslisp-msg-protocol:ros-message-to-list ((msg <SystemReset-request>))
  "Converts a ROS message object to a list"
  (cl:list 'SystemReset-request
))
;//! \htmlinclude SystemReset-response.msg.html

(cl:defclass <SystemReset-response> (roslisp-msg-protocol:ros-message)
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

(cl:defclass SystemReset-response (<SystemReset-response>)
  ())

(cl:defmethod cl:initialize-instance :after ((m <SystemReset-response>) cl:&rest args)
  (cl:declare (cl:ignorable args))
  (cl:unless (cl:typep m 'SystemReset-response)
    (roslisp-msg-protocol:msg-deprecation-warning "using old message class name palletizing-srv:<SystemReset-response> is deprecated: use palletizing-srv:SystemReset-response instead.")))

(cl:ensure-generic-function 'success-val :lambda-list '(m))
(cl:defmethod success-val ((m <SystemReset-response>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader palletizing-srv:success-val is deprecated.  Use palletizing-srv:success instead.")
  (success m))

(cl:ensure-generic-function 'message-val :lambda-list '(m))
(cl:defmethod message-val ((m <SystemReset-response>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader palletizing-srv:message-val is deprecated.  Use palletizing-srv:message instead.")
  (message m))
(cl:defmethod roslisp-msg-protocol:serialize ((msg <SystemReset-response>) ostream)
  "Serializes a message object of type '<SystemReset-response>"
  (cl:write-byte (cl:ldb (cl:byte 8 0) (cl:if (cl:slot-value msg 'success) 1 0)) ostream)
  (cl:let ((__ros_str_len (cl:length (cl:slot-value msg 'message))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) __ros_str_len) ostream))
  (cl:map cl:nil #'(cl:lambda (c) (cl:write-byte (cl:char-code c) ostream)) (cl:slot-value msg 'message))
)
(cl:defmethod roslisp-msg-protocol:deserialize ((msg <SystemReset-response>) istream)
  "Deserializes a message object of type '<SystemReset-response>"
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
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql '<SystemReset-response>)))
  "Returns string type for a service object of type '<SystemReset-response>"
  "palletizing/SystemResetResponse")
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'SystemReset-response)))
  "Returns string type for a service object of type 'SystemReset-response"
  "palletizing/SystemResetResponse")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql '<SystemReset-response>)))
  "Returns md5sum for a message object of type '<SystemReset-response>"
  "937c9679a518e3a18d831e57125ea522")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql 'SystemReset-response)))
  "Returns md5sum for a message object of type 'SystemReset-response"
  "937c9679a518e3a18d831e57125ea522")
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql '<SystemReset-response>)))
  "Returns full string definition for message of type '<SystemReset-response>"
  (cl:format cl:nil "# 响应：是否成功~%bool success~%string message~%~%~%~%"))
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql 'SystemReset-response)))
  "Returns full string definition for message of type 'SystemReset-response"
  (cl:format cl:nil "# 响应：是否成功~%bool success~%string message~%~%~%~%"))
(cl:defmethod roslisp-msg-protocol:serialization-length ((msg <SystemReset-response>))
  (cl:+ 0
     1
     4 (cl:length (cl:slot-value msg 'message))
))
(cl:defmethod roslisp-msg-protocol:ros-message-to-list ((msg <SystemReset-response>))
  "Converts a ROS message object to a list"
  (cl:list 'SystemReset-response
    (cl:cons ':success (success msg))
    (cl:cons ':message (message msg))
))
(cl:defmethod roslisp-msg-protocol:service-request-type ((msg (cl:eql 'SystemReset)))
  'SystemReset-request)
(cl:defmethod roslisp-msg-protocol:service-response-type ((msg (cl:eql 'SystemReset)))
  'SystemReset-response)
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'SystemReset)))
  "Returns string type for a service object of type '<SystemReset>"
  "palletizing/SystemReset")