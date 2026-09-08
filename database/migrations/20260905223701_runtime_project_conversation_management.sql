create or replace function public.runtime_rename_project(p_project_id uuid, p_name text)
returns void
language plpgsql
security definer
set search_path to 'public'
as $function$
declare
  v_identity record;
  v_count integer;
begin
  select * into v_identity from public.resolve_identity();
  if v_identity.account_id is null or v_identity.sh_id is null then
    raise exception 'PROJECT_UNAUTHENTICATED';
  end if;
  if nullif(trim(p_name), '') is null then
    raise exception 'PROJECT_NAME_REQUIRED';
  end if;

  update public.projects
     set name = trim(p_name), updated_at = now()
   where project_id = p_project_id
     and account_id = v_identity.account_id
     and sh_id = v_identity.sh_id;

  get diagnostics v_count = row_count;
  if v_count <> 1 then
    raise exception 'PROJECT_NOT_FOUND';
  end if;
end;
$function$;

create or replace function public.runtime_assign_conversation_project(
  p_conversation_id uuid,
  p_project_id uuid default null
)
returns void
language plpgsql
security definer
set search_path to 'public'
as $function$
declare
  v_identity record;
  v_count integer;
  v_project_account uuid;
  v_project_sh uuid;
begin
  select * into v_identity from public.resolve_identity();
  if v_identity.account_id is null or v_identity.sh_id is null then
    raise exception 'CONVERSATION_UNAUTHENTICATED';
  end if;

  if p_project_id is not null then
    select p.account_id, p.sh_id
      into v_project_account, v_project_sh
      from public.projects p
     where p.project_id = p_project_id;

    if v_project_account is null
       or v_project_sh is null
       or v_project_account <> v_identity.account_id
       or v_project_sh <> v_identity.sh_id then
      raise exception 'CONVERSATION_PROJECT_ACCESS_DENIED';
    end if;
  end if;

  update public.conversation_threads
     set project_id = p_project_id,
         updated_at = now()
   where conversation_id = p_conversation_id
     and account_id = v_identity.account_id
     and sh_id = v_identity.sh_id;

  get diagnostics v_count = row_count;
  if v_count <> 1 then
    raise exception 'CONVERSATION_NOT_FOUND';
  end if;
end;
$function$;

create or replace function public.runtime_delete_project(p_project_id uuid)
returns void
language plpgsql
security definer
set search_path to 'public'
as $function$
declare
  v_identity record;
  v_count integer;
begin
  select * into v_identity from public.resolve_identity();
  if v_identity.account_id is null or v_identity.sh_id is null then
    raise exception 'PROJECT_UNAUTHENTICATED';
  end if;

  perform 1
    from public.projects p
   where p.project_id = p_project_id
     and p.account_id = v_identity.account_id
     and p.sh_id = v_identity.sh_id
   for update;

  if not found then
    raise exception 'PROJECT_NOT_FOUND';
  end if;

  delete from public.conversation_threads
   where project_id = p_project_id
     and account_id = v_identity.account_id
     and sh_id = v_identity.sh_id;

  delete from public.projects
   where project_id = p_project_id
     and account_id = v_identity.account_id
     and sh_id = v_identity.sh_id;

  get diagnostics v_count = row_count;
  if v_count <> 1 then
    raise exception 'PROJECT_NOT_FOUND';
  end if;
end;
$function$;