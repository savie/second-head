create or replace function public.memory_relevance_score(query_text text, memory_content text)
returns numeric
language sql
immutable
parallel safe
set search_path to 'pg_catalog', 'public'
as $function$
  with normalized as (
    select trim(regexp_replace(lower(coalesce(query_text, '')), '[^[:alnum:]\\\\s]+', ' ', 'g')) as q
  ),
  tokens as (
    select regexp_split_to_table(q, '\\\\s+') as token
    from normalized
  ),
  filtered as (
    select token
    from tokens
    where token <> ''
      and token <> all (array[
        'apa','adalah','anda','atau','bahwa','bagaimana','biasanya','dengan','dari','dan','dalam','di','ini','itu','juga','karena','ke','kapan','kamu','kalau','kemana','ketika','mengapa','oleh','pada','saya','sebagai','seperti','tentang','terkait','untuk','yang'
      ]::text[])
  ),
  query_terms as (
    select string_agg(token, ' | ' order by token) as tsq
    from filtered
  )
  select least(1.0::numeric, ts_rank_cd(
    to_tsvector('simple', coalesce(memory_content, '')),
    to_tsquery('simple', nullif(query_terms.tsq, ''))
  )::numeric)
  from query_terms;
$function$;