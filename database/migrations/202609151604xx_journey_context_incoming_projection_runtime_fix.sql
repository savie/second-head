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
    select j.sh_id,j.event_id,j.event_type,j.occurred_at,j.continuity_status,j.gap_code,j.payload,j.source_ref,j.visibility,j.transfer_policy,j.provenance
    from public.journey_events j where j.sh_id=p_sh_id and (j.account_id=v_account_id or j.visibility in ('SHARED','PUBLIC')) order by j.occurred_at desc limit v_limit
  ), incoming_inheritance as (
    select j.sh_id,j.event_id,j.event_type,j.occurred_at,'INCOMING_INHERITANCE'::text as continuity_status,j.gap_code,
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