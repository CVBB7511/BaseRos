<template>
  <section class="operator-panel">
    <div class="section-title">建图控制</div>
    <v-btn-toggle v-model="frontendStore.mode" mandatory density="comfortable" color="primary" class="segmented-control">
      <v-btn value="real" prepend-icon="mdi-robot-industrial-outline">真机</v-btn>
      <v-btn value="sim" prepend-icon="mdi-cube-outline">仿真</v-btn>
    </v-btn-toggle>

    <v-btn
      color="primary"
      prepend-icon="mdi-power"
      :disabled="!rosStore.ros || frontendStore.busy"
      :loading="frontendStore.busy"
      @click="restartMapping"
    >
      重新建图
    </v-btn>

    <v-divider />

    <v-text-field v-model="frontendStore.saveDirectory" label="保存文件夹" hide-details />
    <v-text-field v-model="frontendStore.mapName" label="地图名称" hide-details />
    <v-btn
      color="primary"
      prepend-icon="mdi-content-save-outline"
      :disabled="!rosStore.ros || frontendStore.busy"
      :loading="frontendStore.busy"
      @click="save"
    >
      保存地图
    </v-btn>

    <v-divider />

    <v-text-field v-model="frontendStore.importDirectory" label="导入文件夹" hide-details />
    <v-btn
      color="secondary"
      prepend-icon="mdi-folder-upload-outline"
      :disabled="!rosStore.ros || frontendStore.busy"
      @click="importSelected"
    >
      导入地图
    </v-btn>
    <div class="hint">
      导入后会启动执行系统和 RViz，请在 RViz 中使用 2D Pose Estimate 完成定位。
    </div>

    <v-divider />

    <div class="section-title">桌面标定</div>
    <v-btn-toggle
      v-model="frontendStore.calibrationZone"
      mandatory
      density="comfortable"
      color="primary"
      class="segmented-control"
      @update:model-value="frontendStore.applyZoneDefaults"
    >
      <v-btn value="source" prepend-icon="mdi-table-arrow-right">取货桌</v-btn>
      <v-btn value="dest" prepend-icon="mdi-table-arrow-left">码垛桌</v-btn>
    </v-btn-toggle>
    <div class="hint">
      请先在 RViz 完成 2D Pose Estimate，再将机器人移动到桌子正前方，使机器人朝向桌面中心。
    </div>
    <div class="field-grid">
      <v-text-field v-model.number="frontendStore.calibrationLength" label="桌子长度 (m)" type="number" density="compact" hide-details />
      <v-text-field v-model.number="frontendStore.calibrationWidth" label="桌子宽度/深度 (m)" type="number" density="compact" hide-details />
      <v-text-field v-model.number="frontendStore.calibrationHeight" label="桌面高度 (m)" type="number" density="compact" hide-details />
      <v-text-field v-model.number="frontendStore.calibrationDistance" label="机器人到桌面中心距离 (m)" type="number" density="compact" hide-details />
    </div>
    <v-btn
      color="primary"
      prepend-icon="mdi-crosshairs-gps"
      :disabled="!rosStore.ros || frontendStore.busy"
      :loading="frontendStore.busy"
      @click="calibrate"
    >
      保存标定
    </v-btn>

    <v-divider />

    <div class="section-title">码垛任务</div>
    <div class="task-status">
      <div>
        <span>当前状态</span>
        <strong>{{ frontendStore.palletizingStateLabel }}</strong>
      </div>
      <div>
        <span>耗时</span>
        <strong>{{ Math.round(frontendStore.palletizingStats?.elapsed_time ?? 0) }} s</strong>
      </div>
    </div>
    <v-btn
      color="success"
      prepend-icon="mdi-play-circle-outline"
      :disabled="!rosStore.ros || frontendStore.busy || frontendStore.palletizingActive"
      :loading="frontendStore.busy"
      @click="startTask"
    >
      开始码垛
    </v-btn>
    <v-btn
      color="error"
      prepend-icon="mdi-stop-circle-outline"
      variant="outlined"
      :disabled="!rosStore.ros || frontendStore.busy || !frontendStore.palletizingActive"
      :loading="frontendStore.busy"
      @click="stopTask"
    >
      终止码垛
    </v-btn>

    <v-divider />

    <div class="log-window">
      <div v-if="!frontendStore.message && !frontendStore.error" class="log-empty">暂无操作日志</div>
      <v-alert v-if="frontendStore.message" density="compact" type="success" variant="tonal">
        {{ frontendStore.message }}
      </v-alert>
      <v-alert v-if="frontendStore.error" density="compact" type="error" variant="tonal">
        {{ frontendStore.error }}
      </v-alert>
    </div>
  </section>
</template>

<script setup lang="ts">
import { useFrontendStore } from '../stores/frontend'
import { useRosStore } from '../stores/ros'

const rosStore = useRosStore()
const frontendStore = useFrontendStore()

function restartMapping() {
  if (rosStore.ros) {
    frontendStore.restartMapping(rosStore.ros)
  }
}

function save() {
  if (rosStore.ros) {
    frontendStore.save(rosStore.ros)
  }
}

function importSelected() {
  if (rosStore.ros) {
    frontendStore.importSelected(rosStore.ros)
  }
}

function calibrate() {
  if (rosStore.ros) {
    frontendStore.calibrate(rosStore.ros)
  }
}

function startTask() {
  if (rosStore.ros) {
    frontendStore.startTask(rosStore.ros)
  }
}

function stopTask() {
  if (rosStore.ros) {
    frontendStore.stopTask(rosStore.ros)
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
  overflow-y: auto;
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

.field-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 10px;
}

.segmented-control {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  width: 100%;
  height: auto;
  min-height: 44px;
}

.segmented-control :deep(.v-btn) {
  min-width: 0;
  height: 44px;
  padding-inline: 10px;
}

.segmented-control :deep(.v-btn__content) {
  min-width: 0;
  white-space: nowrap;
}

.task-status {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 8px;
}

.task-status div {
  display: grid;
  gap: 3px;
  padding: 8px;
  border: 1px solid #d6dde5;
  background: #f8fafc;
}

.task-status span {
  color: #566579;
  font-size: 12px;
}

.task-status strong {
  color: #263241;
  font-size: 15px;
}

.log-window {
  display: grid;
  align-content: start;
  min-height: 96px;
  max-height: 132px;
  padding: 8px;
  border: 1px solid #d6dde5;
  overflow-y: auto;
  background: #f8fafc;
}

.log-empty {
  color: #7a8796;
  font-size: 13px;
}
</style>
