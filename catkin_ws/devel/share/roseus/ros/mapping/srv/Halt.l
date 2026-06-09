;; Auto-generated. Do not edit!


(when (boundp 'mapping::Halt)
  (if (not (find-package "MAPPING"))
    (make-package "MAPPING"))
  (shadow 'Halt (find-package "MAPPING")))
(unless (find-package "MAPPING::HALT")
  (make-package "MAPPING::HALT"))
(unless (find-package "MAPPING::HALTREQUEST")
  (make-package "MAPPING::HALTREQUEST"))
(unless (find-package "MAPPING::HALTRESPONSE")
  (make-package "MAPPING::HALTRESPONSE"))

(in-package "ROS")





(defclass mapping::HaltRequest
  :super ros::object
  :slots (_path _name ))

(defmethod mapping::HaltRequest
  (:init
   (&key
    ((:path __path) "")
    ((:name __name) "")
    )
   (send-super :init)
   (setq _path (string __path))
   (setq _name (string __name))
   self)
  (:path
   (&optional __path)
   (if __path (setq _path __path)) _path)
  (:name
   (&optional __name)
   (if __name (setq _name __name)) _name)
  (:serialization-length
   ()
   (+
    ;; string _path
    4 (length _path)
    ;; string _name
    4 (length _name)
    ))
  (:serialize
   (&optional strm)
   (let ((s (if strm strm
              (make-string-output-stream (send self :serialization-length)))))
     ;; string _path
       (write-long (length _path) s) (princ _path s)
     ;; string _name
       (write-long (length _name) s) (princ _name s)
     ;;
     (if (null strm) (get-output-stream-string s))))
  (:deserialize
   (buf &optional (ptr- 0))
   ;; string _path
     (let (n) (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4) (setq _path (subseq buf ptr- (+ ptr- n))) (incf ptr- n))
   ;; string _name
     (let (n) (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4) (setq _name (subseq buf ptr- (+ ptr- n))) (incf ptr- n))
   ;;
   self)
  )

(defclass mapping::HaltResponse
  :super ros::object
  :slots (_success _message ))

(defmethod mapping::HaltResponse
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

(defclass mapping::Halt
  :super ros::object
  :slots ())

(setf (get mapping::Halt :md5sum-) "1ac4a6ed4aa1234807a2d8094fde8568")
(setf (get mapping::Halt :datatype-) "mapping/Halt")
(setf (get mapping::Halt :request) mapping::HaltRequest)
(setf (get mapping::Halt :response) mapping::HaltResponse)

(defmethod mapping::HaltRequest
  (:response () (instance mapping::HaltResponse :init)))

(setf (get mapping::HaltRequest :md5sum-) "1ac4a6ed4aa1234807a2d8094fde8568")
(setf (get mapping::HaltRequest :datatype-) "mapping/HaltRequest")
(setf (get mapping::HaltRequest :definition-)
      "string path # relative path under /media/mitchell/Data/Projects/software_engineering/ros_end/src/mapping/maps/
string name
---
bool success
string message
")

(setf (get mapping::HaltResponse :md5sum-) "1ac4a6ed4aa1234807a2d8094fde8568")
(setf (get mapping::HaltResponse :datatype-) "mapping/HaltResponse")
(setf (get mapping::HaltResponse :definition-)
      "string path # relative path under /media/mitchell/Data/Projects/software_engineering/ros_end/src/mapping/maps/
string name
---
bool success
string message
")



(provide :mapping/Halt "1ac4a6ed4aa1234807a2d8094fde8568")


