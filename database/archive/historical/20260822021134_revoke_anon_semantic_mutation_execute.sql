revoke execute on function public.runtime_replace_memory(uuid,text,text,text,text,text) from public, anon;
revoke execute on function public.runtime_record_memory_with_journey(uuid,text,text,text,numeric,text,text,text) from public, anon;
revoke execute on function public.runtime_record_knowledge_with_journey(uuid,text,text,text,jsonb,text,text,numeric) from public, anon;
revoke execute on function public.runtime_delete_journey_event(uuid) from public, anon;
grant execute on function public.runtime_replace_memory(uuid,text,text,text,text,text) to authenticated;
grant execute on function public.runtime_record_memory_with_journey(uuid,text,text,text,numeric,text,text,text) to authenticated;
grant execute on function public.runtime_record_knowledge_with_journey(uuid,text,text,text,jsonb,text,text,numeric) to authenticated;
grant execute on function public.runtime_delete_journey_event(uuid) to authenticated;
