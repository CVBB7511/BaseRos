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
    <v-alert v-if="rosStore.error" density="compact" type="error" variant="tonal">
      {{ rosStore.error }}
    </v-alert>
  </section>
</template>

<script setup lang="ts">
import { useRosStore } from '../stores/ros'

defineEmits<{ (event: 'open-settings'): void }>()

const rosStore = useRosStore()
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
</style>
