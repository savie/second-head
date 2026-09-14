-- SECOND HEAD — lifecycle cross-domain Journey projections
-- Reconciled after Supabase DEV application.

CREATE OR REPLACE FUNCTION public.runtime_create_clone(p_agreement_id uuid, p_clone_name text DEFAULT NULL::text)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
declare
  v_agreement public.clone_agreements%rowtype;
  v_target_account_id uuid;
  v_target_email text;
  v_source_sh public.sh_instances%rowtype;
  v_clone_sh_id uuid;
  v_now timestamptz:=now();
begin
  if auth.uid() is null then raise exception 'CLONE_REJECTED: authentication required'; end if;
  v_target_account_id:=public.current_account_id();
  if v_target_account_id is null then raise exception 'CLONE_REJECTED: authenticated account not resolved'; end if;
  if not exists (select 1 from public.accounts a where a.account_id=v_target_account_id and a.status<>'deactivated') then raise exception 'CLONE_REJECTED: target account is deactivated or unavailable'; end if;
  select * into v_agreement from public.clone_agreements where agreement_id=p_agreement_id and status='APPROVED' for update;
  if not found then raise exception 'CLONE_REJECTED: approved agreement required'; end if;
  select * into v_source_sh from public.sh_instances where sh_id=v_agreement.source_sh_id and account_id=v_agreement.source_account_id and status<>'deactivated';
  if not found then raise exception 'CLONE_REJECTED: source SH ownership boundary failed'; end if;
  if v_agreement.source_account_id=v_target_account_id then raise exception 'CLONE_REJECTED: source and target accounts must differ'; end if;
  select lower(trim(email)) into v_target_email from public.accounts where account_id=v_target_account_id;
  if v_target_email is null or v_target_email<>lower(trim(v_agreement.target_email)) then raise exception 'CLONE_REJECTED: authenticated recipient does not match intended email'; end if;
  if v_agreement.target_account_id is not null and v_agreement.target_account_id<>v_target_account_id then raise exception 'CLONE_REJECTED: agreement is already linked to another target account'; end if;
  if exists(select 1 from public.sh_instances where account_id=v_target_account_id) then raise exception 'CLONE_REJECTED: target account already has an SH'; end if;
  v_clone_sh_id:=gen_random_uuid();
  insert into public.sh_instances(sh_id,account_id,sh_type,is_primary,canonical_name,creator_ref,status,metadata,version,created_at,updated_at) values(v_clone_sh_id,v_target_account_id,'PRIMARY',true,coalesce(nullif(trim(p_clone_name),''),coalesce(v_source_sh.canonical_name,'SH')||' Clone'),'clone:'||v_agreement.source_sh_id::text,'created',jsonb_build_object('origin','CLONE','source_sh_id',v_agreement.source_sh_id,'source_account_id',v_agreement.source_account_id,'agreement_id',v_agreement.agreement_id,'initial_state_semantics','CONTEXT_REFERENCE_TRAITS','privacy_boundary','GENERAL_SHARED_ONLY','transfer_policy_exclusion','NON_TRANSFERABLE'),1,v_now,v_now);
  insert into public.sh_ownership(ownership_id,account_id,sh_id,role,granted_at,evidence_ref,created_at) values(gen_random_uuid(),v_target_account_id,v_clone_sh_id,'OWNER',v_now,'clone_agreement:'||v_agreement.agreement_id::text,v_now);
  insert into public.sh_clones(clone_sh_id,source_sh_id,agreement_id,status,created_at) values(v_clone_sh_id,v_agreement.source_sh_id,v_agreement.agreement_id,'ACTIVE',v_now);
  insert into public.memories(sh_id,memory_type,content,source,confidence,scope,visibility,transfer_policy,lifecycle,occurrence_count,created_at,updated_at,superseded_by,provenance) select v_clone_sh_id,m.memory_type,m.content,m.source,m.confidence,m.scope,m.visibility,m.transfer_policy,case when m.lifecycle='CANDIDATE' then 'ACTIVE' else m.lifecycle end,m.occurrence_count,v_now,v_now,null,jsonb_build_object('clone_origin',jsonb_build_object('source_sh_id',v_agreement.source_sh_id,'source_account_id',v_agreement.source_account_id,'agreement_id',v_agreement.agreement_id,'cloned_at',v_now),'original_provenance',coalesce(m.provenance,'{}'::jsonb)) from public.memories m where m.sh_id=v_agreement.source_sh_id and m.scope='GENERAL' and m.visibility='SHARED' and m.transfer_policy<>'NON_TRANSFERABLE';
  insert into public.knowledge(content,knowledge_class,scope,visibility,transfer_policy,source,provenance,confidence,version,lifecycle,superseded_by,created_at,updated_at,sh_id) select k.content,k.knowledge_class,k.scope,k.visibility,k.transfer_policy,k.source,jsonb_build_object('clone_origin',jsonb_build_object('source_sh_id',v_agreement.source_sh_id,'source_account_id',v_agreement.source_account_id,'agreement_id',v_agreement.agreement_id,'cloned_at',v_now),'original_provenance',k.provenance),k.confidence,1,case when k.lifecycle='CANDIDATE' then 'ACTIVE' else k.lifecycle end,null,v_now,v_now,v_clone_sh_id from public.knowledge k where k.sh_id=v_agreement.source_sh_id and k.scope='GENERAL' and k.visibility='SHARED' and k.transfer_policy<>'NON_TRANSFERABLE';
  insert into public.experiences(sh_id,account_id,experience_type,content,scope,visibility,transfer_policy,source_ref,provenance,lifecycle,occurred_at,created_at,updated_at) select v_clone_sh_id,v_target_account_id,e.experience_type,e.content,e.scope,e.visibility,e.transfer_policy,e.source_ref,jsonb_build_object('clone_origin',jsonb_build_object('source_sh_id',v_agreement.source_sh_id,'source_account_id',v_agreement.source_account_id,'agreement_id',v_agreement.agreement_id,'cloned_at',v_now),'original_provenance',e.provenance),e.lifecycle,e.occurred_at,v_now,v_now from public.experiences e where e.sh_id=v_agreement.source_sh_id and e.scope='GENERAL' and e.visibility='SHARED' and e.transfer_policy<>'NON_TRANSFERABLE';
  update public.clone_agreements set target_account_id=v_target_account_id where agreement_id=v_agreement.agreement_id;
  insert into public.journey_events(sh_id,account_id,event_type,occurred_at,continuity_status,payload,source_ref,visibility,transfer_policy,provenance) values(v_source_sh.sh_id,v_agreement.source_account_id,'LIFECYCLE',v_now,'CONTINUOUS',jsonb_build_object('state','CLONED','agreement_id',v_agreement.agreement_id,'clone_sh_id',v_clone_sh_id,'target_account_id',v_target_account_id),'clone_operation:'||v_agreement.agreement_id::text,'PRIVATE','NON_TRANSFERABLE',jsonb_build_object('source','runtime_create_clone','agreement_id',v_agreement.agreement_id,'clone_sh_id',v_clone_sh_id,'target_account_id',v_target_account_id));
  insert into public.journey_events(sh_id,account_id,event_type,occurred_at,continuity_status,payload,source_ref,visibility,transfer_policy,provenance) values(v_clone_sh_id,v_target_account_id,'LIFECYCLE',v_now,'CONTINUOUS',jsonb_build_object('state','CLONE_CREATED','agreement_id',v_agreement.agreement_id,'source_sh_id',v_source_sh.sh_id),'clone_operation:'||v_agreement.agreement_id::text||':target','PRIVATE','NON_TRANSFERABLE',jsonb_build_object('source','runtime_create_clone','agreement_id',v_agreement.agreement_id,'source_sh_id',v_source_sh.sh_id));
  return v_clone_sh_id;
