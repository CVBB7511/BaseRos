;; Auto-generated. Do not edit!


(when (boundp 'fetch_server::Fetch)
  (if (not (find-package "FETCH_SERVER"))
    (make-package "FETCH_SERVER"))
  (shadow 'Fetch (find-package "FETCH_SERVER")))
(unless (find-package "FETCH_SERVER::FETCH")
  (make-package "FETCH_SERVER::FETCH"))
(unless (find-package "FETCH_SERVER::FETCHREQUEST")
  (make-package "FETCH_SERVER::FETCHREQUEST"))
(unless (find-package "FETCH_SERVER::FETCHRESPONSE")
  (make-package "FETCH_SERVER::FETCHRESPONSE"))

(in-package "ROS")





(defclass fetch_server::FetchRequest
  :super ros::object
  :slots (_gpx _gpy _gpz _goz _ppx _ppy _ppz _poz ))

(defmethod fetch_server::FetchRequest
  (:init
   (&key
    ((:gpx __gpx) 0.0)
    ((:gpy __gpy) 0.0)
    ((:gpz __gpz) 0.0)
    ((:goz __goz) 0.0)
    ((:ppx __ppx) 0.0)
    ((:ppy __ppy) 0.0)
    ((:ppz __ppz) 0.0)
    ((:poz __poz) 0.0)
    )
   (send-super :init)
   (setq _gpx (float __gpx))
   (setq _gpy (float __gpy))
   (setq _gpz (float __gpz))
   (setq _goz (float __goz))
   (setq _ppx (float __ppx))
   (setq _ppy (float __ppy))
   (setq _ppz (float __ppz))
   (setq _poz (float __poz))
   self)
  (:gpx
   (&optional __gpx)
   (if __gpx (setq _gpx __gpx)) _gpx)
  (:gpy
   (&optional __gpy)
   (if __gpy (setq _gpy __gpy)) _gpy)
  (:gpz
   (&optional __gpz)
   (if __gpz (setq _gpz __gpz)) _gpz)
  (:goz
   (&optional __goz)
   (if __goz (setq _goz __goz)) _goz)
  (:ppx
   (&optional __ppx)
   (if __ppx (setq _ppx __ppx)) _ppx)
  (:ppy
   (&optional __ppy)
   (if __ppy (setq _ppy __ppy)) _ppy)
  (:ppz
   (&optional __ppz)
   (if __ppz (setq _ppz __ppz)) _ppz)
  (:poz
   (&optional __poz)
   (if __poz (setq _poz __poz)) _poz)
  (:serialization-length
   ()
   (+
    ;; float64 _gpx
    8
    ;; float64 _gpy
    8
    ;; float64 _gpz
    8
    ;; float64 _goz
    8
    ;; float64 _ppx
    8
    ;; float64 _ppy
    8
    ;; float64 _ppz
    8
    ;; float64 _poz
    8
    ))
  (:serialize
   (&optional strm)
   (let ((s (if strm strm
              (make-string-output-stream (send self :serialization-length)))))
     ;; float64 _gpx
       (sys::poke _gpx (send s :buffer) (send s :count) :double) (incf (stream-count s) 8)
     ;; float64 _gpy
       (sys::poke _gpy (send s :buffer) (send s :count) :double) (incf (stream-count s) 8)
     ;; float64 _gpz
       (sys::poke _gpz (send s :buffer) (send s :count) :double) (incf (stream-count s) 8)
     ;; float64 _goz
       (sys::poke _goz (send s :buffer) (send s :count) :double) (incf (stream-count s) 8)
     ;; float64 _ppx
       (sys::poke _ppx (send s :buffer) (send s :count) :double) (incf (stream-count s) 8)
     ;; float64 _ppy
       (sys::poke _ppy (send s :buffer) (send s :count) :double) (incf (stream-count s) 8)
     ;; float64 _ppz
       (sys::poke _ppz (send s :buffer) (send s :count) :double) (incf (stream-count s) 8)
     ;; float64 _poz
       (sys::poke _poz (send s :buffer) (send s :count) :double) (incf (stream-count s) 8)
     ;;
     (if (null strm) (get-output-stream-string s))))
  (:deserialize
   (buf &optional (ptr- 0))
   ;; float64 _gpx
     (setq _gpx (sys::peek buf ptr- :double)) (incf ptr- 8)
   ;; float64 _gpy
     (setq _gpy (sys::peek buf ptr- :double)) (incf ptr- 8)
   ;; float64 _gpz
     (setq _gpz (sys::peek buf ptr- :double)) (incf ptr- 8)
   ;; float64 _goz
     (setq _goz (sys::peek buf ptr- :double)) (incf ptr- 8)
   ;; float64 _ppx
     (setq _ppx (sys::peek buf ptr- :double)) (incf ptr- 8)
   ;; float64 _ppy
     (setq _ppy (sys::peek buf ptr- :double)) (incf ptr- 8)
   ;; float64 _ppz
     (setq _ppz (sys::peek buf ptr- :double)) (incf ptr- 8)
   ;; float64 _poz
     (setq _poz (sys::peek buf ptr- :double)) (incf ptr- 8)
   ;;
   self)
  )

(defclass fetch_server::FetchResponse
  :super ros::object
  :slots (_success _message ))

(defmethod fetch_server::FetchResponse
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

(defclass fetch_server::Fetch
  :super ros::object
  :slots ())

(setf (get fetch_server::Fetch :md5sum-) "88a1ffde7893c12d1c785f9936a31695")
(setf (get fetch_server::Fetch :datatype-) "fetch_server/Fetch")
(setf (get fetch_server::Fetch :request) fetch_server::FetchRequest)
(setf (get fetch_server::Fetch :response) fetch_server::FetchResponse)

(defmethod fetch_server::FetchRequest
  (:response () (instance fetch_server::FetchResponse :init)))

(setf (get fetch_server::FetchRequest :md5sum-) "88a1ffde7893c12d1c785f9936a31695")
(setf (get fetch_server::FetchRequest :datatype-) "fetch_server/FetchRequest")
(setf (get fetch_server::FetchRequest :definition-)
      "float64 gpx
float64 gpy
float64 gpz
float64 goz
float64 ppx
float64 ppy
float64 ppz
float64 poz
---
bool success
string message
")

(setf (get fetch_server::FetchResponse :md5sum-) "88a1ffde7893c12d1c785f9936a31695")
(setf (get fetch_server::FetchResponse :datatype-) "fetch_server/FetchResponse")
(setf (get fetch_server::FetchResponse :definition-)
      "float64 gpx
float64 gpy
float64 gpz
float64 goz
float64 ppx
float64 ppy
float64 ppz
float64 poz
---
bool success
string message
")



(provide :fetch_server/Fetch "88a1ffde7893c12d1c785f9936a31695")


