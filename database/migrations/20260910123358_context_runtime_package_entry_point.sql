-- Context Runtime Package entry point.
-- Composes existing runtime boundaries without creating new storage domains.
-- Reuses actor, conversation, state, memory, and knowledge runtime components.

CREATE OR REPLACE FUNCTION public.runtime_get_context_package(
  p_sh_id uuid,
  p_query_text text
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_identity record;
  v_state jsonb;
  v_semantic_context jsonb;
  v_conversation jsonb;
BEGIN
  SELECT * INTO v_identity
  FROM public.resolve_identity();

  IF v_identity.account_id IS NULL OR v_identity.sh_id IS NULL THEN
    RAISE EXCEPTION 'RUNTIME_CONTEXT_UNAUTHENTICATED';
  END IF;

  IF p_sh_id <> v_identity.sh_id THEN
    RAISE EXCEPTION 'RUNTIME_CONTEXT_ACCESS_DENIED';
  END IF;

  SELECT coalesce(jsonb_agg(to_jsonb(c)), '[]'::jsonb)
  INTO v_conversation
  FROM public.runtime_load_conversation_context(p_sh_id) c;

  SELECT public.runtime_get_sh_state(p_sh_id)
  INTO v_state;

  SELECT public.assemble_context(p_sh_id, p_query_text)
  INTO v_semantic_context;

  RETURN jsonb_build_object(
    'sh_id', p_sh_id,
    'conversation', v_conversation,
    'state', coalesce(v_state, '{}'::jsonb),
    'semantic', coalesce(v_semantic_context, '{}'::jsonb)
  );
END;
$$;

REVOKE ALL ON FUNCTION public.runtime_get_context_package(uuid, text) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.runtime_get_context_package(uuid, text) FROM anon;
GRANT EXECUTE ON FUNCTION public.runtime_get_context_package(uuid, text) TO authenticated;
