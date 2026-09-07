create or replace function public.runtime_record_inheritance_unchecked(p_authorization_id uuid, p_payload jsonb default '{}'::jsonb, p_provenance jsonb default '{}'::jsonb)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_auth public.inheritance_authorizations%rowtype;
  v_scope jsonb;
  v_id uuid;
  v_memory_count integer := 0;
  v_knowledge_count integer := 0;
  v_experience_count integer := 0;
  v_journey_count integer := 0;
  v_requested integer := 0;
  v_matched integer := 0;
  v_now timestamptz := now();
begin
  if auth.uid() is null then raise exception 'INHERITANCE_REJECTED: authentication required'; end if;
  select * into v_auth from public.inheritance_authorizations where authorization_id=p_authorization_id and status='APPROVED' for update;
  if not found then raise exception 'INHERITANCE_REJECTED: approved authorization required'; end if;
  if v_auth.source_account_id <> public.current_account_id() then raise exception 'INHERITANCE_REJECTED: source owner approval required'; end if;
  v_scope := coalesce(v_auth.scope, '{}'::jsonb);
  if coalesce(v_scope->'reference_ids','[]'::jsonb) <> '[]'::jsonb or coalesce(v_scope->'value_ids','[]'::jsonb) <> '[]'::jsonb or coalesce(v_scope->'history_ids','[]'::jsonb) <> '[]'::jsonb then raise exception 'INHERITANCE_REJECTED: reference/value/history source domains are not persistently represented'; end if;
  if coalesce(jsonb_array_length(coalesce(v_scope->'memory_ids','[]'::jsonb)),0)+coalesce(jsonb_array_length(coalesce(v_scope->'knowledge_ids','[]'::jsonb)),0)+coalesce(jsonb_array_length(coalesce(v_scope->'experience_ids','[]'::jsonb)),0)+coalesce(jsonb_array_length(coalesce(v_scope->'journey_event_ids','[]'::jsonb)),0)=0 then raise exception 'INHERITANCE_REJECTED: explicit selection required'; end if;
  select count(*) into v_requested from (select distinct value::uuid from jsonb_array_elements_text(coalesce(v_scope->'memory_ids','[]'::jsonb))) x;
  select count(*) into v_matched from public.memories m where m.sh_id=v_auth.source_sh_id and m.memory_id=any(array(select distinct value::uuid from jsonb_array_elements_text(coalesce(v_scope->'memory_ids','[]'::jsonb))));
  if v_requested<>v_matched then raise exception 'INHERITANCE_REJECTED: selected memory is not owned by source SH'; end if;
  select count(*) into v_requested from (select distinct value::uuid from jsonb_array_elements_text(coalesce(v_scope->'knowledge_ids','[]'::jsonb))) x;
  select count(*) into v_matched from public.knowledge k where k.sh_id=v_auth.source_sh_id and k.knowledge_id=any(array(select distinct value::uuid from jsonb_array_elements_text(coalesce(v_scope->'knowledge_ids','[]'::jsonb))));
  if v_requested<>v_matched then raise exception 'INHERITANCE_REJECTED: selected knowledge is not owned by source SH'; end if;
  select count(*) into v_requested from (select distinct value::uuid from jsonb_array_elements_text(coalesce(v_scope->'experience_ids','[]'::jsonb))) x;
  select count(*) into v_matched from public.experiences e where e.sh_id=v_auth.source_sh_id and e.experience_id=any(array(select distinct value::uuid from jsonb_array_elements_text(coalesce(v_scope->'experience_ids','[]'::jsonb))));
  if v_requested<>v_matched then raise exception 'INHERITANCE_REJECTED: selected experience is not owned by source SH'; end if;
  insert into public.memories(sh_id,memory_type,content,source,confidence,scope,visibility,lifecycle,occurrence_count,created_at,updated_at,superseded_by)
  select v_auth.target_sh_id,m.memory_type,m.content,m.source,m.confidence,m.scope,m.visibility,case when m.lifecycle='CANDIDATE' then 'ACTIVE' else m.lifecycle end,m.occurrence_count,v_now,v_now,null from public.memories m where m.sh_id=v_auth.source_sh_id and m.memory_id=any(array(select distinct value::uuid from jsonb_array_elements_text(coalesce(v_scope->'memory_ids','[]'::jsonb))));
  get diagnostics v_memory_count = row_count;
  insert into public.knowledge(content,knowledge_class,scope,visibility,source,provenance,confidence,version,lifecycle,superseded_by,created_at,updated_at,sh_id)
  select k.content,k.knowledge_class,k.scope,k.visibility,k.source,jsonb_build_object('inheritance_origin',jsonb_build_object('source_sh_id',v_auth.source_sh_id,'authorization_id',v_auth.authorization_id,'transferred_at',v_now),'original_provenance',k.provenance),k.confidence,k.version,case when k.lifecycle='CANDIDATE' then 'ACTIVE' else k.lifecycle end,null,v_now,v_now,v_auth.target_sh_id from public.knowledge k where k.sh_id=v_auth.source_sh_id and k.knowledge_id=any(array(select distinct value::uuid from jsonb_array_elements_text(coalesce(v_scope->'knowledge_ids','[]'::jsonb))));
  get diagnostics v_knowledge_count = row_count;
  insert into public.experiences(sh_id,account_id,experience_type,content,scope,visibility,source_ref,provenance,lifecycle,occurred_at,created_at,updated_at)
  select v_auth.target_sh_id,v_auth.target_account_id,e.experience_type,e.content,e.scope,e.visibility,e.source_ref,jsonb_build_object('inheritance_origin',jsonb_build_object('source_sh_id',v_auth.source_sh_id,'authorization_id',v_auth.authorization_id,'transferred_at',v_now),'original_provenance',e.provenance),e.lifecycle,e.occurred_at,v_now,v_now from public.experiences e where e.sh_id=v_auth.source_sh_id and e.experience_id=any(array(select distinct value::uuid from jsonb_array_elements_text(coalesce(v_scope->'experience_ids','[]'::jsonb))));
  get diagnostics v_experience_count = row_count;
  if coalesce(jsonb_array_length(coalesce(v_scope->'journey_event_ids','[]'::jsonb)),0)>0 then v_journey_count:=public.runtime_transfer_selected_journey_events('INHERITANCE',v_auth.source_sh_id,v_auth.target_sh_id,array(select distinct value::uuid from jsonb_array_elements_text(v_scope->'journey_event_ids'))); end if;
  insert into public.inheritance_events(authorization_id,source_sh_id,target_sh_id,payload,provenance) values(v_auth.authorization_id,v_auth.source_sh_id,v_auth.target_sh_id,jsonb_build_object('selection',v_scope,'transferred_counts',jsonb_build_object('memory',v_memory_count,'knowledge',v_knowledge_count,'experience',v_experience_count,'journey',v_journey_count),'payload',coalesce(p_payload,'{}'::jsonb)),jsonb_build_object('transfer_operation','INHERITANCE','source_sh_id',v_auth.source_sh_id,'target_sh_id',v_auth.target_sh_id,'authorization_id',v_auth.authorization_id,'transferred_at',v_now,'caller_provenance',coalesce(p_provenance,'{}'::jsonb))) returning inheritance_id into v_id;
  insert into public.journey_events(sh_id,account_id,event_type,occurred_at,continuity_status,payload,source_ref,visibility,transfer_policy,provenance) values(v_auth.source_sh_id,v_auth.source_account_id,'INHERITANCE',v_now,'CONTINUOUS',jsonb_build_object('inheritance_id',v_id,'authorization_id',v_auth.authorization_id,'selection',v_scope),'inheritance_event:'||v_id::text,'PRIVATE','NON_TRANSFERABLE',jsonb_build_object('source','runtime_record_inheritance','inheritance_id',v_id,'target_sh_id',v_auth.target_sh_id));
  update public.inheritance_authorizations set status='CONSUMED' where authorization_id=v_auth.authorization_id and status='APPROVED';
  if not found then raise exception 'INHERITANCE_REJECTED: authorization consumption failed'; end if;
  return v_id;
end;
$$;