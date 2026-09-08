-- BL-P1-006 audit hardening: internal SECURITY DEFINER identity provisioning functions are not client-facing RPCs.
REVOKE EXECUTE ON FUNCTION public.provision_identity_for_auth_subject(text, text) FROM PUBLIC, anon, authenticated, service_role;
REVOKE EXECUTE ON FUNCTION public.handle_new_auth_user() FROM PUBLIC, anon, authenticated, service_role;
REVOKE EXECUTE ON FUNCTION public.backfill_existing_auth_users() FROM PUBLIC, anon, authenticated, service_role;