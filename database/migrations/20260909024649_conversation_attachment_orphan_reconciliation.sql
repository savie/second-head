BEGIN;

CREATE OR REPLACE FUNCTION public.runtime_reconcile_conversation_attachment_storage_refs(p_storage_refs text[])
RETURNS TABLE(
  storage_ref text,
  attachment_id uuid,
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
  v_identity record;
  v_ref text;
  v_attachment public.conversation_attachments%rowtype;
BEGIN
  SELECT * INTO v_identity FROM public.resolve_identity();
  IF v_identity.account_id IS NULL OR v_identity.sh_id IS NULL THEN
    RAISE EXCEPTION 'CONVERSATION_ATTACHMENT_RECONCILIATION_UNAUTHENTICATED';
  END IF;

  FOREACH v_ref IN ARRAY COALESCE(p_storage_refs, ARRAY[]::text[])
  LOOP
    IF v_ref IS NULL OR length(v_ref) = 0 THEN
      CONTINUE;
    END IF;

    SELECT * INTO v_attachment
    FROM public.conversation_attachments a
    WHERE a.storage_ref = v_ref
      AND a.account_id = v_identity.account_id
      AND a.sh_id = v_identity.sh_id;

    IF NOT FOUND THEN
      storage_ref := v_ref;
      attachment_id := NULL;
      attachment_status := NULL;
      message_id := NULL;
      recovery_dependency := false;
      disposition := 'ORPHAN_OBJECT';
      RETURN NEXT;
      CONTINUE;
    END IF;

    storage_ref := v_attachment.storage_ref;
    attachment_id := v_attachment.attachment_id;
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

REVOKE EXECUTE ON FUNCTION public.runtime_reconcile_conversation_attachment_storage_refs(text[]) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.runtime_reconcile_conversation_attachment_storage_refs(text[]) TO authenticated, service_role;

COMMIT;
