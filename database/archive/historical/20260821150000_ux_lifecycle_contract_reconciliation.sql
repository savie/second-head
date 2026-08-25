-- SECOND HEAD — UX/lifecycle contract reconciliation
-- Owner decisions:
--   * Inheritance recipient input is Account ID only; BE resolves the target PRIMARY SH.
--   * Clone creation input is recipient email only; BE resolves the source PRIMARY SH.
--   * Journey owners may delete their own Journey event; underlying domain records are not deleted by this operation.
--   * End-of-Life requires an explicit confirmation step in FE before execution.
--   * Conversation remains continuously sendable after a completed response; Save to Journey is optional.
--
-- This migration does not replace the Canonical Matrix or Architecture baseline.

create or replace function public.runtime_create_inheritance_authorization_by_account(
  p_target_account_id uuid,
  p_scope jsonb default '{}'::jsonb
)
returns public.inheritance_authorizations
language plpgsql
security definer
set search_path = public
as $$
declare
  v_source_account_id uuid;
  v_source_sh_id uuid;
  v_target_sh_id uuid;
  v_auth public.inheritance_authorizations%rowtype;
begin
  if auth.uid() is null then
    raise exception 'INHERITANCE_AUTHORIZATION_REJECTED: authentication required';
  end if;

  v_source_account_id := public.current_account_id();
  if v_source_account_id is null then
    raise exception 'INHERITANCE_AUTHORIZATION_REJECTED: source account unresolved';
  end if;
  if p_target_account_id is null then
    raise exception 'INHERITANCE_AUTHORIZATION_REJECTED: target account is required';
  end if;
  if v_source_account_id = p_target_account_id then
    raise exception 'INHERITANCE_AUTHORIZATION_REJECTED: source and target accounts must differ';
  end if;

  select s.sh_id into v_source_sh_id
  from public.sh_instances s
  where s.account_id = v_source_account_id
    and s.is_primary = true
    and s.status <> 'deactivated'
  order by s.created_at
  limit 1;
  if v_source_sh_id is null then
    raise exception 'INHERITANCE_AUTHORIZATION_REJECTED: source PRIMARY SH not found';
  end if;

  select s.sh_id into v_target_sh_id
  from public.sh_instances s
  where s.account_id = p_target_account_id
    and s.is_primary = true
    and s.status <> 'deactivated'
  order by s.created_at
  limit 1;
  if v_target_sh_id is null then
    raise exception 'INHERITANCE_AUTHORIZATION_REJECTED: target PRIMARY SH not found';
  end if;

  perform public.runtime_validate_selected_transfer_scope(v_source_sh_id, coalesce(p_scope, '{}'::jsonb), 'INHERITANCE');

  insert into public.inheritance_authorizations(
    source_sh_id, target_sh_id, source_account_id, target_account_id, status, scope
  ) values (
    v_source_sh_id, v_target_sh_id, v_source_account_id, p_target_account_id, 'PENDING', coalesce(p_scope, '{}'::jsonb)
  ) returning * into v_auth;

  return v_auth;
end;
$$;

revoke all on function public.runtime_create_inheritance_authorization_by_account(uuid,jsonb) from public;
grant execute on function public.runtime_create_inheritance_authorization_by_account(uuid,jsonb) to authenticated;

create or replace function public.runtime_create_clone_invitation(
  p_target_email text,
  p_scope jsonb default '{}'::jsonb
)
returns public.clone_agreements
language plpgsql
security definer
set search_path = public
as $$
declare
  v_source_account_id uuid;
  v_source_sh_id uuid;
  v_target_email text := lower(trim(p_target_email));
  v_agreement public.clone_agreements%rowtype;
begin
  if auth.uid() is null then
    raise exception 'CLONE_REJECTED: authentication required';
  end if;
  if v_target_email is null or v_target_email = '' then
    raise exception 'CLONE_REJECTED: recipient email is required';
  end if;

  v_source_account_id := public.current_account_id();
  if v_source_account_id is null then
    raise exception 'CLONE_REJECTED: source account unresolved';
  end if;

  select s.sh_id into v_source_sh_id
  from public.sh_instances s
  where s.account_id = v_source_account_id
    and s.is_primary = true
    and s.status <> 'deactivated'
  order by s.created_at
  limit 1;
  if v_source_sh_id is null then
    raise exception 'CLONE_REJECTED: source PRIMARY SH not found';
  end if;

  if exists (
    select 1 from public.accounts a where lower(trim(a.email)) = v_target_email
  ) then
    raise exception 'CLONE_REJECTED: recipient email already belongs to an Account';
  end if;

  insert into public.clone_agreements(
    source_sh_id, source_account_id, target_account_id, target_email, status, scope
  ) values (
    v_source_sh_id, v_source_account_id, null, v_target_email, 'PENDING', coalesce(p_scope, '{}'::jsonb)
  ) returning * into v_agreement;

  return v_agreement;
end;
$$;

revoke all on function public.runtime_create_clone_invitation(text,jsonb) from public;
grant execute on function public.runtime_create_clone_invitation(text,jsonb) to authenticated;

create or replace function public.runtime_delete_journey_event(p_event_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_account_id uuid := public.current_account_id();
begin
  if auth.uid() is null or v_account_id is null then
    raise exception 'JOURNEY_DELETE_REJECTED: authentication required';
  end if;

  if not exists (
    select 1
    from public.journey_events j
    join public.sh_instances s on s.sh_id = j.sh_id
    where j.event_id = p_event_id
      and s.account_id = v_account_id
  ) then
    raise exception 'JOURNEY_DELETE_REJECTED: owner access required';
  end if;

  delete from public.journey_events where event_id = p_event_id;
end;
$$;

revoke all on function public.runtime_delete_journey_event(uuid) from public;
grant execute on function public.runtime_delete_journey_event(uuid) to authenticated;
