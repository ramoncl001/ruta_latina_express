// @ts-check
import { defineConfig } from 'astro/config';
import tailwindcss from '@tailwindcss/vite';

// Dominio propio: ruta-latina-express.com (configurado vía public/CNAME).
export default defineConfig({
  site: 'https://ruta-latina-express.com',
  base: '/',
  trailingSlash: 'ignore',
  i18n: {
    defaultLocale: 'es',
    locales: ['es', 'en'],
    routing: {
      prefixDefaultLocale: true, // both /es/ and /en/ are explicit; / redirects via JS
    },
  },
  vite: {
    plugins: [tailwindcss()],
  },
});
