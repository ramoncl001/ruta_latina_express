-- =============================================================================
-- Ruta Latina Express — i18n Migration
-- Change: mega-i18n-content-migration
-- Run this in the Supabase SQL Editor (Project: gbasfzzqxjnhaponfgjd)
-- Date: 2026-08-09
--
-- CONVENTION: values in page_content may contain inline HTML tags:
--   <strong>…</strong>          → renders bold (existing pink <strong> style)
--   <span class="hl-gold">…</span> → renders gold highlight
-- These are intentionally stored as HTML and rendered with set:html in Astro.
-- =============================================================================

-- ---------------------------------------------------------------------------
-- 1. Add locale columns to existing tables
-- ---------------------------------------------------------------------------

ALTER TABLE public.service
  ADD COLUMN IF NOT EXISTS title_en       varchar,
  ADD COLUMN IF NOT EXISTS description_en varchar;

ALTER TABLE public.combo
  ADD COLUMN IF NOT EXISTS title_en       varchar,
  ADD COLUMN IF NOT EXISTS description_en varchar;

-- country: name is essentially the same in EN for Cuba/Mexico,
-- but we add the column for completeness and future destinations.
ALTER TABLE public.country
  ADD COLUMN IF NOT EXISTS name_en varchar;

-- ---------------------------------------------------------------------------
-- 2. Fill EN translations for existing rows (service table)
--    Adjust title_en / description_en values for the actual row IDs in your DB.
--    These UPDATE statements use the Spanish title to identify rows.
-- ---------------------------------------------------------------------------

UPDATE public.service
SET
  title_en       = 'Food Bundles',
  description_en = 'Pre-assembled boxes with essentials: rice, oil, chicken, milk, hygiene products. Ready for your family.'
WHERE title ILIKE '%Combos alimenticios%' OR title ILIKE '%alimentici%';

UPDATE public.service
SET
  title_en       = 'Parcels',
  description_en = 'Documents, clothing, small electronics. We quote by weight and destination.'
WHERE title ILIKE '%Encomiendas%';

UPDATE public.service
SET
  title_en       = 'Express Shipping',
  description_en = 'For South America, deliveries in 5 to 8 days with tracking and basic insurance.'
WHERE title ILIKE '%express%';

UPDATE public.service
SET
  title_en       = 'Medicine & Health',
  description_en = 'Shipping of prescription medications, medical supplies, and personal care products.'
WHERE title ILIKE '%Medicinas%' OR title ILIKE '%salud%';

-- ---------------------------------------------------------------------------
-- 3. Fill EN translations for existing rows (combo table)
--    Use ILIKE on title to match regardless of exact casing.
-- ---------------------------------------------------------------------------

UPDATE public.combo
SET
  title_en       = 'Family Bundle Cuba',
  description_en = 'Essential groceries for the month. Ideal for households of 3 to 5 people.'
WHERE title ILIKE '%Familiar Cuba%';

UPDATE public.combo
SET
  title_en       = 'Premium Bundle Cuba',
  description_en = 'Our most complete bundle. Groceries, hygiene items, and premium proteins.'
WHERE title ILIKE '%Premium Cuba%';

UPDATE public.combo
SET
  title_en       = 'Express Bundle Argentina',
  description_en = 'Fast parcel delivery up to 5 kg with basic insurance.'
WHERE title ILIKE '%Express Argentina%';

-- ---------------------------------------------------------------------------
-- 4. Fill EN country names
-- ---------------------------------------------------------------------------

UPDATE public.country SET name_en = 'Cuba'   WHERE name ILIKE 'Cuba';
UPDATE public.country SET name_en = 'Mexico'  WHERE name ILIKE 'Mejico' OR name ILIKE 'México';
-- Add more as new countries are inserted:
-- UPDATE public.country SET name_en = 'Argentina' WHERE name ILIKE 'Argentina';
-- UPDATE public.country SET name_en = 'Chile'     WHERE name ILIKE 'Chile';
-- UPDATE public.country SET name_en = 'Peru'      WHERE name ILIKE 'Perú';
-- UPDATE public.country SET name_en = 'Colombia'  WHERE name ILIKE 'Colombia';

