<template>
  <section class="operator-panel">
    <div class="section-title">建图控制</div>
    <div class="mode-summary">
      <v-icon :icon="frontendStore.mode === 'sim' ? 'mdi-cube-outline' : 'mdi-robot-industrial-outline'" size="18" />
      <span>{{ frontendStore.modeLabel }}</span>
      <strong>{{ frontendStore.environmentStatusLabel }}</strong>
    </div>

    <v-btn
      color="primary"
      prepend-icon="mdi-power"
      :disabled="!rosStore.ros || !frontendStore.environmentReady || frontendStore.busy"
      :loading="frontendStore.busy"
      @click="requestRestartMapping"
    >
      重新建图
    </v-btn>

    <v-divider />

    <v-text-field v-model="frontendStore.saveDirectory" label="保存文件夹" hide-details />
    <v-text-field v-model="frontendStore.mapName" label="地图名称" hide-details />
    <v-btn
      color="primary"
      prepend-icon="mdi-content-save-outline"
      :disabled="!rosStore.ros || !frontendStore.environmentReady || frontendStore.busy"
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
      :disabled="!rosStore.ros || !frontendStore.environmentReady || frontendStore.busy"
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
      :disabled="!rosStore.ros || !frontendStore.environmentReady || frontendStore.busy"
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
      :disabled="!rosStore.ros || !frontendStore.environmentReady || frontendStore.busy || frontendStore.palletizingActive"
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

    <div class="log-heading">
      <span>执行日志</span>
      <v-btn
        icon="mdi-delete-outline"
        size="x-small"
        variant="text"
        title="清空执行日志"
        aria-label="清空执行日志"
        :disabled="frontendStore.operationLogs.length === 0"
        @click="frontendStore.clearLog"
      />
    </div>
    <div class="log-window" role="status" aria-live="polite">
      <div v-if="frontendStore.operationLogs.length === 0" class="log-empty">暂无操作日志</div>
      <v-card
        v-for="entry in frontendStore.operationLogsNewest"
        :key="entry.id"
        tag="article"
        variant="flat"
        class="log-entry"
        :class="`log-entry--${entry.level}`"
      >
        <div class="log-card-header">
          <div class="log-kind">
            <v-icon
              :icon="entry.level === 'success' ? 'mdi-check-circle-outline' : 'mdi-alert-circle-outline'"
              size="17"
            />
            <strong>{{ entry.level === 'success' ? '操作成功' : '操作失败' }}</strong>
          </div>
          <time :datetime="entry.timestamp">{{ formatLogTime(entry.timestamp) }}</time>
        </div>
        <v-card-text class="log-message">{{ entry.message }}</v-card-text>
      </v-card>
    </div>

    <v-dialog v-model="restartDialogOpen" max-width="420">
      <v-card>
        <v-card-title>确认重新建图</v-card-title>
        <v-card-text>
          当前地图尚未保存。重新建图会舍弃现有建图进度，且无法恢复。
        </v-card-text>
        <v-card-actions>
          <v-spacer />
          <v-btn variant="text" @click="restartDialogOpen = false">取消</v-btn>
          <v-btn color="error" variant="flat" @click="confirmRestartMapping">确定</v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
  </section>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useFrontendStore } from '../stores/frontend'
import { useRosStore } from '../stores/ros'

const rosStore = useRosStore()
const frontendStore = useFrontendStore()
const restartDialogOpen = ref(false)

function requestRestartMapping() {
  if (frontendStore.mappingRunning) {
    restartDialogOpen.value = true
    return
  }
  restartMapping()
}

function confirmRestartMapping() {
  restartDialogOpen.value = false
  restartMapping()
}

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

function formatLogTime(timestamp: string) {
  const date = new Date(timestamp)
  if (Number.isNaN(date.getTime())) return timestamp
  const pad = (value: number) => String(value).padStart(2, '0')
  return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())} ` +
    `${pad(date.getHours())}:${pad(date.getMinutes())}:${pad(date.getSeconds())}`
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

.mode-summary {
  display: grid;
  grid-template-columns: 22px auto 1fr;
  min-height: 42px;
  align-items: center;
  gap: 7px;
  padding: 8px 10px;
  border: 1px solid #d6dde5;
  background: #f8fafc;
  color: #354255;
  font-size: 13px;
}

.mode-summary strong {
  justify-self: end;
  color: #26704c;
  font-size: 12px;
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
  grid-template-columns: minmax(0, 1fr);
  grid-auto-rows: max-content;
  align-content: start;
  width: 100%;
  min-width: 0;
  height: 230px;
  min-height: 160px;
  max-height: 230px;
  gap: 9px;
  padding: 9px;
  border: 1px solid #d6dde5;
  overflow-y: auto;
  overflow-x: hidden;
  scrollbar-gutter: stable;
  background: #eef2f5;
}

.log-heading {
  display: flex;
  min-height: 28px;
  align-items: center;
  justify-content: space-between;
  color: #263241;
  font-size: 13px;
  font-weight: 700;
}

.log-entry {
  display: grid;
  width: 100%;
  min-width: 0;
  max-width: 100%;
  border: 1px solid #d5dde6;
  border-left: 4px solid #31845b;
  border-radius: 6px;
  overflow: hidden;
  background: #ffffff;
  box-shadow: 0 1px 3px rgb(31 42 55 / 8%);
}

.log-entry--error {
  border-left-color: #c53a2c;
}

.log-card-header {
  display: flex;
  min-width: 0;
  align-items: center;
  justify-content: space-between;
  flex-wrap: wrap;
  gap: 5px 12px;
  padding: 9px 11px 7px;
  border-bottom: 1px solid #edf1f5;
  color: #566579;
  font-size: 11px;
}

.log-kind {
  display: flex;
  min-width: 0;
  align-items: center;
  gap: 6px;
  color: #26704c;
}

.log-kind strong {
  font-size: 12px;
  font-weight: 700;
}

.log-entry--error .log-kind {
  color: #b42318;
}

.log-card-header time {
  min-width: 0;
  font-family: ui-monospace, SFMono-Regular, Menlo, Consolas, "Liberation Mono", monospace;
  white-space: nowrap;
}

.log-message {
  width: 100%;
  min-width: 0;
  max-width: 100%;
  padding: 10px 11px 12px !important;
  color: #354255;
  font-size: 13px;
  line-height: 1.55;
  overflow: visible;
  overflow-wrap: anywhere;
  white-space: pre-wrap;
  word-break: break-word;
}

.log-empty {
  display: grid;
  min-height: 140px;
  place-items: center;
  padding: 12px;
  color: #7a8796;
  font-size: 13px;
}
</style>
