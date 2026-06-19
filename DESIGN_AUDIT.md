# Design v5.1 Audit — Her Long Game

Audit of the current Flutter codebase against `design.md` v5.1. Severity is from a UX/brand-compliance lens, not a compile lens — the app currently compiles cleanly.

Legend: 🔴 violates a hard rule · 🟠 risky/large impact · 🟡 cleanup/consistency

---

## 1. Forbidden tokens still in the palette

🔴 `lib/theme.dart` defines tokens that v5.1 says must not exist:
- `HLGColors.night` (alias of `ink #2D2A26`) — name is forbidden even though the hex was retuned. Anti-pattern: token survives, future contributors will reach for it as a dark surface.
- `HLGColors.deepForest` + `HLGColors.deepForestSurface` — aliased to `deepSage`. Name implies a forest/dark token; spec says dark surfaces use only `sage-deep`. Currently used in 8 places (auth_page, financial_wellbeing_diagnostic_screen, lesson_screen_page, learning_catalog).
- `HLGColors.ink` / `HLGColors.inkMuted` — not in the v5.1 token map. Spec says all body text is `sage-deep`. These are currently exposed as `HLGColors.textBody` / `HLGColors.textMuted` and used everywhere.

Recommendation: rename the public surface to match the spec map (`sageDark`, `sage`, `sageMid`, `cream`, `creamWarm`, `crownGold`, `horizonOrange`, `antiqueRose`, `sageTint`). Remove `night`, `deepForest`, `deepForestSurface`. Decide explicitly: body text = `sageDark` (v5.1 says so) — drop the `ink`/`inkMuted` tokens.

🔴 `lib/theme.dart` line 78: `static const Color white = Color(0xFFFFFFFF);` — pure white is fine, but no current spec usage. Card background spec allows `#ffffff` or cream — keep but rename/document.

---

## 2. `sage-mid` used as body text (FAILS WCAG AA)

🔴 Spec: `sage-mid (#8A9E8D)` is **placeholder and muted captions only**, never body text or labels under 1rem. Comment in `theme.dart` line 39 even says “Body text · Labels” — that doc is wrong against v5.1.

`HLGColors.midSage` is used as body/label/icon colour across the entire app — found in 40+ files, hundreds of call sites. Highest-traffic offenders:
- `lib/screens/now/now_page.dart` (≥20 hits, includes body text, hint, labels)
- `lib/screens/checkpoint/checkpoint_page.dart` (≥14 hits)
- `lib/screens/profile/account_settings_page.dart` (≥18 hits)
- `lib/screens/profile/her_notes_page.dart`, `dashboard_page.dart`, `goals_snapshot_page.dart`, `payment_page.dart`, `profile_page.dart`, `referral_page.dart`, `learning_progress_overview_page.dart`
- `lib/screens/system/*.dart` (all 5 system pages)
- `lib/screens/wisdom/wisdom_page.dart`, `principles_page.dart`
- `lib/screens/learn/home/home_page.dart`, `learn_page.dart`, `phase_entry_page.dart`
- `lib/screens/lesson/lesson_screen_page.dart`
- `lib/screens/auth/auth_page.dart`, `welcome_screen.dart`
- `lib/widgets/founder_note_card.dart`, `tool_bottom_sheet.dart`, `her_tab_header.dart`, and most tool widgets

Recommendation: a global sweep that replaces `HLGColors.midSage` body/label usage with `HLGColors.textBody` (today = `ink`, post-rename = `sageDark`). Keep `midSage` only for `hintText`, disabled icons, faint borders, dividers (where its ~3.1:1 is fine because it’s decorative).

---

## 3. Em-dashes in user-visible copy

🔴 Spec voice rule: “no em dashes”.

In runtime UI strings (not comments):
- `lib/screens/learn/home/home_page.dart:214` — `'Pick up where you left off — small steps, long game.'`
- `lib/screens/profile/learning_progress_overview_page.dart:165` — `'Up next: —'` and `'Up next — $nextLabel'`
- `lib/widgets/lesson_body_renderer.dart` — multiple em-dash regex matches **(content, not chrome)**: this is parsing logic for lesson body content stored in Supabase; replacing here would only matter if you also rewrite the lesson content.

Recommendation: rewrite the two UI strings above with a colon or full stop. Leave the lesson-body parser alone (it handles content the team controls separately).

Comments in code (`// — DESIGN.md …`) use em-dashes too; harmless, not user-visible.

---

## 4. Color.withOpacity (deprecated)

🟠 `lib/widgets/tools/bubble_index_widget.dart` — 3 hits at lines 163, 240, 567. Should be `withValues(alpha: …)` per repo rule and Flutter 3.27+ deprecation. Every other widget already uses `withValues`.

---

## 5. Inputs: cream-on-cream risk

🟠 Spec: input background must be `cream-warm`, never the same as the card. The codebase uses raw `TextField` widgets in 9 files (sign_in_page, sign_up_page, checkpoint_page, lesson_close_page, now_page, account_settings_page, her_notes_page, portrait_builder_widget, salary_ripple_widget). I did not see any global `InputDecorationTheme` setting `filled: true` + `fillColor: HLGColors.creamWarm`, so fields likely render transparent.

