BEGIN;

-- Backend maintenance extension only: preserve the authenticated/user path while
-- allowing the existing cleanup worker to run as a service_role scheduler job.
CREATE OR REPLACE FUNCTION public.runtime_claim_conversation_attachment_cleanup(p_limit integer DEFAULT 25)
RETURNS TABLE(cleanup_id uuid, attachment_id uuid, account_id uuid, sh_id uuid, storage_ref text)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE
  v_identity record;
  v_limit integer := LEAST(GREATEST(COALESCE(p_limit,25),1),100);
  v_queue public.conversation_attachment_cleanup_queue%rowtype;
  v_attachment public.conversation_attachments%rowtype;
  v_service_worker boolean := (auth.role() = 'service_role');
BEGIN
  IF NOT v_service_worker THEN
    SELECT * INTO v_identity FROM public.resolve_identity();
    IF v_identity.account_id IS NULL OR v_identity.sh_id IS NULL THEN RAISE EXCEPTION 'CONVERSATION_ATTACHMENT_CLEANUP_UNAUTHENTICATED'; END IF;
  END IF;
  FOR v_queue IN
    SELECT q.* FROM public.conversation_attachment_cleanup_queue q
    WHERE (v_service_worker OR (q.account_id=v_identity.account_id AND q.sh_id=v_identity.sh_id))
      AND ((q.status IN ('QUEUED','FAILED') AND q.available_at<=now()) OR (q.status='PROCESSING' AND q.locked_at<now()-interval '10 minutes'))
    ORDER BY q.created_at,q.cleanup_id LIMIT v_limit FOR UPDATE SKIP LOCKED
  LOOP
    SELECT * INTO v_attachment FROM public.conversation_attachments a
    WHERE a.attachment_id=v_queue.attachment_id
      AND (v_service_worker OR (a.account_id=v_identity.account_id AND a.sh_id=v_identity.sh_id))
    FOR UPDATE;
    IF NOT FOUND THEN
      UPDATE public.conversation_attachment_cleanup_queue SET status='PROCESSING',attempts=attempts+1,locked_at=now(),updated_at=now(),last_error=NULL WHERE cleanup_id=v_queue.cleanup_id;
      RETURN QUERY SELECT v_queue.cleanup_id,v_queue.attachment_id,v_queue.account_id,v_queue.sh_id,v_queue.storage_ref; CONTINUE;
    END IF;
    IF v_attachment.message_id IS NOT NULL THEN
      UPDATE public.conversation_attachment_cleanup_queue SET status='COMPLETED',locked_at=NULL,last_error=NULL,updated_at=now() WHERE cleanup_id=v_queue.cleanup_id; CONTINUE;
    END IF;
    IF EXISTS (SELECT 1 FROM public.conversation_attachment_recovery_refs r WHERE r.attachment_id=v_attachment.attachment_id) THEN
      UPDATE public.conversation_attachment_cleanup_queue SET status='QUEUED',available_at=now()+interval '15 minutes',locked_at=NULL,last_error='RECOVERY_DEPENDENCY_PRESENT',updated_at=now() WHERE cleanup_id=v_queue.cleanup_id; CONTINUE;
    END IF;
    IF v_attachment.status <> 'PERSISTED' THEN
      UPDATE public.conversation_attachment_cleanup_queue SET status='QUEUED',available_at=now()+interval '15 minutes',locked_at=NULL,last_error='NON_PERSISTED_ATTACHMENT_DEFERRED',updated_at=now() WHERE cleanup_id=v_queue.cleanup_id; CONTINUE;
    END IF;
    DELETE FROM public.conversation_attachments WHERE attachment_id=v_attachment.attachment_id;
    UPDATE public.conversation_attachment_cleanup_queue SET status='PROCESSING',attempts=attempts+1,locked_at=now(),last_error=NULL,updated_at=now() WHERE cleanup_id=v_queue.cleanup_id;
    RETURN QUERY SELECT v_queue.cleanup_id,v_queue.attachment_id,v_queue.account_id,v_queue.sh_id,v_queue.storage_ref;
  END LOOP;
