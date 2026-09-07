-- The Journey visibility helper is intentionally SECURITY DEFINER and is called by the
-- journey_events RLS policy as a visibility bridge for non-owner authenticated readers.
-- Keep authenticated EXECUTE because revoking it would break that RLS expression.
-- It remains unavailable to anon/public clients.
grant execute on function public.runtime_journey_event_is_shared(uuid) to authenticated;
revoke execute on function public.runtime_journey_event_is_shared(uuid) from anon;
revoke execute on function public.runtime_journey_event_is_shared(uuid) from public;