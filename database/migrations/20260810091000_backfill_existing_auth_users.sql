-- BL-P1-003 — GATED BACKFILL EXECUTION
-- This migration is intentionally separate from the identity-creation-flow migration.
-- It is applied only after actual preflight confirmed that the existing auth.users
-- state is safe: 2 users, valid emails, and zero existing SECOND HEAD identity rows.
-- Conflicts abort the migration; no auto-merge or auto-resolution is performed.

DO $$
DECLARE
  v_user record;
  v_account_id uuid;
  v_sh_id uuid;
  v_email text;
BEGIN
  FOR v_user IN
    SELECT id, email
      FROM auth.users
     ORDER BY created_at, id
  LOOP
    IF EXISTS (
      SELECT 1
        FROM public.account_auth_links
       WHERE provider = 'supabase'
         AND subject_ref = v_user.id::text
    ) THEN
      CONTINUE;
    END IF;

    v_email := lower(trim(v_user.email));

    IF v_email IS NULL OR v_email = '' THEN
      RAISE EXCEPTION 'IDENTITY_ESCALATION: existing auth subject has no usable email';
    END IF;

    IF EXISTS (
      SELECT 1
        FROM public.accounts
       WHERE lower(email) = v_email
    ) THEN
      RAISE EXCEPTION 'IDENTITY_ESCALATION: existing auth email already belongs to an Account';
    END IF;

    INSERT INTO public.accounts (email, status)
    VALUES (v_email, 'created')
    RETURNING account_id INTO v_account_id;

    INSERT INTO public.account_auth_links (account_id, provider, subject_ref)
    VALUES (v_account_id, 'supabase', v_user.id::text);

    INSERT INTO public.sh_instances (
      account_id, sh_type, is_primary, status, metadata, version
    )
    VALUES (
      v_account_id, 'PRIMARY', true, 'created', '{}'::jsonb, 1
    )
    RETURNING sh_id INTO v_sh_id;

    INSERT INTO public.sh_ownership (
      account_id, sh_id, role, granted_at, evidence_ref
    )
    VALUES (
      v_account_id, v_sh_id, 'OWNER', now(), NULL
    );
  END LOOP;
END;
$$;
