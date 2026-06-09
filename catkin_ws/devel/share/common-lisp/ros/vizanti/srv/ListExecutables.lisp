; Auto-generated. Do not edit!


(cl:in-package vizanti-srv)


;//! \htmlinclude ListExecutables-request.msg.html

(cl:defclass <ListExecutables-request> (roslisp-msg-protocol:ros-message)
  ((package
    :reader package
    :initarg :package
    :type cl:string
    :initform ""))
)

(cl:defclass ListExecutables-request (<ListExecutables-request>)
  ())

(cl:defmethod cl:initialize-instance :after ((m <ListExecutables-request>) cl:&rest args)
  (cl:declare (cl:ignorable args))
  (cl:unless (cl:typep m 'ListExecutables-request)
    (roslisp-msg-protocol:msg-deprecation-warning "using old message class name vizanti-srv:<ListExecutables-request> is deprecated: use vizanti-srv:ListExecutables-request instead.")))

(cl:ensure-generic-function 'package-val :lambda-list '(m))
(cl:defmethod package-val ((m <ListExecutables-request>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader vizanti-srv:package-val is deprecated.  Use vizanti-srv:package instead.")
  (package m))
(cl:defmethod roslisp-msg-protocol:serialize ((msg <ListExecutables-request>) ostream)
  "Serializes a message object of type '<ListExecutables-request>"
  (cl:let ((__ros_str_len (cl:length (cl:slot-value msg 'package))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) __ros_str_len) ostream))
  (cl:map cl:nil #'(cl:lambda (c) (cl:write-byte (cl:char-code c) ostream)) (cl:slot-value msg 'package))
)
(cl:defmethod roslisp-msg-protocol:deserialize ((msg <ListExecutables-request>) istream)
  "Deserializes a message object of type '<ListExecutables-request>"
    (cl:let ((__ros_str_len 0))
      (cl:setf (cl:ldb (cl:byte 8 0) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:slot-value msg 'package) (cl:make-string __ros_str_len))
      (cl:dotimes (__ros_str_idx __ros_str_len msg)
        (cl:setf (cl:char (cl:slot-value msg 'package) __ros_str_idx) (cl:code-char (cl:read-byte istream)))))
  msg
)
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql '<ListExecutables-request>)))
  "Returns string type for a service object of type '<ListExecutables-request>"
  "vizanti/ListExecutablesRequest")
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'ListExecutables-request)))
  "Returns string type for a service object of type 'ListExecutables-request"
  "vizanti/ListExecutablesRequest")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql '<ListExecutables-request>)))
  "Returns md5sum for a message object of type '<ListExecutables-request>"
  "0d9dadc8a6139fd3d3c4c0b768c8f47c")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql 'ListExecutables-request)))
  "Returns md5sum for a message object of type 'ListExecutables-request"
  "0d9dadc8a6139fd3d3c4c0b768c8f47c")
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql '<ListExecutables-request>)))
  "Returns full string definition for message of type '<ListExecutables-request>"
  (cl:format cl:nil "string package~%~%~%"))
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql 'ListExecutables-request)))
  "Returns full string definition for message of type 'ListExecutables-request"
  (cl:format cl:nil "string package~%~%~%"))
(cl:defmethod roslisp-msg-protocol:serialization-length ((msg <ListExecutables-request>))
  (cl:+ 0
     4 (cl:length (cl:slot-value msg 'package))
))
(cl:defmethod roslisp-msg-protocol:ros-message-to-list ((msg <ListExecutables-request>))
  "Converts a ROS message object to a list"
  (cl:list 'ListExecutables-request
    (cl:cons ':package (package msg))
))
;//! \htmlinclude ListExecutables-response.msg.html

(cl:defclass <ListExecutables-response> (roslisp-msg-protocol:ros-message)
  ((executables
    :reader executables
    :initarg :executables
    :type (cl:vector cl:string)
   :initform (cl:make-array 0 :element-type 'cl:string :initial-element "")))
)

(cl:defclass ListExecutables-response (<ListExecutables-response>)
  ())

(cl:defmethod cl:initialize-instance :after ((m <ListExecutables-response>) cl:&rest args)
  (cl:declare (cl:ignorable args))
  (cl:unless (cl:typep m 'ListExecutables-response)
    (roslisp-msg-protocol:msg-deprecation-warning "using old message class name vizanti-srv:<ListExecutables-response> is deprecated: use vizanti-srv:ListExecutables-response instead.")))

(cl:ensure-generic-function 'executables-val :lambda-list '(m))
(cl:defmethod executables-val ((m <ListExecutables-response>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader vizanti-srv:executables-val is deprecated.  Use vizanti-srv:executables instead.")
  (executables m))
(cl:defmethod roslisp-msg-protocol:serialize ((msg <ListExecutables-response>) ostream)
  "Serializes a message object of type '<ListExecutables-response>"
  (cl:let ((__ros_arr_len (cl:length (cl:slot-value msg 'executables))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) __ros_arr_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) __ros_arr_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) __ros_arr_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) __ros_arr_len) ostream))
  (cl:map cl:nil #'(cl:lambda (ele) (cl:let ((__ros_str_len (cl:length ele)))
    (cl:write-byte (cl:ldb (cl:byte 8 0) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) __ros_str_len) ostream))
  (cl:map cl:nil #'(cl:lambda (c) (cl:write-byte (cl:char-code c) ostream)) ele))
   (cl:slot-value msg 'executables))
)
(cl:defmethod roslisp-msg-protocol:deserialize ((msg <ListExecutables-response>) istream)
  "Deserializes a message object of type '<ListExecutables-response>"
  (cl:let ((__ros_arr_len 0))
    (cl:setf (cl:ldb (cl:byte 8 0) __ros_arr_len) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 8) __ros_arr_len) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 16) __ros_arr_len) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 24) __ros_arr_len) (cl:read-byte istream))
  (cl:setf (cl:slot-value msg 'executables) (cl:make-array __ros_arr_len))
  (cl:let ((vals (cl:slot-value msg 'executables)))
    (cl:dotimes (i __ros_arr_len)
    (cl:let ((__ros_str_len 0))
      (cl:setf (cl:ldb (cl:byte 8 0) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:aref vals i) (cl:make-string __ros_str_len))
      (cl:dotimes (__ros_str_idx __ros_str_len msg)
        (cl:setf (cl:char (cl:aref vals i) __ros_str_idx) (cl:code-char (cl:read-byte istream))))))))
  msg
)
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql '<ListExecutables-response>)))
  "Returns string type for a service object of type '<ListExecutables-response>"
  "vizanti/ListExecutablesResponse")
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'ListExecutables-response)))
  "Returns string type for a service object of type 'ListExecutables-response"
  "vizanti/ListExecutablesResponse")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql '<ListExecutables-response>)))
  "Returns md5sum for a message object of type '<ListExecutables-response>"
  "0d9dadc8a6139fd3d3c4c0b768c8f47c")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql 'ListExecutables-response)))
  "Returns md5sum for a message object of type 'ListExecutables-response"
  "0d9dadc8a6139fd3d3c4c0b768c8f47c")
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql '<ListExecutables-response>)))
  "Returns full string definition for message of type '<ListExecutables-response>"
  (cl:format cl:nil "string[] executables ~%~%~%~%"))
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql 'ListExecutables-response)))
  "Returns full string definition for message of type 'ListExecutables-response"
  (cl:format cl:nil "string[] executables ~%~%~%~%"))
(cl:defmethod roslisp-msg-protocol:serialization-length ((msg <ListExecutables-response>))
  (cl:+ 0
     4 (cl:reduce #'cl:+ (cl:slot-value msg 'executables) :key #'(cl:lambda (ele) (cl:declare (cl:ignorable ele)) (cl:+ 4 (cl:length ele))))
))
(cl:defmethod roslisp-msg-protocol:ros-message-to-list ((msg <ListExecutables-response>))
  "Converts a ROS message object to a list"
  (cl:list 'ListExecutables-response
    (cl:cons ':executables (executables msg))
))
(cl:defmethod roslisp-msg-protocol:service-request-type ((msg (cl:eql 'ListExecutables)))
  'ListExecutables-request)
(cl:defmethod roslisp-msg-protocol:service-response-type ((msg (cl:eql 'ListExecutables)))
  'ListExecutables-response)
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'ListExecutables)))
  "Returns string type for a service object of type '<ListExecutables>"
  "vizanti/ListExecutables")