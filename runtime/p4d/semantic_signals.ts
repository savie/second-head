/**
 * P4D — Provider-neutral semantic output contract.
 *
 * The model may propose domain candidates through this envelope. Domain
 * decision, validation, trust, persistence, ownership, privacy, and Journey
 * recording remain outside P4D.
 */

export type SemanticSignalOrigin =
  | 'MEMORY'
  | 'EXPLICIT_TEACHING'
  | 'EXTERNAL_REFERENCE';

export type SemanticMemoryCandidate = {
  content: string;
  memory_type?: 'SHORT_TERM' | 'LONG_TERM';
  source?: string;
  confidence?: number | null;
  scope?: 'PRIVATE' | 'GENERAL';
  visibility?: 'OWNER_ONLY' | 'SHARED';
  lifecycle?: 'CANDIDATE' | 'ACTIVE';
};

/**
 * Journey is a significant-event representation, not a transcript.
 * A model may propose a structured Journey candidate, but the Journey
 * decision/recorder boundary remains responsible for deciding and persisting it.
 */
export type SemanticJourneyCandidate = {
  event_type:
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
  payload: Record<string, unknown>;
  source_ref?: string | null;
  occurred_at?: string | null;
  continuity_status?: 'CONTINUOUS' | 'GAP_DETECTED' | 'GAP_UNRESOLVED' | 'RECOVERED';
  gap_code?: string | null;
};

/**
 * Knowledge is intentionally an acquisition signal, not a final Knowledge
 * classification. P3D Acquisition/Validation/Classification remains the
 * authority for downstream Knowledge state.
 */
export type SemanticKnowledgeCandidate = {
  content: string;
  source: string;
  provenance?: unknown;
  scope?: 'PRIVATE' | 'GENERAL';
  visibility?: 'OWNER_ONLY' | 'SHARED';
  confidence?: number | null;
  origin: SemanticSignalOrigin;
};

export type SemanticSignals = {
  memory_candidate?: SemanticMemoryCandidate;
  journey_candidate?: SemanticJourneyCandidate;
  knowledge_candidate?: SemanticKnowledgeCandidate;
};

export function isSemanticSignals(value: unknown): value is SemanticSignals {
  if (!value || typeof value !== 'object' || Array.isArray(value)) return false;
  const signals = value as Record<string, unknown>;
  if (signals.memory_candidate !== undefined &&
      (!signals.memory_candidate || typeof signals.memory_candidate !== 'object' || Array.isArray(signals.memory_candidate))) {
    return false;
  }
  if (signals.journey_candidate !== undefined &&
      (!signals.journey_candidate || typeof signals.journey_candidate !== 'object' || Array.isArray(signals.journey_candidate))) {
    return false;
  }
  if (signals.knowledge_candidate !== undefined &&
      (!signals.knowledge_candidate || typeof signals.knowledge_candidate !== 'object' || Array.isArray(signals.knowledge_candidate))) {
    return false;
  }
  return true;
}
