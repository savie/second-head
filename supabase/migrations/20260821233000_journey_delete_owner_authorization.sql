create or replace function public.runtime_delete_journey_event(p_event_id uuid)
returns void
language plpgsql
security definer
set search_path to 'public'
as $$
begin
  if auth.uid() is null then
    raise exception 'JOURNEY_DELETE_REJECTED: authentication required';
  end if;

  if p_event_id is null then
    raise exception 'JOURNEY_DELETE_REJECTED: event id required';
  end if;

  if not exists (
    select 1
    from public.journey_events j
    join public.sh_instances s on s.sh_id = j.sh_id
    where j.event_id = p_event_id
      and s.account_id = public.current_account_id()
      and s.status <> 'deactivated'
      and j.account_id = public.current_account_id()
  ) then
    raise exception 'JOURNEY_DELETE_REJECTED: event not owned by current account';
  end if;

  delete from public.journey_events
  where event_id = p_event_id;
end;
$$;

grant execute on function public.runtime_delete_journey_event(uuid) to authenticated;
