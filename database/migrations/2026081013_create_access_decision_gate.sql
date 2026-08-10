create or replace function private.access_decision_gate(
  p_authority_domain text,
  p_action text,
  p_target_domain text,
  p_target_sh_id uuid default null,
  p_actor_account_id uuid default null
)
returns table(
  decision text,
  reason text
)
language plpgsql
security definer
set search_path = private, public, pg_temp
as $$
declare
  v_governance_decision text;
  v_governance_reason text;
  v_policy_allowed boolean;
  v_isolation_decision text;
  v_isolation_reason text;
begin
  select ge.decision, ge.reason
    into v_governance_decision, v_governance_reason
  from private.governance_evaluator(
    p_authority_domain,
    p_action,
    p_target_domain,
    p_target_sh_id,
    p_actor_account_id
  ) ge;

  if v_governance_decision is null then
    return query select 'REJECT'::text, 'governance evaluator returned no decision; fail closed'::text;
    return;
  end if;

  if v_governance_decision = 'ESCALATE' then
    return query select 'ESCALATE'::text, coalesce(v_governance_reason, 'governance review required')::text;
    return;
  end if;

  if v_governance_decision <> 'ALLOW' then
    return query select 'REJECT'::text, coalesce(v_governance_reason, 'governance authorization denied')::text;
    return;
  end if;

  v_policy_allowed := private.policy_enforcement_engine(
    p_authority_domain,
    p_action,
    p_target_domain,
    p_target_sh_id,
    p_actor_account_id
  );

  if coalesce(v_policy_allowed, false) is not true then
    return query select 'REJECT'::text, 'policy enforcement denied access'::text;
    return;
  end if;

  select ic.decision, ic.reason
    into v_isolation_decision, v_isolation_reason
  from private.isolation_checker(
    p_target_domain,
    p_target_sh_id,
    p_actor_account_id
  ) ic;

  if v_isolation_decision is distinct from 'PASS' then
    return query select 'REJECT'::text, coalesce(v_isolation_reason, 'isolation check failed; fail closed')::text;
    return;
  end if;

  return query select 'PASS'::text, 'governance, policy enforcement, and isolation checks passed'::text;
end;
$$;

revoke all on function private.access_decision_gate(text,text,text,uuid,uuid) from public;
revoke all on function private.access_decision_gate(text,text,text,uuid,uuid) from anon;
grant execute on function private.access_decision_gate(text,text,text,uuid,uuid) to authenticated;
