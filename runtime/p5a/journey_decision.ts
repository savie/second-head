/**
 * P5A — Journey Decision Boundary
 *
 * Converts already-derived Journey signals into the canonical Journey recorder
 * input. Semantic significance detection remains an injected dependency so
 * Journey is not coupled to a model/provider or to brittle keyword matching.
 */

export type JourneyEventType =
  | 'LIFECYCLE'
  | 'EXPERIENCE'
  | 'MEMORY'
  | 'LEARNING'
  | 'EVOLUTION'
  | 'MIGRATION'
  | 'RECOVERY'
  | 'CONTINUITY'
  | 'SHARING'
  | 'INHERITANCE'
  | 'LEGACY';

export type JourneyContinuityStatus =
  | 'CONTINUOUS'
  | 'GAP_DETECTED'
  | 'GAP_UNRESOLVED'
  | 'RECOVERED';

export type JourneyCandidate = {
  event_type: JourneyEventType;
  payload: Record<string, unknown>;
  source_ref?: string | null;
  occurred_at?: string | null;
  continuity_status?: JourneyContinuityStatus;
  gap_code?: string | null;
};

export type ExplicitJourneyIntent = {
  requested: boolean;
  candidate?: JourneyCandidate;
};

export type JourneyDecisionInput = {
  sh_id: string;
  user_message: string;
  response: unknown;
  automatic_candidate?: JourneyCandidate | null;
  explicit_intent?: ExplicitJourneyIntent | null;
};

export type JourneyDecision = {
  record: boolean;
  candidate?: JourneyCandidate;
  reason: 'NONE' | 'EXPLICIT' | 'AUTOMATIC';
};

export interface JourneyEventRecorder {
  record(input: {
    sh_id: string;
    event_type: JourneyEventType;
    occurred_at?: string | null;
    continuity_status?: JourneyContinuityStatus;
    gap_code?: string | null;
    payload: Record<string, unknown>;
    source_ref?: string | null;
  }): Promise<string>;
}

/** Semantic/runtime machinery supplies candidates; Journey does not invent them. */
export interface JourneySignalDetector {
  detect(input: {
    sh_id: string;
    user_message: string;
    response: unknown;
  }): Promise<{
    automatic_candidate?: JourneyCandidate | null;
    explicit_intent?: ExplicitJourneyIntent | null;
  }>;
}

export interface JourneyRuntimeDecisionSink {
  decideAndRecord(input: {
    sh_id: string;
    user_message: string;
    response: unknown;
  }): Promise<JourneyDecision>;
}

/**
 * Explicit intent wins over an automatic candidate when both are present.
 * An explicit request without a concrete candidate is intentionally rejected
 * at this boundary instead of inventing an event type or payload.
 */
export function decideJourney(input: JourneyDecisionInput): JourneyDecision {
  if (input.explicit_intent?.requested) {
    if (!input.explicit_intent.candidate) {
      return { record: false, reason: 'NONE' };
    }
    return {
      record: true,
      reason: 'EXPLICIT',
      candidate: input.explicit_intent.candidate,
    };
  }

  if (input.automatic_candidate) {
    return {
      record: true,
      reason: 'AUTOMATIC',
      candidate: input.automatic_candidate,
    };
  }

  return { record: false, reason: 'NONE' };
}

export function createJourneyRuntimeDecisionSink(
  detector: JourneySignalDetector,
  recorder: JourneyEventRecorder,
): JourneyRuntimeDecisionSink {
  return {
    async decideAndRecord(input) {
      const signals = await detector.detect(input);
      const decision = decideJourney({ ...input, ...signals });

      if (!decision.record || !decision.candidate) return decision;

      await recorder.record({
        sh_id: input.sh_id,
        event_type: decision.candidate.event_type,
        occurred_at: decision.candidate.occurred_at,
        continuity_status: decision.candidate.continuity_status,
        gap_code: decision.candidate.gap_code,
        payload: decision.candidate.payload,
        source_ref: decision.candidate.source_ref,
      });

      return decision;
    },
  };
}
