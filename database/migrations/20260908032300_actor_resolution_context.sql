-- 5E-C — Explicit resolved actor context
-- Scope: resolve confirmed actor-context gaps only.
-- Does not define SYSTEM_RUNTIME technical mechanism.

CREATE OR REPLACE FUNCTION public.resolve_actor_context()
RETURNS TABLE (
  account_id uuid,
  sh_id uuid,
  ownership_role text,
  actor text,
  authority text,
  sh_designation text
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_account_id uuid;
  v_sh_id uuid;
  v_ownership_role text;
  v_is_creator boolean := false;
BEGIN
  IF auth.uid() IS NULL THEN
    RETURN;
  END IF;

  SELECT aal.account_id
    INTO v_account_id
    FROM public.account_auth_links aal
   WHERE aal.provider = 'supabase'
     AND aal.subject_ref = auth.uid()::text
   LIMIT 1;

  IF v_account_id IS NULL THEN
    RETURN;
  END IF;

  SELECT s.sh_id, o.role
    INTO v_sh_id, v_ownership_role
    FROM public.sh_instances s
    JOIN public.sh_ownership o
      ON o.sh_id = s.sh_id
     AND o.account_id = s.account_id
   WHERE s.account_id = v_account_id
     AND s.is_primary = true
   LIMIT 1;

  IF v_sh_id IS NULL THEN
    RETURN;
  END IF;

  SELECT EXISTS (
    SELECT 1
      FROM private.authority_assignments aa
     WHERE aa.account_id = v_account_id
       AND aa.authority = 'CREATOR'
       AND aa.active = true
  )
    INTO v_is_creator;

  RETURN QUERY
  SELECT
    v_account_id,
    v_sh_id,
    v_ownership_role,
    CASE WHEN v_is_creator THEN 'CREATOR' ELSE 'ACCOUNT_OWNER' END,
    CASE WHEN v_is_creator THEN 'CREATOR' ELSE NULL END,
    CASE WHEN v_is_creator THEN 'SH-000' ELSE 'ORDINARY_SH' END;
END;
$$;

REVOKE EXECUTE ON FUNCTION public.resolve_actor_context() FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.resolve_actor_context() FROM anon;
GRANT EXECUTE ON FUNCTION public.resolve_actor_context() TO authenticated;
GRANT EXECUTE ON FUNCTION public.resolve_actor_context() TO service_role;

COMMENT ON FUNCTION public.resolve_actor_context()
  IS '5E-C resolved actor context: trusted auth subject -> ACCOUNT_ID -> PRIMARY SH_ID + ownership -> Creator authority -> actor and SH designation. SYSTEM_RUNTIME is intentionally outside this function pending its technical design decision.';
