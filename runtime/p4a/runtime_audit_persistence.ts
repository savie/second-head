/**
 * P4A-004 — Runtime Audit & Persistence Boundary
 * Phase 4 — Runtime & Orchestration
 *
 * Minimal realization:
 * - record a bounded runtime event after the runtime decision path;
 * - keep audit persistence separate from identity, context, and memory decision;
 * - never treat audit persistence as authority to mutate SH identity/ownership;
 * - make persistence failure explicit to the caller.
 */

export type RuntimeAuditEvent = {
  sh_id: string;
  account_id: string;
  event_type: 'RUNTIME_REQUEST' | 'RUNTIME_RESPONSE' | 'RUNTIME_MEMORY_DECISION';
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
