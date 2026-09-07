grant execute on function public.runtime_journey_event_is_shared(uuid) to authenticated;
revoke execute on function public.runtime_journey_event_is_shared(uuid) from anon;
revoke execute on function public.runtime_journey_event_is_shared(uuid) from public;