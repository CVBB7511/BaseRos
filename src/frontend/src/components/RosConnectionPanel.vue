<template>
  <section class="panel">
    <div class="panel-head">
      <div class="title">ROS Bridge</div>
      <v-btn icon="mdi-tune-variant" size="x-small" variant="text" @click="$emit('open-settings')" />
    </div>
    <div class="url mono">{{ rosStore.url }}</div>
    <div class="actions">
      <v-btn
        v-if="!rosStore.connected"
        color="primary"
        prepend-icon="mdi-lan-connect"
        :loading="rosStore.status === 'connecting'"
        @click="rosStore.connect()"
      >
        连接
      </v-btn>
      <v-btn v-else color="secondary" prepend-icon="mdi-lan-disconnect" @click="rosStore.disconnect()">
        断开
      </v-btn>
    </div>
    <template v-if="rosStore.connected">
      <v-divider />
      <div class="environment-head">
        <span>运行环境</span>
        <span class="environment-state" :class="`environment-state--${frontendStore.environmentState}`">
          {{ frontendStore.environmentStatusLabel }}
        </span>
      </div>
      <v-btn-toggle
        v-model="frontendStore.mode"
        mandatory
        divided
        density="comfortable"
        color="primary"
        class="mode-control"
        :disabled="frontendStore.busy || frontendStore.environmentState === 'running'"
        @update:model-value="frontendStore.persist"
      >
        <v-btn value="real" prepend-icon="mdi-robot-industrial-outline">实机</v-btn>
        <v-btn value="sim" prepend-icon="mdi-cube-outline">仿真</v-btn>
      </v-btn-toggle>
      <v-btn
        v-if="frontendStore.environmentState !== 'running'"
        color="primary"
        :prepend-icon="frontendStore.mode === 'sim' ? 'mdi-play-box-outline' : 'mdi-link-variant'"
        :loading="frontendStore.busy"
        :disabled="frontendStore.busy"
        @click="activateEnvironment"
      >
        {{ frontendStore.mode === 'sim' ? '启用仿真' : '连接实机' }}
      </v-btn>
      <v-btn
        v-else
        color="secondary"
        variant="outlined"
        prepend-icon="mdi-power-plug-off-outline"
        :loading="frontendStore.busy"
        :disabled="frontendStore.busy || frontendStore.palletizingActive"
        @click="deactivateEnvironment"
      >
        {{ frontendStore.environmentMode === 'sim' ? '停用仿真' : '断开实机' }}
      </v-btn>
    </template>
    <v-alert v-if="rosStore.error" density="compact" type="error" variant="tonal">
      {{ rosStore.error }}
    </v-alert>
  </section>
</template>

<script setup lang="ts">
import { useRosStore } from '../stores/ros'
import { useFrontendStore } from '../stores/frontend'

defineEmits<{ (event: 'open-settings'): void }>()

const rosStore = useRosStore()
const frontendStore = useFrontendStore()

function activateEnvironment() {
  if (rosStore.ros) frontendStore.activateEnvironment(rosStore.ros)
}

function deactivateEnvironment() {
  if (rosStore.ros) frontendStore.deactivateEnvironment(rosStore.ros)
}
</script>

<style scoped>
.panel {
  display: flex;
  flex-direction: column;
  gap: 12px;
  padding: 14px;
  border: 1px solid #d6dde5;
  background: #ffffff;
}

.panel-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.title {
  color: #263241;
  font-size: 15px;
  font-weight: 700;
}

.url {
  overflow-wrap: anywhere;
  color: #566579;
  font-size: 12px;
}

.actions {
  display: grid;
}

.environment-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  color: #263241;
  font-size: 13px;
  font-weight: 700;
}

.environment-state {
  color: #6a7685;
  font-size: 12px;
  font-weight: 600;
}

.environment-state--running {
  color: #26704c;
}

.environment-state--error {
  color: #b42318;
}

.mode-control {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  width: 100%;
  min-height: 42px;
}

.mode-control :deep(.v-btn) {
  min-width: 0;
  height: 42px;
  padding-inline: 8px;
}
</style>
