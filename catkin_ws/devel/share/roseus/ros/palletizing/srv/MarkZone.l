;; Auto-generated. Do not edit!


(when (boundp 'palletizing::MarkZone)
  (if (not (find-package "PALLETIZING"))
    (make-package "PALLETIZING"))
  (shadow 'MarkZone (find-package "PALLETIZING")))
(unless (find-package "PALLETIZING::MARKZONE")
  (make-package "PALLETIZING::MARKZONE"))
(unless (find-package "PALLETIZING::MARKZONEREQUEST")
  (make-package "PALLETIZING::MARKZONEREQUEST"))
(unless (find-package "PALLETIZING::MARKZONERESPONSE")
  (make-package "PALLETIZING::MARKZONERESPONSE"))

(in-package "ROS")





(defclass palletizing::MarkZoneRequest
  :super ros::object
  :slots (_zone_name _x _y _z _yaw _length _width ))

(defmethod palletizing::MarkZoneRequest
  (:init
   (&key
    ((:zone_name __zone_name) "")
    ((:x __x) 0.0)
    ((:y __y) 0.0)
    ((:z __z) 0.0)
    ((:yaw __yaw) 0.0)
    ((:length __length) 0.0)
    ((:width __width) 0.0)
    )
   (send-super :init)
   (setq _zone_name (string __zone_name))
   (setq _x (float __x))
   (setq _y (float __y))
   (setq _z (float __z))
   (setq _yaw (float __yaw))
   (setq _length (float __length))
   (setq _width (float __width))
   self)
  (:zone_name
   (&optional __zone_name)
   (if __zone_name (setq _zone_name __zone_name)) _zone_name)
  (:x
   (&optional __x)
   (if __x (setq _x __x)) _x)
  (:y
   (&optional __y)
   (if __y (setq _y __y)) _y)
  (:z
   (&optional __z)
   (if __z (setq _z __z)) _z)
  (:yaw
   (&optional __yaw)
   (if __yaw (setq _yaw __yaw)) _yaw)
  (:length
   (&optional __length)
   (if __length (setq _length __length)) _length)
  (:width
   (&optional __width)
   (if __width (setq _width __width)) _width)
  (:serialization-length
   ()
   (+
    ;; string _zone_name
    4 (length _zone_name)
    ;; float64 _x
    8
    ;; float64 _y
    8
    ;; float64 _z
    8
    ;; float64 _yaw
    8
    ;; float64 _length
    8
    ;; float64 _width
    8
    ))
  (:serialize
   (&optional strm)
   (let ((s (if strm strm
              (make-string-output-stream (send self :serialization-length)))))
     ;; string _zone_name
       (write-long (length _zone_name) s) (princ _zone_name s)
     ;; float64 _x
       (sys::poke _x (send s :buffer) (send s :count) :double) (incf (stream-count s) 8)
     ;; float64 _y
       (sys::poke _y (send s :buffer) (send s :count) :double) (incf (stream-count s) 8)
     ;; float64 _z
       (sys::poke _z (send s :buffer) (send s :count) :double) (incf (stream-count s) 8)
     ;; float64 _yaw
       (sys::poke _yaw (send s :buffer) (send s :count) :double) (incf (stream-count s) 8)
     ;; float64 _length
       (sys::poke _length (send s :buffer) (send s :count) :double) (incf (stream-count s) 8)
     ;; float64 _width
       (sys::poke _width (send s :buffer) (send s :count) :double) (incf (stream-count s) 8)
     ;;
     (if (null strm) (get-output-stream-string s))))
  (:deserialize
   (buf &optional (ptr- 0))
   ;; string _zone_name
     (let (n) (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4) (setq _zone_name (subseq buf ptr- (+ ptr- n))) (incf ptr- n))
   ;; float64 _x
     (setq _x (sys::peek buf ptr- :double)) (incf ptr- 8)
   ;; float64 _y
     (setq _y (sys::peek buf ptr- :double)) (incf ptr- 8)
   ;; float64 _z
     (setq _z (sys::peek buf ptr- :double)) (incf ptr- 8)
   ;; float64 _yaw
     (setq _yaw (sys::peek buf ptr- :double)) (incf ptr- 8)
   ;; float64 _length
     (setq _length (sys::peek buf ptr- :double)) (incf ptr- 8)
   ;; float64 _width
     (setq _width (sys::peek buf ptr- :double)) (incf ptr- 8)
   ;;
   self)
  )

(defclass palletizing::MarkZoneResponse
  :super ros::object
  :slots (_success ))

(defmethod palletizing::MarkZoneResponse
  (:init
   (&key
    ((:success __success) nil)
    )
   (send-super :init)
   (setq _success __success)
   self)
  (:success
   (&optional (__success :null))
   (if (not (eq __success :null)) (setq _success __success)) _success)
  (:serialization-length
   ()
   (+
    ;; bool _success
    1
    ))
  (:serialize
   (&optional strm)
   (let ((s (if strm strm
              (make-string-output-stream (send self :serialization-length)))))
     ;; bool _success
       (if _success (write-byte -1 s) (write-byte 0 s))
     ;;
     (if (null strm) (get-output-stream-string s))))
  (:deserialize
   (buf &optional (ptr- 0))
   ;; bool _success
     (setq _success (not (= 0 (sys::peek buf ptr- :char)))) (incf ptr- 1)
   ;;
   self)
  )

(defclass palletizing::MarkZone
  :super ros::object
  :slots ())

(setf (get palletizing::MarkZone :md5sum-) "5878b2b5be49cb4126351933277cdaa2")
(setf (get palletizing::MarkZone :datatype-) "palletizing/MarkZone")
(setf (get palletizing::MarkZone :request) palletizing::MarkZoneRequest)
(setf (get palletizing::MarkZone :response) palletizing::MarkZoneResponse)

(defmethod palletizing::MarkZoneRequest
  (:response () (instance palletizing::MarkZoneResponse :init)))

(setf (get palletizing::MarkZoneRequest :md5sum-) "5878b2b5be49cb4126351933277cdaa2")
(setf (get palletizing::MarkZoneRequest :datatype-) "palletizing/MarkZoneRequest")
(setf (get palletizing::MarkZoneRequest :definition-)
      "string zone_name      # 'source' or 'dest'
float64 x
float64 y
float64 z
float64 yaw           # 桌面朝向 (radians in /map frame)
float64 length        # 桌面长度 (沿朝向方向, m)
float64 width         # 桌面宽度/深度 (垂直朝向方向, m)
---
bool success

")

(setf (get palletizing::MarkZoneResponse :md5sum-) "5878b2b5be49cb4126351933277cdaa2")
(setf (get palletizing::MarkZoneResponse :datatype-) "palletizing/MarkZoneResponse")
(setf (get palletizing::MarkZoneResponse :definition-)
      "string zone_name      # 'source' or 'dest'
float64 x
float64 y
float64 z
float64 yaw           # 桌面朝向 (radians in /map frame)
float64 length        # 桌面长度 (沿朝向方向, m)
float64 width         # 桌面宽度/深度 (垂直朝向方向, m)
---
bool success

")



(provide :palletizing/MarkZone "5878b2b5be49cb4126351933277cdaa2")


