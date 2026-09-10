BEGIN;

CREATE OR REPLACE FUNCTION public.runtime_reconcile_conversation_attachment_storage_refs_internal(p_storage_refs text[])
RETURNS TABLE(
  storage_ref text,
  attachment_id uuid,
  account_id uuid,
  sh_id uuid,
  attachment_status text,
  message_id uuid,
  recovery_dependency boolean,
  disposition text
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_ref text;
  v_attachment public.conversation_attachments%rowtype;
BEGIN
  FOREACH v_ref IN ARRAY COALESCE(p_storage_refs, ARRAY[]::text[])
  LOOP
    IF v_ref IS NULL OR length(v_ref) = 0 THEN
      CONTINUE;
    END IF;

    SELECT * INTO v_attachment
    FROM public.conversation_attachments a
    WHERE a.storage_ref = v_ref;

    IF NOT FOUND THEN
      storage_ref := v_ref;
      attachment_id := NULL;
      account_id := NULL;
      sh_id := NULL;
      attachment_status := NULL;
      message_id := NULL;
      recovery_dependency := false;
      disposition := 'ORPHAN_OBJECT';
      RETURN NEXT;
      CONTINUE;
    END IF;

    storage_ref := v_attachment.storage_ref;
    attachment_id := v_attachment.attachment_id;
    account_id := v_attachment.account_id;
    sh_id := v_attachment.sh_id;
    attachment_status := v_attachment.status;
    message_id := v_attachment.message_id;

    SELECT EXISTS (
      SELECT 1 FROM public.conversation_attachment_recovery_refs r
      WHERE r.attachment_id = v_attachment.attachment_id
    ) INTO recovery_dependency;

    IF v_attachment.status IN ('PENDING','FAILED') THEN
      disposition := 'RETRYABLE_ATTACHMENT_RESOURCE';
    ELSIF v_attachment.status = 'PERSISTED' AND v_attachment.message_id IS NULL AND NOT recovery_dependency THEN
      disposition := 'DETACHED_CLEANUP_CANDIDATE';
    ELSE
      disposition := 'REFERENCED_OR_RETAINED';
    END IF;

    RETURN NEXT;
  END LOOP;
END;
$$;

REVOKE EXECUTE ON FUNCTION public.runtime_reconcile_conversation_attachment_storage_refs_internal(text[]) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.runtime_reconcile_conversation_attachment_storage_refs_internal(text[]) TO service_role;

COMMIT;
