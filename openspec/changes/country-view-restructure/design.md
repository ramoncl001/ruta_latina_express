# Design: country-view-restructure

**Date:** 2026-08-18
**Status:** draft
**Phase:** design

---

## Technical Approach

Follow the `combo` table pattern throughout: country-scoped tables carry `country_id uuid references country(id)`, fetchers accept `(countryId, locale)`, and `getStaticPaths()` iterates `country.slug` to emit one route per destination. Single PR: create new tables → update data layer → update/create UI → drop old tables. No migration tooling — SQL blocks run manually in the Supabase SQL Editor in the exact order specified below.

> **Note on schema.sql vs live DB**: `supabase/schema.sql` contains an older Spanish schema (`paises`, `combos`). The live Supabase DB uses the English tables referenced by `supabase.ts` (`country`, `combo`, `pricing_item`, `shipping_box`, etc.). **`supabase/schema.sql` will be updated in this change** to reflect the new authoritative state.

---

## Architecture Decisions

| # | Decision | Choice | Alternatives | Rationale |
|---|----------|--------|--------------|-----------|
| D1 | Country type extended with `slug` | Add `slug text unique` to `country` in DB; add `slug` field to `Country` TS type | Derive slug in frontend from `name` | Slug must be URL-safe and stable; deriving at runtime risks accent/casing bugs; DB column is the source of truth |
| D2 | `BoxesCarousel` reuse vs new `BoxOfferGrid` | New `BoxOfferGrid.astro` per proposal; `BoxesCarousel` stays as dead code to be deleted | Repurpose `BoxesCarousel` with `countryId` prop | `BoxesCarousel` fetches its own data internally; the country view needs data fetched at page level via `Promise.all`; component prop injection would require a refactor larger than creating a new component |
| D3 | `PricingCatalog` reuse for loose products | Pass data via prop `items` instead of self-fetching; OR: update `PricingCatalog` to call `fetchLooseProducts` internally | Keep `fetchPricingItems` and rename table | `PricingCatalog` today self-fetches from `pricing_item`; simplest change is to redirect the internal call to `fetchLooseProducts`. No prop API change needed — both `PricingItem` and `LooseProduct` share the same field shape. |
| D4 | `fetchCountries` slug field | Add `slug` to the existing `.select()` in `fetchCountries`; `Country` type gets `slug: string` | Separate `fetchCountryBySlug` only | `getStaticPaths()` needs slug for ALL countries; adding it to the existing fetcher is one-line change |
| D5 | Page-level parallel fetch | `Promise.all([fetchBoxOffers, fetchPerPoundPrices, fetchSpecialContent])` in each `[pais].astro` / `[country].astro` | Sequential awaits | Mirrors existing `Destinos.astro` pattern; all three are independent queries |
| D6 | DROP timing | Same PR, final SQL block | Separate follow-up PR | Proposal A4: single coherent state. Risk is documented in rollback plan. |

---

## Data Flow

```
Build time (getStaticPaths)
  fetchCountries(locale) ──→ countries[].slug ──→ params[] ──→ one page per slug

Request time (SSG page, each /{locale}/{slug})
  slug (param) ──→ fetchCountryBySlug(slug, locale) ──→ country.id
      │
      └─ Promise.all([
           fetchBoxOffers(country.id, locale),
           fetchPerPoundPrices(country.id, locale),
           fetchSpecialContent(country.id, locale),
         ])
           │
           └─ CountryView.astro
                ├─ BoxOfferGrid.astro      (boxOffers[])
                ├─ PerPoundTable.astro     (prices[])
                └─ SpecialContentBlock.astro (content[])

/es/precios, /en/pricing
  fetchLooseProducts(locale) ──→ PricingCatalog.astro (same component, repointed)
```

---

## DB Migration SQL

Run the following blocks **in order** in the Supabase SQL Editor. Each block is idempotent where possible. `supabase/schema.sql` will be updated to reflect these additions.

### Block 1 — Add slug to country

