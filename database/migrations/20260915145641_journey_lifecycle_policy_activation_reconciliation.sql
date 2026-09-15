ALTER TABLE public.journey_events DROP CONSTRAINT IF EXISTS journey_events_transfer_policy_ck;
ALTER TABLE public.journey_events ADD CONSTRAINT journey_events_transfer_policy_ck CHECK (transfer_policy IN ('NON_TRANSFERABLE','INHERITANCE','SUCCESSION','LEGACY'));

CREATE OR REPLACE FUNCTION public.runtime_activate_selected_transfer_policy(
  p_source_sh_id uuid,
  p_scope jsonb,
  p_policy text
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
declare
  v_policy text := upper(trim(coalesce(p_policy,'')));
  v_source_account uuid := public.current_account_id();
  v_scope jsonb := coalesce(p_scope,'{}'::jsonb);
  v_count integer := 0;
  v_id uuid;
  v_event_id uuid;
begin
  if auth.uid() is null then raise exception 'TRANSFER_POLICY_REJECTED: authentication required'; end if;
  if v_policy not in ('INHERITANCE','SUCCESSION','LEGACY') then raise exception 'TRANSFER_POLICY_REJECTED: lifecycle policy required'; end if;
  if not exists(select 1 from public.sh_instances s where s.sh_id=p_source_sh_id and s.account_id=v_source_account and s.status<>'deactivated') then
    raise exception 'TRANSFER_POLICY_REJECTED: source SH ownership required';
  end if;
  if coalesce(jsonb_array_length(v_scope->'memory_ids'),0)+coalesce(jsonb_array_length(v_scope->'knowledge_ids'),0)+coalesce(jsonb_array_length(v_scope->'experience_ids'),0)+coalesce(jsonb_array_length(v_scope->'journey_event_ids'),0)=0 then
    raise exception 'TRANSFER_POLICY_REJECTED: explicit selection required';
  end if;

  for v_id in select distinct value::uuid from jsonb_array_elements_text(coalesce(v_scope->'memory_ids','[]'::jsonb)) loop
    select j.event_id into v_event_id from public.journey_events j where j.sh_id=p_source_sh_id and j.event_type='MEMORY' and j.payload->>'memory_id'=v_id::text and j.visibility='SHARED' order by j.occurred_at desc limit 1;
    if v_event_id is null then raise exception 'TRANSFER_POLICY_REJECTED: selected memory is not represented as shared Journey'; end if;
    if not exists(select 1 from public.memories m where m.memory_id=v_id and m.sh_id=p_source_sh_id) then raise exception 'TRANSFER_POLICY_REJECTED: selected memory is not owned'; end if;
    update public.memories set scope='GENERAL', visibility='SHARED', transfer_policy=v_policy, updated_at=now() where memory_id=v_id;
    update public.journey_events set visibility='SHARED', transfer_policy=v_policy where event_id=v_event_id;
    v_count:=v_count+1;
  end loop;

  for v_id in select distinct value::uuid from jsonb_array_elements_text(coalesce(v_scope->'knowledge_ids','[]'::jsonb)) loop
    select j.event_id into v_event_id from public.journey_events j where j.sh_id=p_source_sh_id and j.event_type in ('KNOWLEDGE','LEARNING') and j.payload->>'knowledge_id'=v_id::text and j.visibility='SHARED' order by j.occurred_at desc limit 1;
    if v_event_id is null then raise exception 'TRANSFER_POLICY_REJECTED: selected knowledge is not represented as shared Journey'; end if;
    if not exists(select 1 from public.knowledge k where k.knowledge_id=v_id and k.sh_id=p_source_sh_id) then raise exception 'TRANSFER_POLICY_REJECTED: selected knowledge is not owned'; end if;
    update public.knowledge set scope='GENERAL', visibility='SHARED', transfer_policy=v_policy, updated_at=now() where knowledge_id=v_id;
    update public.journey_events set visibility='SHARED', transfer_policy=v_policy where event_id=v_event_id;
    v_count:=v_count+1;
  end loop;

  for v_id in select distinct value::uuid from jsonb_array_elements_text(coalesce(v_scope->'experience_ids','[]'::jsonb)) loop
    select j.event_id into v_event_id from public.journey_events j where j.sh_id=p_source_sh_id and j.event_type='EXPERIENCE' and j.payload->>'experience_id'=v_id::text and j.visibility='SHARED' order by j.occurred_at desc limit 1;
    if v_event_id is null then raise exception 'TRANSFER_POLICY_REJECTED: selected experience is not represented as shared Journey'; end if;
    if not exists(select 1 from public.experiences e where e.experience_id=v_id and e.sh_id=p_source_sh_id) then raise exception 'TRANSFER_POLICY_REJECTED: selected experience is not owned'; end if;
    update public.experiences set scope='GENERAL', visibility='SHARED', transfer_policy=v_policy, updated_at=now() where experience_id=v_id;
    update public.journey_events set visibility='SHARED', transfer_policy=v_policy where event_id=v_event_id;
    v_count:=v_count+1;
  end loop;

  for v_id in select distinct value::uuid from jsonb_array_elements_text(coalesce(v_scope->'journey_event_ids','[]'::jsonb)) loop
    if not exists(select 1 from public.journey_events j where j.event_id=v_id and j.sh_id=p_source_sh_id and j.visibility='SHARED') then raise exception 'TRANSFER_POLICY_REJECTED: selected Journey event is not shared'; end if;
    update public.journey_events set transfer_policy=v_policy where event_id=v_id;
    if exists(select 1 from public.memories m where m.sh_id=p_source_sh_id and m.memory_id=(select j.payload->>'memory_id' from public.journey_events j where j.event_id=v_id)::uuid) then
      update public.memories set scope='GENERAL', visibility='SHARED', transfer_policy=v_policy, updated_at=now() where sh_id=p_source_sh_id and memory_id=(select (j.payload->>'memory_id')::uuid from public.journey_events j where j.event_id=v_id);
    elsif exists(select 1 from public.knowledge k where k.sh_id=p_source_sh_id and k.knowledge_id=(select j.payload->>'knowledge_id' from public.journey_events j where j.event_id=v_id)::uuid) then
      update public.knowledge set scope='GENERAL', visibility='SHARED', transfer_policy=v_policy, updated_at=now() where sh_id=p_source_sh_id and knowledge_id=(select (j.payload->>'knowledge_id')::uuid from public.journey_events j where j.event_id=v_id);
    elsif exists(select 1 from public.experiences e where e.sh_id=p_source_sh_id and e.experience_id=(select j.payload->>'experience_id' from public.journey_events j where j.event_id=v_id)::uuid) then
      update public.experiences set scope='GENERAL', visibility='SHARED', transfer_policy=v_policy, updated_at=now() where sh_id=p_source_sh_id and experience_id=(select (j.payload->>'experience_id')::uuid from public.journey_events j where j.event_id=v_id);
    end if;
    v_count:=v_count+1;
  end loop;
  if v_count=0 then raise exception 'TRANSFER_POLICY_REJECTED: no valid selection'; end if;
end;
$$;

CREATE OR REPLACE FUNCTION public.runtime_prepare_selected_transfer_as_legacy(
  p_source_sh_id uuid,
  p_scope jsonb
)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
declare
  v_legacy_id uuid;
  v_payload jsonb := '{}'::jsonb;
  v_now timestamptz := now();
  v_event_id uuid;
begin
  if auth.uid() is null then raise exception 'LEGACY_PREPARATION_REJECTED: authentication required'; end if;
  if not exists(select 1 from public.sh_instances s where s.sh_id=p_source_sh_id and s.account_id=public.current_account_id() and s.status <> 'deactivated') then raise exception 'LEGACY_PREPARATION_REJECTED: active source SH required'; end if;
  if p_scope is null then raise exception 'LEGACY_PREPARATION_REJECTED: explicit selection required'; end if;
  if p_scope ? 'target_email' then raise exception 'LEGACY_PREPARATION_REJECTED: legacy has no target actor'; end if;
  if coalesce(jsonb_array_length(coalesce(p_scope->'journey_event_ids','[]'::jsonb)),0)=0 then raise exception 'LEGACY_PREPARATION_REJECTED: select at least one shared Journey item'; end if;

  for v_event_id in select distinct value::uuid from jsonb_array_elements_text(coalesce(p_scope->'journey_event_ids','[]'::jsonb)) loop
    if not exists(select 1 from public.journey_events j where j.event_id=v_event_id and j.sh_id=p_source_sh_id and j.visibility='SHARED' and j.transfer_policy='NON_TRANSFERABLE') then raise exception 'LEGACY_PREPARATION_REJECTED: selected Journey item must be SHARED + NON_TRANSFERABLE'; end if;
    update public.journey_events set transfer_policy='LEGACY', visibility='SHARED' where event_id=v_event_id;
    if exists(select 1 from public.memories m where m.sh_id=p_source_sh_id and m.memory_id=(select (j.payload->>'memory_id')::uuid from public.journey_events j where j.event_id=v_event_id)) then
      update public.memories set scope='GENERAL', visibility='SHARED', transfer_policy='LEGACY', updated_at=now() where sh_id=p_source_sh_id and memory_id=(select (j.payload->>'memory_id')::uuid from public.journey_events j where j.event_id=v_event_id);
    elsif exists(select 1 from public.knowledge k where k.sh_id=p_source_sh_id and k.knowledge_id=(select (j.payload->>'knowledge_id')::uuid from public.journey_events j where j.event_id=v_event_id)) then
      update public.knowledge set scope='GENERAL', visibility='SHARED', transfer_policy='LEGACY', updated_at=now() where sh_id=p_source_sh_id and knowledge_id=(select (j.payload->>'knowledge_id')::uuid from public.journey_events j where j.event_id=v_event_id);
    elsif exists(select 1 from public.experiences e where e.sh_id=p_source_sh_id and e.experience_id=(select (j.payload->>'experience_id')::uuid from public.journey_events j where j.event_id=v_event_id)) then
      update public.experiences set scope='GENERAL', visibility='SHARED', transfer_policy='LEGACY', updated_at=now() where sh_id=p_source_sh_id and experience_id=(select (j.payload->>'experience_id')::uuid from public.journey_events j where j.event_id=v_event_id);
    end if;
  end loop;

  v_payload := jsonb_build_object('journey', coalesce((select jsonb_agg(to_jsonb(j)) from public.journey_events j where j.event_id=any(array(select distinct value::uuid from jsonb_array_elements_text(p_scope->'journey_event_ids')))), '[]'::jsonb));
  insert into public.legacy_records(source_sh_id,legacy_type,payload,provenance,status)
  values(p_source_sh_id,'HISTORY',v_payload,jsonb_build_object('legacy_operation','SELECTED_TRANSFER_PREPARATION','source_sh_id',p_source_sh_id,'selection',p_scope,'distribution','ALL_SH','prepared_at',v_now),'PREPARED')
  returning legacy_id into v_legacy_id;
  return v_legacy_id;
end;
$$;

GRANT EXECUTE ON FUNCTION public.runtime_activate_selected_transfer_policy(uuid,jsonb,text) TO authenticated;
REVOKE EXECUTE ON FUNCTION public.runtime_activate_selected_transfer_policy(uuid,jsonb,text) FROM anon, public;
GRANT EXECUTE ON FUNCTION public.runtime_prepare_selected_transfer_as_legacy(uuid,jsonb) TO authenticated;
REVOKE EXECUTE ON FUNCTION public.runtime_prepare_selected_transfer_as_legacy(uuid,jsonb) FROM anon, public;
