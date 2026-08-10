# Tasks: supabase-content-binding

## Review Workload Forecast
- Estimated changed lines: ~500
- 400-line budget risk: Medium
- Chained PRs recommended: No
- Decision needed before apply: No

## Phase 1 — Rewrite `src/lib/supabase.ts`
- [x] 1.1 Add new types: `Service`, `Country`, `Combo`, `ComboWithCountry`, `Contact`
- [x] 1.2 Add new mocks: `SERVICES_MOCK`, `COUNTRIES_MOCK`, `COMBOS_MOCK` (new shape), `CONTACTS_MOCK`
- [x] 1.3 Add fetchers: `fetchServices`, `fetchCountries`, `fetchCombos` (with join), `fetchContacts` (returns Map)
- [x] 1.4 Remove old types `Pais`, `Combo` (old shape) and mocks `PAISES_MOCK`, `COMBOS_MOCK` (old shape)
- [x] 1.5 Remove old fetchers `fetchPaises`, `fetchCombos` (old)

## Phase 2 — `Servicios.astro`
- [x] 2.1 Frontmatter: await `fetchServices()`
- [x] 2.2 Remove hardcoded `servicios` array
- [x] 2.3 Render: placeholder box (rosa + first letter) when `image_url` is `#` or empty, else `<img>`

## Phase 3 — `Destinos.astro`
- [x] 3.1 Frontmatter: `Promise.all([fetchCountries(), fetchCombos()])`
- [x] 3.2 Compute `combosByCountryId` map for count
- [x] 3.3 Render card: flag + name + combo count
- [x] 3.4 Remove client-side `<script>` block
- [x] 3.5 Remove `tiempo_entrega`, `descripcion`, `destacado` from template

## Phase 4 — `Combos.astro`
- [x] 4.1 Frontmatter: await `fetchCombos()`
- [x] 4.2 Render server-side grid using `ComboWithCountry` shape
- [x] 4.3 Remove "Más elegido" badge and featured styling
- [x] 4.4 Show delivery window as `${min_days}-${max_days} días`
- [x] 4.5 Remove entire `<script>` block (client-side fetch)

## Phase 5 — Contact wiring
- [x] 5.1 `index.astro`: fetch contacts once, pass as prop to Footer + CTA
- [x] 5.2 `Footer.astro`: accept `contacts` prop, wire phone/email/whatsapp/instagram links
- [x] 5.3 `CTA.astro`: accept `contacts` prop, wire WhatsApp + email CTAs
- [x] 5.4 Remove all `TODO(slice-2)` comments in Footer and CTA

## Phase 6 — CómoFunciona carousel
- [x] 6.1 Rewrite to fullscreen carousel (100vw × calc(100vh - 4rem) per slide)
- [x] 6.2 4 hardcoded steps (neutral Spanish, no voseo)
- [x] 6.3 Prev/next buttons with chevron SVG icons + aria-labels
- [x] 6.4 Keyboard support (ArrowLeft/ArrowRight, IntersectionObserver guard)
- [x] 6.5 Touch swipe (touchstart/touchend delta > 40px)
- [x] 6.6 Progress dots (role=tab, aria-selected, active = --color-pink)
- [x] 6.7 prefers-reduced-motion: disable transition
- [x] 6.8 No external carousel library

## Phase 7 — Cleanup + verification
- [x] 7.1 Grep for old references (paises_publicos, combos_publicos, PAISES_MOCK, Pais)
- [x] 7.2 Confirm `TODO(slice-2)` in Footer/CTA resolved (QuienesSomos photo TODO is out of scope)
- [x] 7.3 `astro build` exits 0
