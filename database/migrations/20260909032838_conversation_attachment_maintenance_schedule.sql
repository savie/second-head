create extension if not exists pg_cron with schema extensions;

create or replace function public.runtime_run_conversation_attachment_maintenance()
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_url text;
  v_service_key text;
begin
  v_url := current_setting('app.settings.supabase_url', true);
  v_service_key := current_setting('app.settings.supabase_service_role_key', true);

  if v_url is null or v_url = '' or v_service_key is null or v_service_key = '' then
    raise exception 'CONVERSATION_ATTACHMENT_MAINTENANCE_CONFIGURATION_MISSING';
  end if;

  perform net.http_post(
    url := rtrim(v_url, '/') || '/functions/v1/runtime-conversation-attachment-cleanup',
    headers := jsonb_build_object('Content-Type','application/json','Authorization','Bearer ' || v_service_key),
    body := '{}'::jsonb
  );

  perform net.http_post(
    url := rtrim(v_url, '/') || '/functions/v1/runtime-conversation-attachment-reconcile',
    headers := jsonb_build_object('Content-Type','application/json','Authorization','Bearer ' || v_service_key),
    body := '{}'::jsonb
  );
end;
$$;

revoke all on function public.runtime_run_conversation_attachment_maintenance() from public, anon, authenticated;
grant execute on function public.runtime_run_conversation_attachment_maintenance() to service_role;

select cron.unschedule(jobid) from cron.job where jobname in ('second-head-conversation-attachment-cleanup','second-head-conversation-attachment-reconcile');

select cron.schedule('second-head-conversation-attachment-cleanup', '*/15 * * * *', $$select public.runtime_run_conversation_attachment_maintenance();$$);
