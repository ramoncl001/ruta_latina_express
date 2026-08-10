-- Supabase — esquema para Ruta Latina Express
-- Ejecutar en Supabase SQL Editor.

-- =========================
-- Tabla: paises (destinos)
-- =========================
create table if not exists public.paises (
  id uuid primary key default gen_random_uuid(),
  nombre text not null,
  codigo text not null unique,              -- ISO-2: CU, AR, CL, PE, CO...
  bandera text not null default '',         -- Emoji: 🇨🇺 🇦🇷 ...
  tiempo_entrega text not null,             -- '10 a 15 días'
  descripcion text not null default '',
  destacado boolean not null default false,
  orden integer not null default 0,
  activo boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- =========================
-- Tabla: combos
-- =========================
create table if not exists public.combos (
  id uuid primary key default gen_random_uuid(),
  pais_id uuid not null references public.paises(id) on delete restrict,
  nombre text not null,
  descripcion text not null,
  precio_usd numeric(10, 2) not null,
  peso_kg numeric(6, 2),
  destacado boolean not null default false,
  incluye text[] not null default '{}',
  orden integer not null default 0,
  activo boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists combos_pais_id_idx on public.combos(pais_id);

-- =========================
-- Vistas públicas
-- =========================
-- Combos con datos de país joined, listos para el frontend.
create or replace view public.combos_publicos as
  select
    c.id,
    c.nombre,
    c.descripcion,
    c.precio_usd,
    c.peso_kg,
    c.destacado,
    c.incluye,
    c.orden,
    p.id           as pais_id,
    p.nombre       as pais_nombre,
    p.codigo       as pais_codigo,
    p.bandera      as pais_bandera,
    p.tiempo_entrega
  from public.combos c
  join public.paises p on p.id = c.pais_id
  where c.activo = true and p.activo = true
  order by c.orden asc;

create or replace view public.paises_publicos as
  select id, nombre, codigo, bandera, tiempo_entrega, descripcion, destacado, orden
  from public.paises
  where activo = true
  order by orden asc;

-- =========================
-- RLS (lectura pública)
-- =========================
alter table public.paises enable row level security;
alter table public.combos enable row level security;

drop policy if exists "paises_public_read" on public.paises;
create policy "paises_public_read"
  on public.paises for select using (activo = true);

drop policy if exists "combos_public_read" on public.combos;
create policy "combos_public_read"
  on public.combos for select using (activo = true);

-- =========================
-- Trigger: updated_at
-- =========================
create or replace function public.set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists paises_set_updated_at on public.paises;
create trigger paises_set_updated_at
  before update on public.paises
  for each row execute function public.set_updated_at();

drop trigger if exists combos_set_updated_at on public.combos;
create trigger combos_set_updated_at
  before update on public.combos
  for each row execute function public.set_updated_at();

-- =========================
-- Seed
-- =========================
insert into public.paises (nombre, codigo, bandera, tiempo_entrega, descripcion, destacado, orden) values
  ('Cuba',      'CU', '🇨🇺', '10 a 15 días', 'Nuestro destino principal. Combos de alimentos, medicinas y aseo.', true,  1),
  ('Argentina', 'AR', '🇦🇷', '5 a 8 días',   'Paquetería y documentos con entrega puerta a puerta.',             false, 2),
  ('Chile',     'CL', '🇨🇱', '5 a 8 días',   'Envíos express con seguimiento en línea.',                         false, 3),
  ('Perú',      'PE', '🇵🇪', '6 a 10 días',  'Encomiendas y paquetes personales.',                               false, 4),
  ('Colombia',  'CO', '🇨🇴', '6 a 10 días',  'Documentos, ropa y regalos.',                                      false, 5)
on conflict (codigo) do nothing;

-- Combos ejemplo (referencian por código de país)
insert into public.combos (pais_id, nombre, descripcion, precio_usd, peso_kg, destacado, incluye, orden)
select p.id, v.nombre, v.descripcion, v.precio_usd, v.peso_kg, v.destacado, v.incluye, v.orden
from (values
  ('CU', 'Combo Familiar Cuba', 'Alimentos esenciales para el mes. Ideal para hogares de 3 a 5 personas.', 129, 20, false,
    array['Aceite 3L','Arroz 10kg','Frijoles 3kg','Pollo 5kg','Leche en polvo 2kg'], 1),
  ('CU', 'Combo Premium Cuba', 'Nuestro combo más completo. Alimentos, aseo y proteínas premium.', 249, 40, true,
    array['Aceite 5L','Arroz 20kg','Frijoles 5kg','Pollo 10kg','Carne enlatada 12u','Aseo personal completo'], 2),
  ('AR', 'Combo Express Argentina', 'Paquetería rápida hasta 5kg con seguro básico.', 79, 5, false,
    array['Hasta 5kg','Seguimiento en línea','Seguro básico incluido','Recogida a domicilio'], 3)
) as v(codigo, nombre, descripcion, precio_usd, peso_kg, destacado, incluye, orden)
join public.paises p on p.codigo = v.codigo;
