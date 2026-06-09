; Auto-generated. Do not edit!


(cl:in-package vizanti-srv)


;//! \htmlinclude ManageNode-request.msg.html

(cl:defclass <ManageNode-request> (roslisp-msg-protocol:ros-message)
  ((node
    :reader node
    :initarg :node
    :type cl:string
    :initform ""))
)

(cl:defclass ManageNode-request (<ManageNode-request>)
  ())

(cl:defmethod cl:initialize-instance :after ((m <ManageNode-request>) cl:&rest args)
  (cl:declare (cl:ignorable args))
  (cl:unless (cl:typep m 'ManageNode-request)
    (roslisp-msg-protocol:msg-deprecation-warning "using old message class name vizanti-srv:<ManageNode-request> is deprecated: use vizanti-srv:ManageNode-request instead.")))

(cl:ensure-generic-function 'node-val :lambda-list '(m))
(cl:defmethod node-val ((m <ManageNode-request>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader vizanti-srv:node-val is deprecated.  Use vizanti-srv:node instead.")
  (node m))
(cl:defmethod roslisp-msg-protocol:serialize ((msg <ManageNode-request>) ostream)
  "Serializes a message object of type '<ManageNode-request>"
  (cl:let ((__ros_str_len (cl:length (cl:slot-value msg 'node))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) __ros_str_len) ostream))
  (cl:map cl:nil #'(cl:lambda (c) (cl:write-byte (cl:char-code c) ostream)) (cl:slot-value msg 'node))
)
(cl:defmethod roslisp-msg-protocol:deserialize ((msg <ManageNode-request>) istream)
  "Deserializes a message object of type '<ManageNode-request>"
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
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql '<ManageNode-request>)))
  "Returns string type for a service object of type '<ManageNode-request>"
  "vizanti/ManageNodeRequest")
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'ManageNode-request)))
  "Returns string type for a service object of type 'ManageNode-request"
  "vizanti/ManageNodeRequest")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql '<ManageNode-request>)))
  "Returns md5sum for a message object of type '<ManageNode-request>"
  "5734ba0301aeb7212e3511ea9c219c42")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql 'ManageNode-request)))
  "Returns md5sum for a message object of type 'ManageNode-request"
  "5734ba0301aeb7212e3511ea9c219c42")
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql '<ManageNode-request>)))
  "Returns full string definition for message of type '<ManageNode-request>"
  (cl:format cl:nil "string node~%~%~%"))
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql 'ManageNode-request)))
  "Returns full string definition for message of type 'ManageNode-request"
  (cl:format cl:nil "string node~%~%~%"))
(cl:defmethod roslisp-msg-protocol:serialization-length ((msg <ManageNode-request>))
  (cl:+ 0
     4 (cl:length (cl:slot-value msg 'node))
))
(cl:defmethod roslisp-msg-protocol:ros-message-to-list ((msg <ManageNode-request>))
  "Converts a ROS message object to a list"
  (cl:list 'ManageNode-request
    (cl:cons ':node (node msg))
))
;//! \htmlinclude ManageNode-response.msg.html

(cl:defclass <ManageNode-response> (roslisp-msg-protocol:ros-message)
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

(cl:defclass ManageNode-response (<ManageNode-response>)
  ())

(cl:defmethod cl:initialize-instance :after ((m <ManageNode-response>) cl:&rest args)
  (cl:declare (cl:ignorable args))
  (cl:unless (cl:typep m 'ManageNode-response)
    (roslisp-msg-protocol:msg-deprecation-warning "using old message class name vizanti-srv:<ManageNode-response> is deprecated: use vizanti-srv:ManageNode-response instead.")))

(cl:ensure-generic-function 'success-val :lambda-list '(m))
(cl:defmethod success-val ((m <ManageNode-response>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader vizanti-srv:success-val is deprecated.  Use vizanti-srv:success instead.")
  (success m))

(cl:ensure-generic-function 'message-val :lambda-list '(m))
(cl:defmethod message-val ((m <ManageNode-response>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader vizanti-srv:message-val is deprecated.  Use vizanti-srv:message instead.")
  (message m))
(cl:defmethod roslisp-msg-protocol:serialize ((msg <ManageNode-response>) ostream)
  "Serializes a message object of type '<ManageNode-response>"
  (cl:write-byte (cl:ldb (cl:byte 8 0) (cl:if (cl:slot-value msg 'success) 1 0)) ostream)
  (cl:let ((__ros_str_len (cl:length (cl:slot-value msg 'message))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) __ros_str_len) ostream))
  (cl:map cl:nil #'(cl:lambda (c) (cl:write-byte (cl:char-code c) ostream)) (cl:slot-value msg 'message))
)
(cl:defmethod roslisp-msg-protocol:deserialize ((msg <ManageNode-response>) istream)
  "Deserializes a message object of type '<ManageNode-response>"
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
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql '<ManageNode-response>)))
  "Returns string type for a service object of type '<ManageNode-response>"
  "vizanti/ManageNodeResponse")
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'ManageNode-response)))
  "Returns string type for a service object of type 'ManageNode-response"
  "vizanti/ManageNodeResponse")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql '<ManageNode-response>)))
  "Returns md5sum for a message object of type '<ManageNode-response>"
  "5734ba0301aeb7212e3511ea9c219c42")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql 'ManageNode-response)))
  "Returns md5sum for a message object of type 'ManageNode-response"
  "5734ba0301aeb7212e3511ea9c219c42")
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql '<ManageNode-response>)))
  "Returns full string definition for message of type '<ManageNode-response>"
  (cl:format cl:nil "bool success~%string message~%~%~%"))
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql 'ManageNode-response)))
  "Returns full string definition for message of type 'ManageNode-response"
  (cl:format cl:nil "bool success~%string message~%~%~%"))
(cl:defmethod roslisp-msg-protocol:serialization-length ((msg <ManageNode-response>))
  (cl:+ 0
     1
     4 (cl:length (cl:slot-value msg 'message))
))
(cl:defmethod roslisp-msg-protocol:ros-message-to-list ((msg <ManageNode-response>))
  "Converts a ROS message object to a list"
  (cl:list 'ManageNode-response
    (cl:cons ':success (success msg))
    (cl:cons ':message (message msg))
))
(cl:defmethod roslisp-msg-protocol:service-request-type ((msg (cl:eql 'ManageNode)))
  'ManageNode-request)
(cl:defmethod roslisp-msg-protocol:service-response-type ((msg (cl:eql 'ManageNode)))
  'ManageNode-response)
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'ManageNode)))
  "Returns string type for a service object of type '<ManageNode>"
  "vizanti/ManageNode")