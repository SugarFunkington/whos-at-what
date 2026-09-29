-- Some events have no end time, e.g. "bins out at 6am".
-- Empty ends_at = no end time.
alter table public.events alter column ends_at drop not null;

-- The existing check (ends_at >= starts_at) needs no change: a check on an
-- empty value passes, so it only applies when there IS an end time.
