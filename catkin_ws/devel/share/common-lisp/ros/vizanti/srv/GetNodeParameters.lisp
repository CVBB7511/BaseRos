; Auto-generated. Do not edit!


(cl:in-package vizanti-srv)


;//! \htmlinclude GetNodeParameters-request.msg.html

(cl:defclass <GetNodeParameters-request> (roslisp-msg-protocol:ros-message)
  ((node
    :reader node
    :initarg :node
    :type cl:string
    :initform ""))
)

(cl:defclass GetNodeParameters-request (<GetNodeParameters-request>)
  ())

(cl:defmethod cl:initialize-instance :after ((m <GetNodeParameters-request>) cl:&rest args)
  (cl:declare (cl:ignorable args))
  (cl:unless (cl:typep m 'GetNodeParameters-request)
    (roslisp-msg-protocol:msg-deprecation-warning "using old message class name vizanti-srv:<GetNodeParameters-request> is deprecated: use vizanti-srv:GetNodeParameters-request instead.")))

(cl:ensure-generic-function 'node-val :lambda-list '(m))
(cl:defmethod node-val ((m <GetNodeParameters-request>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader vizanti-srv:node-val is deprecated.  Use vizanti-srv:node instead.")
  (node m))
(cl:defmethod roslisp-msg-protocol:serialize ((msg <GetNodeParameters-request>) ostream)
  "Serializes a message object of type '<GetNodeParameters-request>"
  (cl:let ((__ros_str_len (cl:length (cl:slot-value msg 'node))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) __ros_str_len) ostream))
  (cl:map cl:nil #'(cl:lambda (c) (cl:write-byte (cl:char-code c) ostream)) (cl:slot-value msg 'node))
)
(cl:defmethod roslisp-msg-protocol:deserialize ((msg <GetNodeParameters-request>) istream)
  "Deserializes a message object of type '<GetNodeParameters-request>"
    (cl:let ((__ros_str_len 0))
      (cl:setf (cl:ldb (cl:byte 8 0) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:slot-value msg 'node) (cl:make-string __ros_str_len))
      (cl:dotimes (__ros_str_idx __ros_str_len msg)
        (cl:setf (cl:char (cl:slot-value msg 'node) __ros_str_idx) (cl:code-char (cl:read-byte istream)))))
  msg
)
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql '<GetNodeParameters-request>)))
  "Returns string type for a service object of type '<GetNodeParameters-request>"
  "vizanti/GetNodeParametersRequest")
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'GetNodeParameters-request)))
  "Returns string type for a service object of type 'GetNodeParameters-request"
  "vizanti/GetNodeParametersRequest")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql '<GetNodeParameters-request>)))
  "Returns md5sum for a message object of type '<GetNodeParameters-request>"
  "92c3b11f6b804819c754cc42d5293a0b")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql 'GetNodeParameters-request)))
  "Returns md5sum for a message object of type 'GetNodeParameters-request"
  "92c3b11f6b804819c754cc42d5293a0b")
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql '<GetNodeParameters-request>)))
  "Returns full string definition for message of type '<GetNodeParameters-request>"
  (cl:format cl:nil "string node~%~%~%"))
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql 'GetNodeParameters-request)))
  "Returns full string definition for message of type 'GetNodeParameters-request"
  (cl:format cl:nil "string node~%~%~%"))
(cl:defmethod roslisp-msg-protocol:serialization-length ((msg <GetNodeParameters-request>))
  (cl:+ 0
     4 (cl:length (cl:slot-value msg 'node))
))
(cl:defmethod roslisp-msg-protocol:ros-message-to-list ((msg <GetNodeParameters-request>))
  "Converts a ROS message object to a list"
  (cl:list 'GetNodeParameters-request
    (cl:cons ':node (node msg))
))
;//! \htmlinclude GetNodeParameters-response.msg.html

(cl:defclass <GetNodeParameters-response> (roslisp-msg-protocol:ros-message)
  ((parameters
    :reader parameters
    :initarg :parameters
    :type cl:string
    :initform ""))
)

(cl:defclass GetNodeParameters-response (<GetNodeParameters-response>)
  ())

(cl:defmethod cl:initialize-instance :after ((m <GetNodeParameters-response>) cl:&rest args)
  (cl:declare (cl:ignorable args))
  (cl:unless (cl:typep m 'GetNodeParameters-response)
    (roslisp-msg-protocol:msg-deprecation-warning "using old message class name vizanti-srv:<GetNodeParameters-response> is deprecated: use vizanti-srv:GetNodeParameters-response instead.")))

(cl:ensure-generic-function 'parameters-val :lambda-list '(m))
(cl:defmethod parameters-val ((m <GetNodeParameters-response>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader vizanti-srv:parameters-val is deprecated.  Use vizanti-srv:parameters instead.")
  (parameters m))
(cl:defmethod roslisp-msg-protocol:serialize ((msg <GetNodeParameters-response>) ostream)
  "Serializes a message object of type '<GetNodeParameters-response>"
  (cl:let ((__ros_str_len (cl:length (cl:slot-value msg 'parameters))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) __ros_str_len) ostream))
  (cl:map cl:nil #'(cl:lambda (c) (cl:write-byte (cl:char-code c) ostream)) (cl:slot-value msg 'parameters))
)
(cl:defmethod roslisp-msg-protocol:deserialize ((msg <GetNodeParameters-response>) istream)
  "Deserializes a message object of type '<GetNodeParameters-response>"
    (cl:let ((__ros_str_len 0))
      (cl:setf (cl:ldb (cl:byte 8 0) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:slot-value msg 'parameters) (cl:make-string __ros_str_len))
      (cl:dotimes (__ros_str_idx __ros_str_len msg)
        (cl:setf (cl:char (cl:slot-value msg 'parameters) __ros_str_idx) (cl:code-char (cl:read-byte istream)))))
  msg
)
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql '<GetNodeParameters-response>)))
  "Returns string type for a service object of type '<GetNodeParameters-response>"
  "vizanti/GetNodeParametersResponse")
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'GetNodeParameters-response)))
  "Returns string type for a service object of type 'GetNodeParameters-response"
  "vizanti/GetNodeParametersResponse")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql '<GetNodeParameters-response>)))
  "Returns md5sum for a message object of type '<GetNodeParameters-response>"
  "92c3b11f6b804819c754cc42d5293a0b")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql 'GetNodeParameters-response)))
  "Returns md5sum for a message object of type 'GetNodeParameters-response"
  "92c3b11f6b804819c754cc42d5293a0b")
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql '<GetNodeParameters-response>)))
  "Returns full string definition for message of type '<GetNodeParameters-response>"
  (cl:format cl:nil "string parameters~%~%~%"))
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql 'GetNodeParameters-response)))
  "Returns full string definition for message of type 'GetNodeParameters-response"
  (cl:format cl:nil "string parameters~%~%~%"))
(cl:defmethod roslisp-msg-protocol:serialization-length ((msg <GetNodeParameters-response>))
  (cl:+ 0
     4 (cl:length (cl:slot-value msg 'parameters))
))
(cl:defmethod roslisp-msg-protocol:ros-message-to-list ((msg <GetNodeParameters-response>))
  "Converts a ROS message object to a list"
  (cl:list 'GetNodeParameters-response
    (cl:cons ':parameters (parameters msg))
))
(cl:defmethod roslisp-msg-protocol:service-request-type ((msg (cl:eql 'GetNodeParameters)))
  'GetNodeParameters-request)
(cl:defmethod roslisp-msg-protocol:service-response-type ((msg (cl:eql 'GetNodeParameters)))
  'GetNodeParameters-response)
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'GetNodeParameters)))
  "Returns string type for a service object of type '<GetNodeParameters>"
  "vizanti/GetNodeParameters")