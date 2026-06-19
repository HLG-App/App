brand: Her Long Game
version: 5.1
updated: 2026-06-19
format: design.md
maintainer: B&CO GROUP PTY LTD (ACN 698 821 233)
entity: herlonggame.com.au

colors:
  # Source of truth: HerLongGame-BrandGuidelines-2026.pptx
  # --night and --moss are NOT brand colours and must never appear
  # --soft-gold is NOT a brand colour — use --gold only

  primary:
    sage-deep:  "#5C7A62"   # Deep Sage — Primary UI, CTAs, key interactive elements | WCAG on cream: ~5.1:1 ✓ AA all sizes
    sage:       "#7A9279"   # Sage — Secondary, hover states, gradients, borders | WCAG on cream: ~3.5:1 (large text only)
    gold:       "#B8923A"   # Crown Gold — Accent, eyebrows, highlights, stat values | WCAG on cream: ~2.8:1 — decorative only, never body text
    cream:      "#F7F5F0"   # Warm Cream — Primary background, card surfaces, nav

  supporting:
    orange:     "#D4621A"   # Horizon Orange — Secondary CTAs, accent only (under 10% visual weight) | WCAG on cream: ~4.8:1 ✓ AA
    rose:       "#C4756A"   # Antique Rose — Error states, destructive actions, warmth callouts
    sage-mid:   "#8A9E8D"   # Sage Mid — Placeholder text and muted captions ONLY | WCAG on cream: ~3.1:1 — FAILS AA at body sizes
                            # RULE: sage-mid must not be used for body text or labels under 1rem — use sage-deep for readable text

  derived:
    cream-warm: "#F2EFE8"   # Slightly deeper cream — input fields, alternate rows
    sage-tint:  "rgba(92,122,98,0.12)"   # Card borders, dividers, subtle separators

  semantic:
    error:      "#C4756A"   # Antique Rose — validation errors, destructive actions
    success:    "#5C7A62"   # Sage Deep — success confirmations
    warning:    "#D4621A"   # Horizon Orange — warnings, nudges
    focus-ring: "#5C7A62"   # Sage Deep — replaces browser default blue on all elements

  forbidden:
    - "#161E17"   # --night — REMOVED. Never use as dark surface.
    - "#1C1B19"   # --night retuned variant — also removed, same reason
    - "#2C4A3E"   # --moss — REMOVED
    - "#2A3A2C"   # --night-mid — REMOVED
    - "#2E2C29"   # --night-mid retuned variant — also removed
    - "#000000"   # Pure black — never use

  dark-surfaces:
    note: "Dark section backgrounds use sage-deep (#5C7A62) only — hero, stats strip, final CTA, footer"
    allowed: ["#5C7A62"]
    forbidden: ["any --night variant", "any --moss variant", "pure black #000000"]

  proportions:
    sage-deep:  "60-70% visual weight — dominant brand colour"
    orange:     "under 10% — accent only, never primary CTA"
    gold:       "accent — eyebrows, highlights, stat values (decorative)"
    cream:      "primary surface throughout"

  contrast-rules:
    - "sage-deep on cream: ~5.1:1 — passes AA for all text sizes ✓"
    - "cream on sage-deep: ~5.1:1 — passes AA for all text sizes ✓"
    - "orange on cream: ~4.8:1 — passes AA ✓"
    - "sage on cream: ~3.5:1 — large text (1.1rem bold+) only"
    - "gold on sage-deep: ~3.2:1 — eyebrows and large decorative text only"
    - "sage-mid on cream: ~3.1:1 — FAILS AA. Placeholders and captions only, never body/labels"
    - "gold on cream: ~2.8:1 — FAILS AA. Decorative eyebrows only, never body text"

typography:
  display:
    family:     "Playfair Display, serif"
    weights:    [400, 700]
    styles:     [normal, italic]
    usage:      "Headlines, hero titles, section titles, card titles, pull quotes"
    note:       "Italic used for emphasis phrases within headlines — never body copy"

  body:
    family:     "DM Sans, sans-serif"
    weights:    [300, 400, 500, 600]
    usage:      "All body copy, UI labels, navigation, buttons, captions, inputs, legal text"
    note:       "DM Sans handles all functional text — Playfair is display only"

  scale:
    hero:       "clamp(2.1rem, 6.5vw, 4.8rem)"
    feature:    "clamp(1.95rem, 5vw, 3.6rem)"
    section:    "clamp(1.65rem, 4.5vw, 3.2rem)"
    h2:         "clamp(1.25rem, 2.5vw, 1.5rem)"
    callout:    "clamp(1.05rem, 2vw, 1.2rem)"
    card-title: "clamp(1rem, 1.8vw, 1.1rem)"
    body-lg:    "clamp(0.95rem, 1.5vw, 1rem)"
    body:       "0.95rem"
    small:      "0.85rem"
    label:      "0.72rem"
    micro:      "0.625rem"

  eyebrow:
    family:     "DM Sans, sans-serif"
    size:       "0.65rem"
    weight:     500
    tracking:   "0.2em"
    transform:  "uppercase"
    color:      "gold (#B8923A)"

