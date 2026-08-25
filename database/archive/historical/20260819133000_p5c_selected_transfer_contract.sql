-- SECOND HEAD P5C — selected transfer contract reconciliation
-- Uses existing persistent domains only: Memory, Knowledge, Experience, Journey.
-- Reference / Value / History remain explicit semantic scope keys but have no
-- persistent source-domain representation in the current DEV schema; attempts
-- to transfer them are rejected rather than silently approximated.

create or replace function public.runtime_record_inheritance(
  p_authorization_id uuid,
  p_payload jsonb default '{}'::jsonb,
  p_provenance jsonb default '{}'::jsonb
)
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
  select * into v_auth from public.inheritance_authorizations where authorization_id = p_authorization_id and status = 'APPROVED' for update;
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
  get diagnostics v_memory_count=row_count;

  insert into public.knowledge(content,knowledge_class,scope,visibility,source,provenance,confidence,version,lifecycle,superseded_by,created_at,updated_at,sh_id)
  select k.content,k.knowledge_class,k.scope,k.visibility,k.source,jsonb_build_object('inheritance_origin',jsonb_build_object('source_sh_id',v_auth.source_sh_id,'authorization_id',v_auth.authorization_id,'transferred_at',v_now),'original_provenance',k.provenance),k.confidence,k.version,case when k.lifecycle='CANDIDATE' then 'ACTIVE' else k.lifecycle end,null,v_now,v_now,v_auth.target_sh_id from public.knowledge k where k.sh_id=v_auth.source_sh_id and k.knowledge_id=any(array(select distinct value::uuid from jsonb_array_elements_text(coalesce(v_scope->'knowledge_ids','[]'::jsonb))));
  get diagnostics v_knowledge_count=row_count;

  insert into public.experiences(sh_id,account_id,experience_type,content,scope,visibility,source_ref,provenance,lifecycle,occurred_at,created_at,updated_at)
  select v_auth.target_sh_id,v_auth.target_account_id,e.experience_type,e.content,e.scope,e.visibility,e.source_ref,jsonb_build_object('inheritance_origin',jsonb_build_object('source_sh_id',v_auth.source_sh_id,'authorization_id',v_auth.authorization_id,'transferred_at',v_now),'original_provenance',e.provenance),e.lifecycle,e.occurred_at,v_now,v_now from public.experiences e where e.sh_id=v_auth.source_sh_id and e.experience_id=any(array(select distinct value::uuid from jsonb_array_elements_text(coalesce(v_scope->'experience_ids','[]'::jsonb))));
  get diagnostics v_experience_count=row_count;

  if coalesce(jsonb_array_length(coalesce(v_scope->'journey_event_ids','[]'::jsonb)),0)>0 then v_journey_count:=public.runtime_transfer_selected_journey_events('INHERITANCE',v_auth.source_sh_id,v_auth.target_sh_id,array(select distinct value::uuid from jsonb_array_elements_text(v_scope->'journey_event_ids'))); end if;

  insert into public.inheritance_events(authorization_id,source_sh_id,target_sh_id,payload,provenance)
  values(v_auth.authorization_id,v_auth.source_sh_id,v_auth.target_sh_id,jsonb_build_object('selection',v_scope,'transferred_counts',jsonb_build_object('memory',v_memory_count,'knowledge',v_knowledge_count,'experience',v_experience_count,'journey',v_journey_count),'payload',coalesce(p_payload,'{}'::jsonb)),jsonb_build_object('transfer_operation','INHERITANCE','source_sh_id',v_auth.source_sh_id,'target_sh_id',v_auth.target_sh_id,'authorization_id',v_auth.authorization_id,'transferred_at',v_now,'caller_provenance',coalesce(p_provenance,'{}'::jsonb))) returning inheritance_id into v_id;

  insert into public.journey_events(sh_id,account_id,event_type,occurred_at,continuity_status,payload,source_ref,visibility,transfer_policy,provenance)
  values(v_auth.source_sh_id,v_auth.source_account_id,'INHERITANCE',v_now,'CONTINUOUS',jsonb_build_object('inheritance_id',v_id,'authorization_id',v_auth.authorization_id,'selection',v_scope),'inheritance_event:'||v_id::text,'PRIVATE','NON_TRANSFERABLE',jsonb_build_object('source','runtime_record_inheritance','inheritance_id',v_id,'target_sh_id',v_auth.target_sh_id));
  return v_id;
