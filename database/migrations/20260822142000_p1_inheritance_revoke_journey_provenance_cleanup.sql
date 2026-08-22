-- P1: inheritance revoke must remove derived Journey records as well as Memory/Knowledge/Experience.
-- Owner-ratified rule: releasing an Inheritance authorization removes only target-derived information;
-- source/original records remain retained. Succession/Legacy are separate EOL lifecycles.

create or replace function public.runtime_transfer_selected_journey_events(p_operation text, p_source_sh_id uuid, p_target_sh_id uuid, p_event_ids uuid[])
returns integer language plpgsql security definer set search_path=public as $$
declare v_source_account uuid; v_target_account uuid; v_count integer; v_op text:=upper(p_operation); v_required_policy text; v_inheritance_authorization uuid;
begin
  if auth.uid() is null then raise exception 'JOURNEY_TRANSFER_REJECTED: authentication required'; end if;
  if v_op not in ('CLONE','INHERITANCE','SUCCESSION') then raise exception 'JOURNEY_TRANSFER_REJECTED: unsupported operation'; end if;
  if v_op='SUCCESSION' then perform public.runtime_assert_active_sh(p_target_sh_id,'JOURNEY_TRANSFER_TARGET'); if not exists(select 1 from public.sh_instances s where s.sh_id=p_source_sh_id and s.status='deactivated') then raise exception 'JOURNEY_TRANSFER_REJECTED: succession source SH must be deactivated'; end if;
  else perform public.runtime_assert_active_sh(p_source_sh_id,'JOURNEY_TRANSFER_SOURCE'); perform public.runtime_assert_active_sh(p_target_sh_id,'JOURNEY_TRANSFER_TARGET'); end if;
  select s.account_id into v_source_account from public.sh_instances s where s.sh_id=p_source_sh_id;
  select s.account_id into v_target_account from public.sh_instances s where s.sh_id=p_target_sh_id;
  if v_source_account is null or v_target_account is null then raise exception 'JOURNEY_TRANSFER_REJECTED: SH not found'; end if;
  if v_op='CLONE' then
    if v_source_account<>current_account_id() or not exists(select 1 from public.clone_agreements a where a.source_sh_id=p_source_sh_id and a.source_account_id=current_account_id() and a.target_account_id=v_target_account and a.status='APPROVED') then raise exception 'JOURNEY_TRANSFER_REJECTED: approved clone agreement required'; end if;
  elsif v_op='INHERITANCE' then
    v_required_policy:='INHERITANCE';
    select a.authorization_id into v_inheritance_authorization from public.inheritance_authorizations a where a.source_sh_id=p_source_sh_id and a.target_sh_id=p_target_sh_id and a.source_account_id=current_account_id() and a.status='APPROVED' order by a.created_at desc limit 1;
    if v_inheritance_authorization is null then raise exception 'JOURNEY_TRANSFER_REJECTED: approved inheritance authorization required'; end if;
  else
    v_required_policy:='SUCCESSION';
    if not exists(select 1 from public.succession_rules r where r.source_sh_id=p_source_sh_id and r.successor_account_id=v_target_account and r.successor_account_id=current_account_id() and r.status='ACTIVE') then raise exception 'JOURNEY_TRANSFER_REJECTED: active succession rule required'; end if;
  end if;
  if coalesce(array_length(p_event_ids,1),0)=0 then raise exception 'JOURNEY_TRANSFER_REJECTED: explicit event selection required'; end if;
  if exists(select 1 from public.journey_events j where j.event_id=any(p_event_ids) and (j.sh_id<>p_source_sh_id or j.visibility='PRIVATE' or j.transfer_policy='NON_TRANSFERABLE' or (v_required_policy is not null and j.transfer_policy<>v_required_policy))) then raise exception 'JOURNEY_TRANSFER_REJECTED: selection is not eligible for this lifecycle operation'; end if;
  if exists(select 1 from unnest(p_event_ids) requested(event_id) left join public.journey_events j on j.event_id=requested.event_id where j.event_id is null) then raise exception 'JOURNEY_TRANSFER_REJECTED: selected event not found'; end if;
  insert into public.journey_events(sh_id,account_id,event_type,occurred_at,continuity_status,gap_code,payload,source_ref,visibility,transfer_policy,provenance)
  select p_target_sh_id,v_target_account,j.event_type,j.occurred_at,j.continuity_status,j.gap_code,j.payload,'journey_event:'||j.event_id::text,'PRIVATE','NON_TRANSFERABLE',jsonb_build_object('transfer_operation',v_op,'source_sh_id',p_source_sh_id,'source_event_id',j.event_id,'source_provenance',coalesce(j.provenance,'{}'::jsonb),'authorization_id',case when v_op='INHERITANCE' then v_inheritance_authorization else null end,'transferred_at',now())
  from public.journey_events j where j.event_id=any(p_event_ids) and j.sh_id=p_source_sh_id;
  get diagnostics v_count=row_count; return v_count;
end;
$$;

create or replace function public.runtime_revoke_inheritance_authorization(p_authorization_id uuid)
returns void language plpgsql security definer set search_path=public as $$
declare v_auth public.inheritance_authorizations%rowtype;
begin
  if auth.uid() is null then raise exception 'INHERITANCE_REVOKE_REJECTED: authentication required'; end if;
  select * into v_auth from public.inheritance_authorizations where authorization_id=p_authorization_id for update;
  if not found then raise exception 'INHERITANCE_REVOKE_REJECTED: authorization not found'; end if;
  if v_auth.source_account_id<>public.current_account_id() then raise exception 'INHERITANCE_REVOKE_REJECTED: source owner required'; end if;
  if v_auth.status not in ('APPROVED','CONSUMED') then raise exception 'INHERITANCE_REVOKE_REJECTED: authorization not revocable'; end if;
  delete from public.memories m where coalesce(m.provenance,'{}'::jsonb)->'inheritance_origin'->>'authorization_id'=p_authorization_id::text;
  delete from public.knowledge k where coalesce(k.provenance,'{}'::jsonb)->'inheritance_origin'->>'authorization_id'=p_authorization_id::text;
  delete from public.experiences e where coalesce(e.provenance,'{}'::jsonb)->'inheritance_origin'->>'authorization_id'=p_authorization_id::text;
  delete from public.journey_events j where coalesce(j.provenance,'{}'::jsonb)->>'transfer_operation'='INHERITANCE' and coalesce(j.provenance,'{}'::jsonb)->>'authorization_id'=p_authorization_id::text;
  update public.inheritance_authorizations set status='REVOKED', revoked_at=now() where authorization_id=p_authorization_id;
end;
$$;

revoke all on function public.runtime_transfer_selected_journey_events(text,uuid,uuid,uuid[]) from public,anon;
grant execute on function public.runtime_transfer_selected_journey_events(text,uuid,uuid,uuid[]) to authenticated;
revoke all on function public.runtime_revoke_inheritance_authorization(uuid) from public,anon;
grant execute on function public.runtime_revoke_inheritance_authorization(uuid) to authenticated;
