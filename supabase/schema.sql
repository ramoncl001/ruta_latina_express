-- Supabase schema for Ruta Latina Express
-- Authoritative state as of country-view-restructure change.
-- Run each block in order in the Supabase SQL Editor.
--
-- NOTE: The old Spanish-schema (paises/combos) below is kept for reference.
-- The live DB uses English tables (country, combo, etc.) as referenced by supabase.ts.

-- =============================================================================
-- Legacy reference (Spanish schema — superseded by English tables in live DB)
-- =============================================================================

-- create table if not exists public.paises ( ... )  -- superseded by public.country
-- create table if not exists public.combos ( ... )  -- superseded by public.combo

-- =============================================================================
-- Block 1 — Add slug to country (DONE — run in production)
-- =============================================================================

-- 1a. Add column (nullable first to allow backfill)
ALTER TABLE public.country ADD COLUMN IF NOT EXISTS slug text;

-- 1b. Backfill existing rows
UPDATE public.country SET slug = 'cuba'      WHERE name = 'Cuba'      AND slug IS NULL;
UPDATE public.country SET slug = 'argentina' WHERE name = 'Argentina' AND slug IS NULL;
UPDATE public.country SET slug = 'chile'     WHERE name = 'Chile'     AND slug IS NULL;
UPDATE public.country SET slug = 'peru'      WHERE name ILIKE 'per%'  AND slug IS NULL;
UPDATE public.country SET slug = 'colombia'  WHERE name = 'Colombia'  AND slug IS NULL;

-- 1c. Enforce NOT NULL + UNIQUE once all rows are filled
-- Verify first: SELECT id, name, slug FROM public.country WHERE slug IS NULL; → must return 0 rows
ALTER TABLE public.country ALTER COLUMN slug SET NOT NULL;
ALTER TABLE public.country ADD CONSTRAINT country_slug_unique UNIQUE (slug);

-- =============================================================================
-- Block 2 — Create box_offer (DONE — run in production)
-- =============================================================================

CREATE TABLE IF NOT EXISTS public.box_offer (
  id             uuid          PRIMARY KEY DEFAULT gen_random_uuid(),
  country_id     uuid          NOT NULL REFERENCES public.country(id) ON DELETE CASCADE,
  title          text          NOT NULL,
  title_en       text,
  description    text          NOT NULL DEFAULT '',
  description_en text,
  image_url      text,
  height_in      numeric(6,2)  NOT NULL DEFAULT 0,
  width_in       numeric(6,2)  NOT NULL DEFAULT 0,
  depth_in       numeric(6,2)  NOT NULL DEFAULT 0,
  price          numeric(10,2) NOT NULL,
  ord            integer       NOT NULL DEFAULT 0,
  created_at     timestamptz   NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS box_offer_country_id_idx ON public.box_offer(country_id);

-- =============================================================================
-- Block 3 — Create per_pound_price (DONE — run in production)
-- =============================================================================

CREATE TABLE IF NOT EXISTS public.per_pound_price (
  id                  uuid          PRIMARY KEY DEFAULT gen_random_uuid(),
  country_id          uuid          NOT NULL REFERENCES public.country(id) ON DELETE CASCADE,
  transport_medium    text          NOT NULL,
  transport_medium_en text,
  price               numeric(10,2) NOT NULL,
  ord                 integer       NOT NULL DEFAULT 0,
  created_at          timestamptz   NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS per_pound_price_country_id_idx ON public.per_pound_price(country_id);

-- =============================================================================
-- Block 4 — Create special_content (DONE — run in production)
-- =============================================================================

CREATE TABLE IF NOT EXISTS public.special_content (
  id             uuid          PRIMARY KEY DEFAULT gen_random_uuid(),
  country_id     uuid          NOT NULL REFERENCES public.country(id) ON DELETE CASCADE,
  title          text          NOT NULL,
  title_en       text,
  description    text          NOT NULL DEFAULT '',
  description_en text,
  ord            integer       NOT NULL DEFAULT 0,
  created_at     timestamptz   NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS special_content_country_id_idx ON public.special_content(country_id);

-- =============================================================================
-- Block 5 — Create loose_product (DONE — run in production)
-- =============================================================================

CREATE TABLE IF NOT EXISTS public.loose_product (
  id         uuid          PRIMARY KEY DEFAULT gen_random_uuid(),
  name       text          NOT NULL,
  name_en    text,
  unit       text          NOT NULL DEFAULT 'u',
  price      numeric(10,2) NOT NULL,
  ord        integer       NOT NULL DEFAULT 0,
  created_at timestamptz   NOT NULL DEFAULT now()
);

-- =============================================================================
-- Block 6 — Enable RLS + open-read policies on all new tables (DONE — run in production)
-- =============================================================================

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

-- =============================================================================
-- Block 7 — DROP old tables (DEFERRED — run ONLY after production verification)
-- Risk gate: run Block 7 only after astro build succeeds, the site deploys
-- without errors, and /es/precios + /en/pricing render correctly from loose_product.
-- After Block 7, also remove PricingItem/ShippingBox types + mappers/fetchers
-- from src/lib/supabase.ts (they reference dropped tables).
-- =============================================================================

-- DROP TABLE IF EXISTS public.pricing_item CASCADE;
-- DROP TABLE IF EXISTS public.shipping_box  CASCADE;
