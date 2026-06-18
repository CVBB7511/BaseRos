<template>
  <section class="camera-panel">
    <header class="camera-header">
      <div>
        <div class="section-title">摄像头画面</div>
        <div class="camera-state">{{ stateText }}</div>
      </div>
      <v-chip size="small" :color="connected ? 'success' : 'default'" variant="flat">
        {{ connected ? `${displayedFps.toFixed(1)} fps` : '未连接' }}
      </v-chip>
    </header>

    <div class="camera-frame">
      <img ref="imageEl" alt="camera stream" />
      <div v-if="!hasFrame" class="camera-empty">
        <v-icon icon="mdi-video-outline" size="44" />
        <span>{{ emptyText }}</span>
      </div>
    </div>

    <div class="camera-controls">
      <v-text-field
        v-model="topic"
        label="压缩图像话题"
        density="compact"
        hide-details
        @change="persistAndSubscribe"
      />
      <v-text-field
        v-model.number="maxFps"
        label="显示帧率"
        type="number"
        min="1"
        max="15"
        density="compact"
        hide-details
        @change="persistAndSubscribe"
      />
    </div>
  </section>
</template>

<script setup lang="ts">
import ROSLIB from 'roslib'
import { computed, onBeforeUnmount, ref, watch } from 'vue'
import { defaultCameraFps, defaultCameraTopic } from '../ros/config'

interface CompressedImage {
  format: string
  data: string
}

const props = defineProps<{
  ros: ROSLIB.Ros | null
  connected: boolean
}>()

const topic = ref(localStorage.getItem('camera_topic') || defaultCameraTopic)
const maxFps = ref(Number(localStorage.getItem('camera_fps') || defaultCameraFps || 8))
const imageEl = ref<HTMLImageElement | null>(null)
const hasFrame = ref(false)
const status = ref('等待 ROS Bridge 连接')
const displayedFps = ref(0)

let cameraTopic: ROSLIB.Topic | null = null
let lastDrawAt = 0
let framesThisSecond = 0
let pendingFrame: CompressedImage | null = null
let animationFrame = 0
let drawTimer = 0
let statsTimer = 0

const normalizedFps = computed(() => {
  const value = Number(maxFps.value)
  if (!Number.isFinite(value)) {
    return 8
  }
  return Math.min(15, Math.max(1, value))
})

const stateText = computed(() => status.value)
const emptyText = computed(() => props.connected ? '等待压缩图像数据' : '连接 ROS Bridge 后自动显示')

function persistAndSubscribe() {
  localStorage.setItem('camera_topic', topic.value)
  localStorage.setItem('camera_fps', String(normalizedFps.value))
  subscribe()
}

function subscribe() {
  unsubscribe()
  if (!props.connected || !props.ros || !topic.value.trim()) {
    status.value = props.connected ? '请填写压缩图像话题' : '等待 ROS Bridge 连接'
    return
  }

  status.value = `订阅 ${topic.value}`
  cameraTopic = new ROSLIB.Topic({
    ros: props.ros,
    name: topic.value.trim(),
    messageType: 'sensor_msgs/CompressedImage',
    throttle_rate: Math.floor(1000 / normalizedFps.value),
    queue_length: 1,
    queue_size: 1,
  })
  cameraTopic.subscribe(handleFrame)
}

function unsubscribe() {
  if (cameraTopic) {
    cameraTopic.unsubscribe()
    cameraTopic = null
  }
  if (animationFrame) {
    window.cancelAnimationFrame(animationFrame)
    animationFrame = 0
  }
  if (drawTimer) {
    window.clearTimeout(drawTimer)
    drawTimer = 0
  }
  pendingFrame = null
}

function handleFrame(message: unknown) {
  const frame = message as CompressedImage
  if (!frame?.data) {
    return
  }
  const now = performance.now()
  const minInterval = 1000 / normalizedFps.value
  if (now - lastDrawAt < minInterval) {
    pendingFrame = frame
    if (!animationFrame) {
      animationFrame = window.requestAnimationFrame(drawPendingFrame)
    }
    return
  }
  drawFrame(frame)
}

function drawPendingFrame() {
  animationFrame = 0
  if (!pendingFrame) {
    return
  }
  const now = performance.now()
  const minInterval = 1000 / normalizedFps.value
  if (now - lastDrawAt < minInterval) {
    drawTimer = window.setTimeout(() => {
      drawTimer = 0
      drawPendingFrame()
    }, minInterval - (now - lastDrawAt))
    return
  }
  const frame = pendingFrame
  pendingFrame = null
  drawFrame(frame)
}

function drawFrame(frame: CompressedImage) {
  if (!imageEl.value) {
    return
  }
  const mime = frame.format?.toLowerCase().includes('png') ? 'image/png' : 'image/jpeg'
  imageEl.value.src = `data:${mime};base64,${frame.data}`
  hasFrame.value = true
  status.value = `正在显示 ${topic.value}`
  lastDrawAt = performance.now()
  framesThisSecond += 1
}

function startStatsTimer() {
  if (statsTimer) {
    return
  }
  statsTimer = window.setInterval(() => {
    displayedFps.value = framesThisSecond
    framesThisSecond = 0
    if (props.connected && cameraTopic && !hasFrame.value) {
      status.value = `已订阅 ${topic.value}，等待数据`
    }
  }, 1000)
}

watch(
  () => [props.connected, props.ros] as const,
  () => {
    hasFrame.value = false
    subscribe()
  },
  { immediate: true },
)

watch(normalizedFps, () => {
  persistAndSubscribe()
})

startStatsTimer()

onBeforeUnmount(() => {
  unsubscribe()
  if (statsTimer) {
    window.clearInterval(statsTimer)
  }
})
</script>

<style scoped>
.camera-panel {
  display: grid;
  grid-template-rows: auto minmax(0, 1fr) auto;
  gap: 12px;
  height: 100%;
  padding: 14px;
  background: #ffffff;
}

.camera-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
}

.section-title {
  color: #263241;
  font-size: 16px;
  font-weight: 750;
}

.camera-state {
  margin-top: 3px;
  color: #566579;
  font-size: 13px;
  overflow-wrap: anywhere;
}

.camera-frame {
  position: relative;
  min-height: 0;
  overflow: hidden;
  border: 1px solid #cad3dc;
  background: #111827;
}

.camera-frame img {
  display: block;
  width: 100%;
  height: 100%;
  object-fit: contain;
}

.camera-empty {
  position: absolute;
  inset: 0;
  display: grid;
  place-content: center;
  gap: 10px;
  color: #d7dee8;
  font-size: 14px;
  text-align: center;
}

.camera-controls {
  display: grid;
  grid-template-columns: minmax(0, 1fr) 120px;
  gap: 10px;
}

@media (max-width: 1100px) {
  .camera-controls {
    grid-template-columns: 1fr;
  }
}
</style>
