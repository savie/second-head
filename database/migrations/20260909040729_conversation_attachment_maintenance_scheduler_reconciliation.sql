BEGIN;

DO $reconcile$
DECLARE
  v_cleanup_count integer;
  v_orphan_count integer;
  v_cleanup_schedule text;
  v_orphan_schedule text;
  v_cleanup_active boolean;
  v_orphan_active boolean;
BEGIN
  SELECT count(*), max(schedule), bool_and(active)
    INTO v_cleanup_count, v_cleanup_schedule, v_cleanup_active
  FROM cron.job
  WHERE jobname = 'sh_conversation_attachment_cleanup';

  SELECT count(*), max(schedule), bool_and(active)
    INTO v_orphan_count, v_orphan_schedule, v_orphan_active
  FROM cron.job
  WHERE jobname = 'sh_conversation_attachment_orphan_reconciliation';

  IF v_cleanup_count <> 1
     OR v_cleanup_schedule <> '*/15 * * * *'
     OR v_cleanup_active IS DISTINCT FROM true THEN
    RAISE EXCEPTION 'CONVERSATION_ATTACHMENT_CLEANUP_SCHEDULER_RECONCILIATION_FAILED';
  END IF;

  IF v_orphan_count <> 1
     OR v_orphan_schedule <> '17 * * * *'
     OR v_orphan_active IS DISTINCT FROM true THEN
    RAISE EXCEPTION 'CONVERSATION_ATTACHMENT_ORPHAN_SCHEDULER_RECONCILIATION_FAILED';
  END IF;
END;
$reconcile$;

COMMIT;
