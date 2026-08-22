-- SECOND HEAD — P1 security hardening
-- runtime_validate_selected_transfer_scope is an internal validator used by
-- transfer/clone/legacy RPCs. It accepts a source SH and selected record IDs,
-- so exposing it directly to authenticated callers creates an unnecessary
-- cross-account policy/ownership oracle. Trusted SECURITY DEFINER callers
-- remain able to invoke it; direct client execution is removed.

revoke all on function public.runtime_validate_selected_transfer_scope(uuid,jsonb,text) from public;
revoke all on function public.runtime_validate_selected_transfer_scope(uuid,jsonb,text) from anon;
revoke all on function public.runtime_validate_selected_transfer_scope(uuid,jsonb,text) from authenticated;
