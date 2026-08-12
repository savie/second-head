/**
 * BL-P4A-001 / BL-P4A-002 / P4B-001 — Runtime Core Loop + SH Identity & Reasoning Context Boundary
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
 * - model provider is an adapter/execution dependency, not SH identity
 * - memory decision is post-response and outside context assembly/reasoning context
 */

import { resolveRuntimeIdentityAndState, type RuntimeIdentity } from './identity_state_resolution.ts';
import type { ReasoningEngine } from '../p4b/reasoning_context.ts';

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
};

export type RuntimeResult = {
  sh_id: string;
  response: unknown;
};

/**
 * Executes the smallest valid SH runtime path:
 * auth.uid -> resolve existing identity/state -> read-only context assembly
 * -> reasoning boundary -> model execution -> response -> post-response memory decision.
 *
 * `modelAdapter` remains the compatibility/default execution dependency until P4D.
 * When `reasoningEngine` is supplied, the model call is routed through P4B's
 * isolated reasoning-context boundary.
 */
export function createRuntimeCoreLoop(deps: RuntimeDependencies) {
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
    // receive memory/knowledge mutation capabilities.
    const modelResponse = deps.reasoningEngine
      ? await deps.reasoningEngine.process({ context })
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
