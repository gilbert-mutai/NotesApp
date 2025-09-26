// vite.config.js
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  server: {
    proxy: {
      // proxy all /api requests to your backend
      '/api': 'http://localhost:8000',
    },
  },
});
