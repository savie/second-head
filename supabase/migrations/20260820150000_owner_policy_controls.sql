-- SECOND HEAD — Owner policy controls and owner-visible private data reconciliation.
-- Privacy/visibility and transfer policy remain independent.

-- Knowledge private rows must use the canonical account resolver, not auth.uid().
drop policy if exists knowledge_private_owner_select on public.knowledge;
create policy knowledge_private_owner_select on public.knowledge
  for select to authenticated
  using (
    scope = 'PRIVATE'
    and sh_id in (select si.sh_id from public.sh_instances si where si.account_id = public.current_account_id())
  );

create or replace function public.runtime_set_record_policy(
  p_domain text,
  p_record_id uuid,
  p_scope text,
  p_visibility text,
  p_transfer_policy text
)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if auth.uid() is null then raise exception 'POLICY_REJECTED: authentication required'; end if;
  if p_scope not in ('PRIVATE','GENERAL') then raise exception 'POLICY_REJECTED: invalid scope'; end if;
  if p_visibility not in ('OWNER_ONLY','SHARED') then raise exception 'POLICY_REJECTED: invalid visibility'; end if;
  if p_transfer_policy not in ('NON_TRANSFERABLE','INHERITABLE','SUCCESSION','LEGACY') then raise exception 'POLICY_REJECTED: invalid transfer policy'; end if;

  if upper(p_domain) = 'MEMORY' then
    update public.memories m
       set scope=p_scope, visibility=p_visibility, transfer_policy=p_transfer_policy, updated_at=now()
     where m.memory_id=p_record_id
       and exists (select 1 from public.sh_instances s where s.sh_id=m.sh_id and s.account_id=public.current_account_id());
  elsif upper(p_domain) = 'KNOWLEDGE' then
    update public.knowledge k
       set scope=p_scope, visibility=p_visibility, transfer_policy=p_transfer_policy, updated_at=now()
     where k.knowledge_id=p_record_id
       and exists (select 1 from public.sh_instances s where s.sh_id=k.sh_id and s.account_id=public.current_account_id());
  elsif upper(p_domain) = 'EXPERIENCE' then
    update public.experiences e
       set scope=p_scope, visibility=p_visibility, transfer_policy=p_transfer_policy, updated_at=now()
     where e.experience_id=p_record_id
       and e.account_id=public.current_account_id();
  else
    raise exception 'POLICY_REJECTED: unsupported domain';
  end if;

  if not found then raise exception 'POLICY_REJECTED: record not owned by current account'; end if;
end;
$$;
revoke all on function public.runtime_set_record_policy(text,uuid,text,text,text) from public;
grant execute on function public.runtime_set_record_policy(text,uuid,text,text,text) to authenticated;
