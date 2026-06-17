---
brand: Her Long Game
version: 5.0
updated: 2026-06-17
format: design.md
maintainer: B&CO GROUP PTY LTD (ACN 698 821 233)
entity: herlonggame.com.au

colors:
  # Source of truth: HerLongGame-BrandGuidelines-2026.pptx
  # --night and --moss are NOT brand colours and must never appear
  # --soft-gold is NOT a brand colour — use --gold only

  primary:
    sage-deep:  "#5C7A62"   # Deep Sage — Primary UI, CTAs, key interactive elements
    sage:       "#7A9279"   # Sage — Secondary, hover states, gradients, borders
    gold:       "#B8923A"   # Crown Gold — Accent, headers, highlights, stat accents
    cream:      "#F7F5F0"   # Warm Cream — Primary background, card surfaces, nav

  supporting:
    orange:     "#D4621A"   # Horizon Orange — Secondary CTAs, accent only (under 10% visual weight)
    rose:       "#C4756A"   # Antique Rose — Warmth, callouts, error states, contrast
    sage-mid:   "#8A9E8D"   # Sage Mid — Body text, labels, muted UI, captions

  derived:
    cream-warm: "#F2EFE8"   # Slightly deeper cream — input fields, alternate rows
    sage-tint:  "rgba(92,122,98,0.12)"   # Card borders, dividers, subtle separators

  forbidden:
    - "#161E17"   # --night — REMOVED. Never use as dark surface.
    - "#1C1B19"   # --night retuned variant — also removed, same reason
    - "#2C4A3E"   # --moss — REMOVED
    - "#2A3A2C"   # --night-mid — REMOVED
    - "#2E2C29"   # --night-mid retuned variant — also removed

  dark-surfaces:
    note: "Dark section backgrounds use sage-deep (#5C7A62) only — hero, stats strip, final CTA, footer"
    allowed: ["#5C7A62"]
    forbidden: ["any --night variant", "any --moss variant", "pure black #000000"]

  proportions:
    sage-deep:  "60-70% visual weight — dominant brand colour"
    orange:     "under 10% — accent only, never primary CTA"
    gold:       "accent — headers, highlights, stat values"
    cream:      "primary surface throughout"

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
    h2:         "1.5rem"
    callout:    "1.2rem"
    card-title: "1.1rem"
    body-lg:    "1rem"
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
    note:       "Always Crown Gold — primary signal of HLG section structure"

spacing:
  base-unit:    "0.5rem (8px)"
  section-gap:  "clamp(4rem, 8vw, 8rem)"
  container:    "max-width 760px, 1rem side padding mobile / 2rem desktop"
  card-padding: "1.25rem–1.5rem"
  border-radius:
    card:       "0.75rem"
    button:     "0.5rem"
    input:      "0.5rem"
    badge:      "1.25rem"
    small:      "0.375rem"

