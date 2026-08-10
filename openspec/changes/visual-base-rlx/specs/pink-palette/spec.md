# ⚠️ SUPERSEDED — Delta for pink-palette

> **Status**: SUPERSEDED by `specs/brand-palette/spec.md` (2026-08-09).
> The pink scale (`#ec4899` Tailwind default) described here has been replaced by the user-confirmed
> 4-token palette: `#ffffff` / `#000000` / `#F20B68` / `#E5A817`.
> This file is preserved for history. Do NOT implement from this spec — implement from `brand-palette/spec.md`.

---

# Delta for pink-palette (archived)

## ADDED Requirements

### Requirement: Pink Color Scale

The system MUST define a `--color-pink-{50,100,200,300,400,500,600,700,800,900}` scale as CSS custom properties inside the `@theme` block of `src/styles/global.css`, distinct from the existing `--color-rose-*` salmon scale.

| Token | Example use |
|-------|-------------|
| `--color-pink-50` | lightest tint, backgrounds |
| `--color-pink-500` | primary accent — `strong` text color |
| `--color-pink-900` | darkest shade |

#### Scenario: Scale defined alongside rose tokens

- GIVEN `global.css` contains `--color-rose-*` tokens
- WHEN a developer inspects the `@theme` block
- THEN `--color-pink-50` through `--color-pink-900` are present as separate tokens
- AND no pink value is reused as a rose value

#### Scenario: Pink-500 is accessible on white

- GIVEN `--color-pink-500` is the accent color
- WHEN rendered on a white (`#fff`) background
- THEN the contrast ratio MUST meet WCAG AA for large text (3:1) at minimum

### Requirement: Global Strong Color Rule

The system MUST define a global CSS rule `strong { color: var(--color-pink-500); font-weight: 700; }` in `src/styles/global.css`, outside of any scoped component style.

#### Scenario: Strong in body copy renders pink

- GIVEN any `<strong>keyword</strong>` inside a body content area (paragraph, list item, section prose)
- WHEN the page is rendered
- THEN the keyword text color resolves to `--color-pink-500`
- AND the font-weight is 700

#### Scenario: Rule does NOT apply inside interactive elements

- GIVEN a `<button>` or `<a>` inside `<nav>` that internally contains a `<strong>` element
- WHEN the element is rendered
- THEN the pink color SHOULD be overridden by the component's own color rule
- AND the interactive affordance (hover, focus) MUST remain visually correct

#### Scenario: Rule does NOT break headings

- GIVEN an `<h1>`–`<h6>` heading that is already bold by browser default
- WHEN the heading contains no `<strong>` child
- THEN the global `strong` rule does not alter the heading's color
- AND headings retain their existing color tokens

#### Scenario: Zero existing strong elements before keyword pass

- GIVEN the site has zero `<strong>` tags before this change is applied
- WHEN the global rule is added to `global.css`
- THEN no unintended color bleed occurs on the existing page
