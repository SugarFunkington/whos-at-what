-- Data for the home page task rows (#30): where an event happens, and an
-- emoji for each category ("Hurling" -> 🏑, so every hurling event gets one).
-- Both optional. Empty = null, never '' or spaces, so the app has one case
-- to check. The existing table grants cover new columns, so no grant or
-- policy changes.

alter table public.events
  add column location text check (length(trim(location)) > 0);

alter table public.categories
  add column emoji text check (length(trim(emoji)) > 0);
