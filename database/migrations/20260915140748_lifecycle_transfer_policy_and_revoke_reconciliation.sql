-- Lifecycle policy activation belongs to lifecycle selection, not Journey administration.
create or replace function public.runtime_activate_selected_transfer_policy(p_source_sh_id uuid,p_scope jsonb,p_policy text) returns void language plpgsql security definer set search_path=public as $$
declare v_policy text:=upper(trim(coalesce(p_policy,''))); v_source_account uuid:=public.current_account_id(); v_scope jsonb:=coalesce(p_scope,'{}'::jsonb); v_count integer:=0; v_id uuid;
begin
 if auth.uid() is null then raise exception 'TRANSFER_POLICY_REJECTED: authentication required'; end if;
 if v_policy not in ('INHERITANCE','SUCCESSION','LEGACY') then raise exception 'TRANSFER_POLICY_REJECTED: lifecycle policy required'; end if;
 if not exists(select 1 from public.sh_instances s where s.sh_id=p_source_sh_id and s.account_id=v_source_account and s.status<>'deactivated') then raise exception 'TRANSFER_POLICY_REJECTED: source SH ownership required'; end if;
 if coalesce(jsonb_array_length(v_scope->'memory_ids'),0)+coalesce(jsonb_array_length(v_scope->'knowledge_ids'),0)+coalesce(jsonb_array_length(v_scope->'experience_ids'),0)+coalesce(jsonb_array_length(v_scope->'journey_event_ids'),0)=0 then raise exception 'TRANSFER_POLICY_REJECTED: explicit selection required'; end if;
 for v_id in select distinct value::uuid from jsonb_array_elements_text(coalesce(v_scope->'memory_ids','[]'::jsonb)) loop
  if not exists(select 1 from public.memories m where m.memory_id=v_id and m.sh_id=p_source_sh_id and m.scope='GENERAL' and m.visibility='SHARED') then raise exception 'TRANSFER_POLICY_REJECTED: selected memory is not owned/shared'; end if;
  update public.memories set transfer_policy=v_policy,updated_at=now() where memory_id=v_id;
  update public.journey_events set transfer_policy=v_policy,visibility='SHARED' where sh_id=p_source_sh_id and event_type='MEMORY' and payload->>'memory_id'=v_id::text; v_count:=v_count+1;
 end loop;
 for v_id in select distinct value::uuid from jsonb_array_elements_text(coalesce(v_scope->'knowledge_ids','[]'::jsonb)) loop
  if not exists(select 1 from public.knowledge k where k.knowledge_id=v_id and k.sh_id=p_source_sh_id and k.scope='GENERAL' and k.visibility='SHARED') then raise exception 'TRANSFER_POLICY_REJECTED: selected knowledge is not owned/shared'; end if;
  update public.knowledge set transfer_policy=v_policy,updated_at=now() where knowledge_id=v_id;
  update public.journey_events set transfer_policy=v_policy,visibility='SHARED' where sh_id=p_source_sh_id and event_type in ('KNOWLEDGE','LEARNING') and payload->>'knowledge_id'=v_id::text; v_count:=v_count+1;
 end loop;
 for v_id in select distinct value::uuid from jsonb_array_elements_text(coalesce(v_scope->'experience_ids','[]'::jsonb)) loop
  if not exists(select 1 from public.experiences e where e.experience_id=v_id and e.sh_id=p_source_sh_id and e.scope='GENERAL' and e.visibility='SHARED') then raise exception 'TRANSFER_POLICY_REJECTED: selected experience is not owned/shared'; end if;
  update public.experiences set transfer_policy=v_policy,updated_at=now() where experience_id=v_id;
  update public.journey_events set transfer_policy=v_policy,visibility='SHARED' where sh_id=p_source_sh_id and event_type='EXPERIENCE' and payload->>'experience_id'=v_id::text; v_count:=v_count+1;
 end loop;
 for v_id in select distinct value::uuid from jsonb_array_elements_text(coalesce(v_scope->'journey_event_ids','[]'::jsonb)) loop
  if not exists(select 1 from public.journey_events j where j.event_id=v_id and j.sh_id=p_source_sh_id and j.visibility='SHARED') then raise exception 'TRANSFER_POLICY_REJECTED: selected Journey event is not owned/shared'; end if;
  update public.journey_events set transfer_policy=v_policy where event_id=v_id; v_count:=v_count+1;
 end loop;
 if v_count=0 then raise exception 'TRANSFER_POLICY_REJECTED: no valid selection'; end if;
