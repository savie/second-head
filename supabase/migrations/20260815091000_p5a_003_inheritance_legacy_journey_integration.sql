-- P5A follow-up: record source-side inheritance and legacy operations in Journey.
--
-- Both event categories are already canonical Journey vocabulary and the
-- corresponding P5C runtime operations already define the concrete triggers.
-- This preserves privacy boundaries by recording only on the source SH owned
-- by the authenticated source owner.

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
  v_auth inheritance_authorizations%rowtype;
  v_id uuid;
begin
  select *
    into v_auth
  from public.inheritance_authorizations
  where authorization_id = p_authorization_id
    and status = 'APPROVED'
  for update;

  if not found then
    raise exception 'INHERITANCE_REJECTED: approved authorization required';
  end if;

  if v_auth.source_account_id <> current_account_id() then
    raise exception 'INHERITANCE_REJECTED: source owner approval required';
  end if;

  insert into public.inheritance_events (
    authorization_id,
    source_sh_id,
    target_sh_id,
    payload,
    provenance
  )
  values (
    p_authorization_id,
    v_auth.source_sh_id,
    v_auth.target_sh_id,
    coalesce(p_payload, '{}'::jsonb),
    coalesce(p_provenance, '{}'::jsonb)
  )
  returning inheritance_id into v_id;

  insert into public.journey_events (
    sh_id,
    account_id,
    event_type,
    occurred_at,
    continuity_status,
    payload,
    source_ref
  )
  values (
    v_auth.source_sh_id,
    current_account_id(),
    'INHERITANCE',
    now(),
    'CONTINUOUS',
    jsonb_build_object(
      'inheritance_id', v_id,
      'authorization_id', p_authorization_id,
      'target_sh_id', v_auth.target_sh_id,
      'payload', coalesce(p_payload, '{}'::jsonb),
      'provenance', coalesce(p_provenance, '{}'::jsonb)
    ),
    'inheritance_event:' || v_id::text
  );

  return v_id;
end;
$$;

grant execute on function public.runtime_record_inheritance(uuid,jsonb,jsonb) to authenticated;

create or replace function public.runtime_record_legacy(
  p_source_sh_id uuid,
  p_legacy_type text,
  p_payload jsonb default '{}'::jsonb,
  p_provenance jsonb default '{}'::jsonb,
  p_retention_until timestamptz default null
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_id uuid;
begin
  if not exists (
    select 1
    from public.sh_instances s
    where s.sh_id = p_source_sh_id
      and s.account_id = current_account_id()
  ) then
    raise exception 'LEGACY_REJECTED: source owner required';
  end if;

  if p_legacy_type not in ('MEMORY','KNOWLEDGE','EXPERIENCE','JOURNEY','HISTORY','VALUE','REFERENCE') then
    raise exception 'LEGACY_REJECTED: invalid legacy_type';
  end if;

  insert into public.legacy_records (
    source_sh_id,
    legacy_type,
    payload,
    provenance,
    retention_until
  )
  values (
    p_source_sh_id,
    p_legacy_type,
    coalesce(p_payload, '{}'::jsonb),
    coalesce(p_provenance, '{}'::jsonb),
    p_retention_until
  )
  returning legacy_id into v_id;

  insert into public.journey_events (
    sh_id,
    account_id,
    event_type,
    occurred_at,
    continuity_status,
    payload,
    source_ref
  )
  values (
    p_source_sh_id,
    current_account_id(),
    'LEGACY',
    now(),
    'CONTINUOUS',
    jsonb_build_object(
      'legacy_id', v_id,
      'legacy_type', p_legacy_type,
      'retention_until', p_retention_until,
      'payload', coalesce(p_payload, '{}'::jsonb),
      'provenance', coalesce(p_provenance, '{}'::jsonb)
    ),
    'legacy_record:' || v_id::text
  );

  return v_id;
end;
$$;

grant execute on function public.runtime_record_legacy(uuid,text,jsonb,jsonb,timestamptz) to authenticated;