components:
  button-primary:
    background:   "sage-deep (#5C7A62)"
    color:        "cream (#F7F5F0)"
    font:         "DM Sans 500 0.8rem"
    tracking:     "0.04em"
    padding:      "0.85rem 1.75rem"
    radius:       "0.5rem"
    hover:        "darken 8% + translateY(-1px) + box-shadow rgba(92,122,98,0.25)"
    note:         "Sage-deep is primary CTA colour at 60-70% visual weight"

  button-ghost:
    background:   "transparent"
    border:       "1.5px solid sage-deep (#5C7A62)"
    color:        "sage-deep"
    hover:        "background rgba(92,122,98,0.08)"

  button-secondary:
    background:   "orange (#D4621A)"
    color:        "cream"
    usage:        "Secondary CTA, post-success states — under 10% visual weight on any page"

  card:
    background:   "white (#ffffff) or cream (#F7F5F0)"
    border:       "1px solid sage-tint (rgba(92,122,98,0.12))"
    radius:       "0.75rem"
    shadow:       "0 2px 12px rgba(92,122,98,0.06)"
    hover-shadow: "0 6px 20px rgba(92,122,98,0.12)"
    hover-lift:   "translateY(-2px)"

  input:
    background:   "cream-warm (#F2EFE8) — must differ from card background"
    border:       "1.5px solid rgba(92,122,98,0.35)"
    focus-border: "sage-deep (#5C7A62)"
    radius:       "0.5rem"
    padding:      "0.8rem 1rem"
    font:         "DM Sans 400 0.9rem"
    color:        "sage-deep (#5C7A62)"
    placeholder:  "sage-mid (#8A9E8D)"
    note:         "Input background must differ from card — cream on cream hides field boundaries"

  nav:
    background:   "cream (#F7F5F0)"
    border-bottom: "1px solid rgba(92,122,98,0.15)"
    logo-text:    "DM Sans 600, sage-deep"
    logo-sub:     "DM Sans 300, sage, 0.12em tracking, uppercase"
    links:        "DM Sans 0.75rem, sage-deep"
    link-hover:   "gold (#B8923A)"

  dark-section:
    background:   "sage-deep (#5C7A62)"
    heading:      "cream (#F7F5F0), Playfair Display 700"
    body:         "rgba(247,245,240,0.85)"
    label:        "gold (#B8923A), uppercase, tracked"
    accent:       "gold (#B8923A)"
    usage:        "Hero, stats strip, final CTA section, footer only"
    note:         "Never use --night or any dark near-black as section background"

  stat-card:
    context:      "Inside dark/sage-deep panels only"
    background:   "rgba(247,245,240,0.08)"
    border:       "1px solid rgba(247,245,240,0.15)"
    radius:       "0.75rem"
    label:        "DM Sans 0.6rem uppercase tracked, rgba(247,245,240,0.55)"
    value:        "Playfair Display 700 1.75rem, cream"
    accent:       "gold (#B8923A)"

  gate-overlay:
    backdrop:     "rgba(92,122,98,0.85)"
    blur:         "backdrop-filter: blur(6px)"
    card-bg:      "cream (#F7F5F0)"
    card-shadow:  "0 24px 80px rgba(92,122,98,0.3)"
    top-rule:     "4px gradient: gold → sage → orange"

  footer:
    background:   "sage-deep (#5C7A62)"
    text:         "gold (#B8923A), Playfair Display italic"
    links:        "gold (#B8923A)"

  divider:
    style:        "linear-gradient(90deg, gold, sage, cream)"
    height:       "1px"
    margin:       "2rem 0"

motion:
  easing:         "ease-out"
  duration-fast:  "200ms"
  duration-base:  "300ms"
  duration-entry: "420ms"
  entry:          "fade + translateY(16px → 0) over 420ms ease-out"
  stagger:        "80ms between list items"
  hover:          "200ms ease-out — colour shift + shadow only"
  page-transition: "fade 200ms"
  rule:           "Only transform and opacity — no layout-triggering properties"
  ios-note:       "IntersectionObserver fails on iOS Safari with file:// — do not use opacity:0 reveal animations that depend on it"

logo:
  primary-mark:   "Dual-profile SVG — line-drawn sage figure (left) + solid forward-facing figure (right), equal visual weight"
  text-lock:      "Her Long Game / Financial Education"
  on-light:       "sage-deep (#5C7A62) stroke + fill"
  on-dark:        "cream (#F7F5F0) stroke + fill"
  clear-space:    "0.5x logo height on all sides"
  svg-note:       "Always include explicit width and height attributes — iOS Safari renders SVG without dimensions at full viewport scale"

voice:
  tone:           "Optimistic Architect"
  style:          "Direct, warm, dry. Short sentences. No corporate jargon."
  philosophy:     "It's not your fault. But it is your responsibility."
  forbidden:
    - em dashes
    - "Elevate / Seamless / Unleash / Next-Gen / Empower / financial empowerment"
    - gamification language
    - excessive exclamation marks
    - AI-sounding filler phrases
  note:           "Copy earns emotion through data and directness — not inspirational language"

