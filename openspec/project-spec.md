# Project Spec — Ruta Latina Express

**Site**: https://rutalatinaexpress.com  
**Framework**: Astro 7.2.0 + Tailwind CSS 4.3.3 + Supabase  
**Language**: TypeScript  
**Node**: >=22.12.0

## Purpose

Landing page for a Latin America shipping agency. Displays configurable
shipping combos and destination countries, fetched at runtime from Supabase.

## Architecture

- **Pages**: Astro file-based routing (`src/pages/`)
- **Components**: Astro components (`src/components/`)
- **Data layer**: `src/lib/supabase.ts` — runtime Supabase client with mock fallback
- **Styling**: Tailwind CSS v4 via Vite plugin (no `tailwind.config.*` file)
- **Schema**: `supabase/schema.sql`

## Key Tables (Supabase)

| Table | Purpose |
|---|---|
| `combos` | Shipping packages with price, weight, destinations |
| `paises` | Configurable destination countries (flag, delivery time, order) |

Views: `combos_publicos`, `paises_publicos` (joined, public-safe reads)

## i18n

Dual language: `es` (neutral Spanish) and `en` (English).  
No regional variants in content or UI copy.

## Color Palette

Pearl / rose-gold / champagne gold / graphite. Rosa used for keyword highlights.

## Testing

No test runner configured. `strict_tdd: false`.  
To enable: add `vitest` (unit) and/or `@playwright/test` (E2E).

## Change Log

| Date | Change ID | Summary |
|---|---|---|
| 2026-08-09 | — | SDD initialized |
