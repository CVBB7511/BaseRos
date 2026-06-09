// Auto-generated. Do not edit!

// (in-package warehouse_sorting_msgs.msg)


"use strict";

const _serializer = _ros_msg_utils.Serialize;
const _arraySerializer = _serializer.Array;
const _deserializer = _ros_msg_utils.Deserialize;
const _arrayDeserializer = _deserializer.Array;
const _finder = _ros_msg_utils.Find;
const _getByteLength = _ros_msg_utils.getByteLength;
let std_msgs = _finder('std_msgs');

//-----------------------------------------------------------

class TaskStatus {
  constructor(initObj={}) {
    if (initObj === null) {
      // initObj === null is a special case for deserialization where we don't initialize fields
      this.header = null;
      this.task_id = null;
      this.status = null;
      this.total_items = null;
      this.completed_items = null;
      this.failed_items = null;
      this.sorted_natural = null;
      this.sorted_colored = null;
      this.progress = null;
      this.queue_size = null;
      this.current_step = null;
      this.last_error = null;
    }
    else {
      if (initObj.hasOwnProperty('header')) {
        this.header = initObj.header
      }
      else {
        this.header = new std_msgs.msg.Header();
      }
      if (initObj.hasOwnProperty('task_id')) {
        this.task_id = initObj.task_id
      }
      else {
        this.task_id = '';
      }
      if (initObj.hasOwnProperty('status')) {
        this.status = initObj.status
      }
      else {
        this.status = '';
      }
      if (initObj.hasOwnProperty('total_items')) {
        this.total_items = initObj.total_items
      }
      else {
        this.total_items = 0;
      }
      if (initObj.hasOwnProperty('completed_items')) {
        this.completed_items = initObj.completed_items
      }
      else {
        this.completed_items = 0;
      }
      if (initObj.hasOwnProperty('failed_items')) {
        this.failed_items = initObj.failed_items
      }
      else {
        this.failed_items = 0;
      }
      if (initObj.hasOwnProperty('sorted_natural')) {
        this.sorted_natural = initObj.sorted_natural
      }
      else {
        this.sorted_natural = 0;
      }
      if (initObj.hasOwnProperty('sorted_colored')) {
        this.sorted_colored = initObj.sorted_colored
      }
      else {
        this.sorted_colored = 0;
      }
      if (initObj.hasOwnProperty('progress')) {
        this.progress = initObj.progress
      }
      else {
        this.progress = 0.0;
      }
      if (initObj.hasOwnProperty('queue_size')) {
        this.queue_size = initObj.queue_size
      }
      else {
        this.queue_size = 0;
      }
      if (initObj.hasOwnProperty('current_step')) {
        this.current_step = initObj.current_step
      }
      else {
        this.current_step = '';
      }
      if (initObj.hasOwnProperty('last_error')) {
        this.last_error = initObj.last_error
      }
      else {
        this.last_error = '';
      }
    }
  }

  static serialize(obj, buffer, bufferOffset) {
    // Serializes a message object of type TaskStatus
    // Serialize message field [header]
    bufferOffset = std_msgs.msg.Header.serialize(obj.header, buffer, bufferOffset);
    // Serialize message field [task_id]
    bufferOffset = _serializer.string(obj.task_id, buffer, bufferOffset);
    // Serialize message field [status]
    bufferOffset = _serializer.string(obj.status, buffer, bufferOffset);
    // Serialize message field [total_items]
    bufferOffset = _serializer.uint32(obj.total_items, buffer, bufferOffset);
    // Serialize message field [completed_items]
    bufferOffset = _serializer.uint32(obj.completed_items, buffer, bufferOffset);
    // Serialize message field [failed_items]
    bufferOffset = _serializer.uint32(obj.failed_items, buffer, bufferOffset);
    // Serialize message field [sorted_natural]
    bufferOffset = _serializer.uint32(obj.sorted_natural, buffer, bufferOffset);
    // Serialize message field [sorted_colored]
    bufferOffset = _serializer.uint32(obj.sorted_colored, buffer, bufferOffset);
    // Serialize message field [progress]
    bufferOffset = _serializer.float32(obj.progress, buffer, bufferOffset);
    // Serialize message field [queue_size]
    bufferOffset = _serializer.uint32(obj.queue_size, buffer, bufferOffset);
    // Serialize message field [current_step]
    bufferOffset = _serializer.string(obj.current_step, buffer, bufferOffset);
    // Serialize message field [last_error]
    bufferOffset = _serializer.string(obj.last_error, buffer, bufferOffset);
    return bufferOffset;
  }

