-- Creates per-user "phase entry seen" tracking.

create table if not exists public.phase_progress (
  user_id uuid not null references auth.users(id) on delete cascade,
  phase_id integer not null,
  seen_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  primary key (user_id, phase_id)
);

create index if not exists idx_phase_progress_user on public.phase_progress(user_id);

alter table public.phase_progress enable row level security;

drop policy if exists "phase_progress_select_own" on public.phase_progress;
drop policy if exists "phase_progress_insert_own" on public.phase_progress;
drop policy if exists "phase_progress_update_own" on public.phase_progress;

create policy "phase_progress_select_own" on public.phase_progress
for select
using (auth.uid() = user_id);

create policy "phase_progress_insert_own" on public.phase_progress
for insert
with check (auth.uid() = user_id);

create policy "phase_progress_update_own" on public.phase_progress
for update
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

-- updated_at trigger helper (safe to run even if already exists)
do $$
begin
  if not exists (select 1 from pg_proc where proname = 'set_updated_at') then
    create or replace function public.set_updated_at()
    returns trigger
    language plpgsql
    as $$
    begin
      new.updated_at = now();
      return new;
    end;
    $$;
  end if;
end $$;

drop trigger if exists trg_phase_progress_updated_at on public.phase_progress;
create trigger trg_phase_progress_updated_at
before update on public.phase_progress
for each row
execute function public.set_updated_at();
