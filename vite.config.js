import { defineConfig } from 'vite'
import { svelte } from '@sveltejs/vite-plugin-svelte'

// https://vite.dev/config/
export default defineConfig({
  plugins: [svelte()],
  // Vercel 배포 시에는 base를 '/' 또는 './'로 설정해야 합니다.
  base: '/', 
  build: {
    outDir: 'dist',
  }
})