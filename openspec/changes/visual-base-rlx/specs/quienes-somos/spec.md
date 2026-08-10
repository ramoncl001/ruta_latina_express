# QuienesSomos Specification

## Purpose

Emotional storytelling section that establishes brand trust for Ruta Latina Express. Positioned between Destinos and CTA in the single-page layout. Copy MUST be original, warm, neutral Spanish — not voseo, not Rioplatense, not a copy of any competitor's content.

## Requirements

### Requirement: Component Existence

The system MUST include `src/components/QuienesSomos.astro` as a new Astro component.

#### Scenario: Component renders without errors

- GIVEN `QuienesSomos.astro` is imported in `index.astro`
- WHEN the page is compiled by Astro
- THEN no build errors occur and the component outputs valid HTML

### Requirement: Emotional Storytelling Structure

`QuienesSomos.astro` MUST contain all of the following structural elements:

| Element | Requirement |
|---------|-------------|
| Headline | Short (≤10 words), emotionally resonant, neutral Spanish |
| Body paragraph | 2–4 sentences, warm tone, references the bridge between sender and family |
| Value pills or benefit list | 3–4 items (e.g., Confianza, Rapidez, Acompañamiento, Seguridad) |
| Image slot | Optional — an `<img>` or placeholder `<div>` for a future team/brand photo |

#### Scenario: Headline is present and neutral

- GIVEN the component renders
- WHEN its headline text is inspected
- THEN it contains no voseo forms and reads naturally in neutral Spanish

#### Scenario: Value pills render

- GIVEN the component renders
- WHEN the value pill or benefit list is inspected
- THEN 3 to 4 distinct value items are visible

#### Scenario: Image slot is present

- GIVEN the component renders
- WHEN the image area is inspected
- THEN either an `<img>` element or a placeholder `<div>` with a TODO comment is present

### Requirement: Bold Keyword Integration

`QuienesSomos.astro` MUST wrap at least 2 keyword phrases in `<strong>` — drawn from the emotional hooks or destination categories defined in `site-ia`.

#### Scenario: Keywords present and pink

- GIVEN the component is rendered with the global `strong` rule active
- WHEN `<strong>` elements inside `QuienesSomos` are inspected
- THEN at least 2 are present and their text color resolves to `--color-pink-500`

### Requirement: Original Copy

Copy in `QuienesSomos.astro` MUST be original to this project. It MUST NOT reproduce verbatim sentences from any competitor website (e.g., granazul.com/es or similar).

#### Scenario: No verbatim competitor copy

- GIVEN the component's text content
- WHEN compared against known competitor copy patterns
- THEN no full sentence matches a competitor's "Quiénes somos" or "About us" section

### Requirement: Page Placement

`QuienesSomos.astro` MUST be imported and rendered in `src/pages/index.astro` between the `Destinos` section and the `CTA` section.

#### Scenario: Correct placement in DOM

- GIVEN `index.astro` is rendered
- WHEN the DOM order of sections is inspected
- THEN `QuienesSomos` appears after `Destinos` and before `CTA`