  static deserialize(buffer, bufferOffset=[0]) {
    //deserializes a message object of type TaskStatus
    let len;
    let data = new TaskStatus(null);
    // Deserialize message field [header]
    data.header = std_msgs.msg.Header.deserialize(buffer, bufferOffset);
    // Deserialize message field [task_id]
    data.task_id = _deserializer.string(buffer, bufferOffset);
    // Deserialize message field [status]
    data.status = _deserializer.string(buffer, bufferOffset);
    // Deserialize message field [total_items]
    data.total_items = _deserializer.uint32(buffer, bufferOffset);
    // Deserialize message field [completed_items]
    data.completed_items = _deserializer.uint32(buffer, bufferOffset);
    // Deserialize message field [failed_items]
    data.failed_items = _deserializer.uint32(buffer, bufferOffset);
    // Deserialize message field [sorted_natural]
    data.sorted_natural = _deserializer.uint32(buffer, bufferOffset);
    // Deserialize message field [sorted_colored]
    data.sorted_colored = _deserializer.uint32(buffer, bufferOffset);
    // Deserialize message field [progress]
    data.progress = _deserializer.float32(buffer, bufferOffset);
    // Deserialize message field [queue_size]
    data.queue_size = _deserializer.uint32(buffer, bufferOffset);
    // Deserialize message field [current_step]
    data.current_step = _deserializer.string(buffer, bufferOffset);
    // Deserialize message field [last_error]
    data.last_error = _deserializer.string(buffer, bufferOffset);
    return data;
  }

  static getMessageSize(object) {
    let length = 0;
    length += std_msgs.msg.Header.getMessageSize(object.header);
    length += _getByteLength(object.task_id);
    length += _getByteLength(object.status);
    length += _getByteLength(object.current_step);
    length += _getByteLength(object.last_error);
    return length + 44;
  }

  static datatype() {
    // Returns string type for a message object
    return 'warehouse_sorting_msgs/TaskStatus';
  }

  static md5sum() {
    //Returns md5sum for a message object
    return 'b784d483d6404417f2b1da231522b939';
  }

  static messageDefinition() {
    // Returns full string definition for message
    return `
    std_msgs/Header header
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
    
    `;
  }

  static Resolve(msg) {
    // deep-construct a valid message object instance of whatever was passed in
    if (typeof msg !== 'object' || msg === null) {
      msg = {};
    }
    const resolved = new TaskStatus(null);
    if (msg.header !== undefined) {
      resolved.header = std_msgs.msg.Header.Resolve(msg.header)
    }
    else {
      resolved.header = new std_msgs.msg.Header()
    }

    if (msg.task_id !== undefined) {
      resolved.task_id = msg.task_id;
    }
    else {
      resolved.task_id = ''
    }

    if (msg.status !== undefined) {
      resolved.status = msg.status;
    }
    else {
      resolved.status = ''
    }

    if (msg.total_items !== undefined) {
      resolved.total_items = msg.total_items;
    }
    else {
      resolved.total_items = 0
    }

    if (msg.completed_items !== undefined) {
      resolved.completed_items = msg.completed_items;
    }
    else {
      resolved.completed_items = 0
    }

    if (msg.failed_items !== undefined) {
      resolved.failed_items = msg.failed_items;
    }
    else {
      resolved.failed_items = 0
    }

    if (msg.sorted_natural !== undefined) {
      resolved.sorted_natural = msg.sorted_natural;
    }
    else {
      resolved.sorted_natural = 0
    }

    if (msg.sorted_colored !== undefined) {
      resolved.sorted_colored = msg.sorted_colored;
    }
    else {
      resolved.sorted_colored = 0
    }

    if (msg.progress !== undefined) {
      resolved.progress = msg.progress;
    }
    else {
      resolved.progress = 0.0
    }

    if (msg.queue_size !== undefined) {
      resolved.queue_size = msg.queue_size;
    }
    else {
      resolved.queue_size = 0
    }

    if (msg.current_step !== undefined) {
      resolved.current_step = msg.current_step;
    }
    else {
      resolved.current_step = ''
    }

    if (msg.last_error !== undefined) {
      resolved.last_error = msg.last_error;
    }
    else {
      resolved.last_error = ''
    }

    return resolved;
    }
};

module.exports = TaskStatus;
