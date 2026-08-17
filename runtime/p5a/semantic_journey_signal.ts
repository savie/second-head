import type { JourneyCandidate, JourneySignalDetector } from './journey_decision.ts';
import type { SemanticJourneyCandidate, SemanticSignals } from '../p4d/semantic_signals.ts';

/**
 * P4D -> P5A bridge for model-derived Journey candidates.
 *
 * Only structured provider-neutral semantic signals are accepted. Ordinary
 * prose, keywords, and client-supplied text are never interpreted here.
 */
export function createSemanticJourneySignalDetector(): JourneySignalDetector {
  return {
    async detect(input) {
      const signals = extractSemanticSignals(input.response);
      const raw = signals?.journey_candidate;
      if (!raw || typeof raw !== 'object') return {};

      const candidate = raw as SemanticJourneyCandidate;
      if (!candidate.event_type || !candidate.payload || typeof candidate.payload !== 'object') {
        return {};
      }

      const journeyCandidate: JourneyCandidate = {
        event_type: candidate.event_type,
        payload: candidate.payload,
        source_ref: candidate.source_ref ?? 'runtime:p4d:journey_candidate',
        occurred_at: candidate.occurred_at ?? null,
        continuity_status: candidate.continuity_status ?? 'CONTINUOUS',
        gap_code: candidate.gap_code ?? null,
      };

      return { automatic_candidate: journeyCandidate };
    },
  };
}

function extractSemanticSignals(response: unknown): SemanticSignals | undefined {
  if (!response || typeof response !== 'object' || Array.isArray(response)) return undefined;
  const value = response as Record<string, unknown>;

  if (value.semantic_signals && typeof value.semantic_signals === 'object' && !Array.isArray(value.semantic_signals)) {
    return value.semantic_signals as SemanticSignals;
  }

  if (value.journey_candidate && typeof value.journey_candidate === 'object' && !Array.isArray(value.journey_candidate)) {
    return { journey_candidate: value.journey_candidate as SemanticJourneyCandidate };
  }

  return undefined;
}
