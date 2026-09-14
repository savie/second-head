create or replace function public.runtime_create_inheritance_authorization_by_email(
  p_target_email text,
  p_scope jsonb default '{}'::jsonb
)
returns public.inheritance_authorizations
language plpgsql
security definer
set search_path = public
as $$
declare
  v_source_account_id uuid;
  v_source_sh_id uuid;
  v_target_account_id uuid;
  v_target_sh_id uuid;
begin
  if auth.uid() is null then
    raise exception 'INHERITANCE_AUTHORIZATION_REJECTED: authentication required';
  end if;

  v_source_account_id := public.current_account_id();
  select s.sh_id
    into v_source_sh_id
    from public.sh_instances s
   where s.account_id = v_source_account_id
     and s.status <> 'deactivated'
   order by s.is_primary desc, s.created_at asc
   limit 1;

  if v_source_sh_id is null then
    raise exception 'INHERITANCE_AUTHORIZATION_REJECTED: active source SH required';
  end if;

  select a.account_id
    into v_target_account_id
    from public.accounts a
   where lower(trim(a.email)) = lower(trim(p_target_email))
     and a.status <> 'deactivated'
   limit 1;

  if v_target_account_id is null then
    raise exception 'INHERITANCE_AUTHORIZATION_REJECTED: target email is not an active account';
  end if;

  select s.sh_id
    into v_target_sh_id
    from public.sh_instances s
   where s.account_id = v_target_account_id
     and s.status <> 'deactivated'
   order by s.is_primary desc, s.created_at asc
   limit 1;

  if v_target_sh_id is null then
    raise exception 'INHERITANCE_AUTHORIZATION_REJECTED: target account has no active SH';
  end if;

  return public.runtime_create_inheritance_authorization(
    v_source_sh_id,
    v_target_sh_id,
    v_source_account_id,
    v_target_account_id,
    coalesce(p_scope, '{}'::jsonb)
  );
end;
$$;

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
  select s.sh_id
    into v_source_sh_id
    from public.sh_instances s
   where s.account_id = v_source_account_id
     and s.status <> 'deactivated'
   order by s.is_primary desc, s.created_at asc
   limit 1;

  if v_source_sh_id is null then
    raise exception 'SUCCESSION_REQUEST_REJECTED: active source SH required';
  end if;

  select a.account_id
    into v_successor_account_id
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

  insert into public.succession_rules(
    source_sh_id,
    successor_account_id,
    status,
    scope
  ) values (
    v_source_sh_id,
    v_successor_account_id,
    'PENDING',
    coalesce(p_scope, '{}'::jsonb)
  ) returning * into v_rule;

  return v_rule;
end;
$$;

grant execute on function public.runtime_create_inheritance_authorization_by_email(text,jsonb) to authenticated;
grant execute on function public.runtime_create_succession_rule_by_email(text,jsonb) to authenticated;
revoke execute on function public.runtime_create_inheritance_authorization_by_email(text,jsonb) from anon;
revoke execute on function public.runtime_create_succession_rule_by_email(text,jsonb) from anon;
