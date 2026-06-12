; Auto-generated. Do not edit!


(cl:in-package palletizing-srv)


;//! \htmlinclude StartTask-request.msg.html

(cl:defclass <StartTask-request> (roslisp-msg-protocol:ros-message)
  ()
)

(cl:defclass StartTask-request (<StartTask-request>)
  ())

(cl:defmethod cl:initialize-instance :after ((m <StartTask-request>) cl:&rest args)
  (cl:declare (cl:ignorable args))
  (cl:unless (cl:typep m 'StartTask-request)
    (roslisp-msg-protocol:msg-deprecation-warning "using old message class name palletizing-srv:<StartTask-request> is deprecated: use palletizing-srv:StartTask-request instead.")))
(cl:defmethod roslisp-msg-protocol:serialize ((msg <StartTask-request>) ostream)
  "Serializes a message object of type '<StartTask-request>"
)
(cl:defmethod roslisp-msg-protocol:deserialize ((msg <StartTask-request>) istream)
  "Deserializes a message object of type '<StartTask-request>"
  msg
)
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql '<StartTask-request>)))
  "Returns string type for a service object of type '<StartTask-request>"
  "palletizing/StartTaskRequest")
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'StartTask-request)))
  "Returns string type for a service object of type 'StartTask-request"
  "palletizing/StartTaskRequest")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql '<StartTask-request>)))
  "Returns md5sum for a message object of type '<StartTask-request>"
  "937c9679a518e3a18d831e57125ea522")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql 'StartTask-request)))
  "Returns md5sum for a message object of type 'StartTask-request"
  "937c9679a518e3a18d831e57125ea522")
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql '<StartTask-request>)))
  "Returns full string definition for message of type '<StartTask-request>"
  (cl:format cl:nil "~%~%"))
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql 'StartTask-request)))
  "Returns full string definition for message of type 'StartTask-request"
  (cl:format cl:nil "~%~%"))
(cl:defmethod roslisp-msg-protocol:serialization-length ((msg <StartTask-request>))
  (cl:+ 0
))
(cl:defmethod roslisp-msg-protocol:ros-message-to-list ((msg <StartTask-request>))
  "Converts a ROS message object to a list"
  (cl:list 'StartTask-request
))
;//! \htmlinclude StartTask-response.msg.html

(cl:defclass <StartTask-response> (roslisp-msg-protocol:ros-message)
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

(cl:defclass StartTask-response (<StartTask-response>)
  ())

(cl:defmethod cl:initialize-instance :after ((m <StartTask-response>) cl:&rest args)
  (cl:declare (cl:ignorable args))
  (cl:unless (cl:typep m 'StartTask-response)
    (roslisp-msg-protocol:msg-deprecation-warning "using old message class name palletizing-srv:<StartTask-response> is deprecated: use palletizing-srv:StartTask-response instead.")))

(cl:ensure-generic-function 'success-val :lambda-list '(m))
(cl:defmethod success-val ((m <StartTask-response>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader palletizing-srv:success-val is deprecated.  Use palletizing-srv:success instead.")
  (success m))

(cl:ensure-generic-function 'message-val :lambda-list '(m))
(cl:defmethod message-val ((m <StartTask-response>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader palletizing-srv:message-val is deprecated.  Use palletizing-srv:message instead.")
  (message m))
(cl:defmethod roslisp-msg-protocol:serialize ((msg <StartTask-response>) ostream)
  "Serializes a message object of type '<StartTask-response>"
  (cl:write-byte (cl:ldb (cl:byte 8 0) (cl:if (cl:slot-value msg 'success) 1 0)) ostream)
  (cl:let ((__ros_str_len (cl:length (cl:slot-value msg 'message))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) __ros_str_len) ostream))
  (cl:map cl:nil #'(cl:lambda (c) (cl:write-byte (cl:char-code c) ostream)) (cl:slot-value msg 'message))
)
(cl:defmethod roslisp-msg-protocol:deserialize ((msg <StartTask-response>) istream)
  "Deserializes a message object of type '<StartTask-response>"
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
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql '<StartTask-response>)))
  "Returns string type for a service object of type '<StartTask-response>"
  "palletizing/StartTaskResponse")
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'StartTask-response)))
  "Returns string type for a service object of type 'StartTask-response"
  "palletizing/StartTaskResponse")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql '<StartTask-response>)))
  "Returns md5sum for a message object of type '<StartTask-response>"
  "937c9679a518e3a18d831e57125ea522")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql 'StartTask-response)))
  "Returns md5sum for a message object of type 'StartTask-response"
  "937c9679a518e3a18d831e57125ea522")
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql '<StartTask-response>)))
  "Returns full string definition for message of type '<StartTask-response>"
  (cl:format cl:nil "bool success~%string message~%~%~%~%"))
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql 'StartTask-response)))
  "Returns full string definition for message of type 'StartTask-response"
  (cl:format cl:nil "bool success~%string message~%~%~%~%"))
(cl:defmethod roslisp-msg-protocol:serialization-length ((msg <StartTask-response>))
  (cl:+ 0
     1
     4 (cl:length (cl:slot-value msg 'message))
))
(cl:defmethod roslisp-msg-protocol:ros-message-to-list ((msg <StartTask-response>))
  "Converts a ROS message object to a list"
  (cl:list 'StartTask-response
    (cl:cons ':success (success msg))
    (cl:cons ':message (message msg))
))
(cl:defmethod roslisp-msg-protocol:service-request-type ((msg (cl:eql 'StartTask)))
  'StartTask-request)
(cl:defmethod roslisp-msg-protocol:service-response-type ((msg (cl:eql 'StartTask)))
  'StartTask-response)
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'StartTask)))
  "Returns string type for a service object of type '<StartTask>"
  "palletizing/StartTask")