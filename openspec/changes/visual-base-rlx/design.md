# Design: Visual Base + Information Architecture (visual-base-rlx)

## Technical Approach

CSS-first, additive changes only. Start with global tokens (`global.css`), wire the font in `Layout.astro`, then work component-by-component bottom-up. No routing changes, no Supabase schema changes. Every decision is reversible by reverting the branch.

---

## Architecture Decisions

| # | Decision | Choice | Alternatives considered | Rationale |
|---|----------|--------|------------------------|-----------|
| 1 | Font loading mechanism | `<link>` tags in `Layout.astro` | `@import` in `global.css` | `<link>` is parsed by the preload scanner before CSSOM is built; `@import` blocks CSS parsing. Performance wins unambiguously. |
| 2 | Final brand palette | 4 tokens: `--color-white #ffffff`, `--color-ink #000000`, `--color-pink #F20B68`, `--color-gold #E5A817` | Tailwind pink-500 `#ec4899` scale (prior design) | User confirmed these exact hex values as authoritative. No full 10-step scale for Slice 1 — only the 4 base tokens are used. Tints/shades deferred to Slice 2 (hover states). |
| 3 | `strong` rule scope | Global `strong { color: var(--color-pink); font-weight: 700; }` | Scoped `.prose strong` | Zero `<strong>` tags exist in the current codebase (verified). Global rule is safe. Scoped approach adds complexity for no present benefit; can be tightened in Slice 2 if needed. |
| 12 | Pink hex `#F20B68` kept exact | `#F20B68` — user-confirmed, no modification | Adjust to `#E00060` or similar to push above 4.5:1 AA threshold | Contrast on white = ~4.4:1 (borderline AA). `<strong>` is bold (700 weight) so perceptual contrast is acceptable. User explicitly accepted this tradeoff. Do NOT change the hex. |
| 4 | Roboto weights to load | 400, 500, 700 | 300 (thin), 400, 500, 600, 700 | Body text (400), medium labels (500), bold keywords (700) cover all current use cases. Fewer variants = smaller font payload (~20KB less woff2). |
| 5 | `font-display` strategy | `swap` only; no `size-adjust` | `optional`, `fallback` | `swap` satisfies spec FOIT requirement. `size-adjust` is only needed if fallback and Roboto metrics differ enough to cause CLS — Roboto ≈ Inter metrics (both neo-grotesque), CLS risk negligible. Revisit only if Lighthouse flags it. |
| 6 | `QuienesSomos` image slot | `<div>` placeholder with TODO comment | `<img>` with placeholder src | No real image exists yet. A `<div>` with correct aspect ratio and Tailwind classes avoids a broken `<img>` request and makes the placeholder intent explicit. |
| 7 | Footer grid | `grid-cols-1 sm:grid-cols-2 md:grid-cols-4` | Flexbox | CSS Grid gives precise column alignment needed for the 4-column trust footer. Mobile-first: 1col → 2col at sm → 4col at md. |
| 8 | Implementation order | Typography → palette → footer → QuienesSomos → IA reorder + voseo + keywords | Top-down (Hero first) | Bottom-up: each step is independently verifiable and low-blast-radius. CSS tokens affect nothing visually until components use them. |
| 9 | Typography pairing | Dual-font: **Cormorant Garamond** (display headings) + **Roboto** (body) | Single Roboto for all | Cormorant adds editorial warmth to h1–h3; Roboto ensures legibility for body/UI copy. Both loaded from Google Fonts in a single combined stylesheet URL. Inter is dropped entirely. |
| 10 | Font token mapping | `--font-sans: "Roboto"` → body; `--font-display: "Cormorant"` → h1/h2/h3 global rule | CSS-only, no Tailwind plugin | Two tokens in `@theme`, two global rules. Components already using `.font-display` class continue working; body defaults to Roboto without per-component changes. |
| 11 | Contact data in Slice 1 | All email/WhatsApp values become `#` placeholders with inline `{/* TODO(slice-2) */}` | Hardcode client values | Client has not confirmed live contact data. Slice 2 will bind these from Supabase. Placeholder `#` is a valid href (jumps to top) and clearly signals missing data in code review. |
| 12 | Pink hex `#F20B68` kept exact | `#F20B68` — user-confirmed, no modification | Adjust to `#E00060` or similar to push above 4.5:1 AA threshold | Contrast on white = ~4.4:1 (borderline AA). `<strong>` is bold (700 weight) so perceptual contrast is acceptable. User explicitly accepted this tradeoff. Do NOT change the hex. |
| 13 | Gold applied via `.hl-gold` utility class, not a global tag rule | `.hl-gold { color: var(--color-gold); font-weight: 700; }` | Global `time`, `data` tag rule or Tailwind plugin | No HTML semantic element maps to "performance/value keyword". A utility class keeps authoring intent explicit and avoids false positives on unrelated elements. Authors wrap manually: `<span class="hl-gold">24-48 horas</span>`. |

