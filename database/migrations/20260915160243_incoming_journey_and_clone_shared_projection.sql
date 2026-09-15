create or replace function public.runtime_get_journey_context(p_sh_id uuid, p_limit integer default 20)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_account_id uuid;
  v_limit integer;
  v_events jsonb;
begin
  if auth.uid() is null then raise exception 'JOURNEY_CONTEXT_RETRIEVAL_REJECTED: authentication required'; end if;
  v_limit := least(greatest(coalesce(p_limit,20),1),50);
  select s.account_id into v_account_id from public.sh_instances s where s.sh_id=p_sh_id and s.account_id=public.current_account_id() and s.status <> 'deactivated';
  if v_account_id is null then raise exception 'JOURNEY_CONTEXT_RETRIEVAL_REJECTED: SH not owned by current account'; end if;
  with own_events as (
    select j.event_id,j.event_type,j.occurred_at,j.continuity_status,j.gap_code,j.payload,j.source_ref,j.visibility,j.transfer_policy,j.provenance
    from public.journey_events j where j.sh_id=p_sh_id and (j.account_id=v_account_id or j.visibility in ('SHARED','PUBLIC')) order by j.occurred_at desc limit v_limit
  ), incoming_inheritance as (
    select j.event_id,j.event_type,j.occurred_at,'INCOMING_INHERITANCE'::text as continuity_status,j.gap_code,
      j.payload || jsonb_build_object('incoming',true,'authorization_id',ia.authorization_id,'source_sh_id',ia.source_sh_id,'source_account_id',ia.source_account_id) as payload,
      j.source_ref,'SHARED'::text as visibility,'INHERITANCE'::text as transfer_policy,
      coalesce(j.provenance,'{}'::jsonb) || jsonb_build_object('incoming_authorization',ia.authorization_id,'source_sh_id',ia.source_sh_id,'target_sh_id',ia.target_sh_id) as provenance
    from public.inheritance_authorizations ia join public.journey_events j on j.sh_id=ia.source_sh_id and j.visibility='SHARED'
    where ia.target_account_id=v_account_id and ia.target_sh_id=p_sh_id and ia.status='APPROVED'
      and ((j.event_type='MEMORY' and j.payload->>'memory_id' in (select value from jsonb_array_elements_text(coalesce(ia.scope->'memory_ids','[]'::jsonb))))
        or (j.event_type in ('KNOWLEDGE','LEARNING') and j.payload->>'knowledge_id' in (select value from jsonb_array_elements_text(coalesce(ia.scope->'knowledge_ids','[]'::jsonb))))
        or (j.event_type='EXPERIENCE' and j.payload->>'experience_id' in (select value from jsonb_array_elements_text(coalesce(ia.scope->'experience_ids','[]'::jsonb))))
        or j.event_id::text in (select value from jsonb_array_elements_text(coalesce(ia.scope->'journey_event_ids','[]'::jsonb))))
  ), combined as (select * from own_events union all select * from incoming_inheritance)
  select coalesce(jsonb_agg(jsonb_build_object('event_id',c.event_id,'event_type',c.event_type,'occurred_at',c.occurred_at,'continuity_status',c.continuity_status,'gap_code',c.gap_code,'payload',c.payload,'source_ref',c.source_ref,'visibility',coalesce(m.visibility,k.visibility,e.visibility,c.visibility),'transfer_policy',coalesce(m.transfer_policy,k.transfer_policy,e.transfer_policy,c.transfer_policy),'provenance',coalesce(c.provenance,'{}'::jsonb)) order by c.occurred_at desc),'[]'::jsonb) into v_events
  from combined c
  left join public.memories m on upper(c.event_type)='MEMORY' and m.sh_id=c.sh_id and m.memory_id::text=c.payload->>'memory_id'
  left join public.knowledge k on upper(c.event_type) in ('KNOWLEDGE','LEARNING') and k.sh_id=c.sh_id and k.knowledge_id::text=c.payload->>'knowledge_id'
  left join public.experiences e on upper(c.event_type)='EXPERIENCE' and e.sh_id=c.sh_id and e.experience_id::text=c.payload->>'experience_id';
  return jsonb_build_object('events',v_events,'retrieval_limit',v_limit);
end;
$$;

grant execute on function public.runtime_get_journey_context(uuid,integer) to authenticated;
revoke execute on function public.runtime_get_journey_context(uuid,integer) from anon, public;

