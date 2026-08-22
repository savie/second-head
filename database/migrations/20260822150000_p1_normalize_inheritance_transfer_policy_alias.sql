-- P1 deterministic vocabulary reconciliation.
-- INHERITABLE is a compatibility input alias; persisted transfer_policy must be canonical INHERITANCE.
create or replace function public.runtime_record_experience(
  p_sh_id uuid,
  p_experience_type text,
  p_content text,
  p_scope text default 'PRIVATE',
  p_visibility text default 'OWNER_ONLY',
  p_transfer_policy text default 'NON_TRANSFERABLE',
  p_source_ref text default null,
  p_provenance jsonb default '{}',
  p_occurred_at timestamptz default now()
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_account_id uuid;
  v_experience_id uuid;
  v_policy text := upper(p_transfer_policy);
begin
  if auth.uid() is null then raise exception 'EXPERIENCE_REJECTED: authentication required'; end if;
  if p_scope not in ('PRIVATE','GENERAL') then raise exception 'EXPERIENCE_REJECTED: invalid scope'; end if;
  if p_visibility not in ('OWNER_ONLY','SHARED') then raise exception 'EXPERIENCE_REJECTED: invalid visibility'; end if;
  if v_policy='INHERITABLE' then v_policy:='INHERITANCE'; end if;
  if v_policy not in ('NON_TRANSFERABLE','INHERITANCE','SUCCESSION','LEGACY') then raise exception 'EXPERIENCE_REJECTED: invalid transfer policy'; end if;
  select s.account_id into v_account_id from public.sh_instances s where s.sh_id=p_sh_id and s.account_id=public.current_account_id() and s.status<>'deactivated';
  if v_account_id is null then raise exception 'EXPERIENCE_REJECTED: SH not owned by current active account'; end if;
  insert into public.experiences(sh_id,account_id,experience_type,content,scope,visibility,transfer_policy,source_ref,provenance,lifecycle,occurred_at,created_at,updated_at)
  values(p_sh_id,v_account_id,p_experience_type,p_content,p_scope,p_visibility,v_policy,p_source_ref,coalesce(p_provenance,'{}'::jsonb),'ACTIVE',coalesce(p_occurred_at,now()),now(),now())
  returning experience_id into v_experience_id;
  return v_experience_id;
end;
$$;
revoke all on function public.runtime_record_experience(uuid,text,text,text,text,text,text,jsonb,timestamptz) from public;
revoke execute on function public.runtime_record_experience(uuid,text,text,text,text,text,text,jsonb,timestamptz) from anon;
grant execute on function public.runtime_record_experience(uuid,text,text,text,text,text,text,jsonb,timestamptz) to authenticated;

-- No existing INHERITABLE rows were present in DEV at reconciliation time, so no data rewrite is required.
