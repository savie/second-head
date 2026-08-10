create or replace function private.system_governance_boundary(
  p_action text,
  p_target_domain text,
  p_target_sh_id uuid default null,
  p_actor_account_id uuid default null
)
returns table(decision text, reason text)
language plpgsql
stable
security definer
set search_path = ''
as $function$
declare
  v_gate_decision text;
  v_gate_reason text;
begin
  -- Governance authority is bounded to system governance/core targets.
  -- It never becomes an implicit private-data access path.
  if p_target_domain in ('PRIVATE_MEMORY','PRIVATE_CONVERSATION','PRIVATE_CONTEXT') then
    return query select
      'REJECT'::text,
      'system governance authority does not grant omniscient private-data access'::text;
    return;
  end if;

  if p_target_domain not in ('SYSTEM_CORE','SYSTEM_GOVERNANCE') then
    return query select
      'REJECT'::text,
      'system governance boundary only permits system governance/core targets'::text;
    return;
  end if;

  if p_action not in ('GOVERN','EVOLVE') then
    return query select
      'REJECT'::text,
      'system governance boundary accepts only governance actions'::text;
    return;
  end if;

  select g.decision, g.reason
    into v_gate_decision, v_gate_reason
  from private.access_decision_gate(
    'GOVERNANCE',
    p_action,
    p_target_domain,
    p_target_sh_id,
    p_actor_account_id
  ) g;

  if v_gate_decision is null then
    return query select
      'REJECT'::text,
      'access decision gate returned no decision; fail closed'::text;
    return;
  end if;

  return query select v_gate_decision, coalesce(v_gate_reason, 'system governance boundary evaluated')::text;
end;
$function$;

revoke all on function private.system_governance_boundary(text,text,uuid,uuid) from public;
revoke all on function private.system_governance_boundary(text,text,uuid,uuid) from anon;
revoke all on function private.system_governance_boundary(text,text,uuid,uuid) from authenticated;
