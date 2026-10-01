# WhosAtWhat

A family calendar app: what everyone in the family is doing today, with a "how to prep for the day" panel at the top. Parents log in; children are family members without a login.

- `supabase/` - backend: migrations, `seed.sql` test data, RLS permission checks
- `app/` - Flutter app (early: currently a "Hello world" stub)

Commands, test logins and the database-change workflow live in `README.md`.

## How we work

The user is learning Flutter through this project. Work in small, agreed steps:

- Each piece of work starts from a GitHub issue (`gh issue list`). Labels `v1` / `later` set scope.
- Do the one step asked for, explain the Flutter concepts it uses, then stop and let the user pick the next step.
- When a ticket has several tasks, treat each task as its own step.

## Safety

The real (hosted) Supabase project must never be put at risk.

- **RLS is the security boundary.** Every table follows: create -> enable RLS -> grant -> policies. Each family sees and changes only its own data, gated by `public.my_family_ids()`. Extend `supabase/tests/rls_check.py` alongside any schema change, and run it after `supabase db reset`.
- **The app holds only the publishable key.** It ships inside the app binary, so it is public by design. The secret / service_role key and the database password bypass RLS; they stay in a password manager and out of `app/`, git and builds.
- **Keys stay out of git.** App config lives in `app/env/*.json`, which is gitignored. Only `app/env/example.json` is committed, with placeholders. Run with `flutter run --dart-define-from-file=env/local.json`.
- **Develop against local Supabase.** `rls_check.py` refuses to run against anything but localhost; keep new tooling the same way.

## Domain rules

These live in the migrations; they are summarised here because they are easy to miss:

- `members.user_id` null = a child with no login.
- An event with no `event_members` rows is for the whole family.
- `categories.family_id` null = the shared starter list, visible to every family and read-only to them.
- For repeating events, `starts_at` / `ends_at` are the first occurrence. `repeat` allows only `FREQ=DAILY|WEEKLY|MONTHLY` (RFC 5545 subset); widen the check when adding features like skip-weeks.
- `ends_at` is optional (e.g. "Bins out at 6am").
- `event_members` has no update grant: to change who's at an event, delete and re-insert.
- Families default to the `Europe/Dublin` timezone.

## Flutter app

- Talk to Supabase through a repository layer (e.g. `EventsRepository`) so the backend can change later.
- `lib/` layout (from Flutter's app architecture guide): `data/` by type (`repositories/`, later `models/`), `ui/` by feature (`auth/`, `calendar/`, ...) with shared UI in `ui/core/`. A feature's own widgets go in `ui/<feature>/widgets/`. Don't create folders until a file needs them.
- Import app files with `package:app/...`, not relative paths.
- `supabase_flutter` 2.18+ takes `publishableKey`; `anonKey` is deprecated.
- The Android emulator reaches the host's local Supabase at `http://10.0.2.2:54321`; iOS simulator, macOS and web use `http://127.0.0.1:54321`.
- The bundle ID is still the default `com.example.app`. Settle it before Google/Apple sign-in (issue #8), since it is hard to change afterwards.

## Where it's heading

v1: connect the app to Supabase (#1), calendar day and week views (#2), add/edit events (#3), expand repeating events into dates (#4), create a family and invite a partner (#5), live sync across devices (#6), push notifications (#7), Google/Apple sign-in (#8), a rules-based day-prep summary (#9), starter categories (#10).

Later: skip weeks of repeating events, roles on event members (e.g. who's driving), quick add (natural language, share sheet, photos), external calendars, weather in day prep, "leave by" reminders.
