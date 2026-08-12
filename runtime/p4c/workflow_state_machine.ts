/**
 * BL-P4C-001 — Workflow State Machine & Definition
 * Phase 4 — Runtime & Orchestration
 *
 * Minimal realization:
 * - explicit workflow lifecycle;
 * - no implicit state;
 * - no persistence technology selected;
 * - bounded, deterministic transitions only.
 */

export type WorkflowState =
  | 'PLANNED'
  | 'RUNNING'
  | 'COMPLETED'
  | 'FAILED'
  | 'CANCELLED';

export type Workflow = {
  workflow_id: string;
  sh_id: string;
  state: WorkflowState;
};

const transitions: Record<WorkflowState, readonly WorkflowState[]> = {
  PLANNED: ['RUNNING', 'CANCELLED'],
  RUNNING: ['COMPLETED', 'FAILED', 'CANCELLED'],
  COMPLETED: [],
  FAILED: [],
  CANCELLED: [],
};

export function createWorkflow(workflow_id: string, sh_id: string): Workflow {
  if (!workflow_id || !sh_id) throw new Error('WORKFLOW_REJECTED: workflow_id and sh_id are required');
  return { workflow_id, sh_id, state: 'PLANNED' };
}

export function transitionWorkflow(
  workflow: Workflow,
  next: WorkflowState,
): Workflow {
  if (!transitions[workflow.state].includes(next)) {
    throw new Error(`WORKFLOW_INVALID_TRANSITION: ${workflow.state} -> ${next}`);
  }
  return { ...workflow, state: next };
}

export function canTransitionWorkflow(
  state: WorkflowState,
  next: WorkflowState,
): boolean {
  return transitions[state].includes(next);
}
