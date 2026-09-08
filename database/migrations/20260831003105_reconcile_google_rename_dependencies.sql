begin;
alter table public.google_oauth_states rename constraint r4_google_oauth_states_account_id_fkey to google_oauth_states_account_id_fkey;
alter table public.google_connections rename constraint r4_google_connections_account_id_fkey to google_connections_account_id_fkey;
alter table public.google_calendar_actions rename constraint r4_google_calendar_actions_account_id_fkey to google_calendar_actions_account_id_fkey;

alter function public.r4_google_connection_status() rename to google_connection_status;
alter function public.r4_google_oauth_cleanup() rename to google_oauth_cleanup;
alter function public.r4_google_calendar_action_cleanup() rename to google_calendar_action_cleanup;

create or replace function public.google_connection_status()
returns table(connection_id uuid, provider text, target_type text, target_id text, scopes text[], status text, connected_at timestamptz, revoked_at timestamptz, last_verified_at timestamptz)
language sql
set search_path to 'public'
as $function$
 select c.connection_id,c.provider,c.target_type,c.target_id,c.scopes,c.status,c.connected_at,c.revoked_at,c.last_verified_at
 from public.google_connections c where c.account_id=public.current_account_id() order by c.updated_at desc limit 1;
$function$;

create or replace function public.google_oauth_cleanup()
returns integer
language plpgsql
security definer
set search_path to 'public'
as $function$
declare v_count integer;
begin
 if current_user <> 'postgres' and current_setting('request.jwt.claims', true)::jsonb->>'role' <> 'service_role' then raise exception 'R4_OAUTH_CLEANUP_DENIED'; end if;
 delete from public.google_oauth_states where expires_at<now() or consumed_at is not null;
 get diagnostics v_count=row_count;
 return v_count;
end;
$function$;

create or replace function public.google_calendar_action_cleanup()
returns integer
language plpgsql
security definer
set search_path to 'public'
as $function$
declare
  v_count integer;
begin
  if current_user <> 'postgres'
     and current_setting('request.jwt.claims', true)::jsonb->>'role' <> 'service_role' then
    raise exception 'R4_ACTION_CLEANUP_DENIED';
  end if;
  update public.google_calendar_actions
     set status = 'EXPIRED', updated_at = now()
   where status in ('PENDING','CONFIRMED')
     and confirmation_expires_at < now();
  get diagnostics v_count = row_count;
  return v_count;
end;
$function$;

commit;