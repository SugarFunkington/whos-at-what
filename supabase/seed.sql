-- Test data for the LOCAL database only.
-- Runs automatically after `supabase db reset`. Never pushed to the real database.
--
-- Two families, so we can check that each family only sees its own data:
--   Test Family   : Sarah (login 1) + Dave (login 2), children Ella (10),
--                   Jack (8) and Molly (5) with no login
--   Other Family  : Stranger (login 3)
-- The "emails" are just numbers so they are quick to type; every password is 1.

-- Login accounts ------------------------------------------------------------
insert into auth.users (
  instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
  raw_app_meta_data, raw_user_meta_data, created_at, updated_at,
  confirmation_token, email_change, email_change_token_new, recovery_token
)
select '00000000-0000-0000-0000-000000000000', u.id,
       'authenticated', 'authenticated', u.email,
       extensions.crypt('1', extensions.gen_salt('bf')), now(),
       '{"provider":"email","providers":["email"]}', '{}', now(), now(), '', '', '', ''
from (values
  ('11111111-1111-1111-1111-111111111111'::uuid, '1'),  -- Sarah
  ('11111111-1111-1111-1111-111111111112'::uuid, '2'),  -- Dave
  ('22222222-2222-2222-2222-222222222222'::uuid, '3')   -- Stranger
) as u(id, email);

-- Each login also needs an "identity" row saying it uses email + password
insert into auth.identities (
  id, user_id, provider_id, identity_data, provider, last_sign_in_at, created_at, updated_at
)
select gen_random_uuid(), id, id::text,
       jsonb_build_object('sub', id::text, 'email', email, 'email_verified', true),
       'email', now(), now(), now()
from auth.users
where id in ('11111111-1111-1111-1111-111111111111', '11111111-1111-1111-1111-111111111112',
             '22222222-2222-2222-2222-222222222222');

-- Families ------------------------------------------------------------------
insert into public.families (id, name)
values
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Test Family'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'Other Family');

-- Members (user_id empty = child with no login) -------------------------------
insert into public.members (family_id, display_name, colour, user_id)
values
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Sarah',    '#3B82F6', '11111111-1111-1111-1111-111111111111'),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Dave',     '#14B8A6', '11111111-1111-1111-1111-111111111112'),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Ella',     '#EC4899', null),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Jack',     '#F97316', null),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Molly',    '#8B5CF6', null),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'Stranger', '#10B981', '22222222-2222-2222-2222-222222222222');

