-- Reconcile lifecycle request creation with the canonical status vocabulary.
-- Succession has no separate approval state in the current contract; ACTIVE is
-- the executable request state consumed by runtime_execute_succession.
create or replace function public.runtime_create_succession_rule_by_email(
  p_target_email text,
  p_scope jsonb default '{}'::jsonb
)
returns public.succession_rules
language plpgsql
security definer
set search_path = public
as $$
declare
  v_source_account_id uuid;
  v_source_sh_id uuid;
  v_successor_account_id uuid;
  v_rule public.succession_rules%rowtype;
begin
  if auth.uid() is null then
    raise exception 'SUCCESSION_REQUEST_REJECTED: authentication required';
  end if;

  v_source_account_id := public.current_account_id();
  select s.sh_id into v_source_sh_id
    from public.sh_instances s
   where s.account_id = v_source_account_id
     and s.status <> 'deactivated'
   order by s.is_primary desc, s.created_at asc
   limit 1;

  if v_source_sh_id is null then
    raise exception 'SUCCESSION_REQUEST_REJECTED: active source SH required';
  end if;

  select a.account_id into v_successor_account_id
    from public.accounts a
   where lower(trim(a.email)) = lower(trim(p_target_email))
     and a.status <> 'deactivated'
   limit 1;

  if v_successor_account_id is null then
    raise exception 'SUCCESSION_REQUEST_REJECTED: target email is not an active account';
  end if;
  if v_successor_account_id = v_source_account_id then
    raise exception 'SUCCESSION_REQUEST_REJECTED: source and successor accounts must differ';
  end if;

  insert into public.succession_rules(source_sh_id, successor_account_id, status, scope)
  values (v_source_sh_id, v_successor_account_id, 'ACTIVE', coalesce(p_scope, '{}'::jsonb))
  returning * into v_rule;

  return v_rule;
end;
$$;

grant execute on function public.runtime_create_succession_rule_by_email(text,jsonb) to authenticated;
revoke execute on function public.runtime_create_succession_rule_by_email(text,jsonb) from anon;

-- Inheritance follows the existing contract: the source owner is the approving
-- authority, and execution requires APPROVED status.
create or replace function public.runtime_approve_inheritance_authorization(
  p_authorization_id uuid
)
returns public.inheritance_authorizations
language plpgsql
security definer
set search_path = public
as $$
declare
  v_auth public.inheritance_authorizations%rowtype;
begin
  if auth.uid() is null then
    raise exception 'INHERITANCE_APPROVAL_REJECTED: authentication required';
  end if;

  select * into v_auth
    from public.inheritance_authorizations
   where authorization_id = p_authorization_id
   for update;

  if not found then
    raise exception 'INHERITANCE_APPROVAL_REJECTED: authorization not found';
  end if;
  if v_auth.source_account_id <> public.current_account_id() then
    raise exception 'INHERITANCE_APPROVAL_REJECTED: source owner approval required';
  end if;
  if v_auth.status <> 'PENDING' then
    raise exception 'INHERITANCE_APPROVAL_REJECTED: authorization is not pending';
  end if;

  update public.inheritance_authorizations
     set status = 'APPROVED', approved_at = now()
   where authorization_id = p_authorization_id
  returning * into v_auth;

  return v_auth;
end;
$$;

grant execute on function public.runtime_approve_inheritance_authorization(uuid) to authenticated;
revoke execute on function public.runtime_approve_inheritance_authorization(uuid) from anon;
