import ROSLIB from 'roslib'
import type { NavigateFeedback, NavigateResult, Pose } from './types'

export interface NavigateHandlers {
  onFeedback: (feedback: NavigateFeedback) => void
  onResult: (result: NavigateResult) => void
  onStatus?: (status: string) => void
}

export class NavigationGoalClient {
  private readonly client: ROSLIB.ActionClient
  private goal: RosGoalWithEvents | null = null

  constructor(ros: ROSLIB.Ros) {
    this.client = new ROSLIB.ActionClient({
      ros,
      serverName: '/se_navigation/navigate',
      actionName: 'se_navigation/NavigateAction',
      timeout: 10000,
    })
  }

  send(goalPose: Pose, handlers: NavigateHandlers): void {
    this.cancel()
    this.goal = new ROSLIB.Goal({
      actionClient: this.client,
      goalMessage: {
        goal: goalPose,
      },
    }) as RosGoalWithEvents
    this.goal.on('feedback', (feedback) => handlers.onFeedback(feedback as NavigateFeedback))
    this.goal.on('result', (result) => {
      handlers.onResult(result as NavigateResult)
      this.goal = null
    })
    this.goal.on('status', (status) => handlers.onStatus?.(JSON.stringify(status)))
    this.goal.send()
  }

  cancel(): void {
    if (this.goal) {
      this.goal.cancel()
      this.goal = null
    }
  }
}

type RosGoalWithEvents = ROSLIB.Goal & {
  on(event: 'feedback', callback: (feedback: NavigateFeedback) => void): void
  on(event: 'result', callback: (result: NavigateResult) => void): void
  on(event: 'status', callback: (status: unknown) => void): void
}
