-- Canonical migration: transfer provenance is system-managed and revoke cleanup is target-scoped.

create or replace function public.reject_reserved_transfer_provenance()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if session_user <> 'postgres' then
    if coalesce(new.provenance, '{}'::jsonb) ? 'inheritance_origin'
       or coalesce(new.provenance, '{}'::jsonb) ? 'clone_origin' then
      raise exception 'PROVENANCE_REJECTED: reserved transfer provenance is system-managed';
    end if;
  end if;
  return new;
end;
$$;

create or replace trigger memories_reserved_provenance_guard
before insert on public.memories
for each row execute function public.reject_reserved_transfer_provenance();

create or replace trigger knowledge_reserved_provenance_guard
before insert on public.knowledge
for each row execute function public.reject_reserved_transfer_provenance();

create or replace trigger experiences_reserved_provenance_guard
before insert on public.experiences
for each row execute function public.reject_reserved_transfer_provenance();

create or replace trigger journey_events_reserved_provenance_guard
before insert on public.journey_events
for each row execute function public.reject_reserved_transfer_provenance();

create or replace function public.runtime_revoke_inheritance_authorization(p_authorization_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_auth public.inheritance_authorizations%rowtype;
begin
  if auth.uid() is null then
    raise exception 'INHERITANCE_REVOKE_REJECTED: authentication required';
  end if;

  select * into v_auth
  from public.inheritance_authorizations
  where authorization_id = p_authorization_id
  for update;

  if not found then
    raise exception 'INHERITANCE_REVOKE_REJECTED: authorization not found';
  end if;

  if v_auth.source_account_id <> public.current_account_id() then
    raise exception 'INHERITANCE_REVOKE_REJECTED: source owner required';
  end if;

  if v_auth.status not in ('APPROVED', 'CONSUMED') then
    raise exception 'INHERITANCE_REVOKE_REJECTED: authorization not revocable';
  end if;

  delete from public.memories m
  where m.sh_id = v_auth.target_sh_id
    and coalesce(m.provenance, '{}'::jsonb)->'inheritance_origin'->>'authorization_id' = p_authorization_id::text
    and coalesce(m.provenance, '{}'::jsonb)->'inheritance_origin'->>'source_sh_id' = v_auth.source_sh_id::text;

  delete from public.knowledge k
  where k.sh_id = v_auth.target_sh_id
    and coalesce(k.provenance, '{}'::jsonb)->'inheritance_origin'->>'authorization_id' = p_authorization_id::text
    and coalesce(k.provenance, '{}'::jsonb)->'inheritance_origin'->>'source_sh_id' = v_auth.source_sh_id::text;

  delete from public.experiences e
  where e.sh_id = v_auth.target_sh_id
    and coalesce(e.provenance, '{}'::jsonb)->'inheritance_origin'->>'authorization_id' = p_authorization_id::text
    and coalesce(e.provenance, '{}'::jsonb)->'inheritance_origin'->>'source_sh_id' = v_auth.source_sh_id::text;

  delete from public.journey_events j
  where j.sh_id = v_auth.target_sh_id
    and coalesce(j.provenance, '{}'::jsonb)->>'transfer_operation' = 'INHERITANCE'
    and coalesce(j.provenance, '{}'::jsonb)->>'authorization_id' = p_authorization_id::text
    and coalesce(j.provenance, '{}'::jsonb)->>'source_sh_id' = v_auth.source_sh_id::text;

  update public.inheritance_authorizations
  set status = 'REVOKED', revoked_at = now()
  where authorization_id = p_authorization_id;
end;
$$;

revoke all on function public.reject_reserved_transfer_provenance() from public, anon, authenticated;
revoke all on function public.runtime_revoke_inheritance_authorization(uuid) from public, anon;
