create or replace function public.runtime_create_conversation(p_project_id uuid default null::uuid, p_title text default 'New Conversation'::text)
returns uuid
language plpgsql
security definer
set search_path to 'public'
as $function$
declare
  v_identity record;
  v_id uuid;
  v_project_account uuid;
begin
  select * into v_identity from public.resolve_identity();
  if v_identity.account_id is null or v_identity.sh_id is null then
    raise exception 'CONVERSATION_UNAUTHENTICATED';
  end if;

  if p_project_id is not null then
    select p.account_id into v_project_account
    from public.projects p
    where p.project_id = p_project_id
      and p.sh_id = v_identity.sh_id;
    if v_project_account is null or v_project_account <> v_identity.account_id then
      raise exception 'CONVERSATION_PROJECT_ACCESS_DENIED';
    end if;
  end if;

  insert into public.conversation_threads(account_id, sh_id, project_id, title)
  values (
    v_identity.account_id,
    v_identity.sh_id,
    p_project_id,
    coalesce(nullif(trim(p_title), ''), 'New Conversation')
  )
  returning conversation_id into v_id;

  return v_id;
end;
$function$;