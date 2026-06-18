import ROSLIB from 'roslib'
import type { ServiceResult } from './types'

export interface StartMappingRequest {
  sim: boolean
  width: number
  height: number
}

export interface MapFileRequest {
  directory: string
  name: string
  sim: boolean
}

export interface CalibrationRequest {
  zone_name: 'source' | 'dest'
  length: number
  width: number
  height: number
  distance: number
}

export function startMapping(ros: ROSLIB.Ros, request: StartMappingRequest): Promise<ServiceResult> {
  return callService(ros, '/frontend/start_mapping', 'mapping/Start', request)
}

export function saveMap(ros: ROSLIB.Ros, request: MapFileRequest): Promise<ServiceResult> {
  return callService(ros, '/frontend/save_map', 'mapping/MapFile', request)
}

export function importMap(ros: ROSLIB.Ros, request: MapFileRequest): Promise<ServiceResult> {
  return callService(ros, '/frontend/import_map', 'mapping/MapFile', request)
}

export function queryFrontendStatus(ros: ROSLIB.Ros): Promise<ServiceResult> {
  return callService(ros, '/frontend/status', 'std_srvs/Trigger', {})
}

export function calibrateZone(ros: ROSLIB.Ros, request: CalibrationRequest): Promise<ServiceResult> {
  return callService(ros, '/frontend/calibrate_table', 'mapping/CalibrateTable', request)
}

export function startPalletizing(ros: ROSLIB.Ros): Promise<ServiceResult> {
  return callService(ros, '/frontend/start_palletizing', 'std_srvs/Trigger', {})
}

function callService(
  ros: ROSLIB.Ros,
  name: string,
  serviceType: string,
  request: object,
): Promise<ServiceResult> {
  return new Promise((resolve, reject) => {
    const service = new ROSLIB.Service({ ros, name, serviceType })
    service.callService(
      new ROSLIB.ServiceRequest(request),
      (response) => resolve(response as ServiceResult),
      (error) => reject(error),
    )
  })
}