```sql
-- 1a. Add column (nullable first to allow backfill)
ALTER TABLE public.country ADD COLUMN IF NOT EXISTS slug text;

-- 1b. Backfill existing rows
UPDATE public.country SET slug = 'cuba'      WHERE name = 'Cuba'      AND slug IS NULL;
UPDATE public.country SET slug = 'argentina' WHERE name = 'Argentina' AND slug IS NULL;
UPDATE public.country SET slug = 'chile'     WHERE name = 'Chile'     AND slug IS NULL;
UPDATE public.country SET slug = 'peru'      WHERE name = 'Peru'      AND (name ILIKE 'per%') AND slug IS NULL;
UPDATE public.country SET slug = 'colombia'  WHERE name = 'Colombia'  AND slug IS NULL;
-- Add further UPDATE rows for any other countries in your table.

-- 1c. Enforce NOT NULL + UNIQUE once all rows are filled
ALTER TABLE public.country ALTER COLUMN slug SET NOT NULL;
ALTER TABLE public.country ADD CONSTRAINT country_slug_unique UNIQUE (slug);
```

> **Verify before 1c**: `SELECT id, name, slug FROM public.country WHERE slug IS NULL;` must return 0 rows.

### Block 2 — Create box_offer

```sql
CREATE TABLE IF NOT EXISTS public.box_offer (
  id             uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  country_id     uuid        NOT NULL REFERENCES public.country(id) ON DELETE CASCADE,
  title          text        NOT NULL,
  title_en       text,
  description    text        NOT NULL DEFAULT '',
  description_en text,
  image_url      text,
  height_in      numeric(6,2) NOT NULL DEFAULT 0,
  width_in       numeric(6,2) NOT NULL DEFAULT 0,
  depth_in       numeric(6,2) NOT NULL DEFAULT 0,
  price          numeric(10,2) NOT NULL,
  ord            integer     NOT NULL DEFAULT 0,
  created_at     timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS box_offer_country_id_idx ON public.box_offer(country_id);
```

### Block 3 — Create per_pound_price

```sql
CREATE TABLE IF NOT EXISTS public.per_pound_price (
  id                  uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  country_id          uuid        NOT NULL REFERENCES public.country(id) ON DELETE CASCADE,
  transport_medium    text        NOT NULL,
  transport_medium_en text,
  price               numeric(10,2) NOT NULL,
  ord                 integer     NOT NULL DEFAULT 0,
  created_at          timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS per_pound_price_country_id_idx ON public.per_pound_price(country_id);
```

### Block 4 — Create special_content

```sql
CREATE TABLE IF NOT EXISTS public.special_content (
  id             uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  country_id     uuid        NOT NULL REFERENCES public.country(id) ON DELETE CASCADE,
  title          text        NOT NULL,
  title_en       text,
  description    text        NOT NULL DEFAULT '',
  description_en text,
  ord            integer     NOT NULL DEFAULT 0,
  created_at     timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS special_content_country_id_idx ON public.special_content(country_id);
```

### Block 5 — Create loose_product

```sql
CREATE TABLE IF NOT EXISTS public.loose_product (
  id         uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  name       text        NOT NULL,
  name_en    text,
  unit       text        NOT NULL DEFAULT 'u',
  price      numeric(10,2) NOT NULL,
  ord        integer     NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now()
);
```

### Block 6 — Enable RLS + open-read policies on all new tables

```sql
ALTER TABLE public.box_offer       ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.per_pound_price ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.special_content ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.loose_product   ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "box_offer_public_read"       ON public.box_offer;
DROP POLICY IF EXISTS "per_pound_price_public_read" ON public.per_pound_price;
DROP POLICY IF EXISTS "special_content_public_read" ON public.special_content;
DROP POLICY IF EXISTS "loose_product_public_read"   ON public.loose_product;

CREATE POLICY "box_offer_public_read"       ON public.box_offer       FOR SELECT USING (true);
CREATE POLICY "per_pound_price_public_read" ON public.per_pound_price FOR SELECT USING (true);
CREATE POLICY "special_content_public_read" ON public.special_content FOR SELECT USING (true);
CREATE POLICY "loose_product_public_read"   ON public.loose_product   FOR SELECT USING (true);
```

