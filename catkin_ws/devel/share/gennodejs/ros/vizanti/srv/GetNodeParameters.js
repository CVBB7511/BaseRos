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

class GetNodeParametersRequest {
  constructor(initObj={}) {
    if (initObj === null) {
      // initObj === null is a special case for deserialization where we don't initialize fields
      this.node = null;
    }
    else {
      if (initObj.hasOwnProperty('node')) {
        this.node = initObj.node
      }
      else {
        this.node = '';
      }
    }
  }

  static serialize(obj, buffer, bufferOffset) {
    // Serializes a message object of type GetNodeParametersRequest
    // Serialize message field [node]
    bufferOffset = _serializer.string(obj.node, buffer, bufferOffset);
    return bufferOffset;
  }

  static deserialize(buffer, bufferOffset=[0]) {
    //deserializes a message object of type GetNodeParametersRequest
    let len;
    let data = new GetNodeParametersRequest(null);
    // Deserialize message field [node]
    data.node = _deserializer.string(buffer, bufferOffset);
    return data;
  }

  static getMessageSize(object) {
    let length = 0;
    length += _getByteLength(object.node);
    return length + 4;
  }

  static datatype() {
    // Returns string type for a service object
    return 'vizanti/GetNodeParametersRequest';
  }

  static md5sum() {
    //Returns md5sum for a message object
    return 'a94c40e70a4b82863e6e52ec16732447';
  }

  static messageDefinition() {
    // Returns full string definition for message
    return `
    string node
    
    `;
  }

  static Resolve(msg) {
    // deep-construct a valid message object instance of whatever was passed in
    if (typeof msg !== 'object' || msg === null) {
      msg = {};
    }
    const resolved = new GetNodeParametersRequest(null);
    if (msg.node !== undefined) {
      resolved.node = msg.node;
    }
    else {
      resolved.node = ''
    }

    return resolved;
    }
};

class GetNodeParametersResponse {
  constructor(initObj={}) {
    if (initObj === null) {
      // initObj === null is a special case for deserialization where we don't initialize fields
      this.parameters = null;
    }
    else {
      if (initObj.hasOwnProperty('parameters')) {
        this.parameters = initObj.parameters
      }
      else {
        this.parameters = '';
      }
    }
  }

  static serialize(obj, buffer, bufferOffset) {
    // Serializes a message object of type GetNodeParametersResponse
    // Serialize message field [parameters]
    bufferOffset = _serializer.string(obj.parameters, buffer, bufferOffset);
    return bufferOffset;
  }

  static deserialize(buffer, bufferOffset=[0]) {
    //deserializes a message object of type GetNodeParametersResponse
    let len;
    let data = new GetNodeParametersResponse(null);
    // Deserialize message field [parameters]
    data.parameters = _deserializer.string(buffer, bufferOffset);
    return data;
  }

  static getMessageSize(object) {
    let length = 0;
    length += _getByteLength(object.parameters);
    return length + 4;
  }

  static datatype() {
    // Returns string type for a service object
    return 'vizanti/GetNodeParametersResponse';
  }

  static md5sum() {
    //Returns md5sum for a message object
    return 'b96cd7929ab82d8413ba620379c440ce';
  }

  static messageDefinition() {
    // Returns full string definition for message
    return `
    string parameters
    
    `;
  }

  static Resolve(msg) {
    // deep-construct a valid message object instance of whatever was passed in
    if (typeof msg !== 'object' || msg === null) {
      msg = {};
    }
    const resolved = new GetNodeParametersResponse(null);
    if (msg.parameters !== undefined) {
      resolved.parameters = msg.parameters;
    }
    else {
      resolved.parameters = ''
    }

    return resolved;
    }
};

module.exports = {
  Request: GetNodeParametersRequest,
  Response: GetNodeParametersResponse,
  md5sum() { return '92c3b11f6b804819c754cc42d5293a0b'; },
  datatype() { return 'vizanti/GetNodeParameters'; }
};
