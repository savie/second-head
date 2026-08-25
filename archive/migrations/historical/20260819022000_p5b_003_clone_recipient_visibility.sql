-- Recipient visibility follows the owner-approved email-only invitation model.
-- A recipient may see an invitation before target_account_id is linked,
-- provided the authenticated account email matches the intended recipient email.

DROP POLICY IF EXISTS clone_agreements_participant_select ON public.clone_agreements;

CREATE POLICY clone_agreements_participant_select
  ON public.clone_agreements FOR SELECT
  USING (
    source_account_id = public.current_account_id()
    OR target_account_id = public.current_account_id()
    OR lower(trim(target_email)) = lower(trim((
      SELECT a.email
      FROM public.accounts a
      WHERE a.account_id = public.current_account_id()
    )))
  );

CREATE INDEX IF NOT EXISTS clone_agreements_target_email_idx
  ON public.clone_agreements (lower(target_email), status, created_at DESC);
