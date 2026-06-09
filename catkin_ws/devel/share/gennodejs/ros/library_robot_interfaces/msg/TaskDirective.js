// Auto-generated. Do not edit!

// (in-package library_robot_interfaces.msg)


"use strict";

const _serializer = _ros_msg_utils.Serialize;
const _arraySerializer = _serializer.Array;
const _deserializer = _ros_msg_utils.Deserialize;
const _arrayDeserializer = _deserializer.Array;
const _finder = _ros_msg_utils.Find;
const _getByteLength = _ros_msg_utils.getByteLength;
let std_msgs = _finder('std_msgs');

//-----------------------------------------------------------

class TaskDirective {
  constructor(initObj={}) {
    if (initObj === null) {
      // initObj === null is a special case for deserialization where we don't initialize fields
      this.header = null;
      this.command_type = null;
      this.task_id_rails = null;
      this.task_type_rails = null;
      this.task_priority = null;
      this.parameters_json = null;
    }
    else {
      if (initObj.hasOwnProperty('header')) {
        this.header = initObj.header
      }
      else {
        this.header = new std_msgs.msg.Header();
      }
      if (initObj.hasOwnProperty('command_type')) {
        this.command_type = initObj.command_type
      }
      else {
        this.command_type = '';
      }
      if (initObj.hasOwnProperty('task_id_rails')) {
        this.task_id_rails = initObj.task_id_rails
      }
      else {
        this.task_id_rails = '';
      }
      if (initObj.hasOwnProperty('task_type_rails')) {
        this.task_type_rails = initObj.task_type_rails
      }
      else {
        this.task_type_rails = '';
      }
      if (initObj.hasOwnProperty('task_priority')) {
        this.task_priority = initObj.task_priority
      }
      else {
        this.task_priority = 0;
      }
      if (initObj.hasOwnProperty('parameters_json')) {
        this.parameters_json = initObj.parameters_json
      }
      else {
        this.parameters_json = '';
      }
    }
  }

  static serialize(obj, buffer, bufferOffset) {
    // Serializes a message object of type TaskDirective
    // Serialize message field [header]
    bufferOffset = std_msgs.msg.Header.serialize(obj.header, buffer, bufferOffset);
    // Serialize message field [command_type]
    bufferOffset = _serializer.string(obj.command_type, buffer, bufferOffset);
    // Serialize message field [task_id_rails]
    bufferOffset = _serializer.string(obj.task_id_rails, buffer, bufferOffset);
    // Serialize message field [task_type_rails]
    bufferOffset = _serializer.string(obj.task_type_rails, buffer, bufferOffset);
    // Serialize message field [task_priority]
    bufferOffset = _serializer.int32(obj.task_priority, buffer, bufferOffset);
    // Serialize message field [parameters_json]
    bufferOffset = _serializer.string(obj.parameters_json, buffer, bufferOffset);
    return bufferOffset;
  }

  static deserialize(buffer, bufferOffset=[0]) {
    //deserializes a message object of type TaskDirective
    let len;
    let data = new TaskDirective(null);
    // Deserialize message field [header]
    data.header = std_msgs.msg.Header.deserialize(buffer, bufferOffset);
    // Deserialize message field [command_type]
    data.command_type = _deserializer.string(buffer, bufferOffset);
    // Deserialize message field [task_id_rails]
    data.task_id_rails = _deserializer.string(buffer, bufferOffset);
    // Deserialize message field [task_type_rails]
    data.task_type_rails = _deserializer.string(buffer, bufferOffset);
    // Deserialize message field [task_priority]
    data.task_priority = _deserializer.int32(buffer, bufferOffset);
    // Deserialize message field [parameters_json]
    data.parameters_json = _deserializer.string(buffer, bufferOffset);
    return data;
  }

  static getMessageSize(object) {
    let length = 0;
    length += std_msgs.msg.Header.getMessageSize(object.header);
    length += _getByteLength(object.command_type);
    length += _getByteLength(object.task_id_rails);
    length += _getByteLength(object.task_type_rails);
    length += _getByteLength(object.parameters_json);
    return length + 20;
  }

  static datatype() {
    // Returns string type for a message object
    return 'library_robot_interfaces/TaskDirective';
  }

  static md5sum() {
    //Returns md5sum for a message object
    return 'd22fcfa77d7cca35dedf9ea427a99e6a';
  }

  static messageDefinition() {
    // Returns full string definition for message
    return `
    std_msgs/Header header
    string command_type          # 例如: "TASK_EXECUTE", "TASK_CANCEL", "MOVE", "EMERGENCY_STOP"
    string task_id_rails         # Rails Task ID (如果适用，对于即时命令可以为空或特定值)
    string task_type_rails       # 例如: "MAP_BUILD_AUTO", "LOAD_MAP", 或对于即时命令，同command_type
    int32 task_priority         # 任务优先级，0表示最低，10表示最高
    string parameters_json       # JSON字符串，包含任务或命令所需的参数
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
    const resolved = new TaskDirective(null);
    if (msg.header !== undefined) {
      resolved.header = std_msgs.msg.Header.Resolve(msg.header)
    }
    else {
      resolved.header = new std_msgs.msg.Header()
    }

    if (msg.command_type !== undefined) {
      resolved.command_type = msg.command_type;
    }
    else {
      resolved.command_type = ''
    }

    if (msg.task_id_rails !== undefined) {
      resolved.task_id_rails = msg.task_id_rails;
    }
    else {
      resolved.task_id_rails = ''
    }

    if (msg.task_type_rails !== undefined) {
      resolved.task_type_rails = msg.task_type_rails;
    }
    else {
      resolved.task_type_rails = ''
    }

    if (msg.task_priority !== undefined) {
      resolved.task_priority = msg.task_priority;
    }
    else {
      resolved.task_priority = 0
    }

    if (msg.parameters_json !== undefined) {
      resolved.parameters_json = msg.parameters_json;
    }
    else {
      resolved.parameters_json = ''
    }

    return resolved;
    }
};

module.exports = TaskDirective;