Recommendation: define an `InputDecorationTheme` in `lib/theme.dart` with:
- `filled: true`, `fillColor: HLGColors.creamWarm`
- `border` + `enabledBorder` at `1.5px rgba(92,122,98,0.35)`
- `focusedBorder` at `sageDark`
- `errorBorder` at `antiqueRose`
This fixes most fields without touching call sites.

---

## 6. Buttons / focus rings

🟠 No `ButtonStyle` overrides for focus outline observed (`outline: 3px sage-deep, offset 3px`). Flutter Material 3 default focus is a thin overlay, not the visible ring the spec mandates. Will need a `FilledButton`/`OutlinedButton`/`InkWell` theme override or a custom `FocusableActionDetector` wrap.

🟡 No standard loading state on async buttons. Several `FilledButton.icon` / `OutlinedButton`s in auth, profile, and lesson_close pages toggle a `_isSubmitting` and conditionally render text or `CircularProgressIndicator`, but sizes shift. Spec says: identical padding, swap label for 20px spinner.

---

## 7. Skeletons and empty states

🟠 No skeleton loaders found anywhere. Loading is `CircularProgressIndicator` in centred space (LearnPage, ProfilePage, dashboard, etc.). Spec requires sage-tint shimmer skeletons matching the element being loaded.

🟡 Empty states exist in most lists (her_notes, goals_snapshot, bookmarks) but mostly use `midSage` body — same v5.1 violation as §2. Designs are otherwise spec-compliant (centered, ghost CTA).

---

## 8. Icons / library

🟢 No Heroicons, no cupertino icons, no emoji in code. App uses `Icons.*` (Material). Spec says Lucide is canonical. This is a deliberate adoption decision — Material icons aren’t flagged as forbidden, but they aren’t Lucide either. **Not currently a violation, but a future decision: adopt `lucide_flutter` or accept Material as the project standard and update design.md.**

---

## 9. Motion / haptics

🟡 No `HapticFeedback.lightImpact()` / `mediumImpact()` calls anywhere. Spec defines explicit moments where haptics should fire (option select, lesson complete, checkpoint unlock).

🟡 No `prefers-reduced-motion` / `MediaQuery.disableAnimations` checks. Most animations are minimal (`AnimatedSwitcher`, default page transitions) so impact is small, but new shimmer/stagger work must respect this.

🟡 No staggered list entrance animations exist today, so the 6-item cap is not currently breached.

---

## 10. Safe areas

🟢 `SafeArea` used at most tab roots. Quick scan didn’t find a fixed/sticky CTA missing inset handling. Tab bar and bottom sheets look fine.

---

## 11. Typography contract

🟢 Playfair Display used only in display styles (`h1Display`, `h2Section`, `h3SubheadItalic`) and a small number of explicit `GoogleFonts.playfairDisplay` calls for italic labels in `wisdom_page.dart` and `now_page.dart` (line 550). Spec note: italic Playfair for *body* is forbidden — those particular cases are short single-line labels which are borderline display use.

🟢 DM Sans handles everything else.

🟡 `lib/theme.dart` keeps fixed-pixel font sizes (`fontSize: 48`, etc.). Spec uses `clamp()` — on Flutter this maps to `MediaQuery`-aware scaling, which we don’t do. Acceptable trade-off for mobile only; revisit if a tablet/web layout becomes a priority.

---

## 12. Other anti-patterns

🟢 No usage of forbidden hex values (`#161E17`, `#1C1B19`, `#2C4A3E`, `#2A3A2C`, `#2E2C29`, `#000000`).
🟢 No `Colors.black`. (Single string “black” match is in a comment.)
🟢 No `lorem ipsum`.

---

## Priority recommendation

If you want to do this in passes, smallest blast radius first:

1. **Theme cleanup (single file, ~50 LOC):** remove `night`, `deepForest`, `deepForestSurface`, `ink`, `inkMuted`. Rename `deepSage→sageDark`, `midSage→sageMid`, `warmCream→cream`. Keep deprecation aliases (`@Deprecated`) for one cycle to avoid breaking every screen at once.
2. **InputDecorationTheme + focus theme (single file):** `lib/theme.dart`. Fixes inputs and focus rings across the app without touching call sites.
3. **withOpacity → withValues sweep (3 lines):** `bubble_index_widget.dart`.
4. **Em-dash sweep in UI copy (2 strings):** home_page.dart, learning_progress_overview_page.dart.
5. **`midSage` body-text sweep (high effort, 40+ files):** replace body/label usage with `textBody`; keep only for hints/dividers/disabled. Do per-page, not in one PR.
6. **Replace `deepForest` call sites (4 files):** mechanical s/`HLGColors.deepForest`/`HLGColors.sageDark`/.
7. **Skeleton + haptics + Lucide:** new work, not migrations.

Items 1–4 are low-risk and would unlock a clean compile baseline against v5.1 tokens. Items 5–7 are real product work.
