// Auto-generated. Do not edit!

// (in-package warehouse_sorting_msgs.msg)


"use strict";

const _serializer = _ros_msg_utils.Serialize;
const _arraySerializer = _serializer.Array;
const _deserializer = _ros_msg_utils.Deserialize;
const _arrayDeserializer = _deserializer.Array;
const _finder = _ros_msg_utils.Find;
const _getByteLength = _ros_msg_utils.getByteLength;
let geometry_msgs = _finder('geometry_msgs');

//-----------------------------------------------------------

class Cargo {
  constructor(initObj={}) {
    if (initObj === null) {
      // initObj === null is a special case for deserialization where we don't initialize fields
      this.cargo_id = null;
      this.cargo_type = null;
      this.pose = null;
      this.size = null;
      this.volume = null;
      this.confidence = null;
      this.bbox_x = null;
      this.bbox_y = null;
      this.bbox_width = null;
      this.bbox_height = null;
    }
    else {
      if (initObj.hasOwnProperty('cargo_id')) {
        this.cargo_id = initObj.cargo_id
      }
      else {
        this.cargo_id = '';
      }
      if (initObj.hasOwnProperty('cargo_type')) {
        this.cargo_type = initObj.cargo_type
      }
      else {
        this.cargo_type = '';
      }
      if (initObj.hasOwnProperty('pose')) {
        this.pose = initObj.pose
      }
      else {
        this.pose = new geometry_msgs.msg.Pose();
      }
      if (initObj.hasOwnProperty('size')) {
        this.size = initObj.size
      }
      else {
        this.size = new geometry_msgs.msg.Vector3();
      }
      if (initObj.hasOwnProperty('volume')) {
        this.volume = initObj.volume
      }
      else {
        this.volume = 0.0;
      }
      if (initObj.hasOwnProperty('confidence')) {
        this.confidence = initObj.confidence
      }
      else {
        this.confidence = 0.0;
      }
      if (initObj.hasOwnProperty('bbox_x')) {
        this.bbox_x = initObj.bbox_x
      }
      else {
        this.bbox_x = 0;
      }
      if (initObj.hasOwnProperty('bbox_y')) {
        this.bbox_y = initObj.bbox_y
      }
      else {
        this.bbox_y = 0;
      }
      if (initObj.hasOwnProperty('bbox_width')) {
        this.bbox_width = initObj.bbox_width
      }
      else {
        this.bbox_width = 0;
      }
      if (initObj.hasOwnProperty('bbox_height')) {
        this.bbox_height = initObj.bbox_height
      }
      else {
        this.bbox_height = 0;
      }
    }
  }

  static serialize(obj, buffer, bufferOffset) {
    // Serializes a message object of type Cargo
    // Serialize message field [cargo_id]
    bufferOffset = _serializer.string(obj.cargo_id, buffer, bufferOffset);
    // Serialize message field [cargo_type]
    bufferOffset = _serializer.string(obj.cargo_type, buffer, bufferOffset);
    // Serialize message field [pose]
    bufferOffset = geometry_msgs.msg.Pose.serialize(obj.pose, buffer, bufferOffset);
    // Serialize message field [size]
    bufferOffset = geometry_msgs.msg.Vector3.serialize(obj.size, buffer, bufferOffset);
    // Serialize message field [volume]
    bufferOffset = _serializer.float32(obj.volume, buffer, bufferOffset);
    // Serialize message field [confidence]
    bufferOffset = _serializer.float32(obj.confidence, buffer, bufferOffset);
    // Serialize message field [bbox_x]
    bufferOffset = _serializer.int32(obj.bbox_x, buffer, bufferOffset);
    // Serialize message field [bbox_y]
    bufferOffset = _serializer.int32(obj.bbox_y, buffer, bufferOffset);
    // Serialize message field [bbox_width]
    bufferOffset = _serializer.int32(obj.bbox_width, buffer, bufferOffset);
    // Serialize message field [bbox_height]
    bufferOffset = _serializer.int32(obj.bbox_height, buffer, bufferOffset);
    return bufferOffset;
  }

  static deserialize(buffer, bufferOffset=[0]) {
    //deserializes a message object of type Cargo
    let len;
    let data = new Cargo(null);
    // Deserialize message field [cargo_id]
    data.cargo_id = _deserializer.string(buffer, bufferOffset);
    // Deserialize message field [cargo_type]
    data.cargo_type = _deserializer.string(buffer, bufferOffset);
    // Deserialize message field [pose]
    data.pose = geometry_msgs.msg.Pose.deserialize(buffer, bufferOffset);
    // Deserialize message field [size]
    data.size = geometry_msgs.msg.Vector3.deserialize(buffer, bufferOffset);
    // Deserialize message field [volume]
    data.volume = _deserializer.float32(buffer, bufferOffset);
    // Deserialize message field [confidence]
    data.confidence = _deserializer.float32(buffer, bufferOffset);
    // Deserialize message field [bbox_x]
    data.bbox_x = _deserializer.int32(buffer, bufferOffset);
    // Deserialize message field [bbox_y]
    data.bbox_y = _deserializer.int32(buffer, bufferOffset);
    // Deserialize message field [bbox_width]
    data.bbox_width = _deserializer.int32(buffer, bufferOffset);
    // Deserialize message field [bbox_height]
    data.bbox_height = _deserializer.int32(buffer, bufferOffset);
    return data;
  }

  static getMessageSize(object) {
    let length = 0;
    length += _getByteLength(object.cargo_id);
    length += _getByteLength(object.cargo_type);
    return length + 112;
  }

  static datatype() {
    // Returns string type for a message object
    return 'warehouse_sorting_msgs/Cargo';
  }

  static md5sum() {
    //Returns md5sum for a message object
    return 'f165e9d8fad2d5fab3540432824f5105';
  }

  static messageDefinition() {
    // Returns full string definition for message
    return `
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
    const resolved = new Cargo(null);
    if (msg.cargo_id !== undefined) {
      resolved.cargo_id = msg.cargo_id;
    }
    else {
      resolved.cargo_id = ''
    }

    if (msg.cargo_type !== undefined) {
      resolved.cargo_type = msg.cargo_type;
    }
    else {
      resolved.cargo_type = ''
    }

    if (msg.pose !== undefined) {
      resolved.pose = geometry_msgs.msg.Pose.Resolve(msg.pose)
    }
    else {
      resolved.pose = new geometry_msgs.msg.Pose()
    }

    if (msg.size !== undefined) {
      resolved.size = geometry_msgs.msg.Vector3.Resolve(msg.size)
    }
    else {
      resolved.size = new geometry_msgs.msg.Vector3()
    }

    if (msg.volume !== undefined) {
      resolved.volume = msg.volume;
    }
    else {
      resolved.volume = 0.0
    }

    if (msg.confidence !== undefined) {
      resolved.confidence = msg.confidence;
    }
    else {
      resolved.confidence = 0.0
    }

    if (msg.bbox_x !== undefined) {
      resolved.bbox_x = msg.bbox_x;
    }
    else {
      resolved.bbox_x = 0
    }

    if (msg.bbox_y !== undefined) {
      resolved.bbox_y = msg.bbox_y;
    }
    else {
      resolved.bbox_y = 0
    }

    if (msg.bbox_width !== undefined) {
      resolved.bbox_width = msg.bbox_width;
    }
    else {
      resolved.bbox_width = 0
    }

    if (msg.bbox_height !== undefined) {
      resolved.bbox_height = msg.bbox_height;
    }
    else {
      resolved.bbox_height = 0
    }

    return resolved;
    }
};

module.exports = Cargo;
