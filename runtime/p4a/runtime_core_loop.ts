/**
 * BL-P4A-001 — Runtime Core Loop Skeleton
 * Phase 4 — Runtime & Orchestration
 *
 * Minimal realization only.
 *
 * Invariants enforced by this skeleton:
 * - RUNTIME != SH IDENTITY
 * - identity is resolved, never created by runtime
 * - context assembly is read-only from the runtime's perspective
 * - model provider is an adapter, not SH identity
 * - memory decision is post-response and outside context assembly
 *
 * This module intentionally contains no provider SDK, database writes, tool
 * execution, action execution, or autonomous loop. Those belong to later
 * Phase 4 work or existing bounded services.
 */

export type RuntimeInput = {
  user_message: string;
  auth_uid: string;
};

export type ResolvedIdentity = {
  account_id: string;
  sh_id: string;
  ownership_role: string;
};

export type RuntimeContext = {
  identity: ResolvedIdentity;
  user_message: string;
  entries: readonly unknown[];
};

export type ModelResponse = {
  output: unknown;
};

export interface IdentityResolver {
  resolve(authUid: string): Promise<ResolvedIdentity | null>;
}

export interface ContextAssembler {
  assemble(input: {
    identity: ResolvedIdentity;
    user_message: string;
  }): Promise<RuntimeContext>;
}

export interface ModelAdapter {
  generate(context: RuntimeContext): Promise<ModelResponse>;
}

export interface MemoryDecisionSink {
  decide(input: {
    identity: ResolvedIdentity;
    user_message: string;
    response: unknown;
  }): Promise<void>;
}

export type RuntimeDependencies = {
  identityResolver: IdentityResolver;
  contextAssembler: ContextAssembler;
  modelAdapter: ModelAdapter;
  memoryDecision: MemoryDecisionSink;
};

export type RuntimeResult = {
  sh_id: string;
  response: unknown;
};

/**
 * Executes the smallest valid SH runtime path:
 *
 * auth.uid -> resolve existing identity -> read-only context assembly
 * -> model adapter -> response -> post-response memory decision.
 */
export function createRuntimeCoreLoop(deps: RuntimeDependencies) {
  return async function run(input: RuntimeInput): Promise<RuntimeResult> {
    if (!input.auth_uid) {
      throw new Error('RUNTIME_REJECTED: authenticated identity is required');
    }

    if (!input.user_message.trim()) {
      throw new Error('RUNTIME_REJECTED: user_message is required');
    }

    const identity = await deps.identityResolver.resolve(input.auth_uid);

    if (!identity) {
      throw new Error('RUNTIME_REJECTED: SH identity could not be resolved');
    }

    // Context assembly is deliberately a read-only dependency from runtime.
    const context = await deps.contextAssembler.assemble({
      identity,
      user_message: input.user_message,
    });

    // The model is replaceable infrastructure. It does not own SH identity.
    const modelResponse = await deps.modelAdapter.generate(context);

    // Memory decision is post-response; it is not part of context assembly.
    // The runtime does not itself decide what becomes memory.
    await deps.memoryDecision.decide({
      identity,
      user_message: input.user_message,
      response: modelResponse.output,
    });

    return {
      sh_id: identity.sh_id,
      response: modelResponse.output,
    };
  };
}