-- ---------------------------------------------------------------------------
-- 5. Create page_content table
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.page_content (
  id         bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  created_at timestamp with time zone DEFAULT now(),
  section    varchar NOT NULL,
  key        varchar NOT NULL,
  locale     varchar NOT NULL,
  value      text    NOT NULL,
  ord        int     DEFAULT 0,
  UNIQUE (section, key, locale)
);

ALTER TABLE public.page_content ENABLE ROW LEVEL SECURITY;

CREATE POLICY "public read"
  ON public.page_content
  FOR SELECT
  USING (true);

-- ---------------------------------------------------------------------------
-- 6. Seed page_content — Hero (ES)
-- ---------------------------------------------------------------------------

INSERT INTO public.page_content (section, key, locale, value, ord) VALUES
  ('hero', 'badge',          'es', 'Envíos a Cuba y Sudamérica',                                          0),
  ('hero', 'title_line1',    'es', 'Conectamos familias,',                                                0),
  ('hero', 'title_line2',    'es', 'envío tras envío.',                                                   0),
  ('hero', 'subtitle',       'es', 'Enviamos alimentos, medicinas y paquetes con <span class="hl-gold">seguimiento en tiempo real</span>. <strong>Precios transparentes</strong>, <strong>entrega puerta a puerta</strong>, atención humana.', 0),
  ('hero', 'cta_primary',    'es', 'Ver combos y precios',                                                0),
  ('hero', 'cta_secondary',  'es', 'Cómo funciona',                                                      0),
  ('hero', 'badge_tracking', 'es', 'Seguimiento en línea',                                                0),
  ('hero', 'badge_delivery', 'es', 'Entrega puerta a puerta',                                             0),
  ('hero', 'badge_insured',  'es', 'Seguro incluido',                                                     0)
ON CONFLICT (section, key, locale) DO UPDATE SET value = EXCLUDED.value;

-- Hero (EN)
INSERT INTO public.page_content (section, key, locale, value, ord) VALUES
  ('hero', 'badge',          'en', 'Shipping to Cuba & South America',                                    0),
  ('hero', 'title_line1',    'en', 'Connecting families,',                                                0),
  ('hero', 'title_line2',    'en', 'shipment after shipment.',                                            0),
  ('hero', 'subtitle',       'en', 'We ship food, medicine, and packages with <span class="hl-gold">real-time tracking</span>. <strong>Transparent pricing</strong>, <strong>door-to-door delivery</strong>, human support.', 0),
  ('hero', 'cta_primary',    'en', 'View bundles & prices',                                               0),
  ('hero', 'cta_secondary',  'en', 'How it works',                                                        0),
  ('hero', 'badge_tracking', 'en', 'Online tracking',                                                     0),
  ('hero', 'badge_delivery', 'en', 'Door-to-door delivery',                                               0),
  ('hero', 'badge_insured',  'en', 'Insurance included',                                                  0)
ON CONFLICT (section, key, locale) DO UPDATE SET value = EXCLUDED.value;

-- ---------------------------------------------------------------------------
-- 7. Seed page_content — QuienesSomos (ES)
-- ---------------------------------------------------------------------------

