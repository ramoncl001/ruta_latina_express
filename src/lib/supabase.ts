import { createClient, type SupabaseClient } from '@supabase/supabase-js';

const SUPABASE_URL     = import.meta.env.PUBLIC_SUPABASE_URL     as string | undefined;
const SUPABASE_ANON_KEY = import.meta.env.PUBLIC_SUPABASE_ANON_KEY as string | undefined;

export const supabaseEnabled = Boolean(SUPABASE_URL && SUPABASE_ANON_KEY);

export const supabase: SupabaseClient | null = supabaseEnabled
  ? createClient(SUPABASE_URL as string, SUPABASE_ANON_KEY as string, {
      auth: { persistSession: false },
    })
  : null;

// =============================================================================
// Types
// =============================================================================

export type Locale = 'es' | 'en';

export type Service = {
  id: string;
  image_url: string;
  title: string;
  description: string;
};

export type Country = {
  id: string;
  name: string;
  flag: string;
};

export type Combo = {
  id: string;
  country_id: string;
  title: string;
  description: string;
  price: number;
  weight: number | null;
  min_days: number;
  max_days: number;
  products: string[];
};

export type ComboWithCountry = Combo & { country: Country };

export type Contact = {
  id: string;
  name: string;
  value: string;
};

// =============================================================================
// Mocks (fallback when no Supabase env vars)
// =============================================================================

export const SERVICES_MOCK: Record<Locale, Service[]> = {
  es: [
    { id: 's-1', image_url: '#', title: 'Combos alimenticios', description: 'Cajas armadas con lo esencial: arroz, aceite, pollo, leche, aseo. Listo para tu familia.' },
    { id: 's-2', image_url: '#', title: 'Encomiendas',         description: 'Documentos, ropa, electrónicos pequeños. Cotizamos por peso y destino.' },
    { id: 's-3', image_url: '#', title: 'Envío express',       description: 'Para Sudamérica, entregas de 5 a 8 días con seguimiento y seguro básico.' },
    { id: 's-4', image_url: '#', title: 'Medicinas y salud',   description: 'Envío de medicamentos con receta, insumos médicos y productos de cuidado personal.' },
  ],
  en: [
    { id: 's-1', image_url: '#', title: 'Food Bundles',       description: 'Pre-assembled boxes with essentials: rice, oil, chicken, milk, hygiene products. Ready for your family.' },
    { id: 's-2', image_url: '#', title: 'Parcels',            description: 'Documents, clothing, small electronics. We quote by weight and destination.' },
    { id: 's-3', image_url: '#', title: 'Express Shipping',   description: 'For South America, deliveries in 5 to 8 days with tracking and basic insurance.' },
    { id: 's-4', image_url: '#', title: 'Medicine & Health',  description: 'Shipping of prescription medications, medical supplies, and personal care products.' },
  ],
};

export const COUNTRIES_MOCK: Record<Locale, Country[]> = {
  es: [
    { id: 'c-cu', name: 'Cuba',      flag: '🇨🇺' },
    { id: 'c-ar', name: 'Argentina', flag: '🇦🇷' },
    { id: 'c-cl', name: 'Chile',     flag: '🇨🇱' },
    { id: 'c-pe', name: 'Perú',      flag: '🇵🇪' },
    { id: 'c-co', name: 'Colombia',  flag: '🇨🇴' },
  ],
  en: [
    { id: 'c-cu', name: 'Cuba',      flag: '🇨🇺' },
    { id: 'c-ar', name: 'Argentina', flag: '🇦🇷' },
    { id: 'c-cl', name: 'Chile',     flag: '🇨🇱' },
    { id: 'c-pe', name: 'Peru',      flag: '🇵🇪' },
    { id: 'c-co', name: 'Colombia',  flag: '🇨🇴' },
  ],
};

