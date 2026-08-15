create or replace function public.runtime_create_recovery_snapshot(p_sh_id uuid)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare v_snapshot_id uuid; v_account_id uuid; v_manifest jsonb;
begin
 select s.account_id into v_account_id from public.sh_instances s where s.sh_id=p_sh_id and s.account_id=current_account_id();
 if v_account_id is null then raise exception 'RECOVERY_REJECTED: SH not owned by current account'; end if;
 select jsonb_build_object(
   'identity_root', jsonb_build_object('sh_id',s.sh_id,'account_id',s.account_id,'sh_type',s.sh_type,'is_primary',s.is_primary,'canonical_name',s.canonical_name,'creator_ref',s.creator_ref,'status',s.status,'metadata',s.metadata,'version',s.version),
   'ownership_root', coalesce((select jsonb_agg(to_jsonb(o)) from public.sh_ownership o where o.sh_id=s.sh_id),'[]'::jsonb),
   'memories', coalesce((select jsonb_agg(to_jsonb(m)) from public.memories m where m.sh_id=s.sh_id),'[]'::jsonb),
   'conversations', coalesce((select jsonb_agg(to_jsonb(c)) from public.conversations c where c.sh_id=s.sh_id),'[]'::jsonb),
   'journey_events', coalesce((select jsonb_agg(to_jsonb(j)) from public.journey_events j where j.sh_id=s.sh_id),'[]'::jsonb),
   'knowledge', coalesce((select jsonb_agg(to_jsonb(k)) from public.knowledge k where k.scope='PRIVATE' and k.sh_id=s.sh_id),'[]'::jsonb),
   'legacy_records', coalesce((select jsonb_agg(to_jsonb(l)) from public.legacy_records l where l.source_sh_id=s.sh_id),'[]'::jsonb),
   'captured_at', now()
 ) into v_manifest
 from public.sh_instances s where s.sh_id=p_sh_id;
 insert into public.recovery_snapshots(sh_id,account_id,snapshot_kind,manifest) values(p_sh_id,v_account_id,'FULL',v_manifest) returning snapshot_id into v_snapshot_id;
 return v_snapshot_id;
end;
$$;

grant execute on function public.runtime_create_recovery_snapshot(uuid) to authenticated;

create or replace function public.runtime_restore_recovery_snapshot(p_snapshot_id uuid)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare v_snapshot recovery_snapshots%rowtype; v_id uuid; v_sh_id uuid; v_identity uuid; v_gap text := null;
begin
 select * into v_snapshot from public.recovery_snapshots where snapshot_id=p_snapshot_id and account_id=current_account_id();
 if not found then raise exception 'RECOVERY_REJECTED: snapshot not accessible'; end if;
 v_sh_id := v_snapshot.sh_id;
 v_identity := (v_snapshot.manifest->'identity_root'->>'sh_id')::uuid;
 if v_identity <> v_sh_id then raise exception 'RECOVERY_REJECTED: identity root mismatch'; end if;
 if not exists(select 1 from public.sh_instances where sh_id=v_sh_id and account_id=current_account_id()) then raise exception 'RECOVERY_REJECTED: target SH ownership mismatch'; end if;

 insert into public.legacy_records(legacy_id,source_sh_id,legacy_type,payload,provenance,status,retention_until,created_at)
 select x.legacy_id,x.source_sh_id,x.legacy_type,x.payload,x.provenance,x.status,x.retention_until,x.created_at
 from jsonb_to_recordset(coalesce(v_snapshot.manifest->'legacy_records','[]'::jsonb)) as x(legacy_id uuid,source_sh_id uuid,legacy_type text,payload jsonb,provenance jsonb,status text,retention_until timestamptz,created_at timestamptz)
 where x.source_sh_id=v_sh_id
 on conflict (legacy_id) do nothing;

 insert into public.memories(memory_id,sh_id,memory_type,content,source,confidence,scope,visibility,lifecycle,occurrence_count,created_at,updated_at,superseded_by)
 select x.memory_id,x.sh_id,x.memory_type,x.content,x.source,x.confidence,x.scope,x.visibility,x.lifecycle,x.occurrence_count,x.created_at,x.updated_at,x.superseded_by from jsonb_to_recordset(coalesce(v_snapshot.manifest->'memories','[]'::jsonb)) as x(memory_id uuid,sh_id uuid,memory_type text,content text,source text,confidence numeric,scope text,visibility text,lifecycle text,occurrence_count integer,created_at timestamptz,updated_at timestamptz,superseded_by uuid) where x.sh_id=v_sh_id on conflict (memory_id) do nothing;

 insert into public.conversations(conversation_id,account_id,sh_id,role,content,created_at,metadata)
 select x.conversation_id,x.account_id,x.sh_id,x.role,x.content,x.created_at,x.metadata from jsonb_to_recordset(coalesce(v_snapshot.manifest->'conversations','[]'::jsonb)) as x(conversation_id uuid,account_id uuid,sh_id uuid,role text,content text,created_at timestamptz,metadata jsonb) where x.sh_id=v_sh_id and x.account_id=current_account_id() on conflict (conversation_id) do nothing;

 insert into public.journey_events(event_id,sh_id,account_id,event_type,occurred_at,continuity_status,gap_code,payload,source_ref,created_at)
 select x.event_id,x.sh_id,x.account_id,x.event_type,x.occurred_at,x.continuity_status,x.gap_code,x.payload,x.source_ref,x.created_at from jsonb_to_recordset(coalesce(v_snapshot.manifest->'journey_events','[]'::jsonb)) as x(event_id uuid,sh_id uuid,account_id uuid,event_type text,occurred_at timestamptz,continuity_status text,gap_code text,payload jsonb,source_ref text,created_at timestamptz) where x.sh_id=v_sh_id and x.account_id=current_account_id() on conflict (event_id) do nothing;

 insert into public.knowledge(knowledge_id,sh_id,content,knowledge_class,scope,visibility,source,provenance,created_at,updated_at)
 select x.knowledge_id,x.sh_id,x.content,x.knowledge_class,x.scope,x.visibility,x.source,x.provenance,x.created_at,x.updated_at from jsonb_to_recordset(coalesce(v_snapshot.manifest->'knowledge','[]'::jsonb)) as x(knowledge_id uuid,sh_id uuid,content text,knowledge_class text,scope text,visibility text,source text,provenance jsonb,created_at timestamptz,updated_at timestamptz) where x.sh_id=v_sh_id and x.scope='PRIVATE' on conflict (knowledge_id) do nothing;

 insert into public.recovery_events(snapshot_id,sh_id,outcome,continuity_status,gap_code) values(p_snapshot_id,v_sh_id,'RESTORED',case when v_gap is null then 'RECOVERED' else 'GAP_UNRESOLVED' end,v_gap) returning recovery_event_id into v_id;
 return v_id;
end;
$$;

grant execute on function public.runtime_restore_recovery_snapshot(uuid) to authenticated;
