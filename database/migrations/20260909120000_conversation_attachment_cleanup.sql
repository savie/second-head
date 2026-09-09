-- SECOND HEAD — Conversation Attachment cleanup / retention reconciliation
-- Contract: docs/contract/sh_conversation_attachment_contract.md
-- Scope: remove detached durable Attachment Resources only when no active Message and no Recovery dependency.
-- Physical Storage Object deletion remains exclusively through the Supabase Storage API.

BEGIN;

CREATE TABLE public.conversation_attachment_cleanup_queue (
  cleanup_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  attachment_id uuid NULL,
  account_id uuid NOT NULL REFERENCES public.accounts(account_id),
  sh_id uuid NOT NULL REFERENCES public.sh_instances(sh_id),
  storage_ref text NOT NULL,
  status text NOT NULL DEFAULT 'QUEUED',
  attempts integer NOT NULL DEFAULT 0,
  available_at timestamptz NOT NULL DEFAULT now(),
  locked_at timestamptz NULL,
  last_error text NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT conversation_attachment_cleanup_status_check
    CHECK (status IN ('QUEUED','PROCESSING','FAILED','COMPLETED')),
  CONSTRAINT conversation_attachment_cleanup_attempts_check
    CHECK (attempts >= 0)
);

CREATE INDEX conversation_attachment_cleanup_ready_idx
  ON public.conversation_attachment_cleanup_queue(status, available_at, created_at);

CREATE INDEX conversation_attachment_cleanup_account_sh_idx
  ON public.conversation_attachment_cleanup_queue(account_id, sh_id, status, available_at);

CREATE UNIQUE INDEX conversation_attachment_cleanup_attachment_uidx
  ON public.conversation_attachment_cleanup_queue(attachment_id)
  WHERE attachment_id IS NOT NULL AND status <> 'COMPLETED';

ALTER TABLE public.conversation_attachment_cleanup_queue ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE public.conversation_attachment_cleanup_queue FROM anon, authenticated;

CREATE OR REPLACE FUNCTION public.enqueue_conversation_attachment_cleanup()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF OLD.message_id IS NOT NULL AND NEW.message_id IS NULL THEN
    INSERT INTO public.conversation_attachment_cleanup_queue(
      attachment_id,
      account_id,
      sh_id,
      storage_ref,
      status,
      attempts,
      available_at,
      locked_at,
      last_error,
      updated_at
    )
    VALUES(
      NEW.attachment_id,
      NEW.account_id,
      NEW.sh_id,
      NEW.storage_ref,
      'QUEUED',
      0,
      now(),
      NULL,
      NULL,
      now()
    )
    ON CONFLICT (attachment_id) WHERE attachment_id IS NOT NULL AND status <> 'COMPLETED'
    DO UPDATE SET
      storage_ref = EXCLUDED.storage_ref,
      account_id = EXCLUDED.account_id,
      sh_id = EXCLUDED.sh_id,
      status = 'QUEUED',
      available_at = now(),
      locked_at = NULL,
      last_error = NULL,
      updated_at = now();
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS conversation_attachment_cleanup_enqueue
  ON public.conversation_attachments;

CREATE TRIGGER conversation_attachment_cleanup_enqueue
AFTER UPDATE OF message_id ON public.conversation_attachments
FOR EACH ROW
WHEN (OLD.message_id IS NOT NULL AND NEW.message_id IS NULL)
EXECUTE FUNCTION public.enqueue_conversation_attachment_cleanup();

