import { svelte } from '@sveltejs/vite-plugin-svelte'
import inertia from 'inertiax-vite'
import { defineConfig } from 'vite'
import RubyPlugin from 'vite-plugin-ruby'
import UnoCSS from 'unocss/vite'
import presetIcons from "@unocss/preset-icons"
import { presetWind4 } from 'unocss'
import { imagetools } from 'vite-imagetools'

export default defineConfig({
  envPrefix: ['VITE_', 'RAILS_ENV'],
  plugins: [
    imagetools(),
    RubyPlugin(),
    UnoCSS({
      presets: [
        presetIcons({
          extraProperties: {
            display: "inline-block",
            "vertical-align": "middle"
          },
        }),
        presetWind4()
      ],
    }),
    inertia({
      ssr: {
        // entry: 'entrypoints/inertia.js',
      },
    }),
    svelte(),
  ]
})
