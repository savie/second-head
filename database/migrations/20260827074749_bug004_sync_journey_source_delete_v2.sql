-- BUG-004: keep the Journey-side delete path synchronized with source records.
create or replace function public.runtime_delete_journey_record(p_event_id uuid)
returns void language plpgsql security definer set search_path=public as $$
declare
 v_event public.journey_events%rowtype;
 v_domain text;
 v_record_id uuid;
begin
 if auth.uid() is null then raise exception 'JOURNEY_DELETE_REJECTED: authentication required'; end if;

 select j.* into v_event
 from public.journey_events j
 join public.sh_instances s on s.sh_id=j.sh_id
 where j.event_id=p_event_id
   and s.account_id=public.current_account_id()
   and s.status<>'deactivated'
   and j.account_id=public.current_account_id();

 if not found then raise exception 'JOURNEY_DELETE_REJECTED: event not owned by current account'; end if;

 if upper(v_event.event_type)='MEMORY' then
   v_domain:='MEMORY';
   v_record_id:=nullif(v_event.payload->>'memory_id','')::uuid;
 elsif upper(v_event.event_type) in ('KNOWLEDGE','LEARNING') then
   v_domain:='KNOWLEDGE';
   v_record_id:=nullif(v_event.payload->>'knowledge_id','')::uuid;
 elsif upper(v_event.event_type)='EXPERIENCE' then
   v_domain:='EXPERIENCE';
   v_record_id:=nullif(v_event.payload->>'experience_id','')::uuid;
 else
   delete from public.journey_events where event_id=p_event_id;
   return;
 end if;

 if v_record_id is null then
   delete from public.journey_events where event_id=p_event_id;
   return;
 end if;

 perform public.runtime_delete_record_with_journey(v_domain,v_record_id);
end; $$;

revoke all on function public.runtime_delete_journey_record(uuid) from public,anon;
grant execute on function public.runtime_delete_journey_record(uuid) to authenticated;
