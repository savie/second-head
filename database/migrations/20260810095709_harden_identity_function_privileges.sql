-- BL-P1-006 audit hardening
-- Internal SECURITY DEFINER identity provisioning functions are not client-facing RPCs.
-- Restrict EXECUTE to the owning postgres role; trigger execution remains valid because
-- the trigger function runs as SECURITY DEFINER and invokes the provisioning helper.

REVOKE EXECUTE ON FUNCTION public.provision_identity_for_auth_subject(text, text) FROM PUBLIC, anon, authenticated, service_role;
REVOKE EXECUTE ON FUNCTION public.handle_new_auth_user() FROM PUBLIC, anon, authenticated, service_role;
REVOKE EXECUTE ON FUNCTION public.backfill_existing_auth_users() FROM PUBLIC, anon, authenticated, service_role;
