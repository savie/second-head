-- SECOND HEAD — Follow-up corrective migration for conversation attachment finalize.
-- Root cause: RETURNS TABLE output column attachment_id also shadows the UPDATE target column.
-- This migration qualifies the UPDATE target and preserves the same contract.

CREATE OR REPLACE FUNCTION public.runtime_finalize_conversation_attachment(p_attachment_id uuid,p_message_id uuid)
RETURNS TABLE(attachment_id uuid,account_id uuid,sh_id uuid,message_id uuid,filename text,mime_type text,size_bytes bigint,storage_ref text,status text,created_at timestamptz,updated_at timestamptz,persisted_at timestamptz)
LANGUAGE plpgsql SECURITY DEFINER SET search_path=public AS $$
DECLARE
  v_identity record;
  v_attachment public.conversation_attachments%rowtype;
BEGIN
  SELECT * INTO v_identity FROM public.resolve_identity();
  IF v_identity.account_id IS NULL OR v_identity.sh_id IS NULL THEN
    RAISE EXCEPTION 'CONVERSATION_ATTACHMENT_UNAUTHENTICATED';
  END IF;

  SELECT a.* INTO v_attachment
  FROM public.conversation_attachments AS a
  WHERE a.attachment_id = p_attachment_id
    AND a.account_id = v_identity.account_id
    AND a.sh_id = v_identity.sh_id
  FOR UPDATE;

  IF NOT FOUND THEN RAISE EXCEPTION 'CONVERSATION_ATTACHMENT_NOT_FOUND'; END IF;
  IF NOT EXISTS (
    SELECT 1 FROM public.conversations AS c
    WHERE c.message_id = p_message_id
      AND c.account_id = v_identity.account_id
      AND c.sh_id = v_identity.sh_id
  ) THEN
    RAISE EXCEPTION 'CONVERSATION_ATTACHMENT_MESSAGE_NOT_FOUND';
  END IF;

  IF v_attachment.status = 'PERSISTED' THEN
    IF v_attachment.message_id IS DISTINCT FROM p_message_id THEN
      RAISE EXCEPTION 'CONVERSATION_ATTACHMENT_ALREADY_FINALIZED';
    END IF;
    RETURN QUERY
      SELECT v_attachment.attachment_id,v_attachment.account_id,v_attachment.sh_id,v_attachment.message_id,
             v_attachment.filename,v_attachment.mime_type,v_attachment.size_bytes,v_attachment.storage_ref,
             v_attachment.status,v_attachment.created_at,v_attachment.updated_at,v_attachment.persisted_at;
    RETURN;
  END IF;

  IF v_attachment.status NOT IN ('PENDING','FAILED') THEN
    RAISE EXCEPTION 'CONVERSATION_ATTACHMENT_INVALID_STATE';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM storage.objects AS o
    WHERE o.bucket_id = 'second-head-conversation'
      AND o.name = v_attachment.storage_ref
  ) THEN
    RAISE EXCEPTION 'CONVERSATION_ATTACHMENT_STORAGE_OBJECT_NOT_FOUND';
  END IF;

  UPDATE public.conversation_attachments AS a
  SET message_id = p_message_id,
      status = 'PERSISTED',
      persisted_at = now(),
      updated_at = now()
  WHERE a.attachment_id = v_attachment.attachment_id;

  RETURN QUERY
    SELECT a.attachment_id,a.account_id,a.sh_id,a.message_id,a.filename,a.mime_type,a.size_bytes,
           a.storage_ref,a.status,a.created_at,a.updated_at,a.persisted_at
    FROM public.conversation_attachments AS a
    WHERE a.attachment_id = v_attachment.attachment_id;
END;
$$;
