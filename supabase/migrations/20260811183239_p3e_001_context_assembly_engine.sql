create or replace function public.assemble_context(p_sh_id uuid, p_query_text text, p_memory_limit integer default 10, p_knowledge_limit integer default 10)
returns jsonb
language sql
stable
parallel safe
set search_path to 'pg_catalog', 'public'
as $function$
  with memory_items as (
    select coalesce(jsonb_agg(to_jsonb(m) order by m.relevance_score desc, m.updated_at desc), '[]'::jsonb) as items
    from public.retrieve_memories_bounded(
      p_sh_id,
      p_query_text,
      least(greatest(coalesce(p_memory_limit, 10), 1), 50)
    ) as m
  ), knowledge_items as (
    select coalesce(jsonb_agg(to_jsonb(k) order by k.updated_at desc, k.version desc, k.knowledge_id asc), '[]'::jsonb) as items
    from public.retrieve_knowledge_bounded(
      p_query_text,
      least(greatest(coalesce(p_knowledge_limit, 10), 1), 50)
    ) as k
  )
  select jsonb_build_object(
    'query', p_query_text,
    'memory', memory_items.items,
    'knowledge', knowledge_items.items
  )
  from memory_items cross join knowledge_items;
$function$;

revoke all on function public.assemble_context(uuid, text, integer, integer) from public;
revoke all on function public.assemble_context(uuid, text, integer, integer) from anon;
revoke all on function public.assemble_context(uuid, text, integer, integer) from authenticated;
