# WhosAtWhat

A family calendar app: what everyone in the family is doing today, with a "how to prep for the day" panel at the top. Parents log in; children are family members without a login.

- `supabase/` - backend: migrations, `seed.sql` test data, RLS permission checks
- `app/` - Flutter app: email/password login and a list of today's events

Commands, test logins and the database-change workflow live in `README.md`.

## How we work

The user is learning Flutter through this project. Work in small, agreed steps:

- Each piece of work starts from a GitHub issue (`gh issue list`). Labels `v1` / `later` set scope.
- Do the one step asked for, explain the Flutter concepts it uses, then stop and let the user pick the next step.
- When a ticket has several tasks, treat each task as its own step.
- Tickets are often agent-drafted, so they can be wrong. Check each task against the code and the target architecture before doing it. If a task is inaccurate or would add a code smell, raise it with the user and agree the fix first.

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

Run commands from `app/`: `flutter analyze`, `flutter test`, `flutter run --dart-define-from-file=env/local.json`.

### Current state

```
lib/
  main.dart                            Supabase.initialize, MultiProvider, MainApp picks the first page
  config/dependencies.dart             providers: which implementations the app uses
  data/repositories/
    auth/auth_repository.dart          abstract AuthRepository (ChangeNotifier), AuthFailure
    auth/auth_repository_supabase.dart AuthRepositorySupabase
    events/events_repository.dart      abstract EventsRepository
    events/events_repository_supabase.dart  EventsRepositorySupabase
  domain/models/event.dart             Event (immutable)
  ui/
    core/spacing.dart                  shared spacing constants
    auth/login_page.dart               LoginPage
    calendar/home_page.dart            HomePage: today's events
  utils/result.dart                    Result<T>: Ok / Error
testing/fakes/repositories/            FakeAuthRepository, FakeEventsRepository
test/ui/auth/login_page_test.dart      login navigates to home / stays on login
```

- Only `lib/config/`, `lib/data/` and `main.dart` (for `Supabase.initialize`) import `supabase_flutter`. `config/dependencies.dart` is the only place that picks implementations: `SupabaseClient` as a `Provider`, `AuthRepository` as a `ChangeNotifierProvider`, other repositories as `Provider`, each cast to its interface (`as AuthRepository`). Order matters: a provider can only `context.read()` providers earlier in the list.
- Pages read repositories with `context.read<T>()` (in callbacks and `initState`), never through constructors. Only services and repositories are provided; view models are not (they are created where a screen is built, #24).
- `MainApp` reads `isAuthenticated` once at startup, so it does not react to login/logout; the go_router redirect in #23 takes that over.
- Repositories return `Result<T>` instead of throwing, and catch `on Exception` only, so Dart `Error`s (bugs) still surface. Failures Supabase reports become app types (`AuthFailure`), so the UI never sees a Supabase type. Pages `switch` on the `Result`.
- Screen logic (calling repositories, loading state) still lives in each page's `State` class.
- Tests use the fakes, never Supabase. Each fake takes its canned answer in the constructor: `FakeAuthRepository()` logs in, `FakeAuthRepository(loginResult: const Result.error(AuthFailure('...')))` fails; `FakeEventsRepository()` returns no events, or pass `result:`. Widget tests wrap the screen in `MultiProvider` with fakes via `.value`, typed by interface: `ChangeNotifierProvider<AuthRepository>.value(value: FakeAuthRepository())`. Each test covers its own screen's behaviour only (e.g. the login test checks navigation, not what `HomePage` shows).
- Import app files with `package:app/...`, not relative paths. The exception is tests importing from top-level `testing/` (e.g. fakes): `package:app/` only covers `lib/`, so use a relative path like `'../testing/fakes/repositories/fake_auth_repository.dart'`, as compass_app does.
- `supabase_flutter` 2.18+ takes `publishableKey`; `anonKey` is deprecated.
- The Android emulator reaches the host's local Supabase at `http://10.0.2.2:54321`; iOS simulator, macOS and web use `http://127.0.0.1:54321`.
- The bundle ID is still the default `com.example.app`. Settle it before Google/Apple sign-in (issue #8), since it is hard to change afterwards.

### Target architecture

We follow Flutter's app architecture guide (https://docs.flutter.dev/app-architecture). When a pattern question comes up, copy its reference app, [`compass_app`](https://github.com/flutter/samples/tree/main/compass_app/app), rather than bringing in other approaches (e.g. Riverpod, feature-first folders). The one exception: we keep `package:app/...` imports.

Layers: views (widgets, no logic) -> view models (`ChangeNotifier`, one per screen) -> repositories (abstract, the source of truth per data type, return `Result`) -> services (the `SupabaseClient` for now). Repositories never call each other.

Target layout (create folders only when a file needs them):

```
lib/
  config/dependencies.dart       provider setup: which implementations the app uses
  data/repositories/<type>/      <type>_repository.dart (abstract) + <type>_repository_supabase.dart
  domain/models/                 app data types, immutable
  routing/                       router.dart (go_router + auth redirect), routes.dart
  ui/core/                       shared widgets and themes
  ui/<feature>/view_models/      <name>_viewmodel.dart
  ui/<feature>/widgets/          <name>_screen.dart + the feature's own widgets
  utils/                         result.dart, command.dart
testing/fakes/repositories/      fakes used by tests (top level, not in test/)
test/                            mirrors lib/
```

Getting there, in order: #26 repository interfaces + `Result` + fakes -> #25 `provider` -> #24 view models + commands -> #23 go_router. Each ticket ends by updating "Current state" above to match what it added.

## Where it's heading

v1: first the architecture tickets above (#26, #25, #24, #23); then calendar day and week views (#2), add/edit events (#3), expand repeating events into dates (#4), create a family and invite a partner (#5), live sync across devices (#6), push notifications (#7), Google/Apple sign-in (#8), a rules-based day-prep summary (#9), starter categories (#10).

Later: skip weeks of repeating events, roles on event members (e.g. who's driving), quick add (natural language, share sheet, photos), external calendars, weather in day prep, "leave by" reminders.
