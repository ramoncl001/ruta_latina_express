# Exploration: Dual Language + Pink Palette + Reference Patterns

**Change:** dual-lang-palette-refs  
**Date:** 2026-08-09  
**Status:** Ready for Proposal

---

## Current State

### Tone Audit — IS the copy Rioplatense/voseo?

**YES — confirmed.** Two clear voseo instances found:

- `Combos.astro` → heading: **"Elegí el combo ideal"** (`elegí` = voseo imperative)
- `CTA.astro` → body: **"Escribinos por WhatsApp"** (`escribinos` = voseo indirect object)
- `CTA.astro` → heading: **"¿Listo para enviar?"** (neutral)
- `ComoFunciona.astro` → step 1: **"Elegí tu combo"**, **"Seleccioná el combo"** (both voseo)
- `ComoFunciona.astro` → step 3: **"Retiramos en tu domicilio o recibí en nuestro punto"** (`recibí` = voseo)

**Verdict:** 5 voseo instances in 2 components. Layout, Nav, Hero, Servicios, Destinos, Footer are tone-neutral (imperative-free or usted-compatible). Neutral Spanish requires replacing all voseo imperatives.

### Current Language Setup

- `Layout.astro`: `<html lang="es">` — hardcoded, no i18n config
- `astro.config.mjs`: No `i18n` key present, `site: 'https://rutalatinaexpress.com'`
- Routing: single-page SPA-style with anchor `#section` navigation
- All content is hardcoded inline inside each `.astro` component — zero translation layer

### Palette Audit (`global.css`)

Tailwind v4 CSS-first config via `@theme {}`. Current tokens:

| Token | Value | Usage |
|---|---|---|
| `--color-pearl` | `#FBF8F5` | Background |
| `--color-cream` | `#F5EFE7` | Section bg |
| `--color-rose-*` | `#FBEEE9` → `#7A4636` | Accents, borders, hover |
| `--color-gold-*` | `#E8C77B` → `#8F6F2A` | Primary CTA, gradient text |
| `--color-graphite-*` | `#4A4544` → `#1A1817` | Body text, headings |

**No pink token exists.** The rose scale is salmon/terracotta (warm red-brown), NOT pink. A true pink (e.g., fuchsia/magenta direction) would need a new `--color-pink-*` scale. There is no `<strong>` usage anywhere in the current copy — bold keywords exist only as section headings styled with `font-display`.

### Content Inventory — Strings Requiring Translation

| Component | Translatable strings | Voseo instances |
|---|---|---|
| `Layout.astro` | title (1), description (1), meta og (2) | 0 |
| `Nav.astro` | nav links (5 labels), CTA button (1) | 0 |
| `Hero.astro` | badge (1), h1 (2 lines), p (1), 2 CTAs, 3 trust items | 0 |
| `Servicios.astro` | section label, h2, 4 cards × (title+desc) = 10 | 0 |
| `Destinos.astro` | section label, h2 | 0 (data from Supabase) |
| `Combos.astro` | section label, h2, subtext, "Más elegido" badge, CTA × 2 | 1 (Elegí) |
| `ComoFunciona.astro` | section label, h2, 4 steps × (title+desc) = 10 | 3 (Elegí, Seleccioná, recibí) |
| `CTA.astro` | section label, h2, body, 2 CTAs | 1 (Escribinos) |
| `Footer.astro` | tagline (1) | 0 |

**Total unique string keys (estimate):** ~50 ES keys × 2 = 100 EN keys  
**Supabase-driven content** (`paises`, `combos`): country names and delivery times come from DB — need separate translation strategy (either DB columns or code-side lookup tables).

---

## Approaches: Astro i18n

### Option A — Astro Native i18n (`experimental.i18n` → stable in v3+, confirmed in v4+)

Configure `i18n` in `astro.config.mjs`:

```js
i18n: {
  defaultLocale: 'es',
  locales: ['es', 'en'],
  routing: { prefixDefaultLocale: true }, // forces /es/ and /en/
  fallback: { en: 'es' }
}
```

