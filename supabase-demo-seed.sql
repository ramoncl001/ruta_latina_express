-- =============================================================================
-- Ruta Latina Express — Demo seed data (ADITIVO, no borra nada)
-- Correr en Supabase SQL Editor (proyecto gbasfzzqxjnhaponfgjd)
-- =============================================================================
-- Preserva lo existente:
--   service: id=1 (Combos de alimentos) — se mantiene
--   country: id=1 Cuba, id=2 Mejico — se mantienen
--   combo:   id=1 (Combo sencillo) — se mantiene
--   contact: no se toca
-- =============================================================================


-- ---------------------------------------------------------------------------
-- 1. SERVICES  (+3 → total 4)
-- Imágenes: Unsplash directas (source.unsplash.com/random no sirve, usar URLs fijas)
-- ---------------------------------------------------------------------------

INSERT INTO public.service (image_url, title, description, title_en, description_en) VALUES

('https://images.unsplash.com/photo-1607083206869-4c7672e72a8a?w=800&q=80',
 'Encomiendas y paquetería',
 'Envío de documentos, ropa, electrónicos pequeños y regalos. Cotización por peso y destino con seguimiento incluido.',
 'Parcels and mail',
 'Send documents, clothing, small electronics and gifts. Quote by weight and destination with tracking included.'),

('https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?w=800&q=80',
 'Envío express',
 'Para cuando el tiempo importa. Entregas de 5 a 8 días con seguimiento en tiempo real y seguro básico incluido.',
 'Express shipping',
 'For when time matters. Deliveries in 5–8 days with real-time tracking and basic insurance included.'),

('https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=800&q=80',
 'Medicinas y salud',
 'Envío de medicamentos con receta, insumos médicos y productos de cuidado personal a domicilio.',
 'Medicine and health',
 'Ship prescription medications, medical supplies and personal care products door to door.');


-- ---------------------------------------------------------------------------
-- 2. COUNTRIES  (+4 → total 6)
-- ---------------------------------------------------------------------------

INSERT INTO public.country (name, flag, name_en) VALUES
  ('Argentina', '🇦🇷', 'Argentina'),
  ('Colombia',  '🇨🇴', 'Colombia'),
  ('Perú',      '🇵🇪', 'Peru'),
  ('Chile',     '🇨🇱', 'Chile');


-- ---------------------------------------------------------------------------
-- 3. COMBOS  (+9 → total 10)
-- Los country_id usan subquery por nombre para no depender del orden de INSERTs.
-- ---------------------------------------------------------------------------

-- Combos para Cuba
INSERT INTO public.combo
  (country_id, title, description, price, weight, min_days, max_days, products, title_en, description_en)
VALUES

((SELECT id FROM public.country WHERE name = 'Cuba' LIMIT 1),
 'Combo Familiar Cuba',
 'Alimentos esenciales para el mes. Ideal para hogares de 3 a 5 personas.',
 129, 20, 10, 15,
 ARRAY['Aceite 3L', 'Arroz 10kg', 'Frijoles 3kg', 'Pollo 5kg', 'Leche en polvo 2kg'],
 'Family bundle Cuba',
 'Essential food for the month. Ideal for households of 3 to 5 people.'),

((SELECT id FROM public.country WHERE name = 'Cuba' LIMIT 1),
 'Combo Premium Cuba',
 'Nuestro combo más completo. Alimentos, aseo y proteínas premium.',
 249, 40, 10, 15,
 ARRAY['Aceite 5L', 'Arroz 20kg', 'Frijoles 5kg', 'Pollo 10kg', 'Carne enlatada 12u', 'Aseo personal completo'],
 'Premium bundle Cuba',
 'Our most complete bundle. Food, hygiene and premium proteins.'),

((SELECT id FROM public.country WHERE name = 'Cuba' LIMIT 1),
 'Combo Aseo Cuba',
 'Todo lo necesario para el aseo personal y del hogar durante un mes.',
 79, 10, 10, 15,
 ARRAY['Jabón corporal 6u', 'Champú 2L', 'Detergente 5kg', 'Papel higiénico 24u', 'Cepillos y dentífrico'],
 'Hygiene bundle Cuba',
 'Everything needed for personal and household hygiene for a month.'),


-- Combos para Mejico
((SELECT id FROM public.country WHERE name = 'Mejico' LIMIT 1),
 'Combo Express Mexico',
 'Paquetería rápida para envíos urgentes a familiares.',
 89, 8, 4, 7,
 ARRAY['Hasta 8kg', 'Seguimiento en línea', 'Seguro básico incluido', 'Entrega en 4–7 días'],
 'Express bundle Mexico',
 'Fast parcel service for urgent shipments to family.'),

((SELECT id FROM public.country WHERE name = 'Mejico' LIMIT 1),
 'Combo Regalo Mexico',
 'Ideal para cumpleaños, aniversarios y celebraciones.',
 149, 12, 4, 7,
 ARRAY['Empaque premium', 'Dulces variados', 'Chocolates finos', 'Tarjeta personalizada', 'Foto opcional'],
 'Gift bundle Mexico',
 'Ideal for birthdays, anniversaries and celebrations.'),


-- Combos para Argentina
((SELECT id FROM public.country WHERE name = 'Argentina' LIMIT 1),
 'Combo Express Argentina',
 'Paquetería rápida hasta 5kg con seguro básico.',
 79, 5, 5, 8,
 ARRAY['Hasta 5kg', 'Seguimiento en línea', 'Seguro básico incluido', 'Recogida a domicilio'],
 'Express bundle Argentina',
 'Fast parcel service up to 5kg with basic insurance.'),


-- Combos para Colombia
((SELECT id FROM public.country WHERE name = 'Colombia' LIMIT 1),
 'Combo Familiar Colombia',
 'Envío mensual de productos básicos a familiares en Colombia.',
 119, 15, 6, 10,
 ARRAY['Enlatados variados', 'Café premium', 'Aseo personal', 'Snacks', 'Productos de higiene'],
 'Family bundle Colombia',
 'Monthly shipment of essentials to family in Colombia.'),


-- Combos para Perú
((SELECT id FROM public.country WHERE name = 'Perú' LIMIT 1),
 'Combo Express Perú',
 'Entrega rápida a Lima y provincias con seguimiento.',
 95, 8, 6, 10,
 ARRAY['Hasta 8kg', 'Cobertura nacional', 'Seguimiento en línea', 'Seguro incluido'],
 'Express bundle Peru',
 'Fast delivery to Lima and provinces with tracking.'),


-- Combos para Chile
((SELECT id FROM public.country WHERE name = 'Chile' LIMIT 1),
 'Combo Familiar Chile',
 'Productos esenciales enviados de Estados Unidos a Chile.',
 139, 15, 6, 10,
 ARRAY['Alimentos no perecederos', 'Aseo personal', 'Productos de despensa', 'Seguimiento incluido'],
 'Family bundle Chile',
 'Essential products shipped from the United States to Chile.');


-- =============================================================================
-- Verificación rápida (opcional, correr después)
-- =============================================================================
-- SELECT COUNT(*) AS services  FROM public.service;   -- esperado: 4
-- SELECT COUNT(*) AS countries FROM public.country;   -- esperado: 6
-- SELECT COUNT(*) AS combos    FROM public.combo;     -- esperado: 10
-- SELECT c.name AS country, COUNT(cb.id) AS combos
--   FROM public.country c LEFT JOIN public.combo cb ON cb.country_id = c.id
--   GROUP BY c.name ORDER BY combos DESC;
