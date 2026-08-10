# Proposal: mega-i18n-content-migration

## Intent
Add Astro native i18n (ES/EN) with URL prefixes, migrate hardcoded page copy to Supabase `page_content` table, add EN columns to existing tables, and connect all components to locale-aware fetchers.

## Scope
- `astro.config.mjs` — i18n block
- `src/lib/supabase.ts` — locale-aware fetchers + `fetchPageContent`
- `src/pages/index.astro` — client-side redirect
- `src/pages/es/index.astro` + `src/pages/en/index.astro` — locale pages
- `src/layouts/Layout.astro` — html lang + hreflang alternates
- `src/components/Hero.astro`, `QuienesSomos.astro`, `CTA.astro`, `ComoFunciona.astro` — page_content driven
- `src/components/Nav.astro`, `Footer.astro` — hardcoded dict i18n
- `src/components/Servicios.astro`, `Combos.astro`, `Destinos.astro` — locale prop
- `supabase-migration.sql` (repo root) — schema + data migration for user to run

## Approach
- Astro native i18n, `prefixDefaultLocale: true`
- Columnas por idioma in DB (`title_en`, `description_en`, `name_en`)
- `page_content` table for Hero/QuienesSomos/CTA/ComoFunciona copy
- Component fallback maps mirror DB content (graceful degradation before SQL is run)
- No external i18n library
- No visible language selector
