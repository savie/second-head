-- Reconcile Journey Context Retrieval with owner visibility semantics.
-- An authenticated account may retrieve its own Journey events regardless of
-- PRIVATE/OWNER_ONLY visibility; shared/public events remain retrievable.

create or replace function public.runtime_get_journey_context(
  p_sh_id uuid,
  p_limit integer default 20
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_account_id uuid;
  v_limit integer;
  v_events jsonb;
begin
  if auth.uid() is null then
    raise exception 'JOURNEY_CONTEXT_RETRIEVAL_REJECTED: authentication required';
  end if;

  v_limit := least(greatest(coalesce(p_limit,20),1),50);

  select s.account_id into v_account_id
  from public.sh_instances s
  where s.sh_id = p_sh_id
    and s.account_id = public.current_account_id()
    and s.status <> 'deactivated';

  if v_account_id is null then
    raise exception 'JOURNEY_CONTEXT_RETRIEVAL_REJECTED: SH not owned by current account';
  end if;

  select coalesce(jsonb_agg(
    jsonb_build_object(
      'event_id', j.event_id,
      'event_type', j.event_type,
      'occurred_at', j.occurred_at,
      'continuity_status', j.continuity_status,
      'gap_code', j.gap_code,
      'payload', j.payload,
      'source_ref', j.source_ref,
      'provenance', coalesce(j.provenance,'{}'::jsonb)
    ) order by j.occurred_at desc
  ), '[]'::jsonb)
  into v_events
  from (
    select *
    from public.journey_events
    where sh_id = p_sh_id
      and (
        account_id = v_account_id
        or visibility in ('SHARED','PUBLIC')
      )
    order by occurred_at desc
    limit v_limit
  ) j;

  return jsonb_build_object(
    'events', v_events,
    'retrieval_limit', v_limit
  );
end;
$$;

grant execute on function public.runtime_get_journey_context(uuid, integer) to authenticated;
grant execute on function public.runtime_get_journey_context(uuid, integer) to service_role;
revoke execute on function public.runtime_get_journey_context(uuid, integer) from public;
revoke execute on function public.runtime_get_journey_context(uuid, integer) from anon;
