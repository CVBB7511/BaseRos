export const defaultRosbridgeUrl = import.meta.env.VITE_ROSBRIDGE_URL || 'ws://localhost:9090'
export const defaultMapFrame = import.meta.env.VITE_DEFAULT_MAP_FRAME || 'map'
export const defaultBaseFrame = import.meta.env.VITE_DEFAULT_BASE_FRAME || 'base_footprint'
export const defaultMapFitScale = Number(import.meta.env.VITE_MAP_FIT_SCALE || '1.8')
export const defaultCameraTopic = import.meta.env.VITE_DEFAULT_CAMERA_TOPIC || '/kinect2/qhd/image_color_rect/compressed'
export const defaultCameraFps = Number(import.meta.env.VITE_DEFAULT_CAMERA_FPS || '8')
