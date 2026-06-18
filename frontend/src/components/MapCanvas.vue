<template>
  <div ref="containerRef" class="map-canvas-wrap">
    <canvas
      ref="mapCanvasRef"
      class="map-canvas map-canvas-layer"
      aria-hidden="true"
    />
    <canvas
      ref="canvasRef"
      class="map-canvas map-interaction-layer"
      :class="{ 'is-goal-tool': mapStore.selectedTool === 'goal' }"
      @mousedown="handleMouseDown"
      @mousemove="handleMouseMove"
      @mouseup="handleMouseUp"
      @mouseleave="handleMouseUp"
      @wheel.prevent="handleWheel"
    />
    <div class="map-tools">
      <v-btn icon="mdi-fit-to-page-outline" size="small" title="适配地图" @click="fitMap" />
      <v-btn icon="mdi-map-marker-plus-outline" size="small" title="设置终点" :color="mapStore.selectedTool === 'goal' ? 'accent' : undefined" @click="mapStore.selectedTool = 'goal'" />
      <v-btn icon="mdi-cursor-default-click-outline" size="small" title="查看地图" :color="mapStore.selectedTool === 'inspect' ? 'secondary' : undefined" @click="mapStore.selectedTool = 'inspect'" />
    </div>
    <div class="scale-chip">
      fit x {{ mapFitScale }}
      <span v-if="mapRenderStep > 1"> / map 1:{{ mapRenderStep }}</span>
    </div>
    <div v-if="!mapStore.grid" class="empty-state">
      <v-icon icon="mdi-map-outline" size="42" />
      <span>等待 /map</span>
    </div>
  </div>
</template>

<script setup lang="ts">
import { nextTick, onBeforeUnmount, onMounted, ref, watch } from 'vue'
import { defaultMapFitScale } from '../ros/config'
import { useMapStore } from '../stores/map'
import { quaternionToYaw } from '../ros/types'
import type { OccupancyGrid, Pose } from '../ros/types'

const mapStore = useMapStore()
const mapFitScale = Number.isFinite(defaultMapFitScale) && defaultMapFitScale > 0 ? defaultMapFitScale : 1
const maxRenderedMapCells = 1_000_000
const maxPathDisplayPoints = 320
const canvasRef = ref<HTMLCanvasElement | null>(null)
const mapCanvasRef = ref<HTMLCanvasElement | null>(null)
const containerRef = ref<HTMLElement | null>(null)
const scale = ref(1)
const offsetX = ref(0)
const offsetY = ref(0)
const dragging = ref(false)
const movedDuringDrag = ref(false)
const dragStart = ref({ x: 0, y: 0, offsetX: 0, offsetY: 0 })
const interactionMode = ref<'pan' | 'goal' | null>(null)

let resizeObserver: ResizeObserver | null = null
let mapBitmap: ImageData | null = null
let lastGridRef: OccupancyGrid | null = null
let bufferCanvas: HTMLCanvasElement | null = null
let bufferContext: CanvasRenderingContext2D | null = null
let draftGoal: { start: WorldPoint, end: WorldPoint } | null = null
let lastMapMetaKey = ''
let drawScheduled = false
let mapDrawRequested = true
const mapRenderStep = ref(1)

watch(
  () => mapStore.grid,
  async (grid) => {
    if (grid) {
      updateMapBuffer(grid)
      lastGridRef = grid
      const metaKey = mapMetaKey(grid)
      const shouldFit = metaKey !== lastMapMetaKey
      lastMapMetaKey = metaKey
      await nextTick()
      if (shouldFit) {
        fitMap()
      } else {
        scheduleDraw(true)
      }
    } else {
      mapBitmap = null
      bufferCanvas = null
      bufferContext = null
      lastGridRef = null
      lastMapMetaKey = ''
      scheduleDraw(true)
    }
  },
)

watch(
  () => [mapStore.path, mapStore.robotPose, mapStore.goalPose, mapStore.selectedTool, mapStore.scan],
  () => scheduleDraw(false),
)

