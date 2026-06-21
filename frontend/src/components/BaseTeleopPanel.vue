<template>
  <section class="teleop-panel" aria-label="底盘遥控">
    <div class="teleop-heading">
      <div>
        <div class="section-title">底盘遥控</div>
        <div class="teleop-subtitle">按一次改变一档速度</div>
      </div>
      <v-switch
        v-model="enabled"
        label="键盘控制"
        color="primary"
        density="compact"
        hide-details
        :disabled="!connected || locked"
      />
    </div>

    <div v-if="locked" class="teleop-locked">
      <v-icon icon="mdi-lock-outline" size="16" />
      码垛任务进行中，底盘遥控已锁定
    </div>

    <div class="teleop-grid">
      <v-btn icon="mdi-rotate-left" variant="outlined" :disabled="!canDrive" title="Q：逆时针旋转" aria-label="Q：逆时针旋转" @click="nudge('q')" />
      <v-btn icon="mdi-arrow-up" variant="outlined" :disabled="!canDrive" title="W：前进" aria-label="W：前进" @click="nudge('w')" />
      <v-btn icon="mdi-rotate-right" variant="outlined" :disabled="!canDrive" title="E：顺时针旋转" aria-label="E：顺时针旋转" @click="nudge('e')" />
      <v-btn icon="mdi-arrow-left" variant="outlined" :disabled="!canDrive" title="A：左移" aria-label="A：左移" @click="nudge('a')" />
      <v-btn icon="mdi-stop-circle-outline" color="error" variant="flat" :disabled="!connected || locked" title="Space：急停" aria-label="Space：急停" @click="emergencyStop" />
      <v-btn icon="mdi-arrow-right" variant="outlined" :disabled="!canDrive" title="D：右移" aria-label="D：右移" @click="nudge('d')" />
      <span />
      <v-btn icon="mdi-arrow-down" variant="outlined" :disabled="!canDrive" title="S：后退" aria-label="S：后退" @click="nudge('s')" />
      <span />
    </div>

    <div class="key-guide" aria-label="遥控按键提示">
      <span><kbd>W</kbd>/<kbd>S</kbd> 前后</span>
      <span><kbd>A</kbd>/<kbd>D</kbd> 左右</span>
      <span><kbd>Q</kbd>/<kbd>E</kbd> 旋转</span>
      <strong><kbd>Space</kbd> 急停</strong>
    </div>

    <div class="velocity-readout mono">
      <span>前后 {{ formatVelocity(linearX) }} m/s</span>
      <span>左右 {{ formatVelocity(linearY) }} m/s</span>
      <span>旋转 {{ formatVelocity(angularZ) }} rad/s</span>
    </div>
  </section>
</template>

<script setup lang="ts">
import ROSLIB from 'roslib'
import { computed, onBeforeUnmount, onMounted, ref, watch } from 'vue'

const props = defineProps<{
  ros: ROSLIB.Ros | null
  connected: boolean
  locked?: boolean
}>()

const STEP = 0.05
const MAX_LINEAR = 0.5
const MAX_ANGULAR = 1.0
const PUBLISH_PERIOD_MS = 100

const enabled = ref(false)
const linearX = ref(0)
const linearY = ref(0)
const angularZ = ref(0)
const canDrive = computed(() => props.connected && !props.locked && enabled.value && Boolean(props.ros))

let cmdVelTopic: ROSLIB.Topic | null = null
let publishTimer: number | null = null

function clamp(value: number, limit: number) {
  return Math.max(-limit, Math.min(limit, value))
}

function publishVelocity(forceStop = false) {
  if (!cmdVelTopic || !props.connected) {
    return
  }
  cmdVelTopic.publish(new ROSLIB.Message({
    linear: {
      x: forceStop ? 0 : linearX.value,
      y: forceStop ? 0 : linearY.value,
      z: 0,
    },
    angular: {
      x: 0,
      y: 0,
      z: forceStop ? 0 : angularZ.value,
    },
  }))
}

function resetVelocity() {
  linearX.value = 0
  linearY.value = 0
  angularZ.value = 0
}

function emergencyStop() {
  resetVelocity()
  publishVelocity(true)
}

function nudge(key: string) {
  if (!canDrive.value) {
    return
  }
  if (key === 'w') linearX.value = clamp(linearX.value + STEP, MAX_LINEAR)
  if (key === 's') linearX.value = clamp(linearX.value - STEP, MAX_LINEAR)
  if (key === 'a') linearY.value = clamp(linearY.value + STEP, MAX_LINEAR)
  if (key === 'd') linearY.value = clamp(linearY.value - STEP, MAX_LINEAR)
  if (key === 'q') angularZ.value = clamp(angularZ.value + STEP, MAX_ANGULAR)
  if (key === 'e') angularZ.value = clamp(angularZ.value - STEP, MAX_ANGULAR)
  publishVelocity()
}

