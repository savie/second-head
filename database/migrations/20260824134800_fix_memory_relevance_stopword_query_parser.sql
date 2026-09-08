create or replace function public.memory_relevance_score(query_text text, memory_content text)
returns numeric
language sql
immutable
parallel safe
set search_path to 'pg_catalog', 'public'
as $function$
  select least(1.0::numeric, ts_rank_cd(
    to_tsvector('simple', coalesce(memory_content, '')),
    to_tsquery(
      'simple',
      nullif(
        regexp_replace(
          regexp_replace(
            trim(regexp_replace(coalesce(query_text, ''), '[^[:alnum:]\\\\s]+', ' ', 'g')),
            '(^| )(apa|adalah|anda|atau|bahwa|bagaimana|biasanya|dengan|dari|dan|dalam|di|ini|itu|juga|karena|ke|kapan|kamu|kalau|kemana|ketika|mengapa|oleh|pada|saya|sebagai|seperti|tentang|terkait|untuk|yang)( |$)',
            ' ',
            'gi'
          ),
          '\\\\s+',
          ' | ',
          'g'
        ),
        ''
      )
    )
  )::numeric);
$function$;