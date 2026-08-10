# Delta for brand-palette

> **Supersedes**: `specs/pink-palette/` — that capability spec covered only a pink scale (Tailwind default `#ec4899`).
> This spec replaces it with the user-confirmed 4-token palette (white, ink, pink, gold).

---

## ADDED Requirements

### Requirement: Brand Color Tokens

The system MUST define four semantic color tokens inside the `@theme` block of `src/styles/global.css`.

| Token | Hex | Semantic use |
|-------|-----|-------------|
| `--color-white` | `#ffffff` | Page background, surface fills |
| `--color-ink` | `#000000` | Body text |
| `--color-pink` | `#F20B68` | Emotional / people-oriented keyword highlights (see Category Mapping) |
| `--color-gold` | `#E5A817` | Time / precision / value keyword highlights (see Category Mapping) |

> **Note on scale**: No full 10-step scale is required for Slice 1. Only one shade per accent is used.
> Tint/shade variants (`--color-pink-light`, `--color-gold-light`, etc.) MAY be added in later slices
> if hover states require them — out of scope here.

#### Scenario: All four tokens present

- GIVEN `global.css` contains an `@theme` block
- WHEN a developer inspects the `@theme` block
- THEN `--color-white`, `--color-ink`, `--color-pink`, and `--color-gold` are all present
- AND each token resolves to its exact hex value: `#ffffff`, `#000000`, `#F20B68`, `#E5A817`

---

### Requirement: Global Base Rules

The system MUST define global CSS rules in `src/styles/global.css`:

```css
body {
  color: var(--color-ink);
  background: var(--color-white);
}
```

#### Scenario: Body renders black text on white background

- GIVEN the global base rules are defined
- WHEN any page is rendered
- THEN `body` computed color = `rgb(0, 0, 0)` and background = `rgb(255, 255, 255)`

---

### Requirement: Global Strong Color Rule (Pink)

The system MUST define `strong { color: var(--color-pink); font-weight: 700; }` in `src/styles/global.css`, outside any scoped component style.

> **Contrast note**: `#F20B68` on white = ~4.4:1 contrast ratio. This is below WCAG AA for small text (4.5:1) but
> meets AA for large/bold text (3:1). `<strong>` is bold text (700 weight), so perceptual contrast is acceptable.
> The user explicitly accepted this tradeoff — do NOT modify the hex to increase contrast.

#### Scenario: `<strong>` renders pink

- GIVEN any `<strong>keyword</strong>` inside a body content area
- WHEN the page is rendered
- THEN computed color = `#F20B68` (i.e., `rgb(242, 11, 104)`)
- AND font-weight = 700

#### Scenario: Rule does NOT apply inside interactive elements

- GIVEN a `<button>` or `<a>` inside `<nav>` that contains a `<strong>` element
- WHEN the element is rendered
- THEN the component's own color rule overrides the pink
- AND hover/focus affordance remains visually correct

#### Scenario: Rule does NOT break headings

- GIVEN an `<h1>`–`<h6>` that contains no `<strong>` child
- WHEN the heading is rendered
- THEN the global `strong` rule does not alter the heading's color

#### Scenario: Zero pre-existing `<strong>` before keyword pass

- GIVEN the site has zero `<strong>` tags before this change is applied
- WHEN the global rule is added
- THEN no unintended color bleed occurs on the existing page

---

### Requirement: `.hl-gold` Utility Class (Gold)

The system MUST define a utility class in `src/styles/global.css`:

```css
.hl-gold {
  color: var(--color-gold);
  font-weight: 700;
}
```

Authors apply it manually: `<span class="hl-gold">24-48 horas</span>`.

> **Rationale for class vs. tag**: There is no HTML semantic element for "time/precision keyword".
> Using a utility class keeps authoring intent explicit. Pink IS applied via global `<strong>`
> because `<strong>` semantically fits emotional emphasis — the two mechanisms are complementary.

#### Scenario: `.hl-gold` renders gold

- GIVEN any `<span class="hl-gold">24-48 horas</span>` in body copy
- WHEN the page is rendered
- THEN computed color = `#E5A817` (i.e., `rgb(229, 168, 23)`)
- AND font-weight = 700

---

## Highlight Category Mapping

Authors must follow this table when deciding which accent to use. Design reviews will check keyword classification.

| Category | Accent | Hex | Examples |
|----------|--------|-----|---------|
| **Warmth / Identity** — emotional, people, service names | Pink `<strong>` | `#F20B68` | "tu familia", "seres queridos", "puerta a puerta", "confianza", "Combos", "Envíos", "Destinos", country names |
| **Performance / Tangible** — time, price, guarantees, precision | Gold `.hl-gold` | `#E5A817` | "24-48 horas", delivery windows, prices, "garantía", "seguimiento en tiempo real", numeric emphasis |

Rule of thumb: **pink = warmth/identity**, **gold = performance/tangible**.

---

## UNCHANGED Tokens (preserved from previous design)

The existing `--color-rose-*` salmon scale remains as-is. No rose tokens are removed or modified.
