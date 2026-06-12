// Auto-generated. Do not edit!

// (in-package palletizing.msg)


"use strict";

const _serializer = _ros_msg_utils.Serialize;
const _arraySerializer = _serializer.Array;
const _deserializer = _ros_msg_utils.Deserialize;
const _arrayDeserializer = _deserializer.Array;
const _finder = _ros_msg_utils.Find;
const _getByteLength = _ros_msg_utils.getByteLength;

//-----------------------------------------------------------

class PalletizingStats {
  constructor(initObj={}) {
    if (initObj === null) {
      // initObj === null is a special case for deserialization where we don't initialize fields
      this.total_objects = null;
      this.success_count = null;
      this.fail_count = null;
      this.current_layer = null;
      this.hard_zone_layers = null;
      this.soft_zone_layers = null;
      this.success_rate = null;
      this.avg_cycle_time = null;
      this.elapsed_time = null;
      this.current_state = null;
    }
    else {
      if (initObj.hasOwnProperty('total_objects')) {
        this.total_objects = initObj.total_objects
      }
      else {
        this.total_objects = 0;
      }
      if (initObj.hasOwnProperty('success_count')) {
        this.success_count = initObj.success_count
      }
      else {
        this.success_count = 0;
      }
      if (initObj.hasOwnProperty('fail_count')) {
        this.fail_count = initObj.fail_count
      }
      else {
        this.fail_count = 0;
      }
      if (initObj.hasOwnProperty('current_layer')) {
        this.current_layer = initObj.current_layer
      }
      else {
        this.current_layer = 0;
      }
      if (initObj.hasOwnProperty('hard_zone_layers')) {
        this.hard_zone_layers = initObj.hard_zone_layers
      }
      else {
        this.hard_zone_layers = 0;
      }
      if (initObj.hasOwnProperty('soft_zone_layers')) {
        this.soft_zone_layers = initObj.soft_zone_layers
      }
      else {
        this.soft_zone_layers = 0;
      }
      if (initObj.hasOwnProperty('success_rate')) {
        this.success_rate = initObj.success_rate
      }
      else {
        this.success_rate = 0.0;
      }
      if (initObj.hasOwnProperty('avg_cycle_time')) {
        this.avg_cycle_time = initObj.avg_cycle_time
      }
      else {
        this.avg_cycle_time = 0.0;
      }
      if (initObj.hasOwnProperty('elapsed_time')) {
        this.elapsed_time = initObj.elapsed_time
      }
      else {
        this.elapsed_time = 0.0;
      }
      if (initObj.hasOwnProperty('current_state')) {
        this.current_state = initObj.current_state
      }
      else {
        this.current_state = '';
      }
    }
  }

  static serialize(obj, buffer, bufferOffset) {
    // Serializes a message object of type PalletizingStats
    // Serialize message field [total_objects]
    bufferOffset = _serializer.uint32(obj.total_objects, buffer, bufferOffset);
    // Serialize message field [success_count]
    bufferOffset = _serializer.uint32(obj.success_count, buffer, bufferOffset);
    // Serialize message field [fail_count]
    bufferOffset = _serializer.uint32(obj.fail_count, buffer, bufferOffset);
    // Serialize message field [current_layer]
    bufferOffset = _serializer.uint32(obj.current_layer, buffer, bufferOffset);
    // Serialize message field [hard_zone_layers]
    bufferOffset = _serializer.uint32(obj.hard_zone_layers, buffer, bufferOffset);
    // Serialize message field [soft_zone_layers]
    bufferOffset = _serializer.uint32(obj.soft_zone_layers, buffer, bufferOffset);
    // Serialize message field [success_rate]
    bufferOffset = _serializer.float64(obj.success_rate, buffer, bufferOffset);
    // Serialize message field [avg_cycle_time]
    bufferOffset = _serializer.float64(obj.avg_cycle_time, buffer, bufferOffset);
    // Serialize message field [elapsed_time]
    bufferOffset = _serializer.float64(obj.elapsed_time, buffer, bufferOffset);
    // Serialize message field [current_state]
    bufferOffset = _serializer.string(obj.current_state, buffer, bufferOffset);
    return bufferOffset;
  }