end;
$function$;

-- Succession execution now projects the completed cross-domain transition into the source Journey.
-- The existing transfer operation continues to project explicitly selected Journey events to the target.
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
  select count(*) into v_requested from (select distinct value::uuid from jsonb_array_elements_text(coalesce(v_scope->'memory_ids','[]'::jsonb))) x;
  select count(*) into v_matched from public.memories m where m.sh_id=v_source.sh_id and m.memory_id=any(array(select distinct value::uuid from jsonb_array_elements_text(coalesce(v_scope->'memory_ids','[]'::jsonb))));
  if v_requested<>v_matched then raise exception 'SUCCESSION_REJECTED: selected memory is not owned by source SH'; end if;
  select count(*) into v_requested from (select distinct value::uuid from jsonb_array_elements_text(coalesce(v_scope->'knowledge_ids','[]'::jsonb))) x;
  select count(*) into v_matched from public.knowledge k where k.sh_id=v_source.sh_id and k.knowledge_id=any(array(select distinct value::uuid from jsonb_array_elements_text(coalesce(v_scope->'knowledge_ids','[]'::jsonb))));
  if v_requested<>v_matched then raise exception 'SUCCESSION_REJECTED: selected knowledge is not owned by source SH'; end if;
  select count(*) into v_requested from (select distinct value::uuid from jsonb_array_elements_text(coalesce(v_scope->'experience_ids','[]'::jsonb))) x;
  select count(*) into v_matched from public.experiences e where e.sh_id=v_source.sh_id and e.experience_id=any(array(select distinct value::uuid from jsonb_array_elements_text(coalesce(v_scope->'experience_ids','[]'::jsonb))));
  if v_requested<>v_matched then raise exception 'SUCCESSION_REJECTED: selected experience is not owned by source SH'; end if;
  insert into public.memories(sh_id,memory_type,content,source,confidence,scope,visibility,lifecycle,occurrence_count,created_at,updated_at,superseded_by) select v_target.sh_id,m.memory_type,m.content,m.source,m.confidence,m.scope,m.visibility,case when m.lifecycle='CANDIDATE' then 'ACTIVE' else m.lifecycle end,m.occurrence_count,v_now,v_now,null from public.memories m where m.sh_id=v_source.sh_id and m.memory_id=any(array(select distinct value::uuid from jsonb_array_elements_text(coalesce(v_scope->'memory_ids','[]'::jsonb))));
  get diagnostics v_memory_count=row_count;
  insert into public.knowledge(content,knowledge_class,scope,visibility,source,provenance,confidence,version,lifecycle,superseded_by,created_at,updated_at,sh_id) select k.content,k.knowledge_class,k.scope,k.visibility,k.source,jsonb_build_object('succession_origin',jsonb_build_object('source_sh_id',v_source.sh_id,'succession_id',v_rule.succession_id,'transferred_at',v_now),'original_provenance',k.provenance),k.confidence,k.version,case when k.lifecycle='CANDIDATE' then 'ACTIVE' else k.lifecycle end,null,v_now,v_now,v_target.sh_id from public.knowledge k where k.sh_id=v_source.sh_id and k.knowledge_id=any(array(select distinct value::uuid from jsonb_array_elements_text(coalesce(v_scope->'knowledge_ids','[]'::jsonb))));
  get diagnostics v_knowledge_count=row_count;
  insert into public.experiences(sh_id,account_id,experience_type,content,scope,visibility,source_ref,provenance,lifecycle,occurred_at,created_at,updated_at) select v_target.sh_id,v_target.account_id,e.experience_type,e.content,e.scope,e.visibility,e.source_ref,jsonb_build_object('succession_origin',jsonb_build_object('source_sh_id',v_source.sh_id,'succession_id',v_rule.succession_id,'transferred_at',v_now),'original_provenance',e.provenance),e.lifecycle,e.occurred_at,v_now,v_now from public.experiences e where e.sh_id=v_source.sh_id and e.experience_id=any(array(select distinct value::uuid from jsonb_array_elements_text(coalesce(v_scope->'experience_ids','[]'::jsonb))));
  get diagnostics v_experience_count=row_count;
  if coalesce(jsonb_array_length(coalesce(v_scope->'journey_event_ids','[]'::jsonb)),0)>0 then v_journey_count:=public.runtime_transfer_selected_journey_events('SUCCESSION',v_source.sh_id,v_target.sh_id,array(select distinct value::uuid from jsonb_array_elements_text(v_scope->'journey_event_ids'))); end if;
  insert into public.succession_events(succession_id,source_sh_id,target_account_id,target_sh_id,scope,transferred_counts,provenance) values(v_rule.succession_id,v_source.sh_id,v_rule.successor_account_id,v_target.sh_id,v_scope,jsonb_build_object('memory',v_memory_count,'knowledge',v_knowledge_count,'experience',v_experience_count,'journey',v_journey_count),jsonb_build_object('source','runtime_execute_succession','source_sh_id',v_source.sh_id,'target_sh_id',v_target.sh_id,'executed_at',v_now)) returning succession_event_id into v_event;
  insert into public.journey_events(sh_id,account_id,event_type,occurred_at,continuity_status,payload,source_ref,visibility,transfer_policy,provenance) values(v_source.sh_id,v_source.account_id,'LIFECYCLE',v_now,'CONTINUOUS',jsonb_build_object('state','SUCCESSION_EXECUTED','succession_id',v_rule.succession_id,'target_sh_id',v_target.sh_id,'succession_event_id',v_event,'transferred_counts',jsonb_build_object('memory',v_memory_count,'knowledge',v_knowledge_count,'experience',v_experience_count,'journey',v_journey_count)),'succession_operation:'||v_rule.succession_id::text,'PRIVATE','NON_TRANSFERABLE',jsonb_build_object('source','runtime_execute_succession','succession_id',v_rule.succession_id,'target_sh_id',v_target.sh_id,'succession_event_id',v_event));
  update public.succession_rules set status='CONSUMED' where succession_id=v_rule.succession_id;
  return v_event;
end;
$function$;
