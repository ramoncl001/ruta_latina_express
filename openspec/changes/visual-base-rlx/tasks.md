# Tasks: Visual Base + Information Architecture (visual-base-rlx)

## Review Workload Forecast

| Field | Value |
|-------|-------|
| Estimated changed lines | ~350–500 (global.css ~60, Layout.astro ~15, Footer.astro ~120, QuienesSomos.astro ~80 new, ComoFunciona ~30, Combos ~25, CTA ~25, Hero ~20, index.astro ~30) |
| 400-line budget risk | Medium-High (added gold class + doubled highlight pass adds ~50–70 lines vs. prior estimate; comfortably under 800) |
| 800-line budget risk | Low |
| Chained PRs recommended | No — single slice, single PR is appropriate |
| Suggested split | Single PR (slice 1 of 3; chaining is across slices, not within) |
| Delivery strategy | auto-forecast → single PR, no decision gate required |
| Chain strategy | N/A (already a named slice; stacked-to-main applies at slice level) |

Decision needed before apply: No
Chained PRs recommended: No
Chain strategy: stacked-to-main
400-line budget risk: Medium-High
800-line budget risk: Low

### Suggested Work Units

| Unit | Goal | Likely PR | Focused test command | Runtime harness | Rollback boundary |
|------|------|-----------|----------------------|-----------------|-------------------|
| 1 | Typography + brand palette (4 tokens) + global CSS foundation | PR 1 (this slice) | `astro build` exit 0 | `astro dev` → DevTools Computed font-family on body/h2 + color on `strong`/`.hl-gold` | `global.css` + `Layout.astro` only; revert 2 files |
| 2 | Footer + QuienesSomos + component edits + IA reorder | PR 1 (same, continued) | `astro build` exit 0 + voseo grep returns 0 | `astro dev` → 1440px + 375px visual check | All component files; revert independently per file |

---

## Phase 1: Typography Wiring

- [x] 1.1 **`src/styles/global.css`** — inside the existing `@theme` block, add `--font-sans: "Roboto", ui-sans-serif, system-ui, Arial, sans-serif;` and `--font-display: "Cormorant Garamond", Georgia, "Times New Roman", serif;`. Acceptance: both tokens visible in DevTools CSS custom properties panel.

- [x] 1.2 **`src/styles/global.css`** — below the `@theme` block, add global rules: `body { font-family: var(--font-sans); }` and `h1, h2, h3 { font-family: var(--font-display); }`. Acceptance: `body` computed font-family = Roboto; `h2` computed font-family = Cormorant Garamond (DevTools > Computed).

- [x] 1.3 **`src/layouts/Layout.astro`** — replace the existing Google Fonts `<link>` (currently loads Cormorant + Inter) with: two `<link rel="preconnect">` tags (googleapis.com, gstatic.com crossorigin) + one combined stylesheet URL loading `Cormorant+Garamond:wght@600;700` and `Roboto:wght@400;500;700` with `display=swap&subset=latin`. Drop Inter entirely. Acceptance: `<head>` source shows exactly one font stylesheet `<link>`; URL contains both `Cormorant` and `Roboto`; `Inter` does not appear.

---

## Phase 2: Brand Palette + Strong Rule + Gold Utility

- [x] 2.1 **`src/styles/global.css`** — inside the `@theme` block, add the four brand tokens: `--color-white: #ffffff`, `--color-ink: #000000`, `--color-pink: #F20B68`, `--color-gold: #E5A817`. Acceptance: all four tokens visible in DevTools CSS custom properties panel with exact hex values.

- [x] 2.2 **`src/styles/global.css`** — update the `body` rule to include `color: var(--color-ink); background: var(--color-white);` (add to existing `font-family` declaration). Add global rule `strong { color: var(--color-pink); font-weight: 700; }`. Acceptance: body computed color = `rgb(0,0,0)`, background = `rgb(255,255,255)`; after any `<strong>` tag is added in Phase 4+, computed color = `rgb(242, 11, 104)`.

