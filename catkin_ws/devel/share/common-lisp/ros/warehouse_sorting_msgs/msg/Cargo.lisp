; Auto-generated. Do not edit!


(cl:in-package warehouse_sorting_msgs-msg)


;//! \htmlinclude Cargo.msg.html

(cl:defclass <Cargo> (roslisp-msg-protocol:ros-message)
  ((cargo_id
    :reader cargo_id
    :initarg :cargo_id
    :type cl:string
    :initform "")
   (cargo_type
    :reader cargo_type
    :initarg :cargo_type
    :type cl:string
    :initform "")
   (pose
    :reader pose
    :initarg :pose
    :type geometry_msgs-msg:Pose
    :initform (cl:make-instance 'geometry_msgs-msg:Pose))
   (size
    :reader size
    :initarg :size
    :type geometry_msgs-msg:Vector3
    :initform (cl:make-instance 'geometry_msgs-msg:Vector3))
   (volume
    :reader volume
    :initarg :volume
    :type cl:float
    :initform 0.0)
   (confidence
    :reader confidence
    :initarg :confidence
    :type cl:float
    :initform 0.0)
   (bbox_x
    :reader bbox_x
    :initarg :bbox_x
    :type cl:integer
    :initform 0)
   (bbox_y
    :reader bbox_y
    :initarg :bbox_y
    :type cl:integer
    :initform 0)
   (bbox_width
    :reader bbox_width
    :initarg :bbox_width
    :type cl:integer
    :initform 0)
   (bbox_height
    :reader bbox_height
    :initarg :bbox_height
    :type cl:integer
    :initform 0))
)

(cl:defclass Cargo (<Cargo>)
  ())

(cl:defmethod cl:initialize-instance :after ((m <Cargo>) cl:&rest args)
  (cl:declare (cl:ignorable args))
  (cl:unless (cl:typep m 'Cargo)
    (roslisp-msg-protocol:msg-deprecation-warning "using old message class name warehouse_sorting_msgs-msg:<Cargo> is deprecated: use warehouse_sorting_msgs-msg:Cargo instead.")))

(cl:ensure-generic-function 'cargo_id-val :lambda-list '(m))
(cl:defmethod cargo_id-val ((m <Cargo>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader warehouse_sorting_msgs-msg:cargo_id-val is deprecated.  Use warehouse_sorting_msgs-msg:cargo_id instead.")
  (cargo_id m))

(cl:ensure-generic-function 'cargo_type-val :lambda-list '(m))
(cl:defmethod cargo_type-val ((m <Cargo>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader warehouse_sorting_msgs-msg:cargo_type-val is deprecated.  Use warehouse_sorting_msgs-msg:cargo_type instead.")
  (cargo_type m))

(cl:ensure-generic-function 'pose-val :lambda-list '(m))
(cl:defmethod pose-val ((m <Cargo>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader warehouse_sorting_msgs-msg:pose-val is deprecated.  Use warehouse_sorting_msgs-msg:pose instead.")
  (pose m))

(cl:ensure-generic-function 'size-val :lambda-list '(m))
(cl:defmethod size-val ((m <Cargo>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader warehouse_sorting_msgs-msg:size-val is deprecated.  Use warehouse_sorting_msgs-msg:size instead.")
  (size m))

(cl:ensure-generic-function 'volume-val :lambda-list '(m))
(cl:defmethod volume-val ((m <Cargo>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader warehouse_sorting_msgs-msg:volume-val is deprecated.  Use warehouse_sorting_msgs-msg:volume instead.")
  (volume m))

(cl:ensure-generic-function 'confidence-val :lambda-list '(m))
(cl:defmethod confidence-val ((m <Cargo>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader warehouse_sorting_msgs-msg:confidence-val is deprecated.  Use warehouse_sorting_msgs-msg:confidence instead.")
  (confidence m))

(cl:ensure-generic-function 'bbox_x-val :lambda-list '(m))
(cl:defmethod bbox_x-val ((m <Cargo>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader warehouse_sorting_msgs-msg:bbox_x-val is deprecated.  Use warehouse_sorting_msgs-msg:bbox_x instead.")
  (bbox_x m))

(cl:ensure-generic-function 'bbox_y-val :lambda-list '(m))
(cl:defmethod bbox_y-val ((m <Cargo>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader warehouse_sorting_msgs-msg:bbox_y-val is deprecated.  Use warehouse_sorting_msgs-msg:bbox_y instead.")
  (bbox_y m))

(cl:ensure-generic-function 'bbox_width-val :lambda-list '(m))
(cl:defmethod bbox_width-val ((m <Cargo>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader warehouse_sorting_msgs-msg:bbox_width-val is deprecated.  Use warehouse_sorting_msgs-msg:bbox_width instead.")
  (bbox_width m))

(cl:ensure-generic-function 'bbox_height-val :lambda-list '(m))
(cl:defmethod bbox_height-val ((m <Cargo>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader warehouse_sorting_msgs-msg:bbox_height-val is deprecated.  Use warehouse_sorting_msgs-msg:bbox_height instead.")
  (bbox_height m))
(cl:defmethod roslisp-msg-protocol:serialize ((msg <Cargo>) ostream)
  "Serializes a message object of type '<Cargo>"
  (cl:let ((__ros_str_len (cl:length (cl:slot-value msg 'cargo_id))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) __ros_str_len) ostream))
  (cl:map cl:nil #'(cl:lambda (c) (cl:write-byte (cl:char-code c) ostream)) (cl:slot-value msg 'cargo_id))
  (cl:let ((__ros_str_len (cl:length (cl:slot-value msg 'cargo_type))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) __ros_str_len) ostream))
  (cl:map cl:nil #'(cl:lambda (c) (cl:write-byte (cl:char-code c) ostream)) (cl:slot-value msg 'cargo_type))
  (roslisp-msg-protocol:serialize (cl:slot-value msg 'pose) ostream)
  (roslisp-msg-protocol:serialize (cl:slot-value msg 'size) ostream)
  (cl:let ((bits (roslisp-utils:encode-single-float-bits (cl:slot-value msg 'volume))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) bits) ostream))
  (cl:let ((bits (roslisp-utils:encode-single-float-bits (cl:slot-value msg 'confidence))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) bits) ostream))
  (cl:let* ((signed (cl:slot-value msg 'bbox_x)) (unsigned (cl:if (cl:< signed 0) (cl:+ signed 4294967296) signed)))
    (cl:write-byte (cl:ldb (cl:byte 8 0) unsigned) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) unsigned) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) unsigned) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) unsigned) ostream)
    )
  (cl:let* ((signed (cl:slot-value msg 'bbox_y)) (unsigned (cl:if (cl:< signed 0) (cl:+ signed 4294967296) signed)))
    (cl:write-byte (cl:ldb (cl:byte 8 0) unsigned) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) unsigned) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) unsigned) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) unsigned) ostream)
    )
  (cl:let* ((signed (cl:slot-value msg 'bbox_width)) (unsigned (cl:if (cl:< signed 0) (cl:+ signed 4294967296) signed)))
    (cl:write-byte (cl:ldb (cl:byte 8 0) unsigned) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) unsigned) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) unsigned) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) unsigned) ostream)
    )
  (cl:let* ((signed (cl:slot-value msg 'bbox_height)) (unsigned (cl:if (cl:< signed 0) (cl:+ signed 4294967296) signed)))
    (cl:write-byte (cl:ldb (cl:byte 8 0) unsigned) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) unsigned) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) unsigned) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) unsigned) ostream)
    )
)
(cl:defmethod roslisp-msg-protocol:deserialize ((msg <Cargo>) istream)
  "Deserializes a message object of type '<Cargo>"
    (cl:let ((__ros_str_len 0))
      (cl:setf (cl:ldb (cl:byte 8 0) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:slot-value msg 'cargo_id) (cl:make-string __ros_str_len))
      (cl:dotimes (__ros_str_idx __ros_str_len msg)
        (cl:setf (cl:char (cl:slot-value msg 'cargo_id) __ros_str_idx) (cl:code-char (cl:read-byte istream)))))
    (cl:let ((__ros_str_len 0))
      (cl:setf (cl:ldb (cl:byte 8 0) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:slot-value msg 'cargo_type) (cl:make-string __ros_str_len))
      (cl:dotimes (__ros_str_idx __ros_str_len msg)
        (cl:setf (cl:char (cl:slot-value msg 'cargo_type) __ros_str_idx) (cl:code-char (cl:read-byte istream)))))
  (roslisp-msg-protocol:deserialize (cl:slot-value msg 'pose) istream)
  (roslisp-msg-protocol:deserialize (cl:slot-value msg 'size) istream)
    (cl:let ((bits 0))
      (cl:setf (cl:ldb (cl:byte 8 0) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) bits) (cl:read-byte istream))
    (cl:setf (cl:slot-value msg 'volume) (roslisp-utils:decode-single-float-bits bits)))
    (cl:let ((bits 0))
      (cl:setf (cl:ldb (cl:byte 8 0) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) bits) (cl:read-byte istream))
    (cl:setf (cl:slot-value msg 'confidence) (roslisp-utils:decode-single-float-bits bits)))
    (cl:let ((unsigned 0))
      (cl:setf (cl:ldb (cl:byte 8 0) unsigned) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) unsigned) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) unsigned) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) unsigned) (cl:read-byte istream))
      (cl:setf (cl:slot-value msg 'bbox_x) (cl:if (cl:< unsigned 2147483648) unsigned (cl:- unsigned 4294967296))))
    (cl:let ((unsigned 0))
      (cl:setf (cl:ldb (cl:byte 8 0) unsigned) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) unsigned) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) unsigned) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) unsigned) (cl:read-byte istream))
      (cl:setf (cl:slot-value msg 'bbox_y) (cl:if (cl:< unsigned 2147483648) unsigned (cl:- unsigned 4294967296))))
    (cl:let ((unsigned 0))
      (cl:setf (cl:ldb (cl:byte 8 0) unsigned) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) unsigned) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) unsigned) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) unsigned) (cl:read-byte istream))
      (cl:setf (cl:slot-value msg 'bbox_width) (cl:if (cl:< unsigned 2147483648) unsigned (cl:- unsigned 4294967296))))
    (cl:let ((unsigned 0))
      (cl:setf (cl:ldb (cl:byte 8 0) unsigned) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) unsigned) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) unsigned) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) unsigned) (cl:read-byte istream))
      (cl:setf (cl:slot-value msg 'bbox_height) (cl:if (cl:< unsigned 2147483648) unsigned (cl:- unsigned 4294967296))))
  msg
)
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql '<Cargo>)))
  "Returns string type for a message object of type '<Cargo>"
  "warehouse_sorting_msgs/Cargo")
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'Cargo)))
  "Returns string type for a message object of type 'Cargo"
  "warehouse_sorting_msgs/Cargo")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql '<Cargo>)))
  "Returns md5sum for a message object of type '<Cargo>"
  "f165e9d8fad2d5fab3540432824f5105")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql 'Cargo)))
  "Returns md5sum for a message object of type 'Cargo"
  "f165e9d8fad2d5fab3540432824f5105")
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql '<Cargo>)))
  "Returns full string definition for message of type '<Cargo>"
  (cl:format cl:nil "string cargo_id~%string cargo_type~%geometry_msgs/Pose pose~%geometry_msgs/Vector3 size~%float32 volume~%float32 confidence~%int32 bbox_x~%int32 bbox_y~%int32 bbox_width~%int32 bbox_height~%~%================================================================================~%MSG: geometry_msgs/Pose~%# A representation of pose in free space, composed of position and orientation. ~%Point position~%Quaternion orientation~%~%================================================================================~%MSG: geometry_msgs/Point~%# This contains the position of a point in free space~%float64 x~%float64 y~%float64 z~%~%================================================================================~%MSG: geometry_msgs/Quaternion~%# This represents an orientation in free space in quaternion form.~%~%float64 x~%float64 y~%float64 z~%float64 w~%~%================================================================================~%MSG: geometry_msgs/Vector3~%# This represents a vector in free space. ~%# It is only meant to represent a direction. Therefore, it does not~%# make sense to apply a translation to it (e.g., when applying a ~%# generic rigid transformation to a Vector3, tf2 will only apply the~%# rotation). If you want your data to be translatable too, use the~%# geometry_msgs/Point message instead.~%~%float64 x~%float64 y~%float64 z~%~%"))
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql 'Cargo)))
  "Returns full string definition for message of type 'Cargo"
  (cl:format cl:nil "string cargo_id~%string cargo_type~%geometry_msgs/Pose pose~%geometry_msgs/Vector3 size~%float32 volume~%float32 confidence~%int32 bbox_x~%int32 bbox_y~%int32 bbox_width~%int32 bbox_height~%~%================================================================================~%MSG: geometry_msgs/Pose~%# A representation of pose in free space, composed of position and orientation. ~%Point position~%Quaternion orientation~%~%================================================================================~%MSG: geometry_msgs/Point~%# This contains the position of a point in free space~%float64 x~%float64 y~%float64 z~%~%================================================================================~%MSG: geometry_msgs/Quaternion~%# This represents an orientation in free space in quaternion form.~%~%float64 x~%float64 y~%float64 z~%float64 w~%~%================================================================================~%MSG: geometry_msgs/Vector3~%# This represents a vector in free space. ~%# It is only meant to represent a direction. Therefore, it does not~%# make sense to apply a translation to it (e.g., when applying a ~%# generic rigid transformation to a Vector3, tf2 will only apply the~%# rotation). If you want your data to be translatable too, use the~%# geometry_msgs/Point message instead.~%~%float64 x~%float64 y~%float64 z~%~%"))
(cl:defmethod roslisp-msg-protocol:serialization-length ((msg <Cargo>))
  (cl:+ 0
     4 (cl:length (cl:slot-value msg 'cargo_id))
     4 (cl:length (cl:slot-value msg 'cargo_type))
     (roslisp-msg-protocol:serialization-length (cl:slot-value msg 'pose))
     (roslisp-msg-protocol:serialization-length (cl:slot-value msg 'size))
     4
     4
     4
     4
     4
     4
))
(cl:defmethod roslisp-msg-protocol:ros-message-to-list ((msg <Cargo>))
  "Converts a ROS message object to a list"
  (cl:list 'Cargo
    (cl:cons ':cargo_id (cargo_id msg))
    (cl:cons ':cargo_type (cargo_type msg))
    (cl:cons ':pose (pose msg))
    (cl:cons ':size (size msg))
    (cl:cons ':volume (volume msg))
    (cl:cons ':confidence (confidence msg))
    (cl:cons ':bbox_x (bbox_x msg))
    (cl:cons ':bbox_y (bbox_y msg))
    (cl:cons ':bbox_width (bbox_width msg))
    (cl:cons ':bbox_height (bbox_height msg))
))
