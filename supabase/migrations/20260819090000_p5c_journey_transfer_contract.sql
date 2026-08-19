alter table public.journey_events
  add column if not exists visibility text not null default 'PRIVATE',
  add column if not exists transfer_policy text not null default 'NON_TRANSFERABLE',
  add column if not exists provenance jsonb not null default '{}'::jsonb;

update public.journey_events
set visibility = coalesce(nullif(visibility, ''), 'PRIVATE'),
    transfer_policy = coalesce(nullif(transfer_policy, ''), 'NON_TRANSFERABLE'),
    provenance = coalesce(provenance, '{}'::jsonb);

alter table public.journey_events
  add constraint journey_events_visibility_ck
  check (visibility in ('PRIVATE','SHARED','PUBLIC'));

alter table public.journey_events
  add constraint journey_events_transfer_policy_ck
  check (transfer_policy in ('NON_TRANSFERABLE','TRANSFERABLE','EXPLICIT_ONLY'));

create index if not exists journey_events_transfer_idx
  on public.journey_events (sh_id, visibility, transfer_policy, occurred_at desc);

create or replace function public.runtime_classify_journey_event(
  p_event_id uuid,
  p_visibility text,
  p_transfer_policy text,
  p_provenance jsonb default '{}'::jsonb
)
returns void
language plpgsql
security invoker
set search_path = public
as $$
begin
  if auth.uid() is null then
    raise exception 'JOURNEY_CLASSIFY_REJECTED: authentication required';
  end if;

  if p_visibility not in ('PRIVATE','SHARED','PUBLIC') then
    raise exception 'JOURNEY_CLASSIFY_REJECTED: invalid visibility';
  end if;

  if p_transfer_policy not in ('NON_TRANSFERABLE','TRANSFERABLE','EXPLICIT_ONLY') then
    raise exception 'JOURNEY_CLASSIFY_REJECTED: invalid transfer policy';
  end if;

  update public.journey_events j
  set visibility = p_visibility,
      transfer_policy = p_transfer_policy,
      provenance = coalesce(p_provenance, '{}'::jsonb)
  where j.event_id = p_event_id
    and exists (
      select 1
      from public.sh_instances s
      where s.sh_id = j.sh_id
        and s.account_id = current_account_id()
    );

  if not found then
    raise exception 'JOURNEY_CLASSIFY_REJECTED: event not owned by current account';
  end if;
end;
$$;

revoke execute on function public.runtime_classify_journey_event(uuid,text,text,jsonb) from public, anon;
grant execute on function public.runtime_classify_journey_event(uuid,text,text,jsonb) to authenticated;

create or replace function public.runtime_transfer_selected_journey_events(
  p_operation text,
  p_source_sh_id uuid,
  p_target_sh_id uuid,
  p_event_ids uuid[]
)
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  v_source_account uuid;
  v_target_account uuid;
  v_count integer;