onMounted(() => {
  resizeCanvas()
  resizeObserver = new ResizeObserver(() => {
    resizeCanvas()
    fitMap(false)
  })
  if (containerRef.value) {
    resizeObserver.observe(containerRef.value)
  }
})

onBeforeUnmount(() => {
  resizeObserver?.disconnect()
})

function resizeCanvas() {
  const canvas = canvasRef.value
  const mapCanvas = mapCanvasRef.value
  const container = containerRef.value
  if (!canvas || !mapCanvas || !container) {
    return
  }
  const rect = container.getBoundingClientRect()
  const ratio = window.devicePixelRatio || 1
  for (const target of [canvas, mapCanvas]) {
    target.width = Math.max(1, Math.floor(rect.width * ratio))
    target.height = Math.max(1, Math.floor(rect.height * ratio))
    target.style.width = `${rect.width}px`
    target.style.height = `${rect.height}px`
    const ctx = target.getContext('2d')
    ctx?.setTransform(ratio, 0, 0, ratio, 0, 0)
  }
  scheduleDraw(true)
}

function fitMap(redraw = true) {
  const canvas = canvasRef.value
  const grid = mapStore.grid
  if (!canvas || !grid) {
    scheduleDraw(true)
    return
  }
  const rect = canvas.getBoundingClientRect()
  const padding = 38
  const fitScale = Math.min(
    (rect.width - padding * 2) / grid.info.width,
    (rect.height - padding * 2) / grid.info.height,
  )
  scale.value = Math.max(0.2, fitScale * mapFitScale)
  offsetX.value = (rect.width - grid.info.width * scale.value) / 2
  offsetY.value = (rect.height - grid.info.height * scale.value) / 2
  if (redraw) {
    scheduleDraw(true)
  }
}

function scheduleDraw(redrawMap = false) {
  mapDrawRequested ||= redrawMap
  if (drawScheduled) {
    return
  }
  drawScheduled = true
  window.requestAnimationFrame(() => {
    drawScheduled = false
    if (mapDrawRequested) {
      drawMapLayer()
      mapDrawRequested = false
    }
    drawOverlayLayer()
  })
}

function buildMapImage(grid: OccupancyGrid): MapRenderBuffer {
  const { width, height } = grid.info
  const step = getMapRenderStep(width, height)
  const renderWidth = Math.ceil(width / step)
  const renderHeight = Math.ceil(height / step)
  const image = new ImageData(renderWidth, renderHeight)

  for (let y = 0; y < renderHeight; y += 1) {
    const sourceY = height - 1 - Math.min(height - 1, y * step + Math.floor(step / 2))
    for (let x = 0; x < renderWidth; x += 1) {
      const sourceX = Math.min(width - 1, x * step + Math.floor(step / 2))
      const value = grid.data[sourceY * width + sourceX]
      const pixel = (y * renderWidth + x) * 4
      const color = occupancyColor(value)
      image.data[pixel] = color.r
      image.data[pixel + 1] = color.g
      image.data[pixel + 2] = color.b
      image.data[pixel + 3] = color.a
    }
  }
  return {
    image,
    width: renderWidth,
    height: renderHeight,
    step,
  }
}

function drawMapLayer() {
  const canvas = mapCanvasRef.value
  if (!canvas) {
    return
  }
  const ctx = canvas.getContext('2d')
  if (!ctx) {
    return
  }
  const rect = canvas.getBoundingClientRect()
  ctx.clearRect(0, 0, rect.width, rect.height)
  ctx.fillStyle = '#f6f9fb'
  ctx.fillRect(0, 0, rect.width, rect.height)
  drawGridBackdrop(ctx, rect.width, rect.height)

  const grid = mapStore.grid
  if (!grid || !bufferCanvas) {
    return
  }
  if (lastGridRef !== grid) {
    updateMapBuffer(grid)
    lastGridRef = grid
  }

  ctx.save()
  ctx.imageSmoothingEnabled = false
  ctx.translate(offsetX.value, offsetY.value)
  ctx.scale(scale.value, scale.value)
  ctx.drawImage(bufferCanvas, 0, 0, grid.info.width, grid.info.height)
  ctx.restore()
  drawMapBorder(ctx, grid)
}

