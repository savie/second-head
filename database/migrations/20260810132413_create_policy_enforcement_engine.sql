create or replace function private.policy_enforcement_engine(
  p_authority_domain text,
  p_action text,
  p_target_domain text,
  p_target_sh_id uuid default null,
  p_actor_account_id uuid default null
)
returns boolean
language plpgsql
stable
security invoker
set search_path = ''
as $$
declare
  v_decision text;
begin
  select ge.decision into v_decision
  from private.governance_evaluator(p_authority_domain, p_action, p_target_domain, p_target_sh_id, p_actor_account_id) ge
  limit 1;
  return coalesce(v_decision = 'ALLOW', false);
end;
$$;

revoke execute on function private.policy_enforcement_engine(text,text,text,uuid,uuid) from public;
revoke execute on function private.policy_enforcement_engine(text,text,text,uuid,uuid) from anon;
grant usage on schema private to authenticated;
grant execute on function private.policy_enforcement_engine(text,text,text,uuid,uuid) to authenticated;
