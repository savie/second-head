/**
 * P4F-004 — Action Failure Handling & Compensation
 * Phase 4 — Runtime & Orchestration
 *
 * Minimal realization:
 * - failure never silently becomes success;
 * - transactional state failures use rollback where available;
 * - external side effects that cannot be literally rolled back use an
 *   explicit compensation/reconciliation path;
 * - unresolved compensation remains visible as FAILED / COMPENSATION_REQUIRED;
 * - identity/ownership metadata is preserved and is not mutated by this layer.
 */

export type FailureHandlingStatus =
  | 'ROLLED_BACK'
  | 'COMPENSATION_REQUIRED'
  | 'COMPENSATED';

export type ActionFailure = Readonly<{
  action_id: string;
  sh_id: string;
  account_id: string;
  actor_id: string;
  reason: string;
  status: 'FAILED';
}>;

export type FailureHandlingResult = Readonly<{
  action_id: string;
  sh_id: string;
  account_id: string;
  actor_id: string;
  status: FailureHandlingStatus;
  reason: string;
}>;

export interface RollbackBoundary {
  rollback(): Promise<void>;
}

export interface CompensationBoundary {
  compensate(failure: ActionFailure): Promise<void>;
}

export function createActionFailure(input: Readonly<{
  action_id: string;
  sh_id: string;
  account_id: string;
  actor_id: string;
  reason: string;
}>): ActionFailure {
  if (!input.action_id.trim()) throw new Error('ACTION_FAILURE_REJECTED: action id is required');
  if (!input.sh_id.trim()) throw new Error('ACTION_FAILURE_REJECTED: SH identity is required');
  if (!input.account_id.trim()) throw new Error('ACTION_FAILURE_REJECTED: account identity is required');
  if (!input.actor_id.trim()) throw new Error('ACTION_FAILURE_REJECTED: actor identity is required');
  if (!input.reason.trim()) throw new Error('ACTION_FAILURE_REJECTED: failure reason is required');

  return Object.freeze({
    action_id: input.action_id,
    sh_id: input.sh_id,
    account_id: input.account_id,
    actor_id: input.actor_id,
    reason: input.reason,
    status: 'FAILED' as const,
  });
}

/**
 * Handles a failed action whose state boundary can be rolled back.
 */
export async function handleRollback(
  failure: ActionFailure,
  boundary: RollbackBoundary,
): Promise<FailureHandlingResult> {
  await boundary.rollback();

  return Object.freeze({
    action_id: failure.action_id,
    sh_id: failure.sh_id,
    account_id: failure.account_id,
    actor_id: failure.actor_id,
    status: 'ROLLED_BACK' as const,
    reason: failure.reason,
  });
}

/**
 * Marks an external side effect for compensation and attempts the explicit
 * compensating operation. Compensation is not represented as database
 * rollback because an external system may not support literal rollback.
 */
export async function handleCompensation(
  failure: ActionFailure,
  boundary: CompensationBoundary,
): Promise<FailureHandlingResult> {
  try {
    await boundary.compensate(failure);

    return Object.freeze({
      action_id: failure.action_id,
      sh_id: failure.sh_id,
      account_id: failure.account_id,
      actor_id: failure.actor_id,
      status: 'COMPENSATED' as const,
      reason: failure.reason,
    });
  } catch {
    return Object.freeze({
      action_id: failure.action_id,
      sh_id: failure.sh_id,
      account_id: failure.account_id,
      actor_id: failure.actor_id,
      status: 'COMPENSATION_REQUIRED' as const,
      reason: failure.reason,
    });
  }
}
