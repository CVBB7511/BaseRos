<template>
  <header class="top-bar">
    <div class="brand">
      <v-icon icon="mdi-robot-outline" size="25" />
      <span>BaseRos 码垛建图前端</span>
    </div>
    <div class="top-actions">
      <v-chip :color="statusColor" size="small" variant="flat">
        {{ statusLabel }}
      </v-chip>
      <v-btn icon="mdi-cog-outline" size="small" variant="text" @click="$emit('open-settings')" />
    </div>
  </header>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { useRosStore } from '../stores/ros'

defineEmits<{ (event: 'open-settings'): void }>()

const rosStore = useRosStore()

const statusLabel = computed(() => ({
  disconnected: '未连接',
  connecting: '连接中',
  connected: '已连接',
  error: '连接错误',
}[rosStore.status]))

const statusColor = computed(() => ({
  disconnected: 'secondary',
  connecting: 'warning',
  connected: 'success',
  error: 'error',
}[rosStore.status]))
</script>

<style scoped>
.top-bar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 16px;
  border-bottom: 1px solid #cdd6df;
  background: #ffffff;
}

.brand,
.top-actions {
  display: flex;
  align-items: center;
  gap: 10px;
}

.brand {
  color: #1f2a37;
  font-size: 18px;
  font-weight: 750;
}
</style>
