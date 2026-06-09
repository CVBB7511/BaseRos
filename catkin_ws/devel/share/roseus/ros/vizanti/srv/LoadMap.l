;; Auto-generated. Do not edit!


(when (boundp 'vizanti::LoadMap)
  (if (not (find-package "VIZANTI"))
    (make-package "VIZANTI"))
  (shadow 'LoadMap (find-package "VIZANTI")))
(unless (find-package "VIZANTI::LOADMAP")
  (make-package "VIZANTI::LOADMAP"))
(unless (find-package "VIZANTI::LOADMAPREQUEST")
  (make-package "VIZANTI::LOADMAPREQUEST"))
(unless (find-package "VIZANTI::LOADMAPRESPONSE")
  (make-package "VIZANTI::LOADMAPRESPONSE"))

(in-package "ROS")





(defclass vizanti::LoadMapRequest
  :super ros::object
  :slots (_file_path _topic ))

(defmethod vizanti::LoadMapRequest
  (:init
   (&key
    ((:file_path __file_path) "")
    ((:topic __topic) "")
    )
   (send-super :init)
   (setq _file_path (string __file_path))
   (setq _topic (string __topic))
   self)
  (:file_path
   (&optional __file_path)
   (if __file_path (setq _file_path __file_path)) _file_path)
  (:topic
   (&optional __topic)
   (if __topic (setq _topic __topic)) _topic)
  (:serialization-length
   ()
   (+
    ;; string _file_path
    4 (length _file_path)
    ;; string _topic
    4 (length _topic)
    ))
  (:serialize
   (&optional strm)
   (let ((s (if strm strm
              (make-string-output-stream (send self :serialization-length)))))
     ;; string _file_path
       (write-long (length _file_path) s) (princ _file_path s)
     ;; string _topic
       (write-long (length _topic) s) (princ _topic s)
     ;;
     (if (null strm) (get-output-stream-string s))))
  (:deserialize
   (buf &optional (ptr- 0))
   ;; string _file_path
     (let (n) (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4) (setq _file_path (subseq buf ptr- (+ ptr- n))) (incf ptr- n))
   ;; string _topic
     (let (n) (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4) (setq _topic (subseq buf ptr- (+ ptr- n))) (incf ptr- n))
   ;;
   self)
  )

(defclass vizanti::LoadMapResponse
  :super ros::object
  :slots (_success _message ))

(defmethod vizanti::LoadMapResponse
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

(defclass vizanti::LoadMap
  :super ros::object
  :slots ())

(setf (get vizanti::LoadMap :md5sum-) "46e31fc20e6d3bc78598163aa51c13bd")
(setf (get vizanti::LoadMap :datatype-) "vizanti/LoadMap")
(setf (get vizanti::LoadMap :request) vizanti::LoadMapRequest)
(setf (get vizanti::LoadMap :response) vizanti::LoadMapResponse)

(defmethod vizanti::LoadMapRequest
  (:response () (instance vizanti::LoadMapResponse :init)))

(setf (get vizanti::LoadMapRequest :md5sum-) "46e31fc20e6d3bc78598163aa51c13bd")
(setf (get vizanti::LoadMapRequest :datatype-) "vizanti/LoadMapRequest")
(setf (get vizanti::LoadMapRequest :definition-)
      "string file_path
string topic
---
bool success
string message
")

(setf (get vizanti::LoadMapResponse :md5sum-) "46e31fc20e6d3bc78598163aa51c13bd")
(setf (get vizanti::LoadMapResponse :datatype-) "vizanti/LoadMapResponse")
(setf (get vizanti::LoadMapResponse :definition-)
      "string file_path
string topic
---
bool success
string message
")



(provide :vizanti/LoadMap "46e31fc20e6d3bc78598163aa51c13bd")