INSERT INTO public.page_content (section, key, locale, value, ord) VALUES
  ('quienes_somos', 'eyebrow',    'es', 'Quiénes somos',                                                  0),
  ('quienes_somos', 'title',      'es', 'Un puente entre tú<br />y tu <strong>familia</strong>',           0),
  ('quienes_somos', 'body_1',     'es', 'Nacimos para resolver una necesidad real: llevar <strong>alimentos, medicinas y cariño</strong> a quienes más queremos, sin importar la distancia. Cada envío que gestionamos lleva el compromiso de llegar completo, a tiempo y con atención humana de principio a fin.', 0),
  ('quienes_somos', 'body_2',     'es', 'Trabajamos con destinos en <strong>Cuba, Venezuela, Bolivia, Perú y Ecuador</strong> porque sabemos que la <strong>familia</strong> no tiene fronteras. Nuestro equipo coordina cada etapa del envío para que tú solo tengas que preocuparte por elegir qué mandar — con <span class="hl-gold">seguimiento en tiempo real</span> desde el primer momento.', 0),
  ('quienes_somos', 'pill_1',     'es', 'Confianza',                                                       1),
  ('quienes_somos', 'pill_2',     'es', 'Rapidez',                                                         2),
  ('quienes_somos', 'pill_3',     'es', 'Acompañamiento',                                                  3),
  ('quienes_somos', 'pill_4',     'es', 'Seguridad',                                                       4)
ON CONFLICT (section, key, locale) DO UPDATE SET value = EXCLUDED.value;

-- QuienesSomos (EN)
INSERT INTO public.page_content (section, key, locale, value, ord) VALUES
  ('quienes_somos', 'eyebrow',    'en', 'Who we are',                                                     0),
  ('quienes_somos', 'title',      'en', 'A bridge between you<br />and your <strong>family</strong>',     0),
  ('quienes_somos', 'body_1',     'en', 'We were founded to address a real need: bringing <strong>food, medicine, and care</strong> to the people we love most, no matter the distance. Every shipment we handle carries our commitment to arrive complete, on time, and with attentive, human support from start to finish.', 0),
  ('quienes_somos', 'body_2',     'en', 'We serve destinations in <strong>Cuba, Venezuela, Bolivia, Peru, and Ecuador</strong> because we know that <strong>family</strong> has no borders. Our team coordinates every stage of each shipment so all you need to do is choose what to send — with <span class="hl-gold">real-time tracking</span> from the very first moment.', 0),
  ('quienes_somos', 'pill_1',     'en', 'Trust',                                                           1),
  ('quienes_somos', 'pill_2',     'en', 'Speed',                                                           2),
  ('quienes_somos', 'pill_3',     'en', 'Support',                                                         3),
  ('quienes_somos', 'pill_4',     'en', 'Safety',                                                          4)
ON CONFLICT (section, key, locale) DO UPDATE SET value = EXCLUDED.value;

-- ---------------------------------------------------------------------------
-- 8. Seed page_content — CTA (ES)
-- ---------------------------------------------------------------------------

INSERT INTO public.page_content (section, key, locale, value, ord) VALUES
  ('cta', 'eyebrow',   'es', 'Empieza hoy',                                                               0),
  ('cta', 'title',     'es', '¿Listo para <span class="gold-gradient-text">enviar</span>?',               0),
  ('cta', 'body',      'es', 'Escríbenos por WhatsApp y te armamos una <strong>cotización personalizada</strong> en minutos. <strong>Sin compromiso</strong>, sin letra chica.', 0),
  ('cta', 'btn_wa',    'es', '💬 WhatsApp',                                                               0),
  ('cta', 'btn_email', 'es', 'Escríbenos',                                                                0)
ON CONFLICT (section, key, locale) DO UPDATE SET value = EXCLUDED.value;

-- CTA (EN)
INSERT INTO public.page_content (section, key, locale, value, ord) VALUES
  ('cta', 'eyebrow',   'en', 'Get started today',                                                         0),
  ('cta', 'title',     'en', 'Ready to <span class="gold-gradient-text">ship</span>?',                    0),
  ('cta', 'body',      'en', 'Message us on WhatsApp and we will put together a <strong>personalized quote</strong> in minutes. <strong>No commitment</strong>, no fine print.', 0),
  ('cta', 'btn_wa',    'en', '💬 WhatsApp',                                                               0),
  ('cta', 'btn_email', 'en', 'Email us',                                                                  0)
ON CONFLICT (section, key, locale) DO UPDATE SET value = EXCLUDED.value;

