-- P1 terminal lifecycle/security reconciliation.
-- Canonical rule: DEACTIVATED is terminal; Account + SH identity/history remain retained,
-- but the application authentication boundary must reject the identity.

create or replace function public.prevent_identity_reactivation()
returns trigger
language plpgsql
security invoker
set search_path = public
as $$
begin
  if old.status = 'deactivated' and new.status <> 'deactivated' then
    raise exception 'IDENTITY_LIFECYCLE_TERMINAL: deactivated identity cannot be reactivated';
  end if;
  return new;
end;
$$;

create or replace function public.runtime_assert_active_sh(p_sh_id uuid, p_role text default 'SH')
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if auth.uid() is null then
    raise exception '%_REJECTED: authentication required', upper(p_role);
  end if;
  if not exists (select 1 from public.sh_instances s where s.sh_id = p_sh_id and s.status <> 'deactivated') then
    raise exception '%_REJECTED: SH is deactivated or unavailable', upper(p_role);
  end if;
end;
$$;

grant execute on function public.runtime_assert_active_sh(uuid,text) to authenticated;
revoke execute on function public.runtime_assert_active_sh(uuid,text) from anon;
revoke execute on function public.runtime_assert_active_sh(uuid,text) from public;

create or replace function public.runtime_validate_selected_transfer_scope(p_source_sh_id uuid, p_scope jsonb, p_operation text)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare v_scope jsonb:=coalesce(p_scope,'{}'::jsonb); v_requested integer; v_matched integer; v_eligible integer; v_policy text;
begin
  perform public.runtime_assert_active_sh(p_source_sh_id, 'TRANSFER');
  v_policy:=upper(p_operation); if v_policy='INHERITABLE' then v_policy:='INHERITANCE'; end if;
  if v_policy not in ('INHERITANCE','SUCCESSION','LEGACY') then raise exception '%_REJECTED: invalid transfer operation',upper(p_operation); end if;
  v_requested:=(select count(*) from (select distinct value::uuid from jsonb_array_elements_text(coalesce(v_scope->'memory_ids','[]'::jsonb))) x);
  if v_requested>0 then
    select count(*) into v_matched from public.memories m where m.sh_id=p_source_sh_id and m.memory_id=any(array(select distinct value::uuid from jsonb_array_elements_text(coalesce(v_scope->'memory_ids','[]'::jsonb))));
    if v_requested<>v_matched then raise exception '%_REJECTED: selected memory is not owned by source SH',v_policy; end if;
    select count(*) into v_eligible from public.memories m where m.sh_id=p_source_sh_id and m.memory_id=any(array(select distinct value::uuid from jsonb_array_elements_text(coalesce(v_scope->'memory_ids','[]'::jsonb)))) and m.transfer_policy=v_policy;
    if v_requested<>v_eligible then raise exception '%_REJECTED: selected memory is not eligible for this transfer operation',v_policy; end if;
  end if;
  v_requested:=(select count(*) from (select distinct value::uuid from jsonb_array_elements_text(coalesce(v_scope->'knowledge_ids','[]'::jsonb))) x);
  if v_requested>0 then
    select count(*) into v_matched from public.knowledge k where k.sh_id=p_source_sh_id and k.knowledge_id=any(array(select distinct value::uuid from jsonb_array_elements_text(coalesce(v_scope->'knowledge_ids','[]'::jsonb))));
    if v_requested<>v_matched then raise exception '%_REJECTED: selected knowledge is not owned by source SH',v_policy; end if;
    select count(*) into v_eligible from public.knowledge k where k.sh_id=p_source_sh_id and k.knowledge_id=any(array(select distinct value::uuid from jsonb_array_elements_text(coalesce(v_scope->'knowledge_ids','[]'::jsonb)))) and k.transfer_policy=v_policy;
    if v_requested<>v_eligible then raise exception '%_REJECTED: selected knowledge is not eligible for this transfer operation',v_policy; end if;
  end if;
  v_requested:=(select count(*) from (select distinct value::uuid from jsonb_array_elements_text(coalesce(v_scope->'experience_ids','[]'::jsonb))) x);
  if v_requested>0 then
    select count(*) into v_matched from public.experiences e where e.sh_id=p_source_sh_id and e.experience_id=any(array(select distinct value::uuid from jsonb_array_elements_text(coalesce(v_scope->'experience_ids','[]'::jsonb))));
    if v_requested<>v_matched then raise exception '%_REJECTED: selected experience is not owned by source SH',v_policy; end if;
    select count(*) into v_eligible from public.experiences e where e.sh_id=p_source_sh_id and e.experience_id=any(array(select distinct value::uuid from jsonb_array_elements_text(coalesce(v_scope->'experience_ids','[]'::jsonb)))) and e.transfer_policy=v_policy;
    if v_requested<>v_eligible then raise exception '%_REJECTED: selected experience is not eligible for this transfer operation',v_policy; end if;
  end if;
end;
$$;

