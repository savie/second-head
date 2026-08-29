-- R2 Authorized Read / Retrieve: bounded source-bound read against existing SH Knowledge.
create or replace function public.authorized_read_retrieve_bounded(
  p_sh_id uuid,
  p_source text,
  p_scope text default 'PRIVATE',
  p_query text default null,
  p_limit integer default 20,
  p_offset integer default 0,
  p_invocation_id uuid default gen_random_uuid()
)
returns table(result_id uuid, content text, knowledge_class text, source text, scope text, visibility text, provenance jsonb, occurred_at timestamptz)
language plpgsql security definer set search_path to public as $$
declare
  v_account_id uuid;
  v_query text := nullif(trim(coalesce(p_query,'')),'');
  v_limit integer := least(greatest(coalesce(p_limit,20),1),50);
  v_offset integer := least(greatest(coalesce(p_offset,0),0),200);
begin
  if auth.uid() is null then raise exception 'R2_REJECTED: authentication required'; end if;
  v_account_id := public.current_account_id();
  if v_account_id is null then raise exception 'R2_REJECTED: account could not be resolved'; end if;
  if p_sh_id is null or not exists (select 1 from public.sh_instances s where s.sh_id=p_sh_id and s.account_id=v_account_id and s.status<>'deactivated') then
    raise exception 'R2_REJECTED: invalid SH ownership';
  end if;
  if nullif(trim(coalesce(p_source,'')),'') is null then raise exception 'R2_REJECTED: source binding required'; end if;
  if p_scope not in ('PRIVATE','GENERAL') then raise exception 'R2_REJECTED: invalid scope'; end if;
  if v_query is not null and length(v_query)>2000 then raise exception 'R2_REJECTED: query too large'; end if;

  -- Explicit source + scope binding. No provider/connection is treated as implicit authority.
  if not exists (
    select 1 from public.knowledge k
    where k.sh_id=p_sh_id
      and k.source=p_source
      and k.scope=p_scope
      and k.lifecycle in ('CANDIDATE','ACTIVE','UPDATED')
      and ((p_scope='PRIVATE' and k.visibility='OWNER_ONLY') or (p_scope='GENERAL' and k.visibility='SHARED'))
      and (v_query is null or position(lower(v_query) in lower(k.content))>0)
  ) then
    perform public.runtime_record_audit(p_sh_id,'RUNTIME_REQUEST','DENIED',
      jsonb_build_object('source','workstream-e:r2:authorized-read','action_id',p_invocation_id,'tool_id','R2','capability','AUTHORIZED_READ_RETRIEVE','source_binding',p_source,'scope',p_scope,'query_hash',case when v_query is null then null else md5(v_query) end,'reason','NO_AUTHORIZED_MATCH'));
    raise exception 'R2_REJECTED: source/scope not authorized or no permitted data';
  end if;

  perform public.runtime_record_audit(p_sh_id,'RUNTIME_REQUEST','SUCCESS',
    jsonb_build_object('source','workstream-e:r2:authorized-read','action_id',p_invocation_id,'tool_id','R2','capability','AUTHORIZED_READ_RETRIEVE','source_binding',p_source,'scope',p_scope,'query_hash',case when v_query is null then null else md5(v_query) end,'limit',v_limit,'offset',v_offset));

  return query
  select k.knowledge_id,k.content,k.knowledge_class,k.source,k.scope,k.visibility,k.provenance,k.updated_at
  from public.knowledge k
  where k.sh_id=p_sh_id
    and k.source=p_source
    and k.scope=p_scope
    and k.lifecycle in ('CANDIDATE','ACTIVE','UPDATED')
    and ((p_scope='PRIVATE' and k.visibility='OWNER_ONLY') or (p_scope='GENERAL' and k.visibility='SHARED'))
    and (v_query is null or position(lower(v_query) in lower(k.content))>0)
  order by k.updated_at desc,k.knowledge_id
  offset v_offset limit v_limit;
end; $$;

revoke all on function public.authorized_read_retrieve_bounded(uuid,text,text,text,integer,integer,uuid) from public,anon;
grant execute on function public.authorized_read_retrieve_bounded(uuid,text,text,text,integer,integer,uuid) to authenticated;
