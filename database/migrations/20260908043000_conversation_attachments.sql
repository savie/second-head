-- SECOND HEAD — Conversation Attachment durable backend
-- Frozen design: docs/working/conversation/sh_conversation_attachment_migration_design.md
-- Scope: Conversation Message attachments only. No transfer-scope expansion.

BEGIN;

CREATE TABLE public.conversation_attachments (
  attachment_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  account_id uuid NOT NULL REFERENCES public.accounts(account_id),
  sh_id uuid NOT NULL REFERENCES public.sh_instances(sh_id),
  message_id uuid NULL REFERENCES public.conversations(message_id) ON DELETE SET NULL,
  filename text NOT NULL,
  mime_type text NOT NULL,
  size_bytes bigint NOT NULL,
  storage_ref text NOT NULL,
  status text NOT NULL DEFAULT 'PENDING',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  persisted_at timestamptz NULL,
  CONSTRAINT conversation_attachments_size_nonnegative CHECK (size_bytes >= 0),
  CONSTRAINT conversation_attachments_status_check CHECK (status IN ('PENDING','PERSISTED','FAILED')),
  CONSTRAINT conversation_attachments_persisted_fields_check CHECK (
    (status = 'PERSISTED' AND persisted_at IS NOT NULL)
    OR (status <> 'PERSISTED' AND persisted_at IS NULL)
  ),
  CONSTRAINT conversation_attachments_storage_ref_unique UNIQUE (storage_ref)
);

CREATE INDEX conversation_attachments_message_id_idx
  ON public.conversation_attachments(message_id);

CREATE INDEX conversation_attachments_account_sh_idx
  ON public.conversation_attachments(account_id, sh_id);

CREATE INDEX conversation_attachments_status_created_idx
  ON public.conversation_attachments(status, created_at);

