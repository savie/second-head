-- BL-P1-004 — Ownership & Privacy Boundary / Core RLS Identity
-- Scope: identity-table RLS, owner-isolated SELECT, DEFAULT DENY writes.
-- No identity-resolution, memory/context RLS, governance evaluator, clone,
-- ownership transfer, or recovery logic.

CREATE OR REPLACE FUNCTION public.current_account_id()
RETURNS uuid
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT account_id
    FROM public.account_auth_links
   WHERE provider = 'supabase'
     AND subject_ref = auth.uid()::text
   LIMIT 1;
$$;

REVOKE EXECUTE ON FUNCTION public.current_account_id() FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.current_account_id() FROM anon;
GRANT EXECUTE ON FUNCTION public.current_account_id() TO authenticated;

ALTER TABLE public.accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sh_instances ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sh_ownership ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.account_auth_links ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS account_auth_links_select_own ON public.account_auth_links;
CREATE POLICY account_auth_links_select_own
ON public.account_auth_links
FOR SELECT
USING (
  provider = 'supabase'
  AND subject_ref = auth.uid()::text
);

DROP POLICY IF EXISTS accounts_select_own ON public.accounts;
CREATE POLICY accounts_select_own
ON public.accounts
FOR SELECT
USING (account_id = public.current_account_id());

DROP POLICY IF EXISTS sh_instances_select_own ON public.sh_instances;
CREATE POLICY sh_instances_select_own
ON public.sh_instances
FOR SELECT
USING (account_id = public.current_account_id());

DROP POLICY IF EXISTS sh_ownership_select_own ON public.sh_ownership;
CREATE POLICY sh_ownership_select_own
ON public.sh_ownership
FOR SELECT
USING (account_id = public.current_account_id());

COMMENT ON FUNCTION public.current_account_id()
  IS 'BL-P1-004 read-only policy helper: auth subject -> SECOND HEAD ACCOUNT_ID. NULL means no linked account and therefore fail-closed.';
