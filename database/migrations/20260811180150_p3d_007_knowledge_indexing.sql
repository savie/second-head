-- BL-P3D-007 — Knowledge Indexing
-- Minimal database indexing for deterministic Knowledge lookup/filtering.
-- No semantic-search, vector, trust-promotion, or retrieval policy is introduced.

create index if not exists knowledge_lifecycle_idx
  on public.knowledge (lifecycle);

create index if not exists knowledge_class_idx
  on public.knowledge (knowledge_class);

create index if not exists knowledge_scope_visibility_idx
  on public.knowledge (scope, visibility);

create index if not exists knowledge_updated_at_idx
  on public.knowledge (updated_at desc);
