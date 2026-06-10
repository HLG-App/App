# Her Long Game — Architecture
# v5.0 · Updated from Brand Guidelines + product decisions

---

## What this app is

A financial literacy and empowerment app for Australian women.
The learning journey moves from emotional permission → systemic 
understanding → practical action → wealth building.

Core philosophy: "It's not your fault. But it is your responsibility."
Brand motto: "Own the money. Own the future."

Motivation is intrinsic throughout. No points, no streaks, no badges,
no XP, no gamification of any kind. The reward for completing a lesson
is understanding — not a score.

We build women who don't need us. That is the whole point.

---

## Tech stack

- Frontend: Flutter via Dreamflow
- Backend: Supabase (Postgres + Auth + Edge Functions)
- AI: Anthropic Claude API via Supabase Edge Function (portrait generation only)
- State management: Riverpod
- Routing: GoRouter with named routes
- Fonts: Google Fonts (Playfair Display + DM Sans)

---

## Colour palette (v5.0 — exact from brand guidelines)

Primary:
  deepSage:       #5C7A62   Primary · CTAs · Key UI
  sage:           #7A9279   Secondary · Hover · Gradients
  midSage:        #8A9E8D   Body text · Labels

Accent / Neutrals:
  crownGold:      #B8923A   Gold accent · Checkpoints · Pull quotes
  warmCream:      #F7F5F0   Primary background
  petal:          #EDE0D4   Cards · Warm panels

Dark & Signal:
  night:          #2A3A2C   Dark sage — replaces pure black. Warmer, still premium.
  growth:         #7ECFA0   Positive indicators · Up arrows
  horizonOrange:  #D4621A   Accent only · CTAs · Tool headers · Buttons
  antiqueRose:    #C4756A   Warmth · Callouts · Contrast

Derived / utility:
  sagePale:       #D4E0D6   Light backgrounds · Progress tracks
  textBody:       #2A3A2C   Dark body text
  textMuted:      #6A7E6C   Secondary / muted text
  white:          #FFFFFF

---

## Typography (v5.0 — exact from brand guidelines)

Display / Headlines: Playfair Display
  H1 Display:    48pt · Bold
  H2 Section:    32pt · Bold
  H3 Subhead:    24pt · Italic
  Quote:         18pt · Italic
  Rule: Italic for warmth. Bold for headlines.
  "Playfair Display carries the emotion."

UI / Body: DM Sans
  Body:          15pt · Regular
  Label:         12pt · Medium
  UI Element:    11pt · Regular
  Eyebrow:       9pt · All caps · 2em letter spacing
  "DM Sans carries the information."

NEVER use system fonts (Arial, Helvetica) anywhere in the app.

---

## Voice & tone (from brand guidelines)

We are:
  Forward-leaning   — What is becoming possible, not what was wrong
  High-agency       — Active verbs: Build, Secure, Lead. Never: Learn, Fix, Understand
  Specific          — "$340 ahead of schedule" not "great work"
  Warm not parental — We stand beside, not above
  Dry               — Wit without cruelty. A raised eyebrow, not a laugh track

We are not:
  Preachy           — One mention of a value. Then we move. Never repeat.
  Hypey             — No "crush it." No "secret to wealth." None.
  Condescending     — We share ideas with people. We don't explain things to them.
  Vague             — "Build wealth" is not a sentence. What, how, by when — always.
  Guru-dependent    — We build women who don't need us.

Example copy that sounds like us:
  "Own the money. Own the future."
  "Spend less than you earn. Shockingly revolutionary."
  "Done. That's one less thing you didn't know yesterday."
  "Crisis can queue like everyone else."
  "Secure the money. Lead the world."

---

## What must NEVER appear in this app

- XP points or any point system
- Streak counters
- Achievement badges
- Leaderboards or rankings
- "You've earned X" language
- Level-up mechanics
- Comparison to other users
- Social features
- Advisor dependency or product recommendations
- Jargon without plain-English explanation

---

## Core data models

### User
id:                  uuid (PK, matches auth.users — never generate separately)
created_at:          timestamptz
display_name:        text (optional)
emotional_baseline:  text (set ONCE at L0 screen 4, NEVER overwritten anywhere)
emotional_current:   text (set ONCE at CK4 course complete, never before)
portrait_generated:  bool (default false)
habit_awareness:     jsonb (map of dimensions engaged — not a score, a map)
onboarding_complete: bool (default false — L0 sets this to true)

