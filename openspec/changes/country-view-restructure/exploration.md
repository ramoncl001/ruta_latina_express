# Exploration: country-view-restructure

**Date:** 2026-08-18
**Status:** complete
**Phase:** explore

---

## Executive Summary

The site currently has two pricing pages (`/es/precios`, `/en/pricing`) that render **globally-scoped** data — `PricingCatalog` shows `pricing_item` rows (no country FK) and `BoxesCarousel` shows `shipping_box` rows (no country FK). There is no country-view UI today; the `Destinos` component on the home page lists countries with combo counts but does not link to a per-country detail view.

The restructure introduces three new country-scoped tables (`box_offer`, `per_pound_price`, `special_content`) and one non-country-scoped table (`loose_product`), repurposing the existing tables or creating new ones accordingly. The key decision: **`shipping_box` and `pricing_item` are NOT simply extended with `country_id`** — their schemas are sufficiently different from the new entities that new tables should be created, with the old tables potentially retired or kept for backwards compatibility.

---

## Current State

### DB entities (inferred from `src/lib/supabase.ts` + `supabase/schema.sql`)

| TS type / table name | Columns of note | Country-scoped? |
|---|---|---|
| `service` | id, image_url, title, title_en, description, description_en | ❌ |
| `country` | id, name, name_en, flag | N/A (it IS the country) |
| `combo` | id, country_id (FK→country), title, title_en, description, description_en, price, weight, min_days, max_days, products[] | ✅ via `country_id` |
| `contact` | id, name, value | ❌ |
| `page_content` | section, locale, key, value, ord | ❌ (locale column, not country) |
| `pricing_item` | id, title, title_en, description, description_en, price, unit, ord | ❌ (global) |
| `shipping_box` | id, title, title_en, description, description_en, image_url, height_in, width_in, depth_in, price, ord | ❌ (global) |

> **Note:** `supabase/schema.sql` contains an **older Spanish-named schema** (`paises`, `combos`) that is a historical artifact from initial design. The live production tables are the English-named ones (`country`, `combo`) referenced by `supabase.ts`. The SQL file is not auto-applied; it is reference only.

### Existing components rendering pricing/boxes

| Component | Fetcher | Renders | Country filter? |
|---|---|---|---|
| `PricingCatalog.astro` | `fetchPricingItems(locale)` | `pricing_item` — paginated table with Name / Price | ❌ |
| `BoxesCarousel.astro` | `fetchShippingBoxes(locale)` | `shipping_box` — card carousel with dimensions & price | ❌ |

Both are used exclusively on `/es/precios` and `/en/pricing`. Both accept only a `locale` prop — no `countryId`.

### Country selector — existing pattern

`Destinos.astro` (rendered on home page index) fetches **all countries** + **all combos**, computes a count of combos per country, and renders a grid of country cards showing flag, name, and combo count. Cards are non-interactive (no link/click to a country-specific page).

`Combos.astro` fetches **all combos** and renders them in a carousel — no country filter applied, no country picker in UI.

The `combo` table is the **only existing country-scoped entity** and already uses the pattern: `country_id uuid references country(id)` + nested select `country(id, name, name_en, flag)` in the Supabase query.

---

## Entity Mapping: Old → New

### New entity: Box Offers (`box_offer`)

**New entity** — does NOT map cleanly onto `shipping_box`.

| | `shipping_box` | New `box_offer` |
|---|---|---|
| Dimensions | height_in, width_in, depth_in | same fields needed |
| Country | ❌ absent | ✅ `country_id` FK required |
| Title/Description | title, title_en, description, description_en | same i18n pattern |
| image_url | ✅ present | needed? open question |

**Decision: CREATE** new table `box_offer`. Whether to deprecate `shipping_box` or keep it for a global fallback is an open question for the proposal phase.