---

## Data Flow

No runtime data flow changes. Supabase queries in `Destinos` and `Combos` are untouched.

```
Browser request
  └─ Layout.astro <head>
       ├─ <link preconnect fonts.googleapis.com>
       ├─ <link preconnect fonts.gstatic.com crossorigin>
       └─ <link stylesheet Google Fonts (Cormorant Garamond 600,700 + Roboto 400,500,700 latin)>
            └─ global.css (@theme tokens → body font-family → h1/h2/h3 font-display → strong rule)
                  └─ Components render with Roboto body + Cormorant headings + pink keywords
```

---

## File Changes

| File | Action | Description |
|------|--------|-------------|
| `src/styles/global.css` | Modify | Add 4-token brand palette (`--color-white/ink/pink/gold`), add `--font-sans` (Roboto) + `--font-display` (Cormorant), add global `body` (color + background) + `h1/h2/h3` font rules, add `strong` rule, add `.hl-gold` utility class |
| `src/layouts/Layout.astro` | Modify | Replace existing Google Fonts `<link>` with combined Cormorant+Roboto stylesheet; add preconnect tags if absent |
| `src/pages/index.astro` | Modify | Reorder sections; add `QuienesSomos` import and render |
| `src/components/ComoFunciona.astro` | Modify | Fix 3 voseo instances; add `<strong>` to 2 keyword phrases |
| `src/components/Combos.astro` | Modify | Fix 1 voseo instance (`Elegí` → `Elige`); also fix JS `cardHTML` string (same word appears in the `<script>` block's inline HTML) |
| `src/components/CTA.astro` | Modify | Fix 1 voseo instance (`Escribinos` → `Escríbenos`); update kicker text; add `<strong>` to 2 phrases; replace `hola@rutalatinaexpress.com` with `#` + TODO comment |
| `src/components/Hero.astro` | Modify | Add `<strong>` to 3 keyword phrases in body copy |
| `src/components/Footer.astro` | Modify | Full expansion to 4-column trust footer; all phone/email/WhatsApp values become `#` with TODO(slice-2) comments |
| `src/components/QuienesSomos.astro` | Create | New emotional storytelling component |

---

## Interfaces / Contracts

### 1. Typography + Brand Palette — `global.css` additions

```css
@theme {
  /* Add inside existing @theme block — keep all existing tokens */

  /* Body font — replaces Inter */
  --font-sans: "Roboto", ui-sans-serif, system-ui, Arial, sans-serif;

  /* Display font — Cormorant Garamond for h1/h2/h3 editorial headings */
  --font-display: "Cormorant Garamond", Georgia, "Times New Roman", serif;

  /* Brand palette — user-confirmed final values (2026-08-09) */
  --color-white: #ffffff;    /* page background, surface fills */
  --color-ink:   #000000;    /* body text */
  --color-pink:  #F20B68;    /* warmth/identity highlights — applied via <strong> */
  --color-gold:  #E5A817;    /* performance/tangible highlights — applied via .hl-gold */
}

/* Global base */
body {
  font-family: var(--font-sans);
  color: var(--color-ink);
  background: var(--color-white);
}

h1, h2, h3 {
  font-family: var(--font-display);
}

/* Global strong rule — safe: zero <strong> tags exist pre-change.
   #F20B68 on white = ~4.4:1 — acceptable for bold text; user accepted this tradeoff. */
strong {
  color: var(--color-pink);
  font-weight: 700;
}

/* Gold utility class — manual wrap for performance/value keywords.
   No global tag rule because there is no HTML semantic for "time/precision keyword". */
.hl-gold {
  color: var(--color-gold);
  font-weight: 700;
}
```

#### Highlight Category Mapping

Authors must follow this table. Design reviews will check keyword classification.

| Category | Mechanism | Hex | Examples |
|----------|-----------|-----|---------|
| **Warmth / Identity** — emotional, people, service names, countries | `<strong>text</strong>` | `#F20B68` | "tu familia", "seres queridos", "puerta a puerta", "confianza", "Combos", "Envíos", "Destinos", country names |
| **Performance / Tangible** — time, price, guarantees, numeric | `<span class="hl-gold">text</span>` | `#E5A817` | "24-48 horas", delivery windows, prices, "garantía", "seguimiento en tiempo real", numeric emphasis |

Rule of thumb: **pink = warmth/identity**, **gold = performance/tangible**.

> **Font pairing rationale**: Cormorant Garamond (600/700) on `h1–h3` delivers editorial warmth for emotional headings (hero, quiénes somos, section titles). Roboto (400/500/700) on `body` delivers the legibility needed for service descriptions, step instructions, and footer copy. The pairing intentionally creates contrast between display hierarchy and functional body text — aligned with RLX's trust-first brand voice.

> **Scope of `h1, h2, h3` rule**: The global selector applies to all headings. Components that already use `.font-display` as a Tailwind utility class will continue to apply `font-family: var(--font-display)` via that utility — the global rule and the utility class are redundant-compatible (no conflict). Components can override with `font-sans` utility class if a heading needs body font for UI reasons.

### 2. Layout.astro — font head replacement

Replace the existing single Google Fonts `<link>` (currently loads Cormorant + Inter) with:

```html
<!-- Keep existing preconnect tags (already present) -->
<link rel="preconnect" href="https://fonts.googleapis.com" />
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
<!-- Combined stylesheet: Cormorant Garamond (600,700) + Roboto (400,500,700) — Inter dropped -->
<link
  href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:wght@600;700&family=Roboto:wght@400;500;700&display=swap&subset=latin"
  rel="stylesheet"
/>
```

> Note: Inter is dropped — Roboto replaces it as `--font-sans`. Cormorant Garamond is retained and upgraded from weight 500 to **600/700** for display headings. The `subset=latin` parameter restricts download to Latin glyphs (smaller payload). `display=swap` prevents FOIT.

### 3. `QuienesSomos.astro` — component contract

```astro
---
// No props — all copy is static in this slice. Slice 2 will lift copy to Supabase.
---

<section id="quienes-somos" class="py-24 md:py-32 bg-[color:var(--color-cream)]">
  <div class="max-w-6xl mx-auto px-6">
    <div class="grid grid-cols-1 md:grid-cols-2 gap-12 md:gap-16 items-center">

      <!-- Image column (left on desktop) -->
      <div class="order-2 md:order-1">
        <!-- TODO: replace with real team/brand photo at /images/quienes-somos.jpg -->
        <div class="w-full aspect-[4/3] rounded-2xl bg-gradient-to-br
                    from-[color:var(--color-rose-100)] to-[color:var(--color-cream)]
                    flex items-center justify-center text-6xl">
          🌎
        </div>
      </div>

      <!-- Text column (right on desktop) -->
      <div class="order-1 md:order-2">
        <p class="text-xs uppercase tracking-[0.2em] text-[color:var(--color-gold-700)] font-medium">
          Quiénes somos
        </p>
        <h2 class="mt-3 font-display text-4xl md:text-5xl font-semibold text-[color:var(--color-graphite-900)]">
          Un puente entre tú<br />y tu <span class="gold-gradient-text">familia</span>
        </h2>
        <div class="gold-line w-24 mt-6"></div>

        <p class="mt-6 text-[color:var(--color-graphite-500)] leading-relaxed">
          Nacimos para resolver una necesidad real: llevar <strong>alimentos, medicinas y cariño</strong>
          a quienes más queremos, sin importar la distancia. Cada envío que gestionamos
          lleva el compromiso de llegar completo, a tiempo y con atención humana de principio a fin.
        </p>
        <p class="mt-4 text-[color:var(--color-graphite-500)] leading-relaxed">
          Trabajamos con destinos en <strong>Cuba, Venezuela, Bolivia, Perú y Ecuador</strong>
          porque sabemos que la <strong>familia</strong> no tiene fronteras.
          Nuestro equipo coordina cada etapa del envío para que tú solo tengas que preocuparte
          por elegir qué mandar.
        </p>

        <!-- Value pills -->
        <div class="mt-8 flex flex-wrap gap-3">
          {['Confianza', 'Rapidez', 'Acompañamiento', 'Seguridad'].map((v) => (
            <span class="px-4 py-2 rounded-full text-sm font-medium
                         text-[color:var(--color-rose-700)]
                         bg-[color:var(--color-rose-50)]
                         border border-[color:var(--color-rose-100)]">
              {v}
            </span>
          ))}
        </div>
      </div>

    </div>
  </div>
</section>
```

### 4. Deferred Data — Slice 2 Supabase binding

Contact data (email address and WhatsApp number) is **not hardcoded and not invented in Slice 1**. Every occurrence becomes a `#` href placeholder with an explicit inline comment:

```astro
{/* TODO(slice-2): fetch email from Supabase settings table */}
<a href="#">hola@rutalatinaexpress.com</a>

{/* TODO(slice-2): fetch WhatsApp number from Supabase settings table */}
<a href="#">WhatsApp</a>
```

Affected files:
- **`CTA.astro`**: The `hola@rutalatinaexpress.com` link `href` → `#` with TODO comment. Display text kept as-is for readability — it is not real data surfaced to users until Slice 2 wires the dynamic value.
- **`Footer.astro`**: Phone `href`, email `href`, and WhatsApp `href` all → `#` with TODO(slice-2) comments.

Slice 2 scope (out of bounds for this change): `SELECT email, whatsapp FROM settings WHERE key = 'contact'` → Astro SSR or Supabase Edge Function to inject values at render time.

---

## Section-by-Section Change Map

### Final render order in `index.astro`

```astro
<main>
  <Hero />           {/* 1 — keyword: +3 <strong> */}
  <Servicios />      {/* 2 — no copy changes, no voseo */}
  <ComoFunciona />   {/* 3 — 3 voseo fixes, +2 <strong> */}
  <Combos />         {/* 4 — 1 voseo fix (template + script), +1 <strong> */}
  <Destinos />       {/* 5 — no changes */}
  <QuienesSomos />   {/* 6 — NEW, +2 <strong> */}
  <CTA />            {/* 7 — 1 voseo fix, +2 <strong> */}
</main>
<Footer />           {/* 8 — full expansion */}
```

### Component-level change detail

| Component | Action | Voseo fixes | `<strong>` insertions | Copy changes |
|-----------|--------|-------------|----------------------|--------------|
| `Hero` | Modify | 0 | 3: `<strong>seguimiento en tiempo real</strong>`, `<strong>precios transparentes</strong>`, `<strong>entrega puerta a puerta</strong>` | None — existing copy already neutral |
| `Servicios` | No change | 0 | 0 | None |
| `ComoFunciona` | Modify | 3: `Elegí→Elige`, `Seleccioná→Selecciona`, `recibí→recibe` | 2: `<strong>combos</strong>`, `<strong>seguimiento</strong>` | Step descriptions rewritten in neutral Spanish |
| `Combos` | Modify | 1: `Elegí el combo ideal→Elige el combo ideal` (h2 + JS `cardHTML`) | 1: `<strong>precios en USD</strong>` | Also fix `Conectá→Conecta` in `<script>` status text |
| `Destinos` | No change | 0 | 0 | None |
| `QuienesSomos` | Create | 0 | 2: `alimentos, medicinas y cariño`, `Cuba, Venezuela, Bolivia, Perú y Ecuador` | All new copy — original to RLX |
| `CTA` | Modify | 1: `Escribinos→Escríbenos` | 2: `<strong>cotización personalizada</strong>`, `<strong>sin compromiso</strong>` | Kicker `Empezá hoy→Empieza hoy`; email href → `#` with TODO(slice-2) |
| `Footer` | Modify | 0 | 0 | Full rewrite; all contact hrefs → `#` with TODO(slice-2) comments |

**Keyword audit total: 10 `<strong>` wraps** across 5 components — within the 8-15 spec requirement.

Categories covered:
- Service names: `alimentos, medicinas y cariño`, `combos`, `precios en USD`
- Delivery/quality: `seguimiento en tiempo real`, `precios transparentes`, `seguimiento`, `cotización personalizada`
- Destinations: `Cuba, Venezuela, Bolivia, Perú y Ecuador`
- Emotional hooks: `entrega puerta a puerta`, `sin compromiso`

---

## Footer Expansion Design

```
┌──────────────────────────────────────────────────────┐
│  [Logo + Name]                                       │
├────────────┬──────────┬──────────┬───────────────────┤
│ Servicios  │ Nosotros │ Legal    │ Contacto           │
│ • Combos   │ • Q.S.   │ • T&C    │ 📞 # (TODO s2)     │
│ • Encomiend│ • Contacto│ • Priv. │ ✉ # (TODO s2)      │
│ • Express  │          │ • Cookies│ 💬 WhatsApp # (s2)  │
│ • Medicinas│          │          │ 📷 Instagram #      │
├────────────┴──────────┴──────────┴───────────────────┤
│  [VISA placeholder] [MC placeholder] [AMEX placeholder]│
├──────────────────────────────────────────────────────┤
│  © 2026 Ruta Latina Express. Todos los derechos...   │
└──────────────────────────────────────────────────────┘
```

Tailwind grid: `grid grid-cols-1 sm:grid-cols-2 md:grid-cols-4 gap-8`

Payment slots: `<div class="w-12 h-8 bg-gray-200 rounded flex items-center justify-center text-xs text-gray-500 font-medium">` with text labels (VISA, MC, AMEX) — no brand assets copied.

---

## Testing Strategy

| Layer | What | How |
|-------|------|-----|
| Build | No TypeScript errors, no missing imports | `astro build` must exit 0 |
| Visual typography | Roboto renders as body font; Cormorant on h1/h2/h3 | Manual check `astro dev` at 1440px and 375px — DevTools Computed > font-family |
| Visual pink | `<strong>` keywords render pink `#F20B68` | DevTools computed style: `color: rgb(242, 11, 104)` |
| Visual gold | `.hl-gold` spans render gold `#E5A817` | DevTools computed style: `color: rgb(229, 168, 23)` |
| Base colors | Body text is pure black on white background | DevTools computed: `color: rgb(0,0,0)`, background `rgb(255,255,255)` |
| Voseo elimination | Zero voseo imperatives | `grep -r "Elegí\|Seleccioná\|recibí\|Escribinos\|Escribí\|Empezá\|Conectá" src/` returns 0 |
| Section order | DOM order matches IA spec | Browser Elements panel inspection |
| Mobile footer | No overflow at 375px | DevTools device emulation |
| No broken Supabase | Destinos + Combos still load mock data | Visual check — cards render with flag emojis |
| Contact placeholders | No real email/phone in rendered HTML | `grep -r "hola@\|000000" src/` returns 0 after change |

---

## Threat Matrix

N/A — no routing, shell, subprocess, VCS/PR automation, executable-file classification, or process-integration boundary in this change.

---

## Migration / Rollout

No migration required. All changes are CSS additions and component edits on a single branch. No database schema changes. Rollback = `git revert` or branch deletion.

---

## Cross-cutting: Implementation Order

1. `global.css` — add 4-token brand palette (`--color-white/ink/pink/gold`) + `--font-sans` (Roboto) + `--font-display` (Cormorant) + global `body` (color+bg) + `h1-h3` rules + `strong` rule + `.hl-gold` utility class
2. `Layout.astro` — replace Google Fonts link with combined Cormorant+Roboto URL (Inter dropped)
3. `Footer.astro` — full expansion with `#` placeholders + TODO(slice-2) for contact data
4. `QuienesSomos.astro` — create new component
5. `ComoFunciona.astro` — voseo fixes + `<strong>` keywords
6. `Combos.astro` — voseo fix in template AND in `cardHTML` JS string
7. `CTA.astro` — voseo fix + `<strong>` keywords + email href → `#` with TODO(slice-2)
8. `Hero.astro` — `<strong>` keyword wraps only
9. `index.astro` — add QuienesSomos import, reorder sections to final IA

---

## Open Questions

All open questions resolved:

- ✅ **CTA email**: `hola@rutalatinaexpress.com` becomes `#` placeholder with `{/* TODO(slice-2): fetch from Supabase */}` — not hardcoded in Slice 1.
- ✅ **Dual-font strategy confirmed**: Cormorant Garamond (600/700) for display headings, Roboto (400/500/700) for body. Both from Google Fonts. `--font-display` token maps to Cormorant; `--font-sans` maps to Roboto.
- ✅ **Final palette confirmed (2026-08-09)**: white `#ffffff`, ink `#000000`, pink `#F20B68`, gold `#E5A817`. No Tailwind default scale. Pink applied via global `<strong>` rule; gold via `.hl-gold` utility class. WCAG tradeoff explicitly accepted by user.
