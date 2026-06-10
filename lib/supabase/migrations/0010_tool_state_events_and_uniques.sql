-- Phase 6/7 support: event-driven tool actions + uniqueness constraints
-- Adds:
--  - tool_state_events (history log)
--  - unique constraints needed for upserts:
--      tool_states(user_id, tool_code)
--      goals(user_id, goal_code)
--      lesson_progress(user_id, lesson_code)

create extension if not exists "pgcrypto";

-- -----------------------------------------------------------------------------
-- 1) tool_state_events (history)
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

-- RLS policies (match existing pattern in supabase_policies.sql)
alter table public.tool_state_events enable row level security;

drop policy if exists "tool_state_events_select_own" on public.tool_state_events;
drop policy if exists "tool_state_events_insert_own" on public.tool_state_events;

create policy "tool_state_events_select_own" on public.tool_state_events
  for select
  to authenticated
  using (auth.uid() = user_id);

create policy "tool_state_events_insert_own" on public.tool_state_events
  for insert
  to authenticated
  with check (auth.uid() = user_id);

-- -----------------------------------------------------------------------------
-- 2) Uniqueness constraints for upserts
-- -----------------------------------------------------------------------------

-- tool_states: one current snapshot row per (user, tool)
do $$
begin
  if not exists (
    select 1
    from pg_constraint
    where conname = 'tool_states_user_tool_unique'
      and conrelid = 'public.tool_states'::regclass
  ) then
    alter table public.tool_states
      add constraint tool_states_user_tool_unique unique (user_id, tool_code);
  end if;
end $$;

-- goals: enforce uniqueness for (user, goal_code) so upsertGoal is safe
do $$
begin
  if not exists (
    select 1
    from pg_constraint
    where conname = 'goals_user_goal_unique'
      and conrelid = 'public.goals'::regclass
  ) then
    alter table public.goals
      add constraint goals_user_goal_unique unique (user_id, goal_code);
  end if;
end $$;

-- lesson_progress: one progress row per (user, lesson_code)
do $$
begin
  if not exists (
    select 1
    from pg_constraint
    where conname = 'lesson_progress_user_lesson_unique'
      and conrelid = 'public.lesson_progress'::regclass
  ) then
    alter table public.lesson_progress
      add constraint lesson_progress_user_lesson_unique unique (user_id, lesson_code);
  end if;
end $$;
