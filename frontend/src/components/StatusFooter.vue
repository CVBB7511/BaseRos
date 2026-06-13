<template>
  <footer class="status-footer">
    <span>ROS: {{ rosStore.status }}</span>
    <span>Tool: {{ mapStore.selectedTool }}</span>
    <span>Navigation: {{ navigationStore.state }} {{ navigationStore.progress }}%</span>
    <span v-if="mapStore.message">{{ mapStore.message }}</span>
    <span v-if="mapStore.error || navigationStore.error" class="error-text">
      {{ mapStore.error || navigationStore.error }}
    </span>
  </footer>
</template>

<script setup lang="ts">
import { useMapStore } from '../stores/map'
import { useNavigationStore } from '../stores/navigation'
import { useRosStore } from '../stores/ros'

const rosStore = useRosStore()
const mapStore = useMapStore()
const navigationStore = useNavigationStore()
</script>

<style scoped>
.status-footer {
  display: flex;
  align-items: center;
  gap: 18px;
  padding: 0 14px;
  border-top: 1px solid #cdd6df;
  overflow: hidden;
  background: #ffffff;
  color: #506070;
  font-size: 12px;
  white-space: nowrap;
}

.error-text {
  color: #b42318;
}
</style>