Pages become `src/pages/[lang]/index.astro` or `src/pages/es/index.astro` + `src/pages/en/index.astro`.  
Root `/` handled via middleware or redirect page.  
Translation dictionaries: `src/i18n/es.ts` and `src/i18n/en.ts`, imported at page level, passed as props to components.

**Pros:**
- Native Astro support — no extra dependencies
- Generates correct static routes for SSG
- `Astro.currentLocale` available everywhere
- `getRelativeLocaleUrl()` utility for locale-aware links
- Hreflang tags easy to inject in `<head>`

**Cons:**
- Each page file must exist per locale OR use dynamic `[lang]` route
- Components need props threading (pass `t` dictionary down)
- Root `/` redirect requires either a redirect page or middleware (both supported)
- Supabase data doesn't auto-translate — need separate column or lookup

**Effort:** Medium. Most work is content extraction, not config.

---

### Option B — Content Collections driven (i18n per collection)

Each section becomes a Markdown/MDX content collection with locale-prefixed slugs: `src/content/hero/es.md`, `src/content/hero/en.md`.

Components query collections by locale: `getEntry('hero', lang)`.

**Pros:**
- CMS-friendly — editors can own markdown files
- Rich content (bold, links) handled naturally in markdown
- No prop threading — each component fetches its own strings

**Cons:**
- Heavy overhead for short UI strings (button labels, nav items)
- Collections are better for long-form content, not micro-copy
- Each component needs async frontmatter
- Build-time complexity increases
- Overkill for this site's content volume (~50 string keys total)

**Effort:** High (relative to benefit). NOT recommended for this use case.

---

### Option C — Simple dictionary object (no Astro i18n config)

```ts
// src/i18n/translations.ts
export const t = { es: { hero_h1: '...', ... }, en: { ... } }
```

Locale detected from URL path segment or query param. Layout reads `Astro.url.pathname` to extract `lang`.

**Pros:**
- Zero config, works today
- Complete control over routing structure
- Easiest to prototype quickly

**Cons:**
- No `Astro.currentLocale` — must pipe locale manually
- No native static route generation — need to handle `/es/` and `/en/` pages manually
- No built-in hreflang or locale-aware utilities
- Root redirect must be hand-rolled

**Effort:** Low config, but scales poorly — **recommended only as a bridge** while migrating.

### Recommendation: Option A (Astro Native i18n)

Use `prefixDefaultLocale: true` so both `/es/` and `/en/` exist as clean SEO-friendly paths. Root `/` gets a lightweight redirect page that reads `navigator.language` client-side (with ES fallback via `<meta http-equiv="refresh">` for crawlers). Dictionary files in `src/i18n/`. Components receive `t` as a typed prop.

---

## Approaches: Pink-in-Bold Pattern

### Option 1 — Tailwind utility class on `<strong>` (global CSS rule)

Add to `global.css`:

```css
strong {
  color: var(--color-pink-500);
  font-weight: 600;
}
```

And add pink tokens to `@theme`:

```css
--color-pink-400: #F472B6;
--color-pink-500: #EC4899;
--color-pink-600: #DB2777;
```

**Pros:** Zero markup change — any `<strong>` automatically gets pink. Consistent across all components.  
**Cons:** Affects ALL bold text globally (including headings that use `font-semibold` via `font-display`). Must verify `<strong>` is only used for keyword emphasis, not structural bold.

**Effort:** Minimal — 4 CSS lines.

---

### Option 2 — Dedicated `<Highlight>` component

```astro
<!-- src/components/Highlight.astro -->
---
const { color = 'pink' } = Astro.props;
---
<mark class="text-[color:var(--color-pink-500)] bg-transparent font-semibold not-italic"><slot /></mark>
```

Usage: `<Highlight>alimentos frescos</Highlight>`

**Pros:**
- Explicit and semantic — only marked-up content gets pink
- Can vary color per instance
- Accessible (`<mark>` has semantic meaning)
- No risk of unintended global style leakage

**Cons:**
- Requires updating every component to use the component
- More verbose in JSX/Astro template
- `<mark>` default browser styling (yellow background) must be reset

