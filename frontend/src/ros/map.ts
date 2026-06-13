import ROSLIB from 'roslib'
import { makePose, quaternionToYaw, yawToQuaternion } from './types'
import type { LaserScan, OccupancyGrid, PathMessage, Pose, PoseWithCovarianceStamped, ServiceResult, TFMessage, TransformStamped } from './types'

export function subscribeMap(
  ros: ROSLIB.Ros,
  callback: (map: OccupancyGrid) => void,
): ROSLIB.Topic {
  const topic = new ROSLIB.Topic({
    ros,
    name: '/map',
    messageType: 'nav_msgs/OccupancyGrid',
    throttle_rate: 1000,
    compression: 'cbor',
    queue_length: 1,
  })
  topic.subscribe((message) => callback(message as OccupancyGrid))
  return topic
}

export function subscribeGlobalPath(
  ros: ROSLIB.Ros,
  callback: (path: PathMessage) => void,
): ROSLIB.Topic {
  const topic = new ROSLIB.Topic({
    ros,
    name: '/move_base/GlobalPlanner/plan',
    messageType: 'nav_msgs/Path',
    throttle_rate: 1000,
  })
  topic.subscribe((message) => callback(message as PathMessage))
  return topic
}

export function subscribeTfRobotPose(
  ros: ROSLIB.Ros,
  callback: (pose: Pose) => void,
  mapFrame = 'map',
  baseFrame = 'base_footprint',
): ROSLIB.Topic {
  const transforms = new Map<string, TransformStamped>()
  const topic = new ROSLIB.Topic({
    ros,
    name: '/tf',
    messageType: 'tf2_msgs/TFMessage',
    throttle_rate: 250,
    queue_length: 1,
  })
  topic.subscribe((message) => {
    const tfMessage = message as TFMessage
    for (const transform of tfMessage.transforms) {
      transforms.set(transformKey(transform.header.frame_id, transform.child_frame_id), transform)
    }
    const pose = computeRobotPose(transforms, mapFrame, baseFrame)
    if (pose) {
      callback(pose)
    }
  })
  return topic
}

export function subscribeAmclPose(
  ros: ROSLIB.Ros,
  callback: (pose: PoseWithCovarianceStamped) => void,
): ROSLIB.Topic {
  const topic = new ROSLIB.Topic({
    ros,
    name: '/amcl_pose',
    messageType: 'geometry_msgs/PoseWithCovarianceStamped',
    throttle_rate: 500,
  })
  topic.subscribe((message) => callback(message as PoseWithCovarianceStamped))
  return topic
}

export function subscribeLaserScan(
  ros: ROSLIB.Ros,
  callback: (scan: LaserScan) => void,
): ROSLIB.Topic {
  const topic = new ROSLIB.Topic({
    ros,
    name: '/scan',
    messageType: 'sensor_msgs/LaserScan',
    throttle_rate: 500,
    compression: 'cbor',
    queue_length: 1,
  })
  topic.subscribe((message) => callback(message as LaserScan))
  return topic
}

function computeRobotPose(
  transforms: Map<string, TransformStamped>,
  mapFrame: string,
  baseFrame: string,
): Pose | null {
  const normalizedMap = normalizeFrame(mapFrame)
  const normalizedBase = normalizeFrame(baseFrame)
  const direct = getTransform(transforms, normalizedMap, normalizedBase)
  if (direct) {
    return transformToPose(direct)
  }

  const baseFallbacks = [normalizedBase, 'base_footprint', 'base_link']
  for (const candidate of baseFallbacks) {
    const candidateDirect = getTransform(transforms, normalizedMap, candidate)
    if (candidateDirect) {
      return transformToPose(candidateDirect)
    }
  }

  const mapToOdom = getTransform(transforms, normalizedMap, 'odom')
  if (!mapToOdom) {
    return null
  }
  for (const candidate of baseFallbacks) {
    const odomToBase = getTransform(transforms, 'odom', candidate)
    if (odomToBase) {
      return compose2d(mapToOdom, odomToBase)
    }
  }
  return null
}

function getTransform(
  transforms: Map<string, TransformStamped>,
  parent: string,
  child: string,
): TransformStamped | undefined {
  return transforms.get(transformKey(parent, child))
}

function transformKey(parent: string, child: string): string {
  return `${normalizeFrame(parent)}->${normalizeFrame(child)}`
}

function normalizeFrame(frame: string): string {
  return frame.replace(/^\//, '')
}

function transformToPose(transform: TransformStamped): Pose {
  return {
    position: {
      x: transform.transform.translation.x,
      y: transform.transform.translation.y,
      z: transform.transform.translation.z,
    },
    orientation: transform.transform.rotation,
  }
}

function compose2d(parent: TransformStamped, child: TransformStamped): Pose {
  const parentYaw = quaternionToYaw(parent.transform.rotation)
  const childYaw = quaternionToYaw(child.transform.rotation)
  const cos = Math.cos(parentYaw)
  const sin = Math.sin(parentYaw)
  const childX = child.transform.translation.x
  const childY = child.transform.translation.y
  const x = parent.transform.translation.x + cos * childX - sin * childY
  const y = parent.transform.translation.y + sin * childX + cos * childY
  const pose = makePose(x, y, parentYaw + childYaw)
  pose.orientation = yawToQuaternion(parentYaw + childYaw)
  return pose
}

export function saveMap(ros: ROSLIB.Ros, name: string): Promise<ServiceResult> {
  return callService(ros, '/se_map/save_map', 'se_map/SaveMap', { name })
}

export function clearMap(ros: ROSLIB.Ros): Promise<ServiceResult> {
  return callService(ros, '/se_map/clear_map', 'se_map/ClearMap', { confirm: true })
}

export function setInitialPose(ros: ROSLIB.Ros, pose: Pose): Promise<ServiceResult> {
  return callService(ros, '/se_map/set_initial_pose', 'se_map/SetInitialPose', { pose })
}

function callService(
  ros: ROSLIB.Ros,
  name: string,
  serviceType: string,
  request: Record<string, unknown>,
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
