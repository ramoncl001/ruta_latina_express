# Delta for pricing-catalog

## MODIFIED Requirements

### Requirement: Pricing Data Source

The pricing catalog page (`/es/precios`, `/en/pricing`) MUST source its data exclusively from the `loose_product` table. It MUST NOT query `pricing_item`, `shipping_box`, or any country-scoped table.
(Previously: pricing catalog sourced data from `pricing_item` table)

The `loose_product` table contract:
- `name` (text, required)
- `name_en` (nullable)
- `unit` (text, required — e.g. "lb", "kg", "unit")
- `price` (numeric, required)
- `ord` (integer, required for ordering)

Results MUST be ordered by `ord` ascending.

#### Scenario: Loose products displayed in order

- GIVEN `loose_product` has 3 rows with `ord` values `2, 1, 3`
- WHEN the pricing page renders
- THEN products are displayed in order: ord=1, ord=2, ord=3

#### Scenario: English locale name fallback

- GIVEN `locale=en` and a `loose_product` row has `name_en = null` and `name = "Libra"`
- WHEN the pricing page renders
- THEN "Libra" is displayed (Spanish fallback)

#### Scenario: English locale with populated name_en

- GIVEN `locale=en` and a row has `name_en = "Pound"` and `name = "Libra"`
- WHEN the pricing page renders
- THEN "Pound" is displayed

#### Scenario: Empty loose_product table

- GIVEN `loose_product` returns zero rows
- WHEN the pricing page renders
- THEN the catalog section shows a "no data" message
- AND no product rows are rendered

#### Scenario: Query error

- GIVEN the `loose_product` query returns a Supabase error
- WHEN the pricing page renders
- THEN the catalog section shows a "no data" message

---

## REMOVED Requirements

### Requirement: BoxesCarousel on Pricing Page

(Reason: Box offers are now country-scoped and belong to the country view, not the global pricing page. `BoxesCarousel` is removed from `/es/precios` and `/en/pricing`.)
(Migration: `BoxesCarousel` component is repurposed to accept a `countryId` prop and is used exclusively within `CountryView`. Existing imports of `BoxesCarousel` in pricing pages must be removed.)
