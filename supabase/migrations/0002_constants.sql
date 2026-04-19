-- EcoTrack: move hardcoded constants into the database.
-- Depends on 0001_init.sql. Run after 0001 in the Supabase SQL Editor.
--
-- Replaces CHECK constraints on profiles/activities with FKs to lookup tables,
-- so new options can be added with an INSERT rather than a schema migration.

-- ============================================
-- activity_modes (lookup)
-- ============================================
create table public.activity_modes (
  value text primary key,
  label text not null,
  sort_order int not null default 0
);

insert into public.activity_modes (value, label, sort_order) values
  ('personal',  'Personal',           10),
  ('driving',   'Driving',            20),
  ('biking',    'Biking',             30),
  ('shipping',  'Shipping / Marine',  40);

alter table public.activity_modes enable row level security;
create policy "activity_modes_read" on public.activity_modes for select using (true);

-- ============================================
-- engine_sizes (lookup)
-- ============================================
create table public.engine_sizes (
  value text primary key,
  sort_order int not null default 0
);

insert into public.engine_sizes (value, sort_order) values
  ('Electric', 10),
  ('Hybrid',   20),
  ('1.0L',     30),
  ('1.2L',     40),
  ('1.4L',     50),
  ('1.6L',     60),
  ('2.0L',     70),
  ('2.5L',     80),
  ('3.0L+',    90);

alter table public.engine_sizes enable row level security;
create policy "engine_sizes_read" on public.engine_sizes for select using (true);

-- ============================================
-- industries (lookup)
-- ============================================
create table public.industries (
  value text primary key,
  sort_order int not null default 0
);

insert into public.industries (value, sort_order) values
  ('Transport',   10),
  ('Maritime',    20),
  ('Aviation',    30),
  ('Recycling',   40),
  ('Energy',      50),
  ('Agriculture', 60),
  ('Other',       70);

alter table public.industries enable row level security;
create policy "industries_read" on public.industries for select using (true);

-- ============================================
-- Swap CHECK constraints on profiles/activities for FKs to the new lookups.
-- Constraint names come from the defaults assigned by Postgres when CHECK
-- constraints are declared inline in 0001_init.sql.
-- ============================================
alter table public.profiles
  drop constraint if exists profiles_car_engine_size_check,
  drop constraint if exists profiles_industry_check,
  drop constraint if exists profiles_activity_mode_check;

alter table public.profiles
  add constraint profiles_car_engine_size_fkey
    foreign key (car_engine_size) references public.engine_sizes(value),
  add constraint profiles_industry_fkey
    foreign key (industry) references public.industries(value),
  add constraint profiles_activity_mode_fkey
    foreign key (activity_mode) references public.activity_modes(value);

alter table public.activities
  drop constraint if exists activities_mode_check;

alter table public.activities
  add constraint activities_mode_fkey
    foreign key (mode) references public.activity_modes(value);

-- ============================================
-- emission_suggestions (content, keyed by activity mode)
-- ============================================
create table public.emission_suggestions (
  id uuid primary key default gen_random_uuid(),
  mode text not null references public.activity_modes(value),
  suggestion text not null,
  sort_order int not null default 0
);

insert into public.emission_suggestions (mode, suggestion, sort_order) values
  ('personal', 'Replace one car trip per week with biking or walking.',             10),
  ('personal', 'Choose public transportation for short errands.',                   20),
  ('personal', 'Reduce air travel and choose train routes when possible.',          30),
  ('driving',  'Maintain proper tire pressure to improve fuel economy.',            10),
  ('driving',  'Use route planning to avoid traffic and minimize idle time.',       20),
  ('driving',  'Switch to electric or hybrid options for your next vehicle.',       30),
  ('biking',   'Plan bike-friendly routes to avoid busy streets.',                  10),
  ('biking',   'Combine errands into one ride to reduce repeat trips.',             20),
  ('biking',   'Use cargo bikes for short deliveries instead of cars.',             30),
  ('shipping', 'Optimize cargo load and choose cleaner fuels or hybrids.',          10),
  ('shipping', 'Reduce idle time in ports and use digital route planning.',         20),
  ('shipping', 'Monitor vessel speed to minimize fuel consumption.',                30);

alter table public.emission_suggestions enable row level security;
create policy "emission_suggestions_read" on public.emission_suggestions for select using (true);

-- ============================================
-- route_suggestions (content, currently global — not per-user)
-- ============================================
create table public.route_suggestions (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  benefit text not null,
  sort_order int not null default 0
);

insert into public.route_suggestions (name, benefit, sort_order) values
  ('Shorter route via Oak Avenue',     '2.4 km shorter, 8 min faster',                10),
  ('Low-traffic Green Boulevard',      'Avoids congestion and lowers CO2 by 12%',     20),
  ('Eco-friendly highway route',       'Better speed consistency for fewer emissions', 30);

alter table public.route_suggestions enable row level security;
create policy "route_suggestions_read" on public.route_suggestions for select using (true);
