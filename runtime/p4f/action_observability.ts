/**
 * P4F-005 — Action Logging & Observability
 * Phase 4 — Runtime & Orchestration
 *
 * Minimal realization:
 * - preserve who/what/when/authorization/outcome traceability;
 * - reuse the existing runtime audit boundary;
 * - keep exact audit storage schema implementation-level;
 * - do not store raw model chain-of-thought or private payloads unnecessarily.
 */

export type ActionAuditStatus = 'SUCCESS' | 'REJECTED' | 'FAILED';

export type ActionAuditRecord = Readonly<{
  action_id: string;
  sh_id: string;
  account_id: string;
  actor_id: string;
  action_type: string;
  authorization_status: 'AUTHORIZED' | 'REJECTED' | 'NOT_AUTHORIZED';
  outcome: string;
  status: ActionAuditStatus;
  metadata?: Readonly<Record<string, unknown>>;
}>;

export interface RuntimeAuditSink {
  record(input: Readonly<{
    sh_id: string;
    event_type: 'RUNTIME_REQUEST' | 'RUNTIME_RESPONSE' | 'RUNTIME_MEMORY_DECISION';
    status: ActionAuditStatus;
    metadata: Readonly<Record<string, unknown>>;
  }>): Promise<void>;
}

/**
 * Records an action outcome through the existing runtime audit boundary.
 * The action audit remains an observability concern and does not become
 * an authorization mechanism by itself.
 */
export async function recordActionAudit(
  sink: RuntimeAuditSink,
  record: ActionAuditRecord,
): Promise<void> {
  if (!record.action_id.trim()) throw new Error('ACTION_AUDIT_REJECTED: action id is required');
  if (!record.sh_id.trim()) throw new Error('ACTION_AUDIT_REJECTED: SH identity is required');
  if (!record.account_id.trim()) throw new Error('ACTION_AUDIT_REJECTED: account identity is required');
  if (!record.actor_id.trim()) throw new Error('ACTION_AUDIT_REJECTED: actor identity is required');
  if (!record.action_type.trim()) throw new Error('ACTION_AUDIT_REJECTED: action type is required');
  if (!record.outcome.trim()) throw new Error('ACTION_AUDIT_REJECTED: outcome is required');

  await sink.record({
    sh_id: record.sh_id,
    event_type: 'RUNTIME_RESPONSE',
    status: record.status,
    metadata: {
      domain: 'ACTION',
      action_id: record.action_id,
      account_id: record.account_id,
      actor_id: record.actor_id,
      action_type: record.action_type,
      authorization_status: record.authorization_status,
      outcome: record.outcome,
      ...(record.metadata ?? {}),
    },
  });
}
