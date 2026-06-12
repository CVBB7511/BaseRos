;; Auto-generated. Do not edit!


(when (boundp 'palletizing::PalletizingStats)
  (if (not (find-package "PALLETIZING"))
    (make-package "PALLETIZING"))
  (shadow 'PalletizingStats (find-package "PALLETIZING")))
(unless (find-package "PALLETIZING::PALLETIZINGSTATS")
  (make-package "PALLETIZING::PALLETIZINGSTATS"))

(in-package "ROS")
;;//! \htmlinclude PalletizingStats.msg.html


(defclass palletizing::PalletizingStats
  :super ros::object
  :slots (_total_objects _success_count _fail_count _current_layer _hard_zone_layers _soft_zone_layers _success_rate _avg_cycle_time _elapsed_time _current_state ))

(defmethod palletizing::PalletizingStats
  (:init
   (&key
    ((:total_objects __total_objects) 0)
    ((:success_count __success_count) 0)
    ((:fail_count __fail_count) 0)
    ((:current_layer __current_layer) 0)
    ((:hard_zone_layers __hard_zone_layers) 0)
    ((:soft_zone_layers __soft_zone_layers) 0)
    ((:success_rate __success_rate) 0.0)
    ((:avg_cycle_time __avg_cycle_time) 0.0)
    ((:elapsed_time __elapsed_time) 0.0)
    ((:current_state __current_state) "")
    )
   (send-super :init)
   (setq _total_objects (round __total_objects))
   (setq _success_count (round __success_count))
   (setq _fail_count (round __fail_count))
   (setq _current_layer (round __current_layer))
   (setq _hard_zone_layers (round __hard_zone_layers))
   (setq _soft_zone_layers (round __soft_zone_layers))
   (setq _success_rate (float __success_rate))
   (setq _avg_cycle_time (float __avg_cycle_time))
   (setq _elapsed_time (float __elapsed_time))
   (setq _current_state (string __current_state))
   self)
  (:total_objects
   (&optional __total_objects)
   (if __total_objects (setq _total_objects __total_objects)) _total_objects)
  (:success_count
   (&optional __success_count)
   (if __success_count (setq _success_count __success_count)) _success_count)
  (:fail_count
   (&optional __fail_count)
   (if __fail_count (setq _fail_count __fail_count)) _fail_count)
  (:current_layer
   (&optional __current_layer)
   (if __current_layer (setq _current_layer __current_layer)) _current_layer)
  (:hard_zone_layers
   (&optional __hard_zone_layers)
   (if __hard_zone_layers (setq _hard_zone_layers __hard_zone_layers)) _hard_zone_layers)
  (:soft_zone_layers
   (&optional __soft_zone_layers)
   (if __soft_zone_layers (setq _soft_zone_layers __soft_zone_layers)) _soft_zone_layers)
  (:success_rate
   (&optional __success_rate)
   (if __success_rate (setq _success_rate __success_rate)) _success_rate)
  (:avg_cycle_time
   (&optional __avg_cycle_time)
   (if __avg_cycle_time (setq _avg_cycle_time __avg_cycle_time)) _avg_cycle_time)
  (:elapsed_time
   (&optional __elapsed_time)
   (if __elapsed_time (setq _elapsed_time __elapsed_time)) _elapsed_time)
  (:current_state
   (&optional __current_state)
   (if __current_state (setq _current_state __current_state)) _current_state)
  (:serialization-length
   ()
   (+
    ;; uint32 _total_objects
    4
    ;; uint32 _success_count
    4
    ;; uint32 _fail_count
    4
    ;; uint32 _current_layer
    4
    ;; uint32 _hard_zone_layers
    4
    ;; uint32 _soft_zone_layers
    4
    ;; float64 _success_rate
    8
    ;; float64 _avg_cycle_time
    8
    ;; float64 _elapsed_time
    8
    ;; string _current_state
    4 (length _current_state)
    ))
  (:serialize
   (&optional strm)
   (let ((s (if strm strm
              (make-string-output-stream (send self :serialization-length)))))
     ;; uint32 _total_objects
       (write-long _total_objects s)
     ;; uint32 _success_count
       (write-long _success_count s)
     ;; uint32 _fail_count
       (write-long _fail_count s)
     ;; uint32 _current_layer
       (write-long _current_layer s)
     ;; uint32 _hard_zone_layers
       (write-long _hard_zone_layers s)
     ;; uint32 _soft_zone_layers
       (write-long _soft_zone_layers s)
     ;; float64 _success_rate
       (sys::poke _success_rate (send s :buffer) (send s :count) :double) (incf (stream-count s) 8)
     ;; float64 _avg_cycle_time
       (sys::poke _avg_cycle_time (send s :buffer) (send s :count) :double) (incf (stream-count s) 8)
     ;; float64 _elapsed_time
       (sys::poke _elapsed_time (send s :buffer) (send s :count) :double) (incf (stream-count s) 8)
     ;; string _current_state
       (write-long (length _current_state) s) (princ _current_state s)
     ;;
     (if (null strm) (get-output-stream-string s))))
  (:deserialize
   (buf &optional (ptr- 0))
   ;; uint32 _total_objects
     (setq _total_objects (sys::peek buf ptr- :integer)) (incf ptr- 4)
   ;; uint32 _success_count
     (setq _success_count (sys::peek buf ptr- :integer)) (incf ptr- 4)
   ;; uint32 _fail_count
     (setq _fail_count (sys::peek buf ptr- :integer)) (incf ptr- 4)
   ;; uint32 _current_layer
     (setq _current_layer (sys::peek buf ptr- :integer)) (incf ptr- 4)
   ;; uint32 _hard_zone_layers
     (setq _hard_zone_layers (sys::peek buf ptr- :integer)) (incf ptr- 4)
   ;; uint32 _soft_zone_layers
     (setq _soft_zone_layers (sys::peek buf ptr- :integer)) (incf ptr- 4)
   ;; float64 _success_rate
     (setq _success_rate (sys::peek buf ptr- :double)) (incf ptr- 8)
   ;; float64 _avg_cycle_time
     (setq _avg_cycle_time (sys::peek buf ptr- :double)) (incf ptr- 8)
   ;; float64 _elapsed_time
     (setq _elapsed_time (sys::peek buf ptr- :double)) (incf ptr- 8)
   ;; string _current_state
     (let (n) (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4) (setq _current_state (subseq buf ptr- (+ ptr- n))) (incf ptr- n))
   ;;
   self)
  )

(setf (get palletizing::PalletizingStats :md5sum-) "92aa1e36e09f1e3fca1e85e1659ad3fe")
(setf (get palletizing::PalletizingStats :datatype-) "palletizing/PalletizingStats")
(setf (get palletizing::PalletizingStats :definition-)
      "uint32 total_objects
uint32 success_count
uint32 fail_count
uint32 current_layer
uint32 hard_zone_layers
uint32 soft_zone_layers
float64 success_rate
float64 avg_cycle_time
float64 elapsed_time
string current_state

")



(provide :palletizing/PalletizingStats "92aa1e36e09f1e3fca1e85e1659ad3fe")


