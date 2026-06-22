import ROSLIB from 'roslib'
import { defineStore } from 'pinia'
import { calibrateZone, importMap, manageOperationLogs, queryFrontendStatus, saveMap, startMapping, startPalletizing, stopPalletizing } from '../ros/frontend'
import type { PalletizingStats } from '../ros/types'

type ZoneName = 'source' | 'dest'
type OperationLogLevel = 'success' | 'error'

interface OperationLogEntry {
  id: string
  timestamp: string
  level: OperationLogLevel
  message: string
}

const OPERATION_LOG_KEY = 'frontend_operation_logs'
const MAX_OPERATION_LOGS = 100
let operationLogRos: ROSLIB.Ros | null = null

function parseOperationLogs(raw: string): OperationLogEntry[] {
  try {
    const parsed = JSON.parse(raw || '[]')
    if (!Array.isArray(parsed)) return []
    return parsed.filter((entry): entry is OperationLogEntry => (
      typeof entry?.id === 'string' &&
      typeof entry?.timestamp === 'string' &&
      (entry?.level === 'success' || entry?.level === 'error') &&
      typeof entry?.message === 'string'
    )).slice(-MAX_OPERATION_LOGS)
  } catch {
    return []
  }
}

function loadOperationLogs(): OperationLogEntry[] {
  return parseOperationLogs(localStorage.getItem(OPERATION_LOG_KEY) || '[]')
}

interface FrontendState {
  mode: 'sim' | 'real'
  saveDirectory: string
  importDirectory: string
  mapName: string
  busy: boolean
  mappingRunning: boolean
  executeRunning: boolean
  calibrationZone: ZoneName
  calibrationLength: number
  calibrationWidth: number
  calibrationHeight: number
  calibrationDistance: number
  lastPath: string
  message: string
  error: string
  palletizingStats: PalletizingStats | null
  palletizingTopic: ROSLIB.Topic | null
  palletizingActive: boolean
  palletizingState: string
  operationLogs: OperationLogEntry[]
}