CREATE OR REPLACE FUNCTION public.runtime_claim_conversation_attachment_cleanup(p_limit integer DEFAULT 25)
RETURNS TABLE(
  cleanup_id uuid,
  attachment_id uuid,
  account_id uuid,
  sh_id uuid,
  storage_ref text
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_identity record;
  v_limit integer := LEAST(GREATEST(COALESCE(p_limit, 25), 1), 100);
  v_queue public.conversation_attachment_cleanup_queue%rowtype;
  v_attachment public.conversation_attachments%rowtype;
BEGIN
  SELECT * INTO v_identity FROM public.resolve_identity();
  IF v_identity.account_id IS NULL OR v_identity.sh_id IS NULL THEN
    RAISE EXCEPTION 'CONVERSATION_ATTACHMENT_CLEANUP_UNAUTHENTICATED';
  END IF;

  FOR v_queue IN
    SELECT q.*
    FROM public.conversation_attachment_cleanup_queue q
    WHERE q.account_id = v_identity.account_id
      AND q.sh_id = v_identity.sh_id
      AND (
        (q.status IN ('QUEUED','FAILED') AND q.available_at <= now())
        OR (q.status = 'PROCESSING' AND q.locked_at < now() - interval '10 minutes')
      )
    ORDER BY q.created_at, q.cleanup_id
    LIMIT v_limit
    FOR UPDATE SKIP LOCKED
  LOOP
    SELECT * INTO v_attachment
    FROM public.conversation_attachments a
    WHERE a.attachment_id = v_queue.attachment_id
      AND a.account_id = v_identity.account_id
      AND a.sh_id = v_identity.sh_id
    FOR UPDATE;

    IF NOT FOUND THEN
      UPDATE public.conversation_attachment_cleanup_queue
      SET status = 'PROCESSING',
          attempts = attempts + 1,
          locked_at = now(),
          updated_at = now(),
          last_error = NULL
      WHERE cleanup_id = v_queue.cleanup_id;

      RETURN QUERY SELECT v_queue.cleanup_id, v_queue.attachment_id, v_queue.account_id, v_queue.sh_id, v_queue.storage_ref;
      CONTINUE;
    END IF;

    IF v_attachment.message_id IS NOT NULL THEN
      UPDATE public.conversation_attachment_cleanup_queue
      SET status = 'COMPLETED', locked_at = NULL, last_error = NULL, updated_at = now()
      WHERE cleanup_id = v_queue.cleanup_id;
      CONTINUE;
    END IF;

    IF EXISTS (
      SELECT 1
      FROM public.conversation_attachment_recovery_refs r
      WHERE r.attachment_id = v_attachment.attachment_id
    ) THEN
      UPDATE public.conversation_attachment_cleanup_queue
      SET status = 'QUEUED',
          available_at = now() + interval '15 minutes',
          locked_at = NULL,
          last_error = 'RECOVERY_DEPENDENCY_PRESENT',
          updated_at = now()
      WHERE cleanup_id = v_queue.cleanup_id;
      CONTINUE;
    END IF;

    IF v_attachment.status <> 'PERSISTED' THEN
      UPDATE public.conversation_attachment_cleanup_queue
      SET status = 'QUEUED',
          available_at = now() + interval '15 minutes',
          locked_at = NULL,
          last_error = 'NON_PERSISTED_ATTACHMENT_DEFERRED',
          updated_at = now()
      WHERE cleanup_id = v_queue.cleanup_id;
      CONTINUE;
    END IF;

    DELETE FROM public.conversation_attachments
    WHERE attachment_id = v_attachment.attachment_id;

    UPDATE public.conversation_attachment_cleanup_queue
    SET status = 'PROCESSING',
        attempts = attempts + 1,
        locked_at = now(),
        last_error = NULL,
        updated_at = now()
    WHERE cleanup_id = v_queue.cleanup_id;

    RETURN QUERY SELECT v_queue.cleanup_id, v_queue.attachment_id, v_queue.account_id, v_queue.sh_id, v_queue.storage_ref;
  END LOOP;
END;
$$;

CREATE OR REPLACE FUNCTION public.runtime_complete_conversation_attachment_cleanup(p_cleanup_id uuid)
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
    RAISE EXCEPTION 'CONVERSATION_ATTACHMENT_CLEANUP_UNAUTHENTICATED';
  END IF;

  UPDATE public.conversation_attachment_cleanup_queue
  SET status = 'COMPLETED',
      locked_at = NULL,
      last_error = NULL,
      updated_at = now()
  WHERE cleanup_id = p_cleanup_id
    AND account_id = v_identity.account_id
    AND sh_id = v_identity.sh_id
    AND status = 'PROCESSING';

  GET DIAGNOSTICS v_count = ROW_COUNT;
  IF v_count <> 1 THEN
    RAISE EXCEPTION 'CONVERSATION_ATTACHMENT_CLEANUP_NOT_FOUND';
  END IF;
END;
$$;

CREATE OR REPLACE FUNCTION public.runtime_fail_conversation_attachment_cleanup(p_cleanup_id uuid, p_error text)
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
    RAISE EXCEPTION 'CONVERSATION_ATTACHMENT_CLEANUP_UNAUTHENTICATED';
  END IF;

  UPDATE public.conversation_attachment_cleanup_queue
  SET status = 'FAILED',
      available_at = now() + interval '5 minutes',
      locked_at = NULL,
      last_error = left(coalesce(p_error, 'UNKNOWN_STORAGE_CLEANUP_ERROR'), 2000),
      updated_at = now()
  WHERE cleanup_id = p_cleanup_id
    AND account_id = v_identity.account_id
    AND sh_id = v_identity.sh_id
    AND status = 'PROCESSING';

  GET DIAGNOSTICS v_count = ROW_COUNT;
  IF v_count <> 1 THEN
    RAISE EXCEPTION 'CONVERSATION_ATTACHMENT_CLEANUP_NOT_FOUND';
  END IF;
END;
$$;

REVOKE EXECUTE ON FUNCTION public.enqueue_conversation_attachment_cleanup() FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.runtime_claim_conversation_attachment_cleanup(integer) FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public.runtime_complete_conversation_attachment_cleanup(uuid) FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public.runtime_fail_conversation_attachment_cleanup(uuid,text) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.runtime_claim_conversation_attachment_cleanup(integer) TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.runtime_complete_conversation_attachment_cleanup(uuid) TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.runtime_fail_conversation_attachment_cleanup(uuid,text) TO authenticated, service_role;

COMMIT;
