// Auto-generated. Do not edit!

// (in-package fetch_server.srv)


"use strict";

const _serializer = _ros_msg_utils.Serialize;
const _arraySerializer = _serializer.Array;
const _deserializer = _ros_msg_utils.Deserialize;
const _arrayDeserializer = _deserializer.Array;
const _finder = _ros_msg_utils.Find;
const _getByteLength = _ros_msg_utils.getByteLength;

//-----------------------------------------------------------


//-----------------------------------------------------------

class FetchRequest {
  constructor(initObj={}) {
    if (initObj === null) {
      // initObj === null is a special case for deserialization where we don't initialize fields
      this.gpx = null;
      this.gpy = null;
      this.gpz = null;
      this.goz = null;
      this.ppx = null;
      this.ppy = null;
      this.ppz = null;
      this.poz = null;
    }
    else {
      if (initObj.hasOwnProperty('gpx')) {
        this.gpx = initObj.gpx
      }
      else {
        this.gpx = 0.0;
      }
      if (initObj.hasOwnProperty('gpy')) {
        this.gpy = initObj.gpy
      }
      else {
        this.gpy = 0.0;
      }
      if (initObj.hasOwnProperty('gpz')) {
        this.gpz = initObj.gpz
      }
      else {
        this.gpz = 0.0;
      }
      if (initObj.hasOwnProperty('goz')) {
        this.goz = initObj.goz
      }
      else {
        this.goz = 0.0;
      }
      if (initObj.hasOwnProperty('ppx')) {
        this.ppx = initObj.ppx
      }
      else {
        this.ppx = 0.0;
      }
      if (initObj.hasOwnProperty('ppy')) {
        this.ppy = initObj.ppy
      }
      else {
        this.ppy = 0.0;
      }
      if (initObj.hasOwnProperty('ppz')) {
        this.ppz = initObj.ppz
      }
      else {
        this.ppz = 0.0;
      }
      if (initObj.hasOwnProperty('poz')) {
        this.poz = initObj.poz
      }
      else {
        this.poz = 0.0;
      }
    }
  }

  static serialize(obj, buffer, bufferOffset) {
    // Serializes a message object of type FetchRequest
    // Serialize message field [gpx]
    bufferOffset = _serializer.float64(obj.gpx, buffer, bufferOffset);
    // Serialize message field [gpy]
    bufferOffset = _serializer.float64(obj.gpy, buffer, bufferOffset);
    // Serialize message field [gpz]
    bufferOffset = _serializer.float64(obj.gpz, buffer, bufferOffset);
    // Serialize message field [goz]
    bufferOffset = _serializer.float64(obj.goz, buffer, bufferOffset);
    // Serialize message field [ppx]
    bufferOffset = _serializer.float64(obj.ppx, buffer, bufferOffset);
    // Serialize message field [ppy]
    bufferOffset = _serializer.float64(obj.ppy, buffer, bufferOffset);
    // Serialize message field [ppz]
    bufferOffset = _serializer.float64(obj.ppz, buffer, bufferOffset);
    // Serialize message field [poz]
    bufferOffset = _serializer.float64(obj.poz, buffer, bufferOffset);
    return bufferOffset;
  }

  static deserialize(buffer, bufferOffset=[0]) {
    //deserializes a message object of type FetchRequest
    let len;
    let data = new FetchRequest(null);
    // Deserialize message field [gpx]
    data.gpx = _deserializer.float64(buffer, bufferOffset);
    // Deserialize message field [gpy]
    data.gpy = _deserializer.float64(buffer, bufferOffset);
    // Deserialize message field [gpz]
    data.gpz = _deserializer.float64(buffer, bufferOffset);
    // Deserialize message field [goz]
    data.goz = _deserializer.float64(buffer, bufferOffset);
    // Deserialize message field [ppx]
    data.ppx = _deserializer.float64(buffer, bufferOffset);
    // Deserialize message field [ppy]
    data.ppy = _deserializer.float64(buffer, bufferOffset);
    // Deserialize message field [ppz]
    data.ppz = _deserializer.float64(buffer, bufferOffset);
    // Deserialize message field [poz]
    data.poz = _deserializer.float64(buffer, bufferOffset);
    return data;
  }