END;
$$;

CREATE OR REPLACE FUNCTION public.runtime_complete_conversation_attachment_cleanup(p_cleanup_id uuid)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path=public AS $$
DECLARE v_identity record; v_count integer;
BEGIN
  IF auth.role() = 'service_role' THEN
    UPDATE public.conversation_attachment_cleanup_queue SET status='COMPLETED',locked_at=NULL,last_error=NULL,updated_at=now() WHERE cleanup_id=p_cleanup_id AND status='PROCESSING';
  ELSE
    SELECT * INTO v_identity FROM public.resolve_identity();
    IF v_identity.account_id IS NULL OR v_identity.sh_id IS NULL THEN RAISE EXCEPTION 'CONVERSATION_ATTACHMENT_CLEANUP_UNAUTHENTICATED'; END IF;
    UPDATE public.conversation_attachment_cleanup_queue SET status='COMPLETED',locked_at=NULL,last_error=NULL,updated_at=now() WHERE cleanup_id=p_cleanup_id AND account_id=v_identity.account_id AND sh_id=v_identity.sh_id AND status='PROCESSING';
  END IF;
  GET DIAGNOSTICS v_count=ROW_COUNT;
  IF v_count<>1 THEN RAISE EXCEPTION 'CONVERSATION_ATTACHMENT_CLEANUP_NOT_FOUND'; END IF;
END;
$$;

CREATE OR REPLACE FUNCTION public.runtime_fail_conversation_attachment_cleanup(p_cleanup_id uuid,p_error text)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path=public AS $$
DECLARE v_identity record; v_count integer;
BEGIN
  IF auth.role() = 'service_role' THEN
    UPDATE public.conversation_attachment_cleanup_queue SET status='FAILED',available_at=now()+interval '5 minutes',locked_at=NULL,last_error=left(coalesce(p_error,'UNKNOWN_STORAGE_CLEANUP_ERROR'),2000),updated_at=now() WHERE cleanup_id=p_cleanup_id AND status='PROCESSING';
  ELSE
    SELECT * INTO v_identity FROM public.resolve_identity();
    IF v_identity.account_id IS NULL OR v_identity.sh_id IS NULL THEN RAISE EXCEPTION 'CONVERSATION_ATTACHMENT_CLEANUP_UNAUTHENTICATED'; END IF;
    UPDATE public.conversation_attachment_cleanup_queue SET status='FAILED',available_at=now()+interval '5 minutes',locked_at=NULL,last_error=left(coalesce(p_error,'UNKNOWN_STORAGE_CLEANUP_ERROR'),2000),updated_at=now() WHERE cleanup_id=p_cleanup_id AND account_id=v_identity.account_id AND sh_id=v_identity.sh_id AND status='PROCESSING';
  END IF;
  GET DIAGNOSTICS v_count=ROW_COUNT;
  IF v_count<>1 THEN RAISE EXCEPTION 'CONVERSATION_ATTACHMENT_CLEANUP_NOT_FOUND'; END IF;
END;
$$;

REVOKE EXECUTE ON FUNCTION public.runtime_claim_conversation_attachment_cleanup(integer) FROM PUBLIC,anon;
REVOKE EXECUTE ON FUNCTION public.runtime_complete_conversation_attachment_cleanup(uuid) FROM PUBLIC,anon;
REVOKE EXECUTE ON FUNCTION public.runtime_fail_conversation_attachment_cleanup(uuid,text) FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION public.runtime_claim_conversation_attachment_cleanup(integer) TO authenticated,service_role;
GRANT EXECUTE ON FUNCTION public.runtime_complete_conversation_attachment_cleanup(uuid) TO authenticated,service_role;
GRANT EXECUTE ON FUNCTION public.runtime_fail_conversation_attachment_cleanup(uuid,text) TO authenticated,service_role;

COMMIT;
