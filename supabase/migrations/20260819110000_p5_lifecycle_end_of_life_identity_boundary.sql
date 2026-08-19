-- P5 lifecycle reconciliation: permanent SH/account end-of-life boundary.
-- Owner decision: Account + SH remain permanently retained as identity/history;
-- both become non-active; email remains reserved by retained Account row.

alter table public.accounts
  add column if not exists deactivated_at timestamptz;

alter table public.sh_instances
  add column if not exists deactivated_at timestamptz;

comment on column public.accounts.deactivated_at is
  'Permanent account lifecycle end timestamp. Row is retained for identity/history and email reservation.';

comment on column public.sh_instances.deactivated_at is
  'Permanent SH lifecycle end timestamp. SH identity/history is retained; reactivation is forbidden.';

create or replace function public.runtime_end_of_life_sh(p_sh_id uuid, p_reason text default null)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_account_id uuid;
  v_status text;
begin
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
         deactivated_at = coalesce(deactivated_at, now()),
         metadata = metadata || jsonb_build_object(
           'end_of_life', jsonb_build_object(
             'occurred_at', coalesce(deactivated_at, now()),
             'reason', p_reason
           )
         ),
         updated_at = now()
   where sh_id = p_sh_id
     and account_id = v_account_id;

  update public.accounts
     set status = 'deactivated',
         deactivated_at = coalesce(deactivated_at, now()),
         updated_at = now()
   where account_id = v_account_id;

  return p_sh_id;
end;
$$;

grant execute on function public.runtime_end_of_life_sh(uuid, text) to authenticated;

create or replace function public.prevent_identity_reactivation()
returns trigger
language plpgsql
as $$
begin
  if old.status = 'deactivated' and new.status <> 'deactivated' then
    raise exception 'IDENTITY_LIFECYCLE_TERMINAL: deactivated identity cannot be reactivated';
  end if;
  return new;
end;
$$;

drop trigger if exists accounts_prevent_reactivation on public.accounts;
create trigger accounts_prevent_reactivation
before update on public.accounts
for each row execute function public.prevent_identity_reactivation();

drop trigger if exists sh_instances_prevent_reactivation on public.sh_instances;
create trigger sh_instances_prevent_reactivation
before update on public.sh_instances
for each row execute function public.prevent_identity_reactivation();

comment on function public.runtime_end_of_life_sh(uuid, text) is
  'Owner-approved terminal lifecycle operation: permanently deactivates the owned SH and its Account while retaining identity/history and the Account email reservation. Idempotent; no reactivation path.';

comment on function public.prevent_identity_reactivation() is
  'Terminal lifecycle guard for Account/SH identity: DEACTIVATED cannot transition back to an active/created state.';