### Block 7 — DROP old tables (run LAST, after UI is verified in production)

```sql
DROP TABLE IF EXISTS public.pricing_item CASCADE;
DROP TABLE IF EXISTS public.shipping_box  CASCADE;
```

> **Risk gate**: Run Block 7 only after `astro build` succeeds, the site deploys without errors, and `/es/precios` + `/en/pricing` render correctly from `loose_product`. If in doubt, defer to a follow-up PR.

---

## Data Layer — src/lib/supabase.ts

### Updated Country type

```typescript
export type Country = {
  id:   string;
  name: string;
  flag: string;
  slug: string; // ADD — url-safe slug, e.g. "cuba"
};
```

Update `mapCountryRow` to include `slug: String(row['slug'] ?? '')`.
Update `fetchCountries` `.select()` to `'id, name, name_en, flag, slug'`.

### New types

```typescript
export type BoxOffer = {
  id:          string;
  country_id:  string;
  title:       string;       // locale-resolved
  description: string;       // locale-resolved
  image_url:   string | null;
  height_in:   number;
  width_in:    number;
  depth_in:    number;
  price:       number;
};

export type PerPoundPrice = {
  id:               string;
  country_id:       string;
  transport_medium: string;  // locale-resolved
  price:            number;
};

export type SpecialContent = {
  id:          string;
  country_id:  string;
  title:       string;       // locale-resolved
  description: string;       // locale-resolved
};

export type LooseProduct = {
  id:    string;
  name:  string;             // locale-resolved
  unit:  string;
  price: number;
};
```

### Mapper signatures (follow existing pattern exactly)

```typescript
function mapBoxOfferRow(row: Record<string, unknown>, locale: Locale): BoxOffer {
  return {
    id:          String(row['id'] ?? ''),
    country_id:  String(row['country_id'] ?? ''),
    title:       locale === 'en' && row['title_en'] ? String(row['title_en']) : String(row['title'] ?? ''),
    description: locale === 'en' && row['description_en'] ? String(row['description_en']) : String(row['description'] ?? ''),
    image_url:   row['image_url'] != null ? String(row['image_url']) : null,
    height_in:   Number(row['height_in'] ?? 0),
    width_in:    Number(row['width_in']  ?? 0),
    depth_in:    Number(row['depth_in']  ?? 0),
    price:       Number(row['price']     ?? 0),
  };
}

function mapPerPoundPriceRow(row: Record<string, unknown>, locale: Locale): PerPoundPrice {
  return {
    id:               String(row['id'] ?? ''),
    country_id:       String(row['country_id'] ?? ''),
    transport_medium: locale === 'en' && row['transport_medium_en']
                        ? String(row['transport_medium_en'])
                        : String(row['transport_medium'] ?? ''),
    price:            Number(row['price'] ?? 0),
  };
}

function mapSpecialContentRow(row: Record<string, unknown>, locale: Locale): SpecialContent {
  return {
    id:          String(row['id'] ?? ''),
    country_id:  String(row['country_id'] ?? ''),
    title:       locale === 'en' && row['title_en'] ? String(row['title_en']) : String(row['title'] ?? ''),
    description: locale === 'en' && row['description_en'] ? String(row['description_en']) : String(row['description'] ?? ''),
  };
}

function mapLooseProductRow(row: Record<string, unknown>, locale: Locale): LooseProduct {
  return {
    id:    String(row['id'] ?? ''),
    name:  locale === 'en' && row['name_en'] ? String(row['name_en']) : String(row['name'] ?? ''),
    unit:  String(row['unit'] ?? 'u'),
    price: Number(row['price'] ?? 0),
  };
}
```

### Fetcher signatures and .select() column lists

