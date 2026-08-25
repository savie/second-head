-- SECOND HEAD P5B — transactional Clone materialization and state transfer
-- Owner-approved semantics:
--   * target is an email-only intended recipient until registration
--   * recipient registration materializes the Clone as the target account's PRIMARY SH
--   * Memory and Knowledge transfer as new B-owned rows
--   * Memory/Knowledge Candidates are promoted into their real domain on transfer
--   * Conversation and source Journey are never transferred
--   * Context/Reference/Traits are initial-state semantics handled by existing runtime
--   * source and target remain independent

CREATE OR REPLACE FUNCTION public.runtime_create_clone(
  p_agreement_id uuid,
  p_clone_name text DEFAULT NULL::text
)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
DECLARE
  v_agreement public.clone_agreements%rowtype;
  v_target_account_id uuid;
  v_source_sh public.sh_instances%rowtype;
  v_clone_sh_id uuid;
  v_now timestamptz := now();
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'CLONE_REJECTED: authentication required';
  END IF;

  v_target_account_id := public.current_account_id();
  IF v_target_account_id IS NULL THEN
    RAISE EXCEPTION 'CLONE_REJECTED: authenticated account not resolved';
  END IF;

  SELECT *
    INTO v_agreement
    FROM public.clone_agreements
   WHERE agreement_id = p_agreement_id
     AND status = 'APPROVED'
   FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'CLONE_REJECTED: approved agreement required';
  END IF;

  SELECT *
    INTO v_source_sh
    FROM public.sh_instances
   WHERE sh_id = v_agreement.source_sh_id
     AND account_id = v_agreement.source_account_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'CLONE_REJECTED: source SH ownership boundary failed';
  END IF;

  IF v_agreement.source_account_id = v_target_account_id THEN
    RAISE EXCEPTION 'CLONE_REJECTED: source and target accounts must differ';
  END IF;

  IF EXISTS (
    SELECT 1
      FROM public.accounts
     WHERE account_id = v_target_account_id
       AND lower(trim(email)) <> lower(trim(v_agreement.target_email))
  ) THEN
    RAISE EXCEPTION 'CLONE_REJECTED: authenticated recipient does not match intended email';
  END IF;

  IF v_agreement.target_account_id IS NOT NULL
     AND v_agreement.target_account_id <> v_target_account_id THEN
    RAISE EXCEPTION 'CLONE_REJECTED: agreement is already linked to another target account';
  END IF;

  IF EXISTS (
    SELECT 1 FROM public.sh_instances WHERE account_id = v_target_account_id
  ) THEN
    RAISE EXCEPTION 'CLONE_REJECTED: target account already has an SH';
  END IF;

  v_clone_sh_id := gen_random_uuid();

  INSERT INTO public.sh_instances (
    sh_id,
    account_id,
    sh_type,
    is_primary,
    canonical_name,
    creator_ref,
    status,
    metadata,
    version,
    created_at,
    updated_at
  ) VALUES (
    v_clone_sh_id,
    v_target_account_id,
    'PRIMARY',
    true,
    COALESCE(NULLIF(trim(p_clone_name), ''), COALESCE(v_source_sh.canonical_name, 'SH') || ' Clone'),
    'clone:' || v_agreement.source_sh_id::text,
    'created',
    jsonb_build_object(
      'origin', 'CLONE',
      'source_sh_id', v_agreement.source_sh_id,
      'source_account_id', v_agreement.source_account_id,
      'agreement_id', v_agreement.agreement_id,
      'target_email', v_agreement.target_email,
      'initial_state_semantics', 'CONTEXT_REFERENCE_TRAITS'
    ),
    1,
    v_now,
    v_now
  );

  INSERT INTO public.sh_ownership (
    ownership_id,
    account_id,
    sh_id,
    role,
    granted_at,
    evidence_ref,
    created_at
  ) VALUES (
    gen_random_uuid(),
    v_target_account_id,
    v_clone_sh_id,
    'OWNER',
    v_now,
    'clone_agreement:' || v_agreement.agreement_id::text,
    v_now
  );

  INSERT INTO public.sh_clones (
    clone_sh_id,
    source_sh_id,
    agreement_id,
    status,
    created_at
  ) VALUES (
    v_clone_sh_id,
    v_agreement.source_sh_id,
    v_agreement.agreement_id,
    'ACTIVE',
    v_now
  );

  INSERT INTO public.memories (
    sh_id,
    memory_type,
    content,
    source,
    confidence,
    scope,
    visibility,
    lifecycle,
    occurrence_count,
    created_at,
    updated_at,
    superseded_by
  )
  SELECT
    v_clone_sh_id,
    m.memory_type,
    m.content,
    m.source,
    m.confidence,
    m.scope,
    m.visibility,
    CASE WHEN m.lifecycle = 'CANDIDATE' THEN 'ACTIVE' ELSE m.lifecycle END,
    m.occurrence_count,
    v_now,
    v_now,
    NULL
  FROM public.memories m
  WHERE m.sh_id = v_agreement.source_sh_id;

  INSERT INTO public.knowledge (
    content,
    knowledge_class,
    scope,
    visibility,
    source,
    provenance,
    confidence,
    version,
    lifecycle,
    superseded_by,
    created_at,
    updated_at,
    sh_id
  )
  SELECT
    k.content,
    k.knowledge_class,
    k.scope,
    k.visibility,
    k.source,
    jsonb_build_object(
      'clone_origin', jsonb_build_object(
        'source_sh_id', v_agreement.source_sh_id,
        'source_account_id', v_agreement.source_account_id,
        'agreement_id', v_agreement.agreement_id,
        'cloned_at', v_now
      ),
      'original_provenance', k.provenance
    ),
    k.confidence,
    1,
    CASE WHEN k.lifecycle = 'CANDIDATE' THEN 'ACTIVE' ELSE k.lifecycle END,
    NULL,
    v_now,
    v_now,
    CASE WHEN k.scope = 'PRIVATE' THEN v_clone_sh_id ELSE NULL END
  FROM public.knowledge k
  WHERE k.scope = 'GENERAL'
     OR k.sh_id = v_agreement.source_sh_id;

  UPDATE public.clone_agreements
     SET target_account_id = v_target_account_id
   WHERE agreement_id = v_agreement.agreement_id;

  RETURN v_clone_sh_id;
END;
$function$;

REVOKE ALL ON FUNCTION public.runtime_create_clone(uuid, text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.runtime_create_clone(uuid, text) TO authenticated;
