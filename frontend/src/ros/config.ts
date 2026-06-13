export const defaultRosbridgeUrl = import.meta.env.VITE_ROSBRIDGE_URL || 'ws://localhost:9090'
export const defaultMapFrame = import.meta.env.VITE_DEFAULT_MAP_FRAME || 'map'
export const defaultBaseFrame = import.meta.env.VITE_DEFAULT_BASE_FRAME || 'base_footprint'
export const defaultMapFitScale = Number(import.meta.env.VITE_MAP_FIT_SCALE || '1.8')
