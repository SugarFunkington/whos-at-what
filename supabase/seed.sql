-- Test data for the LOCAL database only.
-- Runs automatically after `supabase db reset`. Never pushed to the real database.
--
-- Two families, so we can check that each family only sees its own data:
--   Test Family   : parent@example.com (login) + Ella (child, no login)
--   Other Family  : stranger@example.com (login)
-- Both test logins use the password: password123

-- Login accounts ------------------------------------------------------------
insert into auth.users (
  instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
  raw_app_meta_data, raw_user_meta_data, created_at, updated_at,
  confirmation_token, email_change, email_change_token_new, recovery_token
)
values
  ('00000000-0000-0000-0000-000000000000', '11111111-1111-1111-1111-111111111111',
   'authenticated', 'authenticated', 'parent@example.com',
   extensions.crypt('password123', extensions.gen_salt('bf')), now(),
   '{"provider":"email","providers":["email"]}', '{}', now(), now(), '', '', '', ''),
  ('00000000-0000-0000-0000-000000000000', '22222222-2222-2222-2222-222222222222',
   'authenticated', 'authenticated', 'stranger@example.com',
   extensions.crypt('password123', extensions.gen_salt('bf')), now(),
   '{"provider":"email","providers":["email"]}', '{}', now(), now(), '', '', '', '');

-- Each login also needs an "identity" row saying it uses email + password
insert into auth.identities (
  id, user_id, provider_id, identity_data, provider, last_sign_in_at, created_at, updated_at
)
select gen_random_uuid(), id, id::text,
       jsonb_build_object('sub', id::text, 'email', email, 'email_verified', true),
       'email', now(), now(), now()
from auth.users
where id in ('11111111-1111-1111-1111-111111111111', '22222222-2222-2222-2222-222222222222');

-- Families ------------------------------------------------------------------
insert into public.families (id, name)
values
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Test Family'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'Other Family');

-- Members (user_id empty = child with no login) -------------------------------
insert into public.members (family_id, display_name, colour, user_id)
values
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Parent',   '#3B82F6', '11111111-1111-1111-1111-111111111111'),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Ella',     '#EC4899', null),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'Stranger', '#10B981', '22222222-2222-2222-2222-222222222222');

-- Event templates ---------------------------------------------------------------
-- One starter (family empty), for checking starters stay read-only and can't
-- have members. The real starter list is #10. Test Family has its own
-- "Swimming" too: titles don't have to be unique.
insert into public.event_templates (id, family_id, title, emoji, location, start_time, duration)
values
  ('cccccccc-cccc-cccc-cccc-ccccccccccc0', null,                                   'Swimming', '🏊', null,                      null,          null),
  ('cccccccc-cccc-cccc-cccc-cccccccccccc', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Hurling',  '🏑', null,                      null,          null),
  ('cccccccc-cccc-cccc-cccc-ccccccccccc1', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Swimming', '🏊', 'Leisure Centre, Main St', time '16:00', interval '1 hour'),
  ('cccccccc-cccc-cccc-cccc-ccccccccccc2', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Dinner',   '🍲', 'Home',                    time '18:00', interval '1 hour'),
  ('cccccccc-cccc-cccc-cccc-ccccccccccc3', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Chores',   '🗑️', 'Home',                    null,          null);

-- Ella goes to Test Family's swimming
insert into public.event_template_members (event_template_id, member_id)
select 'cccccccc-cccc-cccc-cccc-ccccccccccc1', id
from public.members
where display_name = 'Ella';

-- Events ----------------------------------------------------------------------
-- The app doesn't expand repeating events yet (#4), so instead of one row per
-- event, each one gets a copy for every day from 30 days ago to a year ahead.
-- Today always has events without rebuilding the database (until a year after
-- the last reset). The copies are one-offs (repeat empty); revisit with #4.
-- Emoji and location are copied from the template, as the app will do.
insert into public.events (family_id, title, event_template_id, emoji, location, starts_at, duration, notes, created_by)
select e.family_id, e.title, e.event_template_id, e.emoji, e.location,
       (g.day::date + e.starts) at time zone 'Europe/Dublin',
       e.duration, e.notes, e.created_by
-- ::date matters: generate_series returns timestamptz here, and converting
-- that to Dublin time again would shift every event by the UTC offset.
from generate_series(current_date - 30, current_date + 365, interval '1 day') as g(day)
cross join (values
  -- Swimming, Ella
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid, 'Swimming',
   'cccccccc-cccc-cccc-cccc-ccccccccccc1'::uuid, '🏊', 'Leisure Centre, Main St',
   time '16:00', interval '1 hour', 'Bring goggles', '11111111-1111-1111-1111-111111111111'::uuid),
  -- Slow cooker dinner, Parent cooking
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Beef stew',
   'cccccccc-cccc-cccc-cccc-ccccccccccc2', '🍲', 'Home',
   time '18:00', interval '1 hour', null, '11111111-1111-1111-1111-111111111111'),
  -- Bins at 6am, no duration, nobody attached = whole family
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Bins out',
   'cccccccc-cccc-cccc-cccc-ccccccccccc3', '🗑️', 'Home',
   time '06:00', null, null, '11111111-1111-1111-1111-111111111111'),
  -- Other Family's event, which Test Family must never see. No template,
  -- emoji or location, so the "empty" case has data too.
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'Football',
   null, null, null,
   time '10:00', interval '1 hour', null, '22222222-2222-2222-2222-222222222222')
) as e(family_id, title, event_template_id, emoji, location, starts, duration, notes, created_by);

-- Who each event is for (Bins out has no rows = whole family)
insert into public.event_members (event_id, member_id)
select e.id, m.id
from public.events e
join public.members m
  on m.family_id = e.family_id
 and m.display_name = case e.title
                        when 'Swimming'  then 'Ella'
                        when 'Beef stew' then 'Parent'
                        when 'Football'  then 'Stranger'
                      end;
