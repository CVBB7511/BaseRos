;; Auto-generated. Do not edit!


(when (boundp 'vizanti::SaveMap)
  (if (not (find-package "VIZANTI"))
    (make-package "VIZANTI"))
  (shadow 'SaveMap (find-package "VIZANTI")))
(unless (find-package "VIZANTI::SAVEMAP")
  (make-package "VIZANTI::SAVEMAP"))
(unless (find-package "VIZANTI::SAVEMAPREQUEST")
  (make-package "VIZANTI::SAVEMAPREQUEST"))
(unless (find-package "VIZANTI::SAVEMAPRESPONSE")
  (make-package "VIZANTI::SAVEMAPRESPONSE"))

(in-package "ROS")





(defclass vizanti::SaveMapRequest
  :super ros::object
  :slots (_file_path _topic ))

(defmethod vizanti::SaveMapRequest
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

(defclass vizanti::SaveMapResponse
  :super ros::object
  :slots (_success _message ))

(defmethod vizanti::SaveMapResponse
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

(defclass vizanti::SaveMap
  :super ros::object
  :slots ())

(setf (get vizanti::SaveMap :md5sum-) "46e31fc20e6d3bc78598163aa51c13bd")
(setf (get vizanti::SaveMap :datatype-) "vizanti/SaveMap")
(setf (get vizanti::SaveMap :request) vizanti::SaveMapRequest)
(setf (get vizanti::SaveMap :response) vizanti::SaveMapResponse)

(defmethod vizanti::SaveMapRequest
  (:response () (instance vizanti::SaveMapResponse :init)))

(setf (get vizanti::SaveMapRequest :md5sum-) "46e31fc20e6d3bc78598163aa51c13bd")
(setf (get vizanti::SaveMapRequest :datatype-) "vizanti/SaveMapRequest")
(setf (get vizanti::SaveMapRequest :definition-)
      "string file_path
string topic
---
bool success
string message
")

(setf (get vizanti::SaveMapResponse :md5sum-) "46e31fc20e6d3bc78598163aa51c13bd")
(setf (get vizanti::SaveMapResponse :datatype-) "vizanti/SaveMapResponse")
(setf (get vizanti::SaveMapResponse :definition-)
      "string file_path
string topic
---
bool success
string message
")



(provide :vizanti/SaveMap "46e31fc20e6d3bc78598163aa51c13bd")


