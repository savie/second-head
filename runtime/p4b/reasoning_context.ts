/**
 * P4B-001 / P4B-002 — Reasoning Context Boundary + Evidence Logging
 * Phase 4 — Runtime & Orchestration
 *
 * Minimal realization:
 * - reasoning consumes the assembled RuntimeContext;
 * - reasoning has no Memory/Knowledge write dependency;
 * - reasoning does not mutate the supplied context;
 * - model remains an injected execution dependency and is not SH identity;
 * - each reasoning cycle can emit bounded audit evidence without persisting raw context.
 */

import type { SemanticSignals } from '../p4d/semantic_signals.ts';

export type ReasoningContext = Readonly<{
  identity: Readonly<{ sh_id: string }>;
  user_message: string;
  entries: readonly unknown[];
}>;

export type ReasoningRequest = Readonly<{
  context: ReasoningContext;
}>;

export type ReasoningResult = Readonly<{
  output: unknown;
  semantic_signals?: SemanticSignals;
}>;

export type ReasoningEvidence = Readonly<{
  sh_id: string;
  event_type: 'RUNTIME_RESPONSE';
  status: 'SUCCESS' | 'FAILED';
  metadata: Readonly<Record<string, unknown>>;
}>;

export interface ReasoningModelExecutor {
  generate(context: ReasoningContext): Promise<ReasoningResult>;
}

export interface ReasoningEvidenceSink {
  append(event: ReasoningEvidence): Promise<void>;
}

export interface ReasoningEngine {
  process(request: ReasoningRequest): Promise<ReasoningResult>;
}

function cloneEntries(entries: readonly unknown[]): readonly unknown[] {
  return Object.freeze([...entries]);
}

function isolateContext(context: ReasoningContext): ReasoningContext {
  return Object.freeze({
    identity: Object.freeze({ sh_id: context.identity.sh_id }),
    user_message: context.user_message,
    entries: cloneEntries(context.entries),
  });
}

function boundedHash(input: unknown): string {
  const serialized = JSON.stringify(input) ?? 'null';
  let hash = 2166136261;
  for (let index = 0; index < serialized.length; index += 1) {
    hash ^= serialized.charCodeAt(index);
    hash = Math.imul(hash, 16777619);
  }
  return (hash >>> 0).toString(16).padStart(8, '0');
}

/**
 * Reasoning boundary. No memory/knowledge mutation capability is exposed here.
 * Evidence records bounded hashes/metadata rather than raw context or model output.
 */
export function createReasoningEngine(
  model: ReasoningModelExecutor,
  evidence?: ReasoningEvidenceSink,
): ReasoningEngine {
  return {
    async process(request) {
      const isolated = isolateContext(request.context);
      const evidenceBase = {
        sh_id: isolated.identity.sh_id,
        event_type: 'RUNTIME_RESPONSE' as const,
        metadata: {
          stage: 'reasoning',
          evidence_version: 'P4B-002.v1',
          context_hash: boundedHash(isolated),
          context_entry_count: isolated.entries.length,
        },
      };

      await evidence?.append({
        ...evidenceBase,
        status: 'SUCCESS',
        metadata: { ...evidenceBase.metadata, phase: 'MODEL_INPUT' },
      });

      try {
        const result = await model.generate(isolated);
        await evidence?.append({
          ...evidenceBase,
          status: 'SUCCESS',
          metadata: {
            ...evidenceBase.metadata,
            phase: 'MODEL_OUTPUT',
            output_hash: boundedHash(result.output),
          },
        });
        return result;
      } catch (error) {
        await evidence?.append({
          ...evidenceBase,
          status: 'FAILED',
          metadata: {
            ...evidenceBase.metadata,
            phase: 'MODEL_OUTPUT',
            error_type: error instanceof Error ? error.name : 'UNKNOWN_ERROR',
          },
        });
        throw error;
      }
    },
  };
}
