# Proposal: Visual Base + Information Architecture (Slice 1)

**Change:** `visual-base-rlx`
**Date:** 2026-08-09
**Historical reference:** `openspec/changes/dual-lang-palette-refs/exploration.md` (obs #636)

---

## Intent

Ruta Latina Express currently lacks visual credibility and information hierarchy. The palette has no pink token, all copy uses Rioplatense voseo (5 instances), the page structure doesn't reflect the service portfolio clearly, and the footer has zero trust signals. This slice establishes the visual foundation (typography, pink palette, bold-keyword pattern) and restructures the single-page site to match a proven IA from a comparable shipping competitor — using RLX's own copy in neutral Spanish.

---

## Scope

### In Scope
- Adopt **Roboto** from Google Fonts via CSS-first Tailwind v4 config (`@theme`, `--font-*`, `display=swap`, preconnect in Layout.astro)
- Add `--color-pink-*` CSS custom property scale to `global.css`; add global `strong { color: var(--color-pink-500) }` rule
- Fix 5 voseo instances: `Combos.astro` (1), `ComoFunciona.astro` (3), `CTA.astro` (1)
- Reorganize `src/pages/index.astro` section order (see IA below)
- Write or rewrite copy for all sections in neutral Spanish (no voseo)
- Add `QuienesSomos.astro` — new emotional storytelling component
- Expand `Footer.astro` — contact, payment methods, legal placeholders, social links
- Wrap 8–15 keyword phrases in `<strong>` across components to activate pink highlight

### Out of Scope
- ❌ No English content, i18n routing, `/es/` or `/en/` prefixes (Slice 3)
- ❌ No Supabase copy migration (Slice 2)
- ❌ No visual identity clone of granazul.com (colors, layout pixels, font family)
- ❌ No Supabase schema changes
- ❌ No admin panel
- ❌ No hero carousel (deferred per exploration)

---

## Target Information Architecture

| # | Section | Notes |
|---|---------|-------|
| 1 | **Hero** | Static emotional headline + trust signals. No carousel. |
| 2 | **Servicios principales** | Adapted tiles for RLX real offerings |
| 3 | **Cómo funciona** | Numbered 1/2/3 steps (voseo → neutral) |
| 4 | **Combos / Cajas destacadas** | RLX combo offerings (voseo → neutral) |
| 5 | **Destinos** | 5 countries from Supabase |
| 6 | **Quiénes somos** | NEW — emotional storytelling, "un puente entre tú y tu familia" |
| 7 | **CTA final** | (voseo → neutral) |
| 8 | **Footer robusto** | Payment methods, legal placeholders, social, phone, email |

---

## Capabilities

### New Capabilities
- `quienes-somos`: Emotional storytelling section — new `QuienesSomos.astro` component

### Modified Capabilities
- `typography-tokens`: Roboto font wired through Tailwind v4 `@theme` and Layout head
- `pink-palette`: `--color-pink-*` scale + global `strong` color rule in `global.css`
- `footer`: Expanded from single-line to rich trust-signal footer
- `site-ia`: Section order and copy reorganized per approved IA

---

## Approach

1. **`global.css` first** — add Roboto `@import`, `--font-*` tokens, `--color-pink-*` scale, `strong` rule. Zero component risk.
2. **Layout.astro** — add `<link rel="preconnect">` + `<link rel="stylesheet">` for Google Fonts.
3. **Voseo pass** — replace the 5 flagged imperatives with neutral equivalents before touching structure.
4. **IA reorganization** — reorder sections in `index.astro`, write new copy per section in neutral Spanish.
5. **`QuienesSomos.astro`** — new component, inserted between ComoFunciona and CTA.
6. **Footer expansion** — add columns: contact, payment icons (SVG/emoji), legal links, social.
7. **Bold keywords** — wrap 8–15 phrases in `<strong>` across Hero, ComoFunciona, CTA, QuienesSomos.

---

## Affected Areas

| Area | Impact | Description |
|------|--------|-------------|
| `src/styles/global.css` | Modified | Roboto import, `--font-*`, `--color-pink-*`, `strong` rule |
| `src/layouts/Layout.astro` | Modified | Google Fonts preconnect + stylesheet link |
| `src/pages/index.astro` | Modified | Section reorder + new QuienesSomos inclusion |
| `src/components/Combos.astro` | Modified | Voseo fix (Elegí → Elige) |
| `src/components/ComoFunciona.astro` | Modified | Voseo fix × 3; renumbered steps; `<strong>` keywords |
| `src/components/CTA.astro` | Modified | Voseo fix (Escribinos → Escríbenos); `<strong>` |
| `src/components/Hero.astro` | Modified | `<strong>` keywords in body copy |
| `src/components/Footer.astro` | Modified | Full expansion — contact, payment, legal, social |
| `src/components/QuienesSomos.astro` | New | Emotional storytelling section |

---

## Risks

| Risk | Likelihood | Mitigation |
|------|------------|------------|
| Global `strong` rule bleeds into structural bold (headings) | Low | Current site has zero `<strong>` usage — safe to add; verify after keyword pass |
| Roboto load adds render-blocking latency | Low | `display=swap` + preconnect prevents FOIT; Roboto is CDN-cached globally |
| Copy rewrite changes meaning unintentionally | Medium | Use neutral Spanish register; preserve all service facts (prices, times, countries) |
| Footer expansion breaks mobile layout | Medium | Build mobile-first, test at 375px before desktop |

---

## Rollback Plan

All changes are additive CSS + component edits on a single branch. Rollback = revert branch. No DB migrations, no routing changes, no config changes that affect the Astro build contract. CSS token additions are non-breaking by nature.

---

## Dependencies

- Google Fonts CDN availability (Roboto) — production dependency; fallback: `system-ui, sans-serif`
- Supabase `paises` table intact (Destinos section reads it; no schema changes required)

---

## Success Criteria

- [ ] Roboto renders as body font across all sections (verified visually at 1440px and 375px)
- [ ] `--color-pink-500` renders on every `<strong>` element in body copy
- [ ] Zero voseo imperatives in page copy (grep confirms: no `Elegí`, `Seleccioná`, `recibí`, `Escribinos`)
- [ ] Page renders sections in the approved IA order (Hero → Servicios → ComoFunciona → Combos → Destinos → QuienesSomos → CTA → Footer)
- [ ] `QuienesSomos.astro` exists and renders emotional copy in neutral Spanish
- [ ] Footer contains: at least one contact method, payment method indicators, legal placeholder links, social links
- [ ] 8+ `<strong>` keyword phrases visible across the page, all rendering pink
- [ ] No console errors, no broken Supabase queries, no layout overflow at mobile

---

## Future Slices (for context)

- **Slice 2** — Migrate hardcoded copy → Supabase `sections` / `section_content` tables; components read from DB at build time; single language still.
- **Slice 3** — Add `locale` dimension; Astro native i18n with `/es/` + `/en/` prefixes; hreflang tags; English translation of all Supabase-backed copy.
