-- BUG-001 / Build #195
-- Runtime-owned short-term conversation context.
-- Reuses existing public.conversations persistence and active-SH identity resolution.
-- Does not create a new storage domain and does not touch Memory or Experience.

CREATE OR REPLACE FUNCTION public.runtime_load_conversation_context(
  p_sh_id uuid,
  p_limit integer DEFAULT 12
)
RETURNS TABLE (
  conversation_id uuid,
  role text,
  content text,
  created_at timestamptz,
  metadata jsonb
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_identity record;
  v_limit integer := greatest(1, least(coalesce(p_limit, 12), 12));
BEGIN
  SELECT * INTO v_identity
  FROM public.resolve_identity();

  IF v_identity.account_id IS NULL OR v_identity.sh_id IS NULL THEN
    RAISE EXCEPTION 'RUNTIME_CONVERSATION_UNAUTHENTICATED';
  END IF;

  IF p_sh_id <> v_identity.sh_id THEN
    RAISE EXCEPTION 'RUNTIME_CONVERSATION_ACCESS_DENIED';
  END IF;

  RETURN QUERY
  SELECT c.conversation_id, c.role, c.content, c.created_at, c.metadata
  FROM (
    SELECT c.*
    FROM public.conversations c
    WHERE c.account_id = v_identity.account_id
      AND c.sh_id = v_identity.sh_id
    ORDER BY c.created_at DESC, c.conversation_id DESC
    LIMIT v_limit
  ) c
  ORDER BY c.created_at ASC, c.conversation_id ASC;
END;
$$;

REVOKE EXECUTE ON FUNCTION public.runtime_load_conversation_context(uuid, integer) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.runtime_load_conversation_context(uuid, integer) FROM anon;
GRANT EXECUTE ON FUNCTION public.runtime_load_conversation_context(uuid, integer) TO authenticated;
