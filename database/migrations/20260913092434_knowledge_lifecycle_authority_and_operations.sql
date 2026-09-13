-- SECOND HEAD — Knowledge lifecycle authority and operations
-- Supabase DEV migration applied as 20260913092434.

create table if not exists public.knowledge_lifecycle_confirmations (
  confirmation_id uuid primary key default gen_random_uuid(),
  account_id uuid not null,
  actor_id uuid not null,
  sh_id uuid not null,
  knowledge_id uuid not null,
  transition text not null,
  operation_key text not null,
  decision_ref text not null,
  status text not null default 'PENDING',
  expires_at timestamptz not null default (now() + interval '15 minutes'),
  confirmed_at timestamptz,
  confirmed_by uuid,
  created_at timestamptz not null default now(),
  constraint knowledge_lifecycle_confirmation_status_ck check (status in ('PENDING','CONFIRMED','CANCELLED','EXPIRED')),
  constraint knowledge_lifecycle_confirmation_transition_ck check (transition in ('INDEXED_TO_ACTIVE','ACTIVE_TO_DEPRECATED','DEPRECATED_TO_ARCHIVED'))
);
create index if not exists knowledge_lifecycle_confirmations_lookup_idx on public.knowledge_lifecycle_confirmations(account_id,sh_id,knowledge_id,transition,operation_key,status);

create table if not exists public.knowledge_lifecycle_operations (
  operation_id uuid primary key default gen_random_uuid(),
  account_id uuid not null,
  actor_id uuid not null,
  sh_id uuid not null,
  knowledge_id uuid not null,
  transition text not null,
  expected_lifecycle text not null,
  previous_lifecycle text,
  resulting_lifecycle text,
  operation_key text not null,
  decision_ref text,
  validation_ref text,
  index_ref text,
  update_ref text,
  confirmation_ref text,
  provenance jsonb not null default '{}'::jsonb,
  result_status text not null,
  resulting_knowledge_id uuid,
  resulting_version integer,
  journey_event_id uuid,
  created_at timestamptz not null default now(),
  authorized_at timestamptz not null default now(),
  constraint knowledge_lifecycle_operations_status_ck check (result_status in ('SUCCESS','ALREADY_APPLIED','REJECTED','FAILED'))
);
create unique index if not exists knowledge_lifecycle_operations_idempotency_idx on public.knowledge_lifecycle_operations(account_id,sh_id,operation_key);
create index if not exists knowledge_lifecycle_operations_knowledge_idx on public.knowledge_lifecycle_operations(knowledge_id,created_at desc);

alter table public.knowledge_lifecycle_confirmations enable row level security;
alter table public.knowledge_lifecycle_operations enable row level security;
revoke all on public.knowledge_lifecycle_confirmations from anon,authenticated;
revoke all on public.knowledge_lifecycle_operations from anon,authenticated;

create or replace function public.runtime_create_knowledge_lifecycle_confirmation(p_knowledge_id uuid,p_transition text,p_operation_key text,p_decision_ref text,p_provenance jsonb default '{}'::jsonb) returns uuid language plpgsql security definer set search_path=public as $$ declare v_id uuid; v_account uuid; v_sh uuid; begin if auth.uid() is null then raise exception 'KNOWLEDGE_CONFIRMATION_REJECTED: authentication required'; end if; select s.account_id,s.sh_id into v_account,v_sh from public.knowledge k join public.sh_instances s on s.sh_id=k.sh_id where k.knowledge_id=p_knowledge_id and k.sh_id is not null and s.account_id=public.current_account_id() and s.status<>'deactivated' for update; if v_account is null then raise exception 'KNOWLEDGE_CONFIRMATION_REJECTED: knowledge not owned by current active account'; end if; if p_transition not in ('INDEXED_TO_ACTIVE','ACTIVE_TO_DEPRECATED','DEPRECATED_TO_ARCHIVED') then raise exception 'KNOWLEDGE_CONFIRMATION_REJECTED: invalid transition'; end if; if nullif(btrim(p_operation_key),'') is null or nullif(btrim(p_decision_ref),'') is null then raise exception 'KNOWLEDGE_CONFIRMATION_REJECTED: operation_key and decision_ref are required'; end if; insert into public.knowledge_lifecycle_confirmations(account_id,actor_id,sh_id,knowledge_id,transition,operation_key,decision_ref) values(v_account,auth.uid(),v_sh,p_knowledge_id,p_transition,btrim(p_operation_key),btrim(p_decision_ref)) returning confirmation_id into v_id; return v_id; end; $$;

