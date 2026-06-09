; Auto-generated. Do not edit!


(cl:in-package fetch_server-srv)


;//! \htmlinclude Fetch-request.msg.html

(cl:defclass <Fetch-request> (roslisp-msg-protocol:ros-message)
  ((gpx
    :reader gpx
    :initarg :gpx
    :type cl:float
    :initform 0.0)
   (gpy
    :reader gpy
    :initarg :gpy
    :type cl:float
    :initform 0.0)
   (gpz
    :reader gpz
    :initarg :gpz
    :type cl:float
    :initform 0.0)
   (goz
    :reader goz
    :initarg :goz
    :type cl:float
    :initform 0.0)
   (ppx
    :reader ppx
    :initarg :ppx
    :type cl:float
    :initform 0.0)
   (ppy
    :reader ppy
    :initarg :ppy
    :type cl:float
    :initform 0.0)
   (ppz
    :reader ppz
    :initarg :ppz
    :type cl:float
    :initform 0.0)
   (poz
    :reader poz
    :initarg :poz
    :type cl:float
    :initform 0.0))
)

(cl:defclass Fetch-request (<Fetch-request>)
  ())

(cl:defmethod cl:initialize-instance :after ((m <Fetch-request>) cl:&rest args)
  (cl:declare (cl:ignorable args))
  (cl:unless (cl:typep m 'Fetch-request)
    (roslisp-msg-protocol:msg-deprecation-warning "using old message class name fetch_server-srv:<Fetch-request> is deprecated: use fetch_server-srv:Fetch-request instead.")))

(cl:ensure-generic-function 'gpx-val :lambda-list '(m))
(cl:defmethod gpx-val ((m <Fetch-request>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader fetch_server-srv:gpx-val is deprecated.  Use fetch_server-srv:gpx instead.")
  (gpx m))

(cl:ensure-generic-function 'gpy-val :lambda-list '(m))
(cl:defmethod gpy-val ((m <Fetch-request>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader fetch_server-srv:gpy-val is deprecated.  Use fetch_server-srv:gpy instead.")
  (gpy m))

(cl:ensure-generic-function 'gpz-val :lambda-list '(m))
(cl:defmethod gpz-val ((m <Fetch-request>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader fetch_server-srv:gpz-val is deprecated.  Use fetch_server-srv:gpz instead.")
  (gpz m))

(cl:ensure-generic-function 'goz-val :lambda-list '(m))
(cl:defmethod goz-val ((m <Fetch-request>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader fetch_server-srv:goz-val is deprecated.  Use fetch_server-srv:goz instead.")
  (goz m))

(cl:ensure-generic-function 'ppx-val :lambda-list '(m))
(cl:defmethod ppx-val ((m <Fetch-request>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader fetch_server-srv:ppx-val is deprecated.  Use fetch_server-srv:ppx instead.")
  (ppx m))

(cl:ensure-generic-function 'ppy-val :lambda-list '(m))
(cl:defmethod ppy-val ((m <Fetch-request>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader fetch_server-srv:ppy-val is deprecated.  Use fetch_server-srv:ppy instead.")
  (ppy m))

(cl:ensure-generic-function 'ppz-val :lambda-list '(m))
(cl:defmethod ppz-val ((m <Fetch-request>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader fetch_server-srv:ppz-val is deprecated.  Use fetch_server-srv:ppz instead.")
  (ppz m))

(cl:ensure-generic-function 'poz-val :lambda-list '(m))
(cl:defmethod poz-val ((m <Fetch-request>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader fetch_server-srv:poz-val is deprecated.  Use fetch_server-srv:poz instead.")
  (poz m))
(cl:defmethod roslisp-msg-protocol:serialize ((msg <Fetch-request>) ostream)
  "Serializes a message object of type '<Fetch-request>"
  (cl:let ((bits (roslisp-utils:encode-double-float-bits (cl:slot-value msg 'gpx))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 32) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 40) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 48) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 56) bits) ostream))
  (cl:let ((bits (roslisp-utils:encode-double-float-bits (cl:slot-value msg 'gpy))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 32) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 40) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 48) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 56) bits) ostream))
  (cl:let ((bits (roslisp-utils:encode-double-float-bits (cl:slot-value msg 'gpz))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 32) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 40) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 48) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 56) bits) ostream))
  (cl:let ((bits (roslisp-utils:encode-double-float-bits (cl:slot-value msg 'goz))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 32) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 40) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 48) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 56) bits) ostream))
  (cl:let ((bits (roslisp-utils:encode-double-float-bits (cl:slot-value msg 'ppx))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 32) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 40) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 48) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 56) bits) ostream))
  (cl:let ((bits (roslisp-utils:encode-double-float-bits (cl:slot-value msg 'ppy))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 32) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 40) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 48) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 56) bits) ostream))
  (cl:let ((bits (roslisp-utils:encode-double-float-bits (cl:slot-value msg 'ppz))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 32) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 40) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 48) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 56) bits) ostream))
  (cl:let ((bits (roslisp-utils:encode-double-float-bits (cl:slot-value msg 'poz))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 32) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 40) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 48) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 56) bits) ostream))
)
(cl:defmethod roslisp-msg-protocol:deserialize ((msg <Fetch-request>) istream)
  "Deserializes a message object of type '<Fetch-request>"
    (cl:let ((bits 0))
      (cl:setf (cl:ldb (cl:byte 8 0) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 32) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 40) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 48) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 56) bits) (cl:read-byte istream))
    (cl:setf (cl:slot-value msg 'gpx) (roslisp-utils:decode-double-float-bits bits)))
    (cl:let ((bits 0))
      (cl:setf (cl:ldb (cl:byte 8 0) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 32) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 40) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 48) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 56) bits) (cl:read-byte istream))
    (cl:setf (cl:slot-value msg 'gpy) (roslisp-utils:decode-double-float-bits bits)))
    (cl:let ((bits 0))
      (cl:setf (cl:ldb (cl:byte 8 0) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 32) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 40) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 48) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 56) bits) (cl:read-byte istream))
    (cl:setf (cl:slot-value msg 'gpz) (roslisp-utils:decode-double-float-bits bits)))
    (cl:let ((bits 0))
      (cl:setf (cl:ldb (cl:byte 8 0) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 32) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 40) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 48) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 56) bits) (cl:read-byte istream))
    (cl:setf (cl:slot-value msg 'goz) (roslisp-utils:decode-double-float-bits bits)))
    (cl:let ((bits 0))
      (cl:setf (cl:ldb (cl:byte 8 0) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 32) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 40) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 48) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 56) bits) (cl:read-byte istream))
    (cl:setf (cl:slot-value msg 'ppx) (roslisp-utils:decode-double-float-bits bits)))
    (cl:let ((bits 0))
      (cl:setf (cl:ldb (cl:byte 8 0) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 32) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 40) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 48) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 56) bits) (cl:read-byte istream))
    (cl:setf (cl:slot-value msg 'ppy) (roslisp-utils:decode-double-float-bits bits)))
    (cl:let ((bits 0))
      (cl:setf (cl:ldb (cl:byte 8 0) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 32) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 40) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 48) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 56) bits) (cl:read-byte istream))
    (cl:setf (cl:slot-value msg 'ppz) (roslisp-utils:decode-double-float-bits bits)))
    (cl:let ((bits 0))
      (cl:setf (cl:ldb (cl:byte 8 0) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 32) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 40) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 48) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 56) bits) (cl:read-byte istream))
    (cl:setf (cl:slot-value msg 'poz) (roslisp-utils:decode-double-float-bits bits)))
  msg
)
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql '<Fetch-request>)))
  "Returns string type for a service object of type '<Fetch-request>"
  "fetch_server/FetchRequest")
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'Fetch-request)))
  "Returns string type for a service object of type 'Fetch-request"
  "fetch_server/FetchRequest")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql '<Fetch-request>)))
  "Returns md5sum for a message object of type '<Fetch-request>"
  "88a1ffde7893c12d1c785f9936a31695")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql 'Fetch-request)))
  "Returns md5sum for a message object of type 'Fetch-request"
  "88a1ffde7893c12d1c785f9936a31695")
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql '<Fetch-request>)))
  "Returns full string definition for message of type '<Fetch-request>"
  (cl:format cl:nil "float64 gpx~%float64 gpy~%float64 gpz~%float64 goz~%float64 ppx~%float64 ppy~%float64 ppz~%float64 poz~%~%~%"))
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql 'Fetch-request)))
  "Returns full string definition for message of type 'Fetch-request"
  (cl:format cl:nil "float64 gpx~%float64 gpy~%float64 gpz~%float64 goz~%float64 ppx~%float64 ppy~%float64 ppz~%float64 poz~%~%~%"))
(cl:defmethod roslisp-msg-protocol:serialization-length ((msg <Fetch-request>))
  (cl:+ 0
     8
     8
     8
     8
     8
     8
     8
     8
))
(cl:defmethod roslisp-msg-protocol:ros-message-to-list ((msg <Fetch-request>))
  "Converts a ROS message object to a list"
  (cl:list 'Fetch-request
    (cl:cons ':gpx (gpx msg))
    (cl:cons ':gpy (gpy msg))
    (cl:cons ':gpz (gpz msg))
    (cl:cons ':goz (goz msg))
    (cl:cons ':ppx (ppx msg))
    (cl:cons ':ppy (ppy msg))
    (cl:cons ':ppz (ppz msg))
    (cl:cons ':poz (poz msg))
))
;//! \htmlinclude Fetch-response.msg.html

(cl:defclass <Fetch-response> (roslisp-msg-protocol:ros-message)
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

(cl:defclass Fetch-response (<Fetch-response>)
  ())

(cl:defmethod cl:initialize-instance :after ((m <Fetch-response>) cl:&rest args)
  (cl:declare (cl:ignorable args))
  (cl:unless (cl:typep m 'Fetch-response)
    (roslisp-msg-protocol:msg-deprecation-warning "using old message class name fetch_server-srv:<Fetch-response> is deprecated: use fetch_server-srv:Fetch-response instead.")))

(cl:ensure-generic-function 'success-val :lambda-list '(m))
(cl:defmethod success-val ((m <Fetch-response>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader fetch_server-srv:success-val is deprecated.  Use fetch_server-srv:success instead.")
  (success m))

(cl:ensure-generic-function 'message-val :lambda-list '(m))
(cl:defmethod message-val ((m <Fetch-response>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader fetch_server-srv:message-val is deprecated.  Use fetch_server-srv:message instead.")
  (message m))
(cl:defmethod roslisp-msg-protocol:serialize ((msg <Fetch-response>) ostream)
  "Serializes a message object of type '<Fetch-response>"
  (cl:write-byte (cl:ldb (cl:byte 8 0) (cl:if (cl:slot-value msg 'success) 1 0)) ostream)
  (cl:let ((__ros_str_len (cl:length (cl:slot-value msg 'message))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) __ros_str_len) ostream))
  (cl:map cl:nil #'(cl:lambda (c) (cl:write-byte (cl:char-code c) ostream)) (cl:slot-value msg 'message))
)
(cl:defmethod roslisp-msg-protocol:deserialize ((msg <Fetch-response>) istream)
  "Deserializes a message object of type '<Fetch-response>"
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
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql '<Fetch-response>)))
  "Returns string type for a service object of type '<Fetch-response>"
  "fetch_server/FetchResponse")
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'Fetch-response)))
  "Returns string type for a service object of type 'Fetch-response"
  "fetch_server/FetchResponse")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql '<Fetch-response>)))
  "Returns md5sum for a message object of type '<Fetch-response>"
  "88a1ffde7893c12d1c785f9936a31695")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql 'Fetch-response)))
  "Returns md5sum for a message object of type 'Fetch-response"
  "88a1ffde7893c12d1c785f9936a31695")
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql '<Fetch-response>)))
  "Returns full string definition for message of type '<Fetch-response>"
  (cl:format cl:nil "bool success~%string message~%~%~%"))
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql 'Fetch-response)))
  "Returns full string definition for message of type 'Fetch-response"
  (cl:format cl:nil "bool success~%string message~%~%~%"))
(cl:defmethod roslisp-msg-protocol:serialization-length ((msg <Fetch-response>))
  (cl:+ 0
     1
     4 (cl:length (cl:slot-value msg 'message))
))
(cl:defmethod roslisp-msg-protocol:ros-message-to-list ((msg <Fetch-response>))
  "Converts a ROS message object to a list"
  (cl:list 'Fetch-response
    (cl:cons ':success (success msg))
    (cl:cons ':message (message msg))
))
(cl:defmethod roslisp-msg-protocol:service-request-type ((msg (cl:eql 'Fetch)))
  'Fetch-request)
(cl:defmethod roslisp-msg-protocol:service-response-type ((msg (cl:eql 'Fetch)))
  'Fetch-response)
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'Fetch)))
  "Returns string type for a service object of type '<Fetch>"
  "fetch_server/Fetch")