create or replace function public.runtime_load_conversation(p_limit integer default 50)
returns setof public.conversations
language plpgsql
security definer
set search_path = public
as $function$
begin
  if auth.uid() is null then
    raise exception 'RUNTIME_CONVERSATION_UNAUTHENTICATED';
  end if;

  return query
  select c.*
  from public.conversations c
  join public.sh_instances si
    on si.sh_id = c.sh_id
   and si.account_id = c.account_id
  where c.account_id = auth.uid()
    and si.account_id = auth.uid()
  order by c.created_at desc
  limit greatest(1, least(coalesce(p_limit, 50), 100));
end;
$function$;

grant execute on function public.runtime_load_conversation(integer) to authenticated;
