# Delta for footer

## MODIFIED Requirements

### Requirement: Footer Column Structure

`src/components/Footer.astro` MUST render a multi-column layout with exactly these four grouped columns:

| Column | Contents |
|--------|----------|
| Servicios | Links to service types (envíos, encomiendas, combos) |
| Nosotros | Link to QuienesSomos anchor, about text anchor |
| Legal | Placeholder links: Términos y condiciones, Política de privacidad |
| Contacto | Phone placeholder, email placeholder, social links |

(Previously: single-line minimal footer with no columns, no contact info, no trust signals)

#### Scenario: Four columns render

- GIVEN `Footer.astro` is rendered
- WHEN its column structure is inspected
- THEN exactly four distinct column groups are visible: Servicios, Nosotros, Legal, Contacto

#### Scenario: Mobile layout does not overflow

- GIVEN a viewport width of 375px
- WHEN Footer renders
- THEN columns stack vertically with no horizontal overflow

### Requirement: Contact Placeholders

The Contacto column MUST contain placeholder items for phone and email using `#` as the href value, marked with a `<!-- TODO: replace with real contact info -->` HTML comment.

The system MUST NOT invent or display a real phone number or email address.

#### Scenario: Phone placeholder present

- GIVEN the Footer renders
- WHEN the Contacto column is inspected
- THEN a phone link exists with `href="#"` and a TODO comment in the source

#### Scenario: Email placeholder present

- GIVEN the Footer renders
- WHEN the Contacto column is inspected
- THEN an email link exists with `href="#"` and a TODO comment in the source

#### Scenario: No fabricated contact data

- GIVEN the Footer's rendered HTML
- WHEN searched for real-format phone numbers (e.g., `+1`, `+54`, digit sequences >6) or `@` email addresses
- THEN none are found

### Requirement: Payment Method Slots

The Footer MUST include a payment methods area with placeholder slots for Visa, MasterCard, and American Express indicators — implemented as SVG placeholders or icon-font placeholders, NOT as copied brand logos.

#### Scenario: Three payment slots render

- GIVEN the Footer renders
- WHEN the payment methods area is inspected
- THEN three labeled placeholder elements are visible (Visa, MasterCard, AmEx)

#### Scenario: No copied brand assets

- GIVEN the Footer source
- WHEN reviewed
- THEN no external `<img src>` pointing to payment brand CDNs or downloaded brand SVG files is present

### Requirement: Legal Placeholder Links

The Legal column MUST contain placeholder anchor elements for "Términos y condiciones" and "Política de privacidad" with `href="#"` and a TODO comment. No legal text SHALL be authored or displayed in this slice.

#### Scenario: Legal links render

- GIVEN the Footer renders
- WHEN the Legal column is inspected
- THEN both legal link labels are visible with `href="#"`
- AND each has a `<!-- TODO: link to real PDF/page -->` comment in source

### Requirement: Social Links

The Footer MUST include placeholder social link anchors (at minimum: WhatsApp, Instagram) with `href="#"` values and TODO comments. Icons MAY be emoji or icon-font glyphs.

#### Scenario: Social placeholders render

- GIVEN the Footer renders
- WHEN social links are inspected
- THEN at least two social platform links are visible with `href="#"` values

### Requirement: No Fabricated Business Data

The Footer MUST NOT display any invented business information including: street addresses, registration numbers, tax IDs, real phone numbers, or real email addresses.

#### Scenario: Audit for fabricated data

- GIVEN the Footer's full rendered content
- WHEN reviewed by a developer
- THEN every piece of contact or legal information is either a known TODO placeholder or a real value explicitly provided by the client
