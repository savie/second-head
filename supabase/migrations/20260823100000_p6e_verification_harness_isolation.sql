-- Isolate CI verification artifacts from interactive SH state.
-- Verification snapshots are explicitly marked and can be removed by the owning test account.

create or replace function public.runtime_create_recovery_snapshot(
  p_sh_id uuid,
  p_verification_marker text
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_snapshot_id uuid;
  v_account_id uuid;
begin
  if auth.uid() is null then
    raise exception 'RECOVERY_REJECTED: authentication required';
  end if;
  if p_verification_marker is null or btrim(p_verification_marker) = '' then
    raise exception 'RECOVERY_REJECTED: verification marker required';
  end if;

  v_snapshot_id := public.runtime_create_recovery_snapshot(p_sh_id);

  select account_id into v_account_id
  from public.sh_instances
  where sh_id = p_sh_id
    and account_id = public.current_account_id();

  if v_account_id is null then
    raise exception 'RECOVERY_REJECTED: SH not owned by current account';
  end if;

  update public.recovery_snapshots
  set manifest = manifest || jsonb_build_object(
    'verification_marker', p_verification_marker,
    'verification_only', true
  )
  where snapshot_id = v_snapshot_id
    and account_id = v_account_id;

  return v_snapshot_id;
end;
$$;

grant execute on function public.runtime_create_recovery_snapshot(uuid,text) to authenticated;

create or replace function public.runtime_cleanup_verification_artifacts(
  p_sh_id uuid,
  p_verification_marker text
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_account_id uuid;
begin
  if auth.uid() is null then
    raise exception 'VERIFICATION_CLEANUP_REJECTED: authentication required';
  end if;
  if p_verification_marker is null or btrim(p_verification_marker) = '' then
    raise exception 'VERIFICATION_CLEANUP_REJECTED: verification marker required';
  end if;

  select account_id into v_account_id
  from public.sh_instances
  where sh_id = p_sh_id
    and account_id = public.current_account_id();

  if v_account_id is null then
    raise exception 'VERIFICATION_CLEANUP_REJECTED: SH not owned by current account';
  end if;

  delete from public.portability_exports
  where sh_id = p_sh_id
    and snapshot_id in (
      select snapshot_id from public.recovery_snapshots
      where sh_id = p_sh_id
        and account_id = v_account_id
        and manifest->>'verification_marker' = p_verification_marker
    );

  delete from public.journey_events
  where sh_id = p_sh_id
    and (
      payload->>'verification_marker' = p_verification_marker
      or source_ref in (
        select 'recovery_event:' || recovery_event_id::text
        from public.recovery_events
        where sh_id = p_sh_id
          and snapshot_id in (
            select snapshot_id from public.recovery_snapshots
            where sh_id = p_sh_id
              and account_id = v_account_id
              and manifest->>'verification_marker' = p_verification_marker
          )
      )
    );

  delete from public.recovery_events
  where sh_id = p_sh_id
    and snapshot_id in (
      select snapshot_id from public.recovery_snapshots
      where sh_id = p_sh_id
        and account_id = v_account_id
        and manifest->>'verification_marker' = p_verification_marker
    );

  delete from public.recovery_snapshots
  where sh_id = p_sh_id
    and account_id = v_account_id
    and manifest->>'verification_marker' = p_verification_marker;

  delete from public.conversations
  where sh_id = p_sh_id
    and coalesce(metadata->>'verification_marker', '') = p_verification_marker;

  delete from public.audit_events
  where sh_id = p_sh_id
    and coalesce(metadata->>'verification_marker', '') = p_verification_marker;

  delete from public.experiences
  where sh_id = p_sh_id
    and coalesce(provenance->>'verification_marker', '') = p_verification_marker;

  delete from public.memories
  where sh_id = p_sh_id
    and coalesce(provenance->>'verification_marker', '') = p_verification_marker;

  delete from public.knowledge
  where sh_id = p_sh_id
    and coalesce(provenance->>'verification_marker', '') = p_verification_marker;
end;
$$;

grant execute on function public.runtime_cleanup_verification_artifacts(uuid,text) to authenticated;
