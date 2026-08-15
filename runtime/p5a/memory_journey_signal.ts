import type { JourneyCandidate, JourneySignalDetector } from './journey_decision.ts';

/**
 * P3B/P4A -> P5A bridge.
 * A memory candidate already derived by the post-response memory decision
 * boundary is also a semantic signal for the Journey layer.
 *
 * This detector never infers memory from keywords or ordinary prose. It only
 * adapts the explicit structured `memory_candidate` signal already present in
 * the runtime response. Identity is supplied by the runtime caller.
 */
export function createMemoryJourneySignalDetector(): JourneySignalDetector {
  return {
    async detect(input) {
      if (!input.response || typeof input.response !== 'object' || Array.isArray(input.response)) {
        return {};
      }

      const raw = (input.response as Record<string, unknown>).memory_candidate;
      if (!raw || typeof raw !== 'object' || Array.isArray(raw)) return {};

      const candidate = raw as Record<string, unknown>;
      if (typeof candidate.content !== 'string' || !candidate.content.trim()) return {};

      const journeyCandidate: JourneyCandidate = {
        event_type: 'MEMORY',
        payload: {
          memory_content: candidate.content.trim(),
          memory_type: candidate.memory_type ?? 'LONG_TERM',
          lifecycle: candidate.lifecycle ?? 'CANDIDATE',
          scope: candidate.scope ?? 'PRIVATE',
          visibility: candidate.visibility ?? 'OWNER_ONLY',
        },
        source_ref: 'runtime:p4a:memory_candidate',
      };

      return { automatic_candidate: journeyCandidate };
    },
  };
}
