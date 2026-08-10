// @ts-check
import { defineConfig } from 'astro/config';
import tailwindcss from '@tailwindcss/vite';

// Dominio propio: rutalatinaexpress.com (configurado vía public/CNAME).
export default defineConfig({
  site: 'https://rutalatinaexpress.com',
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
