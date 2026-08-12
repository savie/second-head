import {
  canTransitionWorkflow,
  createWorkflow,
  transitionWorkflow,
} from './workflow_state_machine';

describe('P4C-001 workflow state machine', () => {
  it('starts explicitly in PLANNED', () => {
    expect(createWorkflow('wf-1', 'sh-1').state).toBe('PLANNED');
  });

  it('allows only defined lifecycle transitions', () => {
    const planned = createWorkflow('wf-1', 'sh-1');
    const running = transitionWorkflow(planned, 'RUNNING');
    const completed = transitionWorkflow(running, 'COMPLETED');

    expect(completed.state).toBe('COMPLETED');
    expect(canTransitionWorkflow('PLANNED', 'COMPLETED')).toBe(false);
    expect(canTransitionWorkflow('COMPLETED', 'RUNNING')).toBe(false);
  });

  it('supports bounded terminal failure/cancellation paths', () => {
    expect(canTransitionWorkflow('RUNNING', 'FAILED')).toBe(true);
    expect(canTransitionWorkflow('RUNNING', 'CANCELLED')).toBe(true);
    expect(canTransitionWorkflow('FAILED', 'RUNNING')).toBe(false);
  });
});
