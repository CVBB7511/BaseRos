<template>
  <v-dialog v-model="open" max-width="760">
    <v-card class="settings-dialog">
      <v-card-title>系统设置</v-card-title>
      <v-tabs v-model="tab" color="primary" grow>
        <v-tab value="connection" prepend-icon="mdi-lan">连接配置</v-tab>
        <v-tab value="robot" prepend-icon="mdi-tune-vertical">机器人参数</v-tab>
      </v-tabs>

      <v-divider />

      <v-card-text class="settings-content">
        <v-window v-model="tab">
          <v-window-item value="connection">
            <div class="settings-form">
              <v-text-field v-model="draftUrl" label="ROS Bridge 地址 (rosbridge_url)" />
              <v-text-field v-model="draftMapFrame" label="地图坐标系 (map_frame)" />
              <v-text-field v-model="draftBaseFrame" label="机器人坐标系 (base_frame)" />
              <v-switch v-model="draftAutoReconnect" color="primary" label="自动重连 (auto_reconnect)" hide-details />
            </div>
          </v-window-item>

          <v-window-item value="robot">
            <v-alert v-if="!rosStore.connected" density="compact" type="warning" variant="tonal">
              请先连接 ROS Bridge。
            </v-alert>
            <v-alert
              v-else-if="frontendStore.environmentState === 'running'"
              density="compact"
              type="warning"
              variant="tonal"
            >
              请先停用仿真或断开实机，再修改参数。
            </v-alert>

            <div v-if="parameterLoading" class="loading-state">
              <v-progress-circular indeterminate color="primary" size="28" />
            </div>

            <v-form v-else v-model="parameterFormValid" class="parameter-form">
              <section class="parameter-section">
                <div class="parameter-title">相机零位</div>
                <div class="field-grid field-grid--two">
                  <v-text-field
                    v-model.number="parameters.kinect_height"
                    label="相机高度 (kinect_height)"
                    suffix="m"
                    type="number"
                    step="0.01"
                    :rules="[numberBetween(0, 1.7)]"
                  />
                  <v-text-field
                    v-model.number="parameters.kinect_pitch"
                    label="相机俯仰角 (kinect_pitch)"
                    suffix="rad"
                    type="number"
                    step="0.01"
                    :rules="[numberBetween(-1.57, 1.57)]"
                  />
                </div>
              </section>

              <section class="parameter-section">
                <div class="parameter-title">真机相机安装位姿</div>
                <div class="field-grid field-grid--three">
                  <v-text-field
                    v-model.number="parameters.camera_x"
                    label="前后位置 (camera_mount.x)"
                    suffix="m"
                    type="number"
                    step="0.001"
                    :rules="[numberBetween(-2, 2)]"
                  />
                  <v-text-field
                    v-model.number="parameters.camera_y"
                    label="左右位置 (camera_mount.y)"
                    suffix="m"
                    type="number"
                    step="0.001"
                    :rules="[numberBetween(-2, 2)]"
                  />
                  <v-text-field
                    v-model.number="parameters.camera_z"
                    label="上下位置 (camera_mount.z)"
                    suffix="m"
                    type="number"
                    step="0.001"
                    :rules="[numberBetween(-2, 2)]"
                  />
                </div>
              </section>

              <section class="parameter-section">
                <div class="parameter-title">抓取补偿</div>
                <div class="field-grid field-grid--two">
                  <v-text-field
                    v-model.number="parameters.grab_y_offset"
                    label="横向补偿 (grab_y_offset)"
                    suffix="m"
                    type="number"
                    step="0.001"
                    :rules="[numberBetween(-1, 1)]"
                  />
                  <v-text-field
                    v-model.number="parameters.grab_lift_offset"
                    label="抬升补偿 (grab_lift_offset)"
                    suffix="m"
                    type="number"
                    step="0.001"
                    :rules="[numberBetween(-1, 1)]"
                  />
                  <v-text-field
                    v-model.number="parameters.grab_forward_offset"
                    label="前向补偿 (grab_forward_offset)"
                    suffix="m"
                    type="number"
                    step="0.001"
                    :rules="[numberBetween(-1, 1)]"
                  />
                  <v-text-field
                    v-model.number="parameters.grab_gripper_value"
                    label="默认夹爪闭合间距 (grab_gripper_value)"
                    suffix="m"
                    type="number"
                    step="0.001"
                    :rules="[numberBetween(0, 0.2)]"
                  />
                  <v-text-field
                    v-model.number="parameters.grab_hand_up_wait"
                    label="抬臂稳定等待时间 (grab_hand_up_wait)"
                    suffix="s"
                    type="number"
                    step="0.1"
                    :rules="[numberBetween(0, 60)]"
                  />
                </div>
              </section>
            </v-form>
          </v-window-item>
        </v-window>
      </v-card-text>

      <v-divider />

      <v-card-actions>
        <v-btn
          v-if="tab === 'robot'"
          color="secondary"
          prepend-icon="mdi-restore"
          variant="text"
          :disabled="!canEditParameters"
          @click="restoreDialogOpen = true"
        >
          恢复默认配置
        </v-btn>
        <v-spacer />
        <v-btn variant="text" @click="open = false">关闭</v-btn>
        <v-btn v-if="tab === 'connection'" color="primary" variant="flat" @click="saveConnection">保存连接配置</v-btn>
        <v-btn
          v-else
          color="primary"
          variant="flat"
          prepend-icon="mdi-content-save-outline"
          :loading="frontendStore.busy"
          :disabled="!canEditParameters || !parameterFormValid || !parameterLoaded"
          @click="saveParameters"
        >
          保存参数
        </v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>

  <v-dialog v-model="restoreDialogOpen" max-width="420">
    <v-card>
      <v-card-title>恢复默认配置</v-card-title>
      <v-card-text>当前机器人参数将恢复为项目预置值。</v-card-text>
      <v-card-actions>
        <v-spacer />
        <v-btn variant="text" @click="restoreDialogOpen = false">取消</v-btn>
        <v-btn color="warning" variant="flat" @click="restoreParameters">确定恢复</v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>
