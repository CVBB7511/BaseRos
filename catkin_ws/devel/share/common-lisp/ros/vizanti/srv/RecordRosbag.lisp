; Auto-generated. Do not edit!


(cl:in-package vizanti-srv)


;//! \htmlinclude RecordRosbag-request.msg.html

(cl:defclass <RecordRosbag-request> (roslisp-msg-protocol:ros-message)
  ((topics
    :reader topics
    :initarg :topics
    :type (cl:vector cl:string)
   :initform (cl:make-array 0 :element-type 'cl:string :initial-element ""))
   (start
    :reader start
    :initarg :start
    :type cl:boolean
    :initform cl:nil)
   (path
    :reader path
    :initarg :path
    :type cl:string
    :initform ""))
)

(cl:defclass RecordRosbag-request (<RecordRosbag-request>)
  ())

(cl:defmethod cl:initialize-instance :after ((m <RecordRosbag-request>) cl:&rest args)
  (cl:declare (cl:ignorable args))
  (cl:unless (cl:typep m 'RecordRosbag-request)
    (roslisp-msg-protocol:msg-deprecation-warning "using old message class name vizanti-srv:<RecordRosbag-request> is deprecated: use vizanti-srv:RecordRosbag-request instead.")))

(cl:ensure-generic-function 'topics-val :lambda-list '(m))
(cl:defmethod topics-val ((m <RecordRosbag-request>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader vizanti-srv:topics-val is deprecated.  Use vizanti-srv:topics instead.")
  (topics m))

(cl:ensure-generic-function 'start-val :lambda-list '(m))
(cl:defmethod start-val ((m <RecordRosbag-request>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader vizanti-srv:start-val is deprecated.  Use vizanti-srv:start instead.")
  (start m))

(cl:ensure-generic-function 'path-val :lambda-list '(m))
(cl:defmethod path-val ((m <RecordRosbag-request>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader vizanti-srv:path-val is deprecated.  Use vizanti-srv:path instead.")
  (path m))
(cl:defmethod roslisp-msg-protocol:serialize ((msg <RecordRosbag-request>) ostream)
  "Serializes a message object of type '<RecordRosbag-request>"
  (cl:let ((__ros_arr_len (cl:length (cl:slot-value msg 'topics))))
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
   (cl:slot-value msg 'topics))
  (cl:write-byte (cl:ldb (cl:byte 8 0) (cl:if (cl:slot-value msg 'start) 1 0)) ostream)
  (cl:let ((__ros_str_len (cl:length (cl:slot-value msg 'path))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) __ros_str_len) ostream))
  (cl:map cl:nil #'(cl:lambda (c) (cl:write-byte (cl:char-code c) ostream)) (cl:slot-value msg 'path))
)
(cl:defmethod roslisp-msg-protocol:deserialize ((msg <RecordRosbag-request>) istream)
  "Deserializes a message object of type '<RecordRosbag-request>"
  (cl:let ((__ros_arr_len 0))
    (cl:setf (cl:ldb (cl:byte 8 0) __ros_arr_len) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 8) __ros_arr_len) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 16) __ros_arr_len) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 24) __ros_arr_len) (cl:read-byte istream))
  (cl:setf (cl:slot-value msg 'topics) (cl:make-array __ros_arr_len))
  (cl:let ((vals (cl:slot-value msg 'topics)))
    (cl:dotimes (i __ros_arr_len)
    (cl:let ((__ros_str_len 0))
      (cl:setf (cl:ldb (cl:byte 8 0) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:aref vals i) (cl:make-string __ros_str_len))
      (cl:dotimes (__ros_str_idx __ros_str_len msg)
        (cl:setf (cl:char (cl:aref vals i) __ros_str_idx) (cl:code-char (cl:read-byte istream))))))))
    (cl:setf (cl:slot-value msg 'start) (cl:not (cl:zerop (cl:read-byte istream))))
    (cl:let ((__ros_str_len 0))
      (cl:setf (cl:ldb (cl:byte 8 0) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:slot-value msg 'path) (cl:make-string __ros_str_len))
      (cl:dotimes (__ros_str_idx __ros_str_len msg)
        (cl:setf (cl:char (cl:slot-value msg 'path) __ros_str_idx) (cl:code-char (cl:read-byte istream)))))
  msg
)
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql '<RecordRosbag-request>)))
  "Returns string type for a service object of type '<RecordRosbag-request>"
  "vizanti/RecordRosbagRequest")
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'RecordRosbag-request)))
  "Returns string type for a service object of type 'RecordRosbag-request"
  "vizanti/RecordRosbagRequest")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql '<RecordRosbag-request>)))
  "Returns md5sum for a message object of type '<RecordRosbag-request>"
  "292a2bef14171aa396b7aff9a49b098c")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql 'RecordRosbag-request)))
  "Returns md5sum for a message object of type 'RecordRosbag-request"
  "292a2bef14171aa396b7aff9a49b098c")
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql '<RecordRosbag-request>)))
  "Returns full string definition for message of type '<RecordRosbag-request>"
  (cl:format cl:nil "string[] topics~%bool start~%string path~%~%~%"))
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql 'RecordRosbag-request)))
  "Returns full string definition for message of type 'RecordRosbag-request"
  (cl:format cl:nil "string[] topics~%bool start~%string path~%~%~%"))
(cl:defmethod roslisp-msg-protocol:serialization-length ((msg <RecordRosbag-request>))
  (cl:+ 0
     4 (cl:reduce #'cl:+ (cl:slot-value msg 'topics) :key #'(cl:lambda (ele) (cl:declare (cl:ignorable ele)) (cl:+ 4 (cl:length ele))))
     1
     4 (cl:length (cl:slot-value msg 'path))
))
(cl:defmethod roslisp-msg-protocol:ros-message-to-list ((msg <RecordRosbag-request>))
  "Converts a ROS message object to a list"
  (cl:list 'RecordRosbag-request
    (cl:cons ':topics (topics msg))
    (cl:cons ':start (start msg))
    (cl:cons ':path (path msg))
))
;//! \htmlinclude RecordRosbag-response.msg.html

(cl:defclass <RecordRosbag-response> (roslisp-msg-protocol:ros-message)
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

(cl:defclass RecordRosbag-response (<RecordRosbag-response>)
  ())

(cl:defmethod cl:initialize-instance :after ((m <RecordRosbag-response>) cl:&rest args)
  (cl:declare (cl:ignorable args))
  (cl:unless (cl:typep m 'RecordRosbag-response)
    (roslisp-msg-protocol:msg-deprecation-warning "using old message class name vizanti-srv:<RecordRosbag-response> is deprecated: use vizanti-srv:RecordRosbag-response instead.")))

(cl:ensure-generic-function 'success-val :lambda-list '(m))
(cl:defmethod success-val ((m <RecordRosbag-response>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader vizanti-srv:success-val is deprecated.  Use vizanti-srv:success instead.")
  (success m))

(cl:ensure-generic-function 'message-val :lambda-list '(m))
(cl:defmethod message-val ((m <RecordRosbag-response>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader vizanti-srv:message-val is deprecated.  Use vizanti-srv:message instead.")
  (message m))
(cl:defmethod roslisp-msg-protocol:serialize ((msg <RecordRosbag-response>) ostream)
  "Serializes a message object of type '<RecordRosbag-response>"
  (cl:write-byte (cl:ldb (cl:byte 8 0) (cl:if (cl:slot-value msg 'success) 1 0)) ostream)
  (cl:let ((__ros_str_len (cl:length (cl:slot-value msg 'message))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) __ros_str_len) ostream))
  (cl:map cl:nil #'(cl:lambda (c) (cl:write-byte (cl:char-code c) ostream)) (cl:slot-value msg 'message))
)
(cl:defmethod roslisp-msg-protocol:deserialize ((msg <RecordRosbag-response>) istream)
  "Deserializes a message object of type '<RecordRosbag-response>"
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
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql '<RecordRosbag-response>)))
  "Returns string type for a service object of type '<RecordRosbag-response>"
  "vizanti/RecordRosbagResponse")
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'RecordRosbag-response)))
  "Returns string type for a service object of type 'RecordRosbag-response"
  "vizanti/RecordRosbagResponse")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql '<RecordRosbag-response>)))
  "Returns md5sum for a message object of type '<RecordRosbag-response>"
  "292a2bef14171aa396b7aff9a49b098c")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql 'RecordRosbag-response)))
  "Returns md5sum for a message object of type 'RecordRosbag-response"
  "292a2bef14171aa396b7aff9a49b098c")
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql '<RecordRosbag-response>)))
  "Returns full string definition for message of type '<RecordRosbag-response>"
  (cl:format cl:nil "bool success~%string message ~%~%~%~%"))
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql 'RecordRosbag-response)))
  "Returns full string definition for message of type 'RecordRosbag-response"
  (cl:format cl:nil "bool success~%string message ~%~%~%~%"))
(cl:defmethod roslisp-msg-protocol:serialization-length ((msg <RecordRosbag-response>))
  (cl:+ 0
     1
     4 (cl:length (cl:slot-value msg 'message))
))
(cl:defmethod roslisp-msg-protocol:ros-message-to-list ((msg <RecordRosbag-response>))
  "Converts a ROS message object to a list"
  (cl:list 'RecordRosbag-response
    (cl:cons ':success (success msg))
    (cl:cons ':message (message msg))
))
(cl:defmethod roslisp-msg-protocol:service-request-type ((msg (cl:eql 'RecordRosbag)))
  'RecordRosbag-request)
(cl:defmethod roslisp-msg-protocol:service-response-type ((msg (cl:eql 'RecordRosbag)))
  'RecordRosbag-response)
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'RecordRosbag)))
  "Returns string type for a service object of type '<RecordRosbag>"
  "vizanti/RecordRosbag")