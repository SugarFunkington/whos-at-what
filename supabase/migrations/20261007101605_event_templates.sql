-- ============================================================================
-- Event templates (#37): categories become event templates, and events get
-- their own emoji and a duration instead of ends_at. Decided in #9.
--   event_templates         - saved values copied into a new event: a starter
--                             "Swimming" or a family's "Play date with Clodagh"
--   event_template_members  - who a template's events are for
-- Events COPY from a template; nothing links live, so changing a template
-- never changes existing events.
-- ============================================================================


-- ----------------------------------------------------------------------------
-- categories -> event_templates
-- A rename keeps the table's grants, RLS policies, indexes and foreign keys:
-- Postgres tracks them by the table, not by its name. Only the names that
-- still say "categories" are renamed below, for clarity.
-- ----------------------------------------------------------------------------
alter table public.categories rename to event_templates;
alter table public.event_templates rename column name to title;

-- Titles aren't unique: "Swimming" for Ella and "Swimming" for Jack are two
-- templates.
drop index public.categories_family_name_unique;

alter table public.event_templates rename constraint categories_pkey to event_templates_pkey;
alter table public.event_templates rename constraint categories_family_id_fkey to event_templates_family_id_fkey;
alter table public.event_templates rename constraint categories_name_check to event_templates_title_check;
alter table public.event_templates rename constraint categories_emoji_check to event_templates_emoji_check;

alter policy "View starter and own family categories" on public.event_templates
  rename to "View starter and own family templates";
alter policy "Add own family categories" on public.event_templates
  rename to "Add own family templates";
alter policy "Edit own family categories" on public.event_templates
  rename to "Edit own family templates";
alter policy "Delete own family categories" on public.event_templates
  rename to "Delete own family templates";

-- Everything an event has except the date. All optional: a starter fills in
-- a little, a saved event fills in everything. Same checks as on events.
alter table public.event_templates
  add column location    text check (length(trim(location)) > 0),
  add column notes       text,
  add column start_time  time,
  add column duration    interval check (duration >= interval '0'),
  add column all_day     boolean not null default false,
  add column repeat      text check (repeat in ('FREQ=DAILY', 'FREQ=WEEKLY', 'FREQ=MONTHLY'));


-- ----------------------------------------------------------------------------
-- events
-- The insert/update policies that check "the category is a starter or this
-- family's own" follow the renames on their own, so they now check the
-- template. No policy changes needed.
-- ----------------------------------------------------------------------------
alter table public.events rename column category_id to event_template_id;
alter table public.events rename constraint events_category_id_fkey to events_event_template_id_fkey;

-- The event's own emoji, copied from its template when it's created.
-- Empty = null, never '' or spaces.
alter table public.events
  add column emoji text check (length(trim(emoji)) > 0);

-- duration replaces ends_at. Optional: "Bins out at 6am" has none.
alter table public.events
  add column duration interval check (duration >= interval '0');

update public.events
set duration = ends_at - starts_at
where ends_at is not null;

alter table public.events drop constraint events_end_not_before_start;
alter table public.events drop column ends_at;


-- ----------------------------------------------------------------------------
-- event_template_members  (the link table, same shape as event_members)
-- One row per person per template. Copied into event_members when an event
-- is created from the template.
-- ----------------------------------------------------------------------------
create table public.event_template_members (
  event_template_id  uuid not null references public.event_templates(id) on delete cascade,
  member_id          uuid not null references public.members(id) on delete cascade,
  primary key (event_template_id, member_id)
);

-- Makes "which templates is Ella on?" fast.
create index event_template_members_member_id_idx on public.event_template_members (member_id);

alter table public.event_template_members enable row level security;

-- No update: to change who's on a template, delete one row and add another.
grant select, insert, delete on public.event_template_members to authenticated;

create policy "View own family template members"
on public.event_template_members for select
to authenticated
using (
  event_template_id in (
    select id from public.event_templates
    where family_id in (select public.my_family_ids())
  )
);

-- The template must be your family's AND the person must be in that same
-- family. Starters (family_id empty) match no member, so they can't have any.
create policy "Add own family template members"
on public.event_template_members for insert
to authenticated
with check (
  exists (
    select 1
    from public.event_templates t
    join public.members m on m.family_id = t.family_id
    where t.id = event_template_id
      and m.id = member_id
      and t.family_id in (select public.my_family_ids())
  )
);

create policy "Remove own family template members"
on public.event_template_members for delete
to authenticated
using (
  event_template_id in (
    select id from public.event_templates
    where family_id in (select public.my_family_ids())
  )
);
