<template>
  <section class="operator-panel">
    <div class="section-title">导航控制</div>
    <v-btn-toggle v-model="mapStore.selectedTool" mandatory density="compact" divided>
      <v-btn value="goal" icon="mdi-map-marker-plus-outline" title="设置终点" />
      <v-btn value="inspect" icon="mdi-cursor-default-click-outline" title="查看地图" />
    </v-btn-toggle>

    <div class="pose-box">
      <div class="pose-title">终点</div>
      <div class="pose-line">{{ poseLabel(mapStore.goalPose) }}</div>
      <v-text-field
        :model-value="mapStore.goalYawDeg"
        label="终点角度"
        type="number"
        suffix="deg"
        hide-details
        @update:model-value="mapStore.updateGoalYaw(Number($event))"
      />
    </div>

    <v-btn
      color="primary"
      prepend-icon="mdi-navigation-variant-outline"
      :disabled="!rosStore.ros || !mapStore.goalPose || navigationStore.running"
      @click="startNavigation"
    >
      开始导航
    </v-btn>
    <v-btn
      color="error"
      prepend-icon="mdi-stop-circle-outline"
      :disabled="!navigationStore.running"
      @click="navigationStore.cancel()"
    >
      取消导航
    </v-btn>

    <v-progress-linear :model-value="navigationStore.progress" color="primary" height="8" />
    <div class="status-line">
      {{ navigationStore.state }}
    </div>
    <v-alert v-if="navigationStore.result?.message" density="compact" :type="navigationStore.result.success ? 'success' : 'warning'" variant="tonal">
      {{ navigationStore.result.message }}
    </v-alert>
    <v-alert v-if="navigationStore.error" density="compact" type="error" variant="tonal">
      {{ navigationStore.error }}
    </v-alert>
  </section>
</template>

<script setup lang="ts">
import { useMapStore } from '../stores/map'
import { useNavigationStore } from '../stores/navigation'
import { useRosStore } from '../stores/ros'
import { quaternionToYaw } from '../ros/types'
import type { Pose } from '../ros/types'

const rosStore = useRosStore()
const mapStore = useMapStore()
const navigationStore = useNavigationStore()

function poseLabel(pose: Pose | null) {
  if (!pose) {
    return '未设置'
  }
  return `x=${pose.position.x.toFixed(2)}, y=${pose.position.y.toFixed(2)}, yaw=${radToDeg(quaternionToYaw(pose.orientation)).toFixed(1)} deg`
}

function startNavigation() {
  if (rosStore.ros) {
    navigationStore.start(rosStore.ros, mapStore.goalPose)
  }
}

function radToDeg(radians: number) {
  return radians * 180 / Math.PI
}
</script>

<style scoped>
.operator-panel {
  display: flex;
  flex-direction: column;
  gap: 12px;
  padding: 14px;
  border: 1px solid #d6dde5;
  border-top: 0;
  background: #ffffff;
}

.section-title {
  color: #263241;
  font-size: 15px;
  font-weight: 700;
}

.pose-box {
  display: grid;
  gap: 8px;
  padding: 10px;
  border: 1px solid #edf1f5;
  background: #fbfcfd;
}

.pose-title {
  color: #263241;
  font-size: 13px;
  font-weight: 700;
}

.pose-line,
.status-line {
  color: #566579;
  font-size: 13px;
}
</style>
