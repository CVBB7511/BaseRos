;; Auto-generated. Do not edit!


(when (boundp 'arm_controller::Place)
  (if (not (find-package "ARM_CONTROLLER"))
    (make-package "ARM_CONTROLLER"))
  (shadow 'Place (find-package "ARM_CONTROLLER")))
(unless (find-package "ARM_CONTROLLER::PLACE")
  (make-package "ARM_CONTROLLER::PLACE"))
(unless (find-package "ARM_CONTROLLER::PLACEREQUEST")
  (make-package "ARM_CONTROLLER::PLACEREQUEST"))
(unless (find-package "ARM_CONTROLLER::PLACERESPONSE")
  (make-package "ARM_CONTROLLER::PLACERESPONSE"))

(in-package "ROS")





(defclass arm_controller::PlaceRequest
  :super ros::object
  :slots (_x _y _z ))

(defmethod arm_controller::PlaceRequest
  (:init
   (&key
    ((:x __x) 0.0)
    ((:y __y) 0.0)
    ((:z __z) 0.0)
    )
   (send-super :init)
   (setq _x (float __x))
   (setq _y (float __y))
   (setq _z (float __z))
   self)
  (:x
   (&optional __x)
   (if __x (setq _x __x)) _x)
  (:y
   (&optional __y)
   (if __y (setq _y __y)) _y)
  (:z
   (&optional __z)
   (if __z (setq _z __z)) _z)
  (:serialization-length
   ()
   (+
    ;; float64 _x
    8
    ;; float64 _y
    8
    ;; float64 _z
    8
    ))
  (:serialize
   (&optional strm)
   (let ((s (if strm strm
              (make-string-output-stream (send self :serialization-length)))))
     ;; float64 _x
       (sys::poke _x (send s :buffer) (send s :count) :double) (incf (stream-count s) 8)
     ;; float64 _y
       (sys::poke _y (send s :buffer) (send s :count) :double) (incf (stream-count s) 8)
     ;; float64 _z
       (sys::poke _z (send s :buffer) (send s :count) :double) (incf (stream-count s) 8)
     ;;
     (if (null strm) (get-output-stream-string s))))
  (:deserialize
   (buf &optional (ptr- 0))
   ;; float64 _x
     (setq _x (sys::peek buf ptr- :double)) (incf ptr- 8)
   ;; float64 _y
     (setq _y (sys::peek buf ptr- :double)) (incf ptr- 8)
   ;; float64 _z
     (setq _z (sys::peek buf ptr- :double)) (incf ptr- 8)
   ;;
   self)
  )

(defclass arm_controller::PlaceResponse
  :super ros::object
  :slots (_message ))

(defmethod arm_controller::PlaceResponse
  (:init
   (&key
    ((:message __message) "")
    )
   (send-super :init)
   (setq _message (string __message))
   self)
  (:message
   (&optional __message)
   (if __message (setq _message __message)) _message)
  (:serialization-length
   ()
   (+
    ;; string _message
    4 (length _message)
    ))
  (:serialize
   (&optional strm)
   (let ((s (if strm strm
              (make-string-output-stream (send self :serialization-length)))))
     ;; string _message
       (write-long (length _message) s) (princ _message s)
     ;;
     (if (null strm) (get-output-stream-string s))))
  (:deserialize
   (buf &optional (ptr- 0))
   ;; string _message
     (let (n) (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4) (setq _message (subseq buf ptr- (+ ptr- n))) (incf ptr- n))
   ;;
   self)
  )

(defclass arm_controller::Place
  :super ros::object
  :slots ())

(setf (get arm_controller::Place :md5sum-) "5803e061cc1e0e9a20474f69197b6e98")
(setf (get arm_controller::Place :datatype-) "arm_controller/Place")
(setf (get arm_controller::Place :request) arm_controller::PlaceRequest)
(setf (get arm_controller::Place :response) arm_controller::PlaceResponse)

(defmethod arm_controller::PlaceRequest
  (:response () (instance arm_controller::PlaceResponse :init)))

(setf (get arm_controller::PlaceRequest :md5sum-) "5803e061cc1e0e9a20474f69197b6e98")
(setf (get arm_controller::PlaceRequest :datatype-) "arm_controller/PlaceRequest")
(setf (get arm_controller::PlaceRequest :definition-)
      "float64 x
float64 y
float64 z
---
string message
")

(setf (get arm_controller::PlaceResponse :md5sum-) "5803e061cc1e0e9a20474f69197b6e98")
(setf (get arm_controller::PlaceResponse :datatype-) "arm_controller/PlaceResponse")
(setf (get arm_controller::PlaceResponse :definition-)
      "float64 x
float64 y
float64 z
---
string message
")



(provide :arm_controller/Place "5803e061cc1e0e9a20474f69197b6e98")


