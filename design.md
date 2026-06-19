brand: Her Long Game
version: 5.1
updated: 2026-06-19
format: design.md
maintainer: B&CO GROUP PTY LTD (ACN 698 821 233)
entity: herlonggame.com.au

app-notes:
  platform: "Flutter (iOS/Android/Web)"
  goal: "This spec must work for native app UI, not just web CSS. Tokens map directly into ThemeData and reusable widgets."
  non-negotiables:
    - "Never introduce forbidden colours (night/moss/black)."
    - "Sage-deep is the readable text colour on cream."
    - "Sage-mid is placeholders and muted captions only."
    - "Buttons never resize while loading; swap label for spinner."
    - "All fixed bottom UI (tab bar, bottom sheets, toasts, CTAs) must account for iOS safe areas."

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

spacing:
  base-unit:    "0.5rem (8px)"
  card-padding: "1.25rem–1.5rem"
  safe-area:
    note:       "Flutter: use SafeArea or MediaQuery padding; avoid hardcoded 0 bottom padding on bottom sheets/tab bars."
    top:        "env(safe-area-inset-top)"
    bottom:     "env(safe-area-inset-bottom)"
  border-radius:
    card:       "0.75rem"
    button:     "0.5rem"
    input:      "0.5rem"
    badge:      "1.25rem"
    tag:        "0.375rem"

components:
  button-primary:
    background:   "sage-deep (#5C7A62)"
    color:        "cream (#F7F5F0)"
    disabled:     "opacity: 0.45 — no colour swap"
    loading:      "Swap label for spinner — keep size identical"

  button-secondary:
    background:   "orange (#D4621A)"
    usage:        "Secondary CTA only; keep under 10% visual weight"

  card:
    background:   "white (#ffffff) or cream (#F7F5F0)"
    border:       "1px sage-tint"
    radius:       "0.75rem"

  input:
    background:   "cream-warm (#F2EFE8)"
    border-min:   "rgba(92,122,98,0.3)"
    placeholder:  "sage-mid (#8A9E8D)"

flutter-token-map:
  note: "HLGColors in lib/theme.dart must stay in sync with this file."
  mapping:
    sage-deep:    "HLGColors.deepSage"
    sage:         "HLGColors.sage"
    sage-mid:     "HLGColors.sageMid"
    gold:         "HLGColors.crownGold"
    cream:        "HLGColors.warmCream"
    orange:       "HLGColors.horizonOrange"
    rose:         "HLGColors.antiqueRose"
    cream-warm:   "HLGColors.creamWarm"
    sage-tint:    "HLGColors.sageTint"

anti-patterns:
  colors:
    - "Never use --night, --moss, or any dark near-black as a surface or background — removed tokens"
    - "Never use pure black (#000000)"
    - "Never use sage-mid (#8A9E8D) for body text or labels — placeholders and muted captions only"
    - "Never use gold (#B8923A) as body text"
  interactive:
    - "Never resize a button during loading"
    - "Never remove focus rings (Flutter web + desktop)"
  motion:
    - "Only transform and opacity"

legal:
  entity:         "B&CO GROUP PTY LTD"
  acn:            "698 821 233"
  abn:            "91 698 821 233"
  address:        "2/290 Boundary Street Spring Hill QLD 4000"
  disclaimer:     "Her Long Game content is for educational purposes only and is not financial advice."
  privacy-url:    "https://www.herlonggame.com.au/privacy.html"

---

# Her Long Game — Design System (App-first) v5.1

This file is the app and web design source of truth. In Flutter, tokens map into `ThemeData` and reusable primitives (buttons, cards, inputs, chips, tab bars, sheets, toasts).

## App-specific implementation rules

### Text colour

- Default body text on cream uses **Deep Sage (#5C7A62)**.
- Sage Mid is never used for body or small labels. It is reserved for placeholders and muted captions only.

### Dark surfaces

- There are no near-black surfaces in the app. Dark panels use **Deep Sage** only.

### Safe areas

- Bottom sheets, tab bars, toasts, and fixed CTAs must account for the iOS home indicator (Flutter: `SafeArea(bottom: true)` or `MediaQuery.paddingOf(context).bottom`).

### Buttons

- Disable splash effects (Flutter: `NoSplash`).
- Disabled state uses opacity reduction, not a colour swap.
- Loading state swaps label for spinner and keeps the same size.
