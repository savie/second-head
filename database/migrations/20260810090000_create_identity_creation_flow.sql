-- BL-P1-003 — Identity Creation & Auth Linkage
-- Source of truth: Git repository migration artifact.
-- Scope: auth.users -> ACCOUNT_ID linkage, PRIMARY SH creation, ownership creation,
--        and gated backfill support. No RLS, authorization, identity-resolution,
--        recovery, clone, or ownership-transfer logic.
--
-- Audit note:
-- BL-P1-002 already created the UNIQUE (provider, subject_ref) constraint on
-- public.account_auth_links. BL-P1-003 therefore MUST NOT recreate it.

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
BEGIN
  -- Idempotency anchor: the platform subject must resolve to the same Account.
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

  -- Email is an identity conflict boundary. Do not merge or auto-resolve.
  SELECT account_id
    INTO v_account_id
    FROM public.accounts
   WHERE lower(email) = v_email;

  IF FOUND THEN
    RAISE EXCEPTION 'IDENTITY_ESCALATION: email already belongs to another Account';
  END IF;

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

CREATE OR REPLACE FUNCTION public.handle_new_auth_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  PERFORM public.provision_identity_for_auth_subject(
    NEW.id::text,
    NEW.email
  );

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

CREATE TRIGGER on_auth_user_created
AFTER INSERT ON auth.users
FOR EACH ROW
EXECUTE FUNCTION public.handle_new_auth_user();

CREATE OR REPLACE FUNCTION public.backfill_existing_auth_users()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_user record;
BEGIN
  FOR v_user IN
    SELECT id, email
      FROM auth.users
     ORDER BY created_at, id
  LOOP
    PERFORM public.provision_identity_for_auth_subject(
      v_user.id::text,
      v_user.email
    );
  END LOOP;
END;
$$;

-- These are operational functions, not client-facing RPC endpoints.
REVOKE EXECUTE ON FUNCTION public.provision_identity_for_auth_subject(text, text) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.handle_new_auth_user() FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.backfill_existing_auth_users() FROM PUBLIC;

COMMENT ON FUNCTION public.provision_identity_for_auth_subject(text, text)
  IS 'BL-P1-003 internal identity provisioning: auth subject -> Account -> PRIMARY SH -> OWNER. Conflicts escalate; no auto-merge.';

COMMENT ON FUNCTION public.handle_new_auth_user()
  IS 'BL-P1-003 AFTER INSERT trigger handler for auth.users. Platform auth subject is not ACCOUNT_ID or SH_ID.';

COMMENT ON FUNCTION public.backfill_existing_auth_users()
  IS 'BL-P1-003 gated backfill helper for pre-existing auth.users. Not executed by this migration.';