create or replace function public.runtime_create_clone(p_agreement_id uuid, p_clone_name text default null)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_agreement public.clone_agreements%rowtype; v_target_account_id uuid; v_target_email text; v_source_sh public.sh_instances%rowtype; v_clone_sh_id uuid; v_now timestamptz:=now();
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
  insert into public.memories(sh_id,memory_type,content,source,confidence,scope,visibility,transfer_policy,lifecycle,occurrence_count,created_at,updated_at,superseded_by,provenance)
  select v_clone_sh_id,m.memory_type,m.content,m.source,m.confidence,'GENERAL','SHARED','NON_TRANSFERABLE',case when m.lifecycle='CANDIDATE' then 'ACTIVE' else m.lifecycle end,m.occurrence_count,v_now,v_now,null,jsonb_build_object('clone_origin',jsonb_build_object('source_sh_id',v_agreement.source_sh_id,'source_account_id',v_agreement.source_account_id,'agreement_id',v_agreement.agreement_id,'source_memory_id',m.memory_id,'cloned_at',v_now),'original_provenance',coalesce(m.provenance,'{}'::jsonb)) from public.memories m where m.sh_id=v_agreement.source_sh_id and m.scope='GENERAL' and m.visibility='SHARED';
  insert into public.knowledge(content,knowledge_class,scope,visibility,transfer_policy,source,provenance,confidence,version,lifecycle,superseded_by,created_at,updated_at,sh_id)
  select k.content,k.knowledge_class,'GENERAL','SHARED','NON_TRANSFERABLE',k.source,jsonb_build_object('clone_origin',jsonb_build_object('source_sh_id',v_agreement.source_sh_id,'source_account_id',v_agreement.source_account_id,'agreement_id',v_agreement.agreement_id,'source_knowledge_id',k.knowledge_id,'cloned_at',v_now),'original_provenance',coalesce(k.provenance,'{}'::jsonb)),k.confidence,1,case when k.lifecycle='CANDIDATE' then 'ACTIVE' else k.lifecycle end,null,v_now,v_now,v_clone_sh_id from public.knowledge k where k.sh_id=v_agreement.source_sh_id and k.scope='GENERAL' and k.visibility='SHARED';
  insert into public.experiences(sh_id,account_id,experience_type,content,scope,visibility,transfer_policy,source_ref,provenance,lifecycle,occurred_at,created_at,updated_at)
  select v_clone_sh_id,v_target_account_id,e.experience_type,e.content,'GENERAL','SHARED','NON_TRANSFERABLE',e.source_ref,jsonb_build_object('clone_origin',jsonb_build_object('source_sh_id',v_agreement.source_sh_id,'source_account_id',v_agreement.source_account_id,'agreement_id',v_agreement.agreement_id,'source_experience_id',e.experience_id,'cloned_at',v_now),'original_provenance',coalesce(e.provenance,'{}'::jsonb)),e.lifecycle,e.occurred_at,v_now,v_now from public.experiences e where e.sh_id=v_agreement.source_sh_id and e.scope='GENERAL' and e.visibility='SHARED';
  insert into public.journey_events(sh_id,account_id,event_type,occurred_at,continuity_status,payload,source_ref,visibility,transfer_policy,provenance)
  select v_clone_sh_id,v_target_account_id,'MEMORY',v_now,'CONTINUOUS',jsonb_build_object('memory_id',m.memory_id,'content',m.content,'title','Cloned Memory'),'clone_memory:'||m.memory_id::text,'SHARED','NON_TRANSFERABLE',jsonb_build_object('transfer_operation','CLONE','source_sh_id',v_agreement.source_sh_id,'source_memory_id',(m.provenance->'clone_origin'->>'source_memory_id'),'agreement_id',v_agreement.agreement_id,'cloned_at',v_now) from public.memories m where m.sh_id=v_clone_sh_id;
  insert into public.journey_events(sh_id,account_id,event_type,occurred_at,continuity_status,payload,source_ref,visibility,transfer_policy,provenance)
  select v_clone_sh_id,v_target_account_id,'KNOWLEDGE',v_now,'CONTINUOUS',jsonb_build_object('knowledge_id',k.knowledge_id,'content',k.content,'title','Cloned Knowledge'),'clone_knowledge:'||k.knowledge_id::text,'SHARED','NON_TRANSFERABLE',jsonb_build_object('transfer_operation','CLONE','source_sh_id',v_agreement.source_sh_id,'source_knowledge_id',(k.provenance->'clone_origin'->>'source_knowledge_id'),'agreement_id',v_agreement.agreement_id,'cloned_at',v_now) from public.knowledge k where k.sh_id=v_clone_sh_id;
  insert into public.journey_events(sh_id,account_id,event_type,occurred_at,continuity_status,payload,source_ref,visibility,transfer_policy,provenance)
  select v_clone_sh_id,v_target_account_id,'EXPERIENCE',v_now,'CONTINUOUS',jsonb_build_object('experience_id',e.experience_id,'content',e.content,'title','Cloned Experience'),'clone_experience:'||e.experience_id::text,'SHARED','NON_TRANSFERABLE',jsonb_build_object('transfer_operation','CLONE','source_sh_id',v_agreement.source_sh_id,'source_experience_id',(e.provenance->'clone_origin'->>'source_experience_id'),'agreement_id',v_agreement.agreement_id,'cloned_at',v_now) from public.experiences e where e.sh_id=v_clone_sh_id;
  update public.clone_agreements set target_account_id=v_target_account_id where agreement_id=v_agreement.agreement_id;
  insert into public.journey_events(sh_id,account_id,event_type,occurred_at,continuity_status,payload,source_ref,visibility,transfer_policy,provenance) values(v_source_sh.sh_id,v_agreement.source_account_id,'LIFECYCLE',v_now,'CONTINUOUS',jsonb_build_object('state','CLONED','agreement_id',v_agreement.agreement_id,'clone_sh_id',v_clone_sh_id,'target_account_id',v_target_account_id),'clone_operation:'||v_agreement.agreement_id::text,'PRIVATE','NON_TRANSFERABLE',jsonb_build_object('source','runtime_create_clone','agreement_id',v_agreement.agreement_id,'clone_sh_id',v_clone_sh_id,'target_account_id',v_target_account_id));
  insert into public.journey_events(sh_id,account_id,event_type,occurred_at,continuity_status,payload,source_ref,visibility,transfer_policy,provenance) values(v_clone_sh_id,v_target_account_id,'LIFECYCLE',v_now,'CONTINUOUS',jsonb_build_object('state','CLONE_CREATED','agreement_id',v_agreement.agreement_id,'source_sh_id',v_source_sh.sh_id),'clone_operation:'||v_agreement.agreement_id::text||':target','PRIVATE','NON_TRANSFERABLE',jsonb_build_object('source','runtime_create_clone','agreement_id',v_agreement.agreement_id,'source_sh_id',v_source_sh.sh_id));
  return v_clone_sh_id;
end;
$$;

grant execute on function public.runtime_create_clone(uuid,text) to authenticated;
revoke execute on function public.runtime_create_clone(uuid,text) from anon, public;
