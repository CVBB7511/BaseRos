;; Auto-generated. Do not edit!


(when (boundp 'vizanti::ListExecutables)
  (if (not (find-package "VIZANTI"))
    (make-package "VIZANTI"))
  (shadow 'ListExecutables (find-package "VIZANTI")))
(unless (find-package "VIZANTI::LISTEXECUTABLES")
  (make-package "VIZANTI::LISTEXECUTABLES"))
(unless (find-package "VIZANTI::LISTEXECUTABLESREQUEST")
  (make-package "VIZANTI::LISTEXECUTABLESREQUEST"))
(unless (find-package "VIZANTI::LISTEXECUTABLESRESPONSE")
  (make-package "VIZANTI::LISTEXECUTABLESRESPONSE"))

(in-package "ROS")





(defclass vizanti::ListExecutablesRequest
  :super ros::object
  :slots (_package ))

(defmethod vizanti::ListExecutablesRequest
  (:init
   (&key
    ((:package __package) "")
    )
   (send-super :init)
   (setq _package (string __package))
   self)
  (:package
   (&optional __package)
   (if __package (setq _package __package)) _package)
  (:serialization-length
   ()
   (+
    ;; string _package
    4 (length _package)
    ))
  (:serialize
   (&optional strm)
   (let ((s (if strm strm
              (make-string-output-stream (send self :serialization-length)))))
     ;; string _package
       (write-long (length _package) s) (princ _package s)
     ;;
     (if (null strm) (get-output-stream-string s))))
  (:deserialize
   (buf &optional (ptr- 0))
   ;; string _package
     (let (n) (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4) (setq _package (subseq buf ptr- (+ ptr- n))) (incf ptr- n))
   ;;
   self)
  )

(defclass vizanti::ListExecutablesResponse
  :super ros::object
  :slots (_executables ))

(defmethod vizanti::ListExecutablesResponse
  (:init
   (&key
    ((:executables __executables) (let (r) (dotimes (i 0) (push "" r)) r))
    )
   (send-super :init)
   (setq _executables __executables)
   self)
  (:executables
   (&optional __executables)
   (if __executables (setq _executables __executables)) _executables)
  (:serialization-length
   ()
   (+
    ;; string[] _executables
    (apply #'+ (mapcar #'(lambda (x) (+ 4 (length x))) _executables)) 4
    ))
  (:serialize
   (&optional strm)
   (let ((s (if strm strm
              (make-string-output-stream (send self :serialization-length)))))
     ;; string[] _executables
     (write-long (length _executables) s)
     (dolist (elem _executables)
       (write-long (length elem) s) (princ elem s)
       )
     ;;
     (if (null strm) (get-output-stream-string s))))
  (:deserialize
   (buf &optional (ptr- 0))
   ;; string[] _executables
   (let (n)
     (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4)
     (setq _executables (make-list n))
     (dotimes (i n)
     (let (n) (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4) (setf (elt _executables i) (subseq buf ptr- (+ ptr- n))) (incf ptr- n))
     ))
   ;;
   self)
  )

(defclass vizanti::ListExecutables
  :super ros::object
  :slots ())

(setf (get vizanti::ListExecutables :md5sum-) "0d9dadc8a6139fd3d3c4c0b768c8f47c")
(setf (get vizanti::ListExecutables :datatype-) "vizanti/ListExecutables")
(setf (get vizanti::ListExecutables :request) vizanti::ListExecutablesRequest)
(setf (get vizanti::ListExecutables :response) vizanti::ListExecutablesResponse)

(defmethod vizanti::ListExecutablesRequest
  (:response () (instance vizanti::ListExecutablesResponse :init)))

(setf (get vizanti::ListExecutablesRequest :md5sum-) "0d9dadc8a6139fd3d3c4c0b768c8f47c")
(setf (get vizanti::ListExecutablesRequest :datatype-) "vizanti/ListExecutablesRequest")
(setf (get vizanti::ListExecutablesRequest :definition-)
      "string package
---
string[] executables 

")

(setf (get vizanti::ListExecutablesResponse :md5sum-) "0d9dadc8a6139fd3d3c4c0b768c8f47c")
(setf (get vizanti::ListExecutablesResponse :datatype-) "vizanti/ListExecutablesResponse")
(setf (get vizanti::ListExecutablesResponse :definition-)
      "string package
---
string[] executables 

")



(provide :vizanti/ListExecutables "0d9dadc8a6139fd3d3c4c0b768c8f47c")