function isEditing(target: EventTarget | null) {
  const element = target as HTMLElement | null
  return Boolean(element?.isContentEditable || ['INPUT', 'TEXTAREA', 'SELECT'].includes(element?.tagName ?? ''))
}

function handleKeydown(event: KeyboardEvent) {
  if (!canDrive.value || event.repeat || event.ctrlKey || event.altKey || event.metaKey || isEditing(event.target)) {
    return
  }
  const key = event.key.toLowerCase()
  if (key === ' ' || event.code === 'Space') {
    event.preventDefault()
    emergencyStop()
    return
  }
  if (['w', 's', 'a', 'd', 'q', 'e'].includes(key)) {
    event.preventDefault()
    nudge(key)
  }
}

function stopForLostFocus() {
  if (enabled.value) {
    emergencyStop()
  }
}

function handleVisibilityChange() {
  if (document.hidden) {
    stopForLostFocus()
  }
}

function attachTopic() {
  cmdVelTopic?.unadvertise()
  cmdVelTopic = props.ros && props.connected
    ? new ROSLIB.Topic({ ros: props.ros, name: '/cmd_vel', messageType: 'geometry_msgs/Twist' })
    : null
}

function formatVelocity(value: number) {
  return `${value >= 0 ? '+' : ''}${value.toFixed(2)}`
}

watch(
  () => [props.ros, props.connected] as const,
  () => {
    if (!props.connected) {
      enabled.value = false
      resetVelocity()
    }
    attachTopic()
  },
  { immediate: true },
)

watch(enabled, (active) => {
  if (!active) {
    emergencyStop()
  }
})

watch(() => props.locked, (locked) => {
  if (locked) {
    enabled.value = false
    emergencyStop()
  }
})

onMounted(() => {
  window.addEventListener('keydown', handleKeydown)
  window.addEventListener('blur', stopForLostFocus)
  window.addEventListener('beforeunload', emergencyStop)
  document.addEventListener('visibilitychange', handleVisibilityChange)
  publishTimer = window.setInterval(() => {
    if (canDrive.value) publishVelocity()
  }, PUBLISH_PERIOD_MS)
})

onBeforeUnmount(() => {
  emergencyStop()
  if (publishTimer !== null) window.clearInterval(publishTimer)
  window.removeEventListener('keydown', handleKeydown)
  window.removeEventListener('blur', stopForLostFocus)
  window.removeEventListener('beforeunload', emergencyStop)
  document.removeEventListener('visibilitychange', handleVisibilityChange)
  cmdVelTopic?.unadvertise()
  cmdVelTopic = null
})
</script>

<style scoped>
.teleop-panel {
  display: grid;
  gap: 10px;
  padding: 10px;
  border: 1px solid #d6dde5;
  background: #f8fafc;
}

.teleop-heading {
  display: flex;
  align-items: start;
  justify-content: space-between;
  gap: 12px;
}

.section-title {
  color: #263241;
  font-size: 15px;
  font-weight: 700;
}

.teleop-subtitle {
  margin-top: 2px;
  color: #66758a;
  font-size: 12px;
}

.teleop-locked {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 6px;
  padding: 7px;
  border: 1px solid #f2c9c5;
  background: #fff5f4;
  color: #a1281c;
  font-size: 12px;
}

.teleop-heading :deep(.v-switch) {
  flex: 0 0 auto;
}

.teleop-grid {
  display: grid;
  grid-template-columns: repeat(3, 44px);
  grid-auto-rows: 44px;
  justify-content: center;
  gap: 6px;
}

.teleop-grid :deep(.v-btn) {
  width: 44px;
  height: 44px;
}

.key-guide {
  display: flex;
  flex-wrap: wrap;
  justify-content: center;
  gap: 5px 12px;
  color: #566579;
  font-size: 12px;
}

.key-guide strong {
  color: #b42318;
}

kbd {
  min-width: 20px;
  padding: 1px 4px;
  border: 1px solid #b8c2ce;
  border-bottom-width: 2px;
  background: #ffffff;
  color: #263241;
  font: inherit;
  font-weight: 700;
  text-align: center;
}

.velocity-readout {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 5px;
  color: #445268;
  font-size: 11px;
  text-align: center;
}

@media (max-width: 1100px) {
  .velocity-readout {
    grid-template-columns: 1fr;
  }
}
</style>
