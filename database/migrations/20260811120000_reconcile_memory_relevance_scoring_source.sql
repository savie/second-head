-- Reconciliation migration for BL-P3C-002.
-- The original remote migration (20260811103611_add_memory_relevance_scoring)
-- is applied remotely but its historical SQL artifact is not present in Git.
-- This forward-only migration captures the verified live function definition
-- without fabricating or rewriting the historical migration.

create or replace function public.memory_relevance_score(query_text text, memory_content text)
returns numeric
language sql
immutable parallel safe
as $$
  select least(
    1.0::numeric,
    ts_rank_cd(
      to_tsvector('simple', coalesce(memory_content, '')),
      plainto_tsquery('simple', coalesce(query_text, ''))
    )::numeric
  );
$$;
