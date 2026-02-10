import { defineConfig } from 'vite'
import { svelte } from '@sveltejs/vite-plugin-svelte'

// https://vite.dev/config/
export default defineConfig({
  plugins: [svelte()],
  base: '/AID-MANI-Hackerthon/', // GitHub Pages용 base 경로
  build: {
    outDir: 'dist',
  }
})
