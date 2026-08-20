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
  id:   string;
  name: string;
  flag: string;
  slug: string; // url-safe slug, e.g. "cuba"
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

export type PricingItem = {
  id: string;
  title: string;
  description: string;
  price: number;
  unit: string; // e.g. "kg", "u", "paquete"
};

export type ShippingBox = {
  id: string;
  title: string;
  description: string;
  image_url: string;
  height_in: number; // inches
  width_in: number;
  depth_in: number;
  price: number;
};

// --- New types (country-view-restructure) ---

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
  svg_icon:         string;  // URL to an SVG icon for the transport medium
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

// =============================================================================
// Contacts fallback (kept — breaking CTA/Footer without contacts is dangerous).
// Business data (services/combos/countries/pricing/boxes) intentionally has
// NO mocks: fetchers return [] on error/empty, and each component shows a
// minimal "no data" message to the user.
// =============================================================================

export const CONTACTS_MOCK: Contact[] = [
  { id: 'ct-1', name: 'phone',     value: '#' },
  { id: 'ct-2', name: 'email',     value: '#' },
  { id: 'ct-3', name: 'whatsapp',  value: '#' },
  { id: 'ct-4', name: 'instagram', value: '#' },
];

// =============================================================================
// Internal helpers
// =============================================================================

function logEmpty(table: string, error: unknown, data: unknown): void {
  if (error) {
    const msg = (error as { message?: string }).message ?? JSON.stringify(error);
    console.warn(`[supabase] ${table}: error (${msg}) — returning empty result`);
    return;
  }
  if (Array.isArray(data) && data.length === 0) {
    console.warn(
      `[supabase] ${table}: query succeeded but returned 0 rows. ` +
        `Check: (1) table has rows in schema 'public', (2) RLS is enabled with a SELECT policy USING (true), ` +
        `(3) publishable/anon key is correct.`,
    );
    return;
  }
  console.warn(`[supabase] ${table}: unknown empty reason — data was falsy`);
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
    slug: String(row['slug'] ?? ''),
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
    console.warn('[supabase] No env vars — returning empty services');
    return [];
  }
  const { data, error } = await supabase
    .from('service')
    .select('id, image_url, title, title_en, description, description_en')
    .order('id');
  if (error || !data || data.length === 0) {
    logEmpty('service', error, data);
    return [];
  }
  return (data as Record<string, unknown>[]).map((row) => mapServiceRow(row, locale));
}

export async function fetchCountries(locale: Locale = 'es'): Promise<Country[]> {
  if (!supabase) {
    console.warn('[supabase] No env vars — returning empty countries');
    return [];
  }
  const { data, error } = await supabase
    .from('country')
    .select('id, name, name_en, flag, slug')
    .order('id');
  if (error || !data || data.length === 0) {
    logEmpty('country', error, data);
    return [];
  }
  return (data as Record<string, unknown>[]).map((row) => mapCountryRow(row, locale));
}

export async function fetchCombos(locale: Locale = 'es'): Promise<ComboWithCountry[]> {
  if (!supabase) {
    console.warn('[supabase] No env vars — returning empty combos');
    return [];
  }
  const { data, error } = await supabase
    .from('combo')
    .select('id, country_id, title, title_en, description, description_en, price, weight, min_days, max_days, products, country(id, name, name_en, flag)')
    .order('id');
  if (error || !data || data.length === 0) {
    logEmpty('combo', error, data);
    return [];
  }
  return (data as Record<string, unknown>[]).map((row) => mapComboRow(row, locale));
}

