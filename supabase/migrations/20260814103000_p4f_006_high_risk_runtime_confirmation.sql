create table if not exists public.runtime_high_risk_confirmations (
  confirmation_id uuid primary key default gen_random_uuid(),
  action_id text not null unique,
  account_id uuid not null,
  sh_id uuid not null,
  actor_id uuid not null,
  operation text not null,
  risk text not null check (risk = 'HIGH'),
  status text not null check (status in ('PENDING','CONFIRMED','EXECUTED','CANCELLED','EXPIRED')),
  target_id uuid not null,
  title text not null,
  description text not null,
  created_at timestamptz not null default now(),
  expires_at timestamptz not null default (now() + interval '10 minutes'),
  confirmed_at timestamptz,
  executed_at timestamptz
);

alter table public.runtime_high_risk_confirmations enable row level security;
revoke all on public.runtime_high_risk_confirmations from anon, authenticated;

create index if not exists runtime_high_risk_confirmations_account_idx
  on public.runtime_high_risk_confirmations(account_id, created_at desc);
create index if not exists runtime_high_risk_confirmations_status_idx
  on public.runtime_high_risk_confirmations(status, expires_at);

alter table public.audit_events drop constraint if exists audit_events_event_type_check;
alter table public.audit_events add constraint audit_events_event_type_check
  check (event_type = any (array['RUNTIME_REQUEST','RUNTIME_RESPONSE','RUNTIME_MEMORY_DECISION','TOOL_INVOCATION','RUNTIME_ACTION']));

create or replace function public.runtime_record_audit(
  p_sh_id uuid, p_event_type text, p_status text, p_metadata jsonb default '{}'::jsonb
)
returns public.audit_events language plpgsql security definer set search_path = public
as $$
declare v_identity record; v_row public.audit_events;
begin
  select * into v_identity from public.resolve_identity();
  if v_identity.account_id is null or v_identity.sh_id is null then raise exception 'RUNTIME_AUDIT_REJECTED: authenticated identity could not be resolved'; end if;
  if p_sh_id <> v_identity.sh_id then raise exception 'RUNTIME_AUDIT_REJECTED: SH ownership boundary failed'; end if;
  if p_event_type not in ('RUNTIME_REQUEST','RUNTIME_RESPONSE','RUNTIME_MEMORY_DECISION','TOOL_INVOCATION','RUNTIME_ACTION') then raise exception 'RUNTIME_AUDIT_REJECTED: invalid event type'; end if;
  if p_status not in ('SUCCESS','REJECTED','FAILED') then raise exception 'RUNTIME_AUDIT_REJECTED: invalid status'; end if;
  insert into public.audit_events(account_id, sh_id, event_type, status, metadata)
  values(v_identity.account_id, v_identity.sh_id, p_event_type, p_status, coalesce(p_metadata,'{}'::jsonb))
  returning * into v_row;
  return v_row;
end; $$;
revoke all on function public.runtime_record_audit(uuid,text,text,jsonb) from public;
grant execute on function public.runtime_record_audit(uuid,text,text,jsonb) to authenticated;

create or replace function public.runtime_create_high_risk_confirmation(
  p_action_id text, p_operation text, p_target_id uuid, p_title text, p_description text
) returns uuid language plpgsql security definer set search_path = public
as $$
declare v_identity record; v_confirmation_id uuid;
begin
  select * into v_identity from public.resolve_identity();
  if v_identity.account_id is null or v_identity.sh_id is null then raise exception 'HIGH_RISK_REJECTED: authenticated identity could not be resolved'; end if;
  if nullif(btrim(p_action_id),'') is null then raise exception 'HIGH_RISK_REJECTED: action_id is required'; end if;
  if nullif(btrim(p_operation),'') is null then raise exception 'HIGH_RISK_REJECTED: operation is required'; end if;
  if p_operation <> 'RECOVERY_RESTORE' then raise exception 'HIGH_RISK_REJECTED: unsupported high-risk operation'; end if;
  if p_target_id is null then raise exception 'HIGH_RISK_REJECTED: target_id is required'; end if;
  if not exists (select 1 from public.recovery_snapshots rs where rs.snapshot_id=p_target_id and rs.account_id=v_identity.account_id and rs.sh_id=v_identity.sh_id) then raise exception 'HIGH_RISK_REJECTED: recovery snapshot is not accessible'; end if;
  insert into public.runtime_high_risk_confirmations(action_id,account_id,sh_id,actor_id,operation,risk,status,target_id,title,description)
  values(p_action_id,v_identity.account_id,v_identity.sh_id,auth.uid(),p_operation,'HIGH','PENDING',p_target_id,coalesce(nullif(btrim(p_title),''),'Confirm recovery restore'),coalesce(nullif(btrim(p_description),''),'Restore this SH recovery snapshot.'))
  returning confirmation_id into v_confirmation_id;
  perform public.runtime_record_audit(v_identity.sh_id,'RUNTIME_ACTION','SUCCESS',jsonb_build_object('action','HIGH_RISK_CONFIRMATION_CREATED','action_id',p_action_id,'operation',p_operation,'confirmation_id',v_confirmation_id,'target_id',p_target_id));
  return v_confirmation_id;
