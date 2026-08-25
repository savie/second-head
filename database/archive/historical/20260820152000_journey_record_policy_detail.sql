-- Journey record detail policy bridge.
-- Resolves an owner-visible Journey event to its underlying Memory,
-- Knowledge, or Experience record without making Journey the authority.

create or replace function public.runtime_get_journey_record_policy(p_event_id uuid)
returns table (
  domain text,
  record_id uuid,
  scope text,
  visibility text,
  transfer_policy text
)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_event public.journey_events%rowtype;
  v_id uuid;
  v_count integer;
begin
  if auth.uid() is null then
    raise exception 'JOURNEY_RECORD_POLICY_REJECTED: authentication required';
  end if;

  select * into v_event
  from public.journey_events e
  where e.event_id = p_event_id
    and exists (
      select 1 from public.sh_instances s
      where s.sh_id = e.sh_id
        and s.account_id = public.current_account_id()
        and s.status <> 'deactivated'
    );

  if not found then
    raise exception 'JOURNEY_RECORD_POLICY_REJECTED: event not found or not owner-visible';
  end if;

  if upper(v_event.event_type) = 'MEMORY' then
    v_id := nullif(v_event.payload ->> 'memory_id', '')::uuid;
    if v_id is null then
      return;
    end if;
    return query
      select 'MEMORY', m.memory_id, m.scope, m.visibility, m.transfer_policy
      from public.memories m
      where m.memory_id = v_id and m.sh_id = v_event.sh_id;
    return;
  end if;

  if upper(v_event.event_type) in ('LEARNING','KNOWLEDGE') then
    v_id := nullif(v_event.payload ->> 'knowledge_id', '')::uuid;
    if v_id is null then
      return;
    end if;
    return query
      select 'KNOWLEDGE', k.knowledge_id, k.scope, k.visibility, k.transfer_policy
      from public.knowledge k
      where k.knowledge_id = v_id and k.sh_id = v_event.sh_id;
    return;
  end if;

  if upper(v_event.event_type) = 'EXPERIENCE' then
    v_id := nullif(v_event.payload ->> 'experience_id', '')::uuid;
    if v_id is not null then
      return query
        select 'EXPERIENCE', x.experience_id, x.scope, x.visibility, x.transfer_policy
        from public.experiences x
        where x.experience_id = v_id and x.sh_id = v_event.sh_id and x.account_id = public.current_account_id();
      return;
    end if;

    -- Backward-compatible resolution for older explicit Journey captures that
    -- predate experience_id in the event payload. Only an exact owner-scoped
    -- source/content match is accepted; ambiguous matches are rejected.
    select count(*), max(x.experience_id)
      into v_count, v_id
    from public.experiences x
    where x.sh_id = v_event.sh_id
      and x.account_id = public.current_account_id()
      and x.source_ref = 'runtime:p5a:explicit_user_capture'
      and x.content = coalesce(v_event.payload ->> 'representation', '');

    if v_count <> 1 then
      return;
    end if;

    return query
      select 'EXPERIENCE', x.experience_id, x.scope, x.visibility, x.transfer_policy
      from public.experiences x
      where x.experience_id = v_id;
    return;
  end if;

  return;
end;
$$;

grant execute on function public.runtime_get_journey_record_policy(uuid) to authenticated;