begin
  if auth.uid() is null then
    raise exception 'JOURNEY_TRANSFER_REJECTED: authentication required';
  end if;

  if p_operation not in ('CLONE','INHERITANCE','SUCCESSION') then
    raise exception 'JOURNEY_TRANSFER_REJECTED: unsupported operation';
  end if;

  select s.account_id into v_source_account
  from public.sh_instances s
  where s.sh_id = p_source_sh_id;
  if v_source_account is null then
    raise exception 'JOURNEY_TRANSFER_REJECTED: source SH not found';
  end if;

  select s.account_id into v_target_account
  from public.sh_instances s
  where s.sh_id = p_target_sh_id;
  if v_target_account is null then
    raise exception 'JOURNEY_TRANSFER_REJECTED: target SH not found';
  end if;

  if p_operation = 'CLONE' then
    if v_source_account <> current_account_id()
       or not exists (
         select 1 from public.clone_agreements a
         where a.source_sh_id = p_source_sh_id
           and a.source_account_id = current_account_id()
           and a.target_account_id = v_target_account
           and a.status = 'APPROVED'
       ) then
      raise exception 'JOURNEY_TRANSFER_REJECTED: approved clone agreement required';
    end if;
  elsif p_operation = 'INHERITANCE' then
    if not exists (
      select 1 from public.inheritance_authorizations a
      where a.source_sh_id = p_source_sh_id
        and a.target_sh_id = p_target_sh_id
        and a.source_account_id = current_account_id()
        and a.status = 'APPROVED'
    ) then
      raise exception 'JOURNEY_TRANSFER_REJECTED: approved inheritance authorization required';
    end if;
  elsif p_operation = 'SUCCESSION' then
    if not exists (
      select 1 from public.succession_rules r
      where r.source_sh_id = p_source_sh_id
        and r.successor_account_id = v_target_account
        and r.successor_account_id = current_account_id()
        and r.status = 'ACTIVE'
    ) then
      raise exception 'JOURNEY_TRANSFER_REJECTED: active succession rule required';
    end if;
  end if;

  if coalesce(array_length(p_event_ids, 1), 0) = 0 then
    raise exception 'JOURNEY_TRANSFER_REJECTED: explicit event selection required';
  end if;

  if exists (
    select 1
    from public.journey_events j
    where j.event_id = any(p_event_ids)
      and (
        j.sh_id <> p_source_sh_id
        or j.visibility = 'PRIVATE'
        or j.transfer_policy = 'NON_TRANSFERABLE'
      )
  ) then
    raise exception 'JOURNEY_TRANSFER_REJECTED: selection contains private or non-transferable event';
  end if;

  if exists (
    select 1
    from unnest(p_event_ids) requested(event_id)
    left join public.journey_events j on j.event_id = requested.event_id
    where j.event_id is null
  ) then
    raise exception 'JOURNEY_TRANSFER_REJECTED: selected event not found';
  end if;

  insert into public.journey_events (
    sh_id,
    account_id,
    event_type,
    occurred_at,
    continuity_status,
    gap_code,
    payload,
    source_ref,
    visibility,
    transfer_policy,
    provenance
  )
  select
    p_target_sh_id,
    v_target_account,
    j.event_type,
    j.occurred_at,
    j.continuity_status,
    j.gap_code,
    j.payload,
    'journey_event:' || j.event_id::text,
    'PRIVATE',
    'NON_TRANSFERABLE',
    jsonb_build_object(
      'transfer_operation', p_operation,
      'source_sh_id', p_source_sh_id,
      'source_event_id', j.event_id,
      'source_provenance', coalesce(j.provenance, '{}'::jsonb),
      'transferred_at', now()
    )
  from public.journey_events j
  where j.event_id = any(p_event_ids)
    and j.sh_id = p_source_sh_id;

  get diagnostics v_count = row_count;
  return v_count;
end;
$$;

revoke execute on function public.runtime_transfer_selected_journey_events(text,uuid,uuid,uuid[]) from public, anon;
grant execute on function public.runtime_transfer_selected_journey_events(text,uuid,uuid,uuid[]) to authenticated;

create or replace function public.runtime_preserve_selected_journey_as_legacy(
  p_source_sh_id uuid,
  p_event_ids uuid[]
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_legacy_id uuid;
  v_payload jsonb;
begin
  if auth.uid() is null then
    raise exception 'LEGACY_JOURNEY_REJECTED: authentication required';
  end if;

  if not exists (
    select 1 from public.sh_instances s
    where s.sh_id = p_source_sh_id
      and s.account_id = current_account_id()
  ) then
    raise exception 'LEGACY_JOURNEY_REJECTED: source owner required';
  end if;

  if coalesce(array_length(p_event_ids, 1), 0) = 0 then
    raise exception 'LEGACY_JOURNEY_REJECTED: explicit event selection required';
  end if;

  if exists (
    select 1
    from public.journey_events j
    where j.event_id = any(p_event_ids)
      and (j.sh_id <> p_source_sh_id or j.visibility = 'PRIVATE' or j.transfer_policy = 'NON_TRANSFERABLE')
  ) then
    raise exception 'LEGACY_JOURNEY_REJECTED: selection contains private or non-transferable event';
  end if;

  select jsonb_agg(
    jsonb_build_object(
      'event_id', j.event_id,
      'event_type', j.event_type,
      'occurred_at', j.occurred_at,
      'continuity_status', j.continuity_status,
      'gap_code', j.gap_code,
      'payload', j.payload,
      'source_ref', j.source_ref,
      'provenance', coalesce(j.provenance, '{}'::jsonb)
    ) order by j.occurred_at, j.event_id
  ) into v_payload
  from public.journey_events j
  where j.event_id = any(p_event_ids)
    and j.sh_id = p_source_sh_id;

  insert into public.legacy_records (
    source_sh_id,
    legacy_type,
    payload,
    provenance
  ) values (
    p_source_sh_id,
    'JOURNEY',
    jsonb_build_object('journey_events', coalesce(v_payload, '[]'::jsonb)),
    jsonb_build_object(
      'legacy_operation', 'JOURNEY_SELECTION',
      'source_sh_id', p_source_sh_id,
      'source_event_ids', to_jsonb(p_event_ids),
      'created_at', now()
    )
  ) returning legacy_id into v_legacy_id;

  return v_legacy_id;
end;
$$;

revoke execute on function public.runtime_preserve_selected_journey_as_legacy(uuid,uuid[]) from public, anon;
grant execute on function public.runtime_preserve_selected_journey_as_legacy(uuid,uuid[]) to authenticated;
