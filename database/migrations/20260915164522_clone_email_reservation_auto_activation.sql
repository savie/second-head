-- Clone is owner-authorized by email reservation; there is no recipient approval step.
-- Creating a Clone request locks the target email and marks the reservation APPROVED.
-- Registration/sign-in of that exact email then materializes the Clone as PRIMARY SH.

CREATE OR REPLACE FUNCTION public.prepare_clone_email_reservation()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_email text;
  v_source_account uuid;
BEGIN
  v_email := lower(trim(NEW.target_email));
  IF v_email IS NULL OR v_email = '' THEN
    RAISE EXCEPTION 'CLONE_REJECTED: target email is required';
  END IF;

  v_source_account := public.current_account_id();
  IF v_source_account IS NULL OR NEW.source_account_id <> v_source_account THEN
    RAISE EXCEPTION 'CLONE_REJECTED: source owner boundary failed';
  END IF;

  IF EXISTS (
    SELECT 1 FROM public.accounts a
    WHERE lower(trim(a.email)) = v_email
  ) THEN
    RAISE EXCEPTION 'CLONE_REJECTED: target email is already registered';
  END IF;

  IF EXISTS (
    SELECT 1 FROM public.clone_agreements ca
    WHERE lower(trim(ca.target_email)) = v_email
      AND ca.status IN ('PENDING','APPROVED')
  ) THEN
    RAISE EXCEPTION 'CLONE_REJECTED: target email is already reserved';
  END IF;

  NEW.target_email := v_email;
  NEW.target_account_id := NULL;
  NEW.status := 'APPROVED';
  NEW.approved_at := COALESCE(NEW.approved_at, now());
  NEW.revoked_at := NULL;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS clone_agreements_auto_approve_email_reservation ON public.clone_agreements;
CREATE TRIGGER clone_agreements_auto_approve_email_reservation
BEFORE INSERT ON public.clone_agreements
FOR EACH ROW
EXECUTE FUNCTION public.prepare_clone_email_reservation();

CREATE UNIQUE INDEX IF NOT EXISTS clone_agreements_one_approved_per_email_idx
  ON public.clone_agreements (lower(target_email))
  WHERE status = 'APPROVED';

-- Existing stale pending reservations point at accounts that are already registered;
-- they cannot become Clone reservations and must not block those addresses forever.
UPDATE public.clone_agreements ca
SET status = 'REVOKED', revoked_at = COALESCE(revoked_at, now())
WHERE ca.status = 'PENDING'
  AND EXISTS (
    SELECT 1 FROM public.accounts a
    WHERE lower(trim(a.email)) = lower(trim(ca.target_email))
  );

-- Clone materialization is invoked through the registration/sign-in path.
-- Keep the lower-level clone constructor internal to trusted runtime functions.
REVOKE EXECUTE ON FUNCTION public.runtime_create_clone(uuid, text) FROM authenticated, anon, PUBLIC;
GRANT EXECUTE ON FUNCTION public.runtime_materialize_registered_clone() TO authenticated;

COMMENT ON FUNCTION public.prepare_clone_email_reservation()
IS 'Clone owner authorization: reserves an unregistered target email and atomically marks the Clone agreement APPROVED; recipient approval is not part of the Clone flow.';