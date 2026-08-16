/**
 * P4D runtime model registry.
 *
 * Provider-neutral composition boundary: the registry owns no provider SDKs,
 * selection policy, fallback policy, identity, or domain persistence.
 */

import type { ModelAdapter } from './model_abstraction.ts';
import type { ModelCandidate } from './model_selection.ts';

export type ModelRegistry = Readonly<{
  candidates(): readonly ModelCandidate[];
}>;

export function createModelRegistry(
  candidates: readonly ModelCandidate[],
): ModelRegistry {
  const seen = new Set<string>();
  const normalized = candidates.map((candidate) => {
    if (!candidate.id.trim()) {
      throw new Error('MODEL_REGISTRY_REJECTED: candidate id is required');
    }
    if (seen.has(candidate.id)) {
      throw new Error(`MODEL_REGISTRY_REJECTED: duplicate candidate id: ${candidate.id}`);
    }
    seen.add(candidate.id);

    if (!candidate.adapter || typeof candidate.adapter.generate !== 'function') {
      throw new Error(`MODEL_REGISTRY_REJECTED: invalid adapter: ${candidate.id}`);
    }

    return Object.freeze({ ...candidate });
  });

  return Object.freeze({
    candidates: () => normalized,
  });
}

export type ModelCandidateFactory = (adapter: ModelAdapter) => ModelCandidate;
