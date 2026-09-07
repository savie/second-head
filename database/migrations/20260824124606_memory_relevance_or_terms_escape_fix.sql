create or replace function public.memory_relevance_score(query_text text, memory_content text)
returns numeric language sql immutable parallel safe
as $$
  select least(1.0::numeric, ts_rank_cd(
    to_tsvector('simple', coalesce(memory_content, '')),
    to_tsquery('simple', regexp_replace(trim(regexp_replace(coalesce(query_text, ''), '[^[:alnum:]\\s]+', ' ', 'g')), '\\s+', ' | ', 'g'))
  )::numeric);
$$;