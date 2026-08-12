/**
 * P4F-002 — High-Risk Action Authorization Gate
 * Phase 4 — Runtime & Orchestration
 *
 * Minimal realization:
 * - HIGH-risk actions cannot bypass PLAN → AUTHORIZATION → CONFIRMATION;
 * - authorization and confirmation are represented as distinct gates;
 * - this module does not execute actions;
 * - no identity/ownership mutation occurs during authorization.
 */

export type HighRiskGateStatus =
  | 'PLANNED'
  | 'AUTHORIZATION_PENDING'
  | 'CONFIRMATION_PENDING'
  | 'AUTHORIZED';

export type HighRiskAction = Readonly<{
  action_id: string;
  sh_id: string;
  account_id: string;
  actor_id: string;
  risk: 'HIGH';
  status: HighRiskGateStatus;
}>;

export function createHighRiskPlan(action: Readonly<{
  action_id: string;
  sh_id: string;
  account_id: string;
  actor_id: string;
  risk: 'HIGH';
}>): HighRiskAction {
  if (!action.action_id.trim()) throw new Error('HIGH_RISK_REJECTED: action id is required');
  if (!action.sh_id.trim()) throw new Error('HIGH_RISK_REJECTED: SH identity is required');
  if (!action.account_id.trim()) throw new Error('HIGH_RISK_REJECTED: account identity is required');
  if (!action.actor_id.trim()) throw new Error('HIGH_RISK_REJECTED: actor identity is required');

  return Object.freeze({ ...action, status: 'PLANNED' as const });
}

export function requestAuthorization(action: HighRiskAction): HighRiskAction {
  if (action.status !== 'PLANNED') {
    throw new Error('HIGH_RISK_GATE_REJECTED: authorization must follow planning');
  }
  return Object.freeze({ ...action, status: 'AUTHORIZATION_PENDING' as const });
}

export function authorize(action: HighRiskAction, authorized: boolean): HighRiskAction {
  if (action.status !== 'AUTHORIZATION_PENDING') {
    throw new Error('HIGH_RISK_GATE_REJECTED: authorization is not pending');
  }
  if (!authorized) {
    throw new Error('HIGH_RISK_AUTHORIZATION_DENIED');
  }
  return Object.freeze({ ...action, status: 'CONFIRMATION_PENDING' as const });
}

export function confirm(action: HighRiskAction, confirmed: boolean): HighRiskAction {
  if (action.status !== 'CONFIRMATION_PENDING') {
    throw new Error('HIGH_RISK_GATE_REJECTED: confirmation is not pending');
  }
  if (!confirmed) {
    throw new Error('HIGH_RISK_CONFIRMATION_DENIED');
  }
  return Object.freeze({ ...action, status: 'AUTHORIZED' as const });
}
