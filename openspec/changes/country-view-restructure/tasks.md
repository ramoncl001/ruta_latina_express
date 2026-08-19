# Tasks: country-view-restructure

## Review Workload Forecast

| Field | Value |
|-------|-------|
| Estimated changed lines | ~900–1 100 (additions + deletions) |
| 400-line budget risk | High (exceeds standard 400-line threshold) |
| Chained PRs recommended | No — delivery strategy is `single-pr-default`; user-approved budget is 1 500 lines |
| Suggested split | Single PR (size:exception required at review) |
| Delivery strategy | single-pr-default |
| Chain strategy | size-exception |

Decision needed before apply: No
Chained PRs recommended: No
Chain strategy: size-exception
400-line budget risk: High

> The estimate falls within the user-approved 1 500-line budget. A `size:exception` label is needed when opening the PR so reviewers are aware of the scope.

### Suggested Work Units

| Unit | Goal | Likely PR | Focused test command | Runtime harness | Rollback boundary |
|------|------|-----------|----------------------|-----------------|-------------------|
| WU-1 | DB migration (Blocks 1–6) | PR 1 (commit 1) | SQL: `SELECT id, name, slug FROM public.country WHERE slug IS NULL;` → 0 rows | Supabase SQL Editor; verify new tables + RLS via `pg_policies` | Revert: drop new tables + slug column; no code deployed yet |
| WU-2 | Data layer — types + fetchers + schema.sql | PR 1 (commit 2) | `astro build` — must exit 0 with no TS errors | `astro build` | Delete new types/fetchers from `supabase.ts`; schema.sql revert |
| WU-3 | Country view — new pages + 4 components | PR 1 (commit 3) | `astro build` — verify `dist/es/cuba/index.html` exists | `astro preview` → `/es/cuba`, `/en/cuba` | Delete 4 new components + 2 new page files |
| WU-4 | Pricing view update + Destinos links | PR 1 (commit 4) | `astro build` + `astro preview` → `/es/precios`, `/en/pricing`, home Destinos links | `astro preview` manual browser | Revert PricingCatalog import + Destinos markup; restore BoxesCarousel usages |
| WU-5 | Cleanup — delete BoxesCarousel + gated DROP | PR 1 (commit 5) | `astro build` exits 0 after BoxesCarousel deleted | Manual browser full regression; Block 7 SQL | Only run Block 7 SQL after production verification; file delete is independently revertable |

---

## Phase 1: DB Migration (WU-1)

Satisfies: RLS Open-Read Policy, Box Offer Data Contract, Per-Pound Price Data Contract, Special Content Data Contract, Pricing Data Source (loose_product), Route Generation (slug prerequisite).

- [x] 1.1 Run Block 1 in Supabase SQL Editor — `ALTER TABLE country ADD COLUMN IF NOT EXISTS slug text`, backfill rows, enforce NOT NULL + UNIQUE constraint.
- [x] 1.2 Verify Block 1: `SELECT id, name, slug FROM public.country WHERE slug IS NULL;` → 0 rows before continuing.
- [x] 1.3 Run Block 2 — `CREATE TABLE IF NOT EXISTS public.box_offer (...)` + index.
- [x] 1.4 Run Block 3 — `CREATE TABLE IF NOT EXISTS public.per_pound_price (...)` + index.
- [x] 1.5 Run Block 4 — `CREATE TABLE IF NOT EXISTS public.special_content (...)` + index.
- [x] 1.6 Run Block 5 — `CREATE TABLE IF NOT EXISTS public.loose_product (...)`.
- [x] 1.7 Run Block 6 — `ENABLE ROW LEVEL SECURITY` + `CREATE POLICY ... FOR SELECT USING (true)` on all 4 new tables.
- [x] 1.8 Verify: run the three SQL verification queries from the design (0 null slugs, column list, RLS policies).

**Commit WU-1** (SQL-only, no source files changed — document verified state in commit message).

---

## Phase 2: Data Layer (WU-2)

Depends on: Phase 1 complete (tables + slug column exist in DB).
Satisfies: Box Offer Data Contract, Per-Pound Price Data Contract, Special Content Data Contract, Pricing Data Source, Locale Column Selection, Route Generation (slug field on Country type).

- [ ] 2.1 In `src/lib/supabase.ts`: add `slug: string` to `Country` type; update `mapCountryRow` to map `slug`; update `fetchCountries` `.select()` to include `slug`.
- [ ] 2.2 Add `BoxOffer` type + `mapBoxOfferRow` mapper (locale-resolved `title`, `description`, `image_url` nullable).
- [ ] 2.3 Add `PerPoundPrice` type + `mapPerPoundPriceRow` mapper (locale-resolved `transport_medium`).
- [ ] 2.4 Add `SpecialContent` type + `mapSpecialContentRow` mapper (locale-resolved `title`, `description`).
- [ ] 2.5 Add `LooseProduct` type + `mapLooseProductRow` mapper (locale-resolved `name`).
- [ ] 2.6 Add `fetchBoxOffers(countryId, locale)` — `.select(...)`, `.eq('country_id', countryId)`, `.order('ord')`; null-guard + logEmpty pattern.
- [ ] 2.7 Add `fetchPerPoundPrices(countryId, locale)` — same pattern.
- [ ] 2.8 Add `fetchSpecialContent(countryId, locale)` — same pattern.
- [ ] 2.9 Add `fetchLooseProducts(locale)` — `.select(...)`, `.order('ord')`; same pattern.
- [ ] 2.10 Add `fetchCountryBySlug(slug, locale)` — `.select('id, name, name_en, flag, slug').eq('slug', slug).single()`; return `null` on error/no data.
- [ ] 2.11 Update `supabase/schema.sql` — append Block 1–6 SQL, Block 7 DROP (commented as gated), remove/replace `pricing_item` and `shipping_box` entries to reflect new authoritative state.
- [ ] 2.12 Run `astro build` — must exit 0 with no TypeScript errors.

