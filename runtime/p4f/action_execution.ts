/**
 * P4F-003 — Action Execution & State Mutation
 * Phase 4 — Runtime & Orchestration
 *
 * Minimal realization:
 * - execution is permitted only after P4F authorization/confirmation;
 * - state mutation is performed through an explicit transactional boundary;
 * - successful mutation commits atomically;
 * - mutation failure rolls back through the same boundary;
 * - identity/ownership fields are preserved and are not mutated by this layer.
 *
 * External side-effect compensation is intentionally outside this slice and
 * belongs to P4F-004.
 */

export type AuthorizedAction = Readonly<{
  action_id: string;
  sh_id: string;
  account_id: string;
  actor_id: string;
  risk: 'LOW' | 'MEDIUM' | 'HIGH';
  status: 'AUTHORIZED';
}>;

export type ActionExecutionResult<T> = Readonly<{
  action_id: string;
  sh_id: string;
  account_id: string;
  actor_id: string;
  status: 'EXECUTED';
  state: T;
}>;

export interface AtomicStateStore<T> {
  begin(): Promise<void>;
  read(): Promise<T>;
  write(nextState: T): Promise<void>;
  commit(): Promise<void>;
  rollback(): Promise<void>;
}

/**
 * Executes an already-authorized action against an explicit atomic state
 * boundary. The action itself cannot alter identity or ownership metadata.
 */
export async function executeAuthorizedAction<T>(
  action: AuthorizedAction,
  store: AtomicStateStore<T>,
  mutate: (currentState: T, action: AuthorizedAction) => T | Promise<T>,
): Promise<ActionExecutionResult<T>> {
  if (!action.action_id.trim()) throw new Error('ACTION_EXECUTION_REJECTED: action id is required');
  if (!action.sh_id.trim()) throw new Error('ACTION_EXECUTION_REJECTED: SH identity is required');
  if (!action.account_id.trim()) throw new Error('ACTION_EXECUTION_REJECTED: account identity is required');
  if (!action.actor_id.trim()) throw new Error('ACTION_EXECUTION_REJECTED: actor identity is required');
  if (action.status !== 'AUTHORIZED') {
    throw new Error('ACTION_EXECUTION_REJECTED: action must be authorized before execution');
  }

  await store.begin();

  try {
    const currentState = await store.read();
    const nextState = await mutate(currentState, action);
    await store.write(nextState);
    await store.commit();

    return Object.freeze({
      action_id: action.action_id,
      sh_id: action.sh_id,
      account_id: action.account_id,
      actor_id: action.actor_id,
      status: 'EXECUTED' as const,
      state: nextState,
    });
  } catch (error) {
    await store.rollback();
    throw error;
  }
}
