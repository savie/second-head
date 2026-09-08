-- Owner-ratified terminal lifecycle + transfer-policy reconciliation.
-- DEACTIVATED = EOL: no recovery restore and no record-policy mutation.
-- Inheritance = ACTIVE source + ACTIVE target; derived target policy follows source and is not editable by target.
-- Legacy = EOL/deactivated source; no active-source legacy operation.

alter table public.memories
  add column if not exists provenance jsonb not null default '{}'::jsonb;

-- Make inheritance-created Memory rows traceable to the authorization without replacing
-- the existing function body wholesale.
do $$
declare d text;
begin
  select pg_get_functiondef(p.oid) into d
  from pg_proc p join pg_namespace n on n.oid=p.pronamespace
  where n.nspname='public' and p.proname='runtime_record_inheritance_unchecked'
    and pg_get_function_identity_arguments(p.oid)='p_authorization_id uuid, p_payload jsonb, p_provenance jsonb';
  d := replace(d,
    'insert into public.memories(sh_id,memory_type,content,source,confidence,scope,visibility,lifecycle,occurrence_count,created_at,updated_at,superseded_by) select v_auth.target_sh_id,m.memory_type,m.content,m.source,m.confidence,m.scope,m.visibility,case when m.lifecycle=''CANDIDATE'' then ''ACTIVE'' else m.lifecycle end,m.occurrence_count,v_now,v_now,null',
    'insert into public.memories(sh_id,memory_type,content,source,confidence,scope,visibility,lifecycle,occurrence_count,created_at,updated_at,superseded_by,provenance) select v_auth.target_sh_id,m.memory_type,m.content,m.source,m.confidence,m.scope,m.visibility,case when m.lifecycle=''CANDIDATE'' then ''ACTIVE'' else m.lifecycle end,m.occurrence_count,v_now,v_now,null,jsonb_build_object(''inheritance_origin'',jsonb_build_object(''source_sh_id'',v_auth.source_sh_id,''authorization_id'',v_auth.authorization_id,''transferred_at'',v_now),''original_provenance'',coalesce(m.provenance,''{}''::jsonb))');
  if d is null or d = '' then raise exception 'inheritance function not found'; end if;
  execute d;
end $$;

-- Make Clone/Succession-created Memory rows provenance-traceable too.
do $$
declare d text;
begin
  select pg_get_functiondef(p.oid) into d
  from pg_proc p join pg_namespace n on n.oid=p.pronamespace
  where n.nspname='public' and p.proname='runtime_create_clone'
    and pg_get_function_identity_arguments(p.oid)='p_agreement_id uuid, p_clone_name text';
  d := replace(d,
    'insert into public.memories(sh_id,memory_type,content,source,confidence,scope,visibility,transfer_policy,lifecycle,occurrence_count,created_at,updated_at,superseded_by) select v_clone_sh_id,m.memory_type,m.content,m.source,m.confidence,m.scope,m.visibility,m.transfer_policy,case when m.lifecycle=''CANDIDATE'' then ''ACTIVE'' else m.lifecycle end,m.occurrence_count,v_now,v_now,null',
    'insert into public.memories(sh_id,memory_type,content,source,confidence,scope,visibility,transfer_policy,lifecycle,occurrence_count,created_at,updated_at,superseded_by,provenance) select v_clone_sh_id,m.memory_type,m.content,m.source,m.confidence,m.scope,m.visibility,m.transfer_policy,case when m.lifecycle=''CANDIDATE'' then ''ACTIVE'' else m.lifecycle end,m.occurrence_count,v_now,v_now,null,jsonb_build_object(''clone_origin'',jsonb_build_object(''source_sh_id'',v_agreement.source_sh_id,''source_account_id'',v_agreement.source_account_id,''agreement_id'',v_agreement.agreement_id,''cloned_at'',v_now),''original_provenance'',coalesce(m.provenance,''{}''::jsonb))');
  execute d;
end $$;