**Commit WU-2**: `src/lib/supabase.ts`, `supabase/schema.sql`.

---

## Phase 3: Country View (WU-3)

Depends on: Phase 2 complete (types + fetchers exported).
Satisfies: Route Generation, Parallel Entity Loading, Section Empty State, Locale Column Selection, Box Offer Data Contract, Per-Pound Price Data Contract, Special Content Data Contract.

- [ ] 3.1 Create `src/components/BoxOfferGrid.astro` — props `items: BoxOffer[], locale: Locale`; responsive grid; image renders when `image_url` non-null, SVG placeholder otherwise; empty-state message per locale.
- [ ] 3.2 Create `src/components/PerPoundTable.astro` — props `items: PerPoundPrice[], locale: Locale`; two-column table (transport_medium | price); empty-state message per locale.
- [ ] 3.3 Create `src/components/SpecialContentBlock.astro` — props `items: SpecialContent[], locale: Locale`; stacked cards ordered by `ord`; empty → render nothing (section hidden entirely, no placeholder).
- [ ] 3.4 Create `src/components/CountryView.astro` — props `boxOffers: BoxOffer[], prices: PerPoundPrice[], specialContent: SpecialContent[], country: Country, locale: Locale`; composes `BoxOfferGrid`, `PerPoundTable`, `SpecialContentBlock` in order.
- [ ] 3.5 Create `src/pages/es/[pais].astro` — `getStaticPaths` calls `fetchCountries('es')`, filters non-null slugs, maps to `{ params: { pais: c.slug }, props: { countryId: c.id } }`; page body runs `Promise.all([fetchCountryBySlug, fetchBoxOffers, fetchPerPoundPrices, fetchSpecialContent, fetchContacts])`; renders `CountryView`.
- [ ] 3.6 Create `src/pages/en/[country].astro` — identical to `[pais].astro` with `locale = 'en'` and param key `country`.
- [ ] 3.7 Run `astro build` — verify `dist/es/cuba/index.html` and `dist/en/cuba/index.html` (or equivalent slugs) are generated; build exits 0.
- [ ] 3.8 Run `astro preview` → visit `/es/{slug}` and `/en/{slug}`; confirm empty-state messages render; no console errors.

**Commit WU-3**: 4 new component files + 2 new page files.

---

## Phase 4: Pricing View + Destinos Links (WU-4)

Depends on: Phase 2 complete (`fetchLooseProducts` exported; `Country.slug` on type).
Satisfies: MODIFIED Pricing Data Source (loose_product), REMOVED BoxesCarousel requirement, Destinos card→link.

- [ ] 4.1 In `src/components/PricingCatalog.astro`: replace `fetchPricingItems` import with `fetchLooseProducts`; update internal call; replace `item.title` with `item.name` in the render loop.
- [ ] 4.2 In `src/pages/es/precios.astro`: remove `BoxesCarousel` import and JSX/Astro usage.
- [ ] 4.3 In `src/pages/en/pricing.astro`: remove `BoxesCarousel` import and JSX/Astro usage.
- [ ] 4.4 In `src/components/Destinos.astro`: replace non-interactive `<div>` card with `<a href={`/${locale}/${c.slug}`}>` anchor; add slug guard (render `<div>` when `c.slug` is falsy to avoid broken links).
- [ ] 4.5 Run `astro build` — exits 0; `dist/es/precios/index.html` and `dist/en/pricing/index.html` exist.
- [ ] 4.6 Run `astro preview` → verify `/es/precios` and `/en/pricing` show only the loose products table (no boxes carousel); verify home page Destinos cards are clickable links.

**Commit WU-4**: `PricingCatalog.astro`, `precios.astro`, `pricing.astro`, `Destinos.astro`.

---

## Phase 5: Cleanup + Gated DROP (WU-5)

Depends on: Phases 3 + 4 verified in production.
Satisfies: REMOVED BoxesCarousel requirement (file deletion).
**Risk gate**: Block 7 SQL MUST NOT run until production is verified per the rollout checklist.

- [ ] 5.1 Delete `src/components/BoxesCarousel.astro` (no remaining imports after WU-4).
- [ ] 5.2 Run `astro build` — exits 0 (confirms no dangling imports reference BoxesCarousel).
- [ ] 5.3 **After production deployment and verification**: run Block 7 in Supabase SQL Editor — `DROP TABLE IF EXISTS public.pricing_item CASCADE; DROP TABLE IF EXISTS public.shipping_box CASCADE;`.
- [ ] 5.4 After Block 7: delete `PricingItem` type, `mapPricingItemRow`, `fetchPricingItems`, `ShippingBox` type, `mapShippingBoxRow`, `fetchShippingBoxes` from `src/lib/supabase.ts` (they reference dropped tables).
- [ ] 5.5 Run final `astro build` + `astro preview` full regression — all done-criteria from design must pass.

**Commit WU-5**: `BoxesCarousel.astro` (deleted) + `supabase.ts` dead-code removal.

---

## Done Criteria Checklist

- [ ] `astro build` exits 0 with routes for each country × locale
- [ ] `/es/precios` and `/en/pricing` show only loose products (no boxes carousel)
- [ ] Country view empty state renders without build errors
- [ ] Country view with seeded data renders all three sections correctly
- [ ] Destinos cards are clickable links pointing to `/{locale}/{slug}`
- [ ] No broken TypeScript imports; no console errors in browser
- [ ] Block 7 SQL run after production verification only
