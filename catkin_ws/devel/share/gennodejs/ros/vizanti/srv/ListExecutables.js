// Auto-generated. Do not edit!

// (in-package vizanti.srv)


"use strict";

const _serializer = _ros_msg_utils.Serialize;
const _arraySerializer = _serializer.Array;
const _deserializer = _ros_msg_utils.Deserialize;
const _arrayDeserializer = _deserializer.Array;
const _finder = _ros_msg_utils.Find;
const _getByteLength = _ros_msg_utils.getByteLength;

//-----------------------------------------------------------


//-----------------------------------------------------------

class ListExecutablesRequest {
  constructor(initObj={}) {
    if (initObj === null) {
      // initObj === null is a special case for deserialization where we don't initialize fields
      this.package = null;
    }
    else {
      if (initObj.hasOwnProperty('package')) {
        this.package = initObj.package
      }
      else {
        this.package = '';
      }
    }
  }

  static serialize(obj, buffer, bufferOffset) {
    // Serializes a message object of type ListExecutablesRequest
    // Serialize message field [package]
    bufferOffset = _serializer.string(obj.package, buffer, bufferOffset);
    return bufferOffset;
  }

  static deserialize(buffer, bufferOffset=[0]) {
    //deserializes a message object of type ListExecutablesRequest
    let len;
    let data = new ListExecutablesRequest(null);
    // Deserialize message field [package]
    data.package = _deserializer.string(buffer, bufferOffset);
    return data;
  }

  static getMessageSize(object) {
    let length = 0;
    length += _getByteLength(object.package);
    return length + 4;
  }

  static datatype() {
    // Returns string type for a service object
    return 'vizanti/ListExecutablesRequest';
  }

  static md5sum() {
    //Returns md5sum for a message object
    return 'e287e1a2ecf8f7296d9bca37f3d48d0c';
  }

  static messageDefinition() {
    // Returns full string definition for message
    return `
    string package
    
    `;
  }

  static Resolve(msg) {
    // deep-construct a valid message object instance of whatever was passed in
    if (typeof msg !== 'object' || msg === null) {
      msg = {};
    }
    const resolved = new ListExecutablesRequest(null);
    if (msg.package !== undefined) {
      resolved.package = msg.package;
    }
    else {
      resolved.package = ''
    }

    return resolved;
    }
};

class ListExecutablesResponse {
  constructor(initObj={}) {
    if (initObj === null) {
      // initObj === null is a special case for deserialization where we don't initialize fields
      this.executables = null;
    }
    else {
      if (initObj.hasOwnProperty('executables')) {
        this.executables = initObj.executables
      }
      else {
        this.executables = [];
      }
    }
  }

  static serialize(obj, buffer, bufferOffset) {
    // Serializes a message object of type ListExecutablesResponse
    // Serialize message field [executables]
    bufferOffset = _arraySerializer.string(obj.executables, buffer, bufferOffset, null);
    return bufferOffset;
  }

  static deserialize(buffer, bufferOffset=[0]) {
    //deserializes a message object of type ListExecutablesResponse
    let len;
    let data = new ListExecutablesResponse(null);
    // Deserialize message field [executables]
    data.executables = _arrayDeserializer.string(buffer, bufferOffset, null)
    return data;
  }

  static getMessageSize(object) {
    let length = 0;
    object.executables.forEach((val) => {
      length += 4 + _getByteLength(val);
    });
    return length + 4;
  }

  static datatype() {
    // Returns string type for a service object
    return 'vizanti/ListExecutablesResponse';
  }

  static md5sum() {
    //Returns md5sum for a message object
    return 'ab0610255ac01d1e2184dfc9f7f7ed73';
  }

  static messageDefinition() {
    // Returns full string definition for message
    return `
    string[] executables 
    
    
    `;
  }

  static Resolve(msg) {
    // deep-construct a valid message object instance of whatever was passed in
    if (typeof msg !== 'object' || msg === null) {
      msg = {};
    }
    const resolved = new ListExecutablesResponse(null);
    if (msg.executables !== undefined) {
      resolved.executables = msg.executables;
    }
    else {
      resolved.executables = []
    }

    return resolved;
    }
};

module.exports = {
  Request: ListExecutablesRequest,
  Response: ListExecutablesResponse,
  md5sum() { return '0d9dadc8a6139fd3d3c4c0b768c8f47c'; },
  datatype() { return 'vizanti/ListExecutables'; }
};
