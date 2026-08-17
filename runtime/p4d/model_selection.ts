/**
 * P4D-002 — Automatic multi-model selection policy.
 *
 * Provider-neutral, task-aware routing. Provider/model choice remains an
 * execution dependency and never participates in SH identity or authority.
 */

import type { ModelAdapter, ModelCapability } from './model_abstraction.ts';

export type ModelCostTier = 'ZERO_BUDGET' | 'PAID';
export type ModelTask = 'conversation' | 'reasoning' | 'semantic' | 'image' | 'vision';

export type ModelCandidate = Readonly<{
  id: string;
  capability: ModelCapability;
  cost_tier: ModelCostTier;
  adapter: ModelAdapter;
  tasks?: readonly ModelTask[];
  priority?: number;
}>;

export type ModelSelectionRequest = Readonly<{
  capability: ModelCapability;
  task?: ModelTask;
  require_zero_budget?: boolean;
}>;

export type ModelSelectionResult = Readonly<{
  model_id: string;
  adapter: ModelAdapter;
  cost_tier: ModelCostTier;
}>;

/**
 * Select the best eligible candidate deterministically.
 * Exact task matches rank above general candidates. Within the same rank,
 * lower explicit priority wins. Zero-budget rejects paid-only candidates.
 */
export function selectModel(
  candidates: readonly ModelCandidate[],
  request: ModelSelectionRequest,
): ModelSelectionResult {
  const requireZeroBudget = request.require_zero_budget ?? true;
  const eligible = candidates.filter((item) =>
    item.capability === request.capability &&
    (!requireZeroBudget || item.cost_tier === 'ZERO_BUDGET'),
  );

  const ranked = eligible
    .map((candidate, index) => ({
      candidate,
      index,
      taskRank: request.task && candidate.tasks?.includes(request.task) ? 0 : 1,
      priority: candidate.priority ?? index,
    }))
    .sort((a, b) => a.taskRank - b.taskRank || a.priority - b.priority || a.index - b.index);

  const candidate = ranked[0]?.candidate;
  if (!candidate) {
    throw new Error(
      requireZeroBudget
        ? 'MODEL_SELECTION_FAILED: no zero-budget model available for capability/task'
        : 'MODEL_SELECTION_FAILED: no eligible model available for capability/task',
    );
  }

  return {
    model_id: candidate.id,
    adapter: candidate.adapter,
    cost_tier: candidate.cost_tier,
  };
}