function drawOverlayLayer() {
  const canvas = canvasRef.value
  if (!canvas) {
    return
  }
  const ctx = canvas.getContext('2d')
  if (!ctx) {
    return
  }
  const rect = canvas.getBoundingClientRect()
  ctx.clearRect(0, 0, rect.width, rect.height)

  const grid = mapStore.grid
  if (!grid) {
    return
  }

  drawPath(ctx)
  drawLaserScan(ctx)
  if (mapStore.robotPose) {
    drawRobot(ctx, mapStore.robotPose)
  }
  if (mapStore.goalPose) {
    drawGoalPose(ctx, mapStore.goalPose)
  }
  if (draftGoal) {
    drawArrow(ctx, draftGoal.start, draftGoal.end, '#e5484d', true)
  }
}

function updateMapBuffer(grid: OccupancyGrid) {
  const rendered = buildMapImage(grid)
  mapBitmap = rendered.image
  mapRenderStep.value = rendered.step
  if (!bufferCanvas) {
    bufferCanvas = document.createElement('canvas')
  }
  if (bufferCanvas.width !== rendered.width || bufferCanvas.height !== rendered.height) {
    bufferCanvas.width = rendered.width
    bufferCanvas.height = rendered.height
    bufferContext = bufferCanvas.getContext('2d')
  }
  bufferContext?.putImageData(mapBitmap, 0, 0)
}

function getMapRenderStep(width: number, height: number) {
  const cells = width * height
  if (cells <= maxRenderedMapCells) {
    return 1
  }
  return Math.ceil(Math.sqrt(cells / maxRenderedMapCells))
}

function mapMetaKey(grid: OccupancyGrid) {
  const origin = grid.info.origin
  return [
    grid.info.width,
    grid.info.height,
    grid.info.resolution,
    origin.position.x,
    origin.position.y,
    origin.position.z,
    origin.orientation.x,
    origin.orientation.y,
    origin.orientation.z,
    origin.orientation.w,
  ].join(':')
}

function drawGridBackdrop(ctx: CanvasRenderingContext2D, width: number, height: number) {
  ctx.strokeStyle = '#dfe8ee'
  ctx.lineWidth = 1
  for (let x = 0; x < width; x += 32) {
    ctx.beginPath()
    ctx.moveTo(x, 0)
    ctx.lineTo(x, height)
    ctx.stroke()
  }
  for (let y = 0; y < height; y += 32) {
    ctx.beginPath()
    ctx.moveTo(0, y)
    ctx.lineTo(width, y)
    ctx.stroke()
  }
}

function drawMapBorder(ctx: CanvasRenderingContext2D, grid: OccupancyGrid) {
  ctx.save()
  ctx.strokeStyle = '#5e717d'
  ctx.lineWidth = 1
  ctx.strokeRect(offsetX.value, offsetY.value, grid.info.width * scale.value, grid.info.height * scale.value)
  ctx.restore()
}

function drawPath(ctx: CanvasRenderingContext2D) {
  const poses = mapStore.path?.poses ?? []
  if (poses.length < 2) {
    return
  }
  const step = Math.max(1, Math.ceil(poses.length / maxPathDisplayPoints))
  ctx.strokeStyle = '#2f9e75'
  ctx.lineWidth = 4
  ctx.lineJoin = 'round'
  ctx.lineCap = 'round'
  ctx.beginPath()
  poses.forEach((poseStamped, index) => {
    if (index !== 0 && index !== poses.length - 1 && index % step !== 0) {
      return
    }
    const p = worldToCanvas(poseStamped.pose.position.x, poseStamped.pose.position.y)
    if (index === 0) {
      ctx.moveTo(p.x, p.y)
    } else {
      ctx.lineTo(p.x, p.y)
    }
  })
  ctx.stroke()
}