end; $$;
revoke all on function public.runtime_activate_selected_transfer_policy(uuid,jsonb,text) from public,anon;
grant execute on function public.runtime_activate_selected_transfer_policy(uuid,jsonb,text) to authenticated;

create or replace function public.runtime_create_inheritance_authorization_by_email(p_target_email text,p_scope jsonb default '{}'::jsonb) returns public.inheritance_authorizations language plpgsql security definer set search_path=public as $$
declare v_source_account uuid:=public.current_account_id(); v_source_sh_id uuid; v_target_account uuid; v_target_sh_id uuid; v_auth public.inheritance_authorizations%rowtype;
begin
 if auth.uid() is null then raise exception 'INHERITANCE_AUTHORIZATION_REJECTED: authentication required'; end if;
 select s.sh_id into v_source_sh_id from public.sh_instances s where s.account_id=v_source_account and s.status<>'deactivated' order by s.is_primary desc,s.created_at asc limit 1;
 if v_source_sh_id is null then raise exception 'INHERITANCE_AUTHORIZATION_REJECTED: active source SH required'; end if;
 select a.account_id into v_target_account from public.accounts a where lower(trim(a.email))=lower(trim(p_target_email)) and a.status<>'deactivated' limit 1;
 if v_target_account is null or v_target_account=v_source_account then raise exception 'INHERITANCE_AUTHORIZATION_REJECTED: active target account required'; end if;
 select s.sh_id into v_target_sh_id from public.sh_instances s where s.account_id=v_target_account and s.status<>'deactivated' and s.is_primary=true order by s.created_at asc limit 1;
 if v_target_sh_id is null then raise exception 'INHERITANCE_AUTHORIZATION_REJECTED: active target PRIMARY SH required'; end if;
 perform public.runtime_activate_selected_transfer_policy(v_source_sh_id,coalesce(p_scope,'{}'::jsonb),'INHERITANCE');
 insert into public.inheritance_authorizations(source_sh_id,target_sh_id,source_account_id,target_account_id,status,scope) values(v_source_sh_id,v_target_sh_id,v_source_account,v_target_account,'PENDING',coalesce(p_scope,'{}'::jsonb)) returning * into v_auth; return v_auth;
end; $$;
grant execute on function public.runtime_create_inheritance_authorization_by_email(text,jsonb) to authenticated;
revoke execute on function public.runtime_create_inheritance_authorization_by_email(text,jsonb) from anon;

create or replace function public.runtime_create_inheritance_authorization(p_source_sh_id uuid,p_target_sh_id uuid,p_source_account_id uuid,p_target_account_id uuid,p_scope jsonb default '{}'::jsonb) returns public.inheritance_authorizations language plpgsql security definer set search_path=public as $$
declare v_auth public.inheritance_authorizations%rowtype;
begin
 if auth.uid() is null then raise exception 'INHERITANCE_AUTHORIZATION_REJECTED: authentication required'; end if;
 if p_source_account_id<>public.current_account_id() then raise exception 'INHERITANCE_AUTHORIZATION_REJECTED: source owner required'; end if;
 if p_source_account_id=p_target_account_id then raise exception 'INHERITANCE_AUTHORIZATION_REJECTED: source and target accounts must differ'; end if;
 if not exists(select 1 from public.sh_instances s where s.sh_id=p_source_sh_id and s.account_id=p_source_account_id and s.status<>'deactivated') then raise exception 'INHERITANCE_AUTHORIZATION_REJECTED: source SH ownership required'; end if;
 if not exists(select 1 from public.sh_instances s where s.sh_id=p_target_sh_id and s.account_id=p_target_account_id and s.status<>'deactivated') then raise exception 'INHERITANCE_AUTHORIZATION_REJECTED: target SH/account mismatch'; end if;
 if p_source_sh_id=p_target_sh_id then raise exception 'INHERITANCE_AUTHORIZATION_REJECTED: source and target SH must differ'; end if;
 perform public.runtime_activate_selected_transfer_policy(p_source_sh_id,coalesce(p_scope,'{}'::jsonb),'INHERITANCE');
 insert into public.inheritance_authorizations(source_sh_id,target_sh_id,source_account_id,target_account_id,status,scope) values(p_source_sh_id,p_target_sh_id,p_source_account_id,p_target_account_id,'PENDING',coalesce(p_scope,'{}'::jsonb)) returning * into v_auth; return v_auth;
