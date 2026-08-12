/**
 * BL-P4A-001 / BL-P4A-002 / P4B-001 / P4B-003 — Runtime Core Loop + Reasoning Security Boundary
 * Phase 4 — Runtime & Orchestration
 *
 * Minimal realization only.
 *
 * Invariants enforced:
 * - RUNTIME != SH IDENTITY
 * - identity is resolved, never created by runtime
 * - request-scoped runtime state is resolved from the existing identity
 * - context assembly is read-only from the runtime's perspective
 * - reasoning consumes isolated context and has no memory/knowledge mutation capability
 * - external/contextual content cannot gain authority merely by appearing in reasoning input
 * - model provider is an adapter/execution dependency, not SH identity
 * - memory decision is post-response and outside context assembly/reasoning context
 */

import { resolveRuntimeIdentityAndState, type RuntimeIdentity } from './identity_state_resolution.ts';
import type { ReasoningEngine } from '../p4b/reasoning_context.ts';
import { createReasoningSecurityBoundary, type ReasoningSecurityEventSink } from '../p4b/reasoning_security.ts';

export type RuntimeInput = {
  user_message: string;
  auth_uid: string;
};

export type ResolvedIdentity = RuntimeIdentity;

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
  reasoningEngine?: ReasoningEngine;
  reasoningSecurityEvents?: ReasoningSecurityEventSink;
};

export type RuntimeResult = {
  sh_id: string;
  response: unknown;
};

/**
 * Executes the smallest valid SH runtime path:
 * auth.uid -> resolve existing identity/state -> read-only context assembly
 * -> reasoning security boundary -> isolated reasoning -> model execution
 * -> response -> post-response memory decision.
 *
 * `modelAdapter` remains the compatibility/default execution dependency until P4D.
 * When `reasoningEngine` is supplied, it is automatically wrapped by the P4B-003
 * security boundary before it receives contextual data.
 */
export function createRuntimeCoreLoop(deps: RuntimeDependencies) {
  const secureReasoning = deps.reasoningEngine
    ? createReasoningSecurityBoundary(deps.reasoningEngine, deps.reasoningSecurityEvents)
    : undefined;

  return async function run(input: RuntimeInput): Promise<RuntimeResult> {
    if (!input.user_message.trim()) {
      throw new Error('RUNTIME_REJECTED: user_message is required');
    }

    const resolved = await resolveRuntimeIdentityAndState(
      deps.identityResolver,
      input.auth_uid,
    );

    // Runtime state is request-scoped resolution state. It is not persisted here.
    const identity = resolved.identity;

    // Context assembly is deliberately a read-only dependency from runtime.
    const context = await deps.contextAssembler.assemble({
      identity,
      user_message: input.user_message,
    });

    // Reasoning is a separate boundary. It receives isolated context and does not
    // receive memory/knowledge mutation capabilities. P4B-003 additionally
    // prevents contextual/external content from becoming authority.
    const modelResponse = secureReasoning
      ? await secureReasoning.process({ context })
      : await deps.modelAdapter.generate(context);

    // Memory decision is post-response; it is not part of context assembly/reasoning.
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
