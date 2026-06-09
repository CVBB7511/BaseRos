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

class RobotStatusCompressed {
  constructor(initObj={}) {
    if (initObj === null) {
      // initObj === null is a special case for deserialization where we don't initialize fields
      this.header = null;
      this.pose_x = null;
      this.pose_y = null;
      this.pose_theta = null;
      this.velocity_linear = null;
      this.velocity_angular = null;
      this.battery_percentage = null;
      this.robot_state_str = null;
      this.error_message = null;
      this.is_emergency_stopped = null;
      this.active_task_id_rails = null;
      this.active_map = null;
    }
    else {
      if (initObj.hasOwnProperty('header')) {
        this.header = initObj.header
      }
      else {
        this.header = new std_msgs.msg.Header();
      }
      if (initObj.hasOwnProperty('pose_x')) {
        this.pose_x = initObj.pose_x
      }
      else {
        this.pose_x = 0.0;
      }
      if (initObj.hasOwnProperty('pose_y')) {
        this.pose_y = initObj.pose_y
      }
      else {
        this.pose_y = 0.0;
      }
      if (initObj.hasOwnProperty('pose_theta')) {
        this.pose_theta = initObj.pose_theta
      }
      else {
        this.pose_theta = 0.0;
      }
      if (initObj.hasOwnProperty('velocity_linear')) {
        this.velocity_linear = initObj.velocity_linear
      }
      else {
        this.velocity_linear = 0.0;
      }
      if (initObj.hasOwnProperty('velocity_angular')) {
        this.velocity_angular = initObj.velocity_angular
      }
      else {
        this.velocity_angular = 0.0;
      }
      if (initObj.hasOwnProperty('battery_percentage')) {
        this.battery_percentage = initObj.battery_percentage
      }
      else {
        this.battery_percentage = 0.0;
      }
      if (initObj.hasOwnProperty('robot_state_str')) {
        this.robot_state_str = initObj.robot_state_str
      }
      else {
        this.robot_state_str = '';
      }
      if (initObj.hasOwnProperty('error_message')) {
        this.error_message = initObj.error_message
      }
      else {
        this.error_message = '';
      }
      if (initObj.hasOwnProperty('is_emergency_stopped')) {
        this.is_emergency_stopped = initObj.is_emergency_stopped
      }
      else {
        this.is_emergency_stopped = false;
      }
      if (initObj.hasOwnProperty('active_task_id_rails')) {
        this.active_task_id_rails = initObj.active_task_id_rails
      }
      else {
        this.active_task_id_rails = 0;
      }
      if (initObj.hasOwnProperty('active_map')) {
        this.active_map = initObj.active_map
      }
      else {
        this.active_map = 0;
      }
    }
  }

  static serialize(obj, buffer, bufferOffset) {
    // Serializes a message object of type RobotStatusCompressed
    // Serialize message field [header]
    bufferOffset = std_msgs.msg.Header.serialize(obj.header, buffer, bufferOffset);
    // Serialize message field [pose_x]
    bufferOffset = _serializer.float32(obj.pose_x, buffer, bufferOffset);
    // Serialize message field [pose_y]
    bufferOffset = _serializer.float32(obj.pose_y, buffer, bufferOffset);
    // Serialize message field [pose_theta]
    bufferOffset = _serializer.float32(obj.pose_theta, buffer, bufferOffset);
    // Serialize message field [velocity_linear]
    bufferOffset = _serializer.float32(obj.velocity_linear, buffer, bufferOffset);
    // Serialize message field [velocity_angular]
    bufferOffset = _serializer.float32(obj.velocity_angular, buffer, bufferOffset);
    // Serialize message field [battery_percentage]
    bufferOffset = _serializer.float32(obj.battery_percentage, buffer, bufferOffset);
    // Serialize message field [robot_state_str]
    bufferOffset = _serializer.string(obj.robot_state_str, buffer, bufferOffset);
    // Serialize message field [error_message]
    bufferOffset = _serializer.string(obj.error_message, buffer, bufferOffset);
    // Serialize message field [is_emergency_stopped]
    bufferOffset = _serializer.bool(obj.is_emergency_stopped, buffer, bufferOffset);
    // Serialize message field [active_task_id_rails]
    bufferOffset = _serializer.int32(obj.active_task_id_rails, buffer, bufferOffset);
    // Serialize message field [active_map]
    bufferOffset = _serializer.int32(obj.active_map, buffer, bufferOffset);
    return bufferOffset;
  }

