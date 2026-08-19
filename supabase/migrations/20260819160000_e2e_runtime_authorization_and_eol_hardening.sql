-- E2E runtime hardening applied to Supabase DEV on 2026-08-19.
-- Keep privileged runtime RPCs unavailable to anon/public callers while
-- preserving authenticated application access.

revoke execute on function public.get_experience(uuid) from public;
grant execute on function public.get_experience(uuid) to authenticated;
revoke execute on function public.list_experiences(uuid, integer) from public;
grant execute on function public.list_experiences(uuid, integer) to authenticated;
revoke execute on function public.runtime_record_experience(uuid, text, text, text, text, text, jsonb, timestamptz) from public;
grant execute on function public.runtime_record_experience(uuid, text, text, text, text, text, jsonb, timestamptz) to authenticated;
revoke execute on function public.runtime_record_memory(uuid, text, text, text, numeric, text, text, text) from public;
grant execute on function public.runtime_record_memory(uuid, text, text, text, numeric, text, text, text) to authenticated;
revoke execute on function public.runtime_record_knowledge_candidate(uuid, text, text, text, jsonb, text, text, numeric) from public;
grant execute on function public.runtime_record_knowledge_candidate(uuid, text, text, text, jsonb, text, text, numeric) to authenticated;
revoke execute on function public.runtime_create_clone(uuid, text) from public;
grant execute on function public.runtime_create_clone(uuid, text) to authenticated;
revoke execute on function public.runtime_materialize_registered_clone() from public;
grant execute on function public.runtime_materialize_registered_clone() to authenticated;
revoke execute on function public.runtime_create_recovery_snapshot(uuid) from public;
grant execute on function public.runtime_create_recovery_snapshot(uuid) to authenticated;
revoke execute on function public.runtime_restore_recovery_snapshot(uuid) from public;
grant execute on function public.runtime_restore_recovery_snapshot(uuid) to authenticated;
revoke execute on function public.runtime_record_inheritance(uuid, jsonb, jsonb) from public;
grant execute on function public.runtime_record_inheritance(uuid, jsonb, jsonb) to authenticated;
revoke execute on function public.runtime_preserve_selected_journey_as_legacy(uuid, uuid[]) from public;
grant execute on function public.runtime_preserve_selected_journey_as_legacy(uuid, uuid[]) to authenticated;
revoke execute on function public.runtime_preserve_selected_transfer_as_legacy(uuid, jsonb) from public;
grant execute on function public.runtime_preserve_selected_transfer_as_legacy(uuid, jsonb) to authenticated;
revoke execute on function public.runtime_record_legacy(uuid, text, jsonb, jsonb, timestamptz) from public;
grant execute on function public.runtime_record_legacy(uuid, text, jsonb, jsonb, timestamptz) to authenticated;
revoke execute on function public.runtime_execute_succession(uuid) from public;
grant execute on function public.runtime_execute_succession(uuid) to authenticated;
revoke execute on function public.runtime_end_of_life_sh(uuid, text) from public;
grant execute on function public.runtime_end_of_life_sh(uuid, text) to authenticated;
revoke execute on function public.runtime_transfer_selected_journey_events(text, uuid, uuid, uuid[]) from public;
grant execute on function public.runtime_transfer_selected_journey_events(text, uuid, uuid, uuid[]) to authenticated;

-- EOL is a terminal lifecycle event and must be represented in Journey.
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
