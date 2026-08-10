create schema if not exists private;

create table if not exists private.authority_assignments (
  account_id uuid primary key references public.accounts(account_id) on delete cascade,
  authority text not null,
  active boolean not null default true,
  created_at timestamptz not null default now(),
  constraint authority_assignments_authority_chk check (authority in ('CREATOR'))
);

revoke all on table private.authority_assignments from public, anon, authenticated;

insert into private.authority_assignments (account_id, authority, active)
values ('c0b99e98-6c75-4d11-9ec0-84e15e87c23d'::uuid, 'CREATOR', true)
on conflict (account_id) do update
set authority = excluded.authority,
    active = excluded.active;

create or replace function private.governance_evaluator(
  p_authority_domain text,
  p_action text,
  p_target_domain text,
  p_target_sh_id uuid default null,
  p_actor_account_id uuid default null
)
returns table (
  decision text,
  actor text,
  account_id uuid,
  target_sh_relation text,
  matched_rule_id bigint,
  reason text
)
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_auth_uid uuid;
  v_account_id uuid;
  v_actor text;
  v_target_relation text;
  v_rule record;
  v_ownership_validated boolean := false;
begin
  v_auth_uid := auth.uid();

  if v_auth_uid is null then
    return query select 'DENY'::text, 'UNAUTHENTICATED'::text, null::uuid, null::text, null::bigint, 'trusted identity context is absent; fail closed'::text;
    return;
  end if;

  select public.current_account_id() into v_account_id;

  if v_account_id is null then
    return query select 'DENY'::text, 'UNRESOLVED_IDENTITY'::text, null::uuid, null::text, null::bigint, 'authenticated subject has no resolved ACCOUNT_ID; fail closed'::text;
    return;
  end if;

  if p_actor_account_id is not null and p_actor_account_id <> v_account_id then
    return query select 'DENY'::text, 'ACCOUNT_OWNER'::text, v_account_id, null::text, null::bigint, 'caller-supplied account identity does not match trusted identity context'::text;
    return;
  end if;

  select case when exists (
    select 1 from private.authority_assignments aa
    where aa.account_id = v_account_id and aa.authority = 'CREATOR' and aa.active
  ) then 'CREATOR' else 'ACCOUNT_OWNER' end into v_actor;

  if p_target_sh_id is null then
    v_target_relation := 'SYSTEM';
  elsif exists (
    select 1 from public.sh_ownership o
    where o.sh_id = p_target_sh_id and o.account_id = v_account_id
  ) then
    v_target_relation := 'SELF';
    v_ownership_validated := true;
  else
    v_target_relation := 'OTHER';
  end if;

  select pm.permission_rule_id, pm.decision, pm.scope_conditions
    into v_rule
    from public.permission_matrix pm
   where pm.actor = v_actor
     and pm.authority_domain = p_authority_domain
     and pm.action = p_action
     and pm.target_domain = p_target_domain
     and pm.target_sh = v_target_relation
   order by
     case when pm.decision = 'DENY' then 0 else 1 end,
     case when cardinality(pm.scope_conditions) = 0 then 0 else 1 end,
     pm.permission_rule_id
   limit 1;

  if not found then
    return query select 'DENY'::text, v_actor, v_account_id, v_target_relation, null::bigint, 'no matching permission rule; default deny'::text;
    return;
  end if;

  if v_rule.decision = 'DENY' then
    return query select 'DENY'::text, v_actor, v_account_id, v_target_relation, v_rule.permission_rule_id, 'permission matrix rule is DENY'::text;
    return;
  end if;

  if 'OWNERSHIP_VALIDATED' = any(v_rule.scope_conditions) and not v_ownership_validated then
    return query select 'DENY'::text, v_actor, v_account_id, v_target_relation, v_rule.permission_rule_id, 'required ownership condition is not satisfied'::text;
    return;
  end if;

  if 'EXPLICIT_SCOPED_AUTHORIZATION' = any(v_rule.scope_conditions) then
    return query select 'DENY'::text, v_actor, v_account_id, v_target_relation, v_rule.permission_rule_id, 'explicit scoped authorization is required but no trusted authorization source exists yet'::text;
    return;
  end if;

  if 'GOVERNANCE_PROCESS_REQUIRED' = any(v_rule.scope_conditions) then
    return query select 'ESCALATE'::text, v_actor, v_account_id, v_target_relation, v_rule.permission_rule_id, 'permission exists but requires governance process'::text;
    return;
  end if;

  return query select v_rule.decision::text, v_actor, v_account_id, v_target_relation, v_rule.permission_rule_id, 'permission matrix rule matched and required conditions are satisfied'::text;
end;
$$;

revoke execute on function private.governance_evaluator(text, text, text, uuid, uuid) from public;
revoke execute on function private.governance_evaluator(text, text, text, uuid, uuid) from anon;
grant usage on schema private to authenticated;
grant execute on function private.governance_evaluator(text, text, text, uuid, uuid) to authenticated;
