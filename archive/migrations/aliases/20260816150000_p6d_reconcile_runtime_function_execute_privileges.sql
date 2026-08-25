revoke execute on function public.runtime_confirm_high_risk_action(uuid) from anon, public;
revoke execute on function public.runtime_create_clone(uuid, text) from anon, public;
revoke execute on function public.runtime_create_high_risk_confirmation(text, text, uuid, text, text) from anon, public;
revoke execute on function public.runtime_create_portability_export(uuid) from anon, public;
revoke execute on function public.runtime_create_recovery_snapshot(uuid) from anon, public;
revoke execute on function public.runtime_execute_high_risk_action(uuid) from anon, public;
revoke execute on function public.runtime_record_inheritance(uuid, jsonb, jsonb) from anon, public;
revoke execute on function public.runtime_record_legacy(uuid, text, jsonb, jsonb, timestamptz) from anon, public;
revoke execute on function public.runtime_restore_recovery_snapshot(uuid) from anon, public;

grant execute on function public.runtime_confirm_high_risk_action(uuid) to authenticated;
grant execute on function public.runtime_create_clone(uuid, text) to authenticated;
grant execute on function public.runtime_create_high_risk_confirmation(text, text, uuid, text, text) to authenticated;
grant execute on function public.runtime_create_portability_export(uuid) to authenticated;
grant execute on function public.runtime_create_recovery_snapshot(uuid) to authenticated;
grant execute on function public.runtime_execute_high_risk_action(uuid) to authenticated;
grant execute on function public.runtime_record_inheritance(uuid, jsonb, jsonb) to authenticated;
grant execute on function public.runtime_record_legacy(uuid, text, jsonb, jsonb, timestamptz) to authenticated;
grant execute on function public.runtime_restore_recovery_snapshot(uuid) to authenticated;