do $$
declare d text;
begin
  select pg_get_functiondef(p.oid) into d
  from pg_proc p join pg_namespace n on n.oid=p.pronamespace
  where n.nspname='public' and p.proname='runtime_execute_succession_unchecked'
    and pg_get_function_identity_arguments(p.oid)='p_succession_id uuid';
  d := replace(d,
    'insert into public.memories(sh_id,memory_type,content,source,confidence,scope,visibility,lifecycle,occurrence_count,created_at,updated_at,superseded_by) select v_target.sh_id,m.memory_type,m.content,m.source,m.confidence,m.scope,m.visibility,case when m.lifecycle=''CANDIDATE'' then ''ACTIVE'' else m.lifecycle end,m.occurrence_count,v_now,v_now,null',
    'insert into public.memories(sh_id,memory_type,content,source,confidence,scope,visibility,lifecycle,occurrence_count,created_at,updated_at,superseded_by,provenance) select v_target.sh_id,m.memory_type,m.content,m.source,m.confidence,m.scope,m.visibility,case when m.lifecycle=''CANDIDATE'' then ''ACTIVE'' else m.lifecycle end,m.occurrence_count,v_now,v_now,null,jsonb_build_object(''succession_origin'',jsonb_build_object(''source_sh_id'',v_source.sh_id,''succession_id'',v_rule.succession_id,''transferred_at'',v_now),''original_provenance'',coalesce(m.provenance,''{}''::jsonb))');
  execute d;
end $$;

-- Recovery restore: terminal SH cannot be restored.
do $$
declare d text;
begin
  select pg_get_functiondef(p.oid) into d from pg_proc p join pg_namespace n on n.oid=p.pronamespace
  where n.nspname='public' and p.proname='runtime_restore_recovery_snapshot'
    and pg_get_function_identity_arguments(p.oid)='p_snapshot_id uuid';
  d := replace(d,
    'if not found then raise exception ''RECOVERY_REJECTED: snapshot not accessible''; end if;',
    'if not found then raise exception ''RECOVERY_REJECTED: snapshot not accessible''; end if; if exists (select 1 from public.sh_instances s where s.sh_id=v_snapshot.sh_id and s.account_id=public.current_account_id() and s.status=''deactivated'') then raise exception ''RECOVERY_REJECTED: SH is terminal/deactivated''; end if;');
  execute d;
end $$;

-- Record policy is an operational mutation: terminal SH cannot change it.
-- Inheritance-derived records also keep the source policy; target cannot rewrite it.
do $$
declare d text;
begin
  select pg_get_functiondef(p.oid) into d from pg_proc p join pg_namespace n on n.oid=p.pronamespace
  where n.nspname='public' and p.proname='runtime_set_record_policy'
    and pg_get_function_identity_arguments(p.oid)='p_domain text, p_record_id uuid, p_scope text, p_visibility text, p_transfer_policy text';
  d := replace(d,
    'if p_scope not in (''PRIVATE'',''GENERAL'') then raise exception ''POLICY_REJECTED: invalid scope''; end if;',
    'if p_scope not in (''PRIVATE'',''GENERAL'') then raise exception ''POLICY_REJECTED: invalid scope''; end if;');
  d := replace(d,
    'if p_transfer_policy not in (''NON_TRANSFERABLE'',''INHERITABLE'',''SUCCESSION'',''LEGACY'') then raise exception ''POLICY_REJECTED: invalid transfer policy''; end if;',
    'if p_transfer_policy not in (''NON_TRANSFERABLE'',''INHERITABLE'',''SUCCESSION'',''LEGACY'') then raise exception ''POLICY_REJECTED: invalid transfer policy''; end if;');
  d := replace(d,
    'if upper(p_domain)=''MEMORY'' then',
    'if upper(p_domain)=''MEMORY'' then if exists(select 1 from public.memories m join public.sh_instances s on s.sh_id=m.sh_id where m.memory_id=p_record_id and s.account_id=public.current_account_id() and s.status=''deactivated'') then raise exception ''POLICY_REJECTED: SH is terminal/deactivated''; end if; if exists(select 1 from public.memories m where m.memory_id=p_record_id and coalesce(m.provenance,''{}''::jsonb) ? ''inheritance_origin'') then raise exception ''POLICY_REJECTED: inherited policy is controlled by source SH''; end if;');
  d := replace(d,
    'elsif upper(p_domain)=''KNOWLEDGE'' then',
    'elsif upper(p_domain)=''KNOWLEDGE'' then if exists(select 1 from public.knowledge k join public.sh_instances s on s.sh_id=k.sh_id where k.knowledge_id=p_record_id and s.account_id=public.current_account_id() and s.status=''deactivated'') then raise exception ''POLICY_REJECTED: SH is terminal/deactivated''; end if; if exists(select 1 from public.knowledge k where k.knowledge_id=p_record_id and coalesce(k.provenance,''{}''::jsonb) ? ''inheritance_origin'') then raise exception ''POLICY_REJECTED: inherited policy is controlled by source SH''; end if;');
  d := replace(d,
    'elsif upper(p_domain)=''EXPERIENCE'' then',
    'elsif upper(p_domain)=''EXPERIENCE'' then if exists(select 1 from public.experiences e join public.sh_instances s on s.sh_id=e.sh_id where e.experience_id=p_record_id and e.account_id=public.current_account_id() and s.status=''deactivated'') then raise exception ''POLICY_REJECTED: SH is terminal/deactivated''; end if; if exists(select 1 from public.experiences e where e.experience_id=p_record_id and coalesce(e.provenance,''{}''::jsonb) ? ''inheritance_origin'') then raise exception ''POLICY_REJECTED: inherited policy is controlled by source SH''; end if;');
  execute d;
