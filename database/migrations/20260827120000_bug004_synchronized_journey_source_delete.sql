-- BUG-004: synchronized Journey <-> source deletion for application/UX lifecycle.
create or replace function public.runtime_delete_record_with_journey(p_domain text,p_record_id uuid)
returns void language plpgsql security definer set search_path=public as $$
declare v_domain text:=upper(trim(p_domain)); v_sh_id uuid; v_account_id uuid; v_exists boolean:=false;
begin
 if auth.uid() is null then raise exception 'RECORD_DELETE_REJECTED: authentication required'; end if;
 if p_record_id is null then raise exception 'RECORD_DELETE_REJECTED: record id required'; end if;
 if v_domain not in ('MEMORY','KNOWLEDGE','EXPERIENCE') then raise exception 'RECORD_DELETE_REJECTED: unsupported source domain'; end if;
 if v_domain='MEMORY' then select m.sh_id into v_sh_id from public.memories m where m.memory_id=p_record_id;
 elsif v_domain='KNOWLEDGE' then select k.sh_id into v_sh_id from public.knowledge k where k.knowledge_id=p_record_id;
 else select e.sh_id into v_sh_id from public.experiences e where e.experience_id=p_record_id and e.account_id=public.current_account_id(); end if;
 if v_sh_id is null then raise exception 'RECORD_DELETE_REJECTED: record not found, unbound, or not owned'; end if;
 select s.account_id into v_account_id from public.sh_instances s where s.sh_id=v_sh_id and s.account_id=public.current_account_id() and s.status<>'deactivated';
 if v_account_id is null then raise exception 'RECORD_DELETE_REJECTED: record not owned by current active account'; end if;
 if v_domain='MEMORY' then v_exists:=exists(select 1 from public.memories where memory_id=p_record_id and sh_id=v_sh_id);
 elsif v_domain='KNOWLEDGE' then v_exists:=exists(select 1 from public.knowledge where knowledge_id=p_record_id and sh_id=v_sh_id);
 else v_exists:=exists(select 1 from public.experiences where experience_id=p_record_id and sh_id=v_sh_id and account_id=public.current_account_id()); end if;
 if not v_exists then raise exception 'RECORD_DELETE_REJECTED: record not found or not owned'; end if;
 delete from public.journey_events j where j.sh_id=v_sh_id and ((v_domain='MEMORY' and upper(j.event_type)='MEMORY' and nullif(j.payload->>'memory_id','')::uuid=p_record_id) or (v_domain='KNOWLEDGE' and upper(j.event_type) in ('KNOWLEDGE','LEARNING') and nullif(j.payload->>'knowledge_id','')::uuid=p_record_id) or (v_domain='EXPERIENCE' and upper(j.event_type)='EXPERIENCE' and nullif(j.payload->>'experience_id','')::uuid=p_record_id));
 if v_domain='MEMORY' then delete from public.memories where memory_id=p_record_id and sh_id=v_sh_id; elsif v_domain='KNOWLEDGE' then delete from public.knowledge where knowledge_id=p_record_id and sh_id=v_sh_id; else delete from public.experiences where experience_id=p_record_id and sh_id=v_sh_id and account_id=public.current_account_id(); end if;
end; $$;

create or replace function public.runtime_delete_journey_record(p_event_id uuid)
returns void language plpgsql security definer set search_path=public as $$
declare v_event public.journey_events%rowtype; v_domain text; v_record_id uuid;
begin
 if auth.uid() is null then raise exception 'JOURNEY_DELETE_REJECTED: authentication required'; end if;
 select j.* into v_event from public.journey_events j join public.sh_instances s on s.sh_id=j.sh_id where j.event_id=p_event_id and s.account_id=public.current_account_id() and s.status<>'deactivated' and j.account_id=public.current_account_id();
 if not found then raise exception 'JOURNEY_DELETE_REJECTED: event not owned by current account'; end if;
 if upper(v_event.event_type)='MEMORY' then v_domain:='MEMORY'; v_record_id:=nullif(v_event.payload->>'memory_id','')::uuid;
 elsif upper(v_event.event_type) in ('KNOWLEDGE','LEARNING') then v_domain:='KNOWLEDGE'; v_record_id:=nullif(v_event.payload->>'knowledge_id','')::uuid;
 elsif upper(v_event.event_type)='EXPERIENCE' then v_domain:='EXPERIENCE'; v_record_id:=nullif(v_event.payload->>'experience_id','')::uuid;
 else delete from public.journey_events where event_id=p_event_id; return; end if;
 if v_record_id is null then delete from public.journey_events where event_id=p_event_id; return; end if;
 perform public.runtime_delete_record_with_journey(v_domain,v_record_id);
end; $$;

revoke all on function public.runtime_delete_record_with_journey(text,uuid) from public,anon;
grant execute on function public.runtime_delete_record_with_journey(text,uuid) to authenticated;
revoke all on function public.runtime_delete_journey_record(uuid) from public,anon;
grant execute on function public.runtime_delete_journey_record(uuid) to authenticated;