CREATE TABLE public.conversation_attachment_recovery_refs (
  snapshot_id uuid NOT NULL REFERENCES public.recovery_snapshots(snapshot_id) ON DELETE CASCADE,
  attachment_id uuid NOT NULL REFERENCES public.conversation_attachments(attachment_id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (snapshot_id, attachment_id)
);

CREATE INDEX conversation_attachment_recovery_refs_attachment_idx
  ON public.conversation_attachment_recovery_refs(attachment_id);

CREATE INDEX conversation_attachment_recovery_refs_snapshot_idx
  ON public.conversation_attachment_recovery_refs(snapshot_id);

ALTER TABLE public.conversation_attachments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.conversation_attachment_recovery_refs ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE public.conversation_attachments FROM anon;
REVOKE INSERT, UPDATE, DELETE ON TABLE public.conversation_attachments FROM authenticated;
GRANT SELECT ON TABLE public.conversation_attachments TO authenticated;
REVOKE ALL ON TABLE public.conversation_attachment_recovery_refs FROM anon, authenticated;

CREATE POLICY conversation_attachments_select_own
  ON public.conversation_attachments
  FOR SELECT
  TO authenticated
  USING (
    account_id = public.current_account_id()
    AND EXISTS (
      SELECT 1
      FROM public.sh_instances s
      WHERE s.sh_id = conversation_attachments.sh_id
        AND s.account_id = public.current_account_id()
        AND s.status <> 'deactivated'
    )
  );

INSERT INTO storage.buckets (id, name, public)
VALUES ('second-head-conversation', 'second-head-conversation', false)
ON CONFLICT (id) DO UPDATE SET public = false, name = excluded.name;

DROP POLICY IF EXISTS second_head_conversation_select ON storage.objects;
DROP POLICY IF EXISTS second_head_conversation_insert ON storage.objects;
DROP POLICY IF EXISTS second_head_conversation_update ON storage.objects;
DROP POLICY IF EXISTS second_head_conversation_delete ON storage.objects;

CREATE POLICY second_head_conversation_select
  ON storage.objects
  FOR SELECT
  TO authenticated
  USING (
    bucket_id = 'second-head-conversation'
    AND EXISTS (
      SELECT 1
      FROM public.conversation_attachments a
      WHERE a.storage_ref = storage.objects.name
        AND a.account_id = public.current_account_id()
        AND EXISTS (
          SELECT 1
          FROM public.sh_instances s
          WHERE s.sh_id = a.sh_id
            AND s.account_id = public.current_account_id()
            AND s.status <> 'deactivated'
        )
        AND a.status = 'PERSISTED'
    )
  );

CREATE POLICY second_head_conversation_insert
  ON storage.objects
  FOR INSERT
  TO authenticated
  WITH CHECK (
    bucket_id = 'second-head-conversation'
    AND EXISTS (
      SELECT 1
      FROM public.conversation_attachments a
      WHERE a.storage_ref = storage.objects.name
        AND a.account_id = public.current_account_id()
        AND a.status IN ('PENDING','FAILED')
        AND EXISTS (
          SELECT 1
          FROM public.sh_instances s
          WHERE s.sh_id = a.sh_id
            AND s.account_id = public.current_account_id()
            AND s.status <> 'deactivated'
        )
    )
  );

CREATE POLICY second_head_conversation_update
  ON storage.objects
  FOR UPDATE
  TO authenticated
  USING (
    bucket_id = 'second-head-conversation'
    AND EXISTS (
      SELECT 1
      FROM public.conversation_attachments a
      WHERE a.storage_ref = storage.objects.name
        AND a.account_id = public.current_account_id()
        AND a.status IN ('PENDING','FAILED')
        AND EXISTS (
          SELECT 1
          FROM public.sh_instances s
          WHERE s.sh_id = a.sh_id
            AND s.account_id = public.current_account_id()
            AND s.status <> 'deactivated'
        )
    )
  )
  WITH CHECK (
    bucket_id = 'second-head-conversation'
    AND EXISTS (
      SELECT 1
      FROM public.conversation_attachments a
      WHERE a.storage_ref = storage.objects.name
        AND a.account_id = public.current_account_id()
        AND a.status IN ('PENDING','FAILED')
        AND EXISTS (
          SELECT 1
          FROM public.sh_instances s
          WHERE s.sh_id = a.sh_id
            AND s.account_id = public.current_account_id()
            AND s.status <> 'deactivated'
        )
    )
  );

CREATE OR REPLACE FUNCTION public.runtime_create_conversation_attachment(
  p_filename text,
  p_mime_type text,
  p_size_bytes bigint
)
RETURNS TABLE (
  attachment_id uuid,
  account_id uuid,
  sh_id uuid,
  message_id uuid,
  filename text,
  mime_type text,
  size_bytes bigint,
  storage_ref text,
  status text,
  created_at timestamptz,
  updated_at timestamptz,
  persisted_at timestamptz
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_identity record;
  v_attachment_id uuid := gen_random_uuid();
BEGIN
  SELECT * INTO v_identity FROM public.resolve_identity();
  IF v_identity.account_id IS NULL OR v_identity.sh_id IS NULL THEN
    RAISE EXCEPTION 'CONVERSATION_ATTACHMENT_UNAUTHENTICATED';
  END IF;
  IF p_filename IS NULL OR btrim(p_filename) = '' THEN
    RAISE EXCEPTION 'CONVERSATION_ATTACHMENT_INVALID_FILENAME';
  END IF;
  IF p_mime_type IS NULL OR btrim(p_mime_type) = '' THEN
    RAISE EXCEPTION 'CONVERSATION_ATTACHMENT_INVALID_MIME_TYPE';
  END IF;
  IF p_size_bytes IS NULL OR p_size_bytes < 0 THEN
    RAISE EXCEPTION 'CONVERSATION_ATTACHMENT_INVALID_SIZE';
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM public.sh_instances s
    WHERE s.sh_id = v_identity.sh_id
      AND s.account_id = v_identity.account_id
      AND s.status <> 'deactivated'
  ) THEN
    RAISE EXCEPTION 'CONVERSATION_ATTACHMENT_SH_NOT_ACCESSIBLE';
  END IF;

  RETURN QUERY
  INSERT INTO public.conversation_attachments (
    attachment_id, account_id, sh_id, filename, mime_type, size_bytes,
    storage_ref, status
  )
  VALUES (
    v_attachment_id, v_identity.account_id, v_identity.sh_id,
    p_filename, p_mime_type, p_size_bytes,
    v_attachment_id::text, 'PENDING'
  )
  RETURNING
    conversation_attachments.attachment_id,
    conversation_attachments.account_id,
    conversation_attachments.sh_id,
    conversation_attachments.message_id,
    conversation_attachments.filename,
    conversation_attachments.mime_type,
    conversation_attachments.size_bytes,
    conversation_attachments.storage_ref,
    conversation_attachments.status,
    conversation_attachments.created_at,
    conversation_attachments.updated_at,
    conversation_attachments.persisted_at;
END;
$$;

CREATE OR REPLACE FUNCTION public.runtime_finalize_conversation_attachment(
  p_attachment_id uuid,
  p_message_id uuid
)
RETURNS TABLE (
  attachment_id uuid,
  account_id uuid,
  sh_id uuid,
  message_id uuid,
  filename text,
  mime_type text,
  size_bytes bigint,
  storage_ref text,
  status text,
  created_at timestamptz,
  updated_at timestamptz,
  persisted_at timestamptz
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_identity record;
  v_attachment public.conversation_attachments%rowtype;
  v_message public.conversations%rowtype;
BEGIN
  SELECT * INTO v_identity FROM public.resolve_identity();
  IF v_identity.account_id IS NULL OR v_identity.sh_id IS NULL THEN
    RAISE EXCEPTION 'CONVERSATION_ATTACHMENT_UNAUTHENTICATED';
  END IF;

  SELECT * INTO v_attachment
  FROM public.conversation_attachments
  WHERE attachment_id = p_attachment_id
    AND account_id = v_identity.account_id
    AND sh_id = v_identity.sh_id
  FOR UPDATE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'CONVERSATION_ATTACHMENT_NOT_FOUND';
  END IF;

  SELECT * INTO v_message
  FROM public.conversations c
  WHERE c.message_id = p_message_id
    AND c.account_id = v_identity.account_id
    AND c.sh_id = v_identity.sh_id;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'CONVERSATION_ATTACHMENT_MESSAGE_NOT_FOUND';
  END IF;

  IF v_attachment.status = 'PERSISTED' THEN
    IF v_attachment.message_id IS DISTINCT FROM p_message_id THEN
      RAISE EXCEPTION 'CONVERSATION_ATTACHMENT_ALREADY_FINALIZED';
    END IF;
    RETURN QUERY SELECT
      v_attachment.attachment_id, v_attachment.account_id, v_attachment.sh_id,
      v_attachment.message_id, v_attachment.filename, v_attachment.mime_type,
      v_attachment.size_bytes, v_attachment.storage_ref, v_attachment.status,
      v_attachment.created_at, v_attachment.updated_at, v_attachment.persisted_at;
    RETURN;
  END IF;

  IF v_attachment.status NOT IN ('PENDING','FAILED') THEN
    RAISE EXCEPTION 'CONVERSATION_ATTACHMENT_INVALID_STATE';
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM storage.objects o
    WHERE o.bucket_id = 'second-head-conversation'
      AND o.name = v_attachment.storage_ref
  ) THEN
    RAISE EXCEPTION 'CONVERSATION_ATTACHMENT_STORAGE_OBJECT_NOT_FOUND';
  END IF;

  UPDATE public.conversation_attachments
  SET message_id = p_message_id,
      status = 'PERSISTED',
      persisted_at = now(),
      updated_at = now()
  WHERE attachment_id = v_attachment.attachment_id;

  RETURN QUERY
  SELECT a.attachment_id, a.account_id, a.sh_id, a.message_id,
         a.filename, a.mime_type, a.size_bytes, a.storage_ref, a.status,
         a.created_at, a.updated_at, a.persisted_at
  FROM public.conversation_attachments a
  WHERE a.attachment_id = v_attachment.attachment_id;
END;
$$;

CREATE OR REPLACE FUNCTION public.runtime_fail_conversation_attachment(p_attachment_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_identity record;
  v_status text;
BEGIN
  SELECT * INTO v_identity FROM public.resolve_identity();
  IF v_identity.account_id IS NULL OR v_identity.sh_id IS NULL THEN
    RAISE EXCEPTION 'CONVERSATION_ATTACHMENT_UNAUTHENTICATED';
  END IF;

  SELECT status INTO v_status
  FROM public.conversation_attachments
  WHERE attachment_id = p_attachment_id
    AND account_id = v_identity.account_id
    AND sh_id = v_identity.sh_id
  FOR UPDATE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'CONVERSATION_ATTACHMENT_NOT_FOUND';
  END IF;

  IF v_status = 'PERSISTED' THEN
    RETURN;
  END IF;

  UPDATE public.conversation_attachments
  SET status = 'FAILED', updated_at = now(), persisted_at = NULL
  WHERE attachment_id = p_attachment_id
    AND account_id = v_identity.account_id
    AND sh_id = v_identity.sh_id;
END;
$$;

CREATE OR REPLACE FUNCTION public.runtime_load_conversation_attachments(p_message_id uuid)
RETURNS TABLE (
  attachment_id uuid,
  account_id uuid,
  sh_id uuid,
  message_id uuid,
  filename text,
  mime_type text,
  size_bytes bigint,
  storage_ref text,
  status text,
  created_at timestamptz,
  updated_at timestamptz,
  persisted_at timestamptz
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_identity record;
BEGIN
  SELECT * INTO v_identity FROM public.resolve_identity();
  IF v_identity.account_id IS NULL OR v_identity.sh_id IS NULL THEN
    RAISE EXCEPTION 'CONVERSATION_ATTACHMENT_UNAUTHENTICATED';
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM public.conversations c
    WHERE c.message_id = p_message_id
      AND c.account_id = v_identity.account_id
      AND c.sh_id = v_identity.sh_id
  ) THEN
    RAISE EXCEPTION 'CONVERSATION_ATTACHMENT_MESSAGE_NOT_FOUND';
  END IF;

  RETURN QUERY
  SELECT a.attachment_id, a.account_id, a.sh_id, a.message_id,
         a.filename, a.mime_type, a.size_bytes, a.storage_ref, a.status,
         a.created_at, a.updated_at, a.persisted_at
  FROM public.conversation_attachments a
  WHERE a.message_id = p_message_id
    AND a.account_id = v_identity.account_id
    AND a.sh_id = v_identity.sh_id
    AND a.status = 'PERSISTED'
  ORDER BY a.created_at, a.attachment_id;
END;
$$;

CREATE OR REPLACE FUNCTION public.runtime_detach_conversation_attachment(p_attachment_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_identity record;
  v_count integer;
BEGIN
  SELECT * INTO v_identity FROM public.resolve_identity();
  IF v_identity.account_id IS NULL OR v_identity.sh_id IS NULL THEN
    RAISE EXCEPTION 'CONVERSATION_ATTACHMENT_UNAUTHENTICATED';
  END IF;

  UPDATE public.conversation_attachments
  SET message_id = NULL, updated_at = now()
  WHERE attachment_id = p_attachment_id
    AND account_id = v_identity.account_id
    AND sh_id = v_identity.sh_id;
  GET DIAGNOSTICS v_count = ROW_COUNT;
  IF v_count <> 1 THEN
    RAISE EXCEPTION 'CONVERSATION_ATTACHMENT_NOT_FOUND';
  END IF;
END;
$$;

REVOKE EXECUTE ON FUNCTION public.runtime_create_conversation_attachment(text,text,bigint) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.runtime_create_conversation_attachment(text,text,bigint) TO authenticated, service_role;
REVOKE EXECUTE ON FUNCTION public.runtime_finalize_conversation_attachment(uuid,uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.runtime_finalize_conversation_attachment(uuid,uuid) TO authenticated, service_role;
REVOKE EXECUTE ON FUNCTION public.runtime_fail_conversation_attachment(uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.runtime_fail_conversation_attachment(uuid) TO authenticated, service_role;
REVOKE EXECUTE ON FUNCTION public.runtime_load_conversation_attachments(uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.runtime_load_conversation_attachments(uuid) TO authenticated, service_role;
REVOKE EXECUTE ON FUNCTION public.runtime_detach_conversation_attachment(uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.runtime_detach_conversation_attachment(uuid) TO authenticated, service_role;

-- Recovery integration: attachment descriptors are snapshot evidence and recovery refs are retention dependencies.
CREATE OR REPLACE FUNCTION public.runtime_create_recovery_snapshot(p_sh_id uuid)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_snapshot_id uuid;
  v_account_id uuid;
  v_manifest jsonb;
BEGIN
  SELECT s.account_id INTO v_account_id
  FROM public.sh_instances s
  WHERE s.sh_id=p_sh_id AND s.account_id=public.current_account_id() AND s.status <> 'deactivated';
  IF v_account_id IS NULL THEN
    RAISE EXCEPTION 'RECOVERY_REJECTED: SH not owned by current active account';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.sh_states WHERE sh_id=p_sh_id) THEN
    RAISE EXCEPTION 'RECOVERY_REJECTED: SH State not found';
  END IF;

  SELECT jsonb_build_object(
    'identity_root',jsonb_build_object('sh_id',s.sh_id,'account_id',s.account_id,'sh_type',s.sh_type,'is_primary',s.is_primary,'canonical_name',s.canonical_name,'creator_ref',s.creator_ref,'status',s.status,'metadata',s.metadata,'version',s.version),
    'ownership_root',coalesce((select jsonb_agg(to_jsonb(o)) from public.sh_ownership o where o.sh_id=s.sh_id),'[]'),
    'state',coalesce((select jsonb_build_object('sh_id',st.sh_id,'state_version',st.state_version,'revision',st.revision,'state_payload',st.state_payload,'created_at',st.created_at,'updated_at',st.updated_at) from public.sh_states st where st.sh_id=s.sh_id),'{}'::jsonb),
    'projects',coalesce((select jsonb_agg(to_jsonb(p)) from public.projects p where p.sh_id=s.sh_id),'[]'),
    'conversation_threads',coalesce((select jsonb_agg(to_jsonb(t)) from public.conversation_threads t where t.sh_id=s.sh_id),'[]'),
    'memories',coalesce((select jsonb_agg(to_jsonb(m)) from public.memories m where m.sh_id=s.sh_id),'[]'),
    'conversations',coalesce((select jsonb_agg(to_jsonb(c)) from public.conversations c where c.sh_id=s.sh_id),'[]'),
    'conversation_attachments',coalesce((select jsonb_agg(jsonb_build_object('attachment_id',a.attachment_id,'account_id',a.account_id,'sh_id',a.sh_id,'message_id',a.message_id,'filename',a.filename,'mime_type',a.mime_type,'size_bytes',a.size_bytes,'storage_ref',a.storage_ref,'status',a.status,'created_at',a.created_at,'updated_at',a.updated_at,'persisted_at',a.persisted_at)) from public.conversation_attachments a where a.sh_id=s.sh_id and a.account_id=v_account_id and a.status='PERSISTED' and a.message_id is not null),'[]'),
    'journey_events',coalesce((select jsonb_agg(to_jsonb(j)) from public.journey_events j where j.sh_id=s.sh_id),'[]'),
    'knowledge',coalesce((select jsonb_agg(to_jsonb(k)) from public.knowledge k where k.scope='PRIVATE' and k.sh_id=s.sh_id),'[]'),
    'experiences',coalesce((select jsonb_agg(to_jsonb(e)) from public.experiences e where e.sh_id=s.sh_id),'[]'),
    'legacy_records',coalesce((select jsonb_agg(to_jsonb(l)) from public.legacy_records l where l.source_sh_id=s.sh_id),'[]'),
    'captured_at',now()
  ) into v_manifest
  from public.sh_instances s where s.sh_id=p_sh_id;

  insert into public.recovery_snapshots(sh_id,account_id,snapshot_kind,manifest)
  values(p_sh_id,v_account_id,'FULL',v_manifest)
  returning snapshot_id into v_snapshot_id;

  insert into public.conversation_attachment_recovery_refs(snapshot_id,attachment_id)
  select v_snapshot_id, a.attachment_id
  from public.conversation_attachments a
  where a.sh_id=p_sh_id and a.account_id=v_account_id and a.status='PERSISTED' and a.message_id is not null
  on conflict (snapshot_id, attachment_id) do nothing;

  return v_snapshot_id;
END;
$$;

CREATE OR REPLACE FUNCTION public.runtime_restore_recovery_snapshot(p_snapshot_id uuid)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_snapshot public.recovery_snapshots%rowtype;
  v_recovery_event_id uuid;
  v_existing_event public.recovery_events%rowtype;
  v_sh_id uuid;
  v_identity uuid;
  v_state jsonb;
  v_state_sh_id uuid;
  v_snapshot_state_version integer;
  v_snapshot_revision bigint;
  v_snapshot_payload jsonb;
  v_current_state_version integer;
  v_missing_before integer := 0;
  v_missing_after integer := 0;
  v_attachment_missing_after integer := 0;
  v_continuity_status text;
  v_gap_code text := null;
BEGIN
  SELECT * INTO v_snapshot FROM public.recovery_snapshots
  WHERE snapshot_id=p_snapshot_id AND account_id=public.current_account_id() FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'RECOVERY_REJECTED: snapshot not accessible'; END IF;
  IF EXISTS (SELECT 1 FROM public.sh_instances s WHERE s.sh_id=v_snapshot.sh_id AND s.account_id=public.current_account_id() AND s.status='deactivated') THEN
    RAISE EXCEPTION 'RECOVERY_REJECTED: SH is terminal/deactivated';
  END IF;
  SELECT * INTO v_existing_event FROM public.recovery_events WHERE snapshot_id=p_snapshot_id FOR UPDATE;
  IF FOUND THEN RETURN v_existing_event.recovery_event_id; END IF;

  v_sh_id:=v_snapshot.sh_id;
  v_identity:=(v_snapshot.manifest->'identity_root'->>'sh_id')::uuid;
  IF v_identity<>v_sh_id THEN RAISE EXCEPTION 'RECOVERY_REJECTED: identity root mismatch'; END IF;
  IF NOT EXISTS (SELECT 1 FROM public.sh_instances WHERE sh_id=v_sh_id AND account_id=public.current_account_id()) THEN
    RAISE EXCEPTION 'RECOVERY_REJECTED: target SH ownership mismatch';
  END IF;

  v_state := v_snapshot.manifest->'state';
  IF v_state IS NULL OR jsonb_typeof(v_state) <> 'object' THEN RAISE EXCEPTION 'RECOVERY_REJECTED: State missing from snapshot'; END IF;
  v_state_sh_id := (v_state->>'sh_id')::uuid;
  IF v_state_sh_id<>v_sh_id THEN RAISE EXCEPTION 'RECOVERY_REJECTED: State identity mismatch'; END IF;
  v_snapshot_state_version := (v_state->>'state_version')::integer;
  v_snapshot_revision := (v_state->>'revision')::bigint;
  v_snapshot_payload := v_state->'state_payload';
  IF v_snapshot_state_version IS NULL OR v_snapshot_state_version <= 0 THEN RAISE EXCEPTION 'RECOVERY_REJECTED: invalid State version'; END IF;
  IF v_snapshot_revision IS NULL OR v_snapshot_revision <= 0 THEN RAISE EXCEPTION 'RECOVERY_REJECTED: invalid State revision'; END IF;
  IF jsonb_typeof(v_snapshot_payload) <> 'object' THEN RAISE EXCEPTION 'RECOVERY_REJECTED: invalid State payload'; END IF;

  SELECT state_version INTO v_current_state_version FROM public.sh_states WHERE sh_id=v_sh_id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'RECOVERY_REJECTED: target SH State not found'; END IF;
  IF v_snapshot_state_version <> v_current_state_version THEN RAISE EXCEPTION 'UNSUPPORTED_STATE_VERSION'; END IF;

  SELECT
    coalesce((select count(*) from jsonb_to_recordset(coalesce(v_snapshot.manifest->'projects','[]'::jsonb)) x(project_id uuid,account_id uuid,sh_id uuid) where x.sh_id=v_sh_id and x.account_id=public.current_account_id() and not exists(select 1 from public.projects p where p.project_id=x.project_id)),0)+
    coalesce((select count(*) from jsonb_to_recordset(coalesce(v_snapshot.manifest->'conversation_threads','[]'::jsonb)) x(conversation_id uuid,account_id uuid,sh_id uuid) where x.sh_id=v_sh_id and x.account_id=public.current_account_id() and not exists(select 1 from public.conversation_threads t where t.conversation_id=x.conversation_id)),0)+
    coalesce((select count(*) from jsonb_to_recordset(coalesce(v_snapshot.manifest->'ownership_root','[]'::jsonb)) x(ownership_id uuid,account_id uuid,sh_id uuid) where x.sh_id=v_sh_id and x.account_id=public.current_account_id() and not exists(select 1 from public.sh_ownership o where o.ownership_id=x.ownership_id)),0)+
    coalesce((select count(*) from jsonb_to_recordset(coalesce(v_snapshot.manifest->'memories','[]'::jsonb)) x(memory_id uuid,sh_id uuid) where x.sh_id=v_sh_id and not exists(select 1 from public.memories m where m.memory_id=x.memory_id)),0)+
    coalesce((select count(*) from jsonb_to_recordset(coalesce(v_snapshot.manifest->'conversations','[]'::jsonb)) x(conversation_id uuid,account_id uuid,sh_id uuid) where x.sh_id=v_sh_id and x.account_id=public.current_account_id() and not exists(select 1 from public.conversations c where c.conversation_id=x.conversation_id)),0)+
    coalesce((select count(*) from jsonb_to_recordset(coalesce(v_snapshot.manifest->'journey_events','[]'::jsonb)) x(event_id uuid,account_id uuid,sh_id uuid) where x.sh_id=v_sh_id and x.account_id=public.current_account_id() and not exists(select 1 from public.journey_events j where j.event_id=x.event_id)),0)+
    coalesce((select count(*) from jsonb_to_recordset(coalesce(v_snapshot.manifest->'knowledge','[]'::jsonb)) x(knowledge_id uuid,sh_id uuid,scope text) where x.sh_id=v_sh_id and x.scope='PRIVATE' and not exists(select 1 from public.knowledge k where k.knowledge_id=x.knowledge_id)),0)+
    coalesce((select count(*) from jsonb_to_recordset(coalesce(v_snapshot.manifest->'experiences','[]'::jsonb)) x(experience_id uuid,sh_id uuid,account_id uuid) where x.sh_id=v_sh_id and x.account_id=public.current_account_id() and not exists(select 1 from public.experiences e where e.experience_id=x.experience_id)),0)+
    coalesce((select count(*) from jsonb_to_recordset(coalesce(v_snapshot.manifest->'legacy_records','[]'::jsonb)) x(legacy_id uuid,source_sh_id uuid) where x.source_sh_id=v_sh_id and not exists(select 1 from public.legacy_records l where l.legacy_id=x.legacy_id)),0)
  INTO v_missing_before;

  INSERT INTO public.projects(project_id,account_id,sh_id,name,metadata,created_at,updated_at)
  SELECT x.project_id,x.account_id,x.sh_id,x.name,x.metadata,x.created_at,x.updated_at
  FROM jsonb_to_recordset(coalesce(v_snapshot.manifest->'projects','[]'::jsonb)) x(project_id uuid,account_id uuid,sh_id uuid,name text,metadata jsonb,created_at timestamptz,updated_at timestamptz)
  WHERE x.sh_id=v_sh_id AND x.account_id=public.current_account_id()
  ON CONFLICT (project_id) DO UPDATE SET account_id=excluded.account_id,sh_id=excluded.sh_id,name=excluded.name,metadata=excluded.metadata,created_at=excluded.created_at,updated_at=excluded.updated_at;

  INSERT INTO public.conversation_threads(conversation_id,account_id,sh_id,project_id,title,created_at,updated_at)
  SELECT x.conversation_id,x.account_id,x.sh_id,x.project_id,x.title,x.created_at,x.updated_at
  FROM jsonb_to_recordset(coalesce(v_snapshot.manifest->'conversation_threads','[]'::jsonb)) x(conversation_id uuid,account_id uuid,sh_id uuid,project_id uuid,title text,created_at timestamptz,updated_at timestamptz)
  WHERE x.sh_id=v_sh_id AND x.account_id=public.current_account_id()
    AND (x.project_id IS NULL OR EXISTS(select 1 from public.projects p where p.project_id=x.project_id and p.sh_id=v_sh_id and p.account_id=public.current_account_id()))
  ON CONFLICT (conversation_id) DO UPDATE SET account_id=excluded.account_id,sh_id=excluded.sh_id,project_id=excluded.project_id,title=excluded.title,created_at=excluded.created_at,updated_at=excluded.updated_at;

  INSERT INTO public.sh_ownership(ownership_id,account_id,sh_id,role,granted_at,evidence_ref,created_at)
  SELECT x.ownership_id,x.account_id,x.sh_id,x.role,x.granted_at,x.evidence_ref,x.created_at FROM jsonb_to_recordset(coalesce(v_snapshot.manifest->'ownership_root','[]'::jsonb)) x(ownership_id uuid,account_id uuid,sh_id uuid,role text,granted_at timestamptz,evidence_ref text,created_at timestamptz) WHERE x.sh_id=v_sh_id AND x.account_id=public.current_account_id() ON CONFLICT (ownership_id) DO NOTHING;
  INSERT INTO public.memories(memory_id,sh_id,memory_type,content,source,confidence,scope,visibility,lifecycle,occurrence_count,created_at,updated_at,superseded_by) SELECT x.memory_id,x.sh_id,x.memory_type,x.content,x.source,x.confidence,x.scope,x.visibility,x.lifecycle,x.occurrence_count,x.created_at,x.updated_at,x.superseded_by FROM jsonb_to_recordset(coalesce(v_snapshot.manifest->'memories','[]'::jsonb)) x(memory_id uuid,sh_id uuid,memory_type text,content text,source text,confidence numeric,scope text,visibility text,lifecycle text,occurrence_count integer,created_at timestamptz,updated_at timestamptz,superseded_by uuid) WHERE x.sh_id=v_sh_id ON CONFLICT (memory_id) DO NOTHING;
  INSERT INTO public.conversations(conversation_id,account_id,sh_id,role,content,created_at,metadata,thread_id,message_id) SELECT x.conversation_id,x.account_id,x.sh_id,x.role,x.content,x.created_at,x.metadata,x.thread_id,x.message_id FROM jsonb_to_recordset(coalesce(v_snapshot.manifest->'conversations','[]'::jsonb)) x(conversation_id uuid,account_id uuid,sh_id uuid,role text,content text,created_at timestamptz,metadata jsonb,thread_id uuid,message_id uuid) WHERE x.sh_id=v_sh_id AND x.account_id=public.current_account_id() AND EXISTS(select 1 from public.conversation_threads t where t.conversation_id=x.thread_id and t.sh_id=v_sh_id and t.account_id=public.current_account_id()) ON CONFLICT (conversation_id) DO NOTHING;
  INSERT INTO public.journey_events(sh_id,account_id,event_type,occurred_at,continuity_status,gap_code,payload,source_ref) SELECT x.sh_id,x.account_id,x.event_type,x.occurred_at,x.continuity_status,x.gap_code,x.payload,x.source_ref FROM jsonb_to_recordset(coalesce(v_snapshot.manifest->'journey_events','[]'::jsonb)) x(event_id uuid,sh_id uuid,account_id uuid,event_type text,occurred_at timestamptz,continuity_status text,gap_code text,payload jsonb,source_ref text) WHERE x.sh_id=v_sh_id AND x.account_id=public.current_account_id() ON CONFLICT (event_id) DO NOTHING;
  INSERT INTO public.knowledge(knowledge_id,content,knowledge_class,scope,visibility,source,provenance,confidence,version,lifecycle,superseded_by,created_at,updated_at,sh_id) SELECT x.knowledge_id,x.content,x.knowledge_class,x.scope,x.visibility,x.source,x.provenance,x.confidence,x.version,x.lifecycle,x.superseded_by,x.created_at,x.updated_at,x.sh_id FROM jsonb_to_recordset(coalesce(v_snapshot.manifest->'knowledge','[]'::jsonb)) x(knowledge_id uuid,content text,knowledge_class text,scope text,visibility text,source text,provenance jsonb,confidence numeric,version integer,lifecycle text,superseded_by uuid,created_at timestamptz,updated_at timestamptz,sh_id uuid) WHERE x.sh_id=v_sh_id AND x.scope='PRIVATE' ON CONFLICT (knowledge_id) DO NOTHING;
  INSERT INTO public.experiences(experience_id,sh_id,account_id,experience_type,content,scope,visibility,source_ref,provenance,lifecycle,occurred_at,created_at,updated_at,transfer_policy) SELECT x.experience_id,x.sh_id,x.account_id,x.experience_type,x.content,x.scope,x.visibility,x.source_ref,x.provenance,x.lifecycle,x.occurred_at,x.created_at,x.updated_at,x.transfer_policy FROM jsonb_to_recordset(coalesce(v_snapshot.manifest->'experiences','[]'::jsonb)) x(experience_id uuid,sh_id uuid,account_id uuid,experience_type text,content text,scope text,visibility text,source_ref text,provenance jsonb,lifecycle text,occurred_at timestamptz,created_at timestamptz,updated_at timestamptz,transfer_policy text) WHERE x.sh_id=v_sh_id AND x.account_id=public.current_account_id() ON CONFLICT (experience_id) DO NOTHING;
  INSERT INTO public.legacy_records(legacy_id,source_sh_id,legacy_type,payload,provenance,status,retention_until,created_at) SELECT x.legacy_id,x.source_sh_id,x.legacy_type,x.payload,x.provenance,x.status,x.retention_until,x.created_at FROM jsonb_to_recordset(coalesce(v_snapshot.manifest->'legacy_records','[]'::jsonb)) x(legacy_id uuid,source_sh_id uuid,legacy_type text,payload jsonb,provenance jsonb,status text,retention_until timestamptz,created_at timestamptz) WHERE x.source_sh_id=v_sh_id ON CONFLICT (legacy_id) DO NOTHING;

  -- Restore attachment relationships only when the durable resource and Storage object still exist.
  INSERT INTO public.conversation_attachment_recovery_refs(snapshot_id, attachment_id)
  SELECT p_snapshot_id, x.attachment_id
  FROM jsonb_to_recordset(coalesce(v_snapshot.manifest->'conversation_attachments','[]'::jsonb)) x(attachment_id uuid,message_id uuid)
  JOIN public.conversation_attachments a ON a.attachment_id=x.attachment_id AND a.account_id=public.current_account_id() AND a.sh_id=v_sh_id
  ON CONFLICT (snapshot_id,attachment_id) DO NOTHING;

  UPDATE public.conversation_attachments a
  SET message_id = x.message_id,
      updated_at = now()
  FROM jsonb_to_recordset(coalesce(v_snapshot.manifest->'conversation_attachments','[]'::jsonb)) x(attachment_id uuid,message_id uuid)
  WHERE a.attachment_id=x.attachment_id
    AND a.account_id=public.current_account_id()
    AND a.sh_id=v_sh_id
    AND a.status='PERSISTED'
    AND a.message_id IS NULL
    AND EXISTS (SELECT 1 FROM public.conversations c WHERE c.message_id=x.message_id AND c.account_id=public.current_account_id() AND c.sh_id=v_sh_id)
    AND EXISTS (SELECT 1 FROM storage.objects o WHERE o.bucket_id='second-head-conversation' AND o.name=a.storage_ref);

  SELECT count(*) INTO v_attachment_missing_after
  FROM jsonb_to_recordset(coalesce(v_snapshot.manifest->'conversation_attachments','[]'::jsonb)) x(attachment_id uuid,message_id uuid,storage_ref text,status text)
  WHERE x.status='PERSISTED'
    AND (
      NOT EXISTS (SELECT 1 FROM public.conversation_attachments a WHERE a.attachment_id=x.attachment_id AND a.account_id=public.current_account_id() AND a.sh_id=v_sh_id AND a.status='PERSISTED')
      OR NOT EXISTS (SELECT 1 FROM storage.objects o WHERE o.bucket_id='second-head-conversation' AND o.name=x.storage_ref)
      OR NOT EXISTS (SELECT 1 FROM public.conversations c WHERE c.message_id=x.message_id AND c.account_id=public.current_account_id() AND c.sh_id=v_sh_id)
      OR EXISTS (SELECT 1 FROM public.conversation_attachments a WHERE a.attachment_id=x.attachment_id AND a.message_id IS NOT NULL AND a.message_id<>x.message_id)
    );

  UPDATE public.sh_states SET state_payload=v_snapshot_payload,state_version=v_snapshot_state_version,revision=greatest(revision,v_snapshot_revision)+1,updated_at=now() WHERE sh_id=v_sh_id;

  SELECT
    coalesce((select count(*) from jsonb_to_recordset(coalesce(v_snapshot.manifest->'projects','[]'::jsonb)) x(project_id uuid,account_id uuid,sh_id uuid) where x.sh_id=v_sh_id and x.account_id=public.current_account_id() and not exists(select 1 from public.projects p where p.project_id=x.project_id)),0)+
    coalesce((select count(*) from jsonb_to_recordset(coalesce(v_snapshot.manifest->'conversation_threads','[]'::jsonb)) x(conversation_id uuid,account_id uuid,sh_id uuid) where x.sh_id=v_sh_id and x.account_id=public.current_account_id() and not exists(select 1 from public.conversation_threads t where t.conversation_id=x.conversation_id)),0)+
    coalesce((select count(*) from jsonb_to_recordset(coalesce(v_snapshot.manifest->'conversations','[]'::jsonb)) x(conversation_id uuid,account_id uuid,sh_id uuid,thread_id uuid) where x.sh_id=v_sh_id and x.account_id=public.current_account_id() and (not exists(select 1 from public.conversations c where c.conversation_id=x.conversation_id) or x.thread_id is null or not exists(select 1 from public.conversation_threads t where t.conversation_id=x.thread_id and t.sh_id=v_sh_id and t.account_id=public.current_account_id()))),0)+
    coalesce((select count(*) from jsonb_to_recordset(coalesce(v_snapshot.manifest->'ownership_root','[]'::jsonb)) x(ownership_id uuid,account_id uuid,sh_id uuid) where x.sh_id=v_sh_id and x.account_id=public.current_account_id() and not exists(select 1 from public.sh_ownership o where o.ownership_id=x.ownership_id)),0)+
    coalesce((select count(*) from jsonb_to_recordset(coalesce(v_snapshot.manifest->'memories','[]'::jsonb)) x(memory_id uuid,sh_id uuid) where x.sh_id=v_sh_id and not exists(select 1 from public.memories m where m.memory_id=x.memory_id)),0)+
    coalesce((select count(*) from jsonb_to_recordset(coalesce(v_snapshot.manifest->'journey_events','[]'::jsonb)) x(event_id uuid,account_id uuid,sh_id uuid) where x.sh_id=v_sh_id and x.account_id=public.current_account_id() and not exists(select 1 from public.journey_events j where j.event_id=x.event_id)),0)+
    coalesce((select count(*) from jsonb_to_recordset(coalesce(v_snapshot.manifest->'knowledge','[]'::jsonb)) x(knowledge_id uuid,sh_id uuid,scope text) where x.sh_id=v_sh_id and x.scope='PRIVATE' and not exists(select 1 from public.knowledge k where k.knowledge_id=x.knowledge_id)),0)+
    coalesce((select count(*) from jsonb_to_recordset(coalesce(v_snapshot.manifest->'experiences','[]'::jsonb)) x(experience_id uuid,sh_id uuid,account_id uuid) where x.sh_id=v_sh_id and x.account_id=public.current_account_id() and not exists(select 1 from public.experiences e where e.experience_id=x.experience_id)),0)+
    coalesce((select count(*) from jsonb_to_recordset(coalesce(v_snapshot.manifest->'legacy_records','[]'::jsonb)) x(legacy_id uuid,source_sh_id uuid) where x.source_sh_id=v_sh_id and not exists(select 1 from public.legacy_records l where l.legacy_id=x.legacy_id)),0)
  INTO v_missing_after;
  v_missing_after := v_missing_after + v_attachment_missing_after;

  IF v_missing_after>0 THEN
    v_continuity_status:='GAP_UNRESOLVED';
    v_gap_code:='CONTINUITY_GAP_UNRESOLVED';
  ELSE
    v_continuity_status:='RECOVERED';
    v_gap_code:=case when v_missing_before>0 then 'CONTINUITY_GAP_RECOVERED' else null end;
  END IF;
  INSERT INTO public.recovery_events(snapshot_id,sh_id,outcome,continuity_status,gap_code) VALUES(p_snapshot_id,v_sh_id,'RESTORED',v_continuity_status,v_gap_code) RETURNING recovery_event_id INTO v_recovery_event_id;
  INSERT INTO public.journey_events(sh_id,account_id,event_type,occurred_at,continuity_status,gap_code,payload,source_ref) VALUES(v_sh_id,public.current_account_id(),'RECOVERY',now(),v_continuity_status,v_gap_code,jsonb_build_object('outcome','RESTORED','snapshot_id',p_snapshot_id,'recovery_event_id',v_recovery_event_id,'state_restored',true),'recovery_event:'||v_recovery_event_id::text);
  RETURN v_recovery_event_id;
END;
$$;

-- Verification-marker overload remains a thin wrapper over the updated base snapshot function.
CREATE OR REPLACE FUNCTION public.runtime_create_recovery_snapshot(p_sh_id uuid, p_verification_marker text)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_snapshot_id uuid;
  v_account_id uuid;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'RECOVERY_REJECTED: authentication required'; END IF;
  IF p_verification_marker IS NULL OR btrim(p_verification_marker) = '' THEN RAISE EXCEPTION 'RECOVERY_REJECTED: verification marker required'; END IF;
  v_snapshot_id := public.runtime_create_recovery_snapshot(p_sh_id);
  SELECT account_id INTO v_account_id FROM public.sh_instances WHERE sh_id = p_sh_id AND account_id = public.current_account_id();
  IF v_account_id IS NULL THEN RAISE EXCEPTION 'RECOVERY_REJECTED: SH not owned by current account'; END IF;
  UPDATE public.recovery_snapshots SET manifest = manifest || jsonb_build_object('verification_marker', p_verification_marker, 'verification_only', true) WHERE snapshot_id = v_snapshot_id AND account_id = v_account_id;
  RETURN v_snapshot_id;
END;
$$;

COMMENT ON TABLE public.conversation_attachments IS 'Durable Conversation attachment resource; local filesystem paths are cache only.';
COMMENT ON TABLE public.conversation_attachment_recovery_refs IS 'Recovery retention dependency for durable Conversation attachments.';
COMMENT ON COLUMN public.conversation_attachments.storage_ref IS 'Server-generated opaque Storage object locator; equal to attachment_id text in the fixed private bucket.';

COMMIT;
