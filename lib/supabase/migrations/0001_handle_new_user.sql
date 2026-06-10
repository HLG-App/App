-- Migration: handle_new_user trigger
-- Purpose: When a new Supabase Auth user is created, ensure a matching row exists in public.users.

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.users (id, created_at)
  values (new.id, now())
  on conflict do nothing;

  return new;
end;
$$;

drop trigger if exists handle_new_user on auth.users;

create trigger handle_new_user
after insert on auth.users
for each row
execute function public.handle_new_user();
