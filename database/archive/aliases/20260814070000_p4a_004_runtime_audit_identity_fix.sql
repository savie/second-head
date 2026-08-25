-- P4A-004 — Runtime audit identity alignment
-- Fix: ACCOUNT_ID is distinct from auth.uid(); resolve the current principal first.
-- Preserve the SH ownership boundary while aligning audit persistence with P4A-005 conversation persistence.

CREATE OR REPLACE FUNCTION public.runtime_record_audit(
  p_sh_id uuid,
  p_event_type text,
  p_status text,
  p_metadata jsonb DEFAULT '{}'::jsonb
)
RETURNS public.audit_events
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_identity record;
  v_row public.audit_events;
BEGIN
  SELECT * INTO v_identity
  FROM public.resolve_identity();

  IF v_identity.account_id IS NULL OR v_identity.sh_id IS NULL THEN
    RAISE EXCEPTION 'RUNTIME_AUDIT_REJECTED: authenticated identity could not be resolved';
  END IF;

  IF p_sh_id <> v_identity.sh_id THEN
    RAISE EXCEPTION 'RUNTIME_AUDIT_REJECTED: SH ownership boundary failed';
  END IF;

  IF p_event_type NOT IN ('RUNTIME_REQUEST', 'RUNTIME_RESPONSE', 'RUNTIME_MEMORY_DECISION') THEN
    RAISE EXCEPTION 'RUNTIME_AUDIT_REJECTED: invalid event type';
  END IF;

  IF p_status NOT IN ('SUCCESS', 'REJECTED', 'FAILED') THEN
    RAISE EXCEPTION 'RUNTIME_AUDIT_REJECTED: invalid status';
  END IF;

  INSERT INTO public.audit_events (
    account_id,
    sh_id,
    event_type,
    status,
    metadata
  )
  VALUES (
    v_identity.account_id,
    v_identity.sh_id,
    p_event_type,
    p_status,
    coalesce(p_metadata, '{}'::jsonb)
  )
  RETURNING * INTO v_row;

  RETURN v_row;
END;
$$;

REVOKE EXECUTE ON FUNCTION public.runtime_record_audit(uuid, text, text, jsonb) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.runtime_record_audit(uuid, text, text, jsonb) FROM anon;
GRANT EXECUTE ON FUNCTION public.runtime_record_audit(uuid, text, text, jsonb) TO authenticated;
