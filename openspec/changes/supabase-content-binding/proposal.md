# Proposal: supabase-content-binding

## Intent
Replace old Spanish-column mock/Supabase queries with English-schema queries against real Supabase tables (`service`, `country`, `combo`, `contact`). Build all data at build time (SSG). Fall back to mocks when env vars are absent.

## Schema (authoritative — do not add columns)
```sql
public.service  (id, created_at, image_url, title, description)
public.country  (id, created_at, name, flag)
public.combo    (id, created_at, country_id → country.id, title, description,
                 price double, weight real, min_days bigint, max_days bigint, products ARRAY)
public.contact  (id, created_at, name, value)
```

## Key decisions
- All fetchers at BUILD TIME — no client-side fetch, no `<script>` hydration
- Mock fallback required (user has no Supabase env vars yet)
- `contact` fetched once in `index.astro`, passed as prop to Footer + CTA
- No "Más elegido" badge or featured styling in Combos
- Destinos shows flag + name + combo count (computed from combos query)
- ComoFunciona becomes fullscreen carousel — vanilla JS, no library
- `ComoFunciona` steps are hardcoded (content does not come from Supabase)

## Out of scope (slice 2)
- Hero copy
- QuienesSomos copy + photo
- CTA copy
- Step images in carousel
