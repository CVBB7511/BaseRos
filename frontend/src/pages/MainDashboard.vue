<template>
  <div class="dashboard-shell">
    <ProjectTopBar @open-settings="settingsOpen = true" />

    <main class="workspace">
      <aside class="left-panel">
        <RosConnectionPanel @open-settings="settingsOpen = true" />
        <section class="info-block">
          <div class="section-title">地图信息</div>
          <div class="kv">
            <span>状态</span>
            <strong>{{ mapStore.grid ? '已接收' : '等待中' }}</strong>
          </div>
          <div class="kv">
            <span>尺寸</span>
            <strong>{{ mapStore.mapSummary }}</strong>
          </div>
          <div class="kv">
            <span>路径点</span>
            <strong>{{ mapStore.pathCount }}</strong>
          </div>
          <div class="kv">
            <span>机器人</span>
            <strong>{{ robotLabel }}</strong>
          </div>
          <div class="kv">
            <span>更新</span>
            <strong>{{ lastMapLabel }}</strong>
          </div>
        </section>
      </aside>

      <section class="map-area">
        <MapCanvas />
      </section>

      <aside class="right-panel">
        <v-tabs v-model="mode" density="compact" grow>
          <v-tab value="mapping">建图</v-tab>
          <v-tab value="navigation">导航</v-tab>
        </v-tabs>
        <MappingPanel v-if="mode === 'mapping'" />
        <NavigationPanel v-else />
      </aside>
    </main>

    <StatusFooter />
    <EnvironmentSettingsDialog v-model="settingsOpen" />
  </div>
</template>

<script setup lang="ts">
import { computed, onBeforeUnmount, ref, watch } from 'vue'
import EnvironmentSettingsDialog from '../components/EnvironmentSettingsDialog.vue'
import MapCanvas from '../components/MapCanvas.vue'
import MappingPanel from '../components/MappingPanel.vue'
import NavigationPanel from '../components/NavigationPanel.vue'
import ProjectTopBar from '../components/ProjectTopBar.vue'
import RosConnectionPanel from '../components/RosConnectionPanel.vue'
import StatusFooter from '../components/StatusFooter.vue'
import { useMapStore } from '../stores/map'
import { useNavigationStore } from '../stores/navigation'
import { useRosStore } from '../stores/ros'
import type { AppMode } from '../ros/types'

const rosStore = useRosStore()
const mapStore = useMapStore()
const navigationStore = useNavigationStore()
const settingsOpen = ref(false)
const mode = ref<AppMode>('mapping')

watch(
  () => rosStore.ros,
  (ros) => {
    mapStore.detach()
    navigationStore.detach()
    if (ros && rosStore.connected) {
      attachMapStore()
      navigationStore.attach(ros)
    }
  },
)

watch(
  () => rosStore.status,
  (status) => {
    if (status === 'connected' && rosStore.ros) {
      attachMapStore()
      navigationStore.attach(rosStore.ros)
    }
    if (status === 'disconnected') {
      mapStore.detach()
      navigationStore.detach()
    }
  },
)

watch(
  () => [rosStore.mapFrame, rosStore.baseFrame],
  () => {
    if (rosStore.ros && rosStore.connected) {
      attachMapStore()
    }
  },
)

function attachMapStore() {
  if (rosStore.ros) {
    mapStore.attach(rosStore.ros, rosStore.mapFrame, rosStore.baseFrame)
  }
}

const lastMapLabel = computed(() => {
  if (!mapStore.lastMapAt) {
    return '-'
  }
  return new Date(mapStore.lastMapAt).toLocaleTimeString()
})

const robotLabel = computed(() => {
  const pose = mapStore.robotPose
  if (!pose) {
    return '未定位'
  }
  return `${pose.position.x.toFixed(2)}, ${pose.position.y.toFixed(2)}`
})

onBeforeUnmount(() => {
  mapStore.detach()
  navigationStore.detach()
})
</script>

<style scoped>
.dashboard-shell {
  display: grid;
  grid-template-rows: 56px 1fr 34px;
  width: 100vw;
  height: 100vh;
  min-width: 960px;
  overflow: hidden;
  background: #eef2f5;
}

.workspace {
  display: grid;
  grid-template-columns: 280px minmax(460px, 1fr) 340px;
  gap: 12px;
  min-height: 0;
  padding: 12px;
}

.left-panel,
.right-panel {
  display: flex;
  min-height: 0;
  flex-direction: column;
  gap: 12px;
}

.map-area {
  min-width: 0;
  min-height: 0;
  overflow: hidden;
  border: 1px solid #cad3dc;
  background: #f8fafc;
}

.info-block {
  padding: 14px;
  border: 1px solid #d6dde5;
  background: #ffffff;
}

.section-title {
  margin-bottom: 12px;
  color: #263241;
  font-size: 15px;
  font-weight: 700;
}

.kv {
  display: flex;
  justify-content: space-between;
  gap: 12px;
  padding: 7px 0;
  border-bottom: 1px solid #edf1f5;
  color: #566579;
  font-size: 13px;
}

.kv:last-child {
  border-bottom: 0;
}

.kv strong {
  color: #1f2a37;
  font-weight: 650;
  text-align: right;
}

@media (max-width: 1100px) {
  .dashboard-shell {
    min-width: 0;
    overflow: auto;
  }

  .workspace {
    grid-template-columns: 1fr;
    grid-template-rows: auto minmax(420px, 1fr) auto;
  }
}
</style>
