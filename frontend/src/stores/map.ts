import type ROSLIB from 'roslib'
import { defineStore } from 'pinia'
import { clearMap, saveMap, subscribeAmclPose, subscribeGlobalPath, subscribeLaserScan, subscribeMap, subscribeTfRobotPose } from '../ros/map'
import { makePose } from '../ros/types'
import type { LaserScan, OccupancyGrid, PathMessage, Pose, ToolMode } from '../ros/types'

interface MapState {
  grid: OccupancyGrid | null
  path: PathMessage | null
  scan: LaserScan | null
  mapTopic: ROSLIB.Topic | null
  pathTopic: ROSLIB.Topic | null
  amclTopic: ROSLIB.Topic | null
  tfTopic: ROSLIB.Topic | null
  scanTopic: ROSLIB.Topic | null
  lastMapAt: number | null
  lastRobotAt: number | null
  lastScanAt: number | null
  selectedTool: ToolMode
  robotPose: Pose | null
  goalPose: Pose | null
  goalYawDeg: number
  saveName: string
  busy: boolean
  message: string
  error: string
}

export const useMapStore = defineStore('map', {
  state: (): MapState => ({
    grid: null,
    path: null,
    scan: null,
    mapTopic: null,
    pathTopic: null,
    amclTopic: null,
    tfTopic: null,
    scanTopic: null,
    lastMapAt: null,
    lastRobotAt: null,
    lastScanAt: null,
    selectedTool: 'inspect',
    robotPose: null,
    goalPose: null,
    goalYawDeg: 0,
    saveName: 'saved_map',
    busy: false,
    message: '',
    error: '',
  }),
  getters: {
    mapSummary: (state) => {
      if (!state.grid) {
        return '未收到地图'
      }
      return `${state.grid.info.width} x ${state.grid.info.height}, ${state.grid.info.resolution.toFixed(3)} m/cell`
    },
    pathCount: (state) => state.path?.poses.length ?? 0,
  },
  actions: {
    attach(ros: ROSLIB.Ros, mapFrame = 'map', baseFrame = 'base_footprint') {
      this.detach()
      this.mapTopic = subscribeMap(ros, (grid) => {
        this.grid = grid
        this.lastMapAt = Date.now()
      })
      this.pathTopic = subscribeGlobalPath(ros, (path) => {
        this.path = path
      })
      this.amclTopic = subscribeAmclPose(ros, (message) => {
        this.robotPose = message.pose.pose
        this.lastRobotAt = Date.now()
      })
      this.tfTopic = subscribeTfRobotPose(ros, (pose) => {
        this.robotPose = pose
        this.lastRobotAt = Date.now()
      }, mapFrame, baseFrame)
      this.scanTopic = subscribeLaserScan(ros, (scan) => {
        this.scan = scan
        this.lastScanAt = Date.now()
      })
    },
    detach() {
      this.mapTopic?.unsubscribe()
      this.pathTopic?.unsubscribe()
      this.amclTopic?.unsubscribe()
      this.tfTopic?.unsubscribe()
      this.scanTopic?.unsubscribe()
      this.mapTopic = null
      this.pathTopic = null
      this.amclTopic = null
      this.tfTopic = null
      this.scanTopic = null
    },
    setPointFromMap(x: number, y: number) {
      if (this.selectedTool === 'goal') {
        this.goalPose = makePose(x, y, degToRad(this.goalYawDeg))
      }
    },
    setGoalFromMap(x: number, y: number, yaw: number) {
      this.goalPose = makePose(x, y, yaw)
      this.goalYawDeg = radToDeg(yaw)
    },
    updateGoalYaw(degrees: number) {
      this.goalYawDeg = degrees
      if (this.goalPose) {
        this.goalPose = makePose(this.goalPose.position.x, this.goalPose.position.y, degToRad(degrees))
      }
    },
    async saveCurrentMap(ros: ROSLIB.Ros) {
      this.busy = true
      this.error = ''
      try {
        const result = await saveMap(ros, this.saveName)
        this.message = result.success ? `地图已保存: ${result.path || this.saveName}` : result.message
        if (!result.success) {
          this.error = result.message
        }
      } catch (error) {
        this.error = String(error)
      } finally {
        this.busy = false
      }
    },
    async clearCurrentMap(ros: ROSLIB.Ros) {
      this.busy = true
      this.error = ''
      try {
        const result = await clearMap(ros)
        this.message = result.message
        if (!result.success) {
          this.error = result.message
        }
      } catch (error) {
        this.error = String(error)
      } finally {
        this.busy = false
      }
    },
  },
})

function degToRad(degrees: number): number {
  return degrees * Math.PI / 180
}

function radToDeg(radians: number): number {
  return radians * 180 / Math.PI
}