export const useFrontendStore = defineStore('frontend', {
  state: (): FrontendState => ({
    mode: (localStorage.getItem('frontend_mode') as 'sim' | 'real') || 'real',
    saveDirectory: localStorage.getItem('save_directory') || '/home/yubowen/BaseRos/real_maps',
    importDirectory: localStorage.getItem('import_directory') || '/home/yubowen/BaseRos/real_maps',
    mapName: localStorage.getItem('map_name') || 'real_map',
    busy: false,
    mappingRunning: false,
    executeRunning: false,
    calibrationZone: (localStorage.getItem('calibration_zone') as ZoneName) || 'source',
    calibrationLength: Number(localStorage.getItem('calibration_length') || '1.2'),
    calibrationWidth: Number(localStorage.getItem('calibration_width') || '0.5'),
    calibrationHeight: Number(localStorage.getItem('calibration_height') || '0.765'),
    calibrationDistance: Number(localStorage.getItem('calibration_distance') || '0.95'),
    lastPath: '',
    message: '',
    error: '',
    palletizingStats: null,
    palletizingTopic: null,
    palletizingActive: false,
    palletizingState: 'IDLE',
    operationLogs: loadOperationLogs(),
  }),
  getters: {
    modeLabel: (state) => state.mode === 'sim' ? '仿真' : '真机',
    operationLogsNewest: (state) => [...state.operationLogs].reverse(),
    palletizingStateLabel: (state) => {
      const value = state.palletizingState
      const labels: Record<string, string> = {
        IDLE: '空闲',
        STARTING: '启动中',
        NAVIGATING: '导航中',
        DETECTING: '检测物体',
        GRABBING: '抓取中',
        PLACING: '放置中',
        ABORTING: '正在终止',
        ABORTED: '人为终止',
        DONE: '已完成',
      }
      return labels[value] || value
    },
  },
  actions: {
    async attachOperationLogs(ros: ROSLIB.Ros) {
      operationLogRos = ros
      const localEntries = [...this.operationLogs]
      try {
        const result = await manageOperationLogs(ros, { action: 'list' })
        if (!result.success) return
        const projectEntries = parseOperationLogs(result.message)
        if (projectEntries.length > 0) {
          this.operationLogs = projectEntries.slice(-MAX_OPERATION_LOGS)
          localStorage.setItem(OPERATION_LOG_KEY, JSON.stringify(this.operationLogs))
        } else if (localEntries.length > 0) {
          await manageOperationLogs(ros, {
            action: 'import',
            text: JSON.stringify(localEntries),
          })
        }
      } catch {
        // Keep the local copy available while the project log service is offline.
      }
    },
    detachOperationLogs() {
      operationLogRos = null
    },
    persist() {
      localStorage.setItem('frontend_mode', this.mode)
      localStorage.setItem('save_directory', this.saveDirectory)
      localStorage.setItem('import_directory', this.importDirectory)
      localStorage.setItem('map_name', this.mapName)
      localStorage.setItem('calibration_zone', this.calibrationZone)
      localStorage.setItem('calibration_length', String(this.calibrationLength))
      localStorage.setItem('calibration_width', String(this.calibrationWidth))
      localStorage.setItem('calibration_height', String(this.calibrationHeight))
      localStorage.setItem('calibration_distance', String(this.calibrationDistance))
    },
    async restartMapping(ros: ROSLIB.Ros) {
      await this.run(async () => {
        this.persist()
        const result = await startMapping(ros, { sim: this.mode === 'sim', width: 12, height: 12 })
        this.applyResult(result)
        this.mappingRunning = result.success
        if (result.success) {
          this.executeRunning = false
        }
      })
    },
    async save(ros: ROSLIB.Ros) {
      await this.run(async () => {
        this.persist()
        const result = await saveMap(ros, { directory: this.saveDirectory, name: this.mapName, sim: this.mode === 'sim' })
        this.applyResult(result)
        if (result.success) {
          this.mappingRunning = false
        }
      })
    },
    async importSelected(ros: ROSLIB.Ros) {
      await this.run(async () => {
        this.persist()
        const result = await importMap(ros, { directory: this.importDirectory, name: this.mapName, sim: this.mode === 'sim' })
        this.applyResult(result)
        if (result.success) {
          this.executeRunning = true
        }
      })
    },
    async calibrate(ros: ROSLIB.Ros) {
      await this.run(async () => {
        this.persist()
        const result = await calibrateZone(ros, {
          zone_name: this.calibrationZone,
          length: this.calibrationLength,
          width: this.calibrationWidth,
          height: this.calibrationHeight,
          distance: this.calibrationDistance,
        })
        this.applyResult(result)
      })
    },
    async startTask(ros: ROSLIB.Ros) {
      await this.run(async () => {
        this.subscribePalletizingStats(ros)
        const result = await startPalletizing(ros)
        this.applyResult(result)
        if (result.success) {
          this.palletizingActive = true
          this.palletizingState = 'STARTING'
        }
      })
    },
    async stopTask(ros: ROSLIB.Ros) {
      await this.run(async () => {
        const result = await stopPalletizing(ros)
        this.applyResult(result)
        if (result.success) {
          this.palletizingActive = false
          this.palletizingState = 'ABORTED'
        }
      })
    },
    subscribePalletizingStats(ros: ROSLIB.Ros) {
      if (this.palletizingTopic) {
        this.palletizingTopic.unsubscribe()
      }
      this.palletizingTopic = new ROSLIB.Topic({
        ros,
        name: '/palletizing/stats',
        messageType: 'palletizing/PalletizingStats',
        throttle_rate: 500,
      })
      this.palletizingTopic.subscribe((message) => {
        const wasActive = this.palletizingActive
        const stats = message as PalletizingStats
        this.palletizingStats = stats
        this.palletizingState = stats.current_state
        this.palletizingActive = !['IDLE', 'DONE', 'ABORTED'].includes(
          stats.current_state,
        )
        if (wasActive && stats.current_state === 'DONE') {
          const elapsedSeconds = Math.max(0, Math.round(stats.elapsed_time || 0))
          this.addLog('success', `码垛完成，耗时 ${elapsedSeconds} 秒`)
        }
      })
    },
    unsubscribePalletizingStats() {
      if (this.palletizingTopic) {
        this.palletizingTopic.unsubscribe()
        this.palletizingTopic = null
      }
      this.palletizingStats = null
      this.palletizingActive = false
      this.palletizingState = 'IDLE'
    },
    applyZoneDefaults(zone: ZoneName) {
      this.calibrationZone = zone
      this.calibrationLength = 1.2
      this.calibrationWidth = 0.5
      this.calibrationHeight = 0.765
      this.calibrationDistance = this.calibrationWidth / 2 + 0.70
      this.persist()
    },
    async refreshStatus(ros: ROSLIB.Ros) {
      await this.run(async () => {
        const result = await queryFrontendStatus(ros)
        this.applyResult(result)
        this.mappingRunning = result.message.includes('mapping: running')
        this.executeRunning = result.message.includes('execute: running')
      })
    },
    applyResult(result: { success: boolean, message: string, path?: string }) {
      this.message = result.success ? result.message : ''
      this.error = result.success ? '' : result.message
      this.lastPath = result.path || this.lastPath
      this.addLog(result.success ? 'success' : 'error', result.message)
    },
    addLog(level: OperationLogLevel, message: string) {
      const normalized = message.trim()
      if (!normalized) return
      this.operationLogs.push({
        id: `${Date.now()}-${Math.random().toString(36).slice(2, 8)}`,
        timestamp: new Date().toISOString(),
        level,
        message: normalized,
      })
      this.operationLogs = this.operationLogs.slice(-MAX_OPERATION_LOGS)
      localStorage.setItem(OPERATION_LOG_KEY, JSON.stringify(this.operationLogs))
      if (operationLogRos) {
        void manageOperationLogs(operationLogRos, {
          action: 'append',
          id: this.operationLogs[this.operationLogs.length - 1].id,
          timestamp: this.operationLogs[this.operationLogs.length - 1].timestamp,
          level,
          text: normalized,
        }).catch(() => undefined)
      }
    },
    clearLog() {
      this.message = ''
      this.error = ''
      this.operationLogs = []
      localStorage.removeItem(OPERATION_LOG_KEY)
      if (operationLogRos) {
        void manageOperationLogs(operationLogRos, { action: 'clear' }).catch(() => undefined)
      }
    },
    async run(work: () => Promise<void>) {
      this.busy = true
      this.message = ''
      this.error = ''
      try {
        await work()
      } catch (error) {
        this.error = String(error)
        this.addLog('error', this.error)
      } finally {
        this.busy = false
      }
    },
  },
})
