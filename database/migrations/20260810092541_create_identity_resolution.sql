-- BL-P1-005 — Identity Resolution & Verification Foundation
-- Scope: current-principal identity resolution only.
-- No authorization engine, governance evaluator, memory/context RLS,
-- ownership transfer, clone, recovery, or runtime identity service.

CREATE OR REPLACE FUNCTION public.resolve_identity()
RETURNS TABLE (
  account_id uuid,
  sh_id uuid,
  ownership_role text
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_match_count integer;
BEGIN
  SELECT count(*)
    INTO v_match_count
    FROM public.account_auth_links aal
    JOIN public.accounts a
      ON a.account_id = aal.account_id
    JOIN public.sh_instances s
      ON s.account_id = a.account_id
     AND s.is_primary = true
    JOIN public.sh_ownership o
      ON o.sh_id = s.sh_id
     AND o.account_id = a.account_id
   WHERE aal.provider = 'supabase'
     AND aal.subject_ref = auth.uid()::text;

  IF v_match_count > 1 THEN
    RAISE EXCEPTION
      'IDENTITY_CONFLICT: ambiguous identity resolution; escalate';
  END IF;

  RETURN QUERY
  SELECT a.account_id,
         s.sh_id,
         o.role
    FROM public.account_auth_links aal
    JOIN public.accounts a
      ON a.account_id = aal.account_id
    JOIN public.sh_instances s
      ON s.account_id = a.account_id
     AND s.is_primary = true
    JOIN public.sh_ownership o
      ON o.sh_id = s.sh_id
     AND o.account_id = a.account_id
   WHERE aal.provider = 'supabase'
     AND aal.subject_ref = auth.uid()::text;
END;
$$;

-- Resolution is an authenticated current-principal operation, not a public RPC.
REVOKE EXECUTE ON FUNCTION public.resolve_identity() FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.resolve_identity() FROM anon;
GRANT EXECUTE ON FUNCTION public.resolve_identity() TO authenticated;

COMMENT ON FUNCTION public.resolve_identity()
  IS 'BL-P1-005 current-principal identity resolution: auth subject -> ACCOUNT_ID -> PRIMARY SH_ID -> ownership. Fail-closed; conflicts escalate; no identity creation.';
