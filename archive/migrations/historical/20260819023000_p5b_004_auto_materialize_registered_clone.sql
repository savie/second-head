-- Once the intended recipient has an authenticated account, registration/session
-- bootstrap can materialize the approved Clone automatically.

CREATE UNIQUE INDEX IF NOT EXISTS clone_agreements_one_approved_per_email_idx
  ON public.clone_agreements (lower(target_email))
  WHERE status = 'APPROVED';

CREATE OR REPLACE FUNCTION public.runtime_materialize_registered_clone()
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
DECLARE
  v_account_id uuid;
  v_email text;
  v_agreement_id uuid;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'CLONE_REJECTED: authentication required';
  END IF;

  v_account_id := public.current_account_id();
  IF v_account_id IS NULL THEN
    RAISE EXCEPTION 'CLONE_REJECTED: authenticated account not resolved';
  END IF;

  SELECT lower(trim(email)) INTO v_email
  FROM public.accounts
  WHERE account_id = v_account_id;

  SELECT agreement_id INTO v_agreement_id
  FROM public.clone_agreements
  WHERE status = 'APPROVED'
    AND target_account_id IS NULL
    AND lower(trim(target_email)) = v_email
  ORDER BY approved_at ASC, created_at ASC
  LIMIT 1;

  IF v_agreement_id IS NULL THEN
    RETURN NULL;
  END IF;

  RETURN public.runtime_create_clone(v_agreement_id, NULL);
END;
$function$;

REVOKE ALL ON FUNCTION public.runtime_materialize_registered_clone() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.runtime_materialize_registered_clone() TO authenticated;
