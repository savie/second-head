/**
 * P4D-003 — Model Fallback & Error Handling
 * Phase 4 — Runtime & Orchestration
 *
 * Minimal realization of fallback behavior:
 * - primary model is attempted first;
 * - an eligible secondary model may be attempted when primary execution fails;
 * - zero-budget policy is preserved by default;
 * - if all eligible candidates fail, return a structured model error;
 * - no SH identity input or mutation exists in this boundary.
 */

import type {
  ModelAdapter,
  ModelCapability,
  ModelResponse,
} from './model_abstraction.ts';
import type { ModelCostTier } from './model_selection.ts';

export type FallbackModelCandidate = Readonly<{
  id: string;
  capability: ModelCapability;
  cost_tier: ModelCostTier;
  adapter: ModelAdapter;
}>;

export type ModelFallbackRequest = Readonly<{
  capability: ModelCapability;
  context: unknown;
  require_zero_budget?: boolean;
}>;

export type ModelFallbackSuccess = Readonly<{
  ok: true;
  model_id: string;
  response: ModelResponse;
  fallback_used: boolean;
  attempted_model_ids: readonly string[];
}>;

export type ModelFallbackFailure = Readonly<{
  ok: false;
  error: {
    code: 'MODEL_EXECUTION_FAILED';
    message: string;
    attempted_model_ids: readonly string[];
  };
}>;

export type ModelFallbackResult = ModelFallbackSuccess | ModelFallbackFailure;

/**
 * Executes eligible candidates in deterministic order.
 * The first candidate is the primary; subsequent candidates are fallbacks.
 */
export async function executeWithFallback(
  candidates: readonly FallbackModelCandidate[],
  request: ModelFallbackRequest,
): Promise<ModelFallbackResult> {
  const requireZeroBudget = request.require_zero_budget ?? true;
  const attemptedModelIds: string[] = [];

  const eligible = candidates.filter((candidate) =>
    candidate.capability === request.capability &&
    (!requireZeroBudget || candidate.cost_tier === 'ZERO_BUDGET')
  );

  for (const candidate of eligible) {
    attemptedModelIds.push(candidate.id);

    try {
      const response = await candidate.adapter.generate({
        capability: request.capability,
        context: request.context,
      });

      return {
        ok: true,
        model_id: candidate.id,
        response,
        fallback_used: attemptedModelIds.length > 1,
        attempted_model_ids: attemptedModelIds,
      };
    } catch {
      // Continue to the next eligible candidate. Provider failures must not
      // become SH identity or runtime-state mutations.
    }
  }

  return {
    ok: false,
    error: {
      code: 'MODEL_EXECUTION_FAILED',
      message: eligible.length === 0
        ? 'No eligible model available for capability'
        : 'All eligible model candidates failed',
      attempted_model_ids: attemptedModelIds,
    },
  };
}
