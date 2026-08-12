/**
 * P4A-004 / P4E-004 — Runtime & Tool Audit Persistence Boundary
 * Phase 4 — Runtime & Orchestration
 *
 * Minimal realization:
 * - record a bounded runtime/tool event after the relevant decision path;
 * - keep audit persistence separate from identity, context, memory and tool authority;
 * - never treat audit persistence as authority to mutate SH identity/ownership;
 * - make persistence failure explicit to the caller.
 */

export type RuntimeAuditEvent = {
  sh_id: string;
  account_id: string;
  event_type:
    | 'RUNTIME_REQUEST'
    | 'RUNTIME_RESPONSE'
    | 'RUNTIME_MEMORY_DECISION'
    | 'TOOL_INVOCATION';
  status: 'SUCCESS' | 'REJECTED' | 'FAILED';
  metadata?: Record<string, unknown>;
};

export interface RuntimeAuditSink {
  append(event: RuntimeAuditEvent): Promise<void>;
}

export async function persistRuntimeAudit(
  sink: RuntimeAuditSink,
  event: RuntimeAuditEvent,
): Promise<void> {
  if (!event.sh_id || !event.account_id) {
    throw new Error('RUNTIME_AUDIT_REJECTED: identity context is required');
  }

  await sink.append({
    ...event,
    metadata: event.metadata ? { ...event.metadata } : {},
  });
}