Proposed columns:
```
box_offer (
  id           uuid primary key default gen_random_uuid(),
  country_id   uuid not null references country(id) on delete restrict,
  title        text not null,
  title_en     text,
  description  text not null default '',
  description_en text,
  height_in    numeric(6,2) not null,
  width_in     numeric(6,2) not null,
  depth_in     numeric(6,2) not null,
  price        numeric(10,2) not null,
  ord          integer not null default 0,
  created_at   timestamptz not null default now()
)
```

---

### New entity: Per-pound Pricing (`per_pound_price`)

**Ambiguous mapping** — `pricing_item` has `unit` (e.g. "kg", "u", "paquete") and no country FK. The new entity adds `country_id` AND a `transport_medium` dimension.

| | `pricing_item` | New `per_pound_price` |
|---|---|---|
| Country | ❌ | ✅ `country_id` FK |
| Unit | `unit` text | implied "lb" (per-pound) |
| Transport medium | ❌ | ✅ `transport_medium` text |
| Title/Description | title, title_en, description, description_en | title/title_en needed? |

**Decision: CREATE** new table `per_pound_price`. The `pricing_item` table is NOT this entity — it lacks both `country_id` and `transport_medium`.

Proposed columns:
```
per_pound_price (
  id                uuid primary key default gen_random_uuid(),
  country_id        uuid not null references country(id) on delete restrict,
  transport_medium  text not null,        -- e.g. "aéreo", "marítimo"
  price             numeric(10,2) not null,
  ord               integer not null default 0,
  created_at        timestamptz not null default now()
)
```

> Open question: Does `transport_medium` need i18n columns (`transport_medium_en`)? Or is it a controlled enum with translation handled in UI? Proposal phase must decide.

---

### New entity: Special Content (`special_content`)

**New entity** — no existing equivalent.

Proposed columns:
```
special_content (
  id             uuid primary key default gen_random_uuid(),
  country_id     uuid not null references country(id) on delete restrict,
  title          text not null,
  title_en       text,
  description    text not null default '',
  description_en text,
  ord            integer not null default 0,
  created_at     timestamptz not null default now()
)
```

---

### New entity: Loose Products (`loose_product`)

**Maps partially onto `pricing_item`** — same structure (name/unit/price, no country), different domain name. The simplest approach is to either:
- **Rename** `pricing_item` → `loose_product` (breaking change to existing fetchers)
- **Create** new `loose_product` table and retire `pricing_item` with a migration

`pricing_item` currently has `title`, `title_en`, `price`, `unit`, `ord`. The new entity needs `name` (same as `title`), `unit`, `price`. There is no `description` needed per the user spec.

**Decision preference: CREATE** new table `loose_product` (cleaner semantics). `PricingCatalog.astro` would be updated to point at `loose_product`. Old `pricing_item` table can be dropped in the migration.

Proposed columns:
```
loose_product (
  id       uuid primary key default gen_random_uuid(),
  name     text not null,
  name_en  text,
  unit     text not null default 'u',
  price    numeric(10,2) not null,
  ord      integer not null default 0,
  created_at timestamptz not null default now()
)
```

---

## Affected Files

| File | Impact |
|---|---|
| `supabase/schema.sql` | Add new table DDL blocks; optionally drop `pricing_item` and `shipping_box` |
| `src/lib/supabase.ts` | Add 4 new TS types + 4 new fetchers; update `fetchPricingItems` → `fetchLooseProducts`; add `fetchBoxOffers(locale, countryId)`, `fetchPerPoundPrices(countryId)`, `fetchSpecialContent(locale, countryId)` |
| `src/components/PricingCatalog.astro` | Update to use `fetchLooseProducts` instead of `fetchPricingItems` |
| `src/components/BoxesCarousel.astro` | Repurpose or replace — currently global; needs `countryId` prop for `box_offer` queries |
| `src/pages/es/precios.astro` | Becomes the "pricing view" (loose products only) OR is restructured — TBD by proposal phase |
| `src/pages/en/pricing.astro` | Same as above |
| `src/components/Destinos.astro` | Country cards likely need to become links to the new country view page |
| `src/components/Nav.astro` | May need a new nav entry for "Países" / "Countries" or the country view |
| NEW: `src/pages/es/[pais].astro` | Dynamic route for the country view (box offers + per-pound pricing + special content) |
| NEW: `src/pages/en/[country].astro` | Same, English locale |
| NEW: `src/components/CountryView.astro` | Container component for the country-specific sections |
| NEW: `src/components/BoxOfferGrid.astro` | Renders `box_offer` rows for a country |
| NEW: `src/components/PerPoundTable.astro` | Renders `per_pound_price` rows for a country |
| NEW: `src/components/SpecialContentBlock.astro` | Renders `special_content` rows for a country |

