# Architecture (Her Long Game)

This document is a maintained mapping between the intended architecture and what is currently implemented under `lib/`.

Last updated: 2026-06-14

---

## 1) High-level structure

**Entry:** `lib/main.dart`

- Initializes Flutter bindings
- Calls `SupabaseConfig.initialize()`
- Runs `App()`

**App + Router:** `lib/app.dart`

- `MaterialApp.router(...)` with `routerConfig: AppRouter.router`
- `GoRouter` is the only routing mechanism (no `Navigator.push/pop` usage expected).

**Navigation shim:** `lib/nav.dart`

- Re-exports router types for backward compatibility.

---

## Colour palette (brand)

| Token | Hex | Usage |
|---|---|---|
| `deepSage` | `#5C7A62` | Primary · CTAs · Key UI |
| `sage` | `#7A9279` | Secondary · Hover · Gradients |
| `midSage` | `#8A9E8D` | Body text · Labels |
| `crownGold` | `#B8923A` | Gold accent |
| `warmCream` | `#F2EFE8` | Primary background |
| `petal` | `#E1E2D8` | Soft surface tint (derived) |
| `night` | `#1E2B22` | Ink text alias (app code uses for primary text) |
| `growth` | `#7ECFA0` | Positive indicators |
| `horizonOrange` | `#D4621A` | Accent only |
| `antiqueRose` | `#C4756A` | Warmth · Callouts · Contrast |
| `deepForest` | `#1E2E20` | Premium onboarding screens |
| `deepForestSurface` | `#1A2E1C` |  |
| `sagePale` | `#D8DBD0` | Soft surface tint (derived) |
| `textBody` | `#1E2B22` | Primary “ink” body text |
| `textMuted` | `#56665A` | Secondary/muted text |
| `white` | `#FFFFFF` |  |

Antique Rose usage rule (from brand system): maximum one use per screen. Appropriate for: Her Notes accents, debt/cost warning cards, community insight borders, stopping-cost callouts. Never use for CTAs, navigation, backgrounds, or body text.

### UI copy rule — no emojis
- Do **not** use emoji characters (e.g. 📚 ✨ 💡) in any user-facing UI copy.
- Tone should be carried by typography, spacing, and (when needed) functional icons — not emoji glyphs.

---

## 2) GoRouter route map

Source of truth: `lib/app.dart`.

### Router settings

- `initialLocation`: `/` (`AppRoutes.splash`)
- `redirect`: **none configured** in `lib/app.dart`
- `errorBuilder`: renders a simple “Page not found” scaffold and logs `state.error`

### Top-level routes (outside tab shell)

| Name | Path | Page | Notes |
|---|---|---|---|
| `splash` | `/` | `SplashPage` | Resolves initial route based on auth + user state. |
| `auth` | `/auth` | `AuthPage` | Sign-in/up flow entry. |
| `welcome` | `/welcome` | `WelcomeScreen` | First onboarding step. |
| `founderNote` | `/founder-note` | `FounderNoteScreen` | Onboarding step. |
| `financialWellbeingDiagnostic` | `/onboarding/diagnostic` | `FinancialWellbeingDiagnosticScreen` | Onboarding step. |
| `lessonCover` | `/lesson/:code` | `LessonPage(lessonCode)` | Lesson “cover/entry” screen. |
| `lessonScreen` | `/lesson/:code/screen?start=0` | `LessonScreenPage(lessonCode, initialScreenIndex)` | Renders lesson screens; drives Continue flow. |
| `lessonClose` | `/lesson/:code/close` | `LessonClosePage(lessonCode)` | “Carry this” close screen. |
| `checkpoint` | `/checkpoint/:num` | `CheckpointPage(checkpointNumber)` | Checkpoint flow. |

### ShellRoute (tab scaffold)

`ShellRoute(builder: (context, state, child) => _TabScaffold(...))`

Bottom nav order (see `_TabScaffold._indexForLocation`):
1) Home
2) System
3) Learn
4) Wisdom
5) Profile

Note: `/now` exists as a route (`NowPage`) but is **not** represented as a bottom-tab destination.

#### Shell routes

