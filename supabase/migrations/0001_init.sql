-- EcoTrack initial schema
-- Run this in the Supabase SQL Editor (Project → SQL → New query) as a single script.

-- ============================================
-- profiles
-- ============================================
create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null default '',
  height_cm text default '',
  weight_kg text default '',
  country text default '',
  city text default '',
  car_engine_size text check (car_engine_size in
    ('1.0L','1.2L','1.4L','1.6L','2.0L','2.5L','3.0L+','Electric','Hybrid','Other')),
  industry text check (industry in
    ('Transport','Maritime','Aviation','Recycling','Energy','Agriculture','Other')),
  activity_mode text check (activity_mode in
    ('personal','driving','biking','shipping')),
  photo_uri text,
  created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;

create policy "profiles_select_own" on public.profiles
  for select using (auth.uid() = id);

create policy "profiles_insert_own" on public.profiles
  for insert with check (auth.uid() = id);

create policy "profiles_update_own" on public.profiles
  for update using (auth.uid() = id) with check (auth.uid() = id);

-- ============================================
-- Auto-create profile row on signup; hydrate from Google metadata
-- ============================================
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, full_name, photo_uri)
  values (
    new.id,
    coalesce(
      new.raw_user_meta_data->>'full_name',
      new.raw_user_meta_data->>'name',
      ''
    ),
    new.raw_user_meta_data->>'avatar_url'
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ============================================
-- activities
-- ============================================
create table public.activities (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  mode text not null check (mode in ('personal','driving','biking','shipping')),
  distance_km numeric(10,3) not null default 0,
  duration_minutes int not null default 0,
  co2_kg numeric(10,3) not null default 0,
  started_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);

create index activities_user_id_started_at_idx
  on public.activities (user_id, started_at desc);

alter table public.activities enable row level security;

create policy "activities_select_own" on public.activities
  for select using (auth.uid() = user_id);

create policy "activities_insert_own" on public.activities
  for insert with check (auth.uid() = user_id);

create policy "activities_update_own" on public.activities
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "activities_delete_own" on public.activities
  for delete using (auth.uid() = user_id);

-- ============================================
-- leaderboard view
-- SECURITY DEFINER so callers can see aggregates across users,
-- while the profiles table itself remains own-only.
-- ============================================
create or replace view public.leaderboard
with (security_invoker = false) as
select
  p.id,
  p.full_name,
  p.photo_uri,
  p.city,
  p.country,
  p.activity_mode,
  coalesce(sum(a.co2_kg), 0) as total_co2_kg,
  count(a.id) as activity_count
from public.profiles p
left join public.activities a on a.user_id = p.id
group by p.id
order by total_co2_kg desc
limit 100;

grant select on public.leaderboard to authenticated, anon;

-- ============================================
-- daily_co2 view for Analytics charts (own-user only)
-- ============================================
create or replace view public.daily_co2
with (security_invoker = true) as
select
  user_id,
  date_trunc('day', started_at)::date as day,
  sum(co2_kg) as co2_kg
from public.activities
group by user_id, day;

grant select on public.daily_co2 to authenticated;
