DROP POLICY IF EXISTS inheritance_auth_participant_select ON public.inheritance_authorizations;
CREATE POLICY inheritance_auth_participant_select
  ON public.inheritance_authorizations
  FOR SELECT
  USING (
    source_account_id = public.current_account_id()
    OR (target_account_id = public.current_account_id() AND status <> 'REVOKED')
  );

DROP POLICY IF EXISTS succession_rules_participant_select ON public.succession_rules;
CREATE POLICY succession_rules_participant_select
  ON public.succession_rules
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.sh_instances s
      WHERE s.sh_id = succession_rules.source_sh_id
        AND s.account_id = public.current_account_id()
    )
    OR (successor_account_id = public.current_account_id() AND status <> 'REVOKED')
  );
