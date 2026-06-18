-- Her Long Game — Supabase schema
-- Source of truth: arhitecture.md
-- Note: RLS is intentionally NOT enabled here (will be added separately).

create extension if not exists "pgcrypto";

-- -----------------------------------------------------------------------------
-- 1) users
-- -----------------------------------------------------------------------------
create table if not exists public.users (
  -- Matches auth.users.id — never generate separately.
  id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz,
  welcomed_at timestamptz,
  founder_note_seen bool default false,
  display_name text,
  emotional_baseline text,
  emotional_current text,
  portrait_generated bool default false,
  habit_awareness jsonb,
  onboarding_complete bool default false
);

-- Migration: welcomed_at (shown once-only welcome screen)
alter table public.users add column if not exists welcomed_at timestamptz;

-- Migration: founder_note_seen (shown once-only founder note)
alter table public.users add column if not exists founder_note_seen bool default false;

-- -----------------------------------------------------------------------------
-- 2) lesson_screens
-- -----------------------------------------------------------------------------
create table if not exists public.lesson_screens (
  lesson_code text not null,
  screen_index integer not null,
  screen_type text not null,
  heading text,
  body_text text,
  image_url text,
  tool_code text,
  options jsonb,
  constraint lesson_screens_pkey primary key (lesson_code, screen_index),
  constraint lesson_screens_screen_type_check check (
    screen_type in (
      'mirror',
      'story',
      'reveal',
      'reframe',
      'responsibility',
      'action',
      'feeling',
      'complete'
    )
  )
);

-- Migration: story screen images
alter table public.lesson_screens add column if not exists image_url text;

-- Migration: linked tools for action screens
alter table public.lesson_screens add column if not exists tool_code text;

-- -----------------------------------------------------------------------------
-- 3) lesson_progress
-- -----------------------------------------------------------------------------
create table if not exists public.lesson_progress (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  lesson_code text not null,
  status text not null,
  current_screen integer default 0,
  completed_at timestamptz,
  s4_response text,
  s7_response jsonb,
  her_notes text,
  constraint lesson_progress_status_check check (
    status in ('not_started', 'in_progress', 'complete')
  )
);

-- Ensure one row per (user, lesson)
alter table public.lesson_progress
  add constraint if not exists lesson_progress_user_lesson_unique unique (user_id, lesson_code);

create index if not exists idx_lesson_progress_user_id on public.lesson_progress(user_id);
create index if not exists idx_lesson_progress_user_lesson on public.lesson_progress(user_id, lesson_code);

-- -----------------------------------------------------------------------------
-- 4) tool_states
-- -----------------------------------------------------------------------------
create table if not exists public.tool_states (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  tool_code text not null,
  inputs jsonb default '{}'::jsonb,
  outputs jsonb default '{}'::jsonb,
  updated_at timestamptz
);

-- Ensure one current snapshot per (user, tool)
alter table public.tool_states
  add constraint if not exists tool_states_user_tool_unique unique (user_id, tool_code);

create index if not exists idx_tool_states_user_id on public.tool_states(user_id);
create index if not exists idx_tool_states_user_tool on public.tool_states(user_id, tool_code);

-- -----------------------------------------------------------------------------
-- 5) goals
-- -----------------------------------------------------------------------------
create table if not exists public.goals (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  goal_code text,
  label text,
  created_at timestamptz,
  target_date date,
  completed_at timestamptz,
  linked_tool text,
  source_lesson text
);

-- Enforce uniqueness for app-level upserts
alter table public.goals
  add constraint if not exists goals_user_goal_unique unique (user_id, goal_code);