| Name | Path | Page |
|---|---|---|
| `system` | `/system` | `HerSystemPage` |
| `home` | `/home` | `HomePage` |
| `principles` | `/principles` | `PrinciplesPage` |
| `learn` | `/learn` | `LearnPage` |
| `now` | `/now` | `NowPage` |
| `wisdom` | `/wisdom` | `WisdomPage` |
| `tools` | `/tools` | `HerToolsPage` |
| `profile` | `/profile` | `ProfilePage` |
| `profileNotes` | `/profile/notes` | `HerNotesPage` |
| `profileAccount` | `/profile/account` | `AccountSettingsPage` |
| `profilePayment` | `/profile/payment` | `PaymentPage` |
| `profileProgress` | `/profile/progress` | `LearningProgressOverviewPage` |
| `profileDashboard` | `/profile/dashboard` | `DashboardPage` |
| `profileGoals` | `/profile/goals` | `GoalsSnapshotPage` |
| `profileReferral` | `/profile/referral` | `ReferralPage` |
| `bookmarks` | `/bookmarks` | `HerBookmarksPage` |
| `direction` | `/direction` | `HerDirectionPage` |
| `perspective` | `/perspective` | `HerPerspectivePage` |

#### Nested learn routes

| Name | Path | Page | Notes |
|---|---|---|---|
| `learnPhase` | `/learn/phase/:phaseId` | `LearnPhasePage(phaseId)` | Phase detail (modules list). |
| `learnPhaseEntry` | `/learn/phase/:phaseId/entry?revisit=1` | `PhaseEntryPage(...)` | Fullscreen dialog; marks phase as “seen”. |
| `learnModule` | `/learn/module/:moduleIndex` | `LessonListPage(moduleIndex)` | Module lesson list. |

---

## 3) Supabase integration

### Supabase client

- Config: `lib/supabase/supabase_config.dart`
- Initialized at app start: `SupabaseConfig.initialize()` in `lib/main.dart`

### Tables (expected by repositories)

The code expects these Postgres tables (names as used in `from('<table>')` calls in Dart):

| Table | Purpose | Primary access layer |
|---|---|---|
| `users` | App user profile row keyed to `auth.users.id` | `UserRepository` / `SupabaseUserStateRepository` |
| `lesson_screens` | Lesson screen content (per `lesson_code`, `screen_index`) | (read path lives in lesson UI; repository coverage is partial) |
| `lesson_progress` | Per-user lesson progress snapshots | `LessonRepository` |
| `phase_progress` | Per-user seen/entry tracking for phases | `PhaseProgressRepository` / `PhaseProgressController` |
| `tool_states` | Latest tool snapshot per user/tool | `ToolRepository.saveToolState` |
| `tool_state_events` | Append-only tool history log | `ToolRepository._insertToolEvent` / `getToolHistory` |
| `goals` | User goals (often created from tools) | `GoalRepository` |
| `her_notes` | Notes + takeaways | `HerNotesPage`, `LessonClosePage`, `HerBookmarksPage` |
| `passed_on` | De-identified community insights | `WisdomPage`, `LessonClosePage`, `PassedOnWidget` |

### Note — Her Perspective vs Wisdom

- **Wisdom** remains a curated reading + reflection space.
- **Her Perspective** is the community feed of “passed on” notes (from `passed_on`).
- The Her pillar should not deep-link to Wisdom.

Note: SQL/migrations are managed in Supabase; this repo may not include local SQL sources.

### RLS policies

RLS policies must exist for all user-owned tables (e.g., `users`, `lesson_progress`, `phase_progress`, `tool_states`, `tool_state_events`, `goals`, `her_notes`, `passed_on`).

This repo does not currently include local SQL policy sources; treat Supabase as the source of truth.

---

## 4) App screen flow (splash → home)

### Startup

1. `main()` → `SupabaseConfig.initialize()` → `runApp(App())`
2. `GoRouter.initialLocation` = `/`
3. `SplashPage` loads user state via `SupabaseUserStateRepository().load()`
4. `SplashPage` routes with `context.go(AppFlowController.instance.getInitialRoute(state))`

### Initial route decision

Source: `lib/flow/app_flow_controller.dart` delegates to `lib/flow/onboarding_flow_controller.dart`.

Decision order (as implemented):

1) Not authenticated → `/auth`

2) Onboarding resume (in order):
- If not welcomed → `/welcome`
- Else if founder note not seen → `/founder-note`
- Else if diagnostic not complete → `/onboarding/diagnostic`
- Else → `/home`