**Effort:** Low-medium — create component + update copy in each component.

---

### Option 3 — CSS custom property + class-based scoping

Add a utility class `.keyword` or use a Tailwind variant:

```css
.keyword-highlight strong {
  color: var(--color-pink-500);
}
```

Wrap body copy sections: `<p class="keyword-highlight">...text with <strong>bold keyword</strong>...</p>`

**Pros:** Middle ground — scoped without a new component. Good for sections where only some bold should be pink.  
**Cons:** Requires wrapper class on every prose element. More coupling between HTML structure and CSS.

**Effort:** Medium.

### Recommendation: Option 1 for MVP, migrate to Option 2 for fine control

For the initial implementation: define pink tokens in `@theme` + add a global `strong { color: var(--color-pink-500) }` rule. Since the current site has **zero `<strong>` usage**, this is safe — any bold added during content writing will automatically be pink. If future headings or structural bold need to remain non-pink, switch to Option 2 `<Highlight>` selectively.

---

## Reference Patterns from granazul.com/es

### Pattern 1 ✅ ADOPT — "Modalidad 1/2/3" numbered service sections

**What:** Three full-width alternating sections (image + text) each prefixed with "Modalidad 1", "Modalidad 2", "Modalidad 3" — Casillero Virtual, Recogida en Casa, Oficinas Físicas.

**Why adopt:** RLE has the equivalent services (Combos/packages, door-to-door, pickup point) but presents them as cards. A numbered flow creates a stronger "here are your options" narrative. Maps perfectly onto RLE's service variants.

**Adaptation:** Replace or augment the current `Servicios.astro` 4-card grid with 3 numbered modality sections. Use "Opción 1/2/3" (neutral) instead of "Modalidad" to differentiate.

---

### Pattern 2 ✅ ADOPT — Rich footer with payment methods + legal + contact

**What:** Footer has: logo, nav columns (Envíos, Nosotros, Legal), payment method logos (Visa, MC, Amex, Revolut, Tropipay), social icons (FB, IG, TikTok), phone + email, legal PDFs.

**Why adopt:** RLE's current footer is a single line: logo + copyright. Zero trust signals, no contact info visible, no legal. This is a significant gap for a shipping business where trust is table stakes.

**Adaptation:** Expand `Footer.astro` with: contact (WhatsApp + email), payment method icons, legal links (T&C, privacy), social links. Payment icons can be SVGs or emoji-style for now.

---

### Pattern 3 ✅ ADOPT — Bold-keyword emphasis in body copy

**What:** Gran Azul uses `<strong>` inside paragraph copy for terms like "**familia en Cuba**", "**24-48 horas**", "**6,000 hoteles**". Visually it's just blue/accent color on bold.

**Why adopt:** Directly matches Change #2 (pink bold keywords). The pattern legitimizes the UX — it's proven in the competitor. Should appear in Hero body copy, ComoFunciona step descriptions, and CTA section.

**Adaptation:** Add pink strong styling + add 2-4 `<strong>` terms per section during translation extraction.

---

### Pattern 4 ⚠️ EVALUATE — Hero carousel with rotating value props

**What:** Full-width carousel with 6-7 slides (hotels, cars, express boxes, appliances, motorcycles, locker, shipping times). Each slide is a different service category with distinct imagery and CTA.

**Why consider:** Creates visual dynamism and surfaces all services at a glance.

**Why hesitate:** Gran Azul has 6+ distinct product lines. RLE currently offers shipping combos + paquetería — 2-3 value props. A carousel with 2 slides is worse UX than a static hero. Also adds JS complexity (carousel library or custom implementation) that conflicts with the clean Astro SSG approach.

**Verdict:** DEFER. Revisit when RLE expands beyond current 4 service types. For now, a static hero with trust signals is sufficient and loads faster.

---

### Pattern 5 ✅ ADOPT — "Quiénes somos" emotional storytelling section

**What:** A short section with headline + emotional paragraph: *"Nos encargamos de que te sientas más cerca de tu gente en Cuba. Cada servicio es un abrazo para los tuyos..."* with a photo of a delivery person.