export async function fetchContacts(): Promise<Map<string, string>> {
  let contacts: Contact[] = CONTACTS_MOCK;
  if (supabase) {
    const { data, error } = await supabase.from('contact').select('*');
    if (error || !data || data.length === 0) {
      logEmpty('contact', error, data);
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
    logEmpty(`page_content(${section}/${locale})`, error, data);
    return new Map();
  }
  return new Map((data as { key: string; value: string }[]).map((r) => [r.key, r.value]));
}

// Map raw DB row → PricingItem, picking the right locale column.
function mapPricingItemRow(row: Record<string, unknown>, locale: Locale): PricingItem {
  return {
    id:          String(row['id'] ?? ''),
    title:       locale === 'en' && row['title_en'] ? String(row['title_en']) : String(row['title'] ?? ''),
    description: locale === 'en' && row['description_en'] ? String(row['description_en']) : String(row['description'] ?? ''),
    price:       Number(row['price'] ?? 0),
    unit:        String(row['unit'] ?? 'u'),
  };
}

// Map raw DB row → ShippingBox, picking the right locale column.
function mapShippingBoxRow(row: Record<string, unknown>, locale: Locale): ShippingBox {
  return {
    id:          String(row['id'] ?? ''),
    title:       locale === 'en' && row['title_en'] ? String(row['title_en']) : String(row['title'] ?? ''),
    description: locale === 'en' && row['description_en'] ? String(row['description_en']) : String(row['description'] ?? ''),
    image_url:   String(row['image_url'] ?? '#'),
    height_in:   Number(row['height_in'] ?? 0),
    width_in:    Number(row['width_in'] ?? 0),
    depth_in:    Number(row['depth_in'] ?? 0),
    price:       Number(row['price'] ?? 0),
  };
}

export async function fetchPricingItems(locale: Locale = 'es'): Promise<PricingItem[]> {
  if (!supabase) {
    console.warn('[supabase] No env vars — returning empty pricing items');
    return [];
  }
  // NOTE: description columns are optional in the query — the current UI
  // (Nombre/Precio table) doesn't render them; the type keeps the field
  // for future use and mapPricingItemRow tolerates missing columns.
  const { data, error } = await supabase
    .from('pricing_item')
    .select('id, title, title_en, price, unit, ord')
    .order('ord');
  if (error || !data || data.length === 0) {
    logEmpty('pricing_item', error, data);
    return [];
  }
  return (data as Record<string, unknown>[]).map((row) => mapPricingItemRow(row, locale));
}

export async function fetchShippingBoxes(locale: Locale = 'es'): Promise<ShippingBox[]> {
  if (!supabase) {
    console.warn('[supabase] No env vars — returning empty shipping boxes');
    return [];
  }
  const { data, error } = await supabase
    .from('shipping_box')
    .select('id, title, title_en, description, description_en, image_url, height_in, width_in, depth_in, price, ord')
    .order('ord');
  if (error || !data || data.length === 0) {
    logEmpty('shipping_box', error, data);
    return [];
  }
  return (data as Record<string, unknown>[]).map((row) => mapShippingBoxRow(row, locale));
}

// =============================================================================
// New mappers — country-view-restructure
// (Block 7 deferred: PricingItem/ShippingBox types + fetchers kept until
//  DROP TABLE runs in production)
// =============================================================================

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
    svg_icon:         String(row['svg_icon'] ?? ''),
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

// =============================================================================
// New fetchers — country-view-restructure
// =============================================================================

export async function fetchBoxOffers(countryId: string, locale: Locale = 'es'): Promise<BoxOffer[]> {
  if (!supabase) {
    console.warn('[supabase] No env vars — returning empty box offers');
    return [];
  }
  const { data, error } = await supabase
    .from('box_offer')
    .select('id, country_id, title, title_en, description, description_en, image_url, height_in, width_in, depth_in, price, ord')
    .eq('country_id', countryId)
    .order('ord');
  if (error || !data || data.length === 0) {
    logEmpty('box_offer', error, data);
    return [];
  }
  return (data as Record<string, unknown>[]).map((row) => mapBoxOfferRow(row, locale));
}

export async function fetchPerPoundPrices(countryId: string, locale: Locale = 'es'): Promise<PerPoundPrice[]> {
  if (!supabase) {
    console.warn('[supabase] No env vars — returning empty per-pound prices');
    return [];
  }
  const { data, error } = await supabase
    .from('per_pound_price')
    .select('id, country_id, transport_medium, transport_medium_en, price, ord, svg_icon')
    .eq('country_id', countryId)
    .order('ord');
  if (error || !data || data.length === 0) {
    logEmpty('per_pound_price', error, data);
    return [];
  }
  return (data as Record<string, unknown>[]).map((row) => mapPerPoundPriceRow(row, locale));
}

export async function fetchSpecialContent(countryId: string, locale: Locale = 'es'): Promise<SpecialContent[]> {
  if (!supabase) {
    console.warn('[supabase] No env vars — returning empty special content');
    return [];
  }
  const { data, error } = await supabase
    .from('special_content')
    .select('id, country_id, title, title_en, description, description_en, ord')
    .eq('country_id', countryId)
    .order('ord');
  if (error || !data || data.length === 0) {
    logEmpty('special_content', error, data);
    return [];
  }
  return (data as Record<string, unknown>[]).map((row) => mapSpecialContentRow(row, locale));
}

export async function fetchLooseProducts(locale: Locale = 'es'): Promise<LooseProduct[]> {
  if (!supabase) {
    console.warn('[supabase] No env vars — returning empty loose products');
    return [];
  }
  const { data, error } = await supabase
    .from('loose_product')
    .select('id, name, name_en, unit, price, ord')
    .order('ord');
  if (error || !data || data.length === 0) {
    logEmpty('loose_product', error, data);
    return [];
  }
  return (data as Record<string, unknown>[]).map((row) => mapLooseProductRow(row, locale));
}

export async function fetchCountryBySlug(slug: string, locale: Locale = 'es'): Promise<Country | null> {
  if (!supabase) {
    console.warn('[supabase] No env vars — returning null for fetchCountryBySlug');
    return null;
  }
  const { data, error } = await supabase
    .from('country')
    .select('id, name, name_en, flag, slug')
    .eq('slug', slug)
    .single();
  if (error || !data) {
    logEmpty('country(by slug)', error, data);
    return null;
  }
  return mapCountryRow(data as Record<string, unknown>, locale);
}