export const COMBOS_MOCK: Record<Locale, ComboWithCountry[]> = {
  es: [
    {
      id: 'mock-1', country_id: 'c-cu',
      title: 'Combo Familiar Cuba', description: 'Alimentos esenciales para el mes. Ideal para hogares de 3 a 5 personas.',
      price: 129, weight: 20, min_days: 10, max_days: 15,
      products: ['Aceite 3L', 'Arroz 10kg', 'Frijoles 3kg', 'Pollo 5kg', 'Leche en polvo 2kg'],
      country: { id: 'c-cu', name: 'Cuba', flag: '🇨🇺' },
    },
    {
      id: 'mock-2', country_id: 'c-cu',
      title: 'Combo Premium Cuba', description: 'Nuestro combo más completo. Alimentos, aseo y proteínas premium.',
      price: 249, weight: 40, min_days: 10, max_days: 15,
      products: ['Aceite 5L', 'Arroz 20kg', 'Frijoles 5kg', 'Pollo 10kg', 'Carne enlatada 12u', 'Aseo personal completo'],
      country: { id: 'c-cu', name: 'Cuba', flag: '🇨🇺' },
    },
    {
      id: 'mock-3', country_id: 'c-ar',
      title: 'Combo Express Argentina', description: 'Paquetería rápida hasta 5kg con seguro básico.',
      price: 79, weight: 5, min_days: 5, max_days: 8,
      products: ['Hasta 5kg', 'Seguimiento en línea', 'Seguro básico incluido', 'Recogida a domicilio'],
      country: { id: 'c-ar', name: 'Argentina', flag: '🇦🇷' },
    },
  ],
  en: [
    {
      id: 'mock-1', country_id: 'c-cu',
      title: 'Family Bundle Cuba', description: 'Essential groceries for the month. Ideal for households of 3 to 5 people.',
      price: 129, weight: 20, min_days: 10, max_days: 15,
      products: ['Oil 3L', 'Rice 10kg', 'Beans 3kg', 'Chicken 5kg', 'Powdered milk 2kg'],
      country: { id: 'c-cu', name: 'Cuba', flag: '🇨🇺' },
    },
    {
      id: 'mock-2', country_id: 'c-cu',
      title: 'Premium Bundle Cuba', description: 'Our most complete bundle. Groceries, hygiene items, and premium proteins.',
      price: 249, weight: 40, min_days: 10, max_days: 15,
      products: ['Oil 5L', 'Rice 20kg', 'Beans 5kg', 'Chicken 10kg', 'Canned meat 12u', 'Full hygiene kit'],
      country: { id: 'c-cu', name: 'Cuba', flag: '🇨🇺' },
    },
    {
      id: 'mock-3', country_id: 'c-ar',
      title: 'Express Bundle Argentina', description: 'Fast parcel delivery up to 5 kg with basic insurance.',
      price: 79, weight: 5, min_days: 5, max_days: 8,
      products: ['Up to 5 kg', 'Online tracking', 'Basic insurance included', 'Home pickup'],
      country: { id: 'c-ar', name: 'Argentina', flag: '🇦🇷' },
    },
  ],
};

export const CONTACTS_MOCK: Contact[] = [
  { id: 'ct-1', name: 'phone',     value: '#' },
  { id: 'ct-2', name: 'email',     value: '#' },
  { id: 'ct-3', name: 'whatsapp',  value: '#' },
  { id: 'ct-4', name: 'instagram', value: '#' },
];

// =============================================================================
// Internal helpers
// =============================================================================

function logFallback(table: string, error: unknown, data: unknown): void {
  if (error) {
    const msg = (error as { message?: string }).message ?? JSON.stringify(error);
    console.warn(`[supabase] ${table}: error (${msg}) — falling back to mock`);
    return;
  }
  if (Array.isArray(data) && data.length === 0) {
    console.warn(
      `[supabase] ${table}: query succeeded but returned 0 rows — falling back to mock. ` +
        `Check: (1) table has rows in schema 'public', (2) RLS is enabled with a SELECT policy USING (true), ` +
        `(3) publishable/anon key is correct.`,
    );
    return;
  }
  console.warn(`[supabase] ${table}: unknown fallback reason — data was falsy`);
}

// Map a raw DB service row to the Service type, picking the right locale column.
function mapServiceRow(row: Record<string, unknown>, locale: Locale): Service {
  return {
    id:          String(row['id'] ?? ''),
    image_url:   String(row['image_url'] ?? '#'),
    title:       locale === 'en' && row['title_en'] ? String(row['title_en']) : String(row['title'] ?? ''),
    description: locale === 'en' && row['description_en'] ? String(row['description_en']) : String(row['description'] ?? ''),
  };
}

// Map a raw DB country row to the Country type.
function mapCountryRow(row: Record<string, unknown>, locale: Locale): Country {
  return {
    id:   String(row['id'] ?? ''),
    name: locale === 'en' && row['name_en'] ? String(row['name_en']) : String(row['name'] ?? ''),
    flag: String(row['flag'] ?? ''),
  };
}

