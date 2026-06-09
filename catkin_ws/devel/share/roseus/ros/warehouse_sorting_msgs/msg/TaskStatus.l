;; Auto-generated. Do not edit!


(when (boundp 'warehouse_sorting_msgs::TaskStatus)
  (if (not (find-package "WAREHOUSE_SORTING_MSGS"))
    (make-package "WAREHOUSE_SORTING_MSGS"))
  (shadow 'TaskStatus (find-package "WAREHOUSE_SORTING_MSGS")))
(unless (find-package "WAREHOUSE_SORTING_MSGS::TASKSTATUS")
  (make-package "WAREHOUSE_SORTING_MSGS::TASKSTATUS"))

(in-package "ROS")
;;//! \htmlinclude TaskStatus.msg.html
(if (not (find-package "STD_MSGS"))
  (ros::roseus-add-msgs "std_msgs"))


(defclass warehouse_sorting_msgs::TaskStatus
  :super ros::object
  :slots (_header _task_id _status _total_items _completed_items _failed_items _sorted_natural _sorted_colored _progress _queue_size _current_step _last_error ))

(defmethod warehouse_sorting_msgs::TaskStatus
  (:init
   (&key
    ((:header __header) (instance std_msgs::Header :init))
    ((:task_id __task_id) "")
    ((:status __status) "")
    ((:total_items __total_items) 0)
    ((:completed_items __completed_items) 0)
    ((:failed_items __failed_items) 0)
    ((:sorted_natural __sorted_natural) 0)
    ((:sorted_colored __sorted_colored) 0)
    ((:progress __progress) 0.0)
    ((:queue_size __queue_size) 0)
    ((:current_step __current_step) "")
    ((:last_error __last_error) "")
    )
   (send-super :init)
   (setq _header __header)
   (setq _task_id (string __task_id))
   (setq _status (string __status))
   (setq _total_items (round __total_items))
   (setq _completed_items (round __completed_items))
   (setq _failed_items (round __failed_items))
   (setq _sorted_natural (round __sorted_natural))
   (setq _sorted_colored (round __sorted_colored))
   (setq _progress (float __progress))
   (setq _queue_size (round __queue_size))
   (setq _current_step (string __current_step))
   (setq _last_error (string __last_error))
   self)
  (:header
   (&rest __header)
   (if (keywordp (car __header))
       (send* _header __header)
     (progn
       (if __header (setq _header (car __header)))
       _header)))
  (:task_id
   (&optional __task_id)
   (if __task_id (setq _task_id __task_id)) _task_id)
  (:status
   (&optional __status)
   (if __status (setq _status __status)) _status)
  (:total_items
   (&optional __total_items)
   (if __total_items (setq _total_items __total_items)) _total_items)
  (:completed_items
   (&optional __completed_items)
   (if __completed_items (setq _completed_items __completed_items)) _completed_items)
  (:failed_items
   (&optional __failed_items)
   (if __failed_items (setq _failed_items __failed_items)) _failed_items)
  (:sorted_natural
   (&optional __sorted_natural)
   (if __sorted_natural (setq _sorted_natural __sorted_natural)) _sorted_natural)
  (:sorted_colored
   (&optional __sorted_colored)
   (if __sorted_colored (setq _sorted_colored __sorted_colored)) _sorted_colored)
  (:progress
   (&optional __progress)
   (if __progress (setq _progress __progress)) _progress)
  (:queue_size
   (&optional __queue_size)
   (if __queue_size (setq _queue_size __queue_size)) _queue_size)
  (:current_step
   (&optional __current_step)
   (if __current_step (setq _current_step __current_step)) _current_step)
  (:last_error
   (&optional __last_error)
   (if __last_error (setq _last_error __last_error)) _last_error)
  (:serialization-length
   ()
   (+
    ;; std_msgs/Header _header
    (send _header :serialization-length)
    ;; string _task_id
    4 (length _task_id)
    ;; string _status
    4 (length _status)
    ;; uint32 _total_items
    4
    ;; uint32 _completed_items
    4
    ;; uint32 _failed_items
    4
    ;; uint32 _sorted_natural
    4
    ;; uint32 _sorted_colored
    4
    ;; float32 _progress
    4
    ;; uint32 _queue_size
    4
    ;; string _current_step
    4 (length _current_step)
    ;; string _last_error
    4 (length _last_error)
    ))
  (:serialize
   (&optional strm)
   (let ((s (if strm strm
              (make-string-output-stream (send self :serialization-length)))))
     ;; std_msgs/Header _header
       (send _header :serialize s)
     ;; string _task_id
       (write-long (length _task_id) s) (princ _task_id s)
     ;; string _status
       (write-long (length _status) s) (princ _status s)
     ;; uint32 _total_items
       (write-long _total_items s)
     ;; uint32 _completed_items
       (write-long _completed_items s)
     ;; uint32 _failed_items
       (write-long _failed_items s)
     ;; uint32 _sorted_natural
       (write-long _sorted_natural s)
     ;; uint32 _sorted_colored
       (write-long _sorted_colored s)
     ;; float32 _progress
       (sys::poke _progress (send s :buffer) (send s :count) :float) (incf (stream-count s) 4)
     ;; uint32 _queue_size
       (write-long _queue_size s)
     ;; string _current_step
       (write-long (length _current_step) s) (princ _current_step s)
     ;; string _last_error
       (write-long (length _last_error) s) (princ _last_error s)
     ;;
     (if (null strm) (get-output-stream-string s))))
  (:deserialize
   (buf &optional (ptr- 0))
   ;; std_msgs/Header _header
     (send _header :deserialize buf ptr-) (incf ptr- (send _header :serialization-length))
   ;; string _task_id
     (let (n) (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4) (setq _task_id (subseq buf ptr- (+ ptr- n))) (incf ptr- n))
   ;; string _status
     (let (n) (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4) (setq _status (subseq buf ptr- (+ ptr- n))) (incf ptr- n))
   ;; uint32 _total_items
     (setq _total_items (sys::peek buf ptr- :integer)) (incf ptr- 4)
   ;; uint32 _completed_items
     (setq _completed_items (sys::peek buf ptr- :integer)) (incf ptr- 4)
   ;; uint32 _failed_items
     (setq _failed_items (sys::peek buf ptr- :integer)) (incf ptr- 4)
   ;; uint32 _sorted_natural
     (setq _sorted_natural (sys::peek buf ptr- :integer)) (incf ptr- 4)
   ;; uint32 _sorted_colored
     (setq _sorted_colored (sys::peek buf ptr- :integer)) (incf ptr- 4)
   ;; float32 _progress
     (setq _progress (sys::peek buf ptr- :float)) (incf ptr- 4)
   ;; uint32 _queue_size
     (setq _queue_size (sys::peek buf ptr- :integer)) (incf ptr- 4)
   ;; string _current_step
     (let (n) (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4) (setq _current_step (subseq buf ptr- (+ ptr- n))) (incf ptr- n))
   ;; string _last_error
     (let (n) (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4) (setq _last_error (subseq buf ptr- (+ ptr- n))) (incf ptr- n))
   ;;
   self)
  )

(setf (get warehouse_sorting_msgs::TaskStatus :md5sum-) "b784d483d6404417f2b1da231522b939")
(setf (get warehouse_sorting_msgs::TaskStatus :datatype-) "warehouse_sorting_msgs/TaskStatus")
(setf (get warehouse_sorting_msgs::TaskStatus :definition-)
      "std_msgs/Header header
string task_id
string status
uint32 total_items
uint32 completed_items
uint32 failed_items
uint32 sorted_natural
uint32 sorted_colored
float32 progress
uint32 queue_size
string current_step
string last_error

================================================================================
MSG: std_msgs/Header
# Standard metadata for higher-level stamped data types.
# This is generally used to communicate timestamped data 
# in a particular coordinate frame.
# 
# sequence ID: consecutively increasing ID 
uint32 seq
#Two-integer timestamp that is expressed as:
# * stamp.sec: seconds (stamp_secs) since epoch (in Python the variable is called 'secs')
# * stamp.nsec: nanoseconds since stamp_secs (in Python the variable is called 'nsecs')
# time-handling sugar is provided by the client library
time stamp
#Frame this data is associated with
string frame_id

")



(provide :warehouse_sorting_msgs/TaskStatus "b784d483d6404417f2b1da231522b939")


