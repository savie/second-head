create or replace function public.memory_relevance_score(query_text text, memory_content text)
returns numeric
language sql
immutable
parallel safe
as $$
  select least(
    1.0::numeric,
    ts_rank_cd(
      to_tsvector('simple', coalesce(memory_content, '')),
      plainto_tsquery('simple', coalesce(query_text, ''))
    )::numeric
  );
$$;

comment on function public.memory_relevance_score(text, text) is
'Relevance scoring primitive for BL-P3C-002. Deterministic PostgreSQL full-text lexical score normalized to [0,1]. Does not authorize, filter, rank-order, inject context, or promote memory to knowledge.';
