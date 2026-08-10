# Ruta Latina Express

Landing en Astro + Tailwind v4 + Supabase para una agencia de envíos a Cuba y Sudamérica.
Deploy en GitHub Pages, catálogo editable en runtime desde Supabase.

## Stack

- **Astro** (SSG estático)
- **Tailwind CSS v4** (paleta blanco perla / rose gold / dorado champán / grafito)
- **Supabase JS** (fetch runtime del catálogo con anon key pública)
- **GitHub Pages** vía GitHub Actions

## Estructura

```
src/
├── components/       # Nav, Hero, Servicios, Combos, ComoFunciona, CTA, Footer
├── layouts/          # Layout base con SEO
├── lib/supabase.ts   # Cliente Supabase + tipos + fallback mock
├── pages/index.astro # Landing
└── styles/global.css # Paleta y tipografía
supabase/schema.sql   # Schema + seed + RLS
.github/workflows/    # Deploy a GH Pages
```

## Desarrollo

```bash
npm run dev
```

Sin variables de entorno, la página muestra el **catálogo mock** (3 combos de ejemplo).

## Conectar Supabase

1. Crear proyecto en [supabase.com](https://supabase.com).
2. En el SQL Editor, ejecutar `supabase/schema.sql`.
3. Copiar `Project URL` y `anon public key` (Settings → API).
4. Crear `.env.local` con:
   ```
   PUBLIC_SUPABASE_URL=https://xxxxx.supabase.co
   PUBLIC_SUPABASE_ANON_KEY=eyJ...
   ```
5. `npm run dev` — el catálogo ahora hidrata desde Supabase.

**Seguridad**: la anon key es pública. RLS con policy `SELECT` sobre `combos` protege los datos. Nunca uses la `service_role` key en el frontend.

## Deploy a GitHub Pages (dominio: rutalatinaexpress.com)

1. Push a GitHub en el repo `ruta-latina-express`.
2. En **Settings → Pages**: source = **GitHub Actions**.
3. En **Settings → Pages → Custom domain**: `rutalatinaexpress.com` + activar **Enforce HTTPS**.
4. En tu proveedor de DNS de `rutalatinaexpress.com`, apuntar:
   - `A` root → `185.199.108.153`, `185.199.109.153`, `185.199.110.153`, `185.199.111.153`
   - `CNAME www` → `TU-USUARIO.github.io`
5. En **Settings → Secrets and variables → Actions**, agregar:
   - `PUBLIC_SUPABASE_URL`
   - `PUBLIC_SUPABASE_ANON_KEY`
6. Push a `main` → workflow builds y publica.

El archivo `public/CNAME` ya tiene `rutalatinaexpress.com`.

## Editar catálogo

Sin código: Supabase Dashboard → Table Editor.
- Tabla `paises` → agregar destinos, cambiar tiempos, marcar destacado, activar/desactivar.
- Tabla `combos` → agregar combos, precios, contenido. Se enlazan al país por `pais_id`.

Cambios reflejados **al instante** en la web (runtime fetch).

## Paleta

| Nombre        | Uso                              | Hex     |
| ------------- | -------------------------------- | ------- |
| Perla         | Background principal             | #FBF8F5 |
| Crema         | Secciones alternas               | #F5EFE7 |
| Rosa palo     | Acentos suaves, bordes           | #F2D9CE |
| Rose gold     | CTA hover, badges                | #B87560 |
| Dorado champán| Detalles premium, gradientes     | #C9A44C |
| Grafito       | Tipografía, dark elements        | #2B2726 |
