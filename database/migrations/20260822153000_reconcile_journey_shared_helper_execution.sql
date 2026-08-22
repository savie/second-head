-- Final canonical reconciliation for runtime_journey_event_is_shared.
-- The helper is a SECURITY DEFINER dependency of the authenticated journey_events
-- visibility RLS policy, so authenticated EXECUTE is intentional and must remain.
-- anon/public must not receive direct execution.
revoke all on function public.runtime_journey_event_is_shared(uuid) from public;
revoke execute on function public.runtime_journey_event_is_shared(uuid) from anon;
grant execute on function public.runtime_journey_event_is_shared(uuid) to authenticated;

-- runtime_assert_active_sh is an internal lifecycle helper and is not a client RPC.
revoke execute on function public.runtime_assert_active_sh(uuid,text) from authenticated;
revoke execute on function public.runtime_assert_active_sh(uuid,text) from anon;
revoke execute on function public.runtime_assert_active_sh(uuid,text) from public;
