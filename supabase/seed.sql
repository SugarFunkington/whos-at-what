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

-- Categories: one of Test Family's own (no starter list yet)
insert into public.categories (id, family_id, name)
values ('cccccccc-cccc-cccc-cccc-cccccccccccc', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Hurling');

-- Events ----------------------------------------------------------------------
-- Times are "today" in the family's timezone, so there's always something
-- on today's calendar after a reset.
insert into public.events (id, family_id, title, category_id, starts_at, ends_at, all_day, repeat, notes, created_by)
values
  -- Weekly swimming, Ella
  ('e0000000-0000-0000-0000-000000000001', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Swimming',
   null,
   (current_date + time '16:00') at time zone 'Europe/Dublin',
   (current_date + time '17:00') at time zone 'Europe/Dublin',
   false, 'FREQ=WEEKLY', 'Bring goggles', '11111111-1111-1111-1111-111111111111'),
  -- One-off slow cooker dinner, Parent cooking
  ('e0000000-0000-0000-0000-000000000002', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Beef stew',
   null,
   (current_date + time '18:00') at time zone 'Europe/Dublin',
   (current_date + time '19:00') at time zone 'Europe/Dublin',
   false, null, null, '11111111-1111-1111-1111-111111111111'),
  -- Weekly bin day, all day, nobody attached = whole family
  ('e0000000-0000-0000-0000-000000000003', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Bins out',
   null,
   current_date::timestamp at time zone 'Europe/Dublin',
   current_date::timestamp at time zone 'Europe/Dublin',
   true, 'FREQ=WEEKLY', null, '11111111-1111-1111-1111-111111111111'),
  -- Other Family's event, which Test Family must never see
  ('e0000000-0000-0000-0000-000000000004', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'Football',
   null,
   (current_date + time '10:00') at time zone 'Europe/Dublin',
   (current_date + time '11:00') at time zone 'Europe/Dublin',
   false, null, null, '22222222-2222-2222-2222-222222222222');

-- Who each event is for (Bins out has no rows = whole family)
insert into public.event_members (event_id, member_id)
select 'e0000000-0000-0000-0000-000000000001'::uuid, id from public.members where display_name = 'Ella'
union all
select 'e0000000-0000-0000-0000-000000000002'::uuid, id from public.members where display_name = 'Parent'
union all
select 'e0000000-0000-0000-0000-000000000004'::uuid, id from public.members where display_name = 'Stranger';
