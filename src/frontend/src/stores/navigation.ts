import type ROSLIB from 'roslib'
import { defineStore } from 'pinia'
import { NavigationGoalClient } from '../ros/navigation'
import type { NavigateFeedback, NavigateResult, Pose } from '../ros/types'

interface NavigationState {
  client: NavigationGoalClient | null
  running: boolean
  state: string
  progress: number
  result: NavigateResult | null
  error: string
  watchdogTimer: number | null
}

export const useNavigationStore = defineStore('navigation', {
  state: (): NavigationState => ({
    client: null,
    running: false,
    state: 'idle',
    progress: 0,
    result: null,
    error: '',
    watchdogTimer: null,
  }),
  actions: {
    attach(ros: ROSLIB.Ros) {
      this.client = new NavigationGoalClient(ros)
    },
    detach() {
      this.cancel()
      this.client = null
    },
    start(ros: ROSLIB.Ros, goalPose: Pose | null) {
      if (!goalPose) {
        this.error = '请先在地图上设置终点'
        return
      }
      if (!this.client) {
        this.attach(ros)
      }
      this.running = true
      this.result = null
      this.error = ''
      this.progress = 0
      this.state = 'sending'
      this.armWatchdog()
      this.client?.send(goalPose, {
        onFeedback: (feedback: NavigateFeedback) => {
          this.clearWatchdog()
          this.progress = feedback.percentage
          this.state = feedback.state
        },
        onResult: (result: NavigateResult) => {
          this.clearWatchdog()
          this.result = result
          this.running = false
          this.progress = result.success ? 100 : this.progress
          this.state = result.result
          if (!result.success) {
            this.error = result.message
          }
        },
      })
    },
    cancel() {
      this.clearWatchdog()
      this.client?.cancel()
      if (this.running) {
        this.running = false
        this.state = 'cancel'
      }
    },
    armWatchdog() {
      this.clearWatchdog()
      this.watchdogTimer = window.setTimeout(() => {
        if (!this.running || this.state !== 'sending') {
          return
        }
        this.client?.cancel()
        this.running = false
        this.state = 'backend_timeout'
        this.error = '导航后端未响应，请确认 Live Navigation Stack 终端已启动并且 /se_navigation/navigate 可用'
      }, 12000)
    },
    clearWatchdog() {
      if (this.watchdogTimer !== null) {
        window.clearTimeout(this.watchdogTimer)
        this.watchdogTimer = null
      }
    },
  },
})
