;; Auto-generated. Do not edit!


(when (boundp 'vizanti::ListPackages)
  (if (not (find-package "VIZANTI"))
    (make-package "VIZANTI"))
  (shadow 'ListPackages (find-package "VIZANTI")))
(unless (find-package "VIZANTI::LISTPACKAGES")
  (make-package "VIZANTI::LISTPACKAGES"))
(unless (find-package "VIZANTI::LISTPACKAGESREQUEST")
  (make-package "VIZANTI::LISTPACKAGESREQUEST"))
(unless (find-package "VIZANTI::LISTPACKAGESRESPONSE")
  (make-package "VIZANTI::LISTPACKAGESRESPONSE"))

(in-package "ROS")





(defclass vizanti::ListPackagesRequest
  :super ros::object
  :slots ())

(defmethod vizanti::ListPackagesRequest
  (:init
   (&key
    )
   (send-super :init)
   self)
  (:serialization-length
   ()
   (+
    0
    ))
  (:serialize
   (&optional strm)
   (let ((s (if strm strm
              (make-string-output-stream (send self :serialization-length)))))
     ;;
     (if (null strm) (get-output-stream-string s))))
  (:deserialize
   (buf &optional (ptr- 0))
   ;;
   self)
  )

(defclass vizanti::ListPackagesResponse
  :super ros::object
  :slots (_packages ))

(defmethod vizanti::ListPackagesResponse
  (:init
   (&key
    ((:packages __packages) (let (r) (dotimes (i 0) (push "" r)) r))
    )
   (send-super :init)
   (setq _packages __packages)
   self)
  (:packages
   (&optional __packages)
   (if __packages (setq _packages __packages)) _packages)
  (:serialization-length
   ()
   (+
    ;; string[] _packages
    (apply #'+ (mapcar #'(lambda (x) (+ 4 (length x))) _packages)) 4
    ))
  (:serialize
   (&optional strm)
   (let ((s (if strm strm
              (make-string-output-stream (send self :serialization-length)))))
     ;; string[] _packages
     (write-long (length _packages) s)
     (dolist (elem _packages)
       (write-long (length elem) s) (princ elem s)
       )
     ;;
     (if (null strm) (get-output-stream-string s))))
  (:deserialize
   (buf &optional (ptr- 0))
   ;; string[] _packages
   (let (n)
     (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4)
     (setq _packages (make-list n))
     (dotimes (i n)
     (let (n) (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4) (setf (elt _packages i) (subseq buf ptr- (+ ptr- n))) (incf ptr- n))
     ))
   ;;
   self)
  )

(defclass vizanti::ListPackages
  :super ros::object
  :slots ())

(setf (get vizanti::ListPackages :md5sum-) "16e658dd9a0c0812bd000a8e17c5f7b4")
(setf (get vizanti::ListPackages :datatype-) "vizanti/ListPackages")
(setf (get vizanti::ListPackages :request) vizanti::ListPackagesRequest)
(setf (get vizanti::ListPackages :response) vizanti::ListPackagesResponse)

(defmethod vizanti::ListPackagesRequest
  (:response () (instance vizanti::ListPackagesResponse :init)))

(setf (get vizanti::ListPackagesRequest :md5sum-) "16e658dd9a0c0812bd000a8e17c5f7b4")
(setf (get vizanti::ListPackagesRequest :datatype-) "vizanti/ListPackagesRequest")
(setf (get vizanti::ListPackagesRequest :definition-)
      "---
string[] packages 

")

(setf (get vizanti::ListPackagesResponse :md5sum-) "16e658dd9a0c0812bd000a8e17c5f7b4")
(setf (get vizanti::ListPackagesResponse :datatype-) "vizanti/ListPackagesResponse")
(setf (get vizanti::ListPackagesResponse :definition-)
      "---
string[] packages 

")



(provide :vizanti/ListPackages "16e658dd9a0c0812bd000a8e17c5f7b4")


