-- SECOND HEAD — Knowledge lifecycle authority exposure hardening
-- Supabase DEV migration applied as 20260913092503.

revoke all on function public.runtime_create_knowledge_lifecycle_confirmation(uuid,text,text,text,jsonb) from public,anon;
revoke all on function public.runtime_confirm_knowledge_lifecycle(uuid) from public,anon;
revoke all on function public.runtime_accept_knowledge(uuid,text,text,text,text,jsonb) from public,anon;
revoke all on function public.runtime_index_knowledge(uuid,text,text,text,jsonb) from public,anon;
revoke all on function public.runtime_activate_knowledge(uuid,text,text,text,text,jsonb) from public,anon;
revoke all on function public.runtime_update_knowledge(uuid,text,text,text,jsonb,text,jsonb) from public,anon;
revoke all on function public.runtime_deprecate_knowledge(uuid,text,text,text,text,jsonb) from public,anon;
revoke all on function public.runtime_archive_knowledge(uuid,text,text,text,text,jsonb) from public,anon;

grant execute on function public.runtime_create_knowledge_lifecycle_confirmation(uuid,text,text,text,jsonb) to authenticated;
grant execute on function public.runtime_confirm_knowledge_lifecycle(uuid) to authenticated;
grant execute on function public.runtime_accept_knowledge(uuid,text,text,text,text,jsonb) to authenticated;
grant execute on function public.runtime_index_knowledge(uuid,text,text,text,jsonb) to authenticated;
grant execute on function public.runtime_activate_knowledge(uuid,text,text,text,text,jsonb) to authenticated;
grant execute on function public.runtime_update_knowledge(uuid,text,text,text,jsonb,text,jsonb) to authenticated;
grant execute on function public.runtime_deprecate_knowledge(uuid,text,text,text,text,jsonb) to authenticated;
grant execute on function public.runtime_archive_knowledge(uuid,text,text,text,text,jsonb) to authenticated;
