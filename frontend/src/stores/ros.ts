import ROSLIB from 'roslib'
import { defineStore } from 'pinia'
import { defaultBaseFrame, defaultMapFrame, defaultRosbridgeUrl } from '../ros/config'

interface RosState {
  ros: ROSLIB.Ros | null
  url: string
  mapFrame: string
  baseFrame: string
  mode: 'sim' | 'real'
  status: 'disconnected' | 'connecting' | 'connected' | 'error'
  error: string
  autoReconnect: boolean
  reconnectTimer: number | null
  manualClose: boolean
}

export const useRosStore = defineStore('ros', {
  state: (): RosState => ({
    ros: null,
    url: localStorage.getItem('rosbridge_url') || defaultRosbridgeUrl,
    mapFrame: localStorage.getItem('map_frame') || defaultMapFrame,
    baseFrame: localStorage.getItem('base_frame') || defaultBaseFrame,
    mode: (localStorage.getItem('run_mode') as 'sim' | 'real') || 'sim',
    status: 'disconnected',
    error: '',
    autoReconnect: localStorage.getItem('auto_reconnect') !== 'false',
    reconnectTimer: null,
    manualClose: false,
  }),
  getters: {
    connected: (state) => state.status === 'connected' && state.ros !== null,
  },
  actions: {
    saveSettings() {
      localStorage.setItem('rosbridge_url', this.url)
      localStorage.setItem('map_frame', this.mapFrame)
      localStorage.setItem('base_frame', this.baseFrame)
      localStorage.setItem('run_mode', this.mode)
      localStorage.setItem('auto_reconnect', String(this.autoReconnect))
    },
    connect() {
      this.disconnect(false)
      this.manualClose = false
      this.status = 'connecting'
      this.error = ''
      const ros = new ROSLIB.Ros({ url: this.url })
      this.ros = ros
      ros.on('connection', () => {
        this.status = 'connected'
        this.error = ''
        this.saveSettings()
      })
      ros.on('error', (error) => {
        this.status = 'error'
        this.error = String(error)
      })
      ros.on('close', () => {
        this.status = 'disconnected'
        if (!this.manualClose && this.autoReconnect) {
          this.scheduleReconnect()
        }
      })
    },
    disconnect(manual = true) {
      this.manualClose = manual
      if (this.reconnectTimer !== null) {
        window.clearTimeout(this.reconnectTimer)
        this.reconnectTimer = null
      }
      if (this.ros) {
        this.ros.close()
      }
      this.ros = null
      this.status = 'disconnected'
    },
    scheduleReconnect() {
      if (this.reconnectTimer !== null) {
        return
      }
      this.reconnectTimer = window.setTimeout(() => {
        this.reconnectTimer = null
        this.connect()
      }, 2500)
    },
  },
})
