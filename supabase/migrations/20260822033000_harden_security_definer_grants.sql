-- P1 security hardening: exposed SECURITY DEFINER functions must not be callable anonymously.
-- Runtime/domain RPCs remain available to authenticated callers only.
REVOKE EXECUTE ON FUNCTION public.list_experience_context(uuid, integer) FROM anon;
REVOKE EXECUTE ON FUNCTION public.list_experiences(uuid, integer) FROM anon;
REVOKE EXECUTE ON FUNCTION public.rls_auto_enable() FROM anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.runtime_classify_experience(uuid, text, text) FROM anon;
REVOKE EXECUTE ON FUNCTION public.runtime_create_inheritance_authorization(uuid, uuid, uuid, uuid, jsonb) FROM anon;
REVOKE EXECUTE ON FUNCTION public.runtime_execute_succession(uuid) FROM anon;
REVOKE EXECUTE ON FUNCTION public.runtime_get_journey_record_policy(uuid) FROM anon;
REVOKE EXECUTE ON FUNCTION public.runtime_journey_event_is_shared(uuid) FROM anon;
REVOKE EXECUTE ON FUNCTION public.runtime_preserve_selected_transfer_as_legacy(uuid, jsonb) FROM anon;
REVOKE EXECUTE ON FUNCTION public.runtime_record_inheritance(uuid, jsonb, jsonb) FROM anon;
