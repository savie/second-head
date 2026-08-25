-- P5B hardening follow-up.
-- Enforce the Owner-resolved email-only target model at the RLS boundary.

DROP POLICY IF EXISTS clone_agreements_source_insert ON public.clone_agreements;

CREATE POLICY clone_agreements_source_insert
  ON public.clone_agreements FOR INSERT
  WITH CHECK (
    source_account_id = current_account_id()
    AND target_account_id IS NULL
    AND lower(target_email) <> lower(
      (SELECT email FROM public.accounts WHERE account_id = current_account_id())
    )
  );
