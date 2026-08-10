# Delta for typography-tokens

## MODIFIED Requirements

### Requirement: Font Family Token

The system MUST define `--font-sans` (and optionally `--font-body`) as a CSS custom property in `global.css` under the Tailwind v4 `@theme` block, resolving to `Roboto, system-ui, Arial, sans-serif`.
(Previously: no explicit font token; browser/system default applied)

#### Scenario: Token defined in @theme

- GIVEN `src/styles/global.css` is imported by the Astro layout
- WHEN the browser parses the stylesheet
- THEN `--font-sans` resolves to a font stack beginning with `Roboto`

#### Scenario: Fallback on font load failure

- GIVEN the Google Fonts CDN is unavailable
- WHEN the browser renders body text
- THEN the computed font-family falls back to `system-ui` or `Arial` with no visible layout break

### Requirement: Google Fonts Loading

The system MUST load Roboto via Google Fonts with a `<link rel="preconnect">` to `https://fonts.googleapis.com` and `https://fonts.gstatic.com` (crossorigin) placed before the stylesheet `<link>` in `<head>`, with `display=swap` in the font URL query string.
(Previously: no external font link in Layout.astro head)

#### Scenario: Preconnect hints present

- GIVEN `src/layouts/Layout.astro` is rendered
- WHEN the browser parses `<head>`
- THEN two `<link rel="preconnect">` tags to Google Fonts origins appear before the font `<link rel="stylesheet">`

#### Scenario: display=swap prevents FOIT

- GIVEN Roboto has not yet been downloaded by the browser
- WHEN the page first paints
- THEN fallback font is shown immediately (no invisible text during font load)
- AND once Roboto loads, text swaps with no Cumulative Layout Shift

#### Scenario: No render-blocking

- GIVEN a slow connection where Roboto takes >200 ms
- WHEN the browser renders the page
- THEN body text is visible using the fallback stack before Roboto arrives

### Requirement: Layout Head Integration

The system MUST insert font-loading markup exclusively in `src/layouts/Layout.astro` inside the `<head>` slot so that all pages inherit it without per-component duplication.
(Previously: Layout.astro had no font-loading concerns)

#### Scenario: Single source of truth

- GIVEN multiple Astro pages using `Layout.astro`
- WHEN any page is rendered
- THEN the Roboto font links appear exactly once per HTML document
