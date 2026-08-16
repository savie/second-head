/**
 * P4D — Provider-neutral semantic candidate formation.
 *
 * This layer does not infer Memory/Knowledge from ordinary prose. It only
 * accepts an explicit semantic_signals envelope emitted by a model adapter
 * (or encoded as JSON model output), then validates and returns the existing
 * provider-neutral proposal contract.
 *
 * Domain policy, ownership, validation, trust, persistence and Journey remain
 * downstream responsibilities.
 */

import {
  isSemanticSignals,
  type SemanticSignals,
} from './semantic_signals.ts';

export function formSemanticSignalsFromModelOutput(output: unknown): SemanticSignals | undefined {
  const candidate = parseExplicitEnvelope(output);
  if (candidate === undefined) return undefined;
  return isSemanticSignals(candidate) ? candidate : undefined;
}

function parseExplicitEnvelope(output: unknown): unknown {
  if (!output || typeof output !== 'object' || Array.isArray(output)) {
    if (typeof output !== 'string' || !output.trim()) return undefined;
    try {
      return parseExplicitEnvelope(JSON.parse(output));
    } catch {
      return undefined;
    }
  }

  const value = output as Record<string, unknown>;
  if (!Object.prototype.hasOwnProperty.call(value, 'semantic_signals')) return undefined;
  return value.semantic_signals;
}
