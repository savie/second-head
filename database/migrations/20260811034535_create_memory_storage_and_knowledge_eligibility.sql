create table if not exists public.memories (
  memory_id uuid primary key default gen_random_uuid(),
  sh_id uuid not null references public.sh_instances(sh_id) on delete cascade,
  memory_type text not null default 'LONG_TERM',
  content text not null,
  source text not null,
  confidence numeric(5,4),
  scope text not null default 'PRIVATE',
  visibility text not null default 'OWNER_ONLY',
  lifecycle text not null default 'ACTIVE',
  occurrence_count integer not null default 1,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  superseded_by uuid null references public.memories(memory_id),
  constraint memories_memory_type_check check (memory_type in ('SHORT_TERM','LONG_TERM')),
  constraint memories_scope_check check (scope in ('PRIVATE','GENERAL')),
  constraint memories_visibility_check check (visibility in ('OWNER_ONLY','SHARED')),
  constraint memories_lifecycle_check check (lifecycle in ('CANDIDATE','ACTIVE','UPDATED','SUPERSEDED','ARCHIVED','DEACTIVATED','DELETED')),
  constraint memories_occurrence_count_check check (occurrence_count >= 1),
  constraint memories_confidence_check check (confidence is null or (confidence >= 0 and confidence <= 1))
);

create index if not exists memories_sh_id_lifecycle_idx
  on public.memories (sh_id, lifecycle, updated_at desc);

create index if not exists memories_sh_id_occurrence_idx
  on public.memories (sh_id, occurrence_count desc);

alter table public.memories enable row level security;

create policy memories_owner_select
  on public.memories
  for select
  to authenticated
  using (
    exists (
      select 1
      from public.sh_instances s
      join public.account_auth_links aal on aal.account_id = s.account_id
      where s.sh_id = memories.sh_id
        and aal.subject_ref = auth.uid()::text
    )
  );

create policy memories_owner_insert
  on public.memories
  for insert
  to authenticated
  with check (
    exists (
      select 1
      from public.sh_instances s
      join public.account_auth_links aal on aal.account_id = s.account_id
      where s.sh_id = memories.sh_id
        and aal.subject_ref = auth.uid()::text
    )
  );

create policy memories_owner_update
  on public.memories
  for update
  to authenticated
  using (
    exists (
      select 1
      from public.sh_instances s
      join public.account_auth_links aal on aal.account_id = s.account_id
      where s.sh_id = memories.sh_id
        and aal.subject_ref = auth.uid()::text
    )
  )
  with check (
    exists (
      select 1
      from public.sh_instances s
      join public.account_auth_links aal on aal.account_id = s.account_id
      where s.sh_id = memories.sh_id
        and aal.subject_ref = auth.uid()::text
    )
  );

create policy memories_owner_delete
  on public.memories
  for delete
  to authenticated
  using (
    exists (
      select 1
      from public.sh_instances s
      join public.account_auth_links aal on aal.account_id = s.account_id
      where s.sh_id = memories.sh_id
        and aal.subject_ref = auth.uid()::text
    )
  );

create or replace view public.memory_knowledge_eligibility
with (security_invoker = true)
as
select
  m.memory_id,
  m.sh_id,
  m.scope,
  m.occurrence_count,
  (m.scope = 'GENERAL' and m.occurrence_count >= 5) as knowledge_candidate
from public.memories m
where m.lifecycle in ('CANDIDATE','ACTIVE');
