-- P1 lifecycle / transfer-policy reconciliation applied to Supabase DEV.
-- Owner-ratified: DEACTIVATED = EOL; no recovery restore or record-policy mutation.
-- Inheritance = ACTIVE source + ACTIVE target; inherited target policy follows source.
-- Legacy = EOL/deactivated source.
-- This migration records the live reconciliation; runtime definitions are maintained by the applied DEV migrations.

alter table public.memories
  add column if not exists provenance jsonb not null default '{}'::jsonb;

create or replace function public.runtime_revoke_inheritance_authorization(p_authorization_id uuid)
returns void language plpgsql security definer set search_path=public
as $$
declare v_auth public.inheritance_authorizations%rowtype;
begin
  if auth.uid() is null then raise exception 'INHERITANCE_REVOKE_REJECTED: authentication required'; end if;
  select * into v_auth from public.inheritance_authorizations where authorization_id=p_authorization_id for update;
  if not found then raise exception 'INHERITANCE_REVOKE_REJECTED: authorization not found'; end if;
  if v_auth.source_account_id<>public.current_account_id() then raise exception 'INHERITANCE_REVOKE_REJECTED: source owner required'; end if;
  if v_auth.status not in ('APPROVED','CONSUMED') then raise exception 'INHERITANCE_REVOKE_REJECTED: authorization not revocable'; end if;
  delete from public.memories m where coalesce(m.provenance,'{}'::jsonb)->'inheritance_origin'->>'authorization_id'=p_authorization_id::text;
  delete from public.knowledge k where coalesce(k.provenance,'{}'::jsonb)->'inheritance_origin'->>'authorization_id'=p_authorization_id::text;
  delete from public.experiences e where coalesce(e.provenance,'{}'::jsonb)->'inheritance_origin'->>'authorization_id'=p_authorization_id::text;
  update public.inheritance_authorizations set status='REVOKED', revoked_at=now() where authorization_id=p_authorization_id;
end $$;
revoke all on function public.runtime_revoke_inheritance_authorization(uuid) from public, anon;
grant execute on function public.runtime_revoke_inheritance_authorization(uuid) to authenticated;

-- Canonical transfer vocabulary is INHERITANCE; INHERITABLE remains accepted only as a compatibility alias and is normalized.
-- Terminal guards and lifecycle-specific Journey eligibility are enforced in the live DEV function definitions.
