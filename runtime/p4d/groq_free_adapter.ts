/** Provider adapter candidate: Groq, behind P4D ModelAdapter. */
import type { ModelAdapter, ModelRequest, ModelResponse } from './model_abstraction.ts';
import type { SemanticSignals } from './semantic_signals.ts';

const ENDPOINT = 'https://api.groq.com/openai/v1/chat/completions';
const MODEL = 'openai/gpt-oss-20b';

const SYSTEM_PROMPT = `You are the semantic model behind Second Head. Return ONLY JSON with response and optional semantic_signals. Candidates are proposals only. Never claim persistence, promotion, sharing, inheritance, cloning, or Core mutation. Never expose private information as shared/general knowledge. Journey candidates are only for significant continuity/lifecycle events, not ordinary transcript messages.`;

export function createGroqAdapter(): ModelAdapter {
  return {
    async generate(request: ModelRequest): Promise<ModelResponse> {
      const key = Deno.env.get('GROQ_API_KEY');
      if (!key) throw new Error('MODEL_CONFIGURATION_ERROR: GROQ_API_KEY is not configured');
      if (request.capability !== 'text') throw new Error('MODEL_REJECTED: Groq adapter currently supports text only');
      const context = request.context as Record<string, unknown>;
      const userMessage = typeof context.user_message === 'string' ? context.user_message : '';
      if (!userMessage.trim()) throw new Error('MODEL_REJECTED: user_message is required');

      const response = await fetch(ENDPOINT, {
        method: 'POST',
        headers: { Authorization: `Bearer ${key}`, 'Content-Type': 'application/json' },
        body: JSON.stringify({
          model: MODEL,
          messages: [{ role: 'system', content: SYSTEM_PROMPT }, { role: 'user', content: userMessage }],
          temperature: 0.2,
          max_tokens: 1200,
          response_format: { type: 'json_object' },
        }),
      });
      const raw = await response.text();
      if (!response.ok) throw new Error(`MODEL_PROVIDER_FAILED: Groq ${response.status}: ${raw.slice(0, 500)}`);
      const envelope = parseEnvelope(raw);
      const output = envelope.response;
      if (typeof output !== 'string') throw new Error('MODEL_PROVIDER_INVALID_OUTPUT: response must be a string');
      const semanticSignals = isSemanticSignalsCandidate(envelope.semantic_signals) ? envelope.semantic_signals : undefined;
      return { output, ...(semanticSignals ? { semantic_signals: semanticSignals } : {}) };
    },
  };
}

function parseEnvelope(raw: string): Record<string, unknown> {
  try {
    const parsed = JSON.parse(raw) as Record<string, unknown>;
    const choices = parsed.choices;
    if (!Array.isArray(choices) || !choices[0] || typeof choices[0] !== 'object') throw new Error('missing choices');
    const message = (choices[0] as Record<string, unknown>).message;
    const content = message && typeof message === 'object' ? (message as Record<string, unknown>).content : undefined;
    if (typeof content !== 'string') throw new Error('missing message content');
    return JSON.parse(content) as Record<string, unknown>;
  } catch (error) {
    const detail = error instanceof Error ? error.message : 'invalid provider response';
    throw new Error(`MODEL_PROVIDER_INVALID_OUTPUT: ${detail}`);
  }
}

function isSemanticSignalsCandidate(value: unknown): value is SemanticSignals {
  if (!value || typeof value !== 'object' || Array.isArray(value)) return false;
  const v = value as Record<string, unknown>;
  return v.journey_candidate !== undefined || v.memory_candidate !== undefined || v.knowledge_candidate !== undefined;
}
