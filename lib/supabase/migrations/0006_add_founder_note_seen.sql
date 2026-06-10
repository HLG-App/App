alter table public.users
add column if not exists founder_note_seen bool default false;
