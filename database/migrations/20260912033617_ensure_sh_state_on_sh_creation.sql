-- Ensure every SH materialization has its initial runtime state row.
-- This enforces the sh_instances -> sh_states lifecycle invariant for
-- normal provisioning and clone materialization paths.

CREATE OR REPLACE FUNCTION public.ensure_sh_state_on_sh_creation()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.sh_states (
    sh_id,
    state_version,
    revision,
    state_payload
  )
  VALUES (
    NEW.sh_id,
    1,
    1,
    '{}'::jsonb
  )
  ON CONFLICT (sh_id) DO NOTHING;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_ensure_sh_state_on_sh_creation ON public.sh_instances;

CREATE TRIGGER trg_ensure_sh_state_on_sh_creation
AFTER INSERT ON public.sh_instances
FOR EACH ROW
EXECUTE FUNCTION public.ensure_sh_state_on_sh_creation();

REVOKE ALL ON FUNCTION public.ensure_sh_state_on_sh_creation() FROM PUBLIC;

COMMENT ON FUNCTION public.ensure_sh_state_on_sh_creation()
IS 'SH lifecycle invariant: every newly materialized SH receives its initial sh_states row atomically with SH creation.';
