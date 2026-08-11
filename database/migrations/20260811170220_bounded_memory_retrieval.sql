CREATE OR REPLACE FUNCTION public.retrieve_memories_bounded(
  p_sh_id uuid,
  p_query_text text,
  p_limit integer DEFAULT 20
)
RETURNS TABLE (
  memory_id uuid,
  sh_id uuid,
  memory_type text,
  content text,
  source text,
  confidence numeric,
  scope text,
  visibility text,
  lifecycle text,
  occurrence_count integer,
  created_at timestamptz,
  updated_at timestamptz,
  superseded_by uuid,
  relevance_score numeric
)
LANGUAGE sql
STABLE
PARALLEL SAFE
SECURITY INVOKER
SET search_path = pg_catalog, public
AS $$
  SELECT
    m.memory_id,
    m.sh_id,
    m.memory_type,
    m.content,
    m.source,
    m.confidence,
    m.scope,
    m.visibility,
    m.lifecycle,
    m.occurrence_count,
    m.created_at,
    m.updated_at,
    m.superseded_by,
    public.memory_relevance_score(p_query_text, m.content) AS relevance_score
  FROM public.memories AS m
  WHERE m.sh_id = p_sh_id
    AND m.lifecycle IN ('CANDIDATE', 'ACTIVE', 'UPDATED')
  ORDER BY
    public.memory_relevance_score(p_query_text, m.content) DESC,
    m.updated_at DESC,
    m.occurrence_count DESC,
    m.memory_id ASC
  LIMIT LEAST(GREATEST(COALESCE(p_limit, 20), 1), 50);
$$;

REVOKE ALL ON FUNCTION public.retrieve_memories_bounded(uuid, text, integer) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.retrieve_memories_bounded(uuid, text, integer) TO authenticated;
