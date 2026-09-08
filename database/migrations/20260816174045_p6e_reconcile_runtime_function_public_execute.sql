revoke execute on function public.runtime_record_journey_event(uuid, text, timestamptz, text, text, jsonb, text) from public;
revoke execute on function public.runtime_record_journey_event(uuid, text, timestamptz, text, text, jsonb, text) from anon;
grant execute on function public.runtime_record_journey_event(uuid, text, timestamptz, text, text, jsonb, text) to authenticated;

revoke execute on function public.runtime_record_memory(uuid, text, text, text, numeric, text, text, text) from public;
revoke execute on function public.runtime_record_memory(uuid, text, text, text, numeric, text, text, text) from anon;
grant execute on function public.runtime_record_memory(uuid, text, text, text, numeric, text, text, text) to authenticated;