---

## Country-View UI Approach

The `combo` table already establishes the pattern for country-filtered queries:
```typescript
// Existing pattern in fetchCombos:
.from('combo')
.select('... , country(id, name, name_en, flag)')
.order('id')
```

For the country view, the new fetchers will filter by `country_id`:
```typescript
// Proposed pattern:
.from('box_offer')
.select('id, country_id, title, title_en, ...')
.eq('country_id', countryId)
.order('ord')
```

**Routing approach options:**

1. **Static SSG per country** — `src/pages/es/[pais].astro` with `getStaticPaths()` fetching all countries at build time. Each country gets its own URL (`/es/cuba`, `/es/argentina`, etc.). Fast, SEO-friendly, but requires a rebuild when countries are added.

2. **Static pages per known country** — Create one page file per country manually (e.g. `/es/cuba.astro`). Simpler but doesn't scale.

3. **Server-side rendering (SSR)** — Dynamic routes rendered at request time. Requires Astro SSR adapter.

**Recommendation:** Option 1 (dynamic SSG with `getStaticPaths`). This is the idiomatic Astro approach, is consistent with how this Astro 7 project would handle this, and doesn't require SSR infrastructure.

Country slug derivation: use the country `id` or a `slug` column. The current `country` table has `id` (uuid) + `name`/`name_en` + `flag`. A `slug` column (e.g. "cuba", "argentina") should be added to `country` to enable clean URLs.

---

## i18n Pattern

Existing convention (from `service`, `combo`, `shipping_box`, `pricing_item`):
- Spanish column: `title` (primary, always populated)
- English column: `title_en` (optional, nullable)
- Mapping: `locale === 'en' && row['title_en'] ? row['title_en'] : row['title']`

All new tables should follow this exact pattern:
- `title` / `title_en`
- `description` / `description_en`
- `name` / `name_en` (for `loose_product`)

The `transport_medium` in `per_pound_price` is the only new translatable field that doesn't fit the title/description pattern — proposal phase must decide if it becomes `transport_medium` / `transport_medium_en` or a controlled enum with UI-side translation.

---

## Migration Path

No migrations directory exists. `supabase/schema.sql` is the single schema file (applied manually via Supabase SQL Editor per the comments). Convention: add new `CREATE TABLE` blocks to `schema.sql` and document what to run.

**Order of operations:**
1. Add `slug` column to `country` table (for clean URLs)
2. Create `box_offer` table
3. Create `per_pound_price` table
4. Create `special_content` table
5. Create `loose_product` table
6. Update RLS policies for all new tables (SELECT USING (true) pattern)
7. Migrate data from `pricing_item` → `loose_product` if applicable
8. Drop `pricing_item` and/or `shipping_box` if retiring them
9. Update `src/lib/supabase.ts` types + fetchers
10. Build UI components
11. Build page routes

---

## Approaches Considered

### Approach A: Extend existing tables with `country_id`
Add `country_id` (nullable) to `pricing_item` and `shipping_box`.