  static deserialize(buffer, bufferOffset=[0]) {
    //deserializes a message object of type PalletizingStats
    let len;
    let data = new PalletizingStats(null);
    // Deserialize message field [total_objects]
    data.total_objects = _deserializer.uint32(buffer, bufferOffset);
    // Deserialize message field [success_count]
    data.success_count = _deserializer.uint32(buffer, bufferOffset);
    // Deserialize message field [fail_count]
    data.fail_count = _deserializer.uint32(buffer, bufferOffset);
    // Deserialize message field [current_layer]
    data.current_layer = _deserializer.uint32(buffer, bufferOffset);
    // Deserialize message field [hard_zone_layers]
    data.hard_zone_layers = _deserializer.uint32(buffer, bufferOffset);
    // Deserialize message field [soft_zone_layers]
    data.soft_zone_layers = _deserializer.uint32(buffer, bufferOffset);
    // Deserialize message field [success_rate]
    data.success_rate = _deserializer.float64(buffer, bufferOffset);
    // Deserialize message field [avg_cycle_time]
    data.avg_cycle_time = _deserializer.float64(buffer, bufferOffset);
    // Deserialize message field [elapsed_time]
    data.elapsed_time = _deserializer.float64(buffer, bufferOffset);
    // Deserialize message field [current_state]
    data.current_state = _deserializer.string(buffer, bufferOffset);
    return data;
  }

  static getMessageSize(object) {
    let length = 0;
    length += _getByteLength(object.current_state);
    return length + 52;
  }

  static datatype() {
    // Returns string type for a message object
    return 'palletizing/PalletizingStats';
  }

  static md5sum() {
    //Returns md5sum for a message object
    return '92aa1e36e09f1e3fca1e85e1659ad3fe';
  }

  static messageDefinition() {
    // Returns full string definition for message
    return `
    uint32 total_objects
    uint32 success_count
    uint32 fail_count
    uint32 current_layer
    uint32 hard_zone_layers
    uint32 soft_zone_layers
    float64 success_rate
    float64 avg_cycle_time
    float64 elapsed_time
    string current_state
    
    `;
  }

  static Resolve(msg) {
    // deep-construct a valid message object instance of whatever was passed in
    if (typeof msg !== 'object' || msg === null) {
      msg = {};
    }
    const resolved = new PalletizingStats(null);
    if (msg.total_objects !== undefined) {
      resolved.total_objects = msg.total_objects;
    }
    else {
      resolved.total_objects = 0
    }

    if (msg.success_count !== undefined) {
      resolved.success_count = msg.success_count;
    }
    else {
      resolved.success_count = 0
    }

    if (msg.fail_count !== undefined) {
      resolved.fail_count = msg.fail_count;
    }
    else {
      resolved.fail_count = 0
    }

    if (msg.current_layer !== undefined) {
      resolved.current_layer = msg.current_layer;
    }
    else {
      resolved.current_layer = 0
    }

    if (msg.hard_zone_layers !== undefined) {
      resolved.hard_zone_layers = msg.hard_zone_layers;
    }
    else {
      resolved.hard_zone_layers = 0
    }

    if (msg.soft_zone_layers !== undefined) {
      resolved.soft_zone_layers = msg.soft_zone_layers;
    }
    else {
      resolved.soft_zone_layers = 0
    }

    if (msg.success_rate !== undefined) {
      resolved.success_rate = msg.success_rate;
    }
    else {
      resolved.success_rate = 0.0
    }

    if (msg.avg_cycle_time !== undefined) {
      resolved.avg_cycle_time = msg.avg_cycle_time;
    }
    else {
      resolved.avg_cycle_time = 0.0
    }

    if (msg.elapsed_time !== undefined) {
      resolved.elapsed_time = msg.elapsed_time;
    }
    else {
      resolved.elapsed_time = 0.0
    }

    if (msg.current_state !== undefined) {
      resolved.current_state = msg.current_state;
    }
    else {
      resolved.current_state = ''
    }

    return resolved;
    }
};

module.exports = PalletizingStats;