### LessonScreen
lesson_code:    text (e.g. 'L0', 'LA', 'L1', 'L1b', 'L7b', 'L8a', 'CK1')
screen_index:   integer (0-indexed)
screen_type:    text — must be one of:
                  mirror | story | reveal | reframe |
                  responsibility | action | feeling | complete
heading:        text
body_text:      text
options:        jsonb (array of strings — feeling and action screens only)

### LessonProgress
id:             uuid
user_id:        uuid (FK users.id — RLS enforced)
lesson_code:    text
status:         text (not_started | in_progress | complete)
current_screen: integer (default 0)
completed_at:   timestamptz (null until complete)
s4_response:    text (emotional baseline — L0 screen 4 only)
s7_response:    jsonb (action screen chip selection)
her_notes:      text (free text from Her Notes prompts)

### ToolState
id:          uuid
user_id:     uuid (FK users.id — RLS enforced)
tool_code:   text (T1|T2|T3|T3b|T4|T4b|T5|T6|T7|T8)
inputs:      jsonb (default {})
outputs:     jsonb (default {})
updated_at:  timestamptz

### Goal
id:           uuid
user_id:      uuid (FK users.id — RLS enforced)
goal_code:    text
label:        text
created_at:   timestamptz
target_date:  date (optional)
completed_at: timestamptz (null = active)
linked_tool:  text (which tool tracks this goal)
source_lesson:text (which lesson created this goal)

