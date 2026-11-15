-- Road to Baisakh: one-time setup for cross-device sync.
-- Paste all of this into Supabase → SQL Editor → New query, then click Run.

create table if not exists public.tracker_state (
  user_id    uuid primary key references auth.users (id) on delete cascade,
  data       jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

-- Lock the table so each signed-in person can only see and change their own row.
alter table public.tracker_state enable row level security;

drop policy if exists "own row: read"   on public.tracker_state;
drop policy if exists "own row: insert" on public.tracker_state;
drop policy if exists "own row: update" on public.tracker_state;

create policy "own row: read"   on public.tracker_state
  for select using (auth.uid() = user_id);
create policy "own row: insert" on public.tracker_state
  for insert with check (auth.uid() = user_id);
create policy "own row: update" on public.tracker_state
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