end $$;

-- Legacy is an EOL preservation path: source SH must already be deactivated.
do $$
declare d text;
begin
  select pg_get_functiondef(p.oid) into d from pg_proc p join pg_namespace n on n.oid=p.pronamespace
  where n.nspname='public' and p.proname='runtime_validate_selected_transfer_scope'
    and pg_get_function_identity_arguments(p.oid)='p_source_sh_id uuid, p_scope jsonb, p_operation text';
  d := replace(d,
    'if v_policy=''SUCCESSION'' then\\n    if not exists (select 1 from public.sh_instances s where s.sh_id=p_source_sh_id and s.status=''deactivated'') then\\n      raise exception ''SUCCESSION_REJECTED: source SH must be end-of-life'';\\n    end if;\\n  else\\n    perform public.runtime_assert_active_sh(p_source_sh_id, ''TRANSFER'');\\n  end if;',
    'if v_policy in (''SUCCESSION'',''LEGACY'') then\\n    if not exists (select 1 from public.sh_instances s where s.sh_id=p_source_sh_id and s.status=''deactivated'') then\\n      raise exception ''TRANSFER_REJECTED: source SH must be end-of-life'';\\n    end if;\\n  else\\n    perform public.runtime_assert_active_sh(p_source_sh_id, ''TRANSFER'');\\n  end if;');
  execute d;
end $$;

-- Journey-based Legacy path has its own explicit source-state guard and owner boundary.
do $$
declare d text;
begin
  select pg_get_functiondef(p.oid) into d from pg_proc p join pg_namespace n on n.oid=p.pronamespace
  where n.nspname='public' and p.proname='runtime_preserve_selected_journey_as_legacy'
    and pg_get_function_identity_arguments(p.oid)='p_source_sh_id uuid, p_event_ids uuid[]';
  d := replace(d,
    'if coalesce(array_length(p_event_ids, 1), 0) = 0 then',
    'if not exists (select 1 from public.sh_instances s where s.sh_id=p_source_sh_id and s.account_id=current_account_id() and s.status=''deactivated'') then raise exception ''LEGACY_JOURNEY_REJECTED: source SH must be end-of-life''; end if; if coalesce(array_length(p_event_ids, 1), 0) = 0 then');
  execute d;
end $$;

-- Transfer-based Legacy path now also enforces source ownership explicitly.
do $$
declare d text;
begin
  select pg_get_functiondef(p.oid) into d from pg_proc p join pg_namespace n on n.oid=p.pronamespace
  where n.nspname='public' and p.proname='runtime_preserve_selected_transfer_as_legacy'
    and pg_get_function_identity_arguments(p.oid)='p_source_sh_id uuid, p_scope jsonb';
  d := replace(d,
    'declare v_result uuid; begin perform public.runtime_validate_selected_transfer_scope',
    'declare v_result uuid; begin if not exists(select 1 from public.sh_instances s where s.sh_id=p_source_sh_id and s.account_id=public.current_account_id()) then raise exception ''LEGACY_REJECTED: source owner required''; end if; perform public.runtime_validate_selected_transfer_scope');
  execute d;
end $$;

-- Inheritance revoke/release: remove only derived target records created by this authorization.
create or replace function public.runtime_revoke_inheritance_authorization(p_authorization_id uuid)
returns void language plpgsql security definer set search_path=public
as $$
declare v_auth public.inheritance_authorizations%rowtype; v_deleted integer;
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