create or replace function public.runtime_transfer_selected_journey_events(p_operation text, p_source_sh_id uuid, p_target_sh_id uuid, p_event_ids uuid[])
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare v_source_account uuid; v_target_account uuid; v_count integer;
begin
  if auth.uid() is null then raise exception 'JOURNEY_TRANSFER_REJECTED: authentication required'; end if;
  perform public.runtime_assert_active_sh(p_source_sh_id, 'JOURNEY_TRANSFER_SOURCE');
  perform public.runtime_assert_active_sh(p_target_sh_id, 'JOURNEY_TRANSFER_TARGET');
  if p_operation not in ('CLONE','INHERITANCE','SUCCESSION') then raise exception 'JOURNEY_TRANSFER_REJECTED: unsupported operation'; end if;
  select s.account_id into v_source_account from public.sh_instances s where s.sh_id=p_source_sh_id;
  select s.account_id into v_target_account from public.sh_instances s where s.sh_id=p_target_sh_id;
  if v_source_account is null or v_target_account is null then raise exception 'JOURNEY_TRANSFER_REJECTED: SH not found'; end if;
  if p_operation='CLONE' then
    if v_source_account<>current_account_id() or not exists (select 1 from public.clone_agreements a where a.source_sh_id=p_source_sh_id and a.source_account_id=current_account_id() and a.target_account_id=v_target_account and a.status='APPROVED') then raise exception 'JOURNEY_TRANSFER_REJECTED: approved clone agreement required'; end if;
  elsif p_operation='INHERITANCE' then
    if not exists (select 1 from public.inheritance_authorizations a where a.source_sh_id=p_source_sh_id and a.target_sh_id=p_target_sh_id and a.source_account_id=current_account_id() and a.status='APPROVED') then raise exception 'JOURNEY_TRANSFER_REJECTED: approved inheritance authorization required'; end if;
  else
    if not exists (select 1 from public.succession_rules r where r.source_sh_id=p_source_sh_id and r.successor_account_id=v_target_account and r.successor_account_id=current_account_id() and r.status='ACTIVE') then raise exception 'JOURNEY_TRANSFER_REJECTED: active succession rule required'; end if;
  end if;
  if coalesce(array_length(p_event_ids,1),0)=0 then raise exception 'JOURNEY_TRANSFER_REJECTED: explicit event selection required'; end if;
  if exists (select 1 from public.journey_events j where j.event_id=any(p_event_ids) and (j.sh_id<>p_source_sh_id or j.visibility='PRIVATE' or j.transfer_policy='NON_TRANSFERABLE')) then raise exception 'JOURNEY_TRANSFER_REJECTED: selection contains private or non-transferable event'; end if;
  if exists (select 1 from unnest(p_event_ids) requested(event_id) left join public.journey_events j on j.event_id=requested.event_id where j.event_id is null) then raise exception 'JOURNEY_TRANSFER_REJECTED: selected event not found'; end if;
  insert into public.journey_events(sh_id,account_id,event_type,occurred_at,continuity_status,gap_code,payload,source_ref,visibility,transfer_policy,provenance)
  select p_target_sh_id,v_target_account,j.event_type,j.occurred_at,j.continuity_status,j.gap_code,j.payload,'journey_event:'||j.event_id::text,'PRIVATE','NON_TRANSFERABLE',jsonb_build_object('transfer_operation',p_operation,'source_sh_id',p_source_sh_id,'source_event_id',j.event_id,'source_provenance',coalesce(j.provenance,'{}'::jsonb),'transferred_at',now())
  from public.journey_events j where j.event_id=any(p_event_ids) and j.sh_id=p_source_sh_id;
  get diagnostics v_count=row_count; return v_count;
end;
$$;

revoke execute on function public.list_experience_context(uuid,integer) from anon;
revoke execute on function public.list_experience_context(uuid,integer) from public;
revoke execute on function public.list_experiences(uuid,integer) from anon;
revoke execute on function public.list_experiences(uuid,integer) from public;
revoke execute on function public.runtime_classify_experience(uuid,text,text) from anon;
revoke execute on function public.runtime_classify_experience(uuid,text,text) from public;
revoke execute on function public.runtime_create_inheritance_authorization(uuid,uuid,uuid,uuid,jsonb) from anon;
revoke execute on function public.runtime_create_inheritance_authorization(uuid,uuid,uuid,uuid,jsonb) from public;
revoke execute on function public.runtime_execute_succession(uuid) from anon;
revoke execute on function public.runtime_execute_succession(uuid) from public;
revoke execute on function public.runtime_get_journey_record_policy(uuid) from anon;
revoke execute on function public.runtime_get_journey_record_policy(uuid) from public;
revoke execute on function public.runtime_journey_event_is_shared(uuid) from anon;
revoke execute on function public.runtime_journey_event_is_shared(uuid) from public;
revoke execute on function public.runtime_preserve_selected_transfer_as_legacy(uuid,jsonb) from anon;
revoke execute on function public.runtime_preserve_selected_transfer_as_legacy(uuid,jsonb) from public;
revoke execute on function public.runtime_record_inheritance(uuid,jsonb,jsonb) from anon;
revoke execute on function public.runtime_record_inheritance(uuid,jsonb,jsonb) from public;
