;; Auto-generated. Do not edit!


(when (boundp 'vizanti::RecordRosbag)
  (if (not (find-package "VIZANTI"))
    (make-package "VIZANTI"))
  (shadow 'RecordRosbag (find-package "VIZANTI")))
(unless (find-package "VIZANTI::RECORDROSBAG")
  (make-package "VIZANTI::RECORDROSBAG"))
(unless (find-package "VIZANTI::RECORDROSBAGREQUEST")
  (make-package "VIZANTI::RECORDROSBAGREQUEST"))
(unless (find-package "VIZANTI::RECORDROSBAGRESPONSE")
  (make-package "VIZANTI::RECORDROSBAGRESPONSE"))

(in-package "ROS")





(defclass vizanti::RecordRosbagRequest
  :super ros::object
  :slots (_topics _start _path ))

(defmethod vizanti::RecordRosbagRequest
  (:init
   (&key
    ((:topics __topics) (let (r) (dotimes (i 0) (push "" r)) r))
    ((:start __start) nil)
    ((:path __path) "")
    )
   (send-super :init)
   (setq _topics __topics)
   (setq _start __start)
   (setq _path (string __path))
   self)
  (:topics
   (&optional __topics)
   (if __topics (setq _topics __topics)) _topics)
  (:start
   (&optional (__start :null))
   (if (not (eq __start :null)) (setq _start __start)) _start)
  (:path
   (&optional __path)
   (if __path (setq _path __path)) _path)
  (:serialization-length
   ()
   (+
    ;; string[] _topics
    (apply #'+ (mapcar #'(lambda (x) (+ 4 (length x))) _topics)) 4
    ;; bool _start
    1
    ;; string _path
    4 (length _path)
    ))
  (:serialize
   (&optional strm)
   (let ((s (if strm strm
              (make-string-output-stream (send self :serialization-length)))))
     ;; string[] _topics
     (write-long (length _topics) s)
     (dolist (elem _topics)
       (write-long (length elem) s) (princ elem s)
       )
     ;; bool _start
       (if _start (write-byte -1 s) (write-byte 0 s))
     ;; string _path
       (write-long (length _path) s) (princ _path s)
     ;;
     (if (null strm) (get-output-stream-string s))))
  (:deserialize
   (buf &optional (ptr- 0))
   ;; string[] _topics
   (let (n)
     (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4)
     (setq _topics (make-list n))
     (dotimes (i n)
     (let (n) (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4) (setf (elt _topics i) (subseq buf ptr- (+ ptr- n))) (incf ptr- n))
     ))
   ;; bool _start
     (setq _start (not (= 0 (sys::peek buf ptr- :char)))) (incf ptr- 1)
   ;; string _path
     (let (n) (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4) (setq _path (subseq buf ptr- (+ ptr- n))) (incf ptr- n))
   ;;
   self)
  )

(defclass vizanti::RecordRosbagResponse
  :super ros::object
  :slots (_success _message ))

(defmethod vizanti::RecordRosbagResponse
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

(defclass vizanti::RecordRosbag
  :super ros::object
  :slots ())

(setf (get vizanti::RecordRosbag :md5sum-) "292a2bef14171aa396b7aff9a49b098c")
(setf (get vizanti::RecordRosbag :datatype-) "vizanti/RecordRosbag")
(setf (get vizanti::RecordRosbag :request) vizanti::RecordRosbagRequest)
(setf (get vizanti::RecordRosbag :response) vizanti::RecordRosbagResponse)

(defmethod vizanti::RecordRosbagRequest
  (:response () (instance vizanti::RecordRosbagResponse :init)))

(setf (get vizanti::RecordRosbagRequest :md5sum-) "292a2bef14171aa396b7aff9a49b098c")
(setf (get vizanti::RecordRosbagRequest :datatype-) "vizanti/RecordRosbagRequest")
(setf (get vizanti::RecordRosbagRequest :definition-)
      "string[] topics
bool start
string path
---
bool success
string message 

")

(setf (get vizanti::RecordRosbagResponse :md5sum-) "292a2bef14171aa396b7aff9a49b098c")
(setf (get vizanti::RecordRosbagResponse :datatype-) "vizanti/RecordRosbagResponse")
(setf (get vizanti::RecordRosbagResponse :definition-)
      "string[] topics
bool start
string path
---
bool success
string message 

")



(provide :vizanti/RecordRosbag "292a2bef14171aa396b7aff9a49b098c")


