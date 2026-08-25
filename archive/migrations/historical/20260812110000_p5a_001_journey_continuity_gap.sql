create table if not exists public.journey_events (
  event_id uuid primary key default gen_random_uuid(),
  sh_id uuid not null references public.sh_instances(sh_id) on delete restrict,
  account_id uuid not null references public.accounts(account_id) on delete restrict,
  event_type text not null check (event_type in (
    'LIFECYCLE', 'EXPERIENCE', 'MEMORY', 'LEARNING', 'EVOLUTION',
    'MIGRATION', 'RECOVERY', 'CONTINUITY', 'SHARING', 'INHERITANCE', 'LEGACY'
  )),
  occurred_at timestamptz not null default now(),
  continuity_status text not null default 'CONTINUOUS' check (
    continuity_status in ('CONTINUOUS', 'GAP_DETECTED', 'GAP_UNRESOLVED', 'RECOVERED')
  ),
  gap_code text,
  payload jsonb not null default '{}'::jsonb,
  source_ref text,
  created_at timestamptz not null default now(),
  constraint journey_events_gap_code_ck check (
    (continuity_status in ('GAP_DETECTED', 'GAP_UNRESOLVED') and nullif(btrim(gap_code), '') is not null)
    or continuity_status in ('CONTINUOUS', 'RECOVERED')
  )
);

create index if not exists journey_events_sh_occurred_idx
  on public.journey_events (sh_id, occurred_at desc);

create index if not exists journey_events_gap_idx
  on public.journey_events (sh_id, continuity_status, occurred_at desc)
  where continuity_status in ('GAP_DETECTED', 'GAP_UNRESOLVED');

alter table public.journey_events enable row level security;

create policy journey_events_owner_select
  on public.journey_events
  for select
  using (
    exists (
      select 1
      from public.sh_instances s
      where s.sh_id = journey_events.sh_id
        and s.account_id = current_account_id()
    )
  );

create policy journey_events_owner_insert
  on public.journey_events
  for insert
  with check (
    account_id = current_account_id()
    and exists (
      select 1
      from public.sh_instances s
      where s.sh_id = journey_events.sh_id
        and s.account_id = current_account_id()
    )
  );

create or replace function public.runtime_record_journey_event(
  p_sh_id uuid,
  p_event_type text,
  p_occurred_at timestamptz default now(),
  p_continuity_status text default 'CONTINUOUS',
  p_gap_code text default null,
  p_payload jsonb default '{}'::jsonb,
  p_source_ref text default null
)
returns uuid
language plpgsql
security invoker
set search_path = public
as $$
declare
  v_event_id uuid;
  v_account_id uuid;
begin
  select s.account_id
    into v_account_id
  from public.sh_instances s
  where s.sh_id = p_sh_id
    and s.account_id = current_account_id();

  if v_account_id is null then
    raise exception 'JOURNEY_REJECTED: SH not owned by current account';
  end if;

  if p_event_type not in (
    'LIFECYCLE', 'EXPERIENCE', 'MEMORY', 'LEARNING', 'EVOLUTION',
    'MIGRATION', 'RECOVERY', 'CONTINUITY', 'SHARING', 'INHERITANCE', 'LEGACY'
  ) then
    raise exception 'JOURNEY_REJECTED: invalid event_type';
  end if;

  if p_continuity_status not in ('CONTINUOUS', 'GAP_DETECTED', 'GAP_UNRESOLVED', 'RECOVERED') then
    raise exception 'JOURNEY_REJECTED: invalid continuity_status';
  end if;

  if p_continuity_status in ('GAP_DETECTED', 'GAP_UNRESOLVED')
     and nullif(btrim(coalesce(p_gap_code, '')), '') is null then
    raise exception 'JOURNEY_REJECTED: gap_code required for continuity gap';
  end if;

  insert into public.journey_events (
    sh_id, account_id, event_type, occurred_at,
    continuity_status, gap_code, payload, source_ref
  ) values (
    p_sh_id, v_account_id, p_event_type, coalesce(p_occurred_at, now()),
    p_continuity_status, nullif(btrim(p_gap_code), ''), coalesce(p_payload, '{}'::jsonb),
    nullif(btrim(p_source_ref), '')
  )
  returning event_id into v_event_id;

  return v_event_id;
end;
$$;

grant execute on function public.runtime_record_journey_event(uuid, text, timestamptz, text, text, jsonb, text) to authenticated;
