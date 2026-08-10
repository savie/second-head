create or replace function private.isolation_checker(
  p_target_domain text,
  p_target_sh_id uuid default null,
  p_actor_account_id uuid default null
)
returns table (
  decision text,
  account_id uuid,
  target_sh_relation text,
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
  v_relation text;
  v_private_target boolean;
begin
  v_auth_uid := auth.uid();

  if v_auth_uid is null then
    return query select 'FAIL'::text, null::uuid, null::text,
      'trusted identity context is absent; fail closed'::text;
    return;
  end if;

  select public.current_account_id() into v_account_id;

  if v_account_id is null then
    return query select 'FAIL'::text, null::uuid, null::text,
      'authenticated subject has no resolved ACCOUNT_ID; fail closed'::text;
    return;
  end if;

  if p_actor_account_id is not null and p_actor_account_id <> v_account_id then
    return query select 'FAIL'::text, v_account_id, null::text,
      'caller-supplied account identity does not match trusted identity context'::text;
    return;
  end if;

  if p_target_sh_id is null then
    v_relation := 'SYSTEM';
  elsif exists (
    select 1 from public.sh_ownership o
    where o.sh_id = p_target_sh_id and o.account_id = v_account_id
  ) then
    v_relation := 'SELF';
  else
    v_relation := 'OTHER';
  end if;

  v_private_target := p_target_domain in (
    'PRIVATE_MEMORY', 'PRIVATE_CONVERSATION', 'PRIVATE_CONTEXT'
  );

  if v_private_target and v_relation = 'OTHER' then
    return query select 'FAIL'::text, v_account_id, v_relation,
      'cross-SH private-data boundary violated; access is denied by isolation baseline'::text;
    return;
  end if;

  return query select 'PASS'::text, v_account_id, v_relation,
    'target remains within the actor isolation boundary'::text;
end;
$$;

revoke all on function private.isolation_checker(text, uuid, uuid) from public;
revoke all on function private.isolation_checker(text, uuid, uuid) from anon;
grant execute on function private.isolation_checker(text, uuid, uuid) to authenticated;