end;
$$;
revoke all on function public.runtime_record_inheritance(uuid,jsonb,jsonb) from public;
grant execute on function public.runtime_record_inheritance(uuid,jsonb,jsonb) to authenticated;

create or replace function public.runtime_execute_succession(p_succession_id uuid)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_rule public.succession_rules%rowtype; v_source public.sh_instances%rowtype; v_target public.sh_instances%rowtype; v_event uuid; v_scope jsonb; v_memory_count integer:=0; v_knowledge_count integer:=0; v_experience_count integer:=0; v_journey_count integer:=0; v_requested integer:=0; v_matched integer:=0; v_now timestamptz:=now();
begin
  if auth.uid() is null then raise exception 'SUCCESSION_REJECTED: authentication required'; end if;
  select * into v_rule from public.succession_rules where succession_id=p_succession_id and status='ACTIVE' for update;
  if not found then raise exception 'SUCCESSION_REJECTED: active succession rule required'; end if;
  select * into v_source from public.sh_instances where sh_id=v_rule.source_sh_id;
  if not found then raise exception 'SUCCESSION_REJECTED: source SH not found'; end if;
  if v_source.status <> 'deactivated' then raise exception 'SUCCESSION_REJECTED: source SH must be end-of-life'; end if;
  if v_rule.successor_account_id <> public.current_account_id() then raise exception 'SUCCESSION_REJECTED: successor account required'; end if;
  select * into v_target from public.sh_instances where account_id=v_rule.successor_account_id and status <> 'deactivated' and is_primary=true order by created_at asc limit 1;
  if not found then raise exception 'SUCCESSION_REJECTED: active successor PRIMARY SH required'; end if;
  v_scope:=coalesce(v_rule.scope,'{}'::jsonb);
  if coalesce(v_scope->'reference_ids','[]'::jsonb) <> '[]'::jsonb or coalesce(v_scope->'value_ids','[]'::jsonb) <> '[]'::jsonb or coalesce(v_scope->'history_ids','[]'::jsonb) <> '[]'::jsonb then raise exception 'SUCCESSION_REJECTED: reference/value/history source domains are not persistently represented'; end if;
  if coalesce(jsonb_array_length(coalesce(v_scope->'memory_ids','[]'::jsonb)),0)+coalesce(jsonb_array_length(coalesce(v_scope->'knowledge_ids','[]'::jsonb)),0)+coalesce(jsonb_array_length(coalesce(v_scope->'experience_ids','[]'::jsonb)),0)+coalesce(jsonb_array_length(coalesce(v_scope->'journey_event_ids','[]'::jsonb)),0)=0 then raise exception 'SUCCESSION_REJECTED: explicit selection required'; end if;

  select count(*) into v_requested from (select distinct value::uuid from jsonb_array_elements_text(coalesce(v_scope->'memory_ids','[]'::jsonb))) x;
  select count(*) into v_matched from public.memories m where m.sh_id=v_source.sh_id and m.memory_id=any(array(select distinct value::uuid from jsonb_array_elements_text(coalesce(v_scope->'memory_ids','[]'::jsonb))));
  if v_requested<>v_matched then raise exception 'SUCCESSION_REJECTED: selected memory is not owned by source SH'; end if;
  select count(*) into v_requested from (select distinct value::uuid from jsonb_array_elements_text(coalesce(v_scope->'knowledge_ids','[]'::jsonb))) x;
  select count(*) into v_matched from public.knowledge k where k.sh_id=v_source.sh_id and k.knowledge_id=any(array(select distinct value::uuid from jsonb_array_elements_text(coalesce(v_scope->'knowledge_ids','[]'::jsonb))));
  if v_requested<>v_matched then raise exception 'SUCCESSION_REJECTED: selected knowledge is not owned by source SH'; end if;
  select count(*) into v_requested from (select distinct value::uuid from jsonb_array_elements_text(coalesce(v_scope->'experience_ids','[]'::jsonb))) x;
  select count(*) into v_matched from public.experiences e where e.sh_id=v_source.sh_id and e.experience_id=any(array(select distinct value::uuid from jsonb_array_elements_text(coalesce(v_scope->'experience_ids','[]'::jsonb))));
  if v_requested<>v_matched then raise exception 'SUCCESSION_REJECTED: selected experience is not owned by source SH'; end if;

  insert into public.memories(sh_id,memory_type,content,source,confidence,scope,visibility,lifecycle,occurrence_count,created_at,updated_at,superseded_by)
  select v_target.sh_id,m.memory_type,m.content,m.source,m.confidence,m.scope,m.visibility,case when m.lifecycle='CANDIDATE' then 'ACTIVE' else m.lifecycle end,m.occurrence_count,v_now,v_now,null from public.memories m where m.sh_id=v_source.sh_id and m.memory_id=any(array(select distinct value::uuid from jsonb_array_elements_text(coalesce(v_scope->'memory_ids','[]'::jsonb))));
  get diagnostics v_memory_count=row_count;
  insert into public.knowledge(content,knowledge_class,scope,visibility,source,provenance,confidence,version,lifecycle,superseded_by,created_at,updated_at,sh_id)
  select k.content,k.knowledge_class,k.scope,k.visibility,k.source,jsonb_build_object('succession_origin',jsonb_build_object('source_sh_id',v_source.sh_id,'succession_id',v_rule.succession_id,'transferred_at',v_now),'original_provenance',k.provenance),k.confidence,k.version,case when k.lifecycle='CANDIDATE' then 'ACTIVE' else k.lifecycle end,null,v_now,v_now,v_target.sh_id from public.knowledge k where k.sh_id=v_source.sh_id and k.knowledge_id=any(array(select distinct value::uuid from jsonb_array_elements_text(coalesce(v_scope->'knowledge_ids','[]'::jsonb))));
  get diagnostics v_knowledge_count=row_count;
  insert into public.experiences(sh_id,account_id,experience_type,content,scope,visibility,source_ref,provenance,lifecycle,occurred_at,created_at,updated_at)
  select v_target.sh_id,v_target.account_id,e.experience_type,e.content,e.scope,e.visibility,e.source_ref,jsonb_build_object('succession_origin',jsonb_build_object('source_sh_id',v_source.sh_id,'succession_id',v_rule.succession_id,'transferred_at',v_now),'original_provenance',e.provenance),e.lifecycle,e.occurred_at,v_now,v_now from public.experiences e where e.sh_id=v_source.sh_id and e.experience_id=any(array(select distinct value::uuid from jsonb_array_elements_text(coalesce(v_scope->'experience_ids','[]'::jsonb))));
  get diagnostics v_experience_count=row_count;
  if coalesce(jsonb_array_length(coalesce(v_scope->'journey_event_ids','[]'::jsonb)),0)>0 then v_journey_count:=public.runtime_transfer_selected_journey_events('SUCCESSION',v_source.sh_id,v_target.sh_id,array(select distinct value::uuid from jsonb_array_elements_text(v_scope->'journey_event_ids'))); end if;

  insert into public.succession_events(succession_id,source_sh_id,target_account_id,target_sh_id,scope,transferred_counts,provenance)
  values(v_rule.succession_id,v_source.sh_id,v_rule.successor_account_id,v_target.sh_id,v_scope,jsonb_build_object('memory',v_memory_count,'knowledge',v_knowledge_count,'experience',v_experience_count,'journey',v_journey_count),jsonb_build_object('source','runtime_execute_succession','source_sh_id',v_source.sh_id,'target_sh_id',v_target.sh_id,'executed_at',v_now)) returning succession_event_id into v_event;
  update public.succession_rules set status='CONSUMED' where succession_id=v_rule.succession_id;
  return v_event;
