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

class ListPackagesRequest {
  constructor(initObj={}) {
    if (initObj === null) {
      // initObj === null is a special case for deserialization where we don't initialize fields
    }
    else {
    }
  }

  static serialize(obj, buffer, bufferOffset) {
    // Serializes a message object of type ListPackagesRequest
    return bufferOffset;
  }

  static deserialize(buffer, bufferOffset=[0]) {
    //deserializes a message object of type ListPackagesRequest
    let len;
    let data = new ListPackagesRequest(null);
    return data;
  }

  static getMessageSize(object) {
    return 0;
  }

  static datatype() {
    // Returns string type for a service object
    return 'vizanti/ListPackagesRequest';
  }

  static md5sum() {
    //Returns md5sum for a message object
    return 'd41d8cd98f00b204e9800998ecf8427e';
  }

  static messageDefinition() {
    // Returns full string definition for message
    return `
    
    `;
  }

  static Resolve(msg) {
    // deep-construct a valid message object instance of whatever was passed in
    if (typeof msg !== 'object' || msg === null) {
      msg = {};
    }
    const resolved = new ListPackagesRequest(null);
    return resolved;
    }
};

class ListPackagesResponse {
  constructor(initObj={}) {
    if (initObj === null) {
      // initObj === null is a special case for deserialization where we don't initialize fields
      this.packages = null;
    }
    else {
      if (initObj.hasOwnProperty('packages')) {
        this.packages = initObj.packages
      }
      else {
        this.packages = [];
      }
    }
  }

  static serialize(obj, buffer, bufferOffset) {
    // Serializes a message object of type ListPackagesResponse
    // Serialize message field [packages]
    bufferOffset = _arraySerializer.string(obj.packages, buffer, bufferOffset, null);
    return bufferOffset;
  }

  static deserialize(buffer, bufferOffset=[0]) {
    //deserializes a message object of type ListPackagesResponse
    let len;
    let data = new ListPackagesResponse(null);
    // Deserialize message field [packages]
    data.packages = _arrayDeserializer.string(buffer, bufferOffset, null)
    return data;
  }

  static getMessageSize(object) {
    let length = 0;
    object.packages.forEach((val) => {
      length += 4 + _getByteLength(val);
    });
    return length + 4;
  }

  static datatype() {
    // Returns string type for a service object
    return 'vizanti/ListPackagesResponse';
  }

  static md5sum() {
    //Returns md5sum for a message object
    return '16e658dd9a0c0812bd000a8e17c5f7b4';
  }

  static messageDefinition() {
    // Returns full string definition for message
    return `
    string[] packages 
    
    
    `;
  }

  static Resolve(msg) {
    // deep-construct a valid message object instance of whatever was passed in
    if (typeof msg !== 'object' || msg === null) {
      msg = {};
    }
    const resolved = new ListPackagesResponse(null);
    if (msg.packages !== undefined) {
      resolved.packages = msg.packages;
    }
    else {
      resolved.packages = []
    }

    return resolved;
    }
};

module.exports = {
  Request: ListPackagesRequest,
  Response: ListPackagesResponse,
  md5sum() { return '16e658dd9a0c0812bd000a8e17c5f7b4'; },
  datatype() { return 'vizanti/ListPackages'; }
};