anti-patterns:
  colors:
    - "Never use --night, --moss, or any dark near-black as a surface or background — these are removed tokens"
    - "Never use --soft-gold — use --gold (#B8923A) only"
    - "Never use orange (#D4621A) as primary CTA — sage-deep leads at 60-70% visual weight"
    - "Never let orange exceed 10% visual weight on any page"
    - "Never use pure black (#000000)"
    - "Never use sage-mid (#8A9E8D) as a dark surface colour"
    - "Never duplicate colour tokens with different names but same hex"

  layout:
    - "No 3-equal-column feature grids — use zig-zag or asymmetric"
    - "No h-screen — use min-h-[100dvh]"
    - "No horizontal overflow on mobile"
    - "No decorative gradients — flat colour or single-axis gradient on dividers only"

  typography:
    - "Never use Playfair Display for body copy — display headings only"
    - "Never stack two Playfair Display blocks without DM Sans separation"

  inputs:
    - "Never set input background same as card background — field boundaries disappear on cream"
    - "Never soften border below rgba(92,122,98,0.3) — inputs become invisible"

  copy:
    - "No lorem ipsum"
    - "No broken external image links — use inline SVG or picsum.photos"
    - "No emoji in UI — use Lucide or Heroicons"
    - "No financial advice claims — always include educational disclaimer"

legal:
  entity:         "B&CO GROUP PTY LTD"
  acn:            "698 821 233"
  abn:            "91 698 821 233"
  address:        "2/290 Boundary Street Spring Hill QLD 4000"
  disclaimer:     "Her Long Game content is for educational purposes only and is not financial advice."
  privacy-url:    "https://www.herlonggame.com.au/privacy.html"
---

# Her Long Game — Design System

**Brand voice:** Optimistic Architect. Direct, warm, dry.

**Core philosophy:** It's not your fault. But it is your responsibility.

## Colour roles — one sentence each

- **Deep Sage (#5C7A62):** Dominant brand colour at 60-70% visual weight. Primary CTAs, dark section backgrounds, footer, hero panels, nav elements.
- **Sage (#7A9279):** Secondary. Hover states, gradients, borders, decorative use.
- **Sage Mid (#8A9E8D):** Muted functional colour. Body text, labels, captions, placeholder text.
- **Crown Gold (#B8923A):** Accent. Section eyebrows, stat values, header highlights, links on dark surfaces.
- **Warm Cream (#F7F5F0):** Primary surface. Page background, card backgrounds, nav, text on dark.
- **Horizon Orange (#D4621A):** Secondary accent under 10% visual weight. Secondary CTAs, hover states, alerts. Never primary.
- **Antique Rose (#C4756A):** Warmth and error. Callout blocks, error states, destructive actions.
- **Sage Tint (rgba 92,122,98 at 12%):** Structural detail. Card borders, dividers, subtle separators.
- **Cream Warm (#F2EFE8):** Input fields, alternate section rows — slightly deeper than primary cream to create visible field boundaries.

## What is not in the palette

`--night`, `--moss`, and all dark near-black variants (`#161E17`, `#1C1B19`, `#2C4A3E`, `#2A3A2C`, `#2E2C29`) are **not HLG brand colours** and must never appear in any HLG file. Dark surfaces are achieved with `sage-deep (#5C7A62)`, not with near-black.

`--soft-gold` is not a brand colour. Use `--gold (#B8923A)` only.

## Typography contract

Playfair Display is display-only — hero headlines, section titles, card titles, pull quotes. DM Sans handles everything functional. Never use Playfair for body copy. Never stack two Playfair blocks without DM Sans separation between them.

## Dark section rule

Only four page regions use `sage-deep` as a background: the hero, the stats strip, the final CTA section, and the footer. All other sections use cream or cream-warm with dark text. This is intentional — sage-deep as background creates the brand's structural anchors. Overusing it flattens the page.

## Input field rule

Input fields must use `cream-warm (#F2EFE8)` as background, not `cream (#F7F5F0)`. When inputs share the same background as the card they sit on, field boundaries disappear. The slightly deeper warm tone creates a visible boundary without requiring a heavy border stroke.

## iOS Safari note

The `.reveal` animation pattern (opacity: 0 → 1 via IntersectionObserver) fails silently on iOS Safari when served from `file://`. Any reveal animations must either use a fallback timeout or avoid opacity: 0 as the initial state. SVG logo marks must always include explicit `width` and `height` attributes — without them, iOS Safari renders SVG at full viewport scale.
