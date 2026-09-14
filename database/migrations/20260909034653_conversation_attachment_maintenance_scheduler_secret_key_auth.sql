BEGIN;

DO $schedule$
DECLARE v_job record;
BEGIN
  FOR v_job IN SELECT jobid FROM cron.job WHERE jobname IN ('sh_conversation_attachment_cleanup','sh_conversation_attachment_orphan_reconciliation') LOOP
    PERFORM cron.unschedule(v_job.jobid);
  END LOOP;
  PERFORM cron.schedule('sh_conversation_attachment_cleanup','*/15 * * * *',$cmd$
    SELECT net.http_post(
      url := 'https://pkhkgvsrqeupvwoqjwmd.supabase.co/functions/v1/runtime-conversation-attachment-cleanup',
      headers := jsonb_build_object('Content-Type','application/json','apikey',(SELECT decrypted_secret FROM vault.decrypted_secrets WHERE name='SUPABASE_SERVICE_ROLE_KEY')),
      body := '{}'::jsonb
    );
  $cmd$);
  PERFORM cron.schedule('sh_conversation_attachment_orphan_reconciliation','17 * * * *',$cmd$
    SELECT net.http_post(
      url := 'https://pkhkgvsrqeupvwoqjwmd.supabase.co/functions/v1/runtime-conversation-attachment-reconcile',
      headers := jsonb_build_object('Content-Type','application/json','apikey',(SELECT decrypted_secret FROM vault.decrypted_secrets WHERE name='SUPABASE_SERVICE_ROLE_KEY')),
      body := '{}'::jsonb
    );
  $cmd$);
END;
$schedule$;

COMMIT;
