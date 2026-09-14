-- SECOND HEAD — succession transfer integrity
-- Reconciled after Supabase DEV application.
-- Ensures selected succession records preserve transfer policy and provenance,
-- and that the canonical transfer-policy validator is enforced before mutation.

CREATE OR REPLACE FUNCTION public.runtime_execute_succession_unchecked(p_succession_id uuid)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
declare
  v_rule public.succession_rules%rowtype;
  v_source public.sh_instances%rowtype;
  v_target public.sh_instances%rowtype;
  v_event uuid;
  v_scope jsonb;
  v_memory_count integer := 0;
  v_knowledge_count integer := 0;
  v_experience_count integer := 0;
  v_journey_count integer := 0;
  v_requested integer := 0;
  v_matched integer := 0;
  v_now timestamptz := now();
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
  v_scope := coalesce(v_rule.scope,'{}'::jsonb);
  if coalesce(v_scope->'reference_ids','[]'::jsonb) <> '[]'::jsonb or coalesce(v_scope->'value_ids','[]'::jsonb) <> '[]'::jsonb or coalesce(v_scope->'history_ids','[]'::jsonb) <> '[]'::jsonb then raise exception 'SUCCESSION_REJECTED: reference/value/history source domains are not persistently represented'; end if;
  if coalesce(jsonb_array_length(coalesce(v_scope->'memory_ids','[]'::jsonb)),0)+coalesce(jsonb_array_length(coalesce(v_scope->'knowledge_ids','[]'::jsonb)),0)+coalesce(jsonb_array_length(coalesce(v_scope->'experience_ids','[]'::jsonb)),0)+coalesce(jsonb_array_length(coalesce(v_scope->'journey_event_ids','[]'::jsonb)),0)=0 then raise exception 'SUCCESSION_REJECTED: explicit selection required'; end if;

  -- Canonical transfer-policy authority must pass before any source mutation.
  perform public.runtime_validate_selected_transfer_scope(v_source.sh_id,v_scope,'SUCCESSION');

  select count(*) into v_requested from (select distinct value::uuid from jsonb_array_elements_text(coalesce(v_scope->'memory_ids','[]'::jsonb))) x;
  select count(*) into v_matched from public.memories m where m.sh_id=v_source.sh_id and m.memory_id=any(array(select distinct value::uuid from jsonb_array_elements_text(coalesce(v_scope->'memory_ids','[]'::jsonb))));
  if v_requested<>v_matched then raise exception 'SUCCESSION_REJECTED: selected memory is not owned by source SH'; end if;
  select count(*) into v_requested from (select distinct value::uuid from jsonb_array_elements_text(coalesce(v_scope->'knowledge_ids','[]'::jsonb))) x;
  select count(*) into v_matched from public.knowledge k where k.sh_id=v_source.sh_id and k.knowledge_id=any(array(select distinct value::uuid from jsonb_array_elements_text(coalesce(v_scope->'knowledge_ids','[]'::jsonb))));
  if v_requested<>v_matched then raise exception 'SUCCESSION_REJECTED: selected knowledge is not owned by source SH'; end if;
  select count(*) into v_requested from (select distinct value::uuid from jsonb_array_elements_text(coalesce(v_scope->'experience_ids','[]'::jsonb))) x;
  select count(*) into v_matched from public.experiences e where e.sh_id=v_source.sh_id and e.experience_id=any(array(select distinct value::uuid from jsonb_array_elements_text(coalesce(v_scope->'experience_ids','[]'::jsonb))));
  if v_requested<>v_matched then raise exception 'SUCCESSION_REJECTED: selected experience is not owned by source SH'; end if;

  insert into public.memories(sh_id,memory_type,content,source,confidence,scope,visibility,transfer_policy,lifecycle,occurrence_count,created_at,updated_at,superseded_by,provenance)
  select v_target.sh_id,m.memory_type,m.content,m.source,m.confidence,m.scope,m.visibility,m.transfer_policy,case when m.lifecycle='CANDIDATE' then 'ACTIVE' else m.lifecycle end,m.occurrence_count,v_now,v_now,null,
    jsonb_build_object('succession_origin',jsonb_build_object('source_sh_id',v_source.sh_id,'succession_id',v_rule.succession_id,'transferred_at',v_now),'original_provenance',coalesce(m.provenance,'{}'::jsonb))
  from public.memories m where m.sh_id=v_source.sh_id and m.memory_id=any(array(select distinct value::uuid from jsonb_array_elements_text(coalesce(v_scope->'memory_ids','[]'::jsonb))));
  get diagnostics v_memory_count=row_count;

  insert into public.knowledge(content,knowledge_class,scope,visibility,transfer_policy,source,provenance,confidence,version,lifecycle,superseded_by,created_at,updated_at,sh_id)
  select k.content,k.knowledge_class,k.scope,k.visibility,k.transfer_policy,k.source,
    jsonb_build_object('succession_origin',jsonb_build_object('source_sh_id',v_source.sh_id,'succession_id',v_rule.succession_id,'transferred_at',v_now),'original_provenance',coalesce(k.provenance,'{}'::jsonb)),
    k.confidence,k.version,case when k.lifecycle='CANDIDATE' then 'ACTIVE' else k.lifecycle end,null,v_now,v_now,v_target.sh_id
  from public.knowledge k where k.sh_id=v_source.sh_id and k.knowledge_id=any(array(select distinct value::uuid from jsonb_array_elements_text(coalesce(v_scope->'knowledge_ids','[]'::jsonb))));
  get diagnostics v_knowledge_count=row_count;

  insert into public.experiences(sh_id,account_id,experience_type,content,scope,visibility,transfer_policy,source_ref,provenance,lifecycle,occurred_at,created_at,updated_at)
  select v_target.sh_id,v_target.account_id,e.experience_type,e.content,e.scope,e.visibility,e.transfer_policy,e.source_ref,
    jsonb_build_object('succession_origin',jsonb_build_object('source_sh_id',v_source.sh_id,'succession_id',v_rule.succession_id,'transferred_at',v_now),'original_provenance',coalesce(e.provenance,'{}'::jsonb)),
    e.lifecycle,e.occurred_at,v_now,v_now
  from public.experiences e where e.sh_id=v_source.sh_id and e.experience_id=any(array(select distinct value::uuid from jsonb_array_elements_text(coalesce(v_scope->'experience_ids','[]'::jsonb))));
  get diagnostics v_experience_count=row_count;

  if coalesce(jsonb_array_length(coalesce(v_scope->'journey_event_ids','[]'::jsonb)),0)>0 then v_journey_count:=public.runtime_transfer_selected_journey_events('SUCCESSION',v_source.sh_id,v_target.sh_id,array(select distinct value::uuid from jsonb_array_elements_text(v_scope->'journey_event_ids'))); end if;

  insert into public.succession_events(succession_id,source_sh_id,target_account_id,target_sh_id,scope,transferred_counts,provenance)
  values(v_rule.succession_id,v_source.sh_id,v_rule.successor_account_id,v_target.sh_id,v_scope,jsonb_build_object('memory',v_memory_count,'knowledge',v_knowledge_count,'experience',v_experience_count,'journey',v_journey_count),jsonb_build_object('source','runtime_execute_succession','source_sh_id',v_source.sh_id,'target_sh_id',v_target.sh_id,'executed_at',v_now)) returning succession_event_id into v_event;

  insert into public.journey_events(sh_id,account_id,event_type,occurred_at,continuity_status,payload,source_ref,visibility,transfer_policy,provenance)
  values(v_source.sh_id,v_source.account_id,'LIFECYCLE',v_now,'CONTINUOUS',jsonb_build_object('state','SUCCESSION_EXECUTED','succession_id',v_rule.succession_id,'target_sh_id',v_target.sh_id,'succession_event_id',v_event,'transferred_counts',jsonb_build_object('memory',v_memory_count,'knowledge',v_knowledge_count,'experience',v_experience_count,'journey',v_journey_count)),'succession_operation:'||v_rule.succession_id::text,'PRIVATE','NON_TRANSFERABLE',jsonb_build_object('source','runtime_execute_succession','succession_id',v_rule.succession_id,'target_sh_id',v_target.sh_id,'succession_event_id',v_event));

  update public.succession_rules set status='CONSUMED' where succession_id=v_rule.succession_id;
  return v_event;
end;
$function$;
