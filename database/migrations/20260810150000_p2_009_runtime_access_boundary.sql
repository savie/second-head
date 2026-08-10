create or replace function private.runtime_access_boundary(
  p_target_domain text,
  p_target_sh_id uuid default null,
  p_actor_account_id uuid default null
)
returns table(decision text, account_id uuid, target_sh_relation text, reason text)
language plpgsql
stable
security definer
set search_path to ''
as $$
declare
  v_auth_uid uuid;
  v_account_id uuid;
  v_relation text;
  v_private_target boolean;
begin
  v_auth_uid := auth.uid();

  if v_auth_uid is null then
    return query select
      'REJECT'::text,
      null::uuid,
      null::text,
      'trusted identity context is absent; runtime access fails closed'::text;
    return;
  end if;

  select public.current_account_id() into v_account_id;

  if v_account_id is null then
    return query select
      'REJECT'::text,
      null::uuid,
      null::text,
      'authenticated subject has no resolved ACCOUNT_ID; runtime access fails closed'::text;
    return;
  end if;

  if p_actor_account_id is not null and p_actor_account_id <> v_account_id then
    return query select
      'REJECT'::text,
      v_account_id,
      null::text,
      'caller-supplied account identity does not match trusted identity context'::text;
    return;
  end if;

  if p_target_sh_id is null then
    v_relation := 'SYSTEM';
  elsif exists (
    select 1
    from public.sh_ownership o
    where o.sh_id = p_target_sh_id
      and o.account_id = v_account_id
  ) then
    v_relation := 'SELF';
  else
    v_relation := 'OTHER';
  end if;

  v_private_target := p_target_domain in (
    'PRIVATE_MEMORY',
    'PRIVATE_CONVERSATION',
    'PRIVATE_CONTEXT'
  );

  -- Runtime execution is not ownership. This boundary does not grant,
  -- transfer, or infer ownership; it only permits execution within the
  -- authenticated principal's own SH or a system-scoped target.
  if v_relation not in ('SELF', 'SYSTEM') then
    return query select
      'REJECT'::text,
      v_account_id,
      v_relation,
      case
        when v_private_target then
          'runtime access to another SH private-data domain requires an explicit scoped authorization source; none is implemented here'::text
        else
          'runtime access to another SH is denied by default; runtime access does not imply ownership'::text
      end;
    return;
  end if;

  return query select
    'PASS'::text,
    v_account_id,
    v_relation,
    'runtime execution is permitted within the authenticated principal boundary; ownership is not granted or transferred'::text;
end;
$$;

revoke all on function private.runtime_access_boundary(text, uuid, uuid) from public;
revoke all on function private.runtime_access_boundary(text, uuid, uuid) from anon;
grant execute on function private.runtime_access_boundary(text, uuid, uuid) to authenticated;
