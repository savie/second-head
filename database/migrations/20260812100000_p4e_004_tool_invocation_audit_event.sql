-- P4E-004 — Tool invocation audit event
-- Minimal schema reconciliation: reuse existing audit_events and allow the
-- tool invocation event type. No new authority or ownership model is added.

alter table public.audit_events drop constraint if exists audit_events_event_type_check;

alter table public.audit_events
add constraint audit_events_event_type_check
check (event_type in (
  'RUNTIME_REQUEST',
  'RUNTIME_RESPONSE',
  'RUNTIME_MEMORY_DECISION',
  'TOOL_INVOCATION'
));
