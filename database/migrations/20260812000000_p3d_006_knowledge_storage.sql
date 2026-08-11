-- BL-P3D-006 — Knowledge Storage
-- Minimal realization of the existing P3D-001 logical Knowledge schema.
-- No new acquisition, trust, sharing, or Core governance model is introduced.

create table public.knowledge (
  knowledge_id uuid primary key default gen_random_uuid(),
  content text not null,
  knowledge_class text not null,
  scope text not null default 'GENERAL',
  visibility text not null default 'OWNER_ONLY',
  source text not null,
  provenance jsonb not null default '{}'::jsonb,
  confidence numeric,
  version integer not null default 1,
  lifecycle text not null default 'CANDIDATE',
  superseded_by uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.knowledge enable row level security;

alter table public.knowledge
  add constraint knowledge_class_check
  check (knowledge_class in ('CANONICAL','DERIVED','LEARNED','IMPORTED','TEMPORARY'));

alter table public.knowledge
  add constraint knowledge_scope_check
  check (scope in ('PRIVATE','GENERAL'));

alter table public.knowledge
  add constraint knowledge_visibility_check
  check (visibility in ('OWNER_ONLY','SHARED'));

alter table public.knowledge
  add constraint knowledge_confidence_check
  check (confidence is null or (confidence >= 0 and confidence <= 1));

alter table public.knowledge
  add constraint knowledge_version_check
  check (version >= 1);

alter table public.knowledge
  add constraint knowledge_lifecycle_check
  check (lifecycle in ('CANDIDATE','ACCEPTED','INDEXED','ACTIVE','UPDATED','DEPRECATED','ARCHIVED'));

alter table public.knowledge
  add constraint knowledge_superseded_by_fkey
  foreign key (superseded_by) references public.knowledge(knowledge_id);