### HerNote
id:          uuid
user_id:     uuid (FK users.id — RLS enforced)
lesson_code: text
prompt:      text (the Her Notes question shown to the user)
response:    text (user's written response)
created_at:  timestamptz

### Portrait
id:                uuid
user_id:           uuid (FK users.id — UNIQUE, one portrait per user)
q1_location:       text (Where do you want to live?)
q2_week:           text (What does a good week look like?)
q3_can_do:         text (What do you want to be able to do that you can't now?)
q4_stop_doing:     text (What do you want to stop doing?)
q5_safety:         text (What does financial safety feel like to you?)
generated_text:    text (Claude API output — 3 warm specific sentences)
monthly_target:    integer (AUD/month — calculated from answers)
scene_description: text (illustration brief)
created_at:        timestamptz
updated_at:        timestamptz

---

## Navigation

Bottom nav bar — 5 tabs, persistent after onboarding complete:

  1. Home     /home     Next lesson card · today's reflection prompt · portrait hero if exists
  2. Learn    /learn    Module list → lesson list → lesson flow
  3. Now      /now      Goal Dashboard — all 8 tool states as live panels
  4. Wisdom   /wisdom   Sound money reading list · Bitcoin primer · saved lessons
  5. Profile  /profile  Her Notes · goals · emotional journey

Bottom nav colours:
  Background:  night (#2A3A2C)
  Selected:    horizonOrange (#D4621A)
  Unselected:  midSage (#8A9E8D)

---

## Lesson sequence (all 21 lessons in order)

Pre-Course:
  L0    This Is For You           (5 min)   no tool
  LA    Your Money Story          (9 min)   no tool

Module 1 · Foundations:
  L1    What Is Money?            (8 min)   no tool
  L1b   WTF Happened in 1971?     (9 min)   no tool
  LB    How Banks Actually Work   (8 min)   no tool
  L2    You Have More Control     (9 min)   T2 Salary Ripple
  CK1   Checkpoint 1

Module 2 · Money & the System:
  L3    What Is Inflation?        (7 min)   T1 Inflation Thief
  L4    The Pay Gap               (7 min)   T7 Invisible Invoice
  LD    The Tax You're Leaving Behind (8 min) no tool
  LE    Your Financial Reputation (6 min)   no tool
  CK2   Checkpoint 2

Module 3 · Building the Base:
  L5    Your First Budget         (8 min)   no tool
  L6    Emergency Fund            (7 min)   T5 Fortress
  L7    Debt & Credit             (8 min)   T4 Debt Race
  L7b   The Wine & the House      (8 min)   T4b True Cost Calculator
  LC    Your Super, Your Future   (10 min)  T6 Super Time Warp
  LF    What Happens If Something Goes Wrong (8 min) no tool
  CK3   Checkpoint 3

Module 4 · Growing Wealth:
  L8    Compound Growth           (8 min)   T3 Coffee Shop Time Machine
  L8a   The Lily Pad Problem      (9 min)   T3b The Curve
  L9    ETFs & Index Funds        (8 min)   no tool
  L10   What Is Bitcoin?          (10 min)  no tool
  CK4   Checkpoint 4 · Course Complete · T8 Future Self Portrait

---

## What If tools (all 10)

T1   Inflation Thief          L3    Two animated jars · Thief removes coins · year slider
T2   Salary Ripple            L2    Animated concentric rings · each ring = a bigger number
T3   Coffee Shop Time Machine L8    Dual TV screens · redirect slider · conscious vs habit
T3b  The Curve                L8a   Lily pad pond chart · flat phase → bend → Day 46 marker
T4   Debt Race                L7    Two horses · hurdles per debt · finish line date
T4b  True Cost Calculator     L7b   Dual column · consumed vs produced · opportunity cost
T5   Emergency Fund Fortress  L6    Stone-by-stone build · 4 milestones · contribution slider
T6   Super Time Warp          LC    Train at junction · Track A vs B · 4 toggle switches
T7   Invisible Invoice        L4    Dark-background invoice · WGEA data · career gap named
T8   Future Self Portrait     CK4   5 questions → Claude API → portrait text → monthly target

All tools open as modal bottom sheets from within the lesson Action screen.
Tools save inputs and outputs to tool_states table.
Goal Dashboard (Now tab) reads tool_states and shows all tools as live panels.

---

## Core flows

### App launch
Check Supabase auth session:
  No session → Auth page
  Session + onboarding_complete = false → L0 (cannot be skipped, back disabled)
  Session + onboarding_complete = true → /home

### Lesson flow
Lesson card tapped → LessonCoverPage (title, time, principle, tool badge if applicable)
Begin / Continue → LessonScreenPage
  Query: lesson_screens WHERE lesson_code = X AND screen_index = currentIndex
  Render based on screen_type (see screen types above)
  Continue → save any response → increment currentIndex → re-query
  Last screen → mark lesson_progress complete → LessonClosePage
LessonClosePage:
  Shows "Small shifts. Long game." (from lessons table)
  Shows close quote
  Button: Continue to next lesson OR Back to Lessons

---

## Features

### Pass it on to her

A moment at the end of every lesson where the user writes something in her own words — what shifted, what she wishes she'd known, what she'd want another woman to hear. Her words are saved to the `passed_on` table which has **no `user_id` column** — de-identified permanently at point of save. A first name is optional and the only personal data that may be stored.

Other women see a random selection of 3 insights from this table on the same lesson's close page and in the Wisdom tab. No likes. No comments. No usernames. No timestamps visible. No interaction. Just words travelling from one woman to another. This is the community flywheel.

### The emotional baseline — most important moment in the app
L0 screen 4 (screen_type: 'feeling'):
  Heading: "How do you feel about money, right now?"
  5 chip options: Anxious · Avoidant · Confused · Curious · Frustrated
  On selection:
    → save to users.emotional_baseline
    → save to lesson_progress.s4_response
    → this value is NEVER touched again anywhere in the app

CK4 (course complete):
  Displays users.emotional_baseline verbatim — "When you started, you said: [value]"
  Asks: "How do you feel about money today?"
  Same 5 options
  On selection → save to users.emotional_current ONLY
  Both values now live in users table side by side.
  This before/after is the emotional payoff of the entire product.

### Tool flow
Lesson reaches Action screen (screen_type: 'action') with a linked tool
Tool intro text shown (1–2 sentences, italic, the analogy)
Orange button: opens ToolBottomSheet (modal, 90% height)
ToolBottomSheet reads tool_code → renders correct widget
User interacts → widget calls onSave(outputs)
onSave → UPSERT tool_states → update Goal Dashboard

### Goal Dashboard (Now tab)
Reads all tool_states for current user
Portrait scene is hero image at top (if portrait_generated = true)
Each tool shown as a live panel — tappable to reopen full tool sheet
No scores. No rankings. Just: here is what you have built and where it stands.

---

## Architectural rules — the agent must follow these always

1.  No gamification — no XP, streaks, badges, points, rankings, levels, ever
2.  Lesson content always read from lesson_screens table — never hardcoded in UI
3.  emotional_baseline is write-once — only written at L0 S4, never updated
4.  emotional_current is write-once — only written at CK4, never before
5.  LessonScreenPage is a single reusable template — not individual pages per lesson
6.  All tools open as bottom sheets — never as separate nav routes
7.  RLS is enabled on all tables — every query scoped to auth.uid()
8.  Tool calculations are pure Dart math — no external calculation packages
9.  Custom tool animations use CustomPainter or flutter_animate
10. L0 cannot be skipped — back navigation disabled for the entire L0 flow
11. onboarding_complete is only set to true when L0 lesson_progress status = complete
12. Portrait is generated by Claude API via Supabase Edge Function — not client-side
13. Colours come from HLGColors class in theme.dart — no hardcoded hex values in widgets
14. Fonts are Playfair Display (headlines) and DM Sans (body) — never system fonts

---

## File structure

lib/
  main.dart
  app.dart                    (GoRouter setup — all named routes defined here)
  theme.dart                  (HLGColors + HLGTextStyles + AppTheme.lightTheme)
  models/
    user_model.dart
    lesson_screen_model.dart
    lesson_progress_model.dart
    tool_state_model.dart
    goal_model.dart
    her_note_model.dart
    portrait_model.dart
  services/
    supabase_service.dart      (all DB queries in one place)
    auth_service.dart
    portrait_service.dart      (Claude API edge function call)
  screens/
    auth/
      auth_page.dart
    home/
      home_page.dart
    learn/
      learn_page.dart          (module list)
      lesson_list_page.dart    (lessons within a module)
    lesson/
      lesson_cover_page.dart
      lesson_screen_page.dart  (the reusable template — reads from DB)
      lesson_close_page.dart
    checkpoint/
      checkpoint_page.dart     (reusable template for CK1–CK4)
    now/
      now_page.dart            (Goal Dashboard)
    wisdom/
      wisdom_page.dart
    profile/
      profile_page.dart
  widgets/
    tool_bottom_sheet.dart     (routes to correct tool widget by tool_code)
    lesson_screen_renderer.dart (renders correct layout by screen_type)
    her_notes_input.dart
    tools/
      fortress_widget.dart     (T5)
      super_warp_widget.dart   (T6)
      inflation_thief_widget.dart (T1)
      salary_ripple_widget.dart   (T2)
      debt_race_widget.dart       (T4)
      true_cost_widget.dart       (T4b)
      time_machine_widget.dart    (T3)
      the_curve_widget.dart       (T3b)
      invisible_invoice_widget.dart (T7)
      portrait_builder_widget.dart  (T8)

---

## Supabase tables (all 8)

users                (one row per user — auto-created on sign-up via trigger)
lesson_screens       (content — seeded once, readable by all authenticated users)
lesson_progress      (one row per user per lesson — RLS: user owns row)
tool_states          (one row per user per tool — RLS: user owns row)
goals                (one row per goal per user — RLS: user owns row)
her_notes            (append-only journal — RLS: user owns row)
portraits            (one row per user, UNIQUE — RLS: user owns row)
passed_on             (de-identified community insights — no user_id; insert for authenticated users, select for approved rows only)

RLS policy for all tables: users may only SELECT, INSERT, UPDATE their own rows.
lesson_screens is SELECT only for all authenticated users (no user_id column).

---

## Edge functions (Supabase)

handle_new_user       Trigger — auto-creates users row on auth.users INSERT
generate_portrait     POST — calls Claude API with 5 answers, returns portrait JSON
get_dashboard_data    POST — aggregates tool_states + goals + portrait for Now tab

generate_portrait Claude call:
  model: claude-sonnet-4-20250514
  max_tokens: 500
  system: "You are a warm portrait generator for a women's financial literacy app.
           Return only valid JSON. No markdown. No preamble."
  user prompt includes all 5 question answers
  returns: { portrait_text, scene_description, monthly_target_estimate }

---

## Build order (10 sprints)

Sprint 1:  Supabase schema + triggers + RLS
Sprint 2:  theme.dart · auth page · GoRouter skeleton
Sprint 3:  L0 lesson flow end-to-end (the emotional baseline moment working)
Sprint 4:  LessonCoverPage + LessonScreenPage template + LessonClosePage
Sprint 5:  Learn tab — module list + lesson list + unlock logic
Sprint 6:  Checkpoint template (CK1–CK4) + emotional current at CK4
Sprint 7:  T5 Fortress · T6 Super Warp · T1 Inflation Thief (highest retention impact)
Sprint 8:  Remaining 7 tools (T2, T3, T3b, T4, T4b, T7, T8)
Sprint 9:  Now tab (Goal Dashboard) + generate_portrait edge function
Sprint 10: Home tab · Profile tab · Wisdom tab · push notifications · App Store prep

Critical path: Sprints 1–4 only. Everything else is parallel after Sprint 4.
Sprint 7 tools are the retention inflection point — get these in before Sprint 8.