```typescript
// country_id FK filter + locale-resolved mapper — mirrors fetchCombos pattern
export async function fetchBoxOffers(countryId: string, locale: Locale = 'es'): Promise<BoxOffer[]> {
  // .select('id, country_id, title, title_en, description, description_en, image_url, height_in, width_in, depth_in, price, ord')
  // .eq('country_id', countryId).order('ord')
}

export async function fetchPerPoundPrices(countryId: string, locale: Locale = 'es'): Promise<PerPoundPrice[]> {
  // .select('id, country_id, transport_medium, transport_medium_en, price, ord')
  // .eq('country_id', countryId).order('ord')
}

export async function fetchSpecialContent(countryId: string, locale: Locale = 'es'): Promise<SpecialContent[]> {
  // .select('id, country_id, title, title_en, description, description_en, ord')
  // .eq('country_id', countryId).order('ord')
}

export async function fetchLooseProducts(locale: Locale = 'es'): Promise<LooseProduct[]> {
  // .select('id, name, name_en, unit, price, ord').order('ord')
  // Replaces fetchPricingItems
}

// Used in getStaticPaths to resolve slug → country.id + name
export async function fetchCountryBySlug(slug: string, locale: Locale = 'es'): Promise<Country | null> {
  // .select('id, name, name_en, flag, slug').eq('slug', slug).single()
  // Returns null on error or no data (page falls through to 404 via getStaticPaths)
}
```

Each fetcher follows the null-guard + logEmpty pattern:
```typescript
if (!supabase) { console.warn('[supabase] No env vars — returning empty ...'); return []; }
const { data, error } = await supabase.from('table_name')...;
if (error || !data || data.length === 0) { logEmpty('table_name', error, data); return []; }
return (data as Record<string, unknown>[]).map((row) => mapXRow(row, locale));
```

### PricingCatalog update

`PricingCatalog.astro` internally calls `fetchPricingItems`. Change the import to `fetchLooseProducts` and update the call. `LooseProduct.name` replaces `PricingItem.title` in the row render. No prop changes needed.

---

## Routing / Pages

### src/pages/es/[pais].astro and src/pages/en/[country].astro

```typescript
// getStaticPaths — identical in both files, only locale differs
export async function getStaticPaths() {
  const countries = await fetchCountries('es'); // or 'en'
  return countries
    .filter((c) => c.slug)
    .map((c) => ({ params: { pais: c.slug }, props: { countryId: c.id } }));
    //           or { params: { country: c.slug } } for EN
}

// Page frontmatter
const { pais } = Astro.params;          // 'en' uses 'country'
const { countryId } = Astro.props;      // passed from getStaticPaths

const locale = 'es'; // or 'en'
const [country, boxOffers, prices, specialContent, contacts] = await Promise.all([
  fetchCountryBySlug(pais, locale),
  fetchBoxOffers(countryId, locale),
  fetchPerPoundPrices(countryId, locale),
  fetchSpecialContent(countryId, locale),
  fetchContacts(),
]);
```

> `fetchCountryBySlug` in the page body is used for display data (name, flag). The `countryId` prop from `getStaticPaths` is authoritative for DB queries — avoids a second DB round-trip for the slug→id lookup.

### Unknown slug

`getStaticPaths` only emits routes for countries that exist in the DB with a non-null slug. Any URL not in that list results in a 404 by Astro's SSG default — no special handling needed.

### Precios / Pricing pages

Remove `BoxesCarousel` import and usage. `PricingCatalog` stays; only its internal fetcher changes to `fetchLooseProducts`.

---

## Components

### New components

**CountryView.astro**
- Props: `boxOffers: BoxOffer[], prices: PerPoundPrice[], specialContent: SpecialContent[], country: Country, locale: Locale`
- Renders three sections in order: `<BoxOfferGrid>`, `<PerPoundTable>`, `<SpecialContentBlock>`
- Each section receives its slice; sections with empty arrays still render with their own "no data" message