grant execute on function public.runtime_create_knowledge_lifecycle_confirmation(uuid,text,text,text,jsonb) to authenticated;

create or replace function public.runtime_confirm_knowledge_lifecycle(p_confirmation_id uuid) returns uuid language plpgsql security definer set search_path=public as $$ declare v public.knowledge_lifecycle_confirmations%rowtype; begin if auth.uid() is null then raise exception 'KNOWLEDGE_CONFIRMATION_REJECTED: authentication required'; end if; select * into v from public.knowledge_lifecycle_confirmations where confirmation_id=p_confirmation_id and account_id=public.current_account_id() and actor_id=auth.uid() for update; if not found then raise exception 'KNOWLEDGE_CONFIRMATION_REJECTED: confirmation not found'; end if; if v.status<>'PENDING' then raise exception 'KNOWLEDGE_CONFIRMATION_REJECTED: confirmation not pending'; end if; if v.expires_at<=now() then update public.knowledge_lifecycle_confirmations set status='EXPIRED' where confirmation_id=p_confirmation_id; raise exception 'KNOWLEDGE_CONFIRMATION_REJECTED: confirmation expired'; end if; update public.knowledge_lifecycle_confirmations set status='CONFIRMED',confirmed_at=now(),confirmed_by=auth.uid() where confirmation_id=p_confirmation_id; return p_confirmation_id; end; $$;

grant execute on function public.runtime_confirm_knowledge_lifecycle(uuid) to authenticated;