end;
$$;
revoke all on function public.runtime_execute_succession(uuid) from public;
grant execute on function public.runtime_execute_succession(uuid) to authenticated;

create or replace function public.runtime_preserve_selected_transfer_as_legacy(p_source_sh_id uuid,p_scope jsonb)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare v_legacy_id uuid; v_payload jsonb:='{}'::jsonb; v_now timestamptz:=now();
begin
  if auth.uid() is null then raise exception 'LEGACY_REJECTED: authentication required'; end if;
  if not exists(select 1 from public.sh_instances s where s.sh_id=p_source_sh_id and s.account_id=public.current_account_id()) then raise exception 'LEGACY_REJECTED: source owner required'; end if;
  if p_scope is null then raise exception 'LEGACY_REJECTED: explicit selection required'; end if;
  if coalesce(p_scope->'reference_ids','[]'::jsonb) <> '[]'::jsonb or coalesce(p_scope->'value_ids','[]'::jsonb) <> '[]'::jsonb or coalesce(p_scope->'history_ids','[]'::jsonb) <> '[]'::jsonb then raise exception 'LEGACY_REJECTED: reference/value/history source domains are not persistently represented'; end if;
  if coalesce(jsonb_array_length(coalesce(p_scope->'memory_ids','[]'::jsonb)),0)+coalesce(jsonb_array_length(coalesce(p_scope->'knowledge_ids','[]'::jsonb)),0)+coalesce(jsonb_array_length(coalesce(p_scope->'experience_ids','[]'::jsonb)),0)+coalesce(jsonb_array_length(coalesce(p_scope->'journey_event_ids','[]'::jsonb)),0)=0 then raise exception 'LEGACY_REJECTED: explicit selection required'; end if;
  if coalesce(jsonb_array_length(coalesce(p_scope->'memory_ids','[]'::jsonb)),0)>0 then v_payload:=v_payload||jsonb_build_object('memory',coalesce((select jsonb_agg(to_jsonb(m)) from public.memories m where m.sh_id=p_source_sh_id and m.memory_id=any(array(select distinct value::uuid from jsonb_array_elements_text(p_scope->'memory_ids')))),'[]'::jsonb)); end if;
  if coalesce(jsonb_array_length(coalesce(p_scope->'knowledge_ids','[]'::jsonb)),0)>0 then v_payload:=v_payload||jsonb_build_object('knowledge',coalesce((select jsonb_agg(to_jsonb(k)) from public.knowledge k where k.sh_id=p_source_sh_id and k.knowledge_id=any(array(select distinct value::uuid from jsonb_array_elements_text(p_scope->'knowledge_ids')))),'[]'::jsonb)); end if;
  if coalesce(jsonb_array_length(coalesce(p_scope->'experience_ids','[]'::jsonb)),0)>0 then v_payload:=v_payload||jsonb_build_object('experience',coalesce((select jsonb_agg(to_jsonb(e)) from public.experiences e where e.sh_id=p_source_sh_id and e.experience_id=any(array(select distinct value::uuid from jsonb_array_elements_text(p_scope->'experience_ids')))),'[]'::jsonb)); end if;
  if coalesce(jsonb_array_length(coalesce(p_scope->'journey_event_ids','[]'::jsonb)),0)>0 then
    if exists(select 1 from public.journey_events j where j.event_id=any(array(select distinct value::uuid from jsonb_array_elements_text(p_scope->'journey_event_ids'))) and (j.sh_id<>p_source_sh_id or j.visibility='PRIVATE' or j.transfer_policy='NON_TRANSFERABLE')) then raise exception 'LEGACY_REJECTED: selected Journey contains private or non-transferable event'; end if;
    v_payload:=v_payload||jsonb_build_object('journey',coalesce((select jsonb_agg(to_jsonb(j)) from public.journey_events j where j.sh_id=p_source_sh_id and j.event_id=any(array(select distinct value::uuid from jsonb_array_elements_text(p_scope->'journey_event_ids')))),'[]'::jsonb));
  end if;
  insert into public.legacy_records(source_sh_id,legacy_type,payload,provenance) values(p_source_sh_id,'HISTORY',v_payload,jsonb_build_object('legacy_operation','SELECTED_TRANSFER_PRESERVATION','source_sh_id',p_source_sh_id,'selection',p_scope,'preserved_at',v_now)) returning legacy_id into v_legacy_id;
  return v_legacy_id;
end;
$$;
revoke all on function public.runtime_preserve_selected_transfer_as_legacy(uuid,jsonb) from public, anon;
grant execute on function public.runtime_preserve_selected_transfer_as_legacy(uuid,jsonb) to authenticated;
