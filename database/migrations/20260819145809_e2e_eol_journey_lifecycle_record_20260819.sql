create or replace function public.runtime_end_of_life_sh(p_sh_id uuid, p_reason text default null)
returns uuid
language plpgsql
security definer
set search_path to 'public'
as $$
declare
  v_account_id uuid;
  v_status text;
  v_now timestamptz := now();
begin
  if auth.uid() is null then
    raise exception 'END_OF_LIFE_REJECTED: authentication required';
  end if;

  select s.account_id, s.status
    into v_account_id, v_status
    from public.sh_instances s
   where s.sh_id = p_sh_id
     and s.account_id = public.current_account_id();

  if v_account_id is null then
    raise exception 'END_OF_LIFE_REJECTED: SH not owned by current account';
  end if;

  if v_status = 'deactivated' then
    return p_sh_id;
  end if;

  update public.sh_instances
     set status = 'deactivated',
         deactivated_at = coalesce(deactivated_at, v_now),
         metadata = metadata || jsonb_build_object(
           'end_of_life', jsonb_build_object(
             'occurred_at', v_now,
             'reason', p_reason
           )
         ),
         updated_at = v_now
   where sh_id = p_sh_id
     and account_id = v_account_id;

  update public.accounts
     set status = 'deactivated',
         deactivated_at = coalesce(deactivated_at, v_now),
         updated_at = v_now
   where account_id = v_account_id;

  insert into public.journey_events(
    sh_id, account_id, event_type, occurred_at, continuity_status,
    payload, source_ref, visibility, transfer_policy, provenance
  ) values (
    p_sh_id,
    v_account_id,
    'LIFECYCLE',
    v_now,
    'CONTINUOUS',
    jsonb_build_object('state','END_OF_LIFE','reason',p_reason),
    'end_of_life:' || p_sh_id::text,
    'PRIVATE',
    'NON_TRANSFERABLE',
    jsonb_build_object('source','runtime_end_of_life_sh','reason',p_reason)
  );

  return p_sh_id;
end;
$$;