---

## 5) Learning architecture (curriculum + lesson progression)

### Canonical curriculum

Source of truth: `lib/data/learning_catalog.dart`

Phases (high-level “Past/Present/Future”):
- Phase 1: THE PAST (moduleIds: `['0','1']`)
- Phase 2: THE PRESENT (moduleIds: `['2','3']`)
- Phase 3: THE FUTURE (moduleIds: `['4']`)

Modules (ordered):
- Module 0: Pre-Course → `LA`
- Module 1: Foundations → `L1`, `L1b`, `LB`, `L2`, `CK1`
- Module 2: Money & the System → `L3`, `L4`, `LD`, `LE`, `CK2`
- Module 3: Building the Base → `L5`, `L6`, `L7`, `L7b`, `LC`, `LF`, `CK3`
- Module 4: Growing Wealth → `L8`, `L8a`, `L9`, `L10`, `CK4`

Unlock rules:
- Module 1 unlocks when `LA` is `complete`
- Module 2 unlocks when `CK1` is `complete`
- Module 3 unlocks when `CK2` is `complete`
- Module 4 unlocks when `CK3` is `complete`

### Progression logic

Source of truth: `lib/utils/lesson_flow.dart` (`LessonFlowController`)

- Maintains a canonical `lessonSequence` derived from `LearningCatalog`
- Computes next route after a lesson:
  - Next checkpoint: `/checkpoint/:num`
  - Next lesson: `/lesson/:code`
  - End of sequence: `/home`
- Supports skipping lessons that have no content by pre-populating `setSkippableLessons(...)`

---

## 6) Widget inventory (custom widgets)

### Shared widgets (`lib/widgets/`)

- `AppBackButton` — `lib/widgets/app_back_button.dart`
- `HerAppBar` — `lib/widgets/her_app_bar.dart`
- `FounderNoteCard` — `lib/widgets/founder_note_card.dart`
- `HerCheatSheet` — `lib/widgets/her_cheat_sheet.dart`
- `LessonBodyRenderer` — `lib/widgets/lesson_body_renderer.dart`
- `PassedOnWidget` — `lib/widgets/passed_on_widget.dart`
- `ResearchRefWidget` — `lib/widgets/research_ref_widget.dart`
- `ToolBottomSheet` — `lib/widgets/tool_bottom_sheet.dart`
- `TooltipTerm` — `lib/widgets/tooltip_term.dart`

### Tool widgets (`lib/widgets/tools/`)

- `InflationThiefWidget` — `inflation_thief_widget.dart`
- `SalaryRippleWidget` — `salary_ripple_widget.dart`
- `TimeMachineWidget` — `time_machine_widget.dart`
- `TheCurveWidget` — `the_curve_widget.dart`
- `DebtRaceWidget` — `debt_race_widget.dart`
- `TrueCostWidget` — `true_cost_widget.dart`
- `FortressWidget` — `fortress_widget.dart`
- `SuperWarpWidget` — `super_warp_widget.dart`
- `InvisibleInvoiceWidget` — `invisible_invoice_widget.dart`

---

## 7) Tool list (codes, names, persistence)

### Tool codes + UI names

Source: `lib/widgets/tool_bottom_sheet.dart` (also mirrored in `HerToolsPage`).

| Code | Name | Widget |
|---|---|---|
| `T1` | Inflation Thief | `InflationThiefWidget` |
| `T2` | Salary Ripple | `SalaryRippleWidget` |
| `T3` | Coffee Shop Time Machine | `TimeMachineWidget` |
| `T3b` | The Curve | `TheCurveWidget` |
| `T4` | Debt Race | `DebtRaceWidget` |
| `T4b` | True Cost Calculator | `TrueCostWidget` |
| `T5` | Emergency Fund Fortress | `FortressWidget` |
| `T6` | Super Time Warp | `SuperWarpWidget` |
| `T7` | Invisible Invoice | `InvisibleInvoiceWidget` |

### Tool persistence model

Domain models:
- `ToolAction` — `lib/domain/tools/tool_action.dart`
- `ToolEvent` — `lib/domain/tools/tool_event.dart`
- `ToolDefinition` — `lib/domain/tools/tool_definition.dart`

Repository:
- `ToolRepository` — `lib/data/repositories/tool_repository.dart`

