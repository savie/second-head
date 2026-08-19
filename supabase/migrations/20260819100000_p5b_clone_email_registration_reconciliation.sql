-- P5B Clone Execution Reconciliation v1.0
-- Owner decision:
--   target begins as an email-only intended recipient;
--   target may not have an Account/SH when the agreement is created;
--   recipient registration claims the approved Clone intent;
--   the resulting Clone SH is the target Account's PRIMARY SH.
-- Canonical documents are not mutated by this migration.

-- 1. Reconcile Clone agreement target representation.
ALTER TABLE public.clone_agreements
  ADD COLUMN IF NOT EXISTS target_email text;

UPDATE public.clone_agreements ca
SET target_email = lower(trim(a.email))
FROM public.accounts a
WHERE a.account_id = ca.target_account_id
  AND (ca.target_email IS NULL OR ca.target_email = '');

ALTER TABLE public.clone_agreements
  ALTER COLUMN target_email SET NOT NULL;

ALTER TABLE public.clone_agreements
  ALTER COLUMN target_account_id DROP NOT NULL;

ALTER TABLE public.clone_agreements
  DROP CONSTRAINT IF EXISTS clone_agreements_target_account_id_fkey;

ALTER TABLE public.clone_agreements
  ADD CONSTRAINT clone_agreements_target_account_id_fkey
  FOREIGN KEY (target_account_id)
  REFERENCES public.accounts(account_id)
  ON DELETE RESTRICT;

ALTER TABLE public.clone_agreements
  DROP CONSTRAINT IF EXISTS clone_agreements_target_identity_ck;

ALTER TABLE public.clone_agreements
  ADD CONSTRAINT clone_agreements_target_identity_ck
  CHECK (target_email = lower(trim(target_email)) AND length(trim(target_email)) > 0);

CREATE INDEX IF NOT EXISTS clone_agreements_target_email_idx
  ON public.clone_agreements(lower(target_email), status, created_at desc);

CREATE UNIQUE INDEX IF NOT EXISTS clone_agreements_pending_email_uq
  ON public.clone_agreements(lower(target_email))
  WHERE status IN ('PENDING','APPROVED') AND target_account_id IS NULL;

-- 2. The source creates the Clone intent. The recipient does not need an Account yet.
DROP POLICY IF EXISTS clone_agreements_target_insert ON public.clone_agreements;
DROP POLICY IF EXISTS clone_agreements_source_insert ON public.clone_agreements;

CREATE POLICY clone_agreements_source_insert
  ON public.clone_agreements FOR INSERT
  WITH CHECK (
    source_account_id = current_account_id()
    AND source_account_id <> coalesce(target_account_id, source_account_id)
  );

-- 3. Keep participant visibility after registration; an unregistered recipient has
-- no Account and therefore no authenticated row-level visibility yet.
DROP POLICY IF EXISTS clone_agreements_source_select ON public.clone_agreements;
CREATE POLICY clone_agreements_participant_select
  ON public.clone_agreements FOR SELECT
  USING (
    source_account_id = current_account_id()
    OR target_account_id = current_account_id()
  );

-- 4. Recipient registration claims an approved Clone invitation by email.
--    This function is internal identity provisioning, not a client-facing RPC.
CREATE OR REPLACE FUNCTION public.provision_identity_for_auth_subject(
  p_subject_ref text,
  p_email text
)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_account_id uuid;
  v_sh_id uuid;
  v_email text;
  v_clone_agreement clone_agreements%rowtype;
