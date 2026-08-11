-- BL-P3D-009 — Knowledge Retrieval
-- Minimal deterministic retrieval for Knowledge already indexed/active and explicitly shareable.
-- No semantic search, vector search, trust promotion, or new ownership model.

create policy knowledge_shared_retrieval_select
on public.knowledge
for select
to authenticated
using (
  scope = 'GENERAL'
  and visibility = 'SHARED'
  and lifecycle in ('INDEXED', 'ACTIVE')
);

CREATE OR REPLACE FUNCTION public.retrieve_knowledge_bounded(
  p_query_text text,
  p_limit integer DEFAULT 20
)
RETURNS TABLE (
  knowledge_id uuid,
  content text,
  knowledge_class text,
  scope text,
  visibility text,
  source text,
  provenance jsonb,
  confidence numeric,
  version integer,
  lifecycle text,
  superseded_by uuid,
  created_at timestamptz,
  updated_at timestamptz
)
LANGUAGE sql
STABLE
PARALLEL SAFE
SECURITY INVOKER
SET search_path = pg_catalog, public
AS $$
  SELECT
    k.knowledge_id,
    k.content,
    k.knowledge_class,
    k.scope,
    k.visibility,
    k.source,
    k.provenance,
    k.confidence,
    k.version,
    k.lifecycle,
    k.superseded_by,
    k.created_at,
    k.updated_at
  FROM public.knowledge AS k
  WHERE k.scope = 'GENERAL'
    AND k.visibility = 'SHARED'
    AND k.lifecycle IN ('INDEXED', 'ACTIVE')
    AND (
      NULLIF(trim(COALESCE(p_query_text, '')), '') IS NULL
      OR k.content ILIKE '%' || trim(p_query_text) || '%'
    )
  ORDER BY
    k.updated_at DESC,
    k.version DESC,
    k.knowledge_id ASC
  LIMIT LEAST(GREATEST(COALESCE(p_limit, 20), 1), 50);
$$;

REVOKE ALL ON FUNCTION public.retrieve_knowledge_bounded(text, integer) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.retrieve_knowledge_bounded(text, integer) TO authenticated;
