-- P5B security hardening
-- Clone materialization is a registration/bootstrap path, not a public direct
-- client execution path.
--
-- runtime_materialize_registered_clone() performs its own authenticated-user
-- check, so anon EXECUTE is unnecessary and must be revoked.
-- runtime_create_clone() is the internal transactional worker invoked by the
-- materialization function; authenticated clients must not call it directly.

REVOKE EXECUTE ON FUNCTION public.runtime_materialize_registered_clone() FROM anon;
GRANT EXECUTE ON FUNCTION public.runtime_materialize_registered_clone() TO authenticated;

REVOKE EXECUTE ON FUNCTION public.runtime_create_clone(uuid, text) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.runtime_create_clone(uuid, text) FROM anon;
REVOKE EXECUTE ON FUNCTION public.runtime_create_clone(uuid, text) FROM authenticated;
