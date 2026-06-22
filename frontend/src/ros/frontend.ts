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

export interface OperationLogRequest {
  action: 'append' | 'list' | 'import' | 'clear'
  id?: string
  timestamp?: string
  level?: 'success' | 'error'
  text?: string
}

export interface EnvironmentResult extends ServiceResult {
  mode: '' | 'sim' | 'real'
  state: 'stopped' | 'running' | 'error'
}

export interface RobotParameters {
  kinect_height: number
  kinect_pitch: number
  camera_x: number
  camera_y: number
  camera_z: number
  grab_y_offset: number
  grab_lift_offset: number
  grab_forward_offset: number
  grab_gripper_value: number
  grab_hand_up_wait: number
}

export interface RobotParametersResult extends ServiceResult, RobotParameters {}

const emptyRobotParameters: RobotParameters = {
  kinect_height: 0,
  kinect_pitch: 0,
  camera_x: 0,
  camera_y: 0,
  camera_z: 0,
  grab_y_offset: 0,
  grab_lift_offset: 0,
  grab_forward_offset: 0,
  grab_gripper_value: 0,
  grab_hand_up_wait: 0,
}

export function manageRobotParameters(
  ros: ROSLIB.Ros,
  action: 'get' | 'save' | 'restore',
  parameters: RobotParameters = emptyRobotParameters,
): Promise<RobotParametersResult> {
  return callService(ros, '/frontend/robot_parameters', 'mapping/RobotParameters', {
    action,
    ...parameters,
  }) as Promise<RobotParametersResult>
}

export function manageEnvironment(
  ros: ROSLIB.Ros,
  action: 'start' | 'stop' | 'status',
  mode: '' | 'sim' | 'real',
): Promise<EnvironmentResult> {
  return callService(ros, '/frontend/environment', 'mapping/Environment', { action, mode }) as Promise<EnvironmentResult>
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

export function stopPalletizing(ros: ROSLIB.Ros): Promise<ServiceResult> {
  return callService(ros, '/frontend/stop_palletizing', 'std_srvs/Trigger', {})
}

export function manageOperationLogs(ros: ROSLIB.Ros, request: OperationLogRequest): Promise<ServiceResult> {
  return callService(ros, '/frontend/operation_logs', 'mapping/OperationLog', {
    action: request.action,
    id: request.id || '',
    timestamp: request.timestamp || '',
    level: request.level || '',
    text: request.text || '',
  })
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
