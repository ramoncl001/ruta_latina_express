# Per-Country Pricing Specification

## Purpose

Defines the data contracts for `box_offer` and `per_pound_price` — the two country-scoped pricing entities displayed on the country view page.

---

## Requirements

### Requirement: Box Offer Data Contract

The `box_offer` table MUST store country-scoped box offers with the following required fields: `country_id` (uuid FK to `country.id`), `title` (text, required), `price` (numeric, required), `ord` (integer, required for ordering). Optional fields: `title_en` (nullable), `description` (nullable), `description_en` (nullable), `transport_medium` (nullable), `transport_medium_en` (nullable), `image_url` (nullable).

The system MUST return box offers ordered by `ord` ascending when fetched for a country.

#### Scenario: Fetching box offers for a country returns ordered rows

- GIVEN `box_offer` has 3 rows for `country_id = X` with `ord` values `3, 1, 2`
- WHEN the country view fetches box offers for country X
- THEN rows are returned in order: ord=1, ord=2, ord=3

#### Scenario: Fetching box offers for a different country returns no rows

- GIVEN `box_offer` has rows only for `country_id = X`
- WHEN the country view fetches box offers for `country_id = Y`
- THEN an empty array is returned

#### Scenario: Box offer with null image_url renders without image

- GIVEN a `box_offer` row has `image_url = null`
- WHEN the country view renders the offer
- THEN no image element is rendered for that offer

#### Scenario: Box offer fetch error

- GIVEN the `box_offer` query returns a Supabase error
- WHEN the country view renders
- THEN the box-offer section shows a "no data" message

---

### Requirement: Per-Pound Price Data Contract

The `per_pound_price` table MUST store country-scoped per-pound shipping rates with required fields: `country_id` (uuid FK to `country.id`), `title` (text, required), `price` (numeric, required), `ord` (integer, required). Optional fields: `title_en` (nullable), `description` (nullable), `description_en` (nullable), `transport_medium` (nullable), `transport_medium_en` (nullable).

The system MUST return per-pound prices ordered by `ord` ascending when fetched for a country.

#### Scenario: Fetching per-pound prices returns ordered rows

- GIVEN `per_pound_price` has 2 rows for `country_id = X` with `ord` values `2, 1`
- WHEN the country view fetches per-pound prices for country X
- THEN rows are returned in order: ord=1, ord=2

#### Scenario: Per-pound price fetch error

- GIVEN the `per_pound_price` query returns a Supabase error
- WHEN the country view renders
- THEN the per-pound section shows a "no data" message

#### Scenario: English locale with populated transport_medium_en

- GIVEN `locale=en` and a `per_pound_price` row has `transport_medium_en = "Air"` and `transport_medium = "Aéreo"`
- WHEN the country view renders
- THEN "Air" is displayed

#### Scenario: English locale with null transport_medium_en — fallback

- GIVEN `locale=en` and a row has `transport_medium_en = null` and `transport_medium = "Aéreo"`
- WHEN the country view renders
- THEN "Aéreo" is displayed (Spanish fallback)

---

### Requirement: RLS Open-Read Policy

Both `box_offer` and `per_pound_price` MUST have a Supabase RLS `SELECT` policy with `USING (true)`. No unauthenticated write access is permitted.

#### Scenario: Unauthenticated client can read rows

- GIVEN an unauthenticated Supabase client
- WHEN it queries `box_offer` or `per_pound_price`
- THEN rows are returned (not blocked by RLS)
