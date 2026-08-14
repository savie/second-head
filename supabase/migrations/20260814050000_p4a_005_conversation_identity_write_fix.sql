-- P4A-005 — Conversation persistence identity alignment
-- Fix: ACCOUNT_ID is distinct from auth.uid(); resolve current principal first.

CREATE OR REPLACE FUNCTION public.runtime_record_conversation(
  p_sh_id uuid,
  p_role text,
  p_content text,
  p_metadata jsonb DEFAULT '{}'::jsonb
)
RETURNS public.conversations
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_identity record;
  v_row public.conversations;
BEGIN
  SELECT * INTO v_identity
  FROM public.resolve_identity();

  IF v_identity.account_id IS NULL OR v_identity.sh_id IS NULL THEN
    RAISE EXCEPTION 'RUNTIME_CONVERSATION_UNAUTHENTICATED';
  END IF;

  IF p_sh_id <> v_identity.sh_id THEN
    RAISE EXCEPTION 'RUNTIME_CONVERSATION_ACCESS_DENIED';
  END IF;

  IF p_role NOT IN ('user', 'assistant', 'system') THEN
    RAISE EXCEPTION 'RUNTIME_CONVERSATION_INVALID_ROLE';
  END IF;

  IF p_content IS NULL OR length(trim(p_content)) = 0 THEN
    RAISE EXCEPTION 'RUNTIME_CONVERSATION_INVALID_CONTENT';
  END IF;

  INSERT INTO public.conversations (
    account_id,
    sh_id,
    role,
    content,
    metadata
  )
  VALUES (
    v_identity.account_id,
    v_identity.sh_id,
    p_role,
    p_content,
    coalesce(p_metadata, '{}'::jsonb)
  )
  RETURNING * INTO v_row;

  RETURN v_row;
END;
$$;

REVOKE EXECUTE ON FUNCTION public.runtime_record_conversation(uuid, text, text, jsonb) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.runtime_record_conversation(uuid, text, text, jsonb) FROM anon;
GRANT EXECUTE ON FUNCTION public.runtime_record_conversation(uuid, text, text, jsonb) TO authenticated;

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
  ORDER BY c.created_at ASC
  LIMIT greatest(1, least(coalesce(p_limit, 50), 100));
END;
$$;

REVOKE EXECUTE ON FUNCTION public.runtime_load_conversation(integer) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.runtime_load_conversation(integer) FROM anon;
GRANT EXECUTE ON FUNCTION public.runtime_load_conversation(integer) TO authenticated;