-- -----------------------------------------------------------------------------
-- 5b) tool_state_events (history log)
-- -----------------------------------------------------------------------------
create table if not exists public.tool_state_events (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  tool_code text not null,
  type text not null,
  payload jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index if not exists idx_tool_state_events_user_id on public.tool_state_events(user_id);
create index if not exists idx_tool_state_events_user_tool_created on public.tool_state_events(user_id, tool_code, created_at desc);

-- -----------------------------------------------------------------------------
-- Seed checkpoint progress rows (run in Supabase SQL Editor when needed)
-- -----------------------------------------------------------------------------
-- INSERT INTO public.lesson_progress (user_id, lesson_code, status, current_screen)
-- SELECT
--   u.id,
--   c.code,
--   'not_started',
--   0
-- FROM public.users u
-- CROSS JOIN (VALUES ('CK1'),('CK2'),('CK3'),('CK4')) AS c(code)
-- ON CONFLICT (user_id, lesson_code) DO NOTHING;

create index if not exists idx_goals_user_id on public.goals(user_id);

-- -----------------------------------------------------------------------------
-- 6) her_notes
-- -----------------------------------------------------------------------------
create table if not exists public.her_notes (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  lesson_code text,
  prompt text,
  response text,
  created_at timestamptz
);

create index if not exists idx_her_notes_user_id on public.her_notes(user_id);

-- -----------------------------------------------------------------------------
-- 7) portraits
-- -----------------------------------------------------------------------------
create table if not exists public.portraits (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  q1_location text,
  q2_week text,
  q3_can_do text,
  q4_stop_doing text,
  q5_safety text,
  generated_text text,
  monthly_target integer,
  scene_description text,
  created_at timestamptz,
  updated_at timestamptz,
  constraint portraits_user_id_unique unique (user_id)
);

create index if not exists idx_portraits_user_id on public.portraits(user_id);

-- -----------------------------------------------------------------------------
-- 8) passed_on (de-identified community insights)
-- -----------------------------------------------------------------------------
create table if not exists public.passed_on (
  id uuid primary key default gen_random_uuid(),
  lesson_code text not null,
  insight_text text not null,
  first_name text,
  created_at timestamptz not null default now(),
  approved boolean not null default true
);

-- -----------------------------------------------------------------------------
-- Seed data (idempotent)
-- -----------------------------------------------------------------------------

-- Lesson: LA (Your Money Story)
insert into public.lesson_screens (lesson_code, screen_index, screen_type, heading, body_text, options)
values
  (
    'LA',
    0,
    'mirror',
    'What did money mean in the house you grew up in?',
    'Most of us learned our first financial lessons without realising it. Not in a classroom. At the kitchen table. In the silences. Those early experiences formed beliefs that still shape decisions you make today.',
    null
  ),
  (
    'LA',
    1,
    'story',
    'Kumari grew up watching her mother hide money.',
    'Not from thieves. From her father. A small amount, every week, folded into the lining of a coat at the back of the wardrobe. Emergency money. Just-in-case money. Her own money. Kumari found herself doing the same thing as an adult. Not because she was hiding anything. Because safety, to her, had always meant hidden.',
    null
  ),
  (
    'LA',
    2,
    'reveal',
    'Your money story has three layers.',
    'Layer 1 – What you were shown: how money was handled in your family. Layer 2 – What you were told: the explicit messages. Layer 3 – What you concluded: the belief you formed. Layer 3 is the one that runs your financial life. It was formed before you were old enough to question it.',
    null
  ),
  (
    'LA',
    3,
    'reframe',
    'A belief formed in childhood is not a personality trait.',
    'It is information from a specific time, filtered through a child''s understanding of the world. You are no longer that child. The first step is not to change the belief. It is to see it clearly – and ask: is this still true? Was it ever true? Who does it serve for me to keep believing it?',
    null
  ),
  (
    'LA',
    4,
    'responsibility',
    'You are not your money story. But you are responsible for what you do with it.',
    'The women who change their financial lives are not the ones who were born with different beliefs. They are the ones who examined theirs – and decided which ones to keep.',
    null
  ),
  (
    'LA',
    5,
    'action',
    'What was the main money message in your family growing up?',
    'Select the one that feels most true.',
    '["Money was tight – we never had quite enough", "Money wasn''t discussed – it was private", "Money caused conflict", "Money was managed well – I had a good example", "I had no idea what was happening with money"]'::jsonb
  ),
  (
    'LA',
    6,
    'complete',
    'LA Complete.',
    'Done. That''s one less thing you didn''t know yesterday.',
    null
  )
on conflict (lesson_code, screen_index) do update
set
  screen_type = excluded.screen_type,
  heading = excluded.heading,
  body_text = excluded.body_text,
  options = excluded.options;
