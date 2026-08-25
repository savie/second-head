-- Reconciliation for Memory retrieval recall.
-- The existing P3C relevance primitive used plainto_tsquery(), which requires
-- every non-stopword in the user query to be present in the Memory text.
-- Natural-language recall queries therefore scored exact durable memories as 0.
-- This forward-only change keeps the same deterministic ts_rank_cd primitive,
-- but builds an OR query so matching query terms can contribute independently.
-- Retrieval then requires a non-trivial relevance score before a Memory enters
-- the bounded runtime candidate set.

create or replace function public.memory_relevance_score(query_text text, memory_content text)
returns numeric
language sql
immutable parallel safe
as $$
  select least(
    1.0::numeric,
    ts_rank_cd(
      to_tsvector('simple', coalesce(memory_content, '')),
      websearch_to_tsquery(
        'simple',
        regexp_replace(trim(coalesce(query_text, '')), '\\s+', ' OR ', 'g')
      )
    )::numeric
  );
$$;

create or replace function public.retrieve_memories_bounded(
  p_sh_id uuid,
  p_query_text text,
  p_limit integer default 20
)
returns table (
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
language sql
stable
parallel safe
security invoker
set search_path = pg_catalog, public
as $$
  select
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
    public.memory_relevance_score(p_query_text, m.content) as relevance_score
  from public.memories as m
  where m.sh_id = p_sh_id
    and m.lifecycle in ('CANDIDATE', 'ACTIVE', 'UPDATED')
    and public.memory_relevance_score(p_query_text, m.content) > 0.15
  order by
    public.memory_relevance_score(p_query_text, m.content) desc,
    m.updated_at desc,
    m.occurrence_count desc,
    m.memory_id asc
  limit least(greatest(coalesce(p_limit, 20), 1), 50);
$$;

revoke all on function public.retrieve_memories_bounded(uuid, text, integer) from public;
grant execute on function public.retrieve_memories_bounded(uuid, text, integer) to authenticated;
