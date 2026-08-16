/**
 * BL-P4A-001 / BL-P4A-002 / P4B-001 / P4B-003 — Runtime Core Loop + Reasoning Security Boundary
 * Phase 4 — Runtime & Orchestration
 *
 * Minimal realization plus the P5A Journey post-response boundary.
 */

import { resolveRuntimeIdentityAndState, type RuntimeIdentity } from './identity_state_resolution.ts';
import type { ReasoningEngine } from '../p4b/reasoning_context.ts';
import { createReasoningSecurityBoundary, type ReasoningSecurityEventSink } from '../p4b/reasoning_security.ts';
import { createModelExecutor, type ModelAdapter } from '../p4d/model_abstraction.ts';
import type { SemanticKnowledgeCandidate } from '../p4d/semantic_signals.ts';
import { validateKnowledgeCandidate, type KnowledgeValidationResult } from '../p3d/knowledge_acquisition_validation.ts';
import type { JourneyRuntimeDecisionSink } from '../p5a/journey_decision.ts';

export type RuntimeInput = { user_message: string; auth_uid: string };
export type ResolvedIdentity = RuntimeIdentity;
export type RuntimeContext = { identity: ResolvedIdentity; user_message: string; entries: readonly unknown[] };
export interface IdentityResolver { resolve(authUid: string): Promise<ResolvedIdentity | null>; }
export interface ContextAssembler { assemble(input: { identity: ResolvedIdentity; user_message: string }): Promise<RuntimeContext>; }
export interface MemoryDecisionSink { decide(input: { identity: ResolvedIdentity; user_message: string; response: unknown }): Promise<void>; }

/** P3D acquisition handoff. Persistence/trust/sharing/Core remain outside this sink. */
export interface KnowledgeAcquisitionSink {
  acquire(input: {
    identity: ResolvedIdentity;
    user_message: string;
    candidate: SemanticKnowledgeCandidate;
    validation: KnowledgeValidationResult;
  }): Promise<void>;
}

export type RuntimeDependencies = {
  identityResolver: IdentityResolver;
  contextAssembler: ContextAssembler;
  modelAdapter: ModelAdapter;
  memoryDecision: MemoryDecisionSink;
  journeyDecision: JourneyRuntimeDecisionSink;
  knowledgeAcquisition?: KnowledgeAcquisitionSink;
  reasoningEngine?: ReasoningEngine;
  reasoningSecurityEvents?: ReasoningSecurityEventSink;
};
export type RuntimeResult = { sh_id: string; response: unknown };

export function createRuntimeCoreLoop(deps: RuntimeDependencies) {
  const secureReasoning = deps.reasoningEngine
    ? createReasoningSecurityBoundary(deps.reasoningEngine, deps.reasoningSecurityEvents)
    : undefined;
  const model = createModelExecutor(deps.modelAdapter);

  return async function run(input: RuntimeInput): Promise<RuntimeResult> {
    if (!input.user_message.trim()) throw new Error('RUNTIME_REJECTED: user_message is required');

    const resolved = await resolveRuntimeIdentityAndState(deps.identityResolver, input.auth_uid);
    const identity = resolved.identity;
    const context = await deps.contextAssembler.assemble({ identity, user_message: input.user_message });

    const modelResponse = secureReasoning
      ? await secureReasoning.process({ context })
      : await model.execute({ capability: 'text', context });

    await deps.journeyDecision.decideAndRecord({
      sh_id: identity.sh_id,
      user_message: input.user_message,
      response: modelResponse.output,
    });

    await deps.memoryDecision.decide({
      identity,
      user_message: input.user_message,
      response: modelResponse,
    });

    const knowledgeCandidate = modelResponse.semantic_signals?.knowledge_candidate;
    if (knowledgeCandidate && deps.knowledgeAcquisition) {
      const validation = validateKnowledgeCandidate(knowledgeCandidate);
      if (validation.outcome === 'VALID') {
        await deps.knowledgeAcquisition.acquire({
          identity,
          user_message: input.user_message,
          candidate: knowledgeCandidate,
          validation,
        });
      }
    }

    return { sh_id: identity.sh_id, response: modelResponse.output };
  };
}
