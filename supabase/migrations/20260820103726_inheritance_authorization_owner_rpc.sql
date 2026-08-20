-- Reconcile the owner-created Inheritance authorization flow with the existing RLS boundary.
-- This migration matches the DEV runtime migration already applied at version 20260820103726.

create or replace function public.runtime_create_inheritance_authorization(
  p_source_sh_id uuid,
  p_target_sh_id uuid,
  p_source_account_id uuid,
  p_target_account_id uuid,
  p_scope jsonb default '{}'::jsonb
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
    raise exception 'INHERITANCE_AUTHORIZATION_REJECTED: authentication required';
  end if;
  if p_source_account_id <> public.current_account_id() then
    raise exception 'INHERITANCE_AUTHORIZATION_REJECTED: source owner required';
  end if;
  if p_source_account_id = p_target_account_id then
    raise exception 'INHERITANCE_AUTHORIZATION_REJECTED: source and target accounts must differ';
  end if;
  if not exists (select 1 from public.sh_instances s where s.sh_id=p_source_sh_id and s.account_id=p_source_account_id and s.status <> 'deactivated') then
    raise exception 'INHERITANCE_AUTHORIZATION_REJECTED: source SH ownership required';
  end if;
  if not exists (select 1 from public.sh_instances s where s.sh_id=p_target_sh_id and s.account_id=p_target_account_id and s.status <> 'deactivated') then
    raise exception 'INHERITANCE_AUTHORIZATION_REJECTED: target SH/account mismatch';
  end if;
  if p_source_sh_id = p_target_sh_id then
    raise exception 'INHERITANCE_AUTHORIZATION_REJECTED: source and target SH must differ';
  end if;
  insert into public.inheritance_authorizations(source_sh_id,target_sh_id,source_account_id,target_account_id,status,scope)
  values(p_source_sh_id,p_target_sh_id,p_source_account_id,p_target_account_id,'PENDING',coalesce(p_scope,'{}'::jsonb))
  returning * into v_auth;
  return v_auth;
end;
$$;

grant execute on function public.runtime_create_inheritance_authorization(uuid, uuid, uuid, uuid, jsonb) to authenticated;
