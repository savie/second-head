create or replace function public.assemble_context(
  p_sh_id uuid,
  p_query_text text,
  p_memory_limit integer default 10,
  p_knowledge_limit integer default 10
)
returns jsonb
language sql
stable
parallel safe
set search_path to 'pg_catalog', 'public'
as $function$
with requested as (
  select
    least(greatest(coalesce(p_memory_limit, 10), 1), 50) as memory_requested,
    least(greatest(coalesce(p_knowledge_limit, 10), 1), 50) as knowledge_requested
),
journey_item as (
  select coalesce(public.runtime_get_journey_context(p_sh_id, 20), '{}'::jsonb) as item
)
select jsonb_build_object(
  'query', p_query_text,
  'journey', journey_item.item
)
from journey_item;
$function$;
