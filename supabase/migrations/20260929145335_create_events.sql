-- ============================================================================
-- Events: the calendar itself.
--   categories     - kinds of activity (starter list + each family's own)
--   events         - what's happening and when (stored once)
--   event_members  - who each event is for (no rows = whole family)
-- Checklist for each table: create -> enable RLS -> grant -> policies
-- ============================================================================


-- ----------------------------------------------------------------------------
-- Shared helper: keep updated_at current whenever a row is edited
-- ----------------------------------------------------------------------------
create or replace function public.set_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;


-- ----------------------------------------------------------------------------
-- categories
-- family_id empty = on the starter list, visible to every family
-- ----------------------------------------------------------------------------
create table public.categories (
  id          uuid primary key default gen_random_uuid(),
  family_id   uuid references public.families(id) on delete cascade,
  name        text not null check (length(trim(name)) > 0),
  created_at  timestamptz not null default now()
);

-- No duplicate names within a family (or within the starter list).
-- Case-insensitive, so "hurling" and "Hurling" count as the same.
-- "nulls not distinct" makes all starter-list rows count as one group.
create unique index categories_family_name_unique
  on public.categories (family_id, lower(name)) nulls not distinct;

alter table public.categories enable row level security;

grant select, insert, update, delete on public.categories to authenticated;

create policy "View starter and own family categories"
on public.categories for select
to authenticated
using (family_id is null or family_id in (select public.my_family_ids()));

-- Families can only add/edit/delete their OWN categories, never the starter list
create policy "Add own family categories"
on public.categories for insert
to authenticated
with check (family_id in (select public.my_family_ids()));

create policy "Edit own family categories"
on public.categories for update
to authenticated
using (family_id in (select public.my_family_ids()))
with check (family_id in (select public.my_family_ids()));

create policy "Delete own family categories"
on public.categories for delete
to authenticated
using (family_id in (select public.my_family_ids()));


-- ----------------------------------------------------------------------------
-- events
-- For repeating events, starts_at/ends_at are the FIRST occurrence.
-- ----------------------------------------------------------------------------
create table public.events (
  id           uuid primary key default gen_random_uuid(),
  family_id    uuid not null references public.families(id) on delete cascade,
  title        text not null check (length(trim(title)) > 0),
  category_id  uuid references public.categories(id) on delete set null,
  starts_at    timestamptz not null,
  ends_at      timestamptz not null,
  all_day      boolean not null default false,
  -- Standard calendar repeat format (RFC 5545). Empty = one-off.
  -- v1 only allows these three; widen this list when adding e.g. skip-weeks.
  repeat       text check (repeat in ('FREQ=DAILY', 'FREQ=WEEKLY', 'FREQ=MONTHLY')),
  notes        text,
  created_by   uuid default auth.uid() references auth.users(id) on delete set null,
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now(),

  constraint events_end_not_before_start check (ends_at >= starts_at)
);

-- Speeds up "show me this family's events around this date"
create index events_family_starts_at_idx on public.events (family_id, starts_at);

create trigger events_set_updated_at
before update on public.events
for each row execute function public.set_updated_at();

alter table public.events enable row level security;

grant select, insert, update, delete on public.events to authenticated;

create policy "View own family events"
on public.events for select
to authenticated
using (family_id in (select public.my_family_ids()));

-- Adding/editing: must be your family, and the category (if any) must be
-- one this family can use - starter list or its own.
create policy "Add own family events"
on public.events for insert
to authenticated
with check (
  family_id in (select public.my_family_ids())
  and (
    category_id is null
    or exists (
      select 1 from public.categories c
      where c.id = category_id
        and (c.family_id is null or c.family_id = events.family_id)
    )
  )
);

create policy "Edit own family events"
on public.events for update
to authenticated
using (family_id in (select public.my_family_ids()))
with check (
  family_id in (select public.my_family_ids())
  and (
    category_id is null
    or exists (
      select 1 from public.categories c
      where c.id = category_id
        and (c.family_id is null or c.family_id = events.family_id)
    )
  )
);

create policy "Delete own family events"
on public.events for delete
to authenticated
using (family_id in (select public.my_family_ids()));


-- ----------------------------------------------------------------------------
-- event_members  (the link table)
-- One row per person per event. No rows for an event = whole family.
-- ----------------------------------------------------------------------------
create table public.event_members (
  event_id   uuid not null references public.events(id) on delete cascade,
  member_id  uuid not null references public.members(id) on delete cascade,
  primary key (event_id, member_id)
);

-- The primary key already makes "who's at this event?" fast.
-- This makes the reverse, "what is Ella doing?", fast too.
create index event_members_member_id_idx on public.event_members (member_id);

alter table public.event_members enable row level security;

-- No update: a row is just a pairing. To change who's at an event,
-- delete one row and add another.
grant select, insert, delete on public.event_members to authenticated;

create policy "View own family event members"
on public.event_members for select
to authenticated
using (
  event_id in (
    select id from public.events
    where family_id in (select public.my_family_ids())
  )
);

-- The event must be in your family AND the person must be in that same
-- family - you can't put someone from another family on your event.
create policy "Add own family event members"
on public.event_members for insert
to authenticated
with check (
  exists (
    select 1
    from public.events e
    join public.members m on m.family_id = e.family_id
    where e.id = event_id
      and m.id = member_id
      and e.family_id in (select public.my_family_ids())
  )
);

create policy "Remove own family event members"
on public.event_members for delete
to authenticated
using (
  event_id in (
    select id from public.events
    where family_id in (select public.my_family_ids())
  )
);
