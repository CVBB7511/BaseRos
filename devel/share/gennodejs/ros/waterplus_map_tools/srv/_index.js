
"use strict";

let GetChargerByName = require('./GetChargerByName.js')
let AddNewWaypoint = require('./AddNewWaypoint.js')
let GetWaypointByName = require('./GetWaypointByName.js')
let SaveWaypoints = require('./SaveWaypoints.js')
let GetNumOfWaypoints = require('./GetNumOfWaypoints.js')
let GetWaypointByIndex = require('./GetWaypointByIndex.js')

module.exports = {
  GetChargerByName: GetChargerByName,
  AddNewWaypoint: AddNewWaypoint,
  GetWaypointByName: GetWaypointByName,
  SaveWaypoints: SaveWaypoints,
  GetNumOfWaypoints: GetNumOfWaypoints,
  GetWaypointByIndex: GetWaypointByIndex,
};
