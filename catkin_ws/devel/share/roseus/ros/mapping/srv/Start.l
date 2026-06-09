;; Auto-generated. Do not edit!


(when (boundp 'mapping::Start)
  (if (not (find-package "MAPPING"))
    (make-package "MAPPING"))
  (shadow 'Start (find-package "MAPPING")))
(unless (find-package "MAPPING::START")
  (make-package "MAPPING::START"))
(unless (find-package "MAPPING::STARTREQUEST")
  (make-package "MAPPING::STARTREQUEST"))
(unless (find-package "MAPPING::STARTRESPONSE")
  (make-package "MAPPING::STARTRESPONSE"))

(in-package "ROS")





(defclass mapping::StartRequest
  :super ros::object
  :slots (_sim _width _height ))

(defmethod mapping::StartRequest
  (:init
   (&key
    ((:sim __sim) nil)
    ((:width __width) 0.0)
    ((:height __height) 0.0)
    )
   (send-super :init)
   (setq _sim __sim)
   (setq _width (float __width))
   (setq _height (float __height))
   self)
  (:sim
   (&optional (__sim :null))
   (if (not (eq __sim :null)) (setq _sim __sim)) _sim)
  (:width
   (&optional __width)
   (if __width (setq _width __width)) _width)
  (:height
   (&optional __height)
   (if __height (setq _height __height)) _height)
  (:serialization-length
   ()
   (+
    ;; bool _sim
    1
    ;; float64 _width
    8
    ;; float64 _height
    8
    ))
  (:serialize
   (&optional strm)
   (let ((s (if strm strm
              (make-string-output-stream (send self :serialization-length)))))
     ;; bool _sim
       (if _sim (write-byte -1 s) (write-byte 0 s))
     ;; float64 _width
       (sys::poke _width (send s :buffer) (send s :count) :double) (incf (stream-count s) 8)
     ;; float64 _height
       (sys::poke _height (send s :buffer) (send s :count) :double) (incf (stream-count s) 8)
     ;;
     (if (null strm) (get-output-stream-string s))))
  (:deserialize
   (buf &optional (ptr- 0))
   ;; bool _sim
     (setq _sim (not (= 0 (sys::peek buf ptr- :char)))) (incf ptr- 1)
   ;; float64 _width
     (setq _width (sys::peek buf ptr- :double)) (incf ptr- 8)
   ;; float64 _height
     (setq _height (sys::peek buf ptr- :double)) (incf ptr- 8)
   ;;
   self)
  )

(defclass mapping::StartResponse
  :super ros::object
  :slots (_success _message ))

(defmethod mapping::StartResponse
  (:init
   (&key
    ((:success __success) nil)
    ((:message __message) "")
    )
   (send-super :init)
   (setq _success __success)
   (setq _message (string __message))
   self)
  (:success
   (&optional (__success :null))
   (if (not (eq __success :null)) (setq _success __success)) _success)
  (:message
   (&optional __message)
   (if __message (setq _message __message)) _message)
  (:serialization-length
   ()
   (+
    ;; bool _success
    1
    ;; string _message
    4 (length _message)
    ))
  (:serialize
   (&optional strm)
   (let ((s (if strm strm
              (make-string-output-stream (send self :serialization-length)))))
     ;; bool _success
       (if _success (write-byte -1 s) (write-byte 0 s))
     ;; string _message
       (write-long (length _message) s) (princ _message s)
     ;;
     (if (null strm) (get-output-stream-string s))))
  (:deserialize
   (buf &optional (ptr- 0))
   ;; bool _success
     (setq _success (not (= 0 (sys::peek buf ptr- :char)))) (incf ptr- 1)
   ;; string _message
     (let (n) (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4) (setq _message (subseq buf ptr- (+ ptr- n))) (incf ptr- n))
   ;;
   self)
  )

(defclass mapping::Start
  :super ros::object
  :slots ())

(setf (get mapping::Start :md5sum-) "4dca6bc64797f691acd5d21876b3c9f4")
(setf (get mapping::Start :datatype-) "mapping/Start")
(setf (get mapping::Start :request) mapping::StartRequest)
(setf (get mapping::Start :response) mapping::StartResponse)

(defmethod mapping::StartRequest
  (:response () (instance mapping::StartResponse :init)))

(setf (get mapping::StartRequest :md5sum-) "4dca6bc64797f691acd5d21876b3c9f4")
(setf (get mapping::StartRequest :datatype-) "mapping/StartRequest")
(setf (get mapping::StartRequest :definition-)
      "bool sim # 明确是在仿真环境内还是在实际场景中
float64 width
float64 height
---
bool success
string message
")

(setf (get mapping::StartResponse :md5sum-) "4dca6bc64797f691acd5d21876b3c9f4")
(setf (get mapping::StartResponse :datatype-) "mapping/StartResponse")
(setf (get mapping::StartResponse :definition-)
      "bool sim # 明确是在仿真环境内还是在实际场景中
float64 width
float64 height
---
bool success
string message
")



(provide :mapping/Start "4dca6bc64797f691acd5d21876b3c9f4")


