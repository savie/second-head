/**
 * P4F-001 — Action Creation & Risk Classification
 * Phase 4 — Runtime & Orchestration
 *
 * Minimal realization:
 * - consequential operations are represented explicitly as Actions;
 * - risk is classified before execution;
 * - only LOW / MEDIUM / HIGH are accepted;
 * - this module does not execute actions or authorize them;
 * - no identity/ownership mutation occurs during action creation.
 */

export type ActionRisk = 'LOW' | 'MEDIUM' | 'HIGH';

export type ActionRequest = Readonly<{
  action_id: string;
  sh_id: string;
  account_id: string;
  actor_id: string;
  operation: string;
  input: unknown;
  risk: ActionRisk;
}>;

export type Action = Readonly<{
  action_id: string;
  sh_id: string;
  account_id: string;
  actor_id: string;
  operation: string;
  input: unknown;
  risk: ActionRisk;
  status: 'CREATED';
}>;

const RISKS: readonly ActionRisk[] = Object.freeze(['LOW', 'MEDIUM', 'HIGH']);

function isRisk(value: unknown): value is ActionRisk {
  return typeof value === 'string' && RISKS.includes(value as ActionRisk);
}

/**
 * Creates an explicit action object and classifies its supplied risk before
 * any execution boundary can consume it. Authorization and execution remain
 * separate concerns for P4F-002+.
 */
export function createAction(request: ActionRequest): Action {
  if (!request.action_id.trim()) throw new Error('ACTION_REJECTED: action id is required');
  if (!request.sh_id.trim()) throw new Error('ACTION_REJECTED: SH identity is required');
  if (!request.account_id.trim()) throw new Error('ACTION_REJECTED: account identity is required');
  if (!request.actor_id.trim()) throw new Error('ACTION_REJECTED: actor identity is required');
  if (!request.operation.trim()) throw new Error('ACTION_REJECTED: operation is required');
  if (!isRisk(request.risk)) throw new Error('ACTION_REJECTED: risk classification is required');

  return Object.freeze({
    action_id: request.action_id,
    sh_id: request.sh_id,
    account_id: request.account_id,
    actor_id: request.actor_id,
    operation: request.operation,
    input: request.input,
    risk: request.risk,
    status: 'CREATED' as const,
  });
}