  static deserialize(buffer, bufferOffset=[0]) {
    //deserializes a message object of type RobotStatusCompressed
    let len;
    let data = new RobotStatusCompressed(null);
    // Deserialize message field [header]
    data.header = std_msgs.msg.Header.deserialize(buffer, bufferOffset);
    // Deserialize message field [pose_x]
    data.pose_x = _deserializer.float32(buffer, bufferOffset);
    // Deserialize message field [pose_y]
    data.pose_y = _deserializer.float32(buffer, bufferOffset);
    // Deserialize message field [pose_theta]
    data.pose_theta = _deserializer.float32(buffer, bufferOffset);
    // Deserialize message field [velocity_linear]
    data.velocity_linear = _deserializer.float32(buffer, bufferOffset);
    // Deserialize message field [velocity_angular]
    data.velocity_angular = _deserializer.float32(buffer, bufferOffset);
    // Deserialize message field [battery_percentage]
    data.battery_percentage = _deserializer.float32(buffer, bufferOffset);
    // Deserialize message field [robot_state_str]
    data.robot_state_str = _deserializer.string(buffer, bufferOffset);
    // Deserialize message field [error_message]
    data.error_message = _deserializer.string(buffer, bufferOffset);
    // Deserialize message field [is_emergency_stopped]
    data.is_emergency_stopped = _deserializer.bool(buffer, bufferOffset);
    // Deserialize message field [active_task_id_rails]
    data.active_task_id_rails = _deserializer.int32(buffer, bufferOffset);
    // Deserialize message field [active_map]
    data.active_map = _deserializer.int32(buffer, bufferOffset);
    return data;
  }

  static getMessageSize(object) {
    let length = 0;
    length += std_msgs.msg.Header.getMessageSize(object.header);
    length += _getByteLength(object.robot_state_str);
    length += _getByteLength(object.error_message);
    return length + 41;
  }

  static datatype() {
    // Returns string type for a message object
    return 'library_robot_interfaces/RobotStatusCompressed';
  }

  static md5sum() {
    //Returns md5sum for a message object
    return '6fbfcb9ff0fd4a4ddc6e1fcb05506c41';
  }

  static messageDefinition() {
    // Returns full string definition for message
    return `
    std_msgs/Header header
    float32 pose_x
    float32 pose_y
    float32 pose_theta
    float32 velocity_linear
    float32 velocity_angular
    float32 battery_percentage  # 0.0 到 100.0
    string robot_state_str      # TaskManager维护的机器人状态字符串, e.g., "idle", "mapping", "error_localization_lost"
    string error_message        # 当前错误信息 (如果有)
    bool is_emergency_stopped
    int32 active_task_id_rails # 当前正在执行的Rails Task ID (0 如果没有)
    int32 active_map      # ROS中当前加载的地图的ID (0 如果没有)
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
    const resolved = new RobotStatusCompressed(null);
    if (msg.header !== undefined) {
      resolved.header = std_msgs.msg.Header.Resolve(msg.header)
    }
    else {
      resolved.header = new std_msgs.msg.Header()
    }

    if (msg.pose_x !== undefined) {
      resolved.pose_x = msg.pose_x;
    }
    else {
      resolved.pose_x = 0.0
    }

    if (msg.pose_y !== undefined) {
      resolved.pose_y = msg.pose_y;
    }
    else {
      resolved.pose_y = 0.0
    }

    if (msg.pose_theta !== undefined) {
      resolved.pose_theta = msg.pose_theta;
    }
    else {
      resolved.pose_theta = 0.0
    }

    if (msg.velocity_linear !== undefined) {
      resolved.velocity_linear = msg.velocity_linear;
    }
    else {
      resolved.velocity_linear = 0.0
    }

    if (msg.velocity_angular !== undefined) {
      resolved.velocity_angular = msg.velocity_angular;
    }
    else {
      resolved.velocity_angular = 0.0
    }

    if (msg.battery_percentage !== undefined) {
      resolved.battery_percentage = msg.battery_percentage;
    }
    else {
      resolved.battery_percentage = 0.0
    }

    if (msg.robot_state_str !== undefined) {
      resolved.robot_state_str = msg.robot_state_str;
    }
    else {
      resolved.robot_state_str = ''
    }

    if (msg.error_message !== undefined) {
      resolved.error_message = msg.error_message;
    }
    else {
      resolved.error_message = ''
    }

    if (msg.is_emergency_stopped !== undefined) {
      resolved.is_emergency_stopped = msg.is_emergency_stopped;
    }
    else {
      resolved.is_emergency_stopped = false
    }

    if (msg.active_task_id_rails !== undefined) {
      resolved.active_task_id_rails = msg.active_task_id_rails;
    }
    else {
      resolved.active_task_id_rails = 0
    }

    if (msg.active_map !== undefined) {
      resolved.active_map = msg.active_map;
    }
    else {
      resolved.active_map = 0
    }

    return resolved;
    }
};

module.exports = RobotStatusCompressed;
