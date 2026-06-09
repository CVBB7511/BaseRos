; Auto-generated. Do not edit!


(cl:in-package mapping-srv)


;//! \htmlinclude Start-request.msg.html

(cl:defclass <Start-request> (roslisp-msg-protocol:ros-message)
  ((sim
    :reader sim
    :initarg :sim
    :type cl:boolean
    :initform cl:nil)
   (width
    :reader width
    :initarg :width
    :type cl:float
    :initform 0.0)
   (height
    :reader height
    :initarg :height
    :type cl:float
    :initform 0.0))
)

(cl:defclass Start-request (<Start-request>)
  ())

(cl:defmethod cl:initialize-instance :after ((m <Start-request>) cl:&rest args)
  (cl:declare (cl:ignorable args))
  (cl:unless (cl:typep m 'Start-request)
    (roslisp-msg-protocol:msg-deprecation-warning "using old message class name mapping-srv:<Start-request> is deprecated: use mapping-srv:Start-request instead.")))

(cl:ensure-generic-function 'sim-val :lambda-list '(m))
(cl:defmethod sim-val ((m <Start-request>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader mapping-srv:sim-val is deprecated.  Use mapping-srv:sim instead.")
  (sim m))

(cl:ensure-generic-function 'width-val :lambda-list '(m))
(cl:defmethod width-val ((m <Start-request>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader mapping-srv:width-val is deprecated.  Use mapping-srv:width instead.")
  (width m))

(cl:ensure-generic-function 'height-val :lambda-list '(m))
(cl:defmethod height-val ((m <Start-request>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader mapping-srv:height-val is deprecated.  Use mapping-srv:height instead.")
  (height m))
(cl:defmethod roslisp-msg-protocol:serialize ((msg <Start-request>) ostream)
  "Serializes a message object of type '<Start-request>"
  (cl:write-byte (cl:ldb (cl:byte 8 0) (cl:if (cl:slot-value msg 'sim) 1 0)) ostream)
  (cl:let ((bits (roslisp-utils:encode-double-float-bits (cl:slot-value msg 'width))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 32) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 40) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 48) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 56) bits) ostream))
  (cl:let ((bits (roslisp-utils:encode-double-float-bits (cl:slot-value msg 'height))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 32) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 40) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 48) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 56) bits) ostream))
)
(cl:defmethod roslisp-msg-protocol:deserialize ((msg <Start-request>) istream)
  "Deserializes a message object of type '<Start-request>"
    (cl:setf (cl:slot-value msg 'sim) (cl:not (cl:zerop (cl:read-byte istream))))
    (cl:let ((bits 0))
      (cl:setf (cl:ldb (cl:byte 8 0) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 32) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 40) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 48) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 56) bits) (cl:read-byte istream))
    (cl:setf (cl:slot-value msg 'width) (roslisp-utils:decode-double-float-bits bits)))
    (cl:let ((bits 0))
      (cl:setf (cl:ldb (cl:byte 8 0) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 32) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 40) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 48) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 56) bits) (cl:read-byte istream))
    (cl:setf (cl:slot-value msg 'height) (roslisp-utils:decode-double-float-bits bits)))
  msg
)
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql '<Start-request>)))
  "Returns string type for a service object of type '<Start-request>"
  "mapping/StartRequest")
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'Start-request)))
  "Returns string type for a service object of type 'Start-request"
  "mapping/StartRequest")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql '<Start-request>)))
  "Returns md5sum for a message object of type '<Start-request>"
  "4dca6bc64797f691acd5d21876b3c9f4")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql 'Start-request)))
  "Returns md5sum for a message object of type 'Start-request"
  "4dca6bc64797f691acd5d21876b3c9f4")
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql '<Start-request>)))
  "Returns full string definition for message of type '<Start-request>"
  (cl:format cl:nil "bool sim # 明确是在仿真环境内还是在实际场景中~%float64 width~%float64 height~%~%~%"))
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql 'Start-request)))
  "Returns full string definition for message of type 'Start-request"
  (cl:format cl:nil "bool sim # 明确是在仿真环境内还是在实际场景中~%float64 width~%float64 height~%~%~%"))
(cl:defmethod roslisp-msg-protocol:serialization-length ((msg <Start-request>))
  (cl:+ 0
     1
     8
     8
))
(cl:defmethod roslisp-msg-protocol:ros-message-to-list ((msg <Start-request>))
  "Converts a ROS message object to a list"
  (cl:list 'Start-request
    (cl:cons ':sim (sim msg))
    (cl:cons ':width (width msg))
    (cl:cons ':height (height msg))
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
    (roslisp-msg-protocol:msg-deprecation-warning "using old message class name mapping-srv:<Start-response> is deprecated: use mapping-srv:Start-response instead.")))

(cl:ensure-generic-function 'success-val :lambda-list '(m))
(cl:defmethod success-val ((m <Start-response>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader mapping-srv:success-val is deprecated.  Use mapping-srv:success instead.")
  (success m))

(cl:ensure-generic-function 'message-val :lambda-list '(m))
(cl:defmethod message-val ((m <Start-response>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader mapping-srv:message-val is deprecated.  Use mapping-srv:message instead.")
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
  "mapping/StartResponse")
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'Start-response)))
  "Returns string type for a service object of type 'Start-response"
  "mapping/StartResponse")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql '<Start-response>)))
  "Returns md5sum for a message object of type '<Start-response>"
  "4dca6bc64797f691acd5d21876b3c9f4")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql 'Start-response)))
  "Returns md5sum for a message object of type 'Start-response"
  "4dca6bc64797f691acd5d21876b3c9f4")
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
  "mapping/Start")