// Auto-generated. Do not edit!

// (in-package palletizing.srv)


"use strict";

const _serializer = _ros_msg_utils.Serialize;
const _arraySerializer = _serializer.Array;
const _deserializer = _ros_msg_utils.Deserialize;
const _arrayDeserializer = _deserializer.Array;
const _finder = _ros_msg_utils.Find;
const _getByteLength = _ros_msg_utils.getByteLength;

//-----------------------------------------------------------

let geometry_msgs = _finder('geometry_msgs');

//-----------------------------------------------------------

class TriggerDetectionRequest {
  constructor(initObj={}) {
    if (initObj === null) {
      // initObj === null is a special case for deserialization where we don't initialize fields
      this.cargo_type = null;
    }
    else {
      if (initObj.hasOwnProperty('cargo_type')) {
        this.cargo_type = initObj.cargo_type
      }
      else {
        this.cargo_type = '';
      }
    }
  }

  static serialize(obj, buffer, bufferOffset) {
    // Serializes a message object of type TriggerDetectionRequest
    // Serialize message field [cargo_type]
    bufferOffset = _serializer.string(obj.cargo_type, buffer, bufferOffset);
    return bufferOffset;
  }

  static deserialize(buffer, bufferOffset=[0]) {
    //deserializes a message object of type TriggerDetectionRequest
    let len;
    let data = new TriggerDetectionRequest(null);
    // Deserialize message field [cargo_type]
    data.cargo_type = _deserializer.string(buffer, bufferOffset);
    return data;
  }

  static getMessageSize(object) {
    let length = 0;
    length += _getByteLength(object.cargo_type);
    return length + 4;
  }

  static datatype() {
    // Returns string type for a service object
    return 'palletizing/TriggerDetectionRequest';
  }

  static md5sum() {
    //Returns md5sum for a message object
    return 'd8d3ec2048ffb969c4596e0ec3aef25b';
  }

  static messageDefinition() {
    // Returns full string definition for message
    return `
    # 触发单次视觉识别服务
    # 请求：货物类型
    string cargo_type
    
    `;
  }

  static Resolve(msg) {
    // deep-construct a valid message object instance of whatever was passed in
    if (typeof msg !== 'object' || msg === null) {
      msg = {};
    }
    const resolved = new TriggerDetectionRequest(null);
    if (msg.cargo_type !== undefined) {
      resolved.cargo_type = msg.cargo_type;
    }
    else {
      resolved.cargo_type = ''
    }

    return resolved;
    }
};

class TriggerDetectionResponse {
  constructor(initObj={}) {
    if (initObj === null) {
      // initObj === null is a special case for deserialization where we don't initialize fields
      this.success = null;
      this.message = null;
      this.position = null;
      this.remaining_count = null;
    }
    else {
      if (initObj.hasOwnProperty('success')) {
        this.success = initObj.success
      }
      else {
        this.success = false;
      }
      if (initObj.hasOwnProperty('message')) {
        this.message = initObj.message
      }
      else {
        this.message = '';
      }
      if (initObj.hasOwnProperty('position')) {
        this.position = initObj.position
      }
      else {
        this.position = new geometry_msgs.msg.Point();
      }
      if (initObj.hasOwnProperty('remaining_count')) {
        this.remaining_count = initObj.remaining_count
      }
      else {
        this.remaining_count = 0;
      }
    }
  }

  static serialize(obj, buffer, bufferOffset) {
    // Serializes a message object of type TriggerDetectionResponse
    // Serialize message field [success]
    bufferOffset = _serializer.bool(obj.success, buffer, bufferOffset);
    // Serialize message field [message]
    bufferOffset = _serializer.string(obj.message, buffer, bufferOffset);
    // Serialize message field [position]
    bufferOffset = geometry_msgs.msg.Point.serialize(obj.position, buffer, bufferOffset);
    // Serialize message field [remaining_count]
    bufferOffset = _serializer.int32(obj.remaining_count, buffer, bufferOffset);
    return bufferOffset;
  }

  static deserialize(buffer, bufferOffset=[0]) {
    //deserializes a message object of type TriggerDetectionResponse
    let len;
    let data = new TriggerDetectionResponse(null);
    // Deserialize message field [success]
    data.success = _deserializer.bool(buffer, bufferOffset);
    // Deserialize message field [message]
    data.message = _deserializer.string(buffer, bufferOffset);
    // Deserialize message field [position]
    data.position = geometry_msgs.msg.Point.deserialize(buffer, bufferOffset);
    // Deserialize message field [remaining_count]
    data.remaining_count = _deserializer.int32(buffer, bufferOffset);
    return data;
  }

  static getMessageSize(object) {
    let length = 0;
    length += _getByteLength(object.message);
    return length + 33;
  }

  static datatype() {
    // Returns string type for a service object
    return 'palletizing/TriggerDetectionResponse';
  }

  static md5sum() {
    //Returns md5sum for a message object
    return 'f5c9adf66f15c230ef796894d4b95eca';
  }

  static messageDefinition() {
    // Returns full string definition for message
    return `
    # 响应：是否成功、目标在 base_link 坐标系下的三维坐标
    bool success
    string message
    geometry_msgs/Point position
    int32 remaining_count
    
    
    ================================================================================
    MSG: geometry_msgs/Point
    # This contains the position of a point in free space
    float64 x
    float64 y
    float64 z
    
    `;
  }

  static Resolve(msg) {
    // deep-construct a valid message object instance of whatever was passed in
    if (typeof msg !== 'object' || msg === null) {
      msg = {};
    }
    const resolved = new TriggerDetectionResponse(null);
    if (msg.success !== undefined) {
      resolved.success = msg.success;
    }
    else {
      resolved.success = false
    }

    if (msg.message !== undefined) {
      resolved.message = msg.message;
    }
    else {
      resolved.message = ''
    }

    if (msg.position !== undefined) {
      resolved.position = geometry_msgs.msg.Point.Resolve(msg.position)
    }
    else {
      resolved.position = new geometry_msgs.msg.Point()
    }

    if (msg.remaining_count !== undefined) {
      resolved.remaining_count = msg.remaining_count;
    }
    else {
      resolved.remaining_count = 0
    }

    return resolved;
    }
};

module.exports = {
  Request: TriggerDetectionRequest,
  Response: TriggerDetectionResponse,
  md5sum() { return '36866cc854ee48ffadf2fd965e06457e'; },
  datatype() { return 'palletizing/TriggerDetection'; }
};
