; Auto-generated. Do not edit!


(cl:in-package navigation-srv)


;//! \htmlinclude Halt-request.msg.html

(cl:defclass <Halt-request> (roslisp-msg-protocol:ros-message)
  ()
)

(cl:defclass Halt-request (<Halt-request>)
  ())

(cl:defmethod cl:initialize-instance :after ((m <Halt-request>) cl:&rest args)
  (cl:declare (cl:ignorable args))
  (cl:unless (cl:typep m 'Halt-request)
    (roslisp-msg-protocol:msg-deprecation-warning "using old message class name navigation-srv:<Halt-request> is deprecated: use navigation-srv:Halt-request instead.")))
(cl:defmethod roslisp-msg-protocol:serialize ((msg <Halt-request>) ostream)
  "Serializes a message object of type '<Halt-request>"
)
(cl:defmethod roslisp-msg-protocol:deserialize ((msg <Halt-request>) istream)
  "Deserializes a message object of type '<Halt-request>"
  msg
)
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql '<Halt-request>)))
  "Returns string type for a service object of type '<Halt-request>"
  "navigation/HaltRequest")
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'Halt-request)))
  "Returns string type for a service object of type 'Halt-request"
  "navigation/HaltRequest")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql '<Halt-request>)))
  "Returns md5sum for a message object of type '<Halt-request>"
  "937c9679a518e3a18d831e57125ea522")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql 'Halt-request)))
  "Returns md5sum for a message object of type 'Halt-request"
  "937c9679a518e3a18d831e57125ea522")
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql '<Halt-request>)))
  "Returns full string definition for message of type '<Halt-request>"
  (cl:format cl:nil "~%~%"))
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql 'Halt-request)))
  "Returns full string definition for message of type 'Halt-request"
  (cl:format cl:nil "~%~%"))
(cl:defmethod roslisp-msg-protocol:serialization-length ((msg <Halt-request>))
  (cl:+ 0
))
(cl:defmethod roslisp-msg-protocol:ros-message-to-list ((msg <Halt-request>))
  "Converts a ROS message object to a list"
  (cl:list 'Halt-request
))
;//! \htmlinclude Halt-response.msg.html

(cl:defclass <Halt-response> (roslisp-msg-protocol:ros-message)
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

(cl:defclass Halt-response (<Halt-response>)
  ())

(cl:defmethod cl:initialize-instance :after ((m <Halt-response>) cl:&rest args)
  (cl:declare (cl:ignorable args))
  (cl:unless (cl:typep m 'Halt-response)
    (roslisp-msg-protocol:msg-deprecation-warning "using old message class name navigation-srv:<Halt-response> is deprecated: use navigation-srv:Halt-response instead.")))

(cl:ensure-generic-function 'success-val :lambda-list '(m))
(cl:defmethod success-val ((m <Halt-response>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader navigation-srv:success-val is deprecated.  Use navigation-srv:success instead.")
  (success m))

(cl:ensure-generic-function 'message-val :lambda-list '(m))
(cl:defmethod message-val ((m <Halt-response>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader navigation-srv:message-val is deprecated.  Use navigation-srv:message instead.")
  (message m))
(cl:defmethod roslisp-msg-protocol:serialize ((msg <Halt-response>) ostream)
  "Serializes a message object of type '<Halt-response>"
  (cl:write-byte (cl:ldb (cl:byte 8 0) (cl:if (cl:slot-value msg 'success) 1 0)) ostream)
  (cl:let ((__ros_str_len (cl:length (cl:slot-value msg 'message))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) __ros_str_len) ostream))
  (cl:map cl:nil #'(cl:lambda (c) (cl:write-byte (cl:char-code c) ostream)) (cl:slot-value msg 'message))
)
(cl:defmethod roslisp-msg-protocol:deserialize ((msg <Halt-response>) istream)
  "Deserializes a message object of type '<Halt-response>"
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
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql '<Halt-response>)))
  "Returns string type for a service object of type '<Halt-response>"
  "navigation/HaltResponse")
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'Halt-response)))
  "Returns string type for a service object of type 'Halt-response"
  "navigation/HaltResponse")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql '<Halt-response>)))
  "Returns md5sum for a message object of type '<Halt-response>"
  "937c9679a518e3a18d831e57125ea522")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql 'Halt-response)))
  "Returns md5sum for a message object of type 'Halt-response"
  "937c9679a518e3a18d831e57125ea522")
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql '<Halt-response>)))
  "Returns full string definition for message of type '<Halt-response>"
  (cl:format cl:nil "bool success~%string message~%~%~%"))
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql 'Halt-response)))
  "Returns full string definition for message of type 'Halt-response"
  (cl:format cl:nil "bool success~%string message~%~%~%"))
(cl:defmethod roslisp-msg-protocol:serialization-length ((msg <Halt-response>))
  (cl:+ 0
     1
     4 (cl:length (cl:slot-value msg 'message))
))
(cl:defmethod roslisp-msg-protocol:ros-message-to-list ((msg <Halt-response>))
  "Converts a ROS message object to a list"
  (cl:list 'Halt-response
    (cl:cons ':success (success msg))
    (cl:cons ':message (message msg))
))
(cl:defmethod roslisp-msg-protocol:service-request-type ((msg (cl:eql 'Halt)))
  'Halt-request)
(cl:defmethod roslisp-msg-protocol:service-response-type ((msg (cl:eql 'Halt)))
  'Halt-response)
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'Halt)))
  "Returns string type for a service object of type '<Halt>"
  "navigation/Halt")