- [x] 2.3 **`src/styles/global.css`** — add utility class `.hl-gold { color: var(--color-gold); font-weight: 700; }`. Acceptance: a test element `<span class="hl-gold">test</span>` in any component resolves to computed color `rgb(229, 168, 23)` and font-weight 700.

---

## Phase 3: Footer Expansion

- [x] 3.1 **`src/components/Footer.astro`** — rewrite to 4-column grid: `grid grid-cols-1 sm:grid-cols-2 md:grid-cols-4 gap-8`. Columns: Servicios (Combos, Encomiendas, Express, Medicinas links with `href="#"`), Nosotros (QuienesSomos anchor, Contacto link with `href="#"`), Legal (Términos y condiciones + Política de privacidad, both `href="#"` with `{/* TODO: link to real PDF/page */}` comments), Contacto (phone, email, WhatsApp, Instagram — all `href="#"` with `{/* TODO(slice-2): fetch from Supabase */}` inline comments). Acceptance: four distinct column headers visible; no real phone/email in rendered HTML; `grep -r "hola@\|+1\|+54" src/components/Footer.astro` returns 0.

- [x] 3.2 **`src/components/Footer.astro`** — add payment method placeholder row: three `<div>` elements labeled VISA, MC, AMEX using `bg-gray-200 rounded` styling. No external `<img>` or brand SVG files. Acceptance: three payment placeholder elements visible; no external image src in footer source.

- [x] 3.3 **`src/components/Footer.astro`** — add copyright line: `© 2026 Ruta Latina Express. Todos los derechos reservados.`. Acceptance: copyright text visible in footer.

---

## Phase 4: QuienesSomos Component

- [x] 4.1 **`src/components/QuienesSomos.astro`** — create new file using the contract from design.md §3. Section id `quienes-somos`, 2-column grid (image left / text right on desktop), image placeholder `<div>` with emoji 🌎, h2 with `.font-display`, gold kicker label, two body paragraphs with `<strong>` on `alimentos, medicinas y cariño` and `Cuba, Venezuela, Bolivia, Perú y Ecuador`, four value pills (Confianza, Rapidez, Acompañamiento, Seguridad). Acceptance: `astro build` passes; component renders in isolation via `astro dev`.

---

## Phase 5: Voseo Cleanup — Component Edits

- [x] 5.1 **`src/components/ComoFunciona.astro`** — fix 3 voseo imperatives: `Elegí → Elige`, `Seleccioná → Selecciona`, `recibí → recibe`. Rewrite step descriptions in neutral Spanish. Add `<strong>combos</strong>` and `<strong>seguimiento</strong>` to relevant step text. Acceptance: `grep "Elegí\|Seleccioná\|recibí" src/components/ComoFunciona.astro` returns 0; two `<strong>` tags present.

- [x] 5.2 **`src/components/Combos.astro`** — fix voseo in template h2: `Elegí el combo ideal → Elige el combo ideal`. Also fix the same phrase inside the `<script>` block's `cardHTML` JS string. Fix `Conectá → Conecta` in script status text. Add `<strong>precios en USD</strong>` to relevant copy. Acceptance: `grep "Elegí\|Conectá" src/components/Combos.astro` returns 0; one `<strong>` tag present.

- [x] 5.3 **`src/components/CTA.astro`** — fix voseo: `Escribinos → Escríbenos`, kicker `Empezá hoy → Empieza hoy`. Add `<strong>cotización personalizada</strong>` and `<strong>sin compromiso</strong>`. Replace `href="mailto:hola@rutalatinaexpress.com"` with `href="#"` and add `{/* TODO(slice-2): fetch from Supabase */}` inline comment above the link. Acceptance: `grep "Escribinos\|Empezá\|hola@" src/components/CTA.astro` returns 0; two `<strong>` tags present.

- [x] 5.4 **`src/components/Hero.astro`** — wrap three keyword phrases in `<strong>`: `seguimiento en tiempo real`, `precios transparentes`, `entrega puerta a puerta`. No other copy changes. Acceptance: three `<strong>` tags present in Hero; existing copy otherwise unchanged.

---

## Phase 6: Site IA Reorder + Keyword Audit (Pink + Gold)

