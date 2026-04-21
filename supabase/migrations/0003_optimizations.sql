-- EcoTrack: Backend Optimizations and Fixes

-- 1. Add composite index for faster aggregation and filtering
create index if not exists activities_user_id_co2_kg_idx
  on public.activities (user_id, co2_kg, started_at desc);

-- 2. Improve Leaderboard View:
-- Adding stable ordering and explicit grouping for all selected columns (best practice)
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
group by p.id, p.full_name, p.photo_uri, p.city, p.country, p.activity_mode
order by total_co2_kg desc, p.id asc
limit 100;

-- 3. Optimization: Add index for profile lookups by name (future-proofing search)
create index if not exists profiles_full_name_trgm_idx on public.profiles using gin (full_name gin_trgm_ops)
  where full_name <> '';

-- 4. Fix: Ensure profiles updated from metadata handles cases where name might be changed in provider
-- (Though we keep 'on conflict do nothing' to respect user in-app overrides)
-- No changes needed to handle_new_user as it currently works as intended for initialization.
