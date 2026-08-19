# Country View Specification

## Purpose

Defines the per-country detail page at `/{locale}/{slug}`. Each country gets one SSG route per locale. The page loads three country-scoped entities in parallel and renders each in an independent section.

---

## Requirements

### Requirement: Route Generation

The system MUST generate one static page per `(locale, country.slug)` pair using `getStaticPaths()`. Only countries with a non-null `slug` value in the `country` table are built. Unknown or missing slugs MUST NOT produce a built route.

#### Scenario: Known slugs build successfully

- GIVEN the `country` table contains rows with slugs `cuba`, `argentina`, `chile`, `peru`, `colombia`
- WHEN `getStaticPaths()` executes at build time
- THEN routes `/es/cuba`, `/es/argentina`, `/en/cuba`, `/en/argentina` (etc.) are generated for all known slugs

#### Scenario: Unknown slug yields no route

- GIVEN a request arrives for `/es/narnia`
- WHEN the SSG build has completed
- THEN no page exists for that path and the host serves a 404

#### Scenario: Country with null slug is excluded

- GIVEN a `country` row has `slug = null`
- WHEN `getStaticPaths()` executes
- THEN that country is not included in the generated routes

---

### Requirement: Parallel Entity Loading

The country view page MUST fetch `box_offer`, `per_pound_price`, and `special_content` for the resolved `country_id` in parallel. A failure in one fetch MUST NOT block the rendering of sections backed by successful fetches.

#### Scenario: All three fetches succeed

- GIVEN a country page is being built and all three tables have rows for that country
- WHEN the page renders
- THEN all three sections (box offers, per-pound pricing, special content) are rendered with their respective data

#### Scenario: One fetch fails, others succeed

- GIVEN the `per_pound_price` fetch returns an error for a given country
- WHEN the page renders
- THEN the per-pound section shows a "no data" message
- AND the box offer and special content sections render normally

---

### Requirement: Section Empty State

Each of the three content sections MUST independently handle an empty result set. Box offers and per-pound pricing MUST display a "no data" message when their entity returns zero rows. Special content MUST hide the section entirely when empty (no heading, no placeholder).

#### Scenario: Box offers empty

- GIVEN `box_offer` returns zero rows for the country
- WHEN the page renders
- THEN the box-offer section displays a "no data" message
- AND no box-offer cards are rendered

#### Scenario: Per-pound pricing empty

- GIVEN `per_pound_price` returns zero rows for the country
- WHEN the page renders
- THEN the per-pound section displays a "no data" message

#### Scenario: Special content empty — section hidden

- GIVEN `special_content` returns zero rows for the country
- WHEN the page renders
- THEN the special-content section is not rendered at all (no heading, no placeholder)

---

### Requirement: Locale Column Selection

All text fields on the country view MUST use locale-appropriate columns. For `locale=en`, the `*_en` variant MUST be used. When the `*_en` column is null, the system MUST fall back to the base (Spanish) column.

#### Scenario: English locale with populated `*_en` columns

- GIVEN `locale=en` and a `box_offer` row has `title_en = "Small Box"` and `title = "Caja Pequeña"`
- WHEN the page renders
- THEN "Small Box" is displayed

#### Scenario: English locale with null `*_en` column — fallback

- GIVEN `locale=en` and a `box_offer` row has `title_en = null` and `title = "Caja Pequeña"`
- WHEN the page renders
- THEN "Caja Pequeña" is displayed (Spanish fallback)

#### Scenario: Spanish locale always uses base columns

- GIVEN `locale=es` and a row has both `title` and `title_en` populated
- WHEN the page renders
- THEN `title` (Spanish) is displayed regardless of `title_en` value
