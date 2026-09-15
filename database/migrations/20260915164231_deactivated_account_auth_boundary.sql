CREATE OR REPLACE FUNCTION public.resolve_actor_context()
RETURNS TABLE(account_id uuid, sh_id uuid, ownership_role text, actor text, authority text, sh_designation text)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
declare
  v_account_id uuid;
  v_account_status text;
  v_sh_id uuid;
  v_ownership_role text;
  v_is_creator boolean := false;
begin
  if auth.uid() is null then
    return;
  end if;

  select aal.account_id
    into v_account_id
    from public.account_auth_links aal
   where aal.provider = 'supabase'
     and aal.subject_ref = auth.uid()::text
   limit 1;

  if v_account_id is null then
    return;
  end if;

  select a.status
    into v_account_status
    from public.accounts a
   where a.account_id = v_account_id;

  if v_account_status = 'deactivated' then
    raise exception 'ACCOUNT_DEACTIVATED: account is end-of-life and cannot establish an active runtime session';
  end if;

  select s.sh_id, o.role
    into v_sh_id, v_ownership_role
    from public.sh_instances s
    join public.sh_ownership o
      on o.sh_id = s.sh_id
     and o.account_id = s.account_id
   where s.account_id = v_account_id
     and s.is_primary = true
     and s.status <> 'deactivated'
   limit 1;

  if v_sh_id is null then
    return;
  end if;

  select exists (
    select 1
      from private.authority_assignments aa
     where aa.account_id = v_account_id
       and aa.authority = 'CREATOR'
       and aa.active = true
  ) into v_is_creator;

  return query
  select
    v_account_id,
    v_sh_id,
    v_ownership_role,
    case when v_is_creator then 'CREATOR' else 'ACCOUNT_OWNER' end,
    case when v_is_creator then 'CREATOR' else null end,
    case when v_is_creator then 'SH-000' else 'ORDINARY_SH' end;
end;
$$;

grant execute on function public.resolve_actor_context() to authenticated;
revoke execute on function public.resolve_actor_context() from anon, public;
