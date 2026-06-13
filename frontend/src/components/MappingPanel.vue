<template>
  <section class="operator-panel">
    <div class="section-title">建图控制</div>
    <v-text-field v-model="mapStore.saveName" label="地图名称" hide-details />
    <v-btn
      color="primary"
      prepend-icon="mdi-content-save-outline"
      :disabled="!rosStore.ros || mapStore.busy"
      :loading="mapStore.busy"
      @click="save"
    >
      保存地图
    </v-btn>
    <v-btn
      color="warning"
      prepend-icon="mdi-map-remove-outline"
      :disabled="!rosStore.ros || mapStore.busy"
      @click="confirmClear = true"
    >
      清除地图
    </v-btn>

    <v-divider />

    <div class="hint">
      终端键盘控制：w/s/a/d/q/e 移动，空格刹车，m 保存。
    </div>
    <v-alert v-if="mapStore.message" density="compact" type="success" variant="tonal">
      {{ mapStore.message }}
    </v-alert>
    <v-alert v-if="mapStore.error" density="compact" type="error" variant="tonal">
      {{ mapStore.error }}
    </v-alert>

    <v-dialog v-model="confirmClear" max-width="420">
      <v-card>
        <v-card-title>清除地图</v-card-title>
        <v-card-text>该操作会请求后端清理当前地图文件。</v-card-text>
        <v-card-actions>
          <v-spacer />
          <v-btn variant="text" @click="confirmClear = false">取消</v-btn>
          <v-btn color="warning" @click="clear">确认</v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
  </section>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useMapStore } from '../stores/map'
import { useRosStore } from '../stores/ros'

const rosStore = useRosStore()
const mapStore = useMapStore()
const confirmClear = ref(false)

function save() {
  if (rosStore.ros) {
    mapStore.saveCurrentMap(rosStore.ros)
  }
}

function clear() {
  confirmClear.value = false
  if (rosStore.ros) {
    mapStore.clearCurrentMap(rosStore.ros)
  }
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

.hint {
  color: #566579;
  font-size: 13px;
  line-height: 1.6;
}
</style>
