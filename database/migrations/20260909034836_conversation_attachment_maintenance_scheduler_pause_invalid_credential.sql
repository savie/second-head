BEGIN;

DO $pause$
DECLARE v_job record;
BEGIN
  FOR v_job IN SELECT jobid FROM cron.job WHERE jobname IN ('sh_conversation_attachment_cleanup','sh_conversation_attachment_orphan_reconciliation') LOOP
    PERFORM cron.unschedule(v_job.jobid);
  END LOOP;
END;
$pause$;

COMMIT;