**Why adopt:** Directly addresses the emotional purchase motivation — families separated by geography. RLE has this sentiment in the Hero ("Conectamos familias") but lacks a dedicated section. This builds trust and differentiates from pure logistics companies.

**Adaptation:** New `QuienesSomos.astro` component, placed between `ComoFunciona` and `CTA`. Photo optional (placeholder OK for launch). This content needs translation (ES + EN) from day one.

---

## Risks

| Risk | Severity | Mitigation |
|---|---|---|
| **Content freeze during translation** | High | Extract all strings to `src/i18n/` BEFORE any new copy changes. Freeze content edits during i18n refactor (1-2 day window). |
| **SEO — hreflang missing** | High | Add `<link rel="alternate" hreflang="es" href="...">` and `hreflang="en"` in `Layout.astro` head. Required for Google to understand language variants. |
| **Root `/` redirect UX** | Medium | Client-side `navigator.language` redirect is invisible to crawlers. Add `<link rel="alternate">` canonical signals. Use JS redirect for users, not meta-refresh (causes flash). |
| **Existing bookmarks break** | Medium | If anyone has bookmarked `rutalatinaexpress.com`, they'll land on `/` which redirects. This is acceptable — redirect is fast and transparent. |
| **Supabase content not translated** | Medium | `paises.nombre` and `combos.nombre` come from DB. Either add `nombre_en` columns to DB tables OR maintain a code-side locale map for the 5 countries and ~3 combo names. Code map is simpler for current scale. |
| **Combos.astro JS re-render** | Low | The client-side `renderCombos()` function generates HTML strings with hardcoded Spanish labels (e.g., "Solicitar este combo", "Más elegido"). These need to receive locale context. Solution: pass current locale as a `data-locale` attribute on the grid, read it in the client script. |
| **Pink token naming collision** | Low | `--color-rose-*` already exists and is NOT pink. New tokens should be `--color-pink-*` (distinct scale). No collision risk if named correctly. |

---

## Affected Files

| File | Change type |
|---|---|
| `astro.config.mjs` | Add `i18n` config block |
| `src/layouts/Layout.astro` | Accept `lang` prop, set `<html lang>`, inject hreflang tags |
| `src/pages/index.astro` | Convert to redirect page |
| `src/pages/es/index.astro` | New — ES home (or `[lang]/index.astro` dynamic route) |
| `src/pages/en/index.astro` | New — EN home |
| `src/i18n/es.ts` | New — Spanish dictionary |
| `src/i18n/en.ts` | New — English dictionary |
| `src/components/Nav.astro` | Accept `t` prop |
| `src/components/Hero.astro` | Accept `t` prop, add `<strong>` keywords |
| `src/components/Servicios.astro` | Accept `t` prop |
| `src/components/Destinos.astro` | Accept `t` prop, locale map for country names |
| `src/components/Combos.astro` | Accept `t` prop, pass locale to client script |
| `src/components/ComoFunciona.astro` | Accept `t` prop, fix voseo → neutral |
| `src/components/CTA.astro` | Accept `t` prop, fix voseo → neutral |
| `src/components/Footer.astro` | Major expansion + accept `t` prop |
| `src/components/QuienesSomos.astro` | New component |
| `src/styles/global.css` | Add `--color-pink-*` tokens + `strong` rule |

---

## Ready for Proposal

**Yes.** All three change areas are well-scoped with low architectural risk:
- i18n: standard Astro native pattern, ~50 string keys, clear file structure
- Pink palette: 4 CSS lines + content markup during translation extraction
- Reference patterns: 4 of 5 patterns are additive (new sections/expansion), 1 deferred

**Recommended sequencing for proposal:**
1. Palette + `strong` markup (10 min, zero risk — unblocks copy work)
2. i18n infrastructure (astro.config + dictionary files + Layout props)
3. Content extraction + voseo → neutral pass (all 8 components)
4. Footer expansion (trust signals — high impact)
5. New `QuienesSomos.astro` section
6. Hero bold keywords
