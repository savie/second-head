/**
 * P4D provider adapter — OpenRouter free router.
 *
 * This is an implementation candidate behind the provider-neutral ModelAdapter
 * boundary. It must never participate in SH identity or domain authority.
 */

import type { ModelAdapter, ModelRequest, ModelResponse } from './model_abstraction.ts';
import type { SemanticSignals } from './semantic_signals.ts';

const OPENROUTER_ENDPOINT = 'https://openrouter.ai/api/v1/chat/completions';
const OPENROUTER_MODEL = 'openrouter/free';

const SYSTEM_PROMPT = `You are the semantic model behind Second Head.
Return ONLY valid JSON with exactly two top-level fields: response (string) and semantic_signals (object).

Automatic semantic assessment is ACTIVE and REQUIRED. For every user message, assess whether it contains a durable owner-owned preference, fact, standing instruction, project state, or other meaningful information that warrants persistence. When warranted, you MUST emit the appropriate memory_candidate or knowledge_candidate even if the user did not explicitly ask to save it. semantic_signals is the machine-readable proposal consumed by downstream decision/persistence layers.

A durable preference such as "I like black coffee and usually drink it every morning before work" MUST produce a memory_candidate whose content preserves the durable fact. Default applicable memory scope to PRIVATE and visibility to OWNER_ONLY.

Explicit owner teaching should produce a knowledge_candidate with origin EXPLICIT_TEACHING, scope PRIVATE, visibility OWNER_ONLY, and provenance containing the source message.

Do not emit candidates for transient, casual, speculative, or low-signal statements merely because they contain a personal detail. Explicit requests to save, store, remember, learn, update, replace, or otherwise persist information MUST emit the appropriate candidate.

A candidate is only a proposal. Never claim persistence, promotion, sharing, inheritance, cloning, or Core mutation unless the runtime result has actually been supplied.

Journey is for significant events/continuity, not ordinary transcript messages or runtime verification. Only emit journey_candidate when the user's message contains a reasonably clear significant continuity/lifecycle event. Use canonical event types when applicable.

Do not expose private information as shared/general knowledge.`;

const RESPONSE_SCHEMA = {
  type: 'object',
  additionalProperties: false,
  properties: {
    response: { type: 'string' },
    semantic_signals: {
      type: 'object',
      additionalProperties: true,
      properties: {
        memory_candidate: { type: 'object' },
        journey_candidate: { type: 'object' },
        knowledge_candidate: { type: 'object' },
      },
    },
  },
  required: ['response', 'semantic_signals'],
};

export function createOpenRouterFreeAdapter(): ModelAdapter {
  return {
    async generate(request: ModelRequest): Promise<ModelResponse> {
      const apiKey = Deno.env.get('OPENROUTER_API_KEY');
      if (!apiKey) throw new Error('MODEL_CONFIGURATION_ERROR: OPENROUTER_API_KEY is not configured');
      if (request.capability !== 'text') throw new Error('MODEL_REJECTED: OpenRouter free adapter currently supports text only');

      const context = request.context as Record<string, unknown>;
      const userMessage = typeof context.user_message === 'string' ? context.user_message : '';
      if (!userMessage.trim()) throw new Error('MODEL_REJECTED: user_message is required');

      const response = await fetch(OPENROUTER_ENDPOINT, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${apiKey}`,
          'Content-Type': 'application/json',
          'X-Title': 'SECOND HEAD',
        },
        body: JSON.stringify({
          model: OPENROUTER_MODEL,
          messages: [
            { role: 'system', content: SYSTEM_PROMPT },
            { role: 'user', content: userMessage },
          ],
          temperature: 0.2,
          max_tokens: 1200,
          response_format: {
            type: 'json_schema',
            json_schema: {
              name: 'second_head_response',
              strict: false,
              schema: RESPONSE_SCHEMA,
            },
          },
        }),
      });

      const raw = await response.text();
      if (!response.ok) {
        throw new Error(`MODEL_PROVIDER_FAILED: OpenRouter ${response.status}: ${raw.slice(0, 500)}`);
      }

      let envelope: Record<string, unknown>;
      try {
        const parsed = JSON.parse(raw) as Record<string, unknown>;
        const choices = parsed.choices;
        if (!Array.isArray(choices) || !choices[0] || typeof choices[0] !== 'object') {
          throw new Error('missing choices');
        }
        const message = (choices[0] as Record<string, unknown>).message;
        const content = message && typeof message === 'object'
          ? (message as Record<string, unknown>).content
          : undefined;
        if (typeof content !== 'string') throw new Error('missing message content');
        envelope = JSON.parse(content) as Record<string, unknown>;
      } catch (error) {
        const detail = error instanceof Error ? error.message : 'invalid provider response';
        throw new Error(`MODEL_PROVIDER_INVALID_OUTPUT: ${detail}`);
      }

      const output = envelope.response;
      if (typeof output !== 'string') throw new Error('MODEL_PROVIDER_INVALID_OUTPUT: response must be a string');

      const semanticSignals = isSemanticSignalsCandidate(envelope.semantic_signals)
        ? envelope.semantic_signals
        : undefined;

      return {
        output,
        ...(semanticSignals ? { semantic_signals: semanticSignals } : {}),
      };
    },
  };
}

function isSemanticSignalsCandidate(value: unknown): value is SemanticSignals {
  if (!value || typeof value !== 'object' || Array.isArray(value)) return false;
  const signals = value as Record<string, unknown>;

  if (signals.journey_candidate !== undefined && !isJourneyCandidate(signals.journey_candidate)) return false;
  if (signals.memory_candidate !== undefined && !isMemoryCandidate(signals.memory_candidate)) return false;
  if (signals.knowledge_candidate !== undefined && !isKnowledgeCandidate(signals.knowledge_candidate)) return false;

  return signals.journey_candidate !== undefined ||
    signals.memory_candidate !== undefined ||
    signals.knowledge_candidate !== undefined;
}

function isJourneyCandidate(value: unknown): boolean {
  if (!value || typeof value !== 'object' || Array.isArray(value)) return false;
  const candidate = value as Record<string, unknown>;
  const eventTypes = new Set([
    'LIFECYCLE', 'EXPERIENCE', 'MEMORY', 'LEARNING', 'EVOLUTION',
    'MIGRATION', 'RECOVERY', 'CONTINUITY', 'SHARING', 'INHERITANCE', 'LEGACY',
  ]);
  return eventTypes.has(String(candidate.event_type)) &&
    !!candidate.payload && typeof candidate.payload === 'object' && !Array.isArray(candidate.payload);
}

function isMemoryCandidate(value: unknown): boolean {
  if (!value || typeof value !== 'object' || Array.isArray(value)) return false;
  const candidate = value as Record<string, unknown>;
  return typeof candidate.content === 'string' && candidate.content.trim().length > 0;
}

function isKnowledgeCandidate(value: unknown): boolean {
  if (!value || typeof value !== 'object' || Array.isArray(value)) return false;
  const candidate = value as Record<string, unknown>;
  return typeof candidate.content === 'string' &&
    candidate.content.trim().length > 0 &&
    typeof candidate.source === 'string' &&
    typeof candidate.origin === 'string';
}
