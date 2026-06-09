;; Auto-generated. Do not edit!


(when (boundp 'vizanti::GetNodeParameters)
  (if (not (find-package "VIZANTI"))
    (make-package "VIZANTI"))
  (shadow 'GetNodeParameters (find-package "VIZANTI")))
(unless (find-package "VIZANTI::GETNODEPARAMETERS")
  (make-package "VIZANTI::GETNODEPARAMETERS"))
(unless (find-package "VIZANTI::GETNODEPARAMETERSREQUEST")
  (make-package "VIZANTI::GETNODEPARAMETERSREQUEST"))
(unless (find-package "VIZANTI::GETNODEPARAMETERSRESPONSE")
  (make-package "VIZANTI::GETNODEPARAMETERSRESPONSE"))

(in-package "ROS")





(defclass vizanti::GetNodeParametersRequest
  :super ros::object
  :slots (_node ))

(defmethod vizanti::GetNodeParametersRequest
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

(defclass vizanti::GetNodeParametersResponse
  :super ros::object
  :slots (_parameters ))

(defmethod vizanti::GetNodeParametersResponse
  (:init
   (&key
    ((:parameters __parameters) "")
    )
   (send-super :init)
   (setq _parameters (string __parameters))
   self)
  (:parameters
   (&optional __parameters)
   (if __parameters (setq _parameters __parameters)) _parameters)
  (:serialization-length
   ()
   (+
    ;; string _parameters
    4 (length _parameters)
    ))
  (:serialize
   (&optional strm)
   (let ((s (if strm strm
              (make-string-output-stream (send self :serialization-length)))))
     ;; string _parameters
       (write-long (length _parameters) s) (princ _parameters s)
     ;;
     (if (null strm) (get-output-stream-string s))))
  (:deserialize
   (buf &optional (ptr- 0))
   ;; string _parameters
     (let (n) (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4) (setq _parameters (subseq buf ptr- (+ ptr- n))) (incf ptr- n))
   ;;
   self)
  )

(defclass vizanti::GetNodeParameters
  :super ros::object
  :slots ())

(setf (get vizanti::GetNodeParameters :md5sum-) "92c3b11f6b804819c754cc42d5293a0b")
(setf (get vizanti::GetNodeParameters :datatype-) "vizanti/GetNodeParameters")
(setf (get vizanti::GetNodeParameters :request) vizanti::GetNodeParametersRequest)
(setf (get vizanti::GetNodeParameters :response) vizanti::GetNodeParametersResponse)

(defmethod vizanti::GetNodeParametersRequest
  (:response () (instance vizanti::GetNodeParametersResponse :init)))

(setf (get vizanti::GetNodeParametersRequest :md5sum-) "92c3b11f6b804819c754cc42d5293a0b")
(setf (get vizanti::GetNodeParametersRequest :datatype-) "vizanti/GetNodeParametersRequest")
(setf (get vizanti::GetNodeParametersRequest :definition-)
      "string node
---
string parameters
")

(setf (get vizanti::GetNodeParametersResponse :md5sum-) "92c3b11f6b804819c754cc42d5293a0b")
(setf (get vizanti::GetNodeParametersResponse :datatype-) "vizanti/GetNodeParametersResponse")
(setf (get vizanti::GetNodeParametersResponse :definition-)
      "string node
---
string parameters
")



(provide :vizanti/GetNodeParameters "92c3b11f6b804819c754cc42d5293a0b")


