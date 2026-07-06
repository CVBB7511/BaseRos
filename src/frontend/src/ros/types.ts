export interface RosHeader {
  seq?: number
  stamp?: {
    secs: number
    nsecs: number
  }
  frame_id: string
}

export interface Point3 {
  x: number
  y: number
  z: number
}

export interface Quaternion {
  x: number
  y: number
  z: number
  w: number
}

export interface Pose {
  position: Point3
  orientation: Quaternion
}

export interface PoseStamped {
  header: RosHeader
  pose: Pose
}

export interface PoseWithCovarianceStamped {
  header: RosHeader
  pose: {
    pose: Pose
    covariance: number[]
  }
}

export interface Odometry {
  header: RosHeader
  child_frame_id: string
  pose: {
    pose: Pose
    covariance: number[]
  }
}

export interface Transform {
  translation: Point3
  rotation: Quaternion
}

export interface TransformStamped {
  header: RosHeader
  child_frame_id: string
  transform: Transform
}

export interface TFMessage {
  transforms: TransformStamped[]
}

export interface OccupancyGrid {
  header: RosHeader
  info: {
    map_load_time?: {
      secs: number
      nsecs: number
    }
    resolution: number
    width: number
    height: number
    origin: Pose
  }
  data: number[]
}

export interface PathMessage {
  header: RosHeader
  poses: PoseStamped[]
}

export interface LaserScan {
  header: RosHeader
  angle_min: number
  angle_max: number
  angle_increment: number
  time_increment: number
  scan_time: number
  range_min: number
  range_max: number
  ranges: number[]
  intensities?: number[]
}

export interface NavigateFeedback {
  percentage: number
  state: string
}

export interface NavigateResult {
  success: boolean
  result: string
  message: string
}

export interface ServiceResult {
  success: boolean
  message: string
  path?: string
}

export interface PalletizingStats {
  total_objects: number
  success_count: number
  fail_count: number
  current_layer: number
  hard_zone_layers: number
  soft_zone_layers: number
  success_rate: number
  avg_cycle_time: number
  elapsed_time: number
  current_state: string
}

export type ToolMode = 'inspect' | 'goal'
export type AppMode = 'mapping' | 'navigation'

export function yawToQuaternion(yaw: number): Quaternion {
  return {
    x: 0,
    y: 0,
    z: Math.sin(yaw / 2),
    w: Math.cos(yaw / 2),
  }
}

export function quaternionToYaw(q: Quaternion): number {
  return Math.atan2(2 * (q.w * q.z + q.x * q.y), 1 - 2 * (q.y * q.y + q.z * q.z))
}

export function makePose(x: number, y: number, yaw = 0): Pose {
  return {
    position: { x, y, z: 0 },
    orientation: yawToQuaternion(yaw),
  }
}
