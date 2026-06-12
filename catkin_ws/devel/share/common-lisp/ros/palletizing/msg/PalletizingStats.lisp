; Auto-generated. Do not edit!


(cl:in-package palletizing-msg)


;//! \htmlinclude PalletizingStats.msg.html

(cl:defclass <PalletizingStats> (roslisp-msg-protocol:ros-message)
  ((total_objects
    :reader total_objects
    :initarg :total_objects
    :type cl:integer
    :initform 0)
   (success_count
    :reader success_count
    :initarg :success_count
    :type cl:integer
    :initform 0)
   (fail_count
    :reader fail_count
    :initarg :fail_count
    :type cl:integer
    :initform 0)
   (current_layer
    :reader current_layer
    :initarg :current_layer
    :type cl:integer
    :initform 0)
   (hard_zone_layers
    :reader hard_zone_layers
    :initarg :hard_zone_layers
    :type cl:integer
    :initform 0)
   (soft_zone_layers
    :reader soft_zone_layers
    :initarg :soft_zone_layers
    :type cl:integer
    :initform 0)
   (success_rate
    :reader success_rate
    :initarg :success_rate
    :type cl:float
    :initform 0.0)
   (avg_cycle_time
    :reader avg_cycle_time
    :initarg :avg_cycle_time
    :type cl:float
    :initform 0.0)
   (elapsed_time
    :reader elapsed_time
    :initarg :elapsed_time
    :type cl:float
    :initform 0.0)
   (current_state
    :reader current_state
    :initarg :current_state
    :type cl:string
    :initform ""))
)

(cl:defclass PalletizingStats (<PalletizingStats>)
  ())

