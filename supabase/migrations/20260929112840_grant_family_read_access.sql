-- Lock 1 (the front door): let logged-in users READ these tables.
-- Lock 2 (the RLS rules) still decides WHICH rows they see.
grant select on public.families to authenticated;
grant select on public.members  to authenticated;

-- Let logged-in users run the helper the rules depend on.
grant execute on function public.my_family_ids() to authenticated;