end; $$;

create or replace function public.runtime_confirm_high_risk_action(p_confirmation_id uuid)
returns uuid language plpgsql security definer set search_path = public
as $$
declare v_identity record; v_row public.runtime_high_risk_confirmations%rowtype;
begin
  select * into v_identity from public.resolve_identity();
  if v_identity.account_id is null or v_identity.sh_id is null then raise exception 'HIGH_RISK_REJECTED: authenticated identity could not be resolved'; end if;
  select * into v_row from public.runtime_high_risk_confirmations where confirmation_id=p_confirmation_id and account_id=v_identity.account_id and sh_id=v_identity.sh_id for update;
  if not found then raise exception 'HIGH_RISK_CONFIRMATION_REJECTED: confirmation not accessible'; end if;
  if v_row.status <> 'PENDING' then raise exception 'HIGH_RISK_CONFIRMATION_REJECTED: confirmation is not pending'; end if;
  if v_row.expires_at <= now() then update public.runtime_high_risk_confirmations set status='EXPIRED' where confirmation_id=p_confirmation_id; raise exception 'HIGH_RISK_CONFIRMATION_REJECTED: confirmation expired'; end if;
  update public.runtime_high_risk_confirmations set status='CONFIRMED', confirmed_at=now() where confirmation_id=p_confirmation_id;
  perform public.runtime_record_audit(v_identity.sh_id,'RUNTIME_ACTION','SUCCESS',jsonb_build_object('action','HIGH_RISK_CONFIRMATION_CONFIRMED','action_id',v_row.action_id,'operation',v_row.operation,'confirmation_id',p_confirmation_id,'target_id',v_row.target_id));
  return p_confirmation_id;
end; $$;

create or replace function public.runtime_execute_high_risk_action(p_confirmation_id uuid)
returns uuid language plpgsql security definer set search_path = public
as $$
declare v_identity record; v_row public.runtime_high_risk_confirmations%rowtype; v_recovery_event_id uuid;
begin
  select * into v_identity from public.resolve_identity();
  if v_identity.account_id is null or v_identity.sh_id is null then raise exception 'HIGH_RISK_REJECTED: authenticated identity could not be resolved'; end if;
  select * into v_row from public.runtime_high_risk_confirmations where confirmation_id=p_confirmation_id and account_id=v_identity.account_id and sh_id=v_identity.sh_id for update;
  if not found then raise exception 'HIGH_RISK_EXECUTION_REJECTED: confirmation not accessible'; end if;
  if v_row.status <> 'CONFIRMED' then raise exception 'HIGH_RISK_EXECUTION_REJECTED: confirmed action required'; end if;
  if v_row.expires_at <= now() then update public.runtime_high_risk_confirmations set status='EXPIRED' where confirmation_id=p_confirmation_id; raise exception 'HIGH_RISK_EXECUTION_REJECTED: confirmation expired'; end if;
  if v_row.actor_id <> auth.uid() or v_row.account_id <> v_identity.account_id or v_row.sh_id <> v_identity.sh_id then raise exception 'HIGH_RISK_EXECUTION_REJECTED: actor/ownership boundary failed'; end if;
  if v_row.operation <> 'RECOVERY_RESTORE' then raise exception 'HIGH_RISK_EXECUTION_REJECTED: unsupported operation'; end if;
  if not exists (select 1 from public.recovery_snapshots rs where rs.snapshot_id=v_row.target_id and rs.account_id=v_identity.account_id and rs.sh_id=v_identity.sh_id) then raise exception 'HIGH_RISK_EXECUTION_REJECTED: target snapshot no longer accessible'; end if;
  v_recovery_event_id := public.runtime_restore_recovery_snapshot(v_row.target_id);
  update public.runtime_high_risk_confirmations set status='EXECUTED', executed_at=now() where confirmation_id=p_confirmation_id;
  perform public.runtime_record_audit(v_identity.sh_id,'RUNTIME_ACTION','SUCCESS',jsonb_build_object('action','HIGH_RISK_ACTION_EXECUTED','action_id',v_row.action_id,'operation',v_row.operation,'confirmation_id',p_confirmation_id,'target_id',v_row.target_id,'recovery_event_id',v_recovery_event_id,'revalidated_at',now()));
  return v_recovery_event_id;
end; $$;

revoke all on function public.runtime_create_high_risk_confirmation(text,text,uuid,text,text) from public;
revoke all on function public.runtime_confirm_high_risk_action(uuid) from public;
revoke all on function public.runtime_execute_high_risk_action(uuid) from public;
grant execute on function public.runtime_create_high_risk_confirmation(text,text,uuid,text,text) to authenticated;
grant execute on function public.runtime_confirm_high_risk_action(uuid) to authenticated;
grant execute on function public.runtime_execute_high_risk_action(uuid) to authenticated;
