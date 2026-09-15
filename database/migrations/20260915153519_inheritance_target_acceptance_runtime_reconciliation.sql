create or replace function public.runtime_approve_inheritance_authorization_target(p_authorization_id uuid)
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
  if v_auth.target_account_id <> public.current_account_id() then
    raise exception 'INHERITANCE_APPROVAL_REJECTED: target account approval required';
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

create or replace function public.runtime_reject_inheritance_authorization_target(p_authorization_id uuid)
returns public.inheritance_authorizations
language plpgsql
security definer
set search_path = public
as $$
declare
  v_auth public.inheritance_authorizations%rowtype;
begin
  if auth.uid() is null then
    raise exception 'INHERITANCE_REJECT_REJECTED: authentication required';
  end if;

  select * into v_auth
  from public.inheritance_authorizations
  where authorization_id = p_authorization_id
  for update;

  if not found then
    raise exception 'INHERITANCE_REJECT_REJECTED: authorization not found';
  end if;
  if v_auth.target_account_id <> public.current_account_id() then
    raise exception 'INHERITANCE_REJECT_REJECTED: target account rejection required';
  end if;
  if v_auth.status <> 'PENDING' then
    raise exception 'INHERITANCE_REJECT_REJECTED: authorization is not pending';
  end if;

  update public.inheritance_authorizations
     set status = 'REVOKED', revoked_at = now()
   where authorization_id = p_authorization_id
  returning * into v_auth;

  return v_auth;
end;
$$;

grant execute on function public.runtime_approve_inheritance_authorization_target(uuid) to authenticated;
grant execute on function public.runtime_reject_inheritance_authorization_target(uuid) to authenticated;
revoke execute on function public.runtime_approve_inheritance_authorization_target(uuid) from anon, public;
revoke execute on function public.runtime_reject_inheritance_authorization_target(uuid) from anon, public;
