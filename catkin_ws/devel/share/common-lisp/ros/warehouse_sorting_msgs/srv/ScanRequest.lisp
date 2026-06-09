; Auto-generated. Do not edit!


(cl:in-package warehouse_sorting_msgs-srv)


;//! \htmlinclude ScanRequest-request.msg.html

(cl:defclass <ScanRequest-request> (roslisp-msg-protocol:ros-message)
  ((force
    :reader force
    :initarg :force
    :type cl:boolean
    :initform cl:nil))
)

(cl:defclass ScanRequest-request (<ScanRequest-request>)
  ())

(cl:defmethod cl:initialize-instance :after ((m <ScanRequest-request>) cl:&rest args)
  (cl:declare (cl:ignorable args))
  (cl:unless (cl:typep m 'ScanRequest-request)
    (roslisp-msg-protocol:msg-deprecation-warning "using old message class name warehouse_sorting_msgs-srv:<ScanRequest-request> is deprecated: use warehouse_sorting_msgs-srv:ScanRequest-request instead.")))

(cl:ensure-generic-function 'force-val :lambda-list '(m))
(cl:defmethod force-val ((m <ScanRequest-request>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader warehouse_sorting_msgs-srv:force-val is deprecated.  Use warehouse_sorting_msgs-srv:force instead.")
  (force m))
(cl:defmethod roslisp-msg-protocol:serialize ((msg <ScanRequest-request>) ostream)
  "Serializes a message object of type '<ScanRequest-request>"
  (cl:write-byte (cl:ldb (cl:byte 8 0) (cl:if (cl:slot-value msg 'force) 1 0)) ostream)
)
(cl:defmethod roslisp-msg-protocol:deserialize ((msg <ScanRequest-request>) istream)
  "Deserializes a message object of type '<ScanRequest-request>"
    (cl:setf (cl:slot-value msg 'force) (cl:not (cl:zerop (cl:read-byte istream))))
  msg
)
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql '<ScanRequest-request>)))
  "Returns string type for a service object of type '<ScanRequest-request>"
  "warehouse_sorting_msgs/ScanRequestRequest")
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'ScanRequest-request)))
  "Returns string type for a service object of type 'ScanRequest-request"
  "warehouse_sorting_msgs/ScanRequestRequest")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql '<ScanRequest-request>)))
  "Returns md5sum for a message object of type '<ScanRequest-request>"
  "c6db9a8beb3e4e03e56bddc308994352")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql 'ScanRequest-request)))
  "Returns md5sum for a message object of type 'ScanRequest-request"
  "c6db9a8beb3e4e03e56bddc308994352")
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql '<ScanRequest-request>)))
  "Returns full string definition for message of type '<ScanRequest-request>"
  (cl:format cl:nil "bool force~%~%~%"))
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql 'ScanRequest-request)))
  "Returns full string definition for message of type 'ScanRequest-request"
  (cl:format cl:nil "bool force~%~%~%"))
(cl:defmethod roslisp-msg-protocol:serialization-length ((msg <ScanRequest-request>))
  (cl:+ 0
     1
))
(cl:defmethod roslisp-msg-protocol:ros-message-to-list ((msg <ScanRequest-request>))
  "Converts a ROS message object to a list"
  (cl:list 'ScanRequest-request
    (cl:cons ':force (force msg))
))
;//! \htmlinclude ScanRequest-response.msg.html

(cl:defclass <ScanRequest-response> (roslisp-msg-protocol:ros-message)
  ((success
    :reader success
    :initarg :success
    :type cl:boolean
    :initform cl:nil)
   (message
    :reader message
    :initarg :message
    :type cl:string
    :initform "")
   (detections
    :reader detections
    :initarg :detections
    :type warehouse_sorting_msgs-msg:DetectedCargoArray
    :initform (cl:make-instance 'warehouse_sorting_msgs-msg:DetectedCargoArray)))
)

(cl:defclass ScanRequest-response (<ScanRequest-response>)
  ())

(cl:defmethod cl:initialize-instance :after ((m <ScanRequest-response>) cl:&rest args)
  (cl:declare (cl:ignorable args))
  (cl:unless (cl:typep m 'ScanRequest-response)
    (roslisp-msg-protocol:msg-deprecation-warning "using old message class name warehouse_sorting_msgs-srv:<ScanRequest-response> is deprecated: use warehouse_sorting_msgs-srv:ScanRequest-response instead.")))

(cl:ensure-generic-function 'success-val :lambda-list '(m))
(cl:defmethod success-val ((m <ScanRequest-response>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader warehouse_sorting_msgs-srv:success-val is deprecated.  Use warehouse_sorting_msgs-srv:success instead.")
  (success m))

(cl:ensure-generic-function 'message-val :lambda-list '(m))
(cl:defmethod message-val ((m <ScanRequest-response>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader warehouse_sorting_msgs-srv:message-val is deprecated.  Use warehouse_sorting_msgs-srv:message instead.")
  (message m))

(cl:ensure-generic-function 'detections-val :lambda-list '(m))
(cl:defmethod detections-val ((m <ScanRequest-response>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader warehouse_sorting_msgs-srv:detections-val is deprecated.  Use warehouse_sorting_msgs-srv:detections instead.")
  (detections m))
(cl:defmethod roslisp-msg-protocol:serialize ((msg <ScanRequest-response>) ostream)
  "Serializes a message object of type '<ScanRequest-response>"
  (cl:write-byte (cl:ldb (cl:byte 8 0) (cl:if (cl:slot-value msg 'success) 1 0)) ostream)
  (cl:let ((__ros_str_len (cl:length (cl:slot-value msg 'message))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) __ros_str_len) ostream))
  (cl:map cl:nil #'(cl:lambda (c) (cl:write-byte (cl:char-code c) ostream)) (cl:slot-value msg 'message))
  (roslisp-msg-protocol:serialize (cl:slot-value msg 'detections) ostream)
)
(cl:defmethod roslisp-msg-protocol:deserialize ((msg <ScanRequest-response>) istream)
  "Deserializes a message object of type '<ScanRequest-response>"
    (cl:setf (cl:slot-value msg 'success) (cl:not (cl:zerop (cl:read-byte istream))))
    (cl:let ((__ros_str_len 0))
      (cl:setf (cl:ldb (cl:byte 8 0) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:slot-value msg 'message) (cl:make-string __ros_str_len))
      (cl:dotimes (__ros_str_idx __ros_str_len msg)
        (cl:setf (cl:char (cl:slot-value msg 'message) __ros_str_idx) (cl:code-char (cl:read-byte istream)))))
  (roslisp-msg-protocol:deserialize (cl:slot-value msg 'detections) istream)
  msg
)
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql '<ScanRequest-response>)))
  "Returns string type for a service object of type '<ScanRequest-response>"
  "warehouse_sorting_msgs/ScanRequestResponse")
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'ScanRequest-response)))
  "Returns string type for a service object of type 'ScanRequest-response"
  "warehouse_sorting_msgs/ScanRequestResponse")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql '<ScanRequest-response>)))
  "Returns md5sum for a message object of type '<ScanRequest-response>"
  "c6db9a8beb3e4e03e56bddc308994352")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql 'ScanRequest-response)))
  "Returns md5sum for a message object of type 'ScanRequest-response"
  "c6db9a8beb3e4e03e56bddc308994352")
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql '<ScanRequest-response>)))
  "Returns full string definition for message of type '<ScanRequest-response>"
  (cl:format cl:nil "bool success~%string message~%warehouse_sorting_msgs/DetectedCargoArray detections~%~%~%================================================================================~%MSG: warehouse_sorting_msgs/DetectedCargoArray~%std_msgs/Header header~%warehouse_sorting_msgs/Cargo[] objects~%~%================================================================================~%MSG: std_msgs/Header~%# Standard metadata for higher-level stamped data types.~%# This is generally used to communicate timestamped data ~%# in a particular coordinate frame.~%# ~%# sequence ID: consecutively increasing ID ~%uint32 seq~%#Two-integer timestamp that is expressed as:~%# * stamp.sec: seconds (stamp_secs) since epoch (in Python the variable is called 'secs')~%# * stamp.nsec: nanoseconds since stamp_secs (in Python the variable is called 'nsecs')~%# time-handling sugar is provided by the client library~%time stamp~%#Frame this data is associated with~%string frame_id~%~%================================================================================~%MSG: warehouse_sorting_msgs/Cargo~%string cargo_id~%string cargo_type~%geometry_msgs/Pose pose~%geometry_msgs/Vector3 size~%float32 volume~%float32 confidence~%int32 bbox_x~%int32 bbox_y~%int32 bbox_width~%int32 bbox_height~%~%================================================================================~%MSG: geometry_msgs/Pose~%# A representation of pose in free space, composed of position and orientation. ~%Point position~%Quaternion orientation~%~%================================================================================~%MSG: geometry_msgs/Point~%# This contains the position of a point in free space~%float64 x~%float64 y~%float64 z~%~%================================================================================~%MSG: geometry_msgs/Quaternion~%# This represents an orientation in free space in quaternion form.~%~%float64 x~%float64 y~%float64 z~%float64 w~%~%================================================================================~%MSG: geometry_msgs/Vector3~%# This represents a vector in free space. ~%# It is only meant to represent a direction. Therefore, it does not~%# make sense to apply a translation to it (e.g., when applying a ~%# generic rigid transformation to a Vector3, tf2 will only apply the~%# rotation). If you want your data to be translatable too, use the~%# geometry_msgs/Point message instead.~%~%float64 x~%float64 y~%float64 z~%~%"))
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql 'ScanRequest-response)))
  "Returns full string definition for message of type 'ScanRequest-response"
  (cl:format cl:nil "bool success~%string message~%warehouse_sorting_msgs/DetectedCargoArray detections~%~%~%================================================================================~%MSG: warehouse_sorting_msgs/DetectedCargoArray~%std_msgs/Header header~%warehouse_sorting_msgs/Cargo[] objects~%~%================================================================================~%MSG: std_msgs/Header~%# Standard metadata for higher-level stamped data types.~%# This is generally used to communicate timestamped data ~%# in a particular coordinate frame.~%# ~%# sequence ID: consecutively increasing ID ~%uint32 seq~%#Two-integer timestamp that is expressed as:~%# * stamp.sec: seconds (stamp_secs) since epoch (in Python the variable is called 'secs')~%# * stamp.nsec: nanoseconds since stamp_secs (in Python the variable is called 'nsecs')~%# time-handling sugar is provided by the client library~%time stamp~%#Frame this data is associated with~%string frame_id~%~%================================================================================~%MSG: warehouse_sorting_msgs/Cargo~%string cargo_id~%string cargo_type~%geometry_msgs/Pose pose~%geometry_msgs/Vector3 size~%float32 volume~%float32 confidence~%int32 bbox_x~%int32 bbox_y~%int32 bbox_width~%int32 bbox_height~%~%================================================================================~%MSG: geometry_msgs/Pose~%# A representation of pose in free space, composed of position and orientation. ~%Point position~%Quaternion orientation~%~%================================================================================~%MSG: geometry_msgs/Point~%# This contains the position of a point in free space~%float64 x~%float64 y~%float64 z~%~%================================================================================~%MSG: geometry_msgs/Quaternion~%# This represents an orientation in free space in quaternion form.~%~%float64 x~%float64 y~%float64 z~%float64 w~%~%================================================================================~%MSG: geometry_msgs/Vector3~%# This represents a vector in free space. ~%# It is only meant to represent a direction. Therefore, it does not~%# make sense to apply a translation to it (e.g., when applying a ~%# generic rigid transformation to a Vector3, tf2 will only apply the~%# rotation). If you want your data to be translatable too, use the~%# geometry_msgs/Point message instead.~%~%float64 x~%float64 y~%float64 z~%~%"))
(cl:defmethod roslisp-msg-protocol:serialization-length ((msg <ScanRequest-response>))
  (cl:+ 0
     1
     4 (cl:length (cl:slot-value msg 'message))
     (roslisp-msg-protocol:serialization-length (cl:slot-value msg 'detections))
))
(cl:defmethod roslisp-msg-protocol:ros-message-to-list ((msg <ScanRequest-response>))
  "Converts a ROS message object to a list"
  (cl:list 'ScanRequest-response
    (cl:cons ':success (success msg))
    (cl:cons ':message (message msg))
    (cl:cons ':detections (detections msg))
))
(cl:defmethod roslisp-msg-protocol:service-request-type ((msg (cl:eql 'ScanRequest)))
  'ScanRequest-request)
(cl:defmethod roslisp-msg-protocol:service-response-type ((msg (cl:eql 'ScanRequest)))
  'ScanRequest-response)
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'ScanRequest)))
  "Returns string type for a service object of type '<ScanRequest>"
  "warehouse_sorting_msgs/ScanRequest")