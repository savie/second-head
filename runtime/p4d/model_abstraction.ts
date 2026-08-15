/**
 * P4D-001 — Model Abstraction Layer
 * Phase 4 — Runtime & Orchestration
 *
 * Provider-independent model boundary.
 *
 * Invariants:
 * - MODEL != SH IDENTITY
 * - model/provider selection is an execution dependency, not identity
 * - runtime depends on a capability-oriented interface, not a provider SDK
 * - provider replacement must not require identity mutation
 */

import type { SemanticSignals } from './semantic_signals.ts';

export type ModelCapability = 'text' | 'vision' | 'image';

export type ModelRequest = {
  capability: ModelCapability;
  context: unknown;
};

export type ModelResponse = {
  output: unknown;
  /** Optional provider-neutral semantic proposals for downstream domain decisions. */
  semantic_signals?: SemanticSignals;
};

/**
 * Stable boundary consumed by Runtime/Reasoning.
 * Provider-specific SDKs must stay behind this interface.
 */
export interface ModelAdapter {
  generate(request: ModelRequest): Promise<ModelResponse>;
}

/**
 * Runtime-facing model abstraction.
 * The selected adapter is intentionally opaque to SH identity.
 */
export interface ModelExecutor {
  execute(request: ModelRequest): Promise<ModelResponse>;
}

export function createModelExecutor(adapter: ModelAdapter): ModelExecutor {
  return {
    async execute(request) {
      if (!request.context) {
        throw new Error('MODEL_REJECTED: context is required');
      }

      if (!['text', 'vision', 'image'].includes(request.capability)) {
        throw new Error('MODEL_REJECTED: unsupported capability');
      }

      return adapter.generate(request);
    },
  };
}
