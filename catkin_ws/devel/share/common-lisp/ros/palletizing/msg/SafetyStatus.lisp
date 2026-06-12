; Auto-generated. Do not edit!


(cl:in-package palletizing-msg)


;//! \htmlinclude SafetyStatus.msg.html

(cl:defclass <SafetyStatus> (roslisp-msg-protocol:ros-message)
  ((level
    :reader level
    :initarg :level
    :type cl:fixnum
    :initform 0)
   (min_distance
    :reader min_distance
    :initarg :min_distance
    :type cl:float
    :initform 0.0)
   (message
    :reader message
    :initarg :message
    :type cl:string
    :initform ""))
)

(cl:defclass SafetyStatus (<SafetyStatus>)
  ())

(cl:defmethod cl:initialize-instance :after ((m <SafetyStatus>) cl:&rest args)
  (cl:declare (cl:ignorable args))
  (cl:unless (cl:typep m 'SafetyStatus)
    (roslisp-msg-protocol:msg-deprecation-warning "using old message class name palletizing-msg:<SafetyStatus> is deprecated: use palletizing-msg:SafetyStatus instead.")))

(cl:ensure-generic-function 'level-val :lambda-list '(m))
(cl:defmethod level-val ((m <SafetyStatus>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader palletizing-msg:level-val is deprecated.  Use palletizing-msg:level instead.")
  (level m))

(cl:ensure-generic-function 'min_distance-val :lambda-list '(m))
(cl:defmethod min_distance-val ((m <SafetyStatus>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader palletizing-msg:min_distance-val is deprecated.  Use palletizing-msg:min_distance instead.")
  (min_distance m))

(cl:ensure-generic-function 'message-val :lambda-list '(m))
(cl:defmethod message-val ((m <SafetyStatus>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader palletizing-msg:message-val is deprecated.  Use palletizing-msg:message instead.")
  (message m))
(cl:defmethod roslisp-msg-protocol:symbol-codes ((msg-type (cl:eql '<SafetyStatus>)))
    "Constants for message type '<SafetyStatus>"
  '((:CLEAR . 0)
    (:WARNING . 1)
    (:EMERGENCY . 2))
)
(cl:defmethod roslisp-msg-protocol:symbol-codes ((msg-type (cl:eql 'SafetyStatus)))
    "Constants for message type 'SafetyStatus"
  '((:CLEAR . 0)
    (:WARNING . 1)
    (:EMERGENCY . 2))
)
(cl:defmethod roslisp-msg-protocol:serialize ((msg <SafetyStatus>) ostream)
  "Serializes a message object of type '<SafetyStatus>"
  (cl:write-byte (cl:ldb (cl:byte 8 0) (cl:slot-value msg 'level)) ostream)
  (cl:let ((bits (roslisp-utils:encode-double-float-bits (cl:slot-value msg 'min_distance))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 32) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 40) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 48) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 56) bits) ostream))
  (cl:let ((__ros_str_len (cl:length (cl:slot-value msg 'message))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) __ros_str_len) ostream))
  (cl:map cl:nil #'(cl:lambda (c) (cl:write-byte (cl:char-code c) ostream)) (cl:slot-value msg 'message))
)
(cl:defmethod roslisp-msg-protocol:deserialize ((msg <SafetyStatus>) istream)
  "Deserializes a message object of type '<SafetyStatus>"
    (cl:setf (cl:ldb (cl:byte 8 0) (cl:slot-value msg 'level)) (cl:read-byte istream))
    (cl:let ((bits 0))
      (cl:setf (cl:ldb (cl:byte 8 0) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 32) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 40) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 48) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 56) bits) (cl:read-byte istream))
    (cl:setf (cl:slot-value msg 'min_distance) (roslisp-utils:decode-double-float-bits bits)))
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
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql '<SafetyStatus>)))
  "Returns string type for a message object of type '<SafetyStatus>"
  "palletizing/SafetyStatus")
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'SafetyStatus)))
  "Returns string type for a message object of type 'SafetyStatus"
  "palletizing/SafetyStatus")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql '<SafetyStatus>)))
  "Returns md5sum for a message object of type '<SafetyStatus>"
  "080f944521045f84e22d6ce4b4a77218")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql 'SafetyStatus)))
  "Returns md5sum for a message object of type 'SafetyStatus"
  "080f944521045f84e22d6ce4b4a77218")
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql '<SafetyStatus>)))
  "Returns full string definition for message of type '<SafetyStatus>"
  (cl:format cl:nil "uint8 CLEAR=0~%uint8 WARNING=1~%uint8 EMERGENCY=2~%uint8 level~%float64 min_distance~%string message~%~%~%"))
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql 'SafetyStatus)))
  "Returns full string definition for message of type 'SafetyStatus"
  (cl:format cl:nil "uint8 CLEAR=0~%uint8 WARNING=1~%uint8 EMERGENCY=2~%uint8 level~%float64 min_distance~%string message~%~%~%"))
(cl:defmethod roslisp-msg-protocol:serialization-length ((msg <SafetyStatus>))
  (cl:+ 0
     1
     8
     4 (cl:length (cl:slot-value msg 'message))
))
(cl:defmethod roslisp-msg-protocol:ros-message-to-list ((msg <SafetyStatus>))
  "Converts a ROS message object to a list"
  (cl:list 'SafetyStatus
    (cl:cons ':level (level msg))
    (cl:cons ':min_distance (min_distance msg))
    (cl:cons ':message (message msg))
))
