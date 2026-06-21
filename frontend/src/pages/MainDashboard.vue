<template>
  <div class="dashboard-shell">
    <ProjectTopBar @open-settings="settingsOpen = true" />

    <main class="workspace">
      <aside class="left-panel">
        <RosConnectionPanel @open-settings="settingsOpen = true" />
        <section class="info-block">
          <div class="section-title">设备流程</div>
          <div class="kv">
            <span>运行模式</span>
            <strong>{{ frontendStore.modeLabel }}</strong>
          </div>
          <div class="kv">
            <span>ROS Bridge</span>
            <strong>{{ rosStore.status }}</strong>
          </div>
          <div class="kv">
            <span>建图流程</span>
            <strong>{{ frontendStore.mappingRunning ? '运行中' : '未运行' }}</strong>
          </div>
          <div class="kv">
            <span>定位/标定</span>
            <strong>{{ frontendStore.executeRunning ? 'RViz 已启动' : '等待导入地图' }}</strong>
          </div>
          <div class="kv">
            <span>地图文件</span>
            <strong>{{ frontendStore.lastPath || '-' }}</strong>
          </div>
        </section>
        <div class="teleop-slot">
          <BaseTeleopPanel
            :ros="rosStore.ros"
            :connected="rosStore.connected"
            :locked="frontendStore.palletizingActive"
          />
        </div>
      </aside>

      <section class="rviz-area">
        <CameraPanel :ros="rosStore.ros" :connected="rosStore.connected" />
      </section>

      <aside class="right-panel">
        <MappingPanel />
      </aside>
    </main>

    <StatusFooter />
    <EnvironmentSettingsDialog v-model="settingsOpen" />
  </div>
</template>

<script setup lang="ts">
import { ref, watch } from 'vue'
import EnvironmentSettingsDialog from '../components/EnvironmentSettingsDialog.vue'
import CameraPanel from '../components/CameraPanel.vue'
import BaseTeleopPanel from '../components/BaseTeleopPanel.vue'
import MappingPanel from '../components/MappingPanel.vue'
import ProjectTopBar from '../components/ProjectTopBar.vue'
import RosConnectionPanel from '../components/RosConnectionPanel.vue'
import StatusFooter from '../components/StatusFooter.vue'
import { useFrontendStore } from '../stores/frontend'
import { useRosStore } from '../stores/ros'

const rosStore = useRosStore()
const frontendStore = useFrontendStore()
const settingsOpen = ref(false)

watch(
  () => rosStore.status,
  (status) => {
    if (status === 'connected' && rosStore.ros) {
      frontendStore.refreshStatus(rosStore.ros)
      frontendStore.subscribePalletizingStats(rosStore.ros)
    } else {
      frontendStore.unsubscribePalletizingStats()
    }
  },
)
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
  grid-template-columns: 280px minmax(460px, 1fr) 430px;
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

.rviz-area {
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

.teleop-slot {
  margin-top: auto;
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
  overflow-wrap: anywhere;
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
