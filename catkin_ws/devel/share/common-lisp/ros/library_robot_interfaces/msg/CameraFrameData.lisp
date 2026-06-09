; Auto-generated. Do not edit!


(cl:in-package library_robot_interfaces-msg)


;//! \htmlinclude CameraFrameData.msg.html

(cl:defclass <CameraFrameData> (roslisp-msg-protocol:ros-message)
  ((header
    :reader header
    :initarg :header
    :type std_msgs-msg:Header
    :initform (cl:make-instance 'std_msgs-msg:Header))
   (frame_id
    :reader frame_id
    :initarg :frame_id
    :type cl:integer
    :initform 0)
   (format
    :reader format
    :initarg :format
    :type cl:string
    :initform "")
   (width
    :reader width
    :initarg :width
    :type cl:integer
    :initform 0)
   (height
    :reader height
    :initarg :height
    :type cl:integer
    :initform 0)
   (data_base64
    :reader data_base64
    :initarg :data_base64
    :type cl:string
    :initform "")
   (data_size
    :reader data_size
    :initarg :data_size
    :type cl:integer
    :initform 0))
)

(cl:defclass CameraFrameData (<CameraFrameData>)
  ())

(cl:defmethod cl:initialize-instance :after ((m <CameraFrameData>) cl:&rest args)
  (cl:declare (cl:ignorable args))
  (cl:unless (cl:typep m 'CameraFrameData)
    (roslisp-msg-protocol:msg-deprecation-warning "using old message class name library_robot_interfaces-msg:<CameraFrameData> is deprecated: use library_robot_interfaces-msg:CameraFrameData instead.")))

(cl:ensure-generic-function 'header-val :lambda-list '(m))
(cl:defmethod header-val ((m <CameraFrameData>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader library_robot_interfaces-msg:header-val is deprecated.  Use library_robot_interfaces-msg:header instead.")
  (header m))

(cl:ensure-generic-function 'frame_id-val :lambda-list '(m))
(cl:defmethod frame_id-val ((m <CameraFrameData>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader library_robot_interfaces-msg:frame_id-val is deprecated.  Use library_robot_interfaces-msg:frame_id instead.")
  (frame_id m))

(cl:ensure-generic-function 'format-val :lambda-list '(m))
(cl:defmethod format-val ((m <CameraFrameData>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader library_robot_interfaces-msg:format-val is deprecated.  Use library_robot_interfaces-msg:format instead.")
  (format m))

(cl:ensure-generic-function 'width-val :lambda-list '(m))
(cl:defmethod width-val ((m <CameraFrameData>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader library_robot_interfaces-msg:width-val is deprecated.  Use library_robot_interfaces-msg:width instead.")
  (width m))

(cl:ensure-generic-function 'height-val :lambda-list '(m))
(cl:defmethod height-val ((m <CameraFrameData>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader library_robot_interfaces-msg:height-val is deprecated.  Use library_robot_interfaces-msg:height instead.")
  (height m))

(cl:ensure-generic-function 'data_base64-val :lambda-list '(m))
(cl:defmethod data_base64-val ((m <CameraFrameData>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader library_robot_interfaces-msg:data_base64-val is deprecated.  Use library_robot_interfaces-msg:data_base64 instead.")
  (data_base64 m))

(cl:ensure-generic-function 'data_size-val :lambda-list '(m))
(cl:defmethod data_size-val ((m <CameraFrameData>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader library_robot_interfaces-msg:data_size-val is deprecated.  Use library_robot_interfaces-msg:data_size instead.")
  (data_size m))
(cl:defmethod roslisp-msg-protocol:serialize ((msg <CameraFrameData>) ostream)
  "Serializes a message object of type '<CameraFrameData>"
  (roslisp-msg-protocol:serialize (cl:slot-value msg 'header) ostream)
  (cl:let* ((signed (cl:slot-value msg 'frame_id)) (unsigned (cl:if (cl:< signed 0) (cl:+ signed 4294967296) signed)))
    (cl:write-byte (cl:ldb (cl:byte 8 0) unsigned) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) unsigned) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) unsigned) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) unsigned) ostream)
    )
  (cl:let ((__ros_str_len (cl:length (cl:slot-value msg 'format))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) __ros_str_len) ostream))
  (cl:map cl:nil #'(cl:lambda (c) (cl:write-byte (cl:char-code c) ostream)) (cl:slot-value msg 'format))
  (cl:let* ((signed (cl:slot-value msg 'width)) (unsigned (cl:if (cl:< signed 0) (cl:+ signed 4294967296) signed)))
    (cl:write-byte (cl:ldb (cl:byte 8 0) unsigned) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) unsigned) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) unsigned) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) unsigned) ostream)
    )
  (cl:let* ((signed (cl:slot-value msg 'height)) (unsigned (cl:if (cl:< signed 0) (cl:+ signed 4294967296) signed)))
    (cl:write-byte (cl:ldb (cl:byte 8 0) unsigned) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) unsigned) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) unsigned) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) unsigned) ostream)
    )
  (cl:let ((__ros_str_len (cl:length (cl:slot-value msg 'data_base64))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) __ros_str_len) ostream))
  (cl:map cl:nil #'(cl:lambda (c) (cl:write-byte (cl:char-code c) ostream)) (cl:slot-value msg 'data_base64))
  (cl:let* ((signed (cl:slot-value msg 'data_size)) (unsigned (cl:if (cl:< signed 0) (cl:+ signed 4294967296) signed)))
    (cl:write-byte (cl:ldb (cl:byte 8 0) unsigned) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) unsigned) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) unsigned) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) unsigned) ostream)
    )
)
(cl:defmethod roslisp-msg-protocol:deserialize ((msg <CameraFrameData>) istream)
  "Deserializes a message object of type '<CameraFrameData>"
  (roslisp-msg-protocol:deserialize (cl:slot-value msg 'header) istream)
    (cl:let ((unsigned 0))
      (cl:setf (cl:ldb (cl:byte 8 0) unsigned) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) unsigned) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) unsigned) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) unsigned) (cl:read-byte istream))
      (cl:setf (cl:slot-value msg 'frame_id) (cl:if (cl:< unsigned 2147483648) unsigned (cl:- unsigned 4294967296))))
    (cl:let ((__ros_str_len 0))
      (cl:setf (cl:ldb (cl:byte 8 0) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:slot-value msg 'format) (cl:make-string __ros_str_len))
      (cl:dotimes (__ros_str_idx __ros_str_len msg)
        (cl:setf (cl:char (cl:slot-value msg 'format) __ros_str_idx) (cl:code-char (cl:read-byte istream)))))
    (cl:let ((unsigned 0))
      (cl:setf (cl:ldb (cl:byte 8 0) unsigned) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) unsigned) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) unsigned) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) unsigned) (cl:read-byte istream))
      (cl:setf (cl:slot-value msg 'width) (cl:if (cl:< unsigned 2147483648) unsigned (cl:- unsigned 4294967296))))
    (cl:let ((unsigned 0))
      (cl:setf (cl:ldb (cl:byte 8 0) unsigned) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) unsigned) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) unsigned) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) unsigned) (cl:read-byte istream))
      (cl:setf (cl:slot-value msg 'height) (cl:if (cl:< unsigned 2147483648) unsigned (cl:- unsigned 4294967296))))
    (cl:let ((__ros_str_len 0))
      (cl:setf (cl:ldb (cl:byte 8 0) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:slot-value msg 'data_base64) (cl:make-string __ros_str_len))
      (cl:dotimes (__ros_str_idx __ros_str_len msg)
        (cl:setf (cl:char (cl:slot-value msg 'data_base64) __ros_str_idx) (cl:code-char (cl:read-byte istream)))))
    (cl:let ((unsigned 0))
      (cl:setf (cl:ldb (cl:byte 8 0) unsigned) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) unsigned) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) unsigned) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) unsigned) (cl:read-byte istream))
      (cl:setf (cl:slot-value msg 'data_size) (cl:if (cl:< unsigned 2147483648) unsigned (cl:- unsigned 4294967296))))
  msg
)
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql '<CameraFrameData>)))
  "Returns string type for a message object of type '<CameraFrameData>"
  "library_robot_interfaces/CameraFrameData")
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'CameraFrameData)))
  "Returns string type for a message object of type 'CameraFrameData"
  "library_robot_interfaces/CameraFrameData")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql '<CameraFrameData>)))
  "Returns md5sum for a message object of type '<CameraFrameData>"
  "21126ab408dfc26931ec388ac082dc56")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql 'CameraFrameData)))
  "Returns md5sum for a message object of type 'CameraFrameData"
  "21126ab408dfc26931ec388ac082dc56")
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql '<CameraFrameData>)))
  "Returns full string definition for message of type '<CameraFrameData>"
  (cl:format cl:nil "std_msgs/Header header~%int32 frame_id~%string format          # e.g., \"jpeg\", \"png\"~%int32 width~%int32 height~%string data_base64     # Base64编码的图像数据~%int32 data_size        # 原始数据大小（字节） ~%================================================================================~%MSG: std_msgs/Header~%# Standard metadata for higher-level stamped data types.~%# This is generally used to communicate timestamped data ~%# in a particular coordinate frame.~%# ~%# sequence ID: consecutively increasing ID ~%uint32 seq~%#Two-integer timestamp that is expressed as:~%# * stamp.sec: seconds (stamp_secs) since epoch (in Python the variable is called 'secs')~%# * stamp.nsec: nanoseconds since stamp_secs (in Python the variable is called 'nsecs')~%# time-handling sugar is provided by the client library~%time stamp~%#Frame this data is associated with~%string frame_id~%~%~%"))
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql 'CameraFrameData)))
  "Returns full string definition for message of type 'CameraFrameData"
  (cl:format cl:nil "std_msgs/Header header~%int32 frame_id~%string format          # e.g., \"jpeg\", \"png\"~%int32 width~%int32 height~%string data_base64     # Base64编码的图像数据~%int32 data_size        # 原始数据大小（字节） ~%================================================================================~%MSG: std_msgs/Header~%# Standard metadata for higher-level stamped data types.~%# This is generally used to communicate timestamped data ~%# in a particular coordinate frame.~%# ~%# sequence ID: consecutively increasing ID ~%uint32 seq~%#Two-integer timestamp that is expressed as:~%# * stamp.sec: seconds (stamp_secs) since epoch (in Python the variable is called 'secs')~%# * stamp.nsec: nanoseconds since stamp_secs (in Python the variable is called 'nsecs')~%# time-handling sugar is provided by the client library~%time stamp~%#Frame this data is associated with~%string frame_id~%~%~%"))
(cl:defmethod roslisp-msg-protocol:serialization-length ((msg <CameraFrameData>))
  (cl:+ 0
     (roslisp-msg-protocol:serialization-length (cl:slot-value msg 'header))
     4
     4 (cl:length (cl:slot-value msg 'format))
     4
     4
     4 (cl:length (cl:slot-value msg 'data_base64))
     4
))
(cl:defmethod roslisp-msg-protocol:ros-message-to-list ((msg <CameraFrameData>))
  "Converts a ROS message object to a list"
  (cl:list 'CameraFrameData
    (cl:cons ':header (header msg))
    (cl:cons ':frame_id (frame_id msg))
    (cl:cons ':format (format msg))
    (cl:cons ':width (width msg))
    (cl:cons ':height (height msg))
    (cl:cons ':data_base64 (data_base64 msg))
    (cl:cons ':data_size (data_size msg))
))