</template>

<script setup lang="ts">
import { computed, reactive, ref, watch } from 'vue'
import type { RobotParameters } from '../ros/frontend'
import { useFrontendStore } from '../stores/frontend'
import { useRosStore } from '../stores/ros'

const props = defineProps<{ modelValue: boolean }>()
const emit = defineEmits<{ (event: 'update:modelValue', value: boolean): void }>()
const rosStore = useRosStore()
const frontendStore = useFrontendStore()

const open = computed({
  get: () => props.modelValue,
  set: (value: boolean) => emit('update:modelValue', value),
})

const tab = ref<'connection' | 'robot'>('connection')
const draftUrl = ref(rosStore.url)
const draftMapFrame = ref(rosStore.mapFrame)
const draftBaseFrame = ref(rosStore.baseFrame)
const draftAutoReconnect = ref(rosStore.autoReconnect)
const parameterLoading = ref(false)
const parameterLoaded = ref(false)
const parameterFormValid = ref(false)
const restoreDialogOpen = ref(false)
const parameters = reactive<RobotParameters>({
  kinect_height: 1.32,
  kinect_pitch: -0.61,
  camera_x: 0.17,
  camera_y: -0.1,
  camera_z: 0,
  grab_y_offset: 0,
  grab_lift_offset: 0,
  grab_forward_offset: 0,
  grab_gripper_value: 0.035,
  grab_hand_up_wait: 4,
})

const canEditParameters = computed(() => (
  rosStore.connected &&
  frontendStore.environmentState !== 'running' &&
  !frontendStore.busy &&
  !parameterLoading.value
))

watch(open, (value) => {
  if (!value) return
  draftUrl.value = rosStore.url
  draftMapFrame.value = rosStore.mapFrame
  draftBaseFrame.value = rosStore.baseFrame
  draftAutoReconnect.value = rosStore.autoReconnect
  if (tab.value === 'robot') void loadParameters()
})

watch(tab, (value) => {
  if (open.value && value === 'robot') void loadParameters()
})

function numberBetween(minimum: number, maximum: number) {
  return (value: unknown) => {
    const number = Number(value)
    return (Number.isFinite(number) && number >= minimum && number <= maximum) ||
      `请输入 ${minimum} 到 ${maximum} 之间的数值`
  }
}

function assignParameters(values: RobotParameters) {
  Object.assign(parameters, values)
  parameterLoaded.value = true
}

async function loadParameters() {
  if (!rosStore.ros || parameterLoading.value) return
  parameterLoading.value = true
  try {
    const values = await frontendStore.loadRobotParameters(rosStore.ros)
    if (values) assignParameters(values)
  } finally {
    parameterLoading.value = false
  }
}

function saveConnection() {
  rosStore.url = draftUrl.value.trim()
  rosStore.mapFrame = draftMapFrame.value.trim() || 'map'
  rosStore.baseFrame = draftBaseFrame.value.trim() || 'base_footprint'
  rosStore.autoReconnect = draftAutoReconnect.value
  rosStore.saveSettings()
  open.value = false
}

async function saveParameters() {
  if (!rosStore.ros) return
  const values = await frontendStore.saveRobotParameters(rosStore.ros, { ...parameters })
  if (values) assignParameters(values)
}

async function restoreParameters() {
  restoreDialogOpen.value = false
  if (!rosStore.ros) return
  const values = await frontendStore.restoreRobotParameters(rosStore.ros)
  if (values) assignParameters(values)
}
</script>

<style scoped>
.settings-dialog {
  max-height: min(88vh, 820px);
}

.settings-content {
  min-height: 360px;
  overflow-y: auto;
}

.settings-form,
.parameter-form {
  display: grid;
  gap: 14px;
  padding-top: 8px;
}

.parameter-section {
  display: grid;
  gap: 10px;
  padding: 12px 0 2px;
  border-bottom: 1px solid #e3e8ee;
}

.parameter-section:last-child {
  border-bottom: 0;
}

.parameter-title {
  color: #263241;
  font-size: 14px;
  font-weight: 700;
}

.field-grid {
  display: grid;
  gap: 10px 12px;
}

.field-grid--two {
  grid-template-columns: repeat(2, minmax(0, 1fr));
}

.field-grid--three {
  grid-template-columns: repeat(3, minmax(0, 1fr));
}

.loading-state {
  display: grid;
  min-height: 300px;
  place-items: center;
}

@media (max-width: 680px) {
  .field-grid--two,
  .field-grid--three {
    grid-template-columns: minmax(0, 1fr);
  }
}
</style>
