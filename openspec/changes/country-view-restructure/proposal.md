# Proposal: Country View Restructure

**Date:** 2026-08-18
**Status:** proposed
**Phase:** propose

---

## Intent

The site currently has no per-country detail pages. Pricing and shipping box data is global — users can't see what boxes, rates, or special promotions apply to the country they want to send to. `Destinos` shows countries but leads nowhere.

This change introduces a dedicated country view at `/{locale}/[country]` and restructures the DB into country-scoped entities. The business can seed country-specific pricing, box offers, and promotional content per destination without modifying code.

---

## Scope

### In Scope

- **DB:** Add `slug` to `country`; create `box_offer`, `per_pound_price`, `special_content` (country-scoped) and `loose_product` (global); drop `pricing_item` + `shipping_box` in the same migration
- **Data layer:** 4 new TS types + fetchers in `src/lib/supabase.ts`; update pricing fetcher to use `loose_product`
- **Country view:** SSG dynamic routes `src/pages/es/[pais].astro` + `src/pages/en/[country].astro` with `getStaticPaths()` driven by `country.slug`
- **Pricing view update:** `/es/precios` and `/en/pricing` show only `loose_product`; `BoxesCarousel` removed from those pages
- **Destinos:** Country cards become links to `/{locale}/{slug}`
- **i18n:** All new tables follow existing `title` / `title_en` pattern; `transport_medium` / `transport_medium_en` (nullable)
- **RLS:** `SELECT USING (true)` open-read policy on all new tables

### Out of Scope

- No auth or admin CMS UI — business seeds data directly via Supabase dashboard
- No SSR adapter — SSG only; adding a country requires a redeploy
- No data migration of existing `pricing_item` / `shipping_box` rows into new tables — business will re-seed
- No new nav item (country entry point is via Destinos cards)
- No image upload flow for `box_offer.image_url`

---

## Capabilities

### New Capabilities

- `country-view`: Per-country detail page (`/{locale}/{slug}`) showing box offers, per-pound rates, and special content for a single destination
- `per-country-pricing`: Country-scoped box offer and per-pound price data layer

### Modified Capabilities

- `pricing-catalog`: `/precios` / `/pricing` page narrows to loose products only; box offers move to the country view

---

## Resolved Assumptions

> Each assumption below can be corrected before spec work begins.

| # | Decision | Assumption |
|---|---|---|
| A1 | `transport_medium` i18n | Treated as a user-visible localized string. DB stores `transport_medium` (ES, required) + `transport_medium_en` (nullable), consistent with existing `title`/`title_en` pattern. |
| A2 | `country.slug` values | Derived from `country.name` as lowercase ASCII slug (e.g. `cuba`, `argentina`, `chile`, `peru`, `colombia`). All existing countries in the table get a slug. |
| A3 | `/precios` after restructure | Shows **only** `loose_product` in a table. `BoxesCarousel` is removed from the pricing pages — boxes belong to the country view. |
| A4 | Retire old tables | `pricing_item` + `shipping_box` are **dropped in this PR** as the final migration step. Single coherent state. If deploy risk is too high, a follow-up DROP is the fallback — note in risks. |
| A5 | `box_offer.image_url` | Included (nullable) for parity with current `shipping_box`. UI renders it when present, omits gracefully when null. |
| A6 | Nav / entry point | No new nav item. Destinos country cards become `<a href="/{locale}/{slug}">` links. Nav stays minimal. |
| A7 | `special_content` cardinality | Multiple rows per country supported via `ord` column. Rendered as stacked sections on the country view. |
| A8 | RLS | Same `SELECT USING (true)` open-read policy as all existing tables. No write RLS needed (no user mutations). |

---

## Approach

Follow the `combo` pattern: country-scoped tables carry a `country_id uuid references country(id)` FK, fetchers filter by it, and `getStaticPaths()` iterates all countries to generate one page per slug.

Single PR, single migration: create new tables → update UI → drop old tables. Empty state convention: no rows → render "no data" message (existing project convention, no mocks).

---

## Affected Areas

| Area | Impact | Description |
|------|--------|-------------|
| `supabase/schema.sql` | Modified | Add `slug` to `country`; CREATE 4 new tables + RLS; DROP `pricing_item`, `shipping_box` |
| `src/lib/supabase.ts` | Modified | 4 new types + fetchers; replace `fetchPricingItems` → `fetchLooseProducts` |
| `src/components/PricingCatalog.astro` | Modified | Switch data source to `loose_product` via `fetchLooseProducts` |
| `src/components/BoxesCarousel.astro` | Modified/Replaced | Repurposed with `countryId` prop using `box_offer`; removed from pricing pages |
| `src/pages/es/precios.astro` | Modified | Remove `BoxesCarousel`; keep `PricingCatalog` (now loose products) |
| `src/pages/en/pricing.astro` | Modified | Same as above |
| `src/components/Destinos.astro` | Modified | Country cards become links to `/{locale}/{slug}` |
| NEW `src/pages/es/[pais].astro` | New | SSG dynamic route — country view (ES) |
| NEW `src/pages/en/[country].astro` | New | SSG dynamic route — country view (EN) |
| NEW `src/components/CountryView.astro` | New | Container: box offers + per-pound rates + special content |
| NEW `src/components/BoxOfferGrid.astro` | New | Renders `box_offer` rows for a country |
| NEW `src/components/PerPoundTable.astro` | New | Renders `per_pound_price` rows for a country |
| NEW `src/components/SpecialContentBlock.astro` | New | Renders `special_content` rows (stacked, ordered) |

---

## Risks

| Risk | Likelihood | Mitigation |
|------|------------|------------|
| Schema applied manually via Supabase SQL Editor — schema drift risk | Med | Document exact SQL blocks to run in order; include schema.sql as the diff source of truth |
| Dropping `pricing_item` + `shipping_box` in same PR — deploy-day risk if something goes wrong | Med | Alternative: drop in a follow-up PR after verifying new UI is stable in production |
| Destinos cards → links: visual regression on home page | Low | Visual diff the home page before merge; keep markup changes minimal |
| SSG rebuild required when a new country is added | Low | Known constraint; acceptable for current business scale |
| Empty country view (no rows seeded yet) | Low | Project convention: show "no data" message — no mocks, no dummy content |

---

## Rollback Plan

1. Revert the PR — removes new page routes and component changes immediately
2. Restore `pricing_item` + `shipping_box` via Supabase SQL Editor using schema.sql history (if DROP was already applied)
3. Revert `PricingCatalog.astro` to `fetchPricingItems` — pricing pages return to previous state
4. Destinos cards revert to non-interactive (no links) — no user-visible breakage

If DROP is deferred to a follow-up PR, rollback of the main PR has zero DB risk.

---

## Dependencies

- `country.slug` column must be seeded for all existing countries before `getStaticPaths()` can generate routes
- Business must seed at least one `box_offer`, `per_pound_price`, or `special_content` row per country to see non-empty country views

---

## Success Criteria

- [ ] `/{locale}/{slug}` renders a country-specific page with box offers, per-pound rates, and special content sections
- [ ] `/es/precios` and `/en/pricing` show only loose products (no `BoxesCarousel`)
- [ ] Destinos country cards link to the correct country view URL
- [ ] Empty state (no rows for a country) renders a "no data" message — no build errors, no broken pages
- [ ] `pricing_item` and `shipping_box` tables are absent from the final production schema
- [ ] All new tables have RLS SELECT policies; no unauthenticated write access
