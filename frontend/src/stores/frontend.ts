import ROSLIB from 'roslib'
import { defineStore } from 'pinia'
import { calibrateZone, importMap, queryFrontendStatus, saveMap, startMapping, startPalletizing } from '../ros/frontend'
import type { PalletizingStats } from '../ros/types'

type ZoneName = 'source' | 'dest'

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
  }),
  getters: {
    modeLabel: (state) => state.mode === 'sim' ? '仿真' : '真机',
    palletizingStateLabel: (state) => {
      const value = state.palletizingStats?.current_state || '未启动'
      const labels: Record<string, string> = {
        IDLE: '空闲',
        STARTING: '启动中',
        NAVIGATING: '导航中',
        DETECTING: '检测物体',
        GRABBING: '抓取中',
        PLACING: '放置中',
        DONE: '已完成',
      }
      return labels[value] || value
    },
  },
  actions: {
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
        this.palletizingStats = message as PalletizingStats
      })
    },
    unsubscribePalletizingStats() {
      if (this.palletizingTopic) {
        this.palletizingTopic.unsubscribe()
        this.palletizingTopic = null
      }
      this.palletizingStats = null
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
      this.message = result.message
      this.error = result.success ? '' : result.message
      this.lastPath = result.path || this.lastPath
    },
    async run(work: () => Promise<void>) {
      this.busy = true
      this.error = ''
      try {
        await work()
      } catch (error) {
        this.error = String(error)
      } finally {
        this.busy = false
      }
    },
  },
})
