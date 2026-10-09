# WhosAtWhat

A family calendar showing what everyone is up to today, with a "how to prep for the day" section at the top.

- `supabase/` - backend: database migrations, local test data (`seed.sql`), tests
- `app/` - Flutter app: email/password login and a list of today's events

Project context and working rules for AI agents are in `AGENTS.md`.

## Local development

Needs Docker running and the [Supabase CLI](https://supabase.com/docs/guides/local-development/cli/getting-started).

```bash
supabase start      # start the local database (first run downloads several GB)
supabase db reset   # rebuild it from the migrations + load seed.sql test data
supabase stop       # stop it when you're done
```

Local dashboard: http://127.0.0.1:54323

Test logins (local only, password `1`):
- `1` - Sarah, Test Family (with Dave and children Ella, Jack and Molly)
- `2` - Dave, Test Family
- `3` - Other Family

## Running the app

With local Supabase running:

```bash
cd app
cp env/example.json env/local.json   # first time only: paste the Publishable key from `supabase status`
flutter run --dart-define-from-file=env/local.json
flutter analyze                      # static checks
flutter test                         # tests
```

`env/local.json` is gitignored; never put the secret / service_role key in it. On the Android emulator, set `SUPABASE_URL` to `http://10.0.2.2:54321`.

## Changing the database

1. `supabase migration new <name>` and write the change
2. `supabase db reset`, then run the permission checks (below)
3. Commit
4. `supabase db push` to the real database, then `supabase db diff --linked` should be empty

Never edit a migration that's already been pushed - write a new one.
Every new table needs: create table -> enable RLS -> grant -> policies.

## Permission checks

Checks that each family can only see and change its own data:

```bash
python3 supabase/tests/rls_check.py
```

Runs against the local database only, and tidies up after itself.
