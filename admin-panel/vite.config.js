import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: {
    allowedHosts: ['bill-admin.onrender.com'],
  },
  preview: {
    allowedHosts: ['bill-admin.onrender.com'],
  },
})