BEGIN
  SELECT account_id
    INTO v_account_id
    FROM public.account_auth_links
   WHERE provider = 'supabase'
     AND subject_ref = p_subject_ref;

  IF FOUND THEN
    RETURN v_account_id;
  END IF;

  v_email := lower(trim(p_email));

  IF v_email IS NULL OR v_email = '' THEN
    RAISE EXCEPTION 'IDENTITY_ESCALATION: auth subject has no usable email';
  END IF;

  -- An already-existing Account remains an identity conflict. Clone registration
  -- is intended for a new recipient identity, not for attaching a Clone to an
  -- unrelated pre-existing Account.
  SELECT account_id
    INTO v_account_id
    FROM public.accounts
   WHERE lower(email) = v_email;

  IF FOUND THEN
    RAISE EXCEPTION 'IDENTITY_ESCALATION: email already belongs to another Account';
  END IF;

  -- Lock the approved email-only Clone intent before creating the Account so that
  -- the target Account and its PRIMARY SH are materialized atomically with the
  -- registration lifecycle.
  SELECT *
    INTO v_clone_agreement
    FROM public.clone_agreements
   WHERE lower(target_email) = v_email
     AND status = 'APPROVED'
     AND target_account_id IS NULL
   ORDER BY approved_at NULLS LAST, created_at, agreement_id
   LIMIT 1
   FOR UPDATE;

  INSERT INTO public.accounts (email, status)
  VALUES (v_email, 'created')
  RETURNING account_id INTO v_account_id;

  BEGIN
    INSERT INTO public.account_auth_links (account_id, provider, subject_ref)
    VALUES (v_account_id, 'supabase', p_subject_ref);
  EXCEPTION
    WHEN unique_violation THEN
      RAISE EXCEPTION 'IDENTITY_ESCALATION: auth subject link conflict';
  END;

  IF FOUND THEN
    -- The SELECT above populated v_clone_agreement. FOUND is evaluated from the
    -- immediately preceding INSERT, so use the agreement identifier explicitly.
    INSERT INTO public.sh_instances (
      account_id,
      sh_type,
      is_primary,
      status,
      metadata,
      version
    )
    VALUES (
      v_account_id,
      'CLONE',
      true,
      'created',
      jsonb_build_object(
        'source_sh_id', v_clone_agreement.source_sh_id,
        'agreement_id', v_clone_agreement.agreement_id
      ),
      1
    )
    RETURNING sh_id INTO v_sh_id;

    INSERT INTO public.sh_ownership (
      account_id,
      sh_id,
      role,
      granted_at,
      evidence_ref
    )
    VALUES (
      v_account_id,
      v_sh_id,
      'OWNER',
      now(),
      v_clone_agreement.agreement_id::text
    );

    INSERT INTO public.sh_clones (
      clone_sh_id,
      source_sh_id,
      agreement_id
    )
    VALUES (
      v_sh_id,
      v_clone_agreement.source_sh_id,
      v_clone_agreement.agreement_id
    );

    UPDATE public.clone_agreements
       SET target_account_id = v_account_id
     WHERE agreement_id = v_clone_agreement.agreement_id;
  ELSE
    INSERT INTO public.sh_instances (
      account_id,
      sh_type,
      is_primary,
      status,
      metadata,
      version
    )
    VALUES (
      v_account_id,
      'PRIMARY',
      true,
      'created',
      '{}'::jsonb,
      1
    )
    RETURNING sh_id INTO v_sh_id;

    INSERT INTO public.sh_ownership (
      account_id,
      sh_id,
      role,
      granted_at,
      evidence_ref
    )
    VALUES (
      v_account_id,
      v_sh_id,
      'OWNER',
      now(),
      NULL
    );
  END IF;

  RETURN v_account_id;
END;
$$;

REVOKE EXECUTE ON FUNCTION public.provision_identity_for_auth_subject(text, text) FROM PUBLIC;

COMMENT ON FUNCTION public.provision_identity_for_auth_subject(text, text)
  IS 'P1/P5B identity provisioning: auth subject -> Account -> PRIMARY SH. An approved email-only Clone intent materializes a CLONE PRIMARY SH; otherwise a normal PRIMARY SH is created. Existing email conflicts escalate.';

-- 5. The old direct execution RPC is no longer the public materialization path.
--    Keep the function name for compatibility, but fail closed rather than
--    silently creating the obsolete non-primary Clone model.
CREATE OR REPLACE FUNCTION public.runtime_create_clone(
  p_agreement_id uuid,
  p_clone_name text default null
)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RAISE EXCEPTION 'CLONE_REJECTED: Clone materializes when the approved recipient registers with the intended email';
END;
$$;

GRANT EXECUTE ON FUNCTION public.runtime_create_clone(uuid, text) TO authenticated;