**BoxOfferGrid.astro**
- Props: `items: BoxOffer[], locale: Locale`
- Renders a responsive grid of box cards (mirrors `BoxesCarousel` markup but no carousel JS)
- Image renders when `image_url` is non-null; box SVG placeholder otherwise
- Empty state: `locale === 'es' ? 'Aún no hay cajas disponibles para este destino.' : 'No box offers available for this destination yet.'`

**PerPoundTable.astro**
- Props: `items: PerPoundPrice[], locale: Locale`
- Renders a simple two-column table: Transport medium | Price per lb
- Empty state: `locale === 'es' ? 'Aún no hay tarifas por libra para este destino.' : 'No per-pound rates available for this destination yet.'`

**SpecialContentBlock.astro**
- Props: `items: SpecialContent[], locale: Locale`
- Renders stacked content cards ordered by `ord`
- Empty state: omit the section entirely (no message — special content is optional promotional material, not core data)

### Destinos.astro update

Change the non-interactive `<div>` card to an `<a>` anchor. The `locale` prop is already available. The `country` type now has `slug`.

```diff
- <div class="group p-6 rounded-2xl ...">
+ <a href={`/${locale}/${c.slug}`} class="group p-6 rounded-2xl ...">
    <div class="text-4xl mb-2 ...">
    ...
- </div>
+ </a>
```

