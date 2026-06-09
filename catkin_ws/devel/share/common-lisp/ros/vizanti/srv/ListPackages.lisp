; Auto-generated. Do not edit!


(cl:in-package vizanti-srv)


;//! \htmlinclude ListPackages-request.msg.html

(cl:defclass <ListPackages-request> (roslisp-msg-protocol:ros-message)
  ()
)

(cl:defclass ListPackages-request (<ListPackages-request>)
  ())

(cl:defmethod cl:initialize-instance :after ((m <ListPackages-request>) cl:&rest args)
  (cl:declare (cl:ignorable args))
  (cl:unless (cl:typep m 'ListPackages-request)
    (roslisp-msg-protocol:msg-deprecation-warning "using old message class name vizanti-srv:<ListPackages-request> is deprecated: use vizanti-srv:ListPackages-request instead.")))
(cl:defmethod roslisp-msg-protocol:serialize ((msg <ListPackages-request>) ostream)
  "Serializes a message object of type '<ListPackages-request>"
)
(cl:defmethod roslisp-msg-protocol:deserialize ((msg <ListPackages-request>) istream)
  "Deserializes a message object of type '<ListPackages-request>"
  msg
)
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql '<ListPackages-request>)))
  "Returns string type for a service object of type '<ListPackages-request>"
  "vizanti/ListPackagesRequest")
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'ListPackages-request)))
  "Returns string type for a service object of type 'ListPackages-request"
  "vizanti/ListPackagesRequest")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql '<ListPackages-request>)))
  "Returns md5sum for a message object of type '<ListPackages-request>"
  "16e658dd9a0c0812bd000a8e17c5f7b4")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql 'ListPackages-request)))
  "Returns md5sum for a message object of type 'ListPackages-request"
  "16e658dd9a0c0812bd000a8e17c5f7b4")
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql '<ListPackages-request>)))
  "Returns full string definition for message of type '<ListPackages-request>"
  (cl:format cl:nil "~%~%"))
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql 'ListPackages-request)))
  "Returns full string definition for message of type 'ListPackages-request"
  (cl:format cl:nil "~%~%"))
(cl:defmethod roslisp-msg-protocol:serialization-length ((msg <ListPackages-request>))
  (cl:+ 0
))
(cl:defmethod roslisp-msg-protocol:ros-message-to-list ((msg <ListPackages-request>))
  "Converts a ROS message object to a list"
  (cl:list 'ListPackages-request
))
;//! \htmlinclude ListPackages-response.msg.html

(cl:defclass <ListPackages-response> (roslisp-msg-protocol:ros-message)
  ((packages
    :reader packages
    :initarg :packages
    :type (cl:vector cl:string)
   :initform (cl:make-array 0 :element-type 'cl:string :initial-element "")))
)

(cl:defclass ListPackages-response (<ListPackages-response>)
  ())

(cl:defmethod cl:initialize-instance :after ((m <ListPackages-response>) cl:&rest args)
  (cl:declare (cl:ignorable args))
  (cl:unless (cl:typep m 'ListPackages-response)
    (roslisp-msg-protocol:msg-deprecation-warning "using old message class name vizanti-srv:<ListPackages-response> is deprecated: use vizanti-srv:ListPackages-response instead.")))

(cl:ensure-generic-function 'packages-val :lambda-list '(m))
(cl:defmethod packages-val ((m <ListPackages-response>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader vizanti-srv:packages-val is deprecated.  Use vizanti-srv:packages instead.")
  (packages m))
(cl:defmethod roslisp-msg-protocol:serialize ((msg <ListPackages-response>) ostream)
  "Serializes a message object of type '<ListPackages-response>"
  (cl:let ((__ros_arr_len (cl:length (cl:slot-value msg 'packages))))
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
   (cl:slot-value msg 'packages))
)
(cl:defmethod roslisp-msg-protocol:deserialize ((msg <ListPackages-response>) istream)
  "Deserializes a message object of type '<ListPackages-response>"
  (cl:let ((__ros_arr_len 0))
    (cl:setf (cl:ldb (cl:byte 8 0) __ros_arr_len) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 8) __ros_arr_len) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 16) __ros_arr_len) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 24) __ros_arr_len) (cl:read-byte istream))
  (cl:setf (cl:slot-value msg 'packages) (cl:make-array __ros_arr_len))
  (cl:let ((vals (cl:slot-value msg 'packages)))
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
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql '<ListPackages-response>)))
  "Returns string type for a service object of type '<ListPackages-response>"
  "vizanti/ListPackagesResponse")
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'ListPackages-response)))
  "Returns string type for a service object of type 'ListPackages-response"
  "vizanti/ListPackagesResponse")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql '<ListPackages-response>)))
  "Returns md5sum for a message object of type '<ListPackages-response>"
  "16e658dd9a0c0812bd000a8e17c5f7b4")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql 'ListPackages-response)))
  "Returns md5sum for a message object of type 'ListPackages-response"
  "16e658dd9a0c0812bd000a8e17c5f7b4")
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql '<ListPackages-response>)))
  "Returns full string definition for message of type '<ListPackages-response>"
  (cl:format cl:nil "string[] packages ~%~%~%~%"))
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql 'ListPackages-response)))
  "Returns full string definition for message of type 'ListPackages-response"
  (cl:format cl:nil "string[] packages ~%~%~%~%"))
(cl:defmethod roslisp-msg-protocol:serialization-length ((msg <ListPackages-response>))
  (cl:+ 0
     4 (cl:reduce #'cl:+ (cl:slot-value msg 'packages) :key #'(cl:lambda (ele) (cl:declare (cl:ignorable ele)) (cl:+ 4 (cl:length ele))))
))
(cl:defmethod roslisp-msg-protocol:ros-message-to-list ((msg <ListPackages-response>))
  "Converts a ROS message object to a list"
  (cl:list 'ListPackages-response
    (cl:cons ':packages (packages msg))
))
(cl:defmethod roslisp-msg-protocol:service-request-type ((msg (cl:eql 'ListPackages)))
  'ListPackages-request)
(cl:defmethod roslisp-msg-protocol:service-response-type ((msg (cl:eql 'ListPackages)))
  'ListPackages-response)
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'ListPackages)))
  "Returns string type for a service object of type '<ListPackages>"
  "vizanti/ListPackages")