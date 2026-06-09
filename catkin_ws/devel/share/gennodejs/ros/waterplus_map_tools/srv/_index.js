
"use strict";

let GetNumOfWaypoints = require('./GetNumOfWaypoints.js')
let SaveWaypoints = require('./SaveWaypoints.js')
let GetWaypointByIndex = require('./GetWaypointByIndex.js')
let GetWaypointByName = require('./GetWaypointByName.js')
let GetChargerByName = require('./GetChargerByName.js')
let AddNewWaypoint = require('./AddNewWaypoint.js')

module.exports = {
  GetNumOfWaypoints: GetNumOfWaypoints,
  SaveWaypoints: SaveWaypoints,
  GetWaypointByIndex: GetWaypointByIndex,
  GetWaypointByName: GetWaypointByName,
  GetChargerByName: GetChargerByName,
  AddNewWaypoint: AddNewWaypoint,
};
