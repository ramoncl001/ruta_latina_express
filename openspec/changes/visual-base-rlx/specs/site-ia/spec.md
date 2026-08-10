# Delta for site-ia

## MODIFIED Requirements

### Requirement: Page Section Order

`src/pages/index.astro` MUST render sections in this exact sequence:

| # | Component | Status |
|---|-----------|--------|
| 1 | `Hero` | existing |
| 2 | `Servicios` | existing |
| 3 | `ComoFunciona` | existing, modified |
| 4 | `Combos` | existing, modified |
| 5 | `Destinos` | existing |
| 6 | `QuienesSomos` | new |
| 7 | `CTA` | existing, modified |
| 8 | `Footer` | existing, expanded |

(Previously: QuienesSomos absent; section order was Hero → Servicios → ComoFunciona → Combos → Destinos → CTA → Footer)

#### Scenario: Section render order

- GIVEN `index.astro` is compiled and served
- WHEN the DOM is inspected
- THEN section elements appear in the order: Hero, Servicios, ComoFunciona, Combos, Destinos, QuienesSomos, CTA, Footer
- AND no section from the approved IA is missing

#### Scenario: QuienesSomos positioned between Destinos and CTA

- GIVEN `index.astro` imports `QuienesSomos`
- WHEN rendered
- THEN `QuienesSomos` appears immediately after `Destinos` and before `CTA`

### Requirement: Neutral Spanish Copy — Voseo Elimination

All component copy MUST use neutral Spanish (`tú` forms or impersonal constructions). Voseo (vos, tenés, elegí, seleccioná, recibí, escribinos) MUST NOT appear in any rendered text.

Specific required replacements:

| File | Voseo form | Neutral replacement |
|------|-----------|---------------------|
| `Combos.astro` | Elegí | Elige |
| `ComoFunciona.astro` | Elegí | Elige |
| `ComoFunciona.astro` | Seleccioná | Selecciona |
| `ComoFunciona.astro` | recibí | recibe |
| `CTA.astro` | Escribinos | Escríbenos |

(Previously: 5 voseo imperatives present across 3 components)

#### Scenario: No voseo in rendered output

- GIVEN all components are rendered
- WHEN a text search is performed on the compiled HTML for `Elegí`, `Seleccioná`, `recibí`, `Escribinos`, `tenés`, `vos`
- THEN zero matches are found

#### Scenario: Replacement preserves meaning

- GIVEN `ComoFunciona.astro` step text is updated
- WHEN a Spanish speaker reads the step instructions
- THEN the instruction retains the same imperative intent (select, receive, write) in neutral register

### Requirement: Bold Keyword Distribution

Components MUST collectively contain 8–15 `<strong>` keyword wraps distributed across the page, covering these categories:

| Category | Examples |
|----------|---------|
| Service names | envíos, encomiendas, paquetes |
| Delivery times | en días, rápido, en tiempo |
| Country/destination names | Cuba, Venezuela, Bolivia, Perú, Ecuador |
| Emotional hooks | familia, confianza, tranquilidad, seguridad |

(Previously: zero `<strong>` elements on the page)

#### Scenario: Minimum keyword count

- GIVEN all modified and new components are rendered
- WHEN `<strong>` elements in body copy are counted
- THEN the count is between 8 and 15 inclusive

#### Scenario: Each category represented

- GIVEN the keyword audit
- WHEN categorized
- THEN at least one keyword from each of the four categories (service names, delivery times, destinations, emotional hooks) is wrapped in `<strong>`

#### Scenario: Keywords render pink

- GIVEN the `strong { color: var(--color-pink-500) }` global rule is active
- WHEN any keyword `<strong>` is rendered in body copy
- THEN its text color resolves to `--color-pink-500`
