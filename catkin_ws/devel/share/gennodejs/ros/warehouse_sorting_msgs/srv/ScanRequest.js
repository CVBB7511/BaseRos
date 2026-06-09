// Auto-generated. Do not edit!

// (in-package warehouse_sorting_msgs.srv)


"use strict";

const _serializer = _ros_msg_utils.Serialize;
const _arraySerializer = _serializer.Array;
const _deserializer = _ros_msg_utils.Deserialize;
const _arrayDeserializer = _deserializer.Array;
const _finder = _ros_msg_utils.Find;
const _getByteLength = _ros_msg_utils.getByteLength;

//-----------------------------------------------------------

let DetectedCargoArray = require('../msg/DetectedCargoArray.js');

//-----------------------------------------------------------

class ScanRequestRequest {
  constructor(initObj={}) {
    if (initObj === null) {
      // initObj === null is a special case for deserialization where we don't initialize fields
      this.force = null;
    }
    else {
      if (initObj.hasOwnProperty('force')) {
        this.force = initObj.force
      }
      else {
        this.force = false;
      }
    }
  }

  static serialize(obj, buffer, bufferOffset) {
    // Serializes a message object of type ScanRequestRequest
    // Serialize message field [force]
    bufferOffset = _serializer.bool(obj.force, buffer, bufferOffset);
    return bufferOffset;
  }

  static deserialize(buffer, bufferOffset=[0]) {
    //deserializes a message object of type ScanRequestRequest
    let len;
    let data = new ScanRequestRequest(null);
    // Deserialize message field [force]
    data.force = _deserializer.bool(buffer, bufferOffset);
    return data;
  }

  static getMessageSize(object) {
    return 1;
  }

  static datatype() {
    // Returns string type for a service object
    return 'warehouse_sorting_msgs/ScanRequestRequest';
  }

  static md5sum() {
    //Returns md5sum for a message object
    return '6fd3f14734166c254bff9db47985b674';
  }

  static messageDefinition() {
    // Returns full string definition for message
    return `
    bool force
    
    `;
  }

  static Resolve(msg) {
    // deep-construct a valid message object instance of whatever was passed in
    if (typeof msg !== 'object' || msg === null) {
      msg = {};
    }
    const resolved = new ScanRequestRequest(null);
    if (msg.force !== undefined) {
      resolved.force = msg.force;
    }
    else {
      resolved.force = false
    }

    return resolved;
    }
};

class ScanRequestResponse {
  constructor(initObj={}) {
    if (initObj === null) {
      // initObj === null is a special case for deserialization where we don't initialize fields
      this.success = null;
      this.message = null;
      this.detections = null;
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
      if (initObj.hasOwnProperty('detections')) {
        this.detections = initObj.detections
      }
      else {
        this.detections = new DetectedCargoArray();
      }
    }
  }

  static serialize(obj, buffer, bufferOffset) {
    // Serializes a message object of type ScanRequestResponse
    // Serialize message field [success]
    bufferOffset = _serializer.bool(obj.success, buffer, bufferOffset);
    // Serialize message field [message]
    bufferOffset = _serializer.string(obj.message, buffer, bufferOffset);
    // Serialize message field [detections]
    bufferOffset = DetectedCargoArray.serialize(obj.detections, buffer, bufferOffset);
    return bufferOffset;
  }

  static deserialize(buffer, bufferOffset=[0]) {
    //deserializes a message object of type ScanRequestResponse
    let len;
    let data = new ScanRequestResponse(null);
    // Deserialize message field [success]
    data.success = _deserializer.bool(buffer, bufferOffset);
    // Deserialize message field [message]
    data.message = _deserializer.string(buffer, bufferOffset);
    // Deserialize message field [detections]
    data.detections = DetectedCargoArray.deserialize(buffer, bufferOffset);
    return data;
  }

  static getMessageSize(object) {
    let length = 0;
    length += _getByteLength(object.message);
    length += DetectedCargoArray.getMessageSize(object.detections);
    return length + 5;
  }

  static datatype() {
    // Returns string type for a service object
    return 'warehouse_sorting_msgs/ScanRequestResponse';
  }

  static md5sum() {
    //Returns md5sum for a message object
    return 'cd4be7cf4af5e71c48052122ff3c1d88';
  }

  static messageDefinition() {
    // Returns full string definition for message
    return `
    bool success
    string message
    warehouse_sorting_msgs/DetectedCargoArray detections
    
    
    ================================================================================
    MSG: warehouse_sorting_msgs/DetectedCargoArray
    std_msgs/Header header
    warehouse_sorting_msgs/Cargo[] objects
    
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
    
    ================================================================================
    MSG: warehouse_sorting_msgs/Cargo
    string cargo_id
    string cargo_type
    geometry_msgs/Pose pose
    geometry_msgs/Vector3 size
    float32 volume
    float32 confidence
    int32 bbox_x
    int32 bbox_y
    int32 bbox_width
    int32 bbox_height
    
    ================================================================================
    MSG: geometry_msgs/Pose
    # A representation of pose in free space, composed of position and orientation. 
    Point position
    Quaternion orientation
    
    ================================================================================
    MSG: geometry_msgs/Point
    # This contains the position of a point in free space
    float64 x
    float64 y
    float64 z
    
    ================================================================================
    MSG: geometry_msgs/Quaternion
    # This represents an orientation in free space in quaternion form.
    
    float64 x
    float64 y
    float64 z
    float64 w
    
    ================================================================================
    MSG: geometry_msgs/Vector3
    # This represents a vector in free space. 
    # It is only meant to represent a direction. Therefore, it does not
    # make sense to apply a translation to it (e.g., when applying a 
    # generic rigid transformation to a Vector3, tf2 will only apply the
    # rotation). If you want your data to be translatable too, use the
    # geometry_msgs/Point message instead.
    
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
    const resolved = new ScanRequestResponse(null);
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

    if (msg.detections !== undefined) {
      resolved.detections = DetectedCargoArray.Resolve(msg.detections)
    }
    else {
      resolved.detections = new DetectedCargoArray()
    }

    return resolved;
    }
};

module.exports = {
  Request: ScanRequestRequest,
  Response: ScanRequestResponse,
  md5sum() { return 'c6db9a8beb3e4e03e56bddc308994352'; },
  datatype() { return 'warehouse_sorting_msgs/ScanRequest'; }
};
