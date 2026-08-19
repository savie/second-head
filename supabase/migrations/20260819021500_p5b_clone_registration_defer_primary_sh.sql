-- P5B Clone registration reconciliation
-- Owner-approved Model B:
--   email-only intended recipient -> registration -> Clone becomes PRIMARY SH.
--
-- The auth provisioning trigger must NOT materialize a normal PRIMARY SH for an
-- approved Clone recipient before the Clone materialization RPC runs, otherwise
-- runtime_create_clone() sees an existing SH and rejects the registration.
--
-- Therefore identity provisioning creates the Account + auth link first, and:
--   * normal registration -> creates PRIMARY SH immediately
--   * approved Clone recipient -> creates NO SH yet; AuthProvider then calls
--     runtime_materialize_registered_clone(), which performs the transactional
--     Clone SH + Memory + Knowledge transfer.

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
  v_has_clone boolean := false;
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

  SELECT account_id
    INTO v_account_id
    FROM public.accounts
   WHERE lower(email) = v_email;

  IF FOUND THEN
    RAISE EXCEPTION 'IDENTITY_ESCALATION: email already belongs to another Account';
  END IF;

  SELECT EXISTS (
    SELECT 1
      FROM public.clone_agreements
     WHERE lower(trim(target_email)) = v_email
       AND status = 'APPROVED'
       AND target_account_id IS NULL
  ) INTO v_has_clone;

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

  IF v_has_clone THEN
    -- Intentionally leave the new Account without an SH for this transaction.
    -- runtime_materialize_registered_clone() is the sole Clone materialization
    -- path and will create the Clone as the account's PRIMARY SH.
    RETURN v_account_id;
  END IF;

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

  RETURN v_account_id;
END;
$$;

REVOKE EXECUTE ON FUNCTION public.provision_identity_for_auth_subject(text, text) FROM PUBLIC;

COMMENT ON FUNCTION public.provision_identity_for_auth_subject(text, text)
  IS 'P1/P5B identity provisioning: auth subject -> Account. Normal registration creates PRIMARY SH; approved email-only Clone registration creates the Account first and defers SH creation to runtime_materialize_registered_clone(), which materializes the Clone as PRIMARY SH with transactional state transfer.';