(cl:defmethod cl:initialize-instance :after ((m <PalletizingStats>) cl:&rest args)
  (cl:declare (cl:ignorable args))
  (cl:unless (cl:typep m 'PalletizingStats)
    (roslisp-msg-protocol:msg-deprecation-warning "using old message class name palletizing-msg:<PalletizingStats> is deprecated: use palletizing-msg:PalletizingStats instead.")))

(cl:ensure-generic-function 'total_objects-val :lambda-list '(m))
(cl:defmethod total_objects-val ((m <PalletizingStats>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader palletizing-msg:total_objects-val is deprecated.  Use palletizing-msg:total_objects instead.")
  (total_objects m))

(cl:ensure-generic-function 'success_count-val :lambda-list '(m))
(cl:defmethod success_count-val ((m <PalletizingStats>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader palletizing-msg:success_count-val is deprecated.  Use palletizing-msg:success_count instead.")
  (success_count m))

(cl:ensure-generic-function 'fail_count-val :lambda-list '(m))
(cl:defmethod fail_count-val ((m <PalletizingStats>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader palletizing-msg:fail_count-val is deprecated.  Use palletizing-msg:fail_count instead.")
  (fail_count m))

(cl:ensure-generic-function 'current_layer-val :lambda-list '(m))
(cl:defmethod current_layer-val ((m <PalletizingStats>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader palletizing-msg:current_layer-val is deprecated.  Use palletizing-msg:current_layer instead.")
  (current_layer m))

(cl:ensure-generic-function 'hard_zone_layers-val :lambda-list '(m))
(cl:defmethod hard_zone_layers-val ((m <PalletizingStats>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader palletizing-msg:hard_zone_layers-val is deprecated.  Use palletizing-msg:hard_zone_layers instead.")
  (hard_zone_layers m))

(cl:ensure-generic-function 'soft_zone_layers-val :lambda-list '(m))
(cl:defmethod soft_zone_layers-val ((m <PalletizingStats>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader palletizing-msg:soft_zone_layers-val is deprecated.  Use palletizing-msg:soft_zone_layers instead.")
  (soft_zone_layers m))

(cl:ensure-generic-function 'success_rate-val :lambda-list '(m))
(cl:defmethod success_rate-val ((m <PalletizingStats>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader palletizing-msg:success_rate-val is deprecated.  Use palletizing-msg:success_rate instead.")
  (success_rate m))

(cl:ensure-generic-function 'avg_cycle_time-val :lambda-list '(m))
(cl:defmethod avg_cycle_time-val ((m <PalletizingStats>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader palletizing-msg:avg_cycle_time-val is deprecated.  Use palletizing-msg:avg_cycle_time instead.")
  (avg_cycle_time m))

(cl:ensure-generic-function 'elapsed_time-val :lambda-list '(m))
(cl:defmethod elapsed_time-val ((m <PalletizingStats>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader palletizing-msg:elapsed_time-val is deprecated.  Use palletizing-msg:elapsed_time instead.")
  (elapsed_time m))

(cl:ensure-generic-function 'current_state-val :lambda-list '(m))
(cl:defmethod current_state-val ((m <PalletizingStats>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader palletizing-msg:current_state-val is deprecated.  Use palletizing-msg:current_state instead.")
  (current_state m))
(cl:defmethod roslisp-msg-protocol:serialize ((msg <PalletizingStats>) ostream)
  "Serializes a message object of type '<PalletizingStats>"
  (cl:write-byte (cl:ldb (cl:byte 8 0) (cl:slot-value msg 'total_objects)) ostream)
  (cl:write-byte (cl:ldb (cl:byte 8 8) (cl:slot-value msg 'total_objects)) ostream)
  (cl:write-byte (cl:ldb (cl:byte 8 16) (cl:slot-value msg 'total_objects)) ostream)
  (cl:write-byte (cl:ldb (cl:byte 8 24) (cl:slot-value msg 'total_objects)) ostream)
  (cl:write-byte (cl:ldb (cl:byte 8 0) (cl:slot-value msg 'success_count)) ostream)
  (cl:write-byte (cl:ldb (cl:byte 8 8) (cl:slot-value msg 'success_count)) ostream)
  (cl:write-byte (cl:ldb (cl:byte 8 16) (cl:slot-value msg 'success_count)) ostream)
  (cl:write-byte (cl:ldb (cl:byte 8 24) (cl:slot-value msg 'success_count)) ostream)
  (cl:write-byte (cl:ldb (cl:byte 8 0) (cl:slot-value msg 'fail_count)) ostream)
  (cl:write-byte (cl:ldb (cl:byte 8 8) (cl:slot-value msg 'fail_count)) ostream)
  (cl:write-byte (cl:ldb (cl:byte 8 16) (cl:slot-value msg 'fail_count)) ostream)
  (cl:write-byte (cl:ldb (cl:byte 8 24) (cl:slot-value msg 'fail_count)) ostream)
  (cl:write-byte (cl:ldb (cl:byte 8 0) (cl:slot-value msg 'current_layer)) ostream)
  (cl:write-byte (cl:ldb (cl:byte 8 8) (cl:slot-value msg 'current_layer)) ostream)
  (cl:write-byte (cl:ldb (cl:byte 8 16) (cl:slot-value msg 'current_layer)) ostream)
  (cl:write-byte (cl:ldb (cl:byte 8 24) (cl:slot-value msg 'current_layer)) ostream)
  (cl:write-byte (cl:ldb (cl:byte 8 0) (cl:slot-value msg 'hard_zone_layers)) ostream)
  (cl:write-byte (cl:ldb (cl:byte 8 8) (cl:slot-value msg 'hard_zone_layers)) ostream)
  (cl:write-byte (cl:ldb (cl:byte 8 16) (cl:slot-value msg 'hard_zone_layers)) ostream)
  (cl:write-byte (cl:ldb (cl:byte 8 24) (cl:slot-value msg 'hard_zone_layers)) ostream)
  (cl:write-byte (cl:ldb (cl:byte 8 0) (cl:slot-value msg 'soft_zone_layers)) ostream)
  (cl:write-byte (cl:ldb (cl:byte 8 8) (cl:slot-value msg 'soft_zone_layers)) ostream)
  (cl:write-byte (cl:ldb (cl:byte 8 16) (cl:slot-value msg 'soft_zone_layers)) ostream)
  (cl:write-byte (cl:ldb (cl:byte 8 24) (cl:slot-value msg 'soft_zone_layers)) ostream)
  (cl:let ((bits (roslisp-utils:encode-double-float-bits (cl:slot-value msg 'success_rate))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 32) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 40) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 48) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 56) bits) ostream))
  (cl:let ((bits (roslisp-utils:encode-double-float-bits (cl:slot-value msg 'avg_cycle_time))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 32) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 40) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 48) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 56) bits) ostream))
  (cl:let ((bits (roslisp-utils:encode-double-float-bits (cl:slot-value msg 'elapsed_time))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 32) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 40) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 48) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 56) bits) ostream))
  (cl:let ((__ros_str_len (cl:length (cl:slot-value msg 'current_state))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) __ros_str_len) ostream))
  (cl:map cl:nil #'(cl:lambda (c) (cl:write-byte (cl:char-code c) ostream)) (cl:slot-value msg 'current_state))
)
(cl:defmethod roslisp-msg-protocol:deserialize ((msg <PalletizingStats>) istream)
  "Deserializes a message object of type '<PalletizingStats>"
    (cl:setf (cl:ldb (cl:byte 8 0) (cl:slot-value msg 'total_objects)) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 8) (cl:slot-value msg 'total_objects)) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 16) (cl:slot-value msg 'total_objects)) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 24) (cl:slot-value msg 'total_objects)) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 0) (cl:slot-value msg 'success_count)) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 8) (cl:slot-value msg 'success_count)) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 16) (cl:slot-value msg 'success_count)) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 24) (cl:slot-value msg 'success_count)) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 0) (cl:slot-value msg 'fail_count)) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 8) (cl:slot-value msg 'fail_count)) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 16) (cl:slot-value msg 'fail_count)) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 24) (cl:slot-value msg 'fail_count)) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 0) (cl:slot-value msg 'current_layer)) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 8) (cl:slot-value msg 'current_layer)) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 16) (cl:slot-value msg 'current_layer)) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 24) (cl:slot-value msg 'current_layer)) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 0) (cl:slot-value msg 'hard_zone_layers)) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 8) (cl:slot-value msg 'hard_zone_layers)) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 16) (cl:slot-value msg 'hard_zone_layers)) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 24) (cl:slot-value msg 'hard_zone_layers)) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 0) (cl:slot-value msg 'soft_zone_layers)) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 8) (cl:slot-value msg 'soft_zone_layers)) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 16) (cl:slot-value msg 'soft_zone_layers)) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 24) (cl:slot-value msg 'soft_zone_layers)) (cl:read-byte istream))
    (cl:let ((bits 0))
      (cl:setf (cl:ldb (cl:byte 8 0) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 32) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 40) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 48) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 56) bits) (cl:read-byte istream))
    (cl:setf (cl:slot-value msg 'success_rate) (roslisp-utils:decode-double-float-bits bits)))
    (cl:let ((bits 0))
      (cl:setf (cl:ldb (cl:byte 8 0) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 32) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 40) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 48) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 56) bits) (cl:read-byte istream))
    (cl:setf (cl:slot-value msg 'avg_cycle_time) (roslisp-utils:decode-double-float-bits bits)))
    (cl:let ((bits 0))
      (cl:setf (cl:ldb (cl:byte 8 0) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 32) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 40) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 48) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 56) bits) (cl:read-byte istream))
    (cl:setf (cl:slot-value msg 'elapsed_time) (roslisp-utils:decode-double-float-bits bits)))
    (cl:let ((__ros_str_len 0))
      (cl:setf (cl:ldb (cl:byte 8 0) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:slot-value msg 'current_state) (cl:make-string __ros_str_len))
      (cl:dotimes (__ros_str_idx __ros_str_len msg)
        (cl:setf (cl:char (cl:slot-value msg 'current_state) __ros_str_idx) (cl:code-char (cl:read-byte istream)))))
  msg
)
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql '<PalletizingStats>)))
  "Returns string type for a message object of type '<PalletizingStats>"
  "palletizing/PalletizingStats")
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'PalletizingStats)))
  "Returns string type for a message object of type 'PalletizingStats"
  "palletizing/PalletizingStats")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql '<PalletizingStats>)))
  "Returns md5sum for a message object of type '<PalletizingStats>"
  "92aa1e36e09f1e3fca1e85e1659ad3fe")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql 'PalletizingStats)))
  "Returns md5sum for a message object of type 'PalletizingStats"
  "92aa1e36e09f1e3fca1e85e1659ad3fe")
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql '<PalletizingStats>)))
  "Returns full string definition for message of type '<PalletizingStats>"
  (cl:format cl:nil "uint32 total_objects~%uint32 success_count~%uint32 fail_count~%uint32 current_layer~%uint32 hard_zone_layers~%uint32 soft_zone_layers~%float64 success_rate~%float64 avg_cycle_time~%float64 elapsed_time~%string current_state~%~%~%"))
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql 'PalletizingStats)))
  "Returns full string definition for message of type 'PalletizingStats"
  (cl:format cl:nil "uint32 total_objects~%uint32 success_count~%uint32 fail_count~%uint32 current_layer~%uint32 hard_zone_layers~%uint32 soft_zone_layers~%float64 success_rate~%float64 avg_cycle_time~%float64 elapsed_time~%string current_state~%~%~%"))
(cl:defmethod roslisp-msg-protocol:serialization-length ((msg <PalletizingStats>))
  (cl:+ 0
     4
     4
     4
     4
     4
     4
     8
     8
     8
     4 (cl:length (cl:slot-value msg 'current_state))
))
(cl:defmethod roslisp-msg-protocol:ros-message-to-list ((msg <PalletizingStats>))
  "Converts a ROS message object to a list"
  (cl:list 'PalletizingStats
    (cl:cons ':total_objects (total_objects msg))
    (cl:cons ':success_count (success_count msg))
    (cl:cons ':fail_count (fail_count msg))
    (cl:cons ':current_layer (current_layer msg))
    (cl:cons ':hard_zone_layers (hard_zone_layers msg))
    (cl:cons ':soft_zone_layers (soft_zone_layers msg))
    (cl:cons ':success_rate (success_rate msg))
    (cl:cons ':avg_cycle_time (avg_cycle_time msg))
    (cl:cons ':elapsed_time (elapsed_time msg))
    (cl:cons ':current_state (current_state msg))
))
