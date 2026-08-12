/**
 * P4D-002 — Model Selection Policy & Zero-Budget Path
 * Phase 4 — Runtime & Orchestration
 *
 * Minimal realization of the accepted v1 policy:
 * - one provider/model path is sufficient for initial execution;
 * - core execution must not require a paid provider;
 * - provider choice remains replaceable through P4D-001's abstraction;
 * - model selection never participates in SH identity resolution or mutation.
 */

import type { ModelAdapter, ModelCapability } from './model_abstraction.ts';

export type ModelCostTier = 'ZERO_BUDGET' | 'PAID';

export type ModelCandidate = Readonly<{
  id: string;
  capability: ModelCapability;
  cost_tier: ModelCostTier;
  adapter: ModelAdapter;
}>;

export type ModelSelectionRequest = Readonly<{
  capability: ModelCapability;
  require_zero_budget?: boolean;
}>;

export type ModelSelectionResult = Readonly<{
  model_id: string;
  adapter: ModelAdapter;
  cost_tier: ModelCostTier;
}>;

/**
 * Selects the first eligible candidate deterministically.
 *
 * The policy intentionally does not hardcode a provider or provider name.
 * A zero-budget request rejects paid-only candidates rather than silently
 * introducing a paid dependency.
 */
export function selectModel(
  candidates: readonly ModelCandidate[],
  request: ModelSelectionRequest,
): ModelSelectionResult {
  const requireZeroBudget = request.require_zero_budget ?? true;

  const candidate = candidates.find((item) =>
    item.capability === request.capability &&
    (!requireZeroBudget || item.cost_tier === 'ZERO_BUDGET'),
  );

  if (!candidate) {
    throw new Error(
      requireZeroBudget
        ? 'MODEL_SELECTION_FAILED: no zero-budget model available for capability'
        : 'MODEL_SELECTION_FAILED: no eligible model available for capability',
    );
  }

  return {
    model_id: candidate.id,
    adapter: candidate.adapter,
    cost_tier: candidate.cost_tier,
  };
}