- **Pros:** Minimal schema change; existing fetchers get a filter parameter
- **Cons:** Mixes global and country-scoped rows in the same table; nullable FK is semantically messy; `shipping_box` lacks `transport_medium`; forces conditional queries; confusing for content editors
- **Effort:** Low DB, Medium code
- **Verdict:** ❌ Rejected — semantic mismatch, nullable FK antipattern for required scoping

### Approach B: Create all new tables, keep old ones (recommended)
Create `box_offer`, `per_pound_price`, `special_content`, `loose_product` as new tables. Keep `pricing_item` and `shipping_box` alive until a migration/deprecation pass.

- **Pros:** Clean semantics; no data migration risk; old components keep working during transition
- **Cons:** Two tables with overlapping intent temporarily (`pricing_item` + `loose_product`)
- **Effort:** Medium DB, Medium code
- **Verdict:** ✅ Recommended

### Approach C: Create new tables, immediately retire old ones
Same as B but includes data migration + dropping `pricing_item` and `shipping_box` in the same migration.

- **Pros:** Clean final state with no orphaned tables
- **Cons:** Larger atomic change; requires data migration to be correct before deploying UI
- **Effort:** Medium-High DB, Medium code
- **Verdict:** ✅ Valid — but increases risk of deploy-day issues; safer to do in two phases

---

## Recommendation

**Use Approach B**, implemented in two phases:
1. **DB phase:** Create new tables + add `slug` to `country` + RLS policies
2. **UI phase:** New fetchers + country-view pages + update pricing/boxes pages to use new tables

Retire `pricing_item` and `shipping_box` in a follow-up cleanup once the new UI is stable.

---

## Risks

1. **No migration tooling** — Schema changes must be applied manually in Supabase SQL Editor. Risk of schema drift between `schema.sql` and production. Proposal should document exact SQL to run.
2. **Country slug column missing** — Dynamic routes (`/es/cuba`) require a stable, URL-safe slug. Adding `slug` to `country` is a prerequisite before building the country-view pages.
3. **`transport_medium` i18n ambiguity** — If transport mediums are user-visible strings (not UI-controlled labels), they need i18n columns. If they're enums (controlled values), they can be translated in component code. Proposal must resolve.
4. **Page structure for `/es/precios` after restructure** — Currently shows both `PricingCatalog` (loose products) and `BoxesCarousel` (boxes). After the change: loose products stay on this page, but box offers move to the country view. This changes the precios/pricing page significantly. The proposal must decide whether the precios page keeps BoxesCarousel (showing global/legacy boxes), removes it, or redirects.
5. **Destinos cards → country-view links** — The Destinos component currently renders non-interactive country cards. They need to become links to `/es/{slug}` or `/en/{slug}`. This is a UI change to an existing component on the home page — risk of visual regression.
6. **`shipping_box` still used by `BoxesCarousel`** — If BoxesCarousel is updated to use `box_offer`, existing `shipping_box` rows become orphaned until the table is dropped.

---

## Open Questions for Proposal Phase

1. Does `transport_medium` need `transport_medium_en`? Or translate in UI code?
2. Should the country URL slug come from `id` (UUID, ugly) or a new `slug` column (e.g. "cuba", "argentina")? If new column, what is the canonical value set?
3. After restructure, what does `/es/precios` show? Only `loose_product` table? Or also a global `shipping_box` fallback?
4. Are `pricing_item` and `shipping_box` retired in this change or kept alive?
5. Does `box_offer` need an `image_url` column (like `shipping_box`) or just dimensions + price?
6. What is the new nav entry for the country view? Does "Destinos" in the nav link to the home section or to a new country-list page?
7. Should `special_content` support multiple rows per country (an array of blocks) or exactly one row per country?
8. Are there any Supabase RLS differences needed for new tables vs the existing `USING (true)` pattern?

---

## Ready for Proposal

**Yes.** The codebase is well-understood. The entity mapping is clear. The main open questions are scoped design decisions that the proposal phase should resolve before spec writing begins.
