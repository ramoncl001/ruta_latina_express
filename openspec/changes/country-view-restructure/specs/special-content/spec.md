# Special Content Specification

## Purpose

Defines the data contract and rendering behavior for `special_content` — country-scoped promotional blocks displayed on the country view page, ordered and stacked.

---

## Requirements

### Requirement: Special Content Data Contract

The `special_content` table MUST store country-scoped promotional blocks with required fields: `country_id` (uuid FK to `country.id`), `title` (text, required), `ord` (integer, required). Optional fields: `title_en` (nullable), `description` (nullable), `description_en` (nullable), `image_url` (nullable).

Multiple rows per country are supported. The system MUST return rows ordered by `ord` ascending.

#### Scenario: Multiple blocks rendered in order

- GIVEN `special_content` has 3 rows for `country_id = X` with `ord` values `3, 1, 2`
- WHEN the country view renders
- THEN blocks are rendered in order: ord=1, ord=2, ord=3

#### Scenario: English locale with populated title_en

- GIVEN `locale=en` and a row has `title_en = "Special Offer"` and `title = "Oferta Especial"`
- WHEN the country view renders
- THEN "Special Offer" is displayed

#### Scenario: English locale with null title_en — fallback

- GIVEN `locale=en` and a row has `title_en = null` and `title = "Oferta Especial"`
- WHEN the country view renders
- THEN "Oferta Especial" is displayed (Spanish fallback)

---

### Requirement: Empty State — Section Hidden

When `special_content` returns zero rows for a country, the system MUST hide the entire special-content section. No heading, no placeholder message, and no empty container SHOULD be rendered.

This differs from box offers and per-pound pricing (which show a "no data" message) because special content is promotional — its absence is not an error condition the user needs to know about.

#### Scenario: No special content — section absent

- GIVEN `special_content` returns zero rows for the country
- WHEN the country view renders
- THEN no special-content section, heading, or placeholder is present in the output

#### Scenario: Query error — section hidden

- GIVEN the `special_content` query returns a Supabase error
- WHEN the country view renders
- THEN the special-content section is not rendered (treated same as empty)

---

### Requirement: RLS Open-Read Policy

`special_content` MUST have a Supabase RLS `SELECT` policy with `USING (true)`.

#### Scenario: Unauthenticated client can read rows

- GIVEN an unauthenticated Supabase client
- WHEN it queries `special_content`
- THEN rows are returned (not blocked by RLS)
