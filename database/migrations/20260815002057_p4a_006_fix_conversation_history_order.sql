-- P4A-006 — Conversation history latest-window fix
-- Preserve the existing identity/authorization boundary; only change the history window
-- so the 50-row limit selects the newest conversations before the App reverses them.
CREATE OR REPLACE FUNCTION public.runtime_load_conversation(p_limit integer DEFAULT 50)
RETURNS SETOF public.conversations
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_identity record;
BEGIN
  SELECT * INTO v_identity
  FROM public.resolve_identity();

  IF v_identity.account_id IS NULL OR v_identity.sh_id IS NULL THEN
    RAISE EXCEPTION 'RUNTIME_CONVERSATION_UNAUTHENTICATED';
  END IF;

  RETURN QUERY
  SELECT c.*
  FROM public.conversations c
  WHERE c.account_id = v_identity.account_id
    AND c.sh_id = v_identity.sh_id
  ORDER BY c.created_at DESC
  LIMIT greatest(1, least(coalesce(p_limit, 50), 100));
END;
$$;

REVOKE EXECUTE ON FUNCTION public.runtime_load_conversation(integer) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.runtime_load_conversation(integer) FROM anon;
GRANT EXECUTE ON FUNCTION public.runtime_load_conversation(integer) TO authenticated;
