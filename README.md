# Her Long Game — Codebase Reference

> Read this file at the start of every session before touching any Dart code.
> It is the authoritative source of truth for the V4 curriculum, routing, and DB schema.

---

## Stack

- **Flutter** (Dart) — iOS/Android mobile app
- **Supabase** — Postgres DB + Auth (`tdlvomtuurscpjfnzcvj`)
- **GoRouter** — navigation
- **State** — StatefulWidgets, no external state manager

---

## V4 Curriculum — Canonical Structure

### Valid lesson codes (V4 only)

| Prefix | Phase | Codes |
|--------|-------|-------|
| `O` | Onboarding / Welcome | O1, O2, O3, O4, O5 |
| `P` | The Past | P1, P2, P3, P4, P5, P6 |
| `N` | The Present | N1, N2, N3, N4, N5, N6, N7, N8, N9, N10, N11, N12, N13 |
| `F` | The Future | F1, F2, F3, F4, F5, F6, F7, F8 |
| `CK` | Checkpoints | CK1, CK2, CK3, CK4 |

### Dead V1 codes — NEVER reference these in code

`L0`, `L0b`, `LA`, `L1`, `L1b`, `LB`, `L2`, `L3`, `L4`, `LD`, `LE`, `L5`, `L6`, `L7`, `L7b`, `LC`, `LF`, `L8`, `L8a`, `L9`, `L10`

These codes do **not exist** in `lesson_progress` or `lesson_screens` in Supabase.
Any code checking `startsWith('L')`, comparing to `'L0'`, or querying `lesson_code = 'L0'` is dead in V4.

### Canonical lesson sequence (order matters for progression)

```
O1 → O2 → O3 → O4 → O5 →
P1 → P2 → P3 → P4 → P5 → P6 → CK1 →
N1 → N2 → N3 → N4 → CK2 →
N5 → N6 → N7 → N8 → N9 → N10 → N11 → N12 → N13 → CK3 →
F1 → F2 → F3 → F4 → F5 → F6 → F7 → F8 → CK4
```

### Module structure

| Module ID | Label | Title | Items | Unlock rule |
|-----------|-------|-------|-------|-------------|
| `0` | Welcome | Before We Begin | O1–O5 | Always unlocked |
| `1` | Module 1 | The Past | P1–P6, CK1 | O5 complete |
| `2` | Module 2 | The Present | N1–N4, CK2 | CK1 complete |
| `3` | Module 3 | The Present | N5–N13, CK3 | CK2 complete |
| `4` | Module 4 | The Future | F1–F8, CK4 | CK3 complete |

### Phase structure

| Phase ID | Title | Modules |
|----------|-------|---------|
| `1` | THE PAST | 0, 1 |
| `2` | THE PRESENT | 2, 3 |
| `3` | THE FUTURE | 4 |

### Checkpoint routing

| Checkpoint | Route on complete |
|------------|------------------|
| CK1, CK2, CK3 | `/learn` |
| CK4 | `/home` |

---

## Supabase Schema

### `lesson_screens` — lesson content

| Column | Type | Notes |
|--------|------|-------|
| `lesson_code` | text | V4 code (O1, P1, N1, F1, CK1…) |
| `screen_index` | int | 0-based index within lesson |
| `screen_type` | text | See valid types below |
| `heading` | text | Main heading text |
| `body_text` | text | Body copy (supports markdown-lite) |
| `image_url` | text? | Network URL or asset path |
| `options` | jsonb? | Array of strings for `feeling`/`action` types |
| `display_name` | text? | Short lesson title for UI |
| `tool_code` | text? | Links to HerTools for `action` screens |

**Valid `screen_type` values:**
`intro`, `reminder`, `mirror`, `story`, `reveal`, `reframe`, `responsibility`,
`action`, `feeling`, `interaction`, `complete`

### `lesson_progress` — per-user lesson state

| Column | Type | Notes |
|--------|------|-------|
| `user_id` | uuid | FK → auth.users |
| `lesson_code` | text | V4 code only |
| `status` | text | `in_progress` or `complete` |
| `current_screen` | int | Last screen index reached |
| `completed_at` | timestamptz? | Set on complete |
| `s4_response` | text? | `feeling` screen selection (emotional check-in) |
| `s7_response` | jsonb? | `action` screen selection or checkpoint knowledge check |

### `users` — user profile

| Column | Type | Notes |
|--------|------|-------|
| `id` | uuid | FK → auth.users.id |
| `emotional_baseline` | text? | Set by financial wellbeing diagnostic (O4 feeling screen) — NOT from L0 |
| `onboarding_complete` | bool | Set to true when O5 completes |
| `habit_awareness` | text? | Used in CK2 screen 1 |
| `emotional_current` | text? | Set by CK4 forward-set selection |

### `phase_progress` — module unlock status

Tracks phase/module progression. Read by `learn_page.dart` to render `PhaseCard` widgets.

### `her_notes` — saved user reflections

Written by checkpoint screens (screen 4 of each CK). Columns: `user_id`, `lesson_code`, `prompt`, `response`, `created_at`.

### `goals` — direction/goals tracker

Columns: `user_id`, `label`, `goal_type`, `completed_at`, `target_date`, `archived_at`.