end; $$;
grant execute on function public.runtime_create_inheritance_authorization(uuid,uuid,uuid,uuid,jsonb) to authenticated;
revoke execute on function public.runtime_create_inheritance_authorization(uuid,uuid,uuid,uuid,jsonb) from anon;

create or replace function public.runtime_create_succession_rule_by_email(p_target_email text,p_scope jsonb default '{}'::jsonb) returns public.succession_rules language plpgsql security definer set search_path=public as $$
declare v_source_account uuid:=public.current_account_id(); v_source_sh_id uuid; v_successor_account_id uuid; v_rule public.succession_rules%rowtype;
begin
 if auth.uid() is null then raise exception 'SUCCESSION_REQUEST_REJECTED: authentication required'; end if;
 select s.sh_id into v_source_sh_id from public.sh_instances s where s.account_id=v_source_account and s.status<>'deactivated' order by s.is_primary desc,s.created_at asc limit 1;
 if v_source_sh_id is null then raise exception 'SUCCESSION_REQUEST_REJECTED: active source SH required'; end if;
 select a.account_id into v_successor_account_id from public.accounts a where lower(trim(a.email))=lower(trim(p_target_email)) and a.status<>'deactivated' limit 1;
 if v_successor_account_id is null then raise exception 'SUCCESSION_REQUEST_REJECTED: target email is not an active account'; end if;
 if v_successor_account_id=v_source_account then raise exception 'SUCCESSION_REQUEST_REJECTED: source and successor accounts must differ'; end if;
 perform public.runtime_activate_selected_transfer_policy(v_source_sh_id,coalesce(p_scope,'{}'::jsonb),'SUCCESSION');
 insert into public.succession_rules(source_sh_id,successor_account_id,status,scope) values(v_source_sh_id,v_successor_account_id,'ACTIVE',coalesce(p_scope,'{}'::jsonb)) returning * into v_rule; return v_rule;
end; $$;
grant execute on function public.runtime_create_succession_rule_by_email(text,jsonb) to authenticated;
revoke execute on function public.runtime_create_succession_rule_by_email(text,jsonb) from anon;

create or replace function public.runtime_revoke_succession_rule(p_succession_id uuid) returns void language plpgsql security definer set search_path=public as $$
declare v_rule public.succession_rules%rowtype;
begin
 if auth.uid() is null then raise exception 'SUCCESSION_REVOKE_REJECTED: authentication required'; end if;
 select * into v_rule from public.succession_rules where succession_id=p_succession_id for update;
 if not found then raise exception 'SUCCESSION_REVOKE_REJECTED: rule not found'; end if;
 if not exists(select 1 from public.sh_instances s where s.sh_id=v_rule.source_sh_id and s.account_id=public.current_account_id()) then raise exception 'SUCCESSION_REVOKE_REJECTED: source owner required'; end if;
 if v_rule.status<>'ACTIVE' then raise exception 'SUCCESSION_REVOKE_REJECTED: succession rule not revocable'; end if;
 update public.succession_rules set status='REVOKED' where succession_id=p_succession_id;
end; $$;
revoke all on function public.runtime_revoke_succession_rule(uuid) from public,anon;
grant execute on function public.runtime_revoke_succession_rule(uuid) to authenticated;
