-- Reconcile canonical transfer-policy vocabulary: INHERITANCE is the established value.
create or replace function public.runtime_set_record_policy(p_domain text, p_record_id uuid, p_scope text, p_visibility text, p_transfer_policy text)
returns void language plpgsql security definer set search_path=public
as $$
declare v_policy text:=upper(p_transfer_policy);
begin
  if auth.uid() is null then raise exception 'POLICY_REJECTED: authentication required'; end if;
  if v_scope not in ('PRIVATE','GENERAL') then raise exception 'POLICY_REJECTED: invalid scope'; end if;
  if v_visibility not in ('OWNER_ONLY','SHARED') then raise exception 'POLICY_REJECTED: invalid visibility'; end if;
  if v_policy='INHERITABLE' then v_policy:='INHERITANCE'; end if;
  if v_policy not in ('NON_TRANSFERABLE','INHERITANCE','SUCCESSION','LEGACY') then raise exception 'POLICY_REJECTED: invalid transfer policy'; end if;
  if upper(p_domain)='MEMORY' then
    if exists(select 1 from public.memories m join public.sh_instances s on s.sh_id=m.sh_id where m.memory_id=p_record_id and s.account_id=public.current_account_id() and s.status='deactivated') then raise exception 'POLICY_REJECTED: SH is terminal/deactivated'; end if;
    if exists(select 1 from public.memories m where m.memory_id=p_record_id and coalesce(m.provenance,'{}'::jsonb) ? 'inheritance_origin') then raise exception 'POLICY_REJECTED: inherited policy is controlled by source SH'; end if;
    update public.memories m set scope=p_scope,visibility=p_visibility,transfer_policy=v_policy,updated_at=now() where m.memory_id=p_record_id and exists(select 1 from public.sh_instances s where s.sh_id=m.sh_id and s.account_id=public.current_account_id());
  elsif upper(p_domain)='KNOWLEDGE' then
    if exists(select 1 from public.knowledge k join public.sh_instances s on s.sh_id=k.sh_id where k.knowledge_id=p_record_id and s.account_id=public.current_account_id() and s.status='deactivated') then raise exception 'POLICY_REJECTED: SH is terminal/deactivated'; end if;
    if exists(select 1 from public.knowledge k where k.knowledge_id=p_record_id and coalesce(k.provenance,'{}'::jsonb) ? 'inheritance_origin') then raise exception 'POLICY_REJECTED: inherited policy is controlled by source SH'; end if;
    update public.knowledge k set scope=p_scope,visibility=p_visibility,transfer_policy=v_policy,updated_at=now() where k.knowledge_id=p_record_id and exists(select 1 from public.sh_instances s where s.sh_id=k.sh_id and s.account_id=public.current_account_id());
  elsif upper(p_domain)='EXPERIENCE' then
    if exists(select 1 from public.experiences e join public.sh_instances s on s.sh_id=e.sh_id where e.experience_id=p_record_id and e.account_id=public.current_account_id() and s.status='deactivated') then raise exception 'POLICY_REJECTED: SH is terminal/deactivated'; end if;
    if exists(select 1 from public.experiences e where e.experience_id=p_record_id and coalesce(e.provenance,'{}'::jsonb) ? 'inheritance_origin') then raise exception 'POLICY_REJECTED: inherited policy is controlled by source SH'; end if;
    update public.experiences e set scope=p_scope,visibility=p_visibility,transfer_policy=v_policy,updated_at=now() where e.experience_id=p_record_id and e.account_id=public.current_account_id();
  else raise exception 'POLICY_REJECTED: unsupported domain'; end if;
  if not found then raise exception 'POLICY_REJECTED: record not owned by current account'; end if;
end $$;

-- Journey transfer must honor lifecycle-specific transfer policy for Inheritance/Succession.
create or replace function public.runtime_transfer_selected_journey_events(p_operation text, p_source_sh_id uuid, p_target_sh_id uuid, p_event_ids uuid[])
returns integer language plpgsql security definer set search_path=public
as $$
declare v_source_account uuid; v_target_account uuid; v_count integer; v_op text:=upper(p_operation); v_required_policy text;
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
    if not exists(select 1 from public.inheritance_authorizations a where a.source_sh_id=p_source_sh_id and a.target_sh_id=p_target_sh_id and a.source_account_id=current_account_id() and a.status='APPROVED') then raise exception 'JOURNEY_TRANSFER_REJECTED: approved inheritance authorization required'; end if;
  else
    v_required_policy:='SUCCESSION';
    if not exists(select 1 from public.succession_rules r where r.source_sh_id=p_source_sh_id and r.successor_account_id=v_target_account and r.successor_account_id=current_account_id() and r.status='ACTIVE') then raise exception 'JOURNEY_TRANSFER_REJECTED: active succession rule required'; end if;
  end if;
  if coalesce(array_length(p_event_ids,1),0)=0 then raise exception 'JOURNEY_TRANSFER_REJECTED: explicit event selection required'; end if;
  if exists(select 1 from public.journey_events j where j.event_id=any(p_event_ids) and (j.sh_id<>p_source_sh_id or j.visibility='PRIVATE' or j.transfer_policy='NON_TRANSFERABLE' or (v_required_policy is not null and j.transfer_policy<>v_required_policy))) then raise exception 'JOURNEY_TRANSFER_REJECTED: selection is not eligible for this lifecycle operation'; end if;
  if exists(select 1 from unnest(p_event_ids) requested(event_id) left join public.journey_events j on j.event_id=requested.event_id where j.event_id is null) then raise exception 'JOURNEY_TRANSFER_REJECTED: selected event not found'; end if;
  insert into public.journey_events(sh_id,account_id,event_type,occurred_at,continuity_status,gap_code,payload,source_ref,visibility,transfer_policy,provenance)
  select p_target_sh_id,v_target_account,j.event_type,j.occurred_at,j.continuity_status,j.gap_code,j.payload,'journey_event:'||j.event_id::text,'PRIVATE','NON_TRANSFERABLE',jsonb_build_object('transfer_operation',v_op,'source_sh_id',p_source_sh_id,'source_event_id',j.event_id,'source_provenance',coalesce(j.provenance,'{}'::jsonb),'transferred_at',now())
  from public.journey_events j where j.event_id=any(p_event_ids) and j.sh_id=p_source_sh_id;
  get diagnostics v_count=row_count; return v_count;
end $$;
