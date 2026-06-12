
"use strict";

let SaveWaypoints = require('./SaveWaypoints.js')
let GetChargerByName = require('./GetChargerByName.js')
let GetNumOfWaypoints = require('./GetNumOfWaypoints.js')
let AddNewWaypoint = require('./AddNewWaypoint.js')
let GetWaypointByName = require('./GetWaypointByName.js')
let GetWaypointByIndex = require('./GetWaypointByIndex.js')

module.exports = {
  SaveWaypoints: SaveWaypoints,
  GetChargerByName: GetChargerByName,
  GetNumOfWaypoints: GetNumOfWaypoints,
  AddNewWaypoint: AddNewWaypoint,
  GetWaypointByName: GetWaypointByName,
  GetWaypointByIndex: GetWaypointByIndex,
};
