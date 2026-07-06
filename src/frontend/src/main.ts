import '@mdi/font/css/materialdesignicons.css'
import 'roboto-fontface/css/roboto/roboto-fontface.css'
import './styles/main.scss'

import { createPinia } from 'pinia'
import { createApp } from 'vue'
import App from './App.vue'
import { vuetify } from './plugins/vuetify'

createApp(App)
  .use(createPinia())
  .use(vuetify)
  .mount('#app')
