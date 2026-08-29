-- R4 bounded Google Calendar CREATE EVENT action lifecycle.
-- This is a bounded R4 vertical slice. It does not generalize the recovery
-- confirmation engine or redefine the global permission matrix.

create table if not exists public.r4_google_calendar_actions (
  action_id uuid primary key,
  account_id uuid not null references public.accounts(account_id) on delete cascade,
  sh_id uuid not null references public.sh_instances(sh_id) on delete cascade,
  actor_id uuid not null,
  operation text not null check (operation = 'CREATE_EVENT'),
  target_id text not null default 'primary' check (target_id = 'primary'),
  risk text not null check (risk = 'HIGH'),
  status text not null check (status in ('PENDING','CONFIRMED','EXECUTING','EXECUTED','FAILED','EXPIRED')),
  confirmation_id uuid not null unique,
  confirmation_expires_at timestamptz not null,
  input jsonb not null,
  input_hash text not null,
  external_event_id text,
  external_event_html_link text,
  result jsonb,
  error_code text,
  created_at timestamptz not null default now(),
  confirmed_at timestamptz,
  executed_at timestamptz,
  updated_at timestamptz not null default now()
);

create index if not exists r4_google_calendar_actions_account_idx
  on public.r4_google_calendar_actions(account_id, created_at desc);

create index if not exists r4_google_calendar_actions_status_idx
  on public.r4_google_calendar_actions(status, confirmation_expires_at);

alter table public.r4_google_calendar_actions enable row level security;

revoke all on public.r4_google_calendar_actions from anon, public, authenticated;
grant select on public.r4_google_calendar_actions to authenticated;

drop policy if exists r4_google_calendar_actions_select_own on public.r4_google_calendar_actions;
create policy r4_google_calendar_actions_select_own
on public.r4_google_calendar_actions
for select
to authenticated
using (account_id = public.current_account_id());

create or replace function public.r4_google_calendar_action_cleanup()
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  v_count integer;
begin
  if current_user <> 'postgres'
     and current_setting('request.jwt.claims', true)::jsonb->>'role' <> 'service_role' then
    raise exception 'R4_ACTION_CLEANUP_DENIED';
  end if;

  update public.r4_google_calendar_actions
     set status = 'EXPIRED', updated_at = now()
   where status in ('PENDING','CONFIRMED')
     and confirmation_expires_at < now();

  get diagnostics v_count = row_count;
  return v_count;
end;
$$;

revoke all on function public.r4_google_calendar_action_cleanup() from public, anon, authenticated;
grant execute on function public.r4_google_calendar_action_cleanup() to service_role;
