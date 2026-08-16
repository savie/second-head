/**
 * P3D — Minimal Acquisition -> Validation runtime boundary.
 *
 * This module does not classify, trust, persist, share, or mutate Core.
 * It only converts an eligible semantic acquisition signal into one of the
 * contract-defined validation outcomes.
 */

import type { SemanticKnowledgeCandidate } from '../p4d/semantic_signals.ts';

export type KnowledgeValidationOutcome = 'VALID' | 'INVALID' | 'NEEDS_REVIEW';

export type KnowledgeValidationResult = {
  outcome: KnowledgeValidationOutcome;
  reason: string;
  candidate: SemanticKnowledgeCandidate;
};

export function validateKnowledgeCandidate(
  candidate: SemanticKnowledgeCandidate,
): KnowledgeValidationResult {
  if (!candidate.content.trim()) {
    return { outcome: 'INVALID', reason: 'CONTENT_REQUIRED', candidate };
  }

  if (!candidate.source.trim()) {
    return { outcome: 'INVALID', reason: 'SOURCE_REQUIRED', candidate };
  }

  if (!candidate.origin) {
    return { outcome: 'INVALID', reason: 'ORIGIN_REQUIRED', candidate };
  }

  if (candidate.scope === 'GENERAL' && candidate.visibility !== 'SHARED') {
    return { outcome: 'NEEDS_REVIEW', reason: 'GENERAL_SCOPE_REQUIRES_EXPLICIT_SHARED_VISIBILITY', candidate };
  }

  if (candidate.confidence !== undefined && candidate.confidence !== null) {
    if (!Number.isFinite(candidate.confidence) || candidate.confidence < 0 || candidate.confidence > 1) {
      return { outcome: 'INVALID', reason: 'CONFIDENCE_OUT_OF_RANGE', candidate };
    }
  }

  if (candidate.origin === 'EXTERNAL_REFERENCE' && !candidate.source.trim()) {
    return { outcome: 'INVALID', reason: 'EXTERNAL_REFERENCE_SOURCE_REQUIRED', candidate };
  }

  return { outcome: 'VALID', reason: 'MINIMUM_VALIDATION_PASSED', candidate };
}
