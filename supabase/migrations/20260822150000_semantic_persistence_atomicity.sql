create or replace function public.runtime_replace_memory(
  p_sh_id uuid,
  p_new_content text,
  p_old_pattern text,
  p_source text default 'runtime:p5a:explicit_user_request',
  p_scope text default 'PRIVATE',
  p_visibility text default 'OWNER_ONLY'
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_new uuid;
  v_old uuid;
  v_match_count integer;
  v_account uuid;
begin
  if auth.uid() is null then raise exception 'MEMORY_REPLACE_REJECTED: authentication required'; end if;
  select s.account_id into v_account
  from public.sh_instances s
  where s.sh_id = p_sh_id
    and s.account_id = public.current_account_id()
    and s.status <> 'deactivated';
  if v_account is null then raise exception 'MEMORY_REPLACE_REJECTED: SH not owned by current active account'; end if;
  if p_new_content is null or btrim(p_new_content) = '' then raise exception 'MEMORY_REPLACE_REJECTED: content is required'; end if;
  if p_old_pattern is null or btrim(p_old_pattern) = '' then raise exception 'MEMORY_REPLACE_REJECTED: replacement target is required'; end if;
  if p_scope not in ('PRIVATE','GENERAL') or p_visibility not in ('OWNER_ONLY','SHARED') then raise exception 'MEMORY_REPLACE_REJECTED: invalid scope or visibility'; end if;

  select count(*), min(memory_id) into v_match_count, v_old
  from public.memories
  where sh_id = p_sh_id
    and lifecycle in ('CANDIDATE','ACTIVE')
    and superseded_by is null
    and content ilike '%' || btrim(p_old_pattern) || '%';
  if v_match_count = 0 then raise exception 'MEMORY_REPLACE_REJECTED: replacement target not found'; end if;
  if v_match_count > 1 then raise exception 'MEMORY_REPLACE_REJECTED: replacement target is ambiguous'; end if;

  insert into public.memories(sh_id,memory_type,content,source,scope,visibility,lifecycle,occurrence_count)
  values(p_sh_id,'LONG_TERM',btrim(p_new_content),coalesce(nullif(btrim(p_source),''),'runtime:p5a:explicit_user_request'),p_scope,p_visibility,'CANDIDATE',1)
  returning memory_id into v_new;

  update public.memories
     set lifecycle = 'UPDATED', superseded_by = v_new, updated_at = now()
   where memory_id = v_old;

  perform public.runtime_record_journey_event(
    p_sh_id,
    'MEMORY',
    now(),
    'CONTINUOUS',
    null,
    jsonb_build_object('memory_id',v_new,'content',btrim(p_new_content),'supersedes_memory_id',v_old,'acquisition','EXPLICIT_USER_REQUEST'),
    coalesce(nullif(btrim(p_source),''),'runtime:p5a:explicit_user_request')
  );
  return v_new;
end;
$$;

create or replace function public.runtime_record_memory_with_journey(
  p_sh_id uuid,
  p_content text,
  p_memory_type text default 'LONG_TERM',
  p_source text default 'runtime_response',
  p_confidence numeric default null,
  p_scope text default 'PRIVATE',
  p_visibility text default 'OWNER_ONLY',
  p_lifecycle text default 'CANDIDATE'
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare v_memory_id uuid; v_account_id uuid;
begin
  if auth.uid() is null then raise exception 'MEMORY_REJECTED: authentication required'; end if;
  select s.account_id into v_account_id from public.sh_instances s where s.sh_id=p_sh_id and s.account_id=public.current_account_id() and s.status <> 'deactivated';
  if v_account_id is null then raise exception 'MEMORY_REJECTED: SH not owned by current active account'; end if;
  if p_content is null or btrim(p_content)='' then raise exception 'MEMORY_REJECTED: content is required'; end if;
  if p_memory_type not in ('SHORT_TERM','LONG_TERM') then raise exception 'MEMORY_REJECTED: invalid memory_type'; end if;
  if p_scope not in ('PRIVATE','GENERAL') then raise exception 'MEMORY_REJECTED: invalid scope'; end if;
  if p_visibility not in ('OWNER_ONLY','SHARED') then raise exception 'MEMORY_REJECTED: invalid visibility'; end if;
  if p_lifecycle not in ('CANDIDATE','ACTIVE') then raise exception 'MEMORY_REJECTED: invalid lifecycle'; end if;
  if p_confidence is not null and (p_confidence<0 or p_confidence>1) then raise exception 'MEMORY_REJECTED: invalid confidence'; end if;
  select memory_id into v_memory_id from public.memories where sh_id=p_sh_id and content=btrim(p_content) and lifecycle in ('CANDIDATE','ACTIVE','UPDATED') order by updated_at desc limit 1 for update;
  if v_memory_id is not null then
    update public.memories set occurrence_count=occurrence_count+1,updated_at=now(),confidence=coalesce(p_confidence,confidence),source=coalesce(nullif(p_source,''),source),memory_type=p_memory_type,scope=p_scope,visibility=p_visibility where memory_id=v_memory_id;
  else
    insert into public.memories(sh_id,memory_type,content,source,confidence,scope,visibility,lifecycle,occurrence_count) values(p_sh_id,p_memory_type,btrim(p_content),p_source,p_confidence,p_scope,p_visibility,p_lifecycle,1) returning memory_id into v_memory_id;
  end if;
  perform public.runtime_record_journey_event(p_sh_id,'MEMORY',now(),'CONTINUOUS',null,jsonb_build_object('memory_id',v_memory_id,'content',btrim(p_content),'memory_type',p_memory_type,'scope',p_scope,'visibility',p_visibility,'lifecycle',p_lifecycle,'acquisition','MODEL_OR_EXPLICIT_CANDIDATE'),coalesce(nullif(btrim(p_source),''),'runtime:p4d:memory_candidate'));
  return v_memory_id;
end;
$$;

create or replace function public.runtime_record_knowledge_with_journey(
  p_sh_id uuid,
  p_content text,
  p_source text,
  p_origin text,
  p_provenance jsonb default '{}',
  p_scope text default 'PRIVATE',
  p_visibility text default 'OWNER_ONLY',
  p_confidence numeric default null
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare v_id uuid; v_account_id uuid;
begin
  if auth.uid() is null then raise exception 'KNOWLEDGE_REJECTED: authentication required'; end if;
  select s.account_id into v_account_id from public.sh_instances s where s.sh_id=p_sh_id and s.account_id=public.current_account_id() and s.status <> 'deactivated';
  if v_account_id is null then raise exception 'KNOWLEDGE_REJECTED: SH not owned by current active account'; end if;
  if p_content is null or btrim(p_content)='' then raise exception 'KNOWLEDGE_REJECTED: content is required'; end if;
  if p_source is null or btrim(p_source)='' then raise exception 'KNOWLEDGE_REJECTED: source is required'; end if;
  if p_origin not in ('MEMORY','EXPLICIT_TEACHING','EXTERNAL_REFERENCE') then raise exception 'KNOWLEDGE_REJECTED: invalid origin'; end if;
  if p_scope not in ('PRIVATE','GENERAL') then raise exception 'KNOWLEDGE_REJECTED: invalid scope'; end if;
  if p_visibility not in ('OWNER_ONLY','SHARED') then raise exception 'KNOWLEDGE_REJECTED: invalid visibility'; end if;
  if p_scope='GENERAL' and p_visibility <> 'SHARED' then raise exception 'KNOWLEDGE_REVIEW_REQUIRED: GENERAL scope requires SHARED visibility'; end if;
  if p_confidence is not null and (p_confidence<0 or p_confidence>1) then raise exception 'KNOWLEDGE_REJECTED: invalid confidence'; end if;
  select knowledge_id into v_id from public.knowledge where sh_id=p_sh_id and content=btrim(p_content) and lifecycle='CANDIDATE' order by updated_at desc limit 1 for update;
  if v_id is not null then
    update public.knowledge set confidence=coalesce(p_confidence,confidence),provenance=coalesce(provenance,'{}')||coalesce(p_provenance,'{}'),updated_at=now() where knowledge_id=v_id;
  else
    insert into public.knowledge(content,knowledge_class,scope,visibility,source,provenance,confidence,lifecycle,sh_id) values(btrim(p_content),case p_origin when 'EXPLICIT_TEACHING' then 'LEARNED' when 'EXTERNAL_REFERENCE' then 'IMPORTED' else 'TEMPORARY' end,p_scope,p_visibility,btrim(p_source),coalesce(p_provenance,'{}')||jsonb_build_object('origin',p_origin,'acquisition','runtime:p4d:knowledge_candidate'),p_confidence,'CANDIDATE',case when p_scope='PRIVATE' then p_sh_id else null end) returning knowledge_id into v_id;
  end if;
  perform public.runtime_record_journey_event(p_sh_id,'LEARNING',now(),'CONTINUOUS',null,jsonb_build_object('knowledge_id',v_id,'content',btrim(p_content),'source',btrim(p_source),'origin',p_origin,'scope',p_scope,'visibility',p_visibility,'acquisition','MODEL_OR_EXPLICIT_CANDIDATE'),btrim(p_source));
  return v_id;
end;
$$;

grant execute on function public.runtime_replace_memory(uuid,text,text,text,text,text) to authenticated;
grant execute on function public.runtime_record_memory_with_journey(uuid,text,text,text,numeric,text,text,text) to authenticated;
grant execute on function public.runtime_record_knowledge_with_journey(uuid,text,text,text,jsonb,text,text,numeric) to authenticated;
revoke execute on function public.runtime_replace_memory(uuid,text,text,text,text,text) from anon;
revoke execute on function public.runtime_record_memory_with_journey(uuid,text,text,text,numeric,text,text,text) from anon;
revoke execute on function public.runtime_record_knowledge_with_journey(uuid,text,text,text,jsonb,text,text,numeric) from anon;
revoke execute on function public.runtime_delete_journey_event(uuid) from anon;