create or replace function public.runtime_knowledge_transition(p_knowledge_id uuid,p_expected_lifecycle text,p_operation_key text,p_transition text,p_decision_ref text default null,p_validation_ref text default null,p_index_ref text default null,p_update_ref text default null,p_confirmation_ref text default null,p_provenance jsonb default '{}'::jsonb,p_successor_content text default null,p_successor_provenance jsonb default '{}'::jsonb) returns jsonb language plpgsql security definer set search_path=public as $$ declare v_k public.knowledge%rowtype; v_account uuid; v_op public.knowledge_lifecycle_operations%rowtype; v_opid uuid; v_new uuid; v_j uuid; v_next text; v_version int; v_confirm_id uuid; begin if auth.uid() is null then raise exception 'KNOWLEDGE_TRANSITION_REJECTED: authentication required'; end if; if nullif(btrim(p_operation_key),'') is null then raise exception 'KNOWLEDGE_TRANSITION_REJECTED: operation_key required'; end if; select s.account_id into v_account from public.sh_instances s where s.sh_id=(select sh_id from public.knowledge where knowledge_id=p_knowledge_id) and s.account_id=public.current_account_id() and s.status<>'deactivated'; if v_account is null then raise exception 'KNOWLEDGE_TRANSITION_REJECTED: SH not owned by current active account'; end if; select * into v_op from public.knowledge_lifecycle_operations where account_id=v_account and sh_id=(select sh_id from public.knowledge where knowledge_id=p_knowledge_id) and operation_key=btrim(p_operation_key) for update; if found then if v_op.knowledge_id<>p_knowledge_id or v_op.transition<>p_transition then raise exception 'KNOWLEDGE_TRANSITION_REJECTED: operation_key conflict'; end if; return jsonb_build_object('status','ALREADY_APPLIED','operation_id',v_op.operation_id,'knowledge_id',v_op.resulting_knowledge_id,'lifecycle',v_op.resulting_lifecycle,'journey_event_id',v_op.journey_event_id); end if; select * into v_k from public.knowledge where knowledge_id=p_knowledge_id for update; if not found then raise exception 'KNOWLEDGE_TRANSITION_REJECTED: knowledge not found'; end if; if v_k.lifecycle<>p_expected_lifecycle then raise exception 'KNOWLEDGE_TRANSITION_REJECTED: expected lifecycle mismatch'; end if; if v_k.sh_id is null then raise exception 'KNOWLEDGE_TRANSITION_REJECTED: knowledge has no SH owner'; end if; if p_transition='CANDIDATE_TO_ACCEPTED' then v_next:='ACCEPTED'; elsif p_transition='ACCEPTED_TO_INDEXED' then v_next:='INDEXED'; elsif p_transition='INDEXED_TO_ACTIVE' then v_next:='ACTIVE'; elsif p_transition='ACTIVE_TO_UPDATED' then v_next:='UPDATED'; elsif p_transition='ACTIVE_TO_DEPRECATED' then v_next:='DEPRECATED'; elsif p_transition='DEPRECATED_TO_ARCHIVED' then v_next:='ARCHIVED'; else raise exception 'KNOWLEDGE_TRANSITION_REJECTED: invalid transition'; end if; if p_transition in ('INDEXED_TO_ACTIVE','ACTIVE_TO_DEPRECATED','DEPRECATED_TO_ARCHIVED') then if p_confirmation_ref is null then raise exception 'KNOWLEDGE_CONFIRMATION_REQUIRED: confirmation_ref required'; end if; begin v_confirm_id:=p_confirmation_ref::uuid; exception when invalid_text_representation then raise exception 'KNOWLEDGE_CONFIRMATION_REJECTED: invalid confirmation_ref'; end; perform 1 from public.knowledge_lifecycle_confirmations c where c.confirmation_id=v_confirm_id and c.account_id=v_account and c.actor_id=auth.uid() and c.sh_id=v_k.sh_id and c.knowledge_id=v_k.knowledge_id and c.transition=p_transition and c.operation_key=btrim(p_operation_key) and c.status='CONFIRMED' and c.expires_at>now() for update; if not found then raise exception 'KNOWLEDGE_CONFIRMATION_REJECTED: exact confirmation not valid'; end if; end if; if p_transition='ACTIVE_TO_UPDATED' then if nullif(btrim(p_successor_content),'') is null then raise exception 'KNOWLEDGE_TRANSITION_REJECTED: successor content required'; end if; insert into public.knowledge(content,knowledge_class,scope,visibility,source,provenance,confidence,lifecycle,sh_id,transfer_policy,version) values(btrim(p_successor_content),v_k.knowledge_class,v_k.scope,v_k.visibility,v_k.source,coalesce(p_successor_provenance,'{}')||jsonb_build_object('supersedes',v_k.knowledge_id),v_k.confidence,'ACTIVE',v_k.sh_id,v_k.transfer_policy,v_k.version+1) returning knowledge_id,version into v_new,v_version; update public.knowledge set lifecycle='UPDATED',superseded_by=v_new,updated_at=now() where knowledge_id=v_k.knowledge_id; else update public.knowledge set lifecycle=v_next,updated_at=now() where knowledge_id=v_k.knowledge_id; v_new:=v_k.knowledge_id; v_version:=v_k.version; end if; insert into public.knowledge_lifecycle_operations(account_id,actor_id,sh_id,knowledge_id,transition,expected_lifecycle,previous_lifecycle,resulting_lifecycle,operation_key,decision_ref,validation_ref,index_ref,update_ref,confirmation_ref,provenance,result_status,resulting_knowledge_id,resulting_version) values(v_account,auth.uid(),v_k.sh_id,v_k.knowledge_id,p_transition,p_expected_lifecycle,v_k.lifecycle,v_next,btrim(p_operation_key),p_decision_ref,p_validation_ref,p_index_ref,p_update_ref,p_confirmation_ref,coalesce(p_provenance,'{}'),'SUCCESS',v_new,v_version) returning operation_id into v_opid; v_j:=public.runtime_record_journey_event(v_k.sh_id,'LIFECYCLE',now(),'CONTINUOUS',null,jsonb_build_object('domain','KNOWLEDGE','knowledge_id',v_k.knowledge_id,'transition',p_transition,'operation_id',v_opid,'operation_key',btrim(p_operation_key),'previous_lifecycle',v_k.lifecycle,'resulting_lifecycle',v_next,'resulting_knowledge_id',v_new,'resulting_version',v_version,'provenance_ref',p_provenance->>'ref'),p_operation_key); update public.knowledge_lifecycle_operations set journey_event_id=v_j where operation_id=v_opid; return jsonb_build_object('status','SUCCESS','operation_id',v_opid,'knowledge_id',v_new,'lifecycle',v_next,'version',v_version,'journey_event_id',v_j); end; $$;