// Map a raw DB combo row (with nested country) to ComboWithCountry.
function mapComboRow(row: Record<string, unknown>, locale: Locale): ComboWithCountry {
  const countryRaw = (row['country'] as Record<string, unknown>) ?? {};
  return {
    id:          String(row['id'] ?? ''),
    country_id:  String(row['country_id'] ?? ''),
    title:       locale === 'en' && row['title_en'] ? String(row['title_en']) : String(row['title'] ?? ''),
    description: locale === 'en' && row['description_en'] ? String(row['description_en']) : String(row['description'] ?? ''),
    price:       Number(row['price'] ?? 0),
    weight:      row['weight'] != null ? Number(row['weight']) : null,
    min_days:    Number(row['min_days'] ?? 0),
    max_days:    Number(row['max_days'] ?? 0),
    products:    Array.isArray(row['products']) ? (row['products'] as string[]) : [],
    country:     mapCountryRow(countryRaw, locale),
  };
}

// =============================================================================
// Fetchers
// =============================================================================

export async function fetchServices(locale: Locale = 'es'): Promise<Service[]> {
  if (!supabase) {
    console.warn('[supabase] No env vars — using SERVICES_MOCK');
    return SERVICES_MOCK[locale];
  }
  const { data, error } = await supabase
    .from('service')
    .select('id, image_url, title, title_en, description, description_en')
    .order('id');
  if (error || !data || data.length === 0) {
    logFallback('service', error, data);
    return SERVICES_MOCK[locale];
  }
  return (data as Record<string, unknown>[]).map((row) => mapServiceRow(row, locale));
}

export async function fetchCountries(locale: Locale = 'es'): Promise<Country[]> {
  if (!supabase) {
    console.warn('[supabase] No env vars — using COUNTRIES_MOCK');
    return COUNTRIES_MOCK[locale];
  }
  const { data, error } = await supabase
    .from('country')
    .select('id, name, name_en, flag')
    .order('id');
  if (error || !data || data.length === 0) {
    logFallback('country', error, data);
    return COUNTRIES_MOCK[locale];
  }
  return (data as Record<string, unknown>[]).map((row) => mapCountryRow(row, locale));
}

export async function fetchCombos(locale: Locale = 'es'): Promise<ComboWithCountry[]> {
  if (!supabase) {
    console.warn('[supabase] No env vars — using COMBOS_MOCK');
    return COMBOS_MOCK[locale];
  }
  const { data, error } = await supabase
    .from('combo')
    .select('id, country_id, title, title_en, description, description_en, price, weight, min_days, max_days, products, country(id, name, name_en, flag)')
    .order('id');
  if (error || !data || data.length === 0) {
    logFallback('combo', error, data);
    return COMBOS_MOCK[locale];
  }
  return (data as Record<string, unknown>[]).map((row) => mapComboRow(row, locale));
}

export async function fetchContacts(): Promise<Map<string, string>> {
  let contacts: Contact[] = CONTACTS_MOCK;
  if (supabase) {
    const { data, error } = await supabase.from('contact').select('*');
    if (error || !data || data.length === 0) {
      logFallback('contact', error, data);
    } else {
      contacts = data as Contact[];
    }
  } else {
    console.warn('[supabase] No env vars — using CONTACTS_MOCK');
  }
  return new Map(contacts.map((c) => [c.name, c.value]));
}

/**
 * Fetch all copy for a given section and locale from page_content.
 * Returns a Map<key, value> so components can do: copy.get('title').
 * Falls back to an empty Map when Supabase is unavailable (components render
 * nothing or use hardcoded fallbacks defined per-component).
 */
export async function fetchPageContent(section: string, locale: Locale): Promise<Map<string, string>> {
  if (!supabase) {
    console.warn(`[supabase] No env vars — page_content(${section}/${locale}) returning empty map`);
    return new Map();
  }
  const { data, error } = await supabase
    .from('page_content')
    .select('key, value')
    .eq('section', section)
    .eq('locale', locale)
    .order('ord');
  if (error || !data || data.length === 0) {
    logFallback(`page_content(${section}/${locale})`, error, data);
    return new Map();
  }
  return new Map((data as { key: string; value: string }[]).map((r) => [r.key, r.value]));
}
