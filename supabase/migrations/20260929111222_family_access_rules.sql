-- Helper: "which family IDs is the logged-in person a member of?"
-- 'security definer' lets it read members without going through the lock,
-- which avoids the infinite loop. It only ever returns YOUR families.
create or replace function public.my_family_ids()
returns setof uuid
language sql
stable
security definer
set search_path = ''
as $$
  select family_id from public.members where user_id = auth.uid();
$$;

-- Rule 1: you can see a family if you're in it
create policy "View own families"
on public.families for select
to authenticated
using (id in (select public.my_family_ids()));

-- Rule 2: you can see members of families you're in (including children)
create policy "View members of own families"
on public.members for select
to authenticated
using (family_id in (select public.my_family_ids()));