function drawLaserScan(ctx: CanvasRenderingContext2D) {
  const scan = mapStore.scan
  const robotPose = mapStore.robotPose
  if (!scan || !robotPose || scan.ranges.length === 0) {
    return
  }
  const robotYaw = quaternionToYaw(robotPose.orientation)
  const step = Math.max(1, Math.floor(scan.ranges.length / 360))

  ctx.save()
  ctx.fillStyle = 'rgba(228, 62, 70, 0.75)'
  for (let i = 0; i < scan.ranges.length; i += step) {
    const range = scan.ranges[i]
    if (!Number.isFinite(range) || range < scan.range_min || range > scan.range_max) {
      continue
    }
    const angle = robotYaw + scan.angle_min + i * scan.angle_increment
    const x = robotPose.position.x + range * Math.cos(angle)
    const y = robotPose.position.y + range * Math.sin(angle)
    const p = worldToCanvas(x, y)
    ctx.fillRect(p.x - 1.5, p.y - 1.5, 3, 3)
  }
  ctx.restore()
}

function drawRobot(ctx: CanvasRenderingContext2D, pose: Pose) {
  const p = worldToCanvas(pose.position.x, pose.position.y)
  const yaw = quaternionToYaw(pose.orientation)
  const bodyLength = clamp(metersToPixels(0.54), 24, 54)
  const bodyWidth = clamp(metersToPixels(0.38), 18, 40)
  const radius = clamp(metersToPixels(0.28), 18, 48)

  ctx.save()
  ctx.translate(p.x, p.y)
  ctx.strokeStyle = 'rgba(37, 111, 120, 0.26)'
  ctx.lineWidth = 2
  ctx.setLineDash([5, 4])
  ctx.beginPath()
  ctx.arc(0, 0, radius, 0, Math.PI * 2)
  ctx.stroke()
  ctx.setLineDash([])

  ctx.rotate(-yaw)
  ctx.fillStyle = '#256f78'
  ctx.strokeStyle = '#ffffff'
  ctx.lineWidth = 2
  ctx.beginPath()
  ctx.ellipse(0, 0, bodyLength / 2, bodyWidth / 2, 0, 0, Math.PI * 2)
  ctx.fill()
  ctx.stroke()

  ctx.fillStyle = '#42d3c8'
  ctx.beginPath()
  ctx.moveTo(bodyLength / 2 + 7, 0)
  ctx.lineTo(bodyLength / 2 - 6, -bodyWidth / 2 + 5)
  ctx.lineTo(bodyLength / 2 - 6, bodyWidth / 2 - 5)
  ctx.closePath()
  ctx.fill()
  ctx.stroke()

  ctx.fillStyle = '#ffffff'
  ctx.beginPath()
  ctx.arc(-bodyLength * 0.18, -bodyWidth * 0.28, 3, 0, Math.PI * 2)
  ctx.arc(-bodyLength * 0.18, bodyWidth * 0.28, 3, 0, Math.PI * 2)
  ctx.fill()
  ctx.restore()
}

function drawGoalPose(ctx: CanvasRenderingContext2D, pose: Pose) {
  const yaw = quaternionToYaw(pose.orientation)
  const start = { x: pose.position.x, y: pose.position.y }
  const length = Math.max(0.32, pixelsToMeters(34))
  const end = {
    x: start.x + Math.cos(yaw) * length,
    y: start.y + Math.sin(yaw) * length,
  }
  drawArrow(ctx, start, end, '#d8793a', false)
  const p = worldToCanvas(start.x, start.y)
  ctx.save()
  ctx.fillStyle = '#d8793a'
  ctx.strokeStyle = '#ffffff'
  ctx.lineWidth = 2
  ctx.beginPath()
  ctx.arc(p.x, p.y, 7, 0, Math.PI * 2)
  ctx.fill()
  ctx.stroke()
  ctx.restore()
}

