-- SECOND HEAD — Harden privacy / transfer RPC privileges.
revoke all on function public.runtime_record_experience(uuid,text,text,text,text,text,text,jsonb,timestamptz) from anon, public;
grant execute on function public.runtime_record_experience(uuid,text,text,text,text,text,text,jsonb,timestamptz) to authenticated;
revoke all on function public.runtime_set_record_policy(text,uuid,text,text,text) from anon, public;
grant execute on function public.runtime_set_record_policy(text,uuid,text,text,text) to authenticated;
revoke all on function public.runtime_validate_selected_transfer_scope(uuid,jsonb,text) from anon, public;
grant execute on function public.runtime_validate_selected_transfer_scope(uuid,jsonb,text) to authenticated;
