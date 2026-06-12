;; Auto-generated. Do not edit!


(when (boundp 'palletizing::SafetyStatus)
  (if (not (find-package "PALLETIZING"))
    (make-package "PALLETIZING"))
  (shadow 'SafetyStatus (find-package "PALLETIZING")))
(unless (find-package "PALLETIZING::SAFETYSTATUS")
  (make-package "PALLETIZING::SAFETYSTATUS"))

(in-package "ROS")
;;//! \htmlinclude SafetyStatus.msg.html


(intern "*CLEAR*" (find-package "PALLETIZING::SAFETYSTATUS"))
(shadow '*CLEAR* (find-package "PALLETIZING::SAFETYSTATUS"))
(defconstant palletizing::SafetyStatus::*CLEAR* 0)
(intern "*WARNING*" (find-package "PALLETIZING::SAFETYSTATUS"))
(shadow '*WARNING* (find-package "PALLETIZING::SAFETYSTATUS"))
(defconstant palletizing::SafetyStatus::*WARNING* 1)
(intern "*EMERGENCY*" (find-package "PALLETIZING::SAFETYSTATUS"))
(shadow '*EMERGENCY* (find-package "PALLETIZING::SAFETYSTATUS"))
(defconstant palletizing::SafetyStatus::*EMERGENCY* 2)

(defun palletizing::SafetyStatus-to-symbol (const)
  (cond
        ((= const 0) 'palletizing::SafetyStatus::*CLEAR*)
        ((= const 1) 'palletizing::SafetyStatus::*WARNING*)
        ((= const 2) 'palletizing::SafetyStatus::*EMERGENCY*)
        (t nil)))

(defclass palletizing::SafetyStatus
  :super ros::object
  :slots (_level _min_distance _message ))

(defmethod palletizing::SafetyStatus
  (:init
   (&key
    ((:level __level) 0)
    ((:min_distance __min_distance) 0.0)
    ((:message __message) "")
    )
   (send-super :init)
   (setq _level (round __level))
   (setq _min_distance (float __min_distance))
   (setq _message (string __message))
   self)
  (:level
   (&optional __level)
   (if __level (setq _level __level)) _level)
  (:min_distance
   (&optional __min_distance)
   (if __min_distance (setq _min_distance __min_distance)) _min_distance)
  (:message
   (&optional __message)
   (if __message (setq _message __message)) _message)
  (:serialization-length
   ()
   (+
    ;; uint8 _level
    1
    ;; float64 _min_distance
    8
    ;; string _message
    4 (length _message)
    ))
  (:serialize
   (&optional strm)
   (let ((s (if strm strm
              (make-string-output-stream (send self :serialization-length)))))
     ;; uint8 _level
       (write-byte _level s)
     ;; float64 _min_distance
       (sys::poke _min_distance (send s :buffer) (send s :count) :double) (incf (stream-count s) 8)
     ;; string _message
       (write-long (length _message) s) (princ _message s)
     ;;
     (if (null strm) (get-output-stream-string s))))
  (:deserialize
   (buf &optional (ptr- 0))
   ;; uint8 _level
     (setq _level (sys::peek buf ptr- :char)) (incf ptr- 1)
   ;; float64 _min_distance
     (setq _min_distance (sys::peek buf ptr- :double)) (incf ptr- 8)
   ;; string _message
     (let (n) (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4) (setq _message (subseq buf ptr- (+ ptr- n))) (incf ptr- n))
   ;;
   self)
  )

(setf (get palletizing::SafetyStatus :md5sum-) "080f944521045f84e22d6ce4b4a77218")
(setf (get palletizing::SafetyStatus :datatype-) "palletizing/SafetyStatus")
(setf (get palletizing::SafetyStatus :definition-)
      "uint8 CLEAR=0
uint8 WARNING=1
uint8 EMERGENCY=2
uint8 level
float64 min_distance
string message

")



(provide :palletizing/SafetyStatus "080f944521045f84e22d6ce4b4a77218")