function drawArrow(
  ctx: CanvasRenderingContext2D,
  start: WorldPoint,
  end: WorldPoint,
  color: string,
  dashed: boolean,
) {
  const a = worldToCanvas(start.x, start.y)
  const b = worldToCanvas(end.x, end.y)
  const dx = b.x - a.x
  const dy = b.y - a.y
  const length = Math.hypot(dx, dy)
  if (length < 3) {
    return
  }
  const ux = dx / length
  const uy = dy / length
  const head = 13
  const wing = 6

  ctx.save()
  ctx.strokeStyle = color
  ctx.fillStyle = color
  ctx.lineWidth = 3
  ctx.lineCap = 'round'
  if (dashed) {
    ctx.setLineDash([7, 5])
  }
  ctx.beginPath()
  ctx.moveTo(a.x, a.y)
  ctx.lineTo(b.x, b.y)
  ctx.stroke()
  ctx.setLineDash([])
  ctx.beginPath()
  ctx.moveTo(b.x, b.y)
  ctx.lineTo(b.x - ux * head - uy * wing, b.y - uy * head + ux * wing)
  ctx.lineTo(b.x - ux * head + uy * wing, b.y - uy * head - ux * wing)
  ctx.closePath()
  ctx.fill()
  ctx.restore()
}

function worldToCanvas(x: number, y: number) {
  const grid = mapStore.grid
  if (!grid) {
    return { x: 0, y: 0 }
  }
  const origin = grid.info.origin.position
  const cellX = (x - origin.x) / grid.info.resolution
  const cellY = (y - origin.y) / grid.info.resolution
  return {
    x: offsetX.value + cellX * scale.value,
    y: offsetY.value + (grid.info.height - cellY) * scale.value,
  }
}

function canvasToWorld(clientX: number, clientY: number) {
  const canvas = canvasRef.value
  const grid = mapStore.grid
  if (!canvas || !grid) {
    return null
  }
  const rect = canvas.getBoundingClientRect()
  const x = clientX - rect.left
  const y = clientY - rect.top
  const cellX = (x - offsetX.value) / scale.value
  const cellY = grid.info.height - ((y - offsetY.value) / scale.value)
  return {
    x: grid.info.origin.position.x + cellX * grid.info.resolution,
    y: grid.info.origin.position.y + cellY * grid.info.resolution,
  }
}

function handleMouseDown(event: MouseEvent) {
  const point = canvasToWorld(event.clientX, event.clientY)
  dragging.value = true
  movedDuringDrag.value = false
  interactionMode.value = mapStore.selectedTool === 'goal' && point ? 'goal' : 'pan'
  dragStart.value = {
    x: event.clientX,
    y: event.clientY,
    offsetX: offsetX.value,
    offsetY: offsetY.value,
  }
  if (interactionMode.value === 'goal' && point) {
    draftGoal = { start: point, end: point }
    scheduleDraw()
  }
}

function handleMouseMove(event: MouseEvent) {
  if (!dragging.value) {
    return
  }
  const dx = event.clientX - dragStart.value.x
  const dy = event.clientY - dragStart.value.y
  if (Math.abs(dx) + Math.abs(dy) > 3) {
    movedDuringDrag.value = true
  }
  if (interactionMode.value === 'goal') {
    const point = canvasToWorld(event.clientX, event.clientY)
    if (draftGoal && point) {
      draftGoal = { start: draftGoal.start, end: point }
    }
  } else {
    offsetX.value = dragStart.value.offsetX + dx
    offsetY.value = dragStart.value.offsetY + dy
  }
  scheduleDraw()
}

function handleMouseUp(event: MouseEvent) {
  if (!dragging.value) {
    return
  }
  if (interactionMode.value === 'goal') {
    const point = canvasToWorld(event.clientX, event.clientY)
    if (draftGoal && point) {
      const dx = point.x - draftGoal.start.x
      const dy = point.y - draftGoal.start.y
      const yaw = Math.hypot(dx, dy) > pixelsToMeters(8)
        ? Math.atan2(dy, dx)
        : mapStore.goalYawDeg * Math.PI / 180
      mapStore.setGoalFromMap(draftGoal.start.x, draftGoal.start.y, yaw)
    }
    draftGoal = null
    scheduleDraw()
  }
  dragging.value = false
  interactionMode.value = null
}

