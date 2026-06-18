import { aliases, mdi } from 'vuetify/iconsets/mdi'
import { createVuetify } from 'vuetify'
import 'vuetify/styles'

export const vuetify = createVuetify({
  defaults: {
    VBtn: {
      rounded: 'sm',
      variant: 'flat',
    },
    VCard: {
      rounded: 'sm',
      elevation: 0,
    },
    VTextField: {
      density: 'compact',
      variant: 'outlined',
    },
    VSelect: {
      density: 'compact',
      variant: 'outlined',
    },
  },
  icons: {
    defaultSet: 'mdi',
    aliases,
    sets: { mdi },
  },
  theme: {
    defaultTheme: 'baseRosLight',
    themes: {
      baseRosLight: {
        dark: false,
        colors: {
          background: '#eef2f5',
          surface: '#ffffff',
          primary: '#256f78',
          secondary: '#44556b',
          accent: '#d8793a',
          error: '#b42318',
          warning: '#b54708',
          info: '#256f78',
          success: '#287d3c',
        },
      },
    },
  },
})
