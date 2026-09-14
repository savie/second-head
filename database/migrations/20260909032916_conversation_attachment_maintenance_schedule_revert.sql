select cron.unschedule(jobid) from cron.job where jobname = 'second-head-conversation-attachment-cleanup';
drop function if exists public.runtime_run_conversation_attachment_maintenance();
