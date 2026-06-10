-- Create tool_state_events (append-only history log for tool state changes)
--
-- Requirements:
--  - Preserve existing tool_states behavior (latest/current snapshot)
--  - tool_state_events is historical-only; no UI wiring in this migration
--  - Backward compatible with existing dashboard/tool save flows

create extension if not exists "pgcrypto";

create table if not exists public.tool_state_events (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  tool_code text not null,
  type text not null,
  payload jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

-- Indexes
create index if not exists idx_tool_state_events_user_tool
  on public.tool_state_events (user_id, tool_code);

create index if not exists idx_tool_state_events_created_at
  on public.tool_state_events (created_at);