---

## Navigation / Routing

### Routes inside `ShellRoute` (bottom nav bar visible)

| Route | Screen |
|-------|--------|
| `/home` | HomePage |
| `/learn` | LearnPage (phase list) |
| `/learn/phase/:phaseId` | LearningPhasePage |
| `/learn/phase/:phaseId/entry` | PhaseEntryPage |
| `/learn/module/:moduleIndex` | LessonListPage |
| `/direction` | DirectionPage |
| `/profile` | ProfilePage |

### Routes OUTSIDE `ShellRoute` (no bottom nav)

| Route | Screen |
|-------|--------|
| `/lesson/:lessonCode` | LessonScreenPage |
| `/lesson/:lessonCode/close` | LessonClosePage |
| `/checkpoint/:n` | CheckpointPage (n = 1..4) |
| `/auth` | AuthPage |
| `/splash` | SplashPage |
| `/onboarding` | OnboardingPage |

### Key routing rules

- Completing a lesson → `LessonFlow.nextRouteAfterLesson(code)` → `/lesson/$code/close`
- After close → `LessonFlow.nextRouteAfterClose(code)` → next lesson or checkpoint
- Checkpoints are reached at `/checkpoint/1` through `/checkpoint/4`
- Checkpoint code ↔ route: `CK1` = `/checkpoint/1`, `CK2` = `/checkpoint/2`, etc.

---

## Key Files

| File | Role |
|------|------|
| `lib/data/learning_catalog.dart` | Single source of truth for module/phase structure and unlock rules |
| `lib/data/lesson_names.dart` | Display names and micro-labels for V4 lesson codes |
| `lib/utils/lesson_flow.dart` | Progression logic: next lesson/checkpoint after completing a lesson |
| `lib/supabase/supabase_config.dart` | Supabase client, `SupabaseService.selectSingle` (uses `.maybeSingle()` — returns null, not error, for missing rows) |
| `lib/app.dart` | GoRouter route definitions; ShellRoute for tabs |
| `lib/screens/learn/home/home_page.dart` | Home screen: loads next lesson, goals snapshot |
| `lib/screens/learn/learn_page.dart` | Phase list; reads `phase_progress` |
| `lib/screens/learn/lesson_list_page.dart` | Module lesson list; unlock logic; minutes map |
| `lib/screens/lesson/lesson_screen_page.dart` | Lesson screen renderer; screen_type routing |
| `lib/screens/lesson/lesson_close_page.dart` | Post-lesson close/share screen |
| `lib/screens/checkpoint/checkpoint_page.dart` | Checkpoint 4-screen flow |

---

## Lesson Flow Detail

### Lesson screen types and their eyebrow labels

| screen_type | Eyebrow label |
|-------------|---------------|
| `intro` | *(none — dark background screen)* |
| `reminder` | this space is yours |
| `mirror` | REFLECTION |
| `story` | THE STORY |
| `reveal` | THE REVEAL |
| `reframe` | REFRAME |
| `responsibility` | YOUR MOVE |
| `action` | YOUR TURN |
| `feeling` | CHECK IN |
| `interaction` | YOUR REFLECTION |
| `complete` | CARRY THIS |

### `feeling` screen behaviour

- Requires user to select an option before Continue is enabled
- Selection saved to `lesson_progress.s4_response`
- Also writes to `users.emotional_baseline` via `UserRepository.updateEmotionalBaseline`
- The ONLY place `emotional_baseline` is ever written

### `action` screen behaviour

- Requires user to select an option before Continue is enabled
- Selection saved to `lesson_progress.s7_response`
- May show a tool button if `tool_code` is set on the screen

### Lesson close page (`LessonClosePage`)

- "Pass it on to her" share section is SUPPRESSED for O1–O5 (onboarding)
- O5 completion writes `users.onboarding_complete = true`
- Onboarding lessons (O1–O5) should never show the share CTA

---

## Common Gotchas — Never Do These

1. **Never query `lesson_progress` for V1 codes** — L0, LA, L1 etc. don't exist in the DB. Queries will always return null.
2. **Never check `lessonCode == 'L0'`** — L0 doesn't exist in V4. Any branch on this is dead code.
3. **Never check `code.startsWith('L')`** to find non-checkpoint lessons — V4 codes are O/P/N/F/CK prefix. Use `code.startsWith('CK')` to identify checkpoints; everything else is a lesson.
4. **`_checkpointPrereqs` in `lesson_list_page.dart` must stay empty** — unlock rules live in `LearningCatalog.unlockRule`. V1 had extra prereqs here; V4 does not.
5. **`emotional_baseline` comes from `users` table, not `lesson_progress.s4_response`** — the L0 s4_response path is dead. Use `userRow['emotional_baseline']` only.
6. **`SupabaseService.selectSingle` returns null for missing rows** — it uses `.maybeSingle()`. Never assume a missing row is an error.
7. **Lesson minutes maps must include V4 codes** — O1–O5, P1–P6, N1–N13, F1–F8. No L-prefix codes.
8. **`PopScope(canPop: false)` for L0 is dead** — all lessons in V4 show a back button and Exit button. No lesson should be un-dismissable.
