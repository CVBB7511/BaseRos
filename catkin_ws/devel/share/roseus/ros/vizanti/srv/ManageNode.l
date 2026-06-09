;; Auto-generated. Do not edit!


(when (boundp 'vizanti::ManageNode)
  (if (not (find-package "VIZANTI"))
    (make-package "VIZANTI"))
  (shadow 'ManageNode (find-package "VIZANTI")))
(unless (find-package "VIZANTI::MANAGENODE")
  (make-package "VIZANTI::MANAGENODE"))
(unless (find-package "VIZANTI::MANAGENODEREQUEST")
  (make-package "VIZANTI::MANAGENODEREQUEST"))
(unless (find-package "VIZANTI::MANAGENODERESPONSE")
  (make-package "VIZANTI::MANAGENODERESPONSE"))

(in-package "ROS")





(defclass vizanti::ManageNodeRequest
  :super ros::object
  :slots (_node ))

(defmethod vizanti::ManageNodeRequest
  (:init
   (&key
    ((:node __node) "")
    )
   (send-super :init)
   (setq _node (string __node))
   self)
  (:node
   (&optional __node)
   (if __node (setq _node __node)) _node)
  (:serialization-length
   ()
   (+
    ;; string _node
    4 (length _node)
    ))
  (:serialize
   (&optional strm)
   (let ((s (if strm strm
              (make-string-output-stream (send self :serialization-length)))))
     ;; string _node
       (write-long (length _node) s) (princ _node s)
     ;;
     (if (null strm) (get-output-stream-string s))))
  (:deserialize
   (buf &optional (ptr- 0))
   ;; string _node
     (let (n) (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4) (setq _node (subseq buf ptr- (+ ptr- n))) (incf ptr- n))
   ;;
   self)
  )

(defclass vizanti::ManageNodeResponse
  :super ros::object
  :slots (_success _message ))

(defmethod vizanti::ManageNodeResponse
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

(defclass vizanti::ManageNode
  :super ros::object
  :slots ())

(setf (get vizanti::ManageNode :md5sum-) "5734ba0301aeb7212e3511ea9c219c42")
(setf (get vizanti::ManageNode :datatype-) "vizanti/ManageNode")
(setf (get vizanti::ManageNode :request) vizanti::ManageNodeRequest)
(setf (get vizanti::ManageNode :response) vizanti::ManageNodeResponse)

(defmethod vizanti::ManageNodeRequest
  (:response () (instance vizanti::ManageNodeResponse :init)))

(setf (get vizanti::ManageNodeRequest :md5sum-) "5734ba0301aeb7212e3511ea9c219c42")
(setf (get vizanti::ManageNodeRequest :datatype-) "vizanti/ManageNodeRequest")
(setf (get vizanti::ManageNodeRequest :definition-)
      "string node
---
bool success
string message
")

(setf (get vizanti::ManageNodeResponse :md5sum-) "5734ba0301aeb7212e3511ea9c219c42")
(setf (get vizanti::ManageNodeResponse :datatype-) "vizanti/ManageNodeResponse")
(setf (get vizanti::ManageNodeResponse :definition-)
      "string node
---
bool success
string message
")



(provide :vizanti/ManageNode "5734ba0301aeb7212e3511ea9c219c42")