- [x] 6.1 **`src/pages/index.astro`** — add `import QuienesSomos from '../components/QuienesSomos.astro';` at the top of the frontmatter. Reorder `<main>` children to match the design IA: Hero → Servicios → ComoFunciona → Combos → Destinos → QuienesSomos → CTA. `<Footer />` outside `<main>`. Acceptance: DOM order in browser Elements panel matches spec sequence; `QuienesSomos` section visible at 1440px.

- [x] 6.2 **Pink `<strong>` coverage check** — verify all pink keyword wraps are present (warmth/identity category). Target list:
  - `seguimiento en tiempo real` → `<span class="hl-gold">` (move to gold — see 6.3; remove from here if previously marked pink)
  - `precios transparentes` → `<strong>` (Hero) — **keep pink**: emotional brand promise
  - `entrega puerta a puerta` → `<strong>` (Hero) — **pink**: identity/service
  - `combos` → `<strong>` (ComoFunciona) — **pink**: service name
  - `seguimiento` → `<span class="hl-gold">` (ComoFunciona — see 6.3)
  - `alimentos, medicinas y cariño` → `<strong>` (QuienesSomos) — **pink**: emotional/people
  - `Cuba, Venezuela, Bolivia, Perú y Ecuador` → `<strong>` (QuienesSomos) — **pink**: country names (warmth/identity)
  - `cotización personalizada` → `<strong>` (CTA) — **pink**: service/people
  - `sin compromiso` → `<strong>` (CTA) — **pink**: emotional/trust
  - `precios en USD` → `<span class="hl-gold">` (Combos — see 6.3)

  Acceptance: `grep -r "<strong>" src/components/ | wc -l` returns ≥ 7. **Result: 8 ✓**

- [x] 6.3 **Gold `.hl-gold` coverage** — wrap performance/tangible keywords with `<span class="hl-gold">`:
  - `seguimiento en tiempo real` → `<span class="hl-gold">seguimiento en tiempo real</span>` (Hero)
  - `seguimiento` → `<span class="hl-gold">seguimiento</span>` (ComoFunciona step)
  - `precios en USD` → `<span class="hl-gold">precios en USD</span>` (Combos)
  - `24-48 horas` (if present in any copy) → `<span class="hl-gold">` automatically

  Acceptance: `grep -r "hl-gold" src/components/ | wc -l` returns ≥ 3. **Result: 4 ✓**

- [x] 6.4 **Total keyword coverage check** — combined pink + gold count. Acceptance: `grep -rE "(<strong>|hl-gold)" src/components/ | wc -l` returns ≥ 10. **Result: 12 ✓**

---

## Phase 7: Build + Voseo Grep Verification

- [x] 7.1 Run `astro build` — must exit 0 with no TypeScript errors and no missing import errors. Acceptance: build output shows "build complete" or equivalent; no error lines. **Result: exit 0 ✓ "1 page(s) built in 1.22s"**

- [x] 7.2 Run voseo elimination grep: `grep -r "Elegí\|Seleccioná\|recibí\|Escribinos\|Escribí\|Empezá\|Conectá" src/` must return 0 results. Acceptance: command exits with no matches. **Result: 0 matches ✓**

- [x] 7.3 Run contact data grep: `grep -r "hola@\|@rutalatina\|000000" src/` must return 0 results. Acceptance: command exits with no matches. **Result: 0 matches ✓**

---

## Phase 8: Manual Visual Check

- [ ] 8.1 At 1440px — verify: Roboto renders as body font in DevTools Computed; Cormorant Garamond renders on h2 headings; `<strong>` keywords appear in pink (`rgb(242, 11, 104)`); `.hl-gold` spans appear in gold (`rgb(229, 168, 23)`); body text is pure black on white; QuienesSomos section visible between Destinos and CTA; footer shows 4 columns; three payment placeholders visible.

- [ ] 8.2 At 375px — verify: footer columns stack vertically with no horizontal overflow; QuienesSomos image placeholder stacks above text; no text truncation on CTAs.

- [ ] 8.3 Destinos + Combos smoke check — confirm both components still render cards with flag emojis and no console errors (Supabase mock data unaffected).
