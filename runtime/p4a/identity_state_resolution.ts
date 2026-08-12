/**
 * BL-P4A-002 — SH Identity & State Resolution
 * Phase 4 — Runtime & Orchestration
 *
 * Minimal realization:
 * - resolve an existing SH identity from authenticated identity input;
 * - never create an SH identity in Runtime;
 * - expose only resolved runtime state needed by the current request;
 * - do not introduce a persistent sessions/state table in v1.0.
 */

export type RuntimeIdentity = {
  account_id: string;
  sh_id: string;
  ownership_role: string;
};

export type RuntimeState = {
  status: 'RESOLVED';
  sh_id: string;
  account_id: string;
};

export interface ExistingIdentityResolver {
  resolve(authUid: string): Promise<RuntimeIdentity | null>;
}

export type ResolvedRuntime = {
  identity: RuntimeIdentity;
  state: RuntimeState;
};

/**
 * Resolves runtime identity/state without creating or mutating identity.
 * State here is request-scoped resolution state, not persistent application state.
 */
export async function resolveRuntimeIdentityAndState(
  resolver: ExistingIdentityResolver,
  authUid: string,
): Promise<ResolvedRuntime> {
  if (!authUid) {
    throw new Error('RUNTIME_REJECTED: authenticated identity is required');
  }

  const identity = await resolver.resolve(authUid);

  if (!identity) {
    throw new Error('RUNTIME_REJECTED: SH identity could not be resolved');
  }

  return {
    identity,
    state: {
      status: 'RESOLVED',
      sh_id: identity.sh_id,
      account_id: identity.account_id,
    },
  };
}