Persistence behavior:
- **Snapshot**: `tool_states` stores latest per `(user_id, tool_code)` via `upsert(..., onConflict: 'user_id,tool_code')`
- **History**: `tool_state_events` is append-only; inserts are best-effort and never block UX
- **Goals**: `save_goal` actions also upsert `goals` rows

---

## 8) Known issues / risks (codebase-derived)

1) **Schema drift risk: `lesson_progress.updated_at`**
   - The app previously encountered Supabase “schema cache” failures when attempting to upsert an `updated_at` field on `lesson_progress`.
   - Current code was adjusted to be tolerant (retry without `updated_at` if missing).
   - Recommended stabilization: add `updated_at timestamptz` to `lesson_progress` (or ensure repo never sends it).

2) **Duplicate table creation across migrations for `tool_state_events`**
   - Both `0010_tool_state_events_and_uniques.sql` and `0011_create_tool_state_events.sql` create `tool_state_events`.
   - Both are written with `create table if not exists`, so this is generally safe but may cause confusion during audits.

3) **RLS coverage split across files**
   - Most RLS policies live in `supabase_policies.sql`, but `phase_progress` RLS policies live in migration `0009_create_phase_progress.sql`.
   - This is fine, but policy management is not centralized in one file.

4) **Learning content availability is Supabase-driven**
   - Lesson screens come from `lesson_screens`. If a lesson code exists in `LearningCatalog` but has 0 screens, it must be marked skippable via `LessonFlowController.setSkippableLessons` (loaded by app logic elsewhere).
   - Without a consistent “completeness” check, flow can dead-end or feel inconsistent.

5) **Schema drift risk: `users.name` / `users.display_name`**
   - Some environments do not have `name`/`display_name` columns on `users`.
   - `UserRepository.upsertProfile` is tolerant: if those columns are missing it retries without them.

---

## 9) File/folder reference (lib)

For the full `lib/` file tree, see the audit output from the architecture audit session.

---

## 12) Onboarding flow (correct sequence — as of May 2026)

1. New user signs up → `/welcome` (4-page swipe)
2. Taps `Start my long game →` → `/founder-note`
3. Reads founder note, taps `Start my long game →` → `/onboarding/diagnostic`
4. Completes Financial Wellbeing Diagnostic → `/home`
5. From home: begins learning via Learn tab or Up Next card

### IMPORTANT — L0 status

L0 “Before We Begin” exists in `lesson_screens` with 5 screens and valid content.

L0 is **NOT** part of the onboarding flow — the diagnostic replaced it.

L0 remains in the lessons table under module `pre_course`.

L0 emotional baseline capture (feeling screen) is now handled by the diagnostic.

- Do NOT route new users to `/lesson/L0` as part of onboarding.
- Do NOT reference L0 as the emotional baseline capture point.

### Emotional baseline capture

Emotional baseline is captured in `FinancialWellbeingDiagnosticScreen`.

It is saved to `users.emotional_baseline`.

The diagnostic also populates: `diagnostic_complete`, `diagnostic_archetype`, `diagnostic_scores`.

### Key flags on users table

- `welcomed_at` — set when founder note button is tapped
- `founder_note_seen` — set to true when founder note button is tapped
- `diagnostic_complete` — set to true when diagnostic is finished
- `onboarding_complete` — set to true after first lesson is completed

---

## 13) Notes vs Takeaways (current implementation)

Both “notes” and “takeaways” persist to the `her_notes` table.

- **Her Notes**: rows where `prompt != 'TAKEAWAY'`
- **Her Bookmarks (Takeaways)**: rows where `prompt == 'TAKEAWAY'` (saved from `LessonClosePage`)

This keeps the feature lightweight without introducing a new table.

---

## 14) Keeping this document accurate

Update this file when you change any of:

1) **Routes**: add/edit paths in `lib/app.dart` (or any go_router redirects)
2) **Persistence**: add new `from('<table>')` usage or change a table/column assumption
3) **Flow decisions**: onboarding or lesson progression logic (`lib/flow/*`, `lib/utils/lesson_flow.dart`)
4) **Cross-cutting UI primitives**: theme tokens in `lib/theme.dart`, shared widgets in `lib/widgets/*`

Suggested workflow:
- In the PR that changes architecture, include an “Architecture.md updated” checkbox.
- Keep `Last updated` current.