If `c.slug` is empty (row with no slug — only possible if Block 1 wasn't run), fall back to rendering the non-interactive `<div>` to avoid broken links:

```typescript
{c.slug ? <a href={`/${locale}/${c.slug}`} class="..."> : <div class="...">}
```

---

## i18n

All new mapper functions follow the identical locale-selection pattern already used by `mapServiceRow`, `mapComboRow`, `mapShippingBoxRow`:

```typescript
locale === 'en' && row['field_en'] ? String(row['field_en']) : String(row['field'] ?? '')
```

- Null `*_en` values fall back to the Spanish (primary) column automatically
- The two page trees (`es/` and `en/`) both call `fetchCountries(locale)` in `getStaticPaths`; each tree generates its own route set from the same slugs
- `transport_medium_en` is nullable; if absent the Spanish string is shown to English users (acceptable per A1)

---

## Edge Cases & Error Handling

| Case | Handling |
|------|----------|
| Unknown slug | Not emitted by `getStaticPaths` → Astro 404 |
| Empty `box_offer` for a country | `BoxOfferGrid` renders "no data" message |
| Empty `per_pound_price` | `PerPoundTable` renders "no data" message |
| Empty `special_content` | `SpecialContentBlock` renders nothing (promotional, optional) |
| Null `*_en` column | Mapper falls back to ES column |
| `fetchCountryBySlug` returns null | Page renders with `country = null`; guard with `country?.name ?? ''` in template |
| `supabase` is null (no env vars) | All fetchers return `[]`; pages render full "no data" empty states; `astro build` completes |
| Country has slug but no DB rows in any new table | All three sections show their respective empty states — valid build |

---

## Threat Matrix

N/A — no routing framework mutations, shell commands, subprocesses, VCS/PR automation, executable-file classification, or process-integration boundary in this change. All new routes are statically generated by Astro's SSG at build time.

---

## Migration / Rollout

1. Run DB Blocks 1–6 in the Supabase SQL Editor **before** deploying the code change
2. Seed `country.slug` for all existing rows (Block 1b) and verify 0 null slugs
3. Deploy code change — `astro build` generates static routes from the now-populated slugs
4. Verify `/es/cuba`, `/en/cuba` etc. build and render (even with 0 rows — empty state is valid)
5. Run Block 7 (DROP) only after production verification

---

## File-by-File Change Map

| File | Action | Notes |
|------|--------|-------|
| `supabase/schema.sql` | MODIFY | Append new tables, slug column, RLS policies, DROP statements |
| `src/lib/supabase.ts` | MODIFY | `Country` type + `slug`; 4 new types; 5 new fetchers; `fetchLooseProducts` replaces `fetchPricingItems` |
| `src/components/PricingCatalog.astro` | MODIFY | Import `fetchLooseProducts` instead of `fetchPricingItems`; render `item.name` instead of `item.title` |
| `src/components/Destinos.astro` | MODIFY | Cards become `<a href="/{locale}/{slug}">` with slug-guard |
| `src/pages/es/precios.astro` | MODIFY | Remove `BoxesCarousel` import + usage |
| `src/pages/en/pricing.astro` | MODIFY | Remove `BoxesCarousel` import + usage |
| `src/pages/es/[pais].astro` | CREATE | SSG dynamic route; `getStaticPaths` + `Promise.all` fetch |
| `src/pages/en/[country].astro` | CREATE | SSG dynamic route; identical to `[pais].astro` with `locale = 'en'` |
| `src/components/CountryView.astro` | CREATE | Layout container for the 3 subsections |
| `src/components/BoxOfferGrid.astro` | CREATE | Renders `BoxOffer[]` grid |
| `src/components/PerPoundTable.astro` | CREATE | Renders `PerPoundPrice[]` table |
| `src/components/SpecialContentBlock.astro` | CREATE | Renders `SpecialContent[]` stacked cards |
| `src/components/BoxesCarousel.astro` | DELETE | Removed from pricing pages; superseded by `BoxOfferGrid` in country view |

> `PricingItem` and `ShippingBox` types + their mappers/fetchers in `supabase.ts` are deleted once Block 7 runs.

---

## Verification Plan

Since there is no test runner, verification is `astro build` + manual browser checks.

### Step 1 — DB verification (before code deploy)

```sql
-- All countries have slugs
SELECT id, name, slug FROM public.country WHERE slug IS NULL; -- must return 0 rows

-- New tables are visible with correct columns
SELECT column_name, data_type FROM information_schema.columns
  WHERE table_name IN ('box_offer','per_pound_price','special_content','loose_product')
  ORDER BY table_name, ordinal_position;

-- RLS policies exist
SELECT tablename, policyname FROM pg_policies
  WHERE tablename IN ('box_offer','per_pound_price','special_content','loose_product');
```

### Step 2 — Build verification

```bash
astro build
```

**Done** when:
- Build exits 0
- `dist/es/cuba/index.html`, `dist/en/cuba/index.html` etc. exist (one file per country × 2 locales)
- `dist/es/precios/index.html` and `dist/en/pricing/index.html` exist
- No TypeScript errors in output

### Step 3 — Manual browser checks

| Page | Check |
|------|-------|
| `astro preview` → `/es/precios` | Only `PricingCatalog` (loose products table); no boxes carousel |
| `/en/pricing` | Same — only loose products table |
| `/es/cuba` | Renders with empty-state messages (no rows seeded yet is valid) |
| `/en/cuba` | Same in English |
| Home page (`/es/`) | Destinos cards render as links pointing to `/{locale}/{slug}` |
| Dev tools → Network | No 404s on page load; no console errors |

### Step 4 — Seed + re-verify

Seed at least one `box_offer`, `per_pound_price`, and `special_content` row for Cuba in the Supabase dashboard, then rebuild:

```bash
astro build && astro preview
```

Check `/es/cuba` shows real data in all three sections.

### Done criteria

- [ ] `astro build` exits 0 with routes for each country × locale
- [ ] `/es/precios` and `/en/pricing` show only loose products
- [ ] Country view empty state renders without build errors
- [ ] Country view with seeded data renders correctly
- [ ] Destinos cards are clickable links on the home page
- [ ] No broken imports (TypeScript resolves all new types/fetchers)

---

## Open Questions

- [ ] `LooseProduct.name` replaces `PricingItem.title` in `PricingCatalog` — confirm the `page_content` copy key `pricing_catalog.title` still applies (no copy key changes needed, confirmed)
- [ ] Should `BoxesCarousel.astro` be deleted in this PR or kept as dead code? Proposal says "removed from pricing pages" — recommend DELETE for clean state.
