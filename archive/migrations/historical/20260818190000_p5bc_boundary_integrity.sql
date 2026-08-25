-- P5B/P5C boundary integrity: keep agreement/authorization identity fields
-- consistent with the SH/account relationships already enforced by runtime guards.

DROP POLICY IF EXISTS clone_agreements_target_insert ON public.clone_agreements;
CREATE POLICY clone_agreements_target_insert
  ON public.clone_agreements FOR INSERT
  WITH CHECK (
    target_account_id = current_account_id()
    AND source_account_id <> current_account_id()
    AND EXISTS (
      SELECT 1
      FROM public.sh_instances s
      WHERE s.sh_id = clone_agreements.source_sh_id
        AND s.account_id = clone_agreements.source_account_id
    )
  );

DROP POLICY IF EXISTS inheritance_auth_target_insert ON public.inheritance_authorizations;
CREATE POLICY inheritance_auth_target_insert
  ON public.inheritance_authorizations FOR INSERT
  WITH CHECK (
    target_account_id = current_account_id()
    AND source_account_id <> current_account_id()
    AND EXISTS (
      SELECT 1
      FROM public.sh_instances s
      WHERE s.sh_id = inheritance_authorizations.source_sh_id
        AND s.account_id = inheritance_authorizations.source_account_id
    )
    AND EXISTS (
      SELECT 1
      FROM public.sh_instances t
      WHERE t.sh_id = inheritance_authorizations.target_sh_id
        AND t.account_id = inheritance_authorizations.target_account_id
    )
  );
