<template>
  <footer class="status-footer">
    <span>ROS: {{ rosStore.status }}</span>
    <span>Mode: {{ frontendStore.modeLabel }}</span>
    <span>Mapping: {{ frontendStore.mappingRunning ? 'running' : 'stopped' }}</span>
    <span>Execute: {{ frontendStore.executeRunning ? 'running' : 'stopped' }}</span>
    <span v-if="frontendStore.message">{{ frontendStore.message }}</span>
    <span v-if="frontendStore.error" class="error-text">
      {{ frontendStore.error }}
    </span>
  </footer>
</template>

<script setup lang="ts">
import { useFrontendStore } from '../stores/frontend'
import { useRosStore } from '../stores/ros'

const rosStore = useRosStore()
const frontendStore = useFrontendStore()
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