  static getMessageSize(object) {
    return 64;
  }

  static datatype() {
    // Returns string type for a service object
    return 'fetch_server/FetchRequest';
  }

  static md5sum() {
    //Returns md5sum for a message object
    return 'a4e572a55a03d78b6a81f4cfe0a115e3';
  }

  static messageDefinition() {
    // Returns full string definition for message
    return `
    float64 gpx
    float64 gpy
    float64 gpz
    float64 goz
    float64 ppx
    float64 ppy
    float64 ppz
    float64 poz
    
    `;
  }

  static Resolve(msg) {
    // deep-construct a valid message object instance of whatever was passed in
    if (typeof msg !== 'object' || msg === null) {
      msg = {};
    }
    const resolved = new FetchRequest(null);
    if (msg.gpx !== undefined) {
      resolved.gpx = msg.gpx;
    }
    else {
      resolved.gpx = 0.0
    }

    if (msg.gpy !== undefined) {
      resolved.gpy = msg.gpy;
    }
    else {
      resolved.gpy = 0.0
    }

    if (msg.gpz !== undefined) {
      resolved.gpz = msg.gpz;
    }
    else {
      resolved.gpz = 0.0
    }

    if (msg.goz !== undefined) {
      resolved.goz = msg.goz;
    }
    else {
      resolved.goz = 0.0
    }

    if (msg.ppx !== undefined) {
      resolved.ppx = msg.ppx;
    }
    else {
      resolved.ppx = 0.0
    }

    if (msg.ppy !== undefined) {
      resolved.ppy = msg.ppy;
    }
    else {
      resolved.ppy = 0.0
    }

    if (msg.ppz !== undefined) {
      resolved.ppz = msg.ppz;
    }
    else {
      resolved.ppz = 0.0
    }

    if (msg.poz !== undefined) {
      resolved.poz = msg.poz;
    }
    else {
      resolved.poz = 0.0
    }

    return resolved;
    }
};

class FetchResponse {
  constructor(initObj={}) {
    if (initObj === null) {
      // initObj === null is a special case for deserialization where we don't initialize fields
      this.success = null;
      this.message = null;
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
    }
  }

  static serialize(obj, buffer, bufferOffset) {
    // Serializes a message object of type FetchResponse
    // Serialize message field [success]
    bufferOffset = _serializer.bool(obj.success, buffer, bufferOffset);
    // Serialize message field [message]
    bufferOffset = _serializer.string(obj.message, buffer, bufferOffset);
    return bufferOffset;
  }

  static deserialize(buffer, bufferOffset=[0]) {
    //deserializes a message object of type FetchResponse
    let len;
    let data = new FetchResponse(null);
    // Deserialize message field [success]
    data.success = _deserializer.bool(buffer, bufferOffset);
    // Deserialize message field [message]
    data.message = _deserializer.string(buffer, bufferOffset);
    return data;
  }

  static getMessageSize(object) {
    let length = 0;
    length += _getByteLength(object.message);
    return length + 5;
  }

  static datatype() {
    // Returns string type for a service object
    return 'fetch_server/FetchResponse';
  }

  static md5sum() {
    //Returns md5sum for a message object
    return '937c9679a518e3a18d831e57125ea522';
  }

  static messageDefinition() {
    // Returns full string definition for message
    return `
    bool success
    string message
    
    `;
  }

  static Resolve(msg) {
    // deep-construct a valid message object instance of whatever was passed in
    if (typeof msg !== 'object' || msg === null) {
      msg = {};
    }
    const resolved = new FetchResponse(null);
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

    return resolved;
    }
};

module.exports = {
  Request: FetchRequest,
  Response: FetchResponse,
  md5sum() { return '88a1ffde7893c12d1c785f9936a31695'; },
  datatype() { return 'fetch_server/Fetch'; }
};
