;; Auto-generated. Do not edit!


(when (boundp 'navigation::Start)
  (if (not (find-package "NAVIGATION"))
    (make-package "NAVIGATION"))
  (shadow 'Start (find-package "NAVIGATION")))
(unless (find-package "NAVIGATION::START")
  (make-package "NAVIGATION::START"))
(unless (find-package "NAVIGATION::STARTREQUEST")
  (make-package "NAVIGATION::STARTREQUEST"))
(unless (find-package "NAVIGATION::STARTRESPONSE")
  (make-package "NAVIGATION::STARTRESPONSE"))

(in-package "ROS")





(defclass navigation::StartRequest
  :super ros::object
  :slots (_sim _map _path _name ))

(defmethod navigation::StartRequest
  (:init
   (&key
    ((:sim __sim) nil)
    ((:map __map) nil)
    ((:path __path) "")
    ((:name __name) "")
    )
   (send-super :init)
   (setq _sim __sim)
   (setq _map __map)
   (setq _path (string __path))
   (setq _name (string __name))
   self)
  (:sim
   (&optional (__sim :null))
   (if (not (eq __sim :null)) (setq _sim __sim)) _sim)
  (:map
   (&optional (__map :null))
   (if (not (eq __map :null)) (setq _map __map)) _map)
  (:path
   (&optional __path)
   (if __path (setq _path __path)) _path)
  (:name
   (&optional __name)
   (if __name (setq _name __name)) _name)
  (:serialization-length
   ()
   (+
    ;; bool _sim
    1
    ;; bool _map
    1
    ;; string _path
    4 (length _path)
    ;; string _name
    4 (length _name)
    ))
  (:serialize
   (&optional strm)
   (let ((s (if strm strm
              (make-string-output-stream (send self :serialization-length)))))
     ;; bool _sim
       (if _sim (write-byte -1 s) (write-byte 0 s))
     ;; bool _map
       (if _map (write-byte -1 s) (write-byte 0 s))
     ;; string _path
       (write-long (length _path) s) (princ _path s)
     ;; string _name
       (write-long (length _name) s) (princ _name s)
     ;;
     (if (null strm) (get-output-stream-string s))))
  (:deserialize
   (buf &optional (ptr- 0))
   ;; bool _sim
     (setq _sim (not (= 0 (sys::peek buf ptr- :char)))) (incf ptr- 1)
   ;; bool _map
     (setq _map (not (= 0 (sys::peek buf ptr- :char)))) (incf ptr- 1)
   ;; string _path
     (let (n) (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4) (setq _path (subseq buf ptr- (+ ptr- n))) (incf ptr- n))
   ;; string _name
     (let (n) (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4) (setq _name (subseq buf ptr- (+ ptr- n))) (incf ptr- n))
   ;;
   self)
  )

(defclass navigation::StartResponse
  :super ros::object
  :slots (_success _message ))

(defmethod navigation::StartResponse
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

(defclass navigation::Start
  :super ros::object
  :slots ())

(setf (get navigation::Start :md5sum-) "1fee74da3380a92a6837430b198ca30d")
(setf (get navigation::Start :datatype-) "navigation/Start")
(setf (get navigation::Start :request) navigation::StartRequest)
(setf (get navigation::Start :response) navigation::StartResponse)

(defmethod navigation::StartRequest
  (:response () (instance navigation::StartResponse :init)))

(setf (get navigation::StartRequest :md5sum-) "1fee74da3380a92a6837430b198ca30d")
(setf (get navigation::StartRequest :datatype-) "navigation/StartRequest")
(setf (get navigation::StartRequest :definition-)
      "bool sim
bool map
string path # relative path under /media/mitchell/Data/Projects/software_engineering/ros_end/src/mapping/maps/
string name # name of map
---
bool success
string message
")

(setf (get navigation::StartResponse :md5sum-) "1fee74da3380a92a6837430b198ca30d")
(setf (get navigation::StartResponse :datatype-) "navigation/StartResponse")
(setf (get navigation::StartResponse :definition-)
      "bool sim
bool map
string path # relative path under /media/mitchell/Data/Projects/software_engineering/ros_end/src/mapping/maps/
string name # name of map
---
bool success
string message
")



(provide :navigation/Start "1fee74da3380a92a6837430b198ca30d")