-- ---------------------------------------------------------------------------
-- 9. Seed page_content — ComoFunciona steps (ES)
-- ---------------------------------------------------------------------------

INSERT INTO public.page_content (section, key, locale, value, ord) VALUES
  ('como_funciona', 'eyebrow',      'es', 'Cómo funciona',                                                0),
  ('como_funciona', 'title',        'es', 'Cuatro pasos, <span class="gold-gradient-text">cero complicaciones</span>', 0),
  ('como_funciona', 'step_1_n',     'es', '01',                                                           1),
  ('como_funciona', 'step_1_title', 'es', 'Cotiza tu envío',                                              1),
  ('como_funciona', 'step_1_desc',  'es', 'Selecciona el <strong>combo</strong> o cotiza un envío personalizado según peso y destino.', 1),
  ('como_funciona', 'step_2_n',     'es', '02',                                                           2),
  ('como_funciona', 'step_2_title', 'es', 'Elige tu opción',                                              2),
  ('como_funciona', 'step_2_desc',  'es', 'Revisa los precios y elige el combo o servicio que mejor se adapte a tu familia.', 2),
  ('como_funciona', 'step_3_n',     'es', '03',                                                           3),
  ('como_funciona', 'step_3_title', 'es', 'Confirma y paga',                                              3),
  ('como_funciona', 'step_3_desc',  'es', 'Coordinamos por WhatsApp. Aceptamos transferencia, tarjeta y efectivo.', 3),
  ('como_funciona', 'step_4_n',     'es', '04',                                                           4),
  ('como_funciona', 'step_4_title', 'es', 'Recibe el envío',                                              4),
  ('como_funciona', 'step_4_desc',  'es', 'Te compartimos el código de <span class="hl-gold">seguimiento</span> hasta la entrega final.', 4)
ON CONFLICT (section, key, locale) DO UPDATE SET value = EXCLUDED.value;

-- ComoFunciona steps (EN)
INSERT INTO public.page_content (section, key, locale, value, ord) VALUES
  ('como_funciona', 'eyebrow',      'en', 'How it works',                                                 0),
  ('como_funciona', 'title',        'en', 'Four steps, <span class="gold-gradient-text">zero hassle</span>', 0),
  ('como_funciona', 'step_1_n',     'en', '01',                                                           1),
  ('como_funciona', 'step_1_title', 'en', 'Get a quote',                                                  1),
  ('como_funciona', 'step_1_desc',  'en', 'Select a <strong>bundle</strong> or request a custom quote based on weight and destination.', 1),
  ('como_funciona', 'step_2_n',     'en', '02',                                                           2),
  ('como_funciona', 'step_2_title', 'en', 'Choose your option',                                           2),
  ('como_funciona', 'step_2_desc',  'en', 'Review prices and choose the bundle or service that best suits your family.', 2),
  ('como_funciona', 'step_3_n',     'en', '03',                                                           3),
  ('como_funciona', 'step_3_title', 'en', 'Confirm and pay',                                              3),
  ('como_funciona', 'step_3_desc',  'en', 'We coordinate via WhatsApp. We accept bank transfer, card, and cash.', 3),
  ('como_funciona', 'step_4_n',     'en', '04',                                                           4),
  ('como_funciona', 'step_4_title', 'en', 'Receive your shipment',                                        4),
  ('como_funciona', 'step_4_desc',  'en', 'We share the <span class="hl-gold">tracking</span> code with you until final delivery.', 4)
ON CONFLICT (section, key, locale) DO UPDATE SET value = EXCLUDED.value;

-- =============================================================================
-- END OF MIGRATION
-- Verify with:
--   SELECT section, key, locale, LEFT(value, 60) FROM public.page_content ORDER BY section, ord, locale;
--   SELECT id, title, title_en FROM public.service;
--   SELECT id, title, title_en FROM public.combo;
--   SELECT id, name, name_en  FROM public.country;
-- =============================================================================
