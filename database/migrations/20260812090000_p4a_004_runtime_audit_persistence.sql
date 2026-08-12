create table if not exists public.audit_events (
  event_id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  account_id uuid not null,
  sh_id uuid not null,
  event_type text not null check (event_type in ('RUNTIME_REQUEST','RUNTIME_RESPONSE','RUNTIME_MEMORY_DECISION')),
  status text not null check (status in ('SUCCESS','REJECTED','FAILED')),
  metadata jsonb not null default '{}'::jsonb
);

alter table public.audit_events enable row level security;

create policy audit_events_insert_own_sh
on public.audit_events
for insert to authenticated
with check (
  account_id = auth.uid()
  and exists (select 1 from public.sh_ownership o where o.account_id = auth.uid() and o.sh_id = audit_events.sh_id)
);

create policy audit_events_select_own_sh
on public.audit_events
for select to authenticated
using (
  account_id = auth.uid()
  and exists (select 1 from public.sh_ownership o where o.account_id = auth.uid() and o.sh_id = audit_events.sh_id)
);

create or replace function public.runtime_record_audit(
  p_sh_id uuid,
  p_event_type text,
  p_status text,
  p_metadata jsonb default '{}'::jsonb
)
returns public.audit_events
language plpgsql
security invoker
set search_path = public
as $$
declare v_row public.audit_events;
begin
  if auth.uid() is null then raise exception 'RUNTIME_AUDIT_REJECTED: authentication required'; end if;
  insert into public.audit_events (account_id, sh_id, event_type, status, metadata)
  select auth.uid(), p_sh_id, p_event_type, p_status, coalesce(p_metadata, '{}'::jsonb)
  where exists (select 1 from public.sh_ownership o where o.account_id = auth.uid() and o.sh_id = p_sh_id)
  returning * into v_row;
  if v_row.event_id is null then raise exception 'RUNTIME_AUDIT_REJECTED: SH ownership boundary failed'; end if;
  return v_row;
end;
$$;

grant execute on function public.runtime_record_audit(uuid, text, text, jsonb) to authenticated;
