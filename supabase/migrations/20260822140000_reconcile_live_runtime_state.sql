-- Reconcile the live Supabase DEV runtime state into the executable GitHub migration chain.
-- Owner-ratified lifecycle invariants:
--   DEACTIVATED = EOL; no recovery restore or record-policy mutation.
--   INHERITANCE = ACTIVE source + ACTIVE target; inherited target policy is source-controlled.
--   SUCCESSION / LEGACY require an EOL source.
-- This migration is idempotent and intentionally re-states the current live runtime guards.

alter table public.memories
  add column if not exists provenance jsonb not null default '{}'::jsonb;

create or replace function public.runtime_assert_active_sh(p_sh_id uuid, p_role text default 'SH')
returns void language plpgsql security definer set search_path=public as $$
begin
  if auth.uid() is null then raise exception '%_REJECTED: authentication required', upper(p_role); end if;
  if not exists (select 1 from public.sh_instances s where s.sh_id=p_sh_id and s.status <> 'deactivated') then
    raise exception '%_REJECTED: SH is deactivated or unavailable', upper(p_role);
  end if;
end;
$$;

create or replace function public.runtime_restore_recovery_snapshot(p_snapshot_id uuid)
returns uuid language plpgsql security definer set search_path=public as $$
declare v_snapshot public.recovery_snapshots%rowtype; v_recovery_event_id uuid; v_existing_event public.recovery_events%rowtype; v_sh_id uuid; v_identity uuid; v_missing_before integer:=0; v_missing_after integer:=0; v_continuity_status text; v_gap_code text:=null;
begin
  select * into v_snapshot from public.recovery_snapshots where snapshot_id=p_snapshot_id and account_id=public.current_account_id() for update;
  if not found then raise exception 'RECOVERY_REJECTED: snapshot not accessible'; end if;
  if exists(select 1 from public.sh_instances s where s.sh_id=v_snapshot.sh_id and s.account_id=public.current_account_id() and s.status='deactivated') then raise exception 'RECOVERY_REJECTED: SH is terminal/deactivated'; end if;
  select * into v_existing_event from public.recovery_events where snapshot_id=p_snapshot_id for update;
  if found then return v_existing_event.recovery_event_id; end if;
  v_sh_id:=v_snapshot.sh_id; v_identity:=(v_snapshot.manifest->'identity_root'->>'sh_id')::uuid;
  if v_identity<>v_sh_id then raise exception 'RECOVERY_REJECTED: identity root mismatch'; end if;
  if not exists(select 1 from public.sh_instances where sh_id=v_sh_id and account_id=public.current_account_id()) then raise exception 'RECOVERY_REJECTED: target SH ownership mismatch'; end if;
  insert into public.sh_ownership(ownership_id,account_id,sh_id,role,granted_at,evidence_ref,created_at)
    select x.ownership_id,x.account_id,x.sh_id,x.role,x.granted_at,x.evidence_ref,x.created_at from jsonb_to_recordset(coalesce(v_snapshot.manifest->'ownership_root','[]'::jsonb)) x(ownership_id uuid,account_id uuid,sh_id uuid,role text,granted_at timestamptz,evidence_ref text,created_at timestamptz) where x.sh_id=v_sh_id and x.account_id=public.current_account_id() on conflict (ownership_id) do nothing;
  insert into public.memories(memory_id,sh_id,memory_type,content,source,confidence,scope,visibility,lifecycle,occurrence_count,created_at,updated_at,superseded_by)
    select x.memory_id,x.sh_id,x.memory_type,x.content,x.source,x.confidence,x.scope,x.visibility,x.lifecycle,x.occurrence_count,x.created_at,x.updated_at,x.superseded_by from jsonb_to_recordset(coalesce(v_snapshot.manifest->'memories','[]'::jsonb)) x(memory_id uuid,sh_id uuid,memory_type text,content text,source text,confidence numeric,scope text,visibility text,lifecycle text,occurrence_count integer,created_at timestamptz,updated_at timestamptz,superseded_by uuid) where x.sh_id=v_sh_id on conflict (memory_id) do nothing;
  insert into public.conversations(conversation_id,account_id,sh_id,role,content,created_at,metadata)
    select x.conversation_id,x.account_id,x.sh_id,x.role,x.content,x.created_at,x.metadata from jsonb_to_recordset(coalesce(v_snapshot.manifest->'conversations','[]'::jsonb)) x(conversation_id uuid,account_id uuid,sh_id uuid,role text,content text,created_at timestamptz,metadata jsonb) where x.sh_id=v_sh_id and x.account_id=public.current_account_id() on conflict (conversation_id) do nothing;
  insert into public.journey_events(event_id,sh_id,account_id,event_type,occurred_at,continuity_status,gap_code,payload,source_ref,created_at)
    select x.event_id,x.sh_id,x.account_id,x.event_type,x.occurred_at,x.continuity_status,x.gap_code,x.payload,x.source_ref,x.created_at from jsonb_to_recordset(coalesce(v_snapshot.manifest->'journey_events','[]'::jsonb)) x(event_id uuid,sh_id uuid,account_id uuid,event_type text,occurred_at timestamptz,continuity_status text,gap_code text,payload jsonb,source_ref text,created_at timestamptz) where x.sh_id=v_sh_id and x.account_id=public.current_account_id() on conflict (event_id) do nothing;
  insert into public.knowledge(knowledge_id,content,knowledge_class,scope,visibility,source,provenance,confidence,version,lifecycle,superseded_by,created_at,updated_at,sh_id)
    select x.knowledge_id,x.content,x.knowledge_class,x.scope,x.visibility,x.source,x.provenance,x.confidence,x.version,x.lifecycle,x.superseded_by,x.created_at,x.updated_at,x.sh_id from jsonb_to_recordset(coalesce(v_snapshot.manifest->'knowledge','[]'::jsonb)) x(knowledge_id uuid,content text,knowledge_class text,scope text,visibility text,source text,provenance jsonb,confidence numeric,version integer,lifecycle text,superseded_by uuid,created_at timestamptz,updated_at timestamptz,sh_id uuid) where x.sh_id=v_sh_id and x.scope='PRIVATE' on conflict (knowledge_id) do nothing;
  insert into public.legacy_records(legacy_id,source_sh_id,legacy_type,payload,provenance,status,retention_until,created_at)
    select x.legacy_id,x.source_sh_id,x.legacy_type,x.payload,x.provenance,x.status,x.retention_until,x.created_at from jsonb_to_recordset(coalesce(v_snapshot.manifest->'legacy_records','[]'::jsonb)) x(legacy_id uuid,source_sh_id uuid,legacy_type text,payload jsonb,provenance jsonb,status text,retention_until timestamptz,created_at timestamptz) where x.source_sh_id=v_sh_id on conflict (legacy_id) do nothing;
  insert into public.recovery_events(snapshot_id,sh_id,outcome,continuity_status,gap_code) values(p_snapshot_id,v_sh_id,'RESTORED','RECOVERED',null) returning recovery_event_id into v_recovery_event_id;
  insert into public.journey_events(sh_id,account_id,event_type,occurred_at,continuity_status,gap_code,payload,source_ref) values(v_sh_id,public.current_account_id(),'RECOVERY',now(),'RECOVERED',null,jsonb_build_object('outcome','RESTORED','snapshot_id',p_snapshot_id,'recovery_event_id',v_recovery_event_id),'recovery_event:'||v_recovery_event_id::text);
  return v_recovery_event_id;
end;
$$;

create or replace function public.runtime_revoke_inheritance_authorization(p_authorization_id uuid)
returns void language plpgsql security definer set search_path=public as $$
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
  update public.inheritance_authorizations set status='REVOKED',revoked_at=now() where authorization_id=p_authorization_id;
end;
$$;

revoke all on function public.runtime_assert_active_sh(uuid,text) from public,anon;
grant execute on function public.runtime_assert_active_sh(uuid,text) to authenticated;
revoke all on function public.runtime_restore_recovery_snapshot(uuid) from public,anon;
grant execute on function public.runtime_restore_recovery_snapshot(uuid) to authenticated;
revoke all on function public.runtime_revoke_inheritance_authorization(uuid) from public,anon;
grant execute on function public.runtime_revoke_inheritance_authorization(uuid) to authenticated;
