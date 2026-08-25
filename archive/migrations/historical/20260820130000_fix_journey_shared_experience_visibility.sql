-- TC-EXP-06 visibility reconciliation.
-- Journey is a projection; PRIVATE/OWNER_ONLY records remain owner-only,
-- while GENERAL/SHARED underlying Memory/Knowledge/Experience records may
-- appear to other authenticated accounts through Journey.

create or replace function public.runtime_journey_event_is_shared(p_event_id uuid)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
declare
  v_event public.journey_events%rowtype;
  v_id uuid;
  v_shared boolean := false;
begin
  if auth.uid() is null or p_event_id is null then
    return false;
  end if;

  select * into v_event
  from public.journey_events e
  where e.event_id = p_event_id;

  if not found then
    return false;
  end if;

  if upper(v_event.event_type) = 'MEMORY' then
    v_id := nullif(v_event.payload ->> 'memory_id', '')::uuid;
    if v_id is null then return false; end if;
    select (m.scope = 'GENERAL' and m.visibility = 'SHARED')
      into v_shared
    from public.memories m
    where m.memory_id = v_id and m.sh_id = v_event.sh_id;
    return coalesce(v_shared, false);
  end if;

  if upper(v_event.event_type) in ('LEARNING','KNOWLEDGE') then
    v_id := nullif(v_event.payload ->> 'knowledge_id', '')::uuid;
    if v_id is null then return false; end if;
    select (k.scope = 'GENERAL' and k.visibility = 'SHARED')
      into v_shared
    from public.knowledge k
    where k.knowledge_id = v_id and k.sh_id = v_event.sh_id;
    return coalesce(v_shared, false);
  end if;

  if upper(v_event.event_type) = 'EXPERIENCE' then
    v_id := nullif(v_event.payload ->> 'experience_id', '')::uuid;
    if v_id is not null then
      select (x.scope = 'GENERAL' and x.visibility = 'SHARED')
        into v_shared
      from public.experiences x
      where x.experience_id = v_id and x.sh_id = v_event.sh_id;
      return coalesce(v_shared, false);
    end if;

    -- Backward compatibility for older explicit captures without experience_id.
    select count(*) = 1 and bool_and(x.scope = 'GENERAL' and x.visibility = 'SHARED')
      into v_shared
    from public.experiences x
    where x.sh_id = v_event.sh_id
      and x.source_ref = 'runtime:p5a:explicit_user_capture'
      and x.content = coalesce(v_event.payload ->> 'representation', '');
    return coalesce(v_shared, false);
  end if;

  return false;
end;
$$;

revoke all on function public.runtime_journey_event_is_shared(uuid) from public;
grant execute on function public.runtime_journey_event_is_shared(uuid) to authenticated;

drop policy if exists journey_events_owner_select on public.journey_events;

create policy journey_events_visibility_select
  on public.journey_events
  for select to authenticated
  using (
    exists (
      select 1
      from public.sh_instances s
      where s.sh_id = journey_events.sh_id
        and s.account_id = public.current_account_id()
    )
    or public.runtime_journey_event_is_shared(journey_events.event_id)
  );

comment on function public.runtime_journey_event_is_shared(uuid) is
  'Journey visibility bridge: exposes only GENERAL/SHARED underlying records to non-owner accounts; PRIVATE/OWNER_ONLY remains owner-scoped.';
