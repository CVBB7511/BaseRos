<template>
  <v-dialog v-model="open" max-width="560">
    <v-card>
      <v-card-title>环境配置</v-card-title>
      <v-card-text class="settings-form">
        <v-text-field v-model="draftUrl" label="ROS Bridge 地址" />
        <v-select
          v-model="draftMode"
          :items="modeItems"
          item-title="title"
          item-value="value"
          label="运行模式"
        />
        <v-text-field v-model="draftMapFrame" label="地图坐标系" />
        <v-text-field v-model="draftBaseFrame" label="机器人坐标系" />
        <v-switch v-model="draftAutoReconnect" color="primary" label="自动重连" hide-details />
      </v-card-text>
      <v-card-actions>
        <v-spacer />
        <v-btn variant="text" @click="open = false">取消</v-btn>
        <v-btn color="primary" @click="save">保存</v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>
</template>

<script setup lang="ts">
import { computed, ref, watch } from 'vue'
import { useRosStore } from '../stores/ros'

const props = defineProps<{ modelValue: boolean }>()
const emit = defineEmits<{ (event: 'update:modelValue', value: boolean): void }>()
const rosStore = useRosStore()

const open = computed({
  get: () => props.modelValue,
  set: (value: boolean) => emit('update:modelValue', value),
})

const modeItems = [
  { title: '仿真', value: 'sim' },
  { title: '实机', value: 'real' },
]

const draftUrl = ref(rosStore.url)
const draftMode = ref(rosStore.mode)
const draftMapFrame = ref(rosStore.mapFrame)
const draftBaseFrame = ref(rosStore.baseFrame)
const draftAutoReconnect = ref(rosStore.autoReconnect)

watch(open, (value) => {
  if (value) {
    draftUrl.value = rosStore.url
    draftMode.value = rosStore.mode
    draftMapFrame.value = rosStore.mapFrame
    draftBaseFrame.value = rosStore.baseFrame
    draftAutoReconnect.value = rosStore.autoReconnect
  }
})

function save() {
  rosStore.url = draftUrl.value.trim()
  rosStore.mode = draftMode.value
  rosStore.mapFrame = draftMapFrame.value.trim() || 'map'
  rosStore.baseFrame = draftBaseFrame.value.trim() || 'base_footprint'
  rosStore.autoReconnect = draftAutoReconnect.value
  rosStore.saveSettings()
  open.value = false
}
</script>

<style scoped>
.settings-form {
  display: grid;
  gap: 12px;
}
</style>