spacing:
  base-unit:    "0.5rem (8px)"
  section-gap:  "clamp(4rem, 8vw, 8rem)"
  container:    "max-width 760px, 1rem side padding mobile / 2rem desktop"
  card-padding: "1.25rem–1.5rem"
  safe-area:
    top:        "env(safe-area-inset-top)"
    bottom:     "env(safe-area-inset-bottom)"
  border-radius:
    card:       "0.75rem"
    button:     "0.5rem"
    input:      "0.5rem"
    badge:      "1.25rem"
    tag:        "0.375rem"

z-index:
  base:         0
  raised:       10
  sticky:       100
  overlay:      200
  modal:        300
  toast:        400

flutter-token-map:
  sage-deep:    "HLGColors.sageDark"
  sage:         "HLGColors.sage"
  sage-mid:     "HLGColors.sageMid"
  gold:         "HLGColors.crownGold"
  cream:        "HLGColors.cream"
  orange:       "HLGColors.horizonOrange"
  rose:         "HLGColors.antiqueRose"
  cream-warm:   "HLGColors.creamWarm"
  sage-tint:    "HLGColors.sageTint"

anti-patterns:
  colors:
    - "Never use --night, --moss, or any dark near-black as a surface or background"
    - "Never use --soft-gold — use --gold (#B8923A) only"
    - "Never use orange as primary CTA — sage-deep leads at 60-70% visual weight"
    - "Never let orange exceed 10% visual weight on any page"
    - "Never use pure black (#000000)"
    - "Never use sage-mid for body text or labels — placeholder and muted captions only"
    - "Never use gold (#B8923A) as body text on any surface — ~2.8:1 fails WCAG AA"
  typography:
    - "Never use Playfair Display for body copy"
    - "Never use gold as body text"
  inputs:
    - "Never set input background same as card background"
    - "Never soften input border below rgba(92,122,98,0.3)"
  interactive:
    - "Never remove focus rings — sage-deep outline 3px"
    - "Never resize a button during loading — swap label for spinner"
    - "Never show a blank space during async load — always skeleton"
  motion:
    - "Never stagger more than 6 items"
    - "Never animate layout-affecting properties"
  copy:
    - "No em dashes"
    - "No emoji in UI — use Lucide icons"
    - "No Heroicons — Lucide is the only icon library"

legal:
  entity:         "B&CO GROUP PTY LTD"
  acn:            "698 821 233"
  abn:            "91 698 821 233"
  address:        "2/290 Boundary Street Spring Hill QLD 4000"
  disclaimer:     "Her Long Game content is for educational purposes only and is not financial advice."
  privacy-url:    "https://www.herlonggame.com.au/privacy.html"

---

# Her Long Game — Design System v5.1

Full spec saved here as the canonical source of truth. Flutter token map: HLGColors must stay in sync.

Key colour roles:
- Deep Sage (#5C7A62) — primary, 60-70% weight, CTAs, dark surfaces, footer
- Sage (#7A9279) — secondary, hovers, gradients, borders
- Sage Mid (#8A9E8D) — placeholders and muted captions ONLY
- Crown Gold (#B8923A) — decorative accent only, never body text
- Warm Cream (#F7F5F0) — primary surface
- Cream Warm (#F2EFE8) — inputs only
- Horizon Orange (#D4621A) — secondary accent under 10%
- Antique Rose (#C4756A) — errors and warmth

Forbidden: night (#161E17, #1C1B19, #2A3A2C, #2E2C29), moss (#2C4A3E), pure black, soft-gold.

Dark backgrounds: sage-deep only.

Typography: Playfair Display = display only. DM Sans = everything else. Eyebrows: gold uppercase 0.2em tracking.

Icons: Lucide only. No Heroicons. No emoji.

Voice: Optimistic Architect. Direct, warm, dry. No em dashes. No corporate jargon. No "leverage / unleash / empower".

Inputs: cream-warm background (never same as card). Border min rgba(92,122,98,0.3).

Focus rings: sage-deep 3px outline, 3px offset. Never removed.

Loading: skeleton screens with sage-tint shimmer. Reduced-motion fallback static.

Empty states: always designed, never blank.

Motion: only transform + opacity. Stagger cap 6 items.

Haptics (Flutter): light for selection, medium for completion/checkpoint, none for back/error/scroll.

Safe areas: env(safe-area-inset-*) on all fixed/sticky elements.

iOS Safari: avoid opacity:0 IntersectionObserver reveal pattern; always explicit width/height on SVG.

Legal: B&CO GROUP PTY LTD · ACN 698 821 233 · ABN 91 698 821 233 · 2/290 Boundary Street Spring Hill QLD 4000.