-- Event templates ---------------------------------------------------------------
-- One starter (family empty), for checking starters stay read-only and can't
-- have members. The real starter list is #10. Test Family has its own
-- "Swimming" too: titles don't have to be unique.
insert into public.event_templates (id, family_id, title, emoji, location, start_time, duration)
values
  ('cccccccc-cccc-cccc-cccc-ccccccccccc0', null,                                   'Swimming', '🏊', null,                      null,          null),
  ('cccccccc-cccc-cccc-cccc-cccccccccccc', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Hurling',  '🏑', null,                      null,          null),
  ('cccccccc-cccc-cccc-cccc-ccccccccccc1', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Swimming', '🏊', 'Leisure Centre, Main St', time '16:00', interval '45 minutes'),
  ('cccccccc-cccc-cccc-cccc-ccccccccccc2', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Dinner',   '🍲', 'Home',                    time '17:30', interval '1 hour'),
  ('cccccccc-cccc-cccc-cccc-ccccccccccc3', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Chores',   '🗑️', 'Home',                    null,          null);

-- Molly goes to Test Family's swimming
insert into public.event_template_members (event_template_id, member_id)
select 'cccccccc-cccc-cccc-cccc-ccccccccccc1', id
from public.members
where display_name = 'Molly';

-- Events ----------------------------------------------------------------------
-- A full weekday for Test Family: school, lessons, sport, chores, and a
-- parent's night out. Parents' work only shows as when they leave.
--
-- The app doesn't expand repeating events yet (#4), so instead of one row per
-- event, each one gets a copy for every day from 30 days ago to a year ahead.
-- Today always has events without rebuilding the database (until a year after
-- the last reset). The copies are one-offs (repeat empty); revisit with #4.
-- Emoji and location are copied from the template, as the app will do.
-- Some events share a start time (4pm, 6:30pm) to test grouping, and some
-- have no duration (e.g. "Bins out").
insert into public.events (family_id, title, event_template_id, emoji, location, starts_at, duration, notes, created_by)
select e.family_id, e.title, e.event_template_id, e.emoji, e.location,
       (g.day::date + e.starts) at time zone 'Europe/Dublin',
       e.duration, e.notes, e.created_by
-- ::date matters: generate_series returns timestamptz here, and converting
-- that to Dublin time again would shift every event by the UTC offset.
from generate_series(current_date - 30, current_date + 365, interval '1 day') as g(day)
cross join (values
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid, 'Bins out',
   'cccccccc-cccc-cccc-cccc-ccccccccccc3'::uuid, '🗑️', 'Home',
   time '06:00', null::interval, 'Green bin this week', '11111111-1111-1111-1111-111111111111'::uuid),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Walk Bailey',
   null, '🐕', 'Park loop',
   time '06:45', interval '30 minutes', null, '11111111-1111-1111-1111-111111111112'),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Pack lunches',
   null, '🥪', 'Home',
   time '07:30', interval '15 minutes', 'Molly: no nuts, class rule', '11111111-1111-1111-1111-111111111111'),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Dave leaves for work',
   null, '🚗', null,
   time '08:00', null, null, '11111111-1111-1111-1111-111111111112'),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'School drop-off',
   null, '🏫', 'St. Brigid''s NS',
   time '08:30', interval '20 minutes', 'Jack: PE gear today', '11111111-1111-1111-1111-111111111111'),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Sarah leaves for work',
   null, '🚗', null,
   time '09:00', null, null, '11111111-1111-1111-1111-111111111111'),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Molly collected by Granny',
   null, '🎒', 'St. Brigid''s NS',
   time '13:30', null, 'Granny has her until 3:30', '11111111-1111-1111-1111-111111111111'),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'School pick-up',
   null, '🏫', 'St. Brigid''s NS',
   time '15:00', interval '20 minutes', null, '11111111-1111-1111-1111-111111111112'),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Homework',
   null, '✏️', 'Home',
   time '15:30', interval '30 minutes', null, '11111111-1111-1111-1111-111111111111'),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Piano lesson',
   null, '🎹', 'Mrs Byrne''s, Church Rd',
   time '16:00', interval '30 minutes', 'Bring grade 2 book', '11111111-1111-1111-1111-111111111111'),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Swimming',
   'cccccccc-cccc-cccc-cccc-ccccccccccc1', '🏊', 'Leisure Centre, Main St',
   time '16:00', interval '45 minutes', 'Bring goggles', '11111111-1111-1111-1111-111111111111'),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Guitar lesson',
   null, '🎸', 'Music Hub, Main St',
   time '16:45', interval '30 minutes', null, '11111111-1111-1111-1111-111111111111'),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Beef stew',
   'cccccccc-cccc-cccc-cccc-ccccccccccc2', '🍲', 'Home',
   time '17:30', interval '1 hour', 'Slow cooker on at 8am', '11111111-1111-1111-1111-111111111112'),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Hurling training',
   'cccccccc-cccc-cccc-cccc-cccccccccccc', '🏑', 'GAA Club',
   time '18:30', interval '1 hour', 'Helmet, hurley, water bottle', '11111111-1111-1111-1111-111111111112'),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Evening walk',
   null, '🐕', 'Around the block',
   time '18:30', interval '20 minutes', null, '11111111-1111-1111-1111-111111111111'),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Bath & bedtime',
   null, '🛁', 'Home',
   time '19:00', interval '45 minutes', null, '11111111-1111-1111-1111-111111111111'),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Drinks with Aoife',
   null, '🍷', 'The Stag''s Head',
   time '20:00', interval '2 hours 30 minutes', 'Dave on bedtime duty', '11111111-1111-1111-1111-111111111111'),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Uniforms out for tomorrow',
   null, '👕', 'Home',
   time '21:00', null, null, '11111111-1111-1111-1111-111111111112'),
  -- Other Family's event, which Test Family must never see. No template,
  -- emoji or location, so the "empty" case has data too.
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'Football',
   null, null, null,
   time '10:00', interval '1 hour', null, '22222222-2222-2222-2222-222222222222')
) as e(family_id, title, event_template_id, emoji, location, starts, duration, notes, created_by);

-- Who each event is for. "Bins out" and "Beef stew" have no rows = whole family.
insert into public.event_members (event_id, member_id)
select e.id, m.id
from public.events e
join (values
  ('Walk Bailey',               'Dave'),
  ('Pack lunches',              'Sarah'),
  ('Dave leaves for work',      'Dave'),
  ('School drop-off',           'Sarah'),
  ('School drop-off',           'Ella'),
  ('School drop-off',           'Jack'),
  ('School drop-off',           'Molly'),
  ('Sarah leaves for work',     'Sarah'),
  ('Molly collected by Granny', 'Molly'),
  ('School pick-up',            'Dave'),
  ('School pick-up',            'Ella'),
  ('School pick-up',            'Jack'),
  ('Homework',                  'Ella'),
  ('Homework',                  'Jack'),
  ('Piano lesson',              'Ella'),
  ('Swimming',                  'Molly'),
  ('Guitar lesson',             'Jack'),
  ('Hurling training',          'Jack'),
  ('Hurling training',          'Dave'),
  ('Evening walk',              'Ella'),
  ('Bath & bedtime',            'Molly'),
  ('Bath & bedtime',            'Sarah'),
  ('Drinks with Aoife',         'Sarah'),
  ('Uniforms out for tomorrow', 'Dave'),
  ('Football',                  'Stranger')
) as em(title, display_name) on em.title = e.title
join public.members m
  on m.family_id = e.family_id
 and m.display_name = em.display_name;