function handleWheel(event: WheelEvent) {
  const canvas = canvasRef.value
  if (!canvas) {
    return
  }
  const rect = canvas.getBoundingClientRect()
  const mx = event.clientX - rect.left
  const my = event.clientY - rect.top
  const beforeX = (mx - offsetX.value) / scale.value
  const beforeY = (my - offsetY.value) / scale.value
  const factor = event.deltaY < 0 ? 1.12 : 0.88
  scale.value = Math.min(12, Math.max(0.12, scale.value * factor))
  offsetX.value = mx - beforeX * scale.value
  offsetY.value = my - beforeY * scale.value
  scheduleDraw()
}

function occupancyColor(value: number) {
  if (value < 0) {
    return { r: 255, g: 255, b: 255, a: 0 }
  }
  const lightness = clamp(48 - value * 0.42, 8, 48)
  const { r, g, b } = hslToRgb(184, 74, lightness)
  return { r, g, b, a: 235 }
}

function hslToRgb(h: number, s: number, l: number) {
  const hue = h / 360
  const saturation = s / 100
  const light = l / 100
  if (saturation === 0) {
    const value = Math.round(light * 255)
    return { r: value, g: value, b: value }
  }
  const q = light < 0.5 ? light * (1 + saturation) : light + saturation - light * saturation
  const p = 2 * light - q
  return {
    r: Math.round(hueToRgb(p, q, hue + 1 / 3) * 255),
    g: Math.round(hueToRgb(p, q, hue) * 255),
    b: Math.round(hueToRgb(p, q, hue - 1 / 3) * 255),
  }
}

function hueToRgb(p: number, q: number, t: number) {
  let value = t
  if (value < 0) {
    value += 1
  }
  if (value > 1) {
    value -= 1
  }
  if (value < 1 / 6) {
    return p + (q - p) * 6 * value
  }
  if (value < 1 / 2) {
    return q
  }
  if (value < 2 / 3) {
    return p + (q - p) * (2 / 3 - value) * 6
  }
  return p
}

function metersToPixels(meters: number) {
  const grid = mapStore.grid
  if (!grid) {
    return meters * 20
  }
  return meters / grid.info.resolution * scale.value
}

function pixelsToMeters(pixels: number) {
  const grid = mapStore.grid
  if (!grid || scale.value <= 0) {
    return 0
  }
  return pixels / scale.value * grid.info.resolution
}

function clamp(value: number, min: number, max: number) {
  return Math.min(max, Math.max(min, value))
}

interface WorldPoint {
  x: number
  y: number
}

interface MapRenderBuffer {
  image: ImageData
  width: number
  height: number
  step: number
}
</script>

<style scoped>
.map-canvas-wrap {
  position: relative;
  width: 100%;
  height: 100%;
  min-height: 360px;
}

.map-canvas {
  position: absolute;
  inset: 0;
  display: block;
  width: 100%;
  height: 100%;
}

.map-canvas-layer {
  z-index: 0;
  pointer-events: none;
}

.map-interaction-layer {
  z-index: 1;
  cursor: crosshair;
}

.map-tools {
  position: absolute;
  z-index: 2;
  top: 12px;
  left: 12px;
  display: flex;
  gap: 8px;
  padding: 6px;
  border: 1px solid #d6dde5;
  background: rgba(255, 255, 255, 0.94);
}

.scale-chip {
  position: absolute;
  z-index: 2;
  right: 12px;
  bottom: 12px;
  padding: 4px 8px;
  border: 1px solid #d6dde5;
  background: rgba(255, 255, 255, 0.94);
  color: #566579;
  font-size: 12px;
}

.empty-state {
  position: absolute;
  z-index: 2;
  inset: 0;
  display: grid;
  place-content: center;
  gap: 10px;
  color: #68778a;
  pointer-events: none;
  text-align: center;
}
</style>