create or replace function public.runtime_accept_knowledge(p_knowledge_id uuid,p_expected_lifecycle text,p_operation_key text,p_decision_ref text,p_validation_ref text,p_provenance jsonb default '{}'::jsonb) returns jsonb language sql security definer set search_path=public as $$ select public.runtime_knowledge_transition(p_knowledge_id,p_expected_lifecycle,p_operation_key,'CANDIDATE_TO_ACCEPTED',p_decision_ref,p_validation_ref,null,null,null,p_provenance,null,null); $$;
create or replace function public.runtime_index_knowledge(p_knowledge_id uuid,p_expected_lifecycle text,p_operation_key text,p_index_ref text,p_provenance jsonb default '{}'::jsonb) returns jsonb language sql security definer set search_path=public as $$ select public.runtime_knowledge_transition(p_knowledge_id,p_expected_lifecycle,p_operation_key,'ACCEPTED_TO_INDEXED',null,null,p_index_ref,null,null,p_provenance,null,null); $$;
create or replace function public.runtime_activate_knowledge(p_knowledge_id uuid,p_expected_lifecycle text,p_operation_key text,p_decision_ref text,p_confirmation_ref text,p_provenance jsonb default '{}'::jsonb) returns jsonb language sql security definer set search_path=public as $$ select public.runtime_knowledge_transition(p_knowledge_id,p_expected_lifecycle,p_operation_key,'INDEXED_TO_ACTIVE',p_decision_ref,null,null,null,p_confirmation_ref,p_provenance,null,null); $$;
create or replace function public.runtime_update_knowledge(p_knowledge_id uuid,p_expected_lifecycle text,p_operation_key text,p_update_ref text,p_provenance jsonb,p_successor_content text,p_successor_provenance jsonb) returns jsonb language sql security definer set search_path=public as $$ select public.runtime_knowledge_transition(p_knowledge_id,p_expected_lifecycle,p_operation_key,'ACTIVE_TO_UPDATED',null,null,null,p_update_ref,null,p_provenance,p_successor_content,p_successor_provenance); $$;
create or replace function public.runtime_deprecate_knowledge(p_knowledge_id uuid,p_expected_lifecycle text,p_operation_key text,p_decision_ref text,p_confirmation_ref text,p_provenance jsonb default '{}'::jsonb) returns jsonb language sql security definer set search_path=public as $$ select public.runtime_knowledge_transition(p_knowledge_id,p_expected_lifecycle,p_operation_key,'ACTIVE_TO_DEPRECATED',p_decision_ref,null,null,null,p_confirmation_ref,p_provenance,null,null); $$;
create or replace function public.runtime_archive_knowledge(p_knowledge_id uuid,p_expected_lifecycle text,p_operation_key text,p_decision_ref text,p_confirmation_ref text,p_provenance jsonb default '{}'::jsonb) returns jsonb language sql security definer set search_path=public as $$ select public.runtime_knowledge_transition(p_knowledge_id,p_expected_lifecycle,p_operation_key,'DEPRECATED_TO_ARCHIVED',p_decision_ref,null,null,null,p_confirmation_ref,p_provenance,null,null); $$;

grant execute on function public.runtime_accept_knowledge(uuid,text,text,text,text,jsonb) to authenticated;
grant execute on function public.runtime_index_knowledge(uuid,text,text,text,jsonb) to authenticated;
grant execute on function public.runtime_activate_knowledge(uuid,text,text,text,text,jsonb) to authenticated;
grant execute on function public.runtime_update_knowledge(uuid,text,text,text,jsonb,text,jsonb) to authenticated;
grant execute on function public.runtime_deprecate_knowledge(uuid,text,text,text,text,jsonb) to authenticated;
grant execute on function public.runtime_archive_knowledge(uuid,text,text,text,text,jsonb) to authenticated;
revoke all on function public.runtime_knowledge_transition(uuid,text,text,text,text,text,text,text,text,jsonb,text,jsonb) from public,anon,authenticated;
