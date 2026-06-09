; Auto-generated. Do not edit!


(cl:in-package navigation-srv)


;//! \htmlinclude Start-request.msg.html

(cl:defclass <Start-request> (roslisp-msg-protocol:ros-message)
  ((sim
    :reader sim
    :initarg :sim
    :type cl:boolean
    :initform cl:nil)
   (map
    :reader map
    :initarg :map
    :type cl:boolean
    :initform cl:nil)
   (path
    :reader path
    :initarg :path
    :type cl:string
    :initform "")
   (name
    :reader name
    :initarg :name
    :type cl:string
    :initform ""))
)

(cl:defclass Start-request (<Start-request>)
  ())

(cl:defmethod cl:initialize-instance :after ((m <Start-request>) cl:&rest args)
  (cl:declare (cl:ignorable args))
  (cl:unless (cl:typep m 'Start-request)
    (roslisp-msg-protocol:msg-deprecation-warning "using old message class name navigation-srv:<Start-request> is deprecated: use navigation-srv:Start-request instead.")))

(cl:ensure-generic-function 'sim-val :lambda-list '(m))
(cl:defmethod sim-val ((m <Start-request>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader navigation-srv:sim-val is deprecated.  Use navigation-srv:sim instead.")
  (sim m))

(cl:ensure-generic-function 'map-val :lambda-list '(m))
(cl:defmethod map-val ((m <Start-request>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader navigation-srv:map-val is deprecated.  Use navigation-srv:map instead.")
  (map m))

(cl:ensure-generic-function 'path-val :lambda-list '(m))
(cl:defmethod path-val ((m <Start-request>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader navigation-srv:path-val is deprecated.  Use navigation-srv:path instead.")
  (path m))

(cl:ensure-generic-function 'name-val :lambda-list '(m))
(cl:defmethod name-val ((m <Start-request>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader navigation-srv:name-val is deprecated.  Use navigation-srv:name instead.")
  (name m))
(cl:defmethod roslisp-msg-protocol:serialize ((msg <Start-request>) ostream)
  "Serializes a message object of type '<Start-request>"
  (cl:write-byte (cl:ldb (cl:byte 8 0) (cl:if (cl:slot-value msg 'sim) 1 0)) ostream)
  (cl:write-byte (cl:ldb (cl:byte 8 0) (cl:if (cl:slot-value msg 'map) 1 0)) ostream)
  (cl:let ((__ros_str_len (cl:length (cl:slot-value msg 'path))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) __ros_str_len) ostream))
  (cl:map cl:nil #'(cl:lambda (c) (cl:write-byte (cl:char-code c) ostream)) (cl:slot-value msg 'path))
  (cl:let ((__ros_str_len (cl:length (cl:slot-value msg 'name))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) __ros_str_len) ostream))
  (cl:map cl:nil #'(cl:lambda (c) (cl:write-byte (cl:char-code c) ostream)) (cl:slot-value msg 'name))
)
(cl:defmethod roslisp-msg-protocol:deserialize ((msg <Start-request>) istream)
  "Deserializes a message object of type '<Start-request>"
    (cl:setf (cl:slot-value msg 'sim) (cl:not (cl:zerop (cl:read-byte istream))))
    (cl:setf (cl:slot-value msg 'map) (cl:not (cl:zerop (cl:read-byte istream))))
    (cl:let ((__ros_str_len 0))
      (cl:setf (cl:ldb (cl:byte 8 0) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:slot-value msg 'path) (cl:make-string __ros_str_len))
      (cl:dotimes (__ros_str_idx __ros_str_len msg)
        (cl:setf (cl:char (cl:slot-value msg 'path) __ros_str_idx) (cl:code-char (cl:read-byte istream)))))
    (cl:let ((__ros_str_len 0))
      (cl:setf (cl:ldb (cl:byte 8 0) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:slot-value msg 'name) (cl:make-string __ros_str_len))
      (cl:dotimes (__ros_str_idx __ros_str_len msg)
        (cl:setf (cl:char (cl:slot-value msg 'name) __ros_str_idx) (cl:code-char (cl:read-byte istream)))))
  msg
)
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql '<Start-request>)))
  "Returns string type for a service object of type '<Start-request>"
  "navigation/StartRequest")
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'Start-request)))
  "Returns string type for a service object of type 'Start-request"
  "navigation/StartRequest")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql '<Start-request>)))
  "Returns md5sum for a message object of type '<Start-request>"
  "1fee74da3380a92a6837430b198ca30d")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql 'Start-request)))
  "Returns md5sum for a message object of type 'Start-request"
  "1fee74da3380a92a6837430b198ca30d")
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql '<Start-request>)))
  "Returns full string definition for message of type '<Start-request>"
  (cl:format cl:nil "bool sim~%bool map~%string path # relative path under /media/mitchell/Data/Projects/software_engineering/ros_end/src/mapping/maps/~%string name # name of map~%~%~%"))
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql 'Start-request)))
  "Returns full string definition for message of type 'Start-request"
  (cl:format cl:nil "bool sim~%bool map~%string path # relative path under /media/mitchell/Data/Projects/software_engineering/ros_end/src/mapping/maps/~%string name # name of map~%~%~%"))
(cl:defmethod roslisp-msg-protocol:serialization-length ((msg <Start-request>))
  (cl:+ 0
     1
     1
     4 (cl:length (cl:slot-value msg 'path))
     4 (cl:length (cl:slot-value msg 'name))
))
(cl:defmethod roslisp-msg-protocol:ros-message-to-list ((msg <Start-request>))
  "Converts a ROS message object to a list"
  (cl:list 'Start-request
    (cl:cons ':sim (sim msg))
    (cl:cons ':map (map msg))
    (cl:cons ':path (path msg))
    (cl:cons ':name (name msg))
))
;//! \htmlinclude Start-response.msg.html

(cl:defclass <Start-response> (roslisp-msg-protocol:ros-message)
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

(cl:defclass Start-response (<Start-response>)
  ())

(cl:defmethod cl:initialize-instance :after ((m <Start-response>) cl:&rest args)
  (cl:declare (cl:ignorable args))
  (cl:unless (cl:typep m 'Start-response)
    (roslisp-msg-protocol:msg-deprecation-warning "using old message class name navigation-srv:<Start-response> is deprecated: use navigation-srv:Start-response instead.")))

(cl:ensure-generic-function 'success-val :lambda-list '(m))
(cl:defmethod success-val ((m <Start-response>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader navigation-srv:success-val is deprecated.  Use navigation-srv:success instead.")
  (success m))

(cl:ensure-generic-function 'message-val :lambda-list '(m))
(cl:defmethod message-val ((m <Start-response>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader navigation-srv:message-val is deprecated.  Use navigation-srv:message instead.")
  (message m))
(cl:defmethod roslisp-msg-protocol:serialize ((msg <Start-response>) ostream)
  "Serializes a message object of type '<Start-response>"
  (cl:write-byte (cl:ldb (cl:byte 8 0) (cl:if (cl:slot-value msg 'success) 1 0)) ostream)
  (cl:let ((__ros_str_len (cl:length (cl:slot-value msg 'message))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) __ros_str_len) ostream))
  (cl:map cl:nil #'(cl:lambda (c) (cl:write-byte (cl:char-code c) ostream)) (cl:slot-value msg 'message))
)
(cl:defmethod roslisp-msg-protocol:deserialize ((msg <Start-response>) istream)
  "Deserializes a message object of type '<Start-response>"
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
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql '<Start-response>)))
  "Returns string type for a service object of type '<Start-response>"
  "navigation/StartResponse")
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'Start-response)))
  "Returns string type for a service object of type 'Start-response"
  "navigation/StartResponse")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql '<Start-response>)))
  "Returns md5sum for a message object of type '<Start-response>"
  "1fee74da3380a92a6837430b198ca30d")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql 'Start-response)))
  "Returns md5sum for a message object of type 'Start-response"
  "1fee74da3380a92a6837430b198ca30d")
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql '<Start-response>)))
  "Returns full string definition for message of type '<Start-response>"
  (cl:format cl:nil "bool success~%string message~%~%~%"))
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql 'Start-response)))
  "Returns full string definition for message of type 'Start-response"
  (cl:format cl:nil "bool success~%string message~%~%~%"))
(cl:defmethod roslisp-msg-protocol:serialization-length ((msg <Start-response>))
  (cl:+ 0
     1
     4 (cl:length (cl:slot-value msg 'message))
))
(cl:defmethod roslisp-msg-protocol:ros-message-to-list ((msg <Start-response>))
  "Converts a ROS message object to a list"
  (cl:list 'Start-response
    (cl:cons ':success (success msg))
    (cl:cons ':message (message msg))
))
(cl:defmethod roslisp-msg-protocol:service-request-type ((msg (cl:eql 'Start)))
  'Start-request)
(cl:defmethod roslisp-msg-protocol:service-response-type ((msg (cl:eql 'Start)))
  'Start-response)
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'Start)))
  "Returns string type for a service object of type '<Start>"
  "navigation/Start")