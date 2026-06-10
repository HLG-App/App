-- Row Level Security policies.
-- Apply via the Supabase module in Dreamflow.


-- -----------------------------------------------------------------------------
-- Enable RLS on all tables
-- -----------------------------------------------------------------------------
alter table public.users enable row level security;
alter table public.lesson_screens enable row level security;
alter table public.lesson_progress enable row level security;
alter table public.tool_states enable row level security;
alter table public.tool_state_events enable row level security;
alter table public.goals enable row level security;
alter table public.her_notes enable row level security;
alter table public.portraits enable row level security;
alter table public.passed_on enable row level security;

-- -----------------------------------------------------------------------------
-- users: authenticated users can SELECT/INSERT/UPDATE their own row
-- where id = auth.uid()
-- -----------------------------------------------------------------------------
drop policy if exists "users_select_own" on public.users;
drop policy if exists "users_insert_own" on public.users;
drop policy if exists "users_update_own" on public.users;

create policy "users_select_own" on public.users
  for select to authenticated
  using (id = auth.uid());

create policy "users_insert_own" on public.users
  for insert to authenticated
  with check (id = auth.uid());

create policy "users_update_own" on public.users
  for update to authenticated
  using (id = auth.uid())
  with check (id = auth.uid());

-- -----------------------------------------------------------------------------
-- lesson_screens: authenticated users can SELECT (public content)
-- -----------------------------------------------------------------------------
drop policy if exists "lesson_screens_select_all" on public.lesson_screens;

create policy "lesson_screens_select_all" on public.lesson_screens
  for select to authenticated
  using (true);

-- -----------------------------------------------------------------------------
-- lesson_progress: authenticated users can SELECT/INSERT/UPDATE their own rows
-- where user_id = auth.uid()
-- -----------------------------------------------------------------------------
drop policy if exists "lesson_progress_select_own" on public.lesson_progress;
drop policy if exists "lesson_progress_insert_own" on public.lesson_progress;
drop policy if exists "lesson_progress_update_own" on public.lesson_progress;

create policy "lesson_progress_select_own" on public.lesson_progress
  for select to authenticated
  using (user_id = auth.uid());

create policy "lesson_progress_insert_own" on public.lesson_progress
  for insert to authenticated
  with check (user_id = auth.uid());

create policy "lesson_progress_update_own" on public.lesson_progress
  for update to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

-- -----------------------------------------------------------------------------
-- tool_states: authenticated users can SELECT/INSERT/UPDATE their own rows
-- where user_id = auth.uid()
-- -----------------------------------------------------------------------------
drop policy if exists "tool_states_select_own" on public.tool_states;
drop policy if exists "tool_states_insert_own" on public.tool_states;
drop policy if exists "tool_states_update_own" on public.tool_states;

create policy "tool_states_select_own" on public.tool_states
  for select to authenticated
  using (user_id = auth.uid());

create policy "tool_states_insert_own" on public.tool_states
  for insert to authenticated
  with check (user_id = auth.uid());

create policy "tool_states_update_own" on public.tool_states
  for update to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

-- -----------------------------------------------------------------------------
-- tool_state_events: authenticated users can SELECT/INSERT their own rows
-- where user_id = auth.uid()
-- -----------------------------------------------------------------------------
drop policy if exists "tool_state_events_select_own" on public.tool_state_events;
drop policy if exists "tool_state_events_insert_own" on public.tool_state_events;

create policy "tool_state_events_select_own" on public.tool_state_events
  for select to authenticated
  using (user_id = auth.uid());

create policy "tool_state_events_insert_own" on public.tool_state_events
  for insert to authenticated
  with check (user_id = auth.uid());

-- -----------------------------------------------------------------------------
-- goals: authenticated users can SELECT/INSERT/UPDATE their own rows
-- where user_id = auth.uid()
-- -----------------------------------------------------------------------------
drop policy if exists "goals_select_own" on public.goals;
drop policy if exists "goals_insert_own" on public.goals;
drop policy if exists "goals_update_own" on public.goals;

create policy "goals_select_own" on public.goals
  for select to authenticated
  using (user_id = auth.uid());

create policy "goals_insert_own" on public.goals
  for insert to authenticated
  with check (user_id = auth.uid());

create policy "goals_update_own" on public.goals
  for update to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

-- -----------------------------------------------------------------------------
-- her_notes: authenticated users can SELECT/INSERT/UPDATE their own rows
-- where user_id = auth.uid()
-- -----------------------------------------------------------------------------
drop policy if exists "her_notes_select_own" on public.her_notes;
drop policy if exists "her_notes_insert_own" on public.her_notes;
drop policy if exists "her_notes_update_own" on public.her_notes;

create policy "her_notes_select_own" on public.her_notes
  for select to authenticated
  using (user_id = auth.uid());

create policy "her_notes_insert_own" on public.her_notes
  for insert to authenticated
  with check (user_id = auth.uid());

create policy "her_notes_update_own" on public.her_notes
  for update to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

-- -----------------------------------------------------------------------------
-- portraits: authenticated users can SELECT/INSERT/UPDATE their own rows
-- where user_id = auth.uid()
-- -----------------------------------------------------------------------------
drop policy if exists "portraits_select_own" on public.portraits;
drop policy if exists "portraits_insert_own" on public.portraits;
drop policy if exists "portraits_update_own" on public.portraits;

create policy "portraits_select_own" on public.portraits
  for select to authenticated
  using (user_id = auth.uid());

create policy "portraits_insert_own" on public.portraits
  for insert to authenticated
  with check (user_id = auth.uid());

create policy "portraits_update_own" on public.portraits
  for update to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

-- -----------------------------------------------------------------------------
-- passed_on: de-identified community insights
-- INSERT: any authenticated user can insert (no user_id column by design)
-- SELECT: approved rows are readable by all (public)
-- -----------------------------------------------------------------------------
drop policy if exists "anyone can pass it on" on public.passed_on;
drop policy if exists "approved insights are readable by all" on public.passed_on;

create policy "anyone can pass it on"
  on public.passed_on for insert
  to authenticated
  with check (true);

create policy "approved insights are readable by all"
  on public.passed_on for select
  using (approved = true);
