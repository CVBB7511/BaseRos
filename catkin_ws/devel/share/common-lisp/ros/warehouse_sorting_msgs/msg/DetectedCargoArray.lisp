; Auto-generated. Do not edit!


(cl:in-package warehouse_sorting_msgs-msg)


;//! \htmlinclude DetectedCargoArray.msg.html

(cl:defclass <DetectedCargoArray> (roslisp-msg-protocol:ros-message)
  ((header
    :reader header
    :initarg :header
    :type std_msgs-msg:Header
    :initform (cl:make-instance 'std_msgs-msg:Header))
   (objects
    :reader objects
    :initarg :objects
    :type (cl:vector warehouse_sorting_msgs-msg:Cargo)
   :initform (cl:make-array 0 :element-type 'warehouse_sorting_msgs-msg:Cargo :initial-element (cl:make-instance 'warehouse_sorting_msgs-msg:Cargo))))
)

(cl:defclass DetectedCargoArray (<DetectedCargoArray>)
  ())

(cl:defmethod cl:initialize-instance :after ((m <DetectedCargoArray>) cl:&rest args)
  (cl:declare (cl:ignorable args))
  (cl:unless (cl:typep m 'DetectedCargoArray)
    (roslisp-msg-protocol:msg-deprecation-warning "using old message class name warehouse_sorting_msgs-msg:<DetectedCargoArray> is deprecated: use warehouse_sorting_msgs-msg:DetectedCargoArray instead.")))

(cl:ensure-generic-function 'header-val :lambda-list '(m))
(cl:defmethod header-val ((m <DetectedCargoArray>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader warehouse_sorting_msgs-msg:header-val is deprecated.  Use warehouse_sorting_msgs-msg:header instead.")
  (header m))

(cl:ensure-generic-function 'objects-val :lambda-list '(m))
(cl:defmethod objects-val ((m <DetectedCargoArray>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader warehouse_sorting_msgs-msg:objects-val is deprecated.  Use warehouse_sorting_msgs-msg:objects instead.")
  (objects m))
(cl:defmethod roslisp-msg-protocol:serialize ((msg <DetectedCargoArray>) ostream)
  "Serializes a message object of type '<DetectedCargoArray>"
  (roslisp-msg-protocol:serialize (cl:slot-value msg 'header) ostream)
  (cl:let ((__ros_arr_len (cl:length (cl:slot-value msg 'objects))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) __ros_arr_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) __ros_arr_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) __ros_arr_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) __ros_arr_len) ostream))
  (cl:map cl:nil #'(cl:lambda (ele) (roslisp-msg-protocol:serialize ele ostream))
   (cl:slot-value msg 'objects))
)
(cl:defmethod roslisp-msg-protocol:deserialize ((msg <DetectedCargoArray>) istream)
  "Deserializes a message object of type '<DetectedCargoArray>"
  (roslisp-msg-protocol:deserialize (cl:slot-value msg 'header) istream)
  (cl:let ((__ros_arr_len 0))
    (cl:setf (cl:ldb (cl:byte 8 0) __ros_arr_len) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 8) __ros_arr_len) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 16) __ros_arr_len) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 24) __ros_arr_len) (cl:read-byte istream))
  (cl:setf (cl:slot-value msg 'objects) (cl:make-array __ros_arr_len))
  (cl:let ((vals (cl:slot-value msg 'objects)))
    (cl:dotimes (i __ros_arr_len)
    (cl:setf (cl:aref vals i) (cl:make-instance 'warehouse_sorting_msgs-msg:Cargo))
  (roslisp-msg-protocol:deserialize (cl:aref vals i) istream))))
  msg
)
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql '<DetectedCargoArray>)))
  "Returns string type for a message object of type '<DetectedCargoArray>"
  "warehouse_sorting_msgs/DetectedCargoArray")
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'DetectedCargoArray)))
  "Returns string type for a message object of type 'DetectedCargoArray"
  "warehouse_sorting_msgs/DetectedCargoArray")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql '<DetectedCargoArray>)))
  "Returns md5sum for a message object of type '<DetectedCargoArray>"
  "753fda52a894cc2e000a484354dd94f2")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql 'DetectedCargoArray)))
  "Returns md5sum for a message object of type 'DetectedCargoArray"
  "753fda52a894cc2e000a484354dd94f2")
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql '<DetectedCargoArray>)))
  "Returns full string definition for message of type '<DetectedCargoArray>"
  (cl:format cl:nil "std_msgs/Header header~%warehouse_sorting_msgs/Cargo[] objects~%~%================================================================================~%MSG: std_msgs/Header~%# Standard metadata for higher-level stamped data types.~%# This is generally used to communicate timestamped data ~%# in a particular coordinate frame.~%# ~%# sequence ID: consecutively increasing ID ~%uint32 seq~%#Two-integer timestamp that is expressed as:~%# * stamp.sec: seconds (stamp_secs) since epoch (in Python the variable is called 'secs')~%# * stamp.nsec: nanoseconds since stamp_secs (in Python the variable is called 'nsecs')~%# time-handling sugar is provided by the client library~%time stamp~%#Frame this data is associated with~%string frame_id~%~%================================================================================~%MSG: warehouse_sorting_msgs/Cargo~%string cargo_id~%string cargo_type~%geometry_msgs/Pose pose~%geometry_msgs/Vector3 size~%float32 volume~%float32 confidence~%int32 bbox_x~%int32 bbox_y~%int32 bbox_width~%int32 bbox_height~%~%================================================================================~%MSG: geometry_msgs/Pose~%# A representation of pose in free space, composed of position and orientation. ~%Point position~%Quaternion orientation~%~%================================================================================~%MSG: geometry_msgs/Point~%# This contains the position of a point in free space~%float64 x~%float64 y~%float64 z~%~%================================================================================~%MSG: geometry_msgs/Quaternion~%# This represents an orientation in free space in quaternion form.~%~%float64 x~%float64 y~%float64 z~%float64 w~%~%================================================================================~%MSG: geometry_msgs/Vector3~%# This represents a vector in free space. ~%# It is only meant to represent a direction. Therefore, it does not~%# make sense to apply a translation to it (e.g., when applying a ~%# generic rigid transformation to a Vector3, tf2 will only apply the~%# rotation). If you want your data to be translatable too, use the~%# geometry_msgs/Point message instead.~%~%float64 x~%float64 y~%float64 z~%~%"))
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql 'DetectedCargoArray)))
  "Returns full string definition for message of type 'DetectedCargoArray"
  (cl:format cl:nil "std_msgs/Header header~%warehouse_sorting_msgs/Cargo[] objects~%~%================================================================================~%MSG: std_msgs/Header~%# Standard metadata for higher-level stamped data types.~%# This is generally used to communicate timestamped data ~%# in a particular coordinate frame.~%# ~%# sequence ID: consecutively increasing ID ~%uint32 seq~%#Two-integer timestamp that is expressed as:~%# * stamp.sec: seconds (stamp_secs) since epoch (in Python the variable is called 'secs')~%# * stamp.nsec: nanoseconds since stamp_secs (in Python the variable is called 'nsecs')~%# time-handling sugar is provided by the client library~%time stamp~%#Frame this data is associated with~%string frame_id~%~%================================================================================~%MSG: warehouse_sorting_msgs/Cargo~%string cargo_id~%string cargo_type~%geometry_msgs/Pose pose~%geometry_msgs/Vector3 size~%float32 volume~%float32 confidence~%int32 bbox_x~%int32 bbox_y~%int32 bbox_width~%int32 bbox_height~%~%================================================================================~%MSG: geometry_msgs/Pose~%# A representation of pose in free space, composed of position and orientation. ~%Point position~%Quaternion orientation~%~%================================================================================~%MSG: geometry_msgs/Point~%# This contains the position of a point in free space~%float64 x~%float64 y~%float64 z~%~%================================================================================~%MSG: geometry_msgs/Quaternion~%# This represents an orientation in free space in quaternion form.~%~%float64 x~%float64 y~%float64 z~%float64 w~%~%================================================================================~%MSG: geometry_msgs/Vector3~%# This represents a vector in free space. ~%# It is only meant to represent a direction. Therefore, it does not~%# make sense to apply a translation to it (e.g., when applying a ~%# generic rigid transformation to a Vector3, tf2 will only apply the~%# rotation). If you want your data to be translatable too, use the~%# geometry_msgs/Point message instead.~%~%float64 x~%float64 y~%float64 z~%~%"))
(cl:defmethod roslisp-msg-protocol:serialization-length ((msg <DetectedCargoArray>))
  (cl:+ 0
     (roslisp-msg-protocol:serialization-length (cl:slot-value msg 'header))
     4 (cl:reduce #'cl:+ (cl:slot-value msg 'objects) :key #'(cl:lambda (ele) (cl:declare (cl:ignorable ele)) (cl:+ (roslisp-msg-protocol:serialization-length ele))))
))
(cl:defmethod roslisp-msg-protocol:ros-message-to-list ((msg <DetectedCargoArray>))
  "Converts a ROS message object to a list"
  (cl:list 'DetectedCargoArray
    (cl:cons ':header (header msg))
    (cl:cons ':objects (objects msg))
))
