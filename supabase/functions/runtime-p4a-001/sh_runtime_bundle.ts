type Capability = 'text' | 'vision' | 'image';
type Task = 'conversation' | 'reasoning' | 'semantic' | 'image' | 'vision';
type CostTier = 'ZERO_BUDGET' | 'PAID';
type Signals = { memory_candidate?: Record<string, unknown>; journey_candidate?: Record<string, unknown>; knowledge_candidate?: Record<string, unknown> };
type Response = { output: unknown; semantic_signals?: Signals };
type Adapter = { generate(request: { capability: Capability; context: unknown }): Promise<Response> };
type Candidate = { id: string; capability: Capability; cost_tier: CostTier; adapter: Adapter; tasks?: readonly Task[]; priority?: number };

const SYSTEM_PROMPT = `You are the semantic model behind Second Head. Return ONLY valid JSON with exactly a string field response and a semantic_signals object. semantic_signals may contain memory_candidate, journey_candidate, and knowledge_candidate; when a candidate is not warranted, omit that candidate. Candidates are proposals only and are not persisted or promoted by you. Never claim persistence, promotion, sharing, inheritance, cloning, or Core mutation. Never expose private information as shared/general knowledge. Journey is for significant continuity/lifecycle events, not ordinary transcript messages. IMPORTANT: when the user's message itself expresses or records a significant continuity/lifecycle event, decision, commitment, transition, milestone, state change, or other information that should become part of the SH's continuity, you MUST emit semantic_signals.journey_candidate as a structured object with event_type and payload, even if your natural-language response also explains why it is significant. Do not merely say that something should be a Journey candidate; actually emit the candidate object. For a Journey candidate, event_type must be a concise event type and payload must contain the relevant continuity facts without inventing facts not present in the input. If the message is ordinary conversation with no significant continuity/lifecycle signal, do not emit journey_candidate.`;

function parseProviderEnvelope(raw: string): Record<string, unknown> {
  try {
    const parsed = JSON.parse(raw) as Record<string, unknown>;
    const choices = parsed.choices;
    if (!Array.isArray(choices) || !choices[0] || typeof choices[0] !== 'object') throw new Error('missing choices');
    const message = (choices[0] as Record<string, unknown>).message;
    const content = message && typeof message === 'object' ? (message as Record<string, unknown>).content : undefined;
    if (typeof content !== 'string') throw new Error('missing message content');
    return JSON.parse(content) as Record<string, unknown>;
  } catch (error) {
    throw new Error(`MODEL_PROVIDER_INVALID_OUTPUT: ${error instanceof Error ? error.message : 'invalid provider response'}`);
  }
}

function signals(value: unknown): Signals | undefined {
  if (!value || typeof value !== 'object' || Array.isArray(value)) return undefined;
  const v = value as Record<string, unknown>;
  if (v.journey_candidate === undefined && v.memory_candidate === undefined && v.knowledge_candidate === undefined) return undefined;
  return v as Signals;
}

function openRouter(): Adapter { return { async generate(request) {
  const key = Deno.env.get('OPENROUTER_API_KEY');
  if (!key) throw new Error('MODEL_CONFIGURATION_ERROR: OPENROUTER_API_KEY is not configured');
  if (request.capability !== 'text') throw new Error('MODEL_REJECTED: OpenRouter free adapter currently supports text only');
  const context = request.context as Record<string, unknown>;
  const userMessage = typeof context.user_message === 'string' ? context.user_message : '';
  if (!userMessage.trim()) throw new Error('MODEL_REJECTED: user_message is required');
  const response = await fetch('https://openrouter.ai/api/v1/chat/completions', { method: 'POST', headers: { Authorization: `Bearer ${key}`, 'Content-Type': 'application/json', 'X-Title': 'SECOND HEAD' }, body: JSON.stringify({ model: 'openrouter/free', messages: [{ role: 'system', content: SYSTEM_PROMPT }, { role: 'user', content: userMessage }], temperature: 0.2, max_tokens: 1200, response_format: { type: 'json_object' } }) });
  const raw = await response.text();
  if (!response.ok) throw new Error(`MODEL_PROVIDER_FAILED: OpenRouter ${response.status}: ${raw.slice(0, 500)}`);
  const envelope = parseProviderEnvelope(raw);
  if (typeof envelope.response !== 'string') throw new Error('MODEL_PROVIDER_INVALID_OUTPUT: response must be a string');
  return { output: envelope.response, ...(signals(envelope.semantic_signals) ? { semantic_signals: signals(envelope.semantic_signals) } : {}) };
} }; }

function groq(): Adapter { return { async generate(request) {
  const key = Deno.env.get('GROQ_API_KEY');
  if (!key) throw new Error('MODEL_CONFIGURATION_ERROR: GROQ_API_KEY is not configured');
  if (request.capability !== 'text') throw new Error('MODEL_REJECTED: Groq adapter currently supports text only');
  const context = request.context as Record<string, unknown>;
  const userMessage = typeof context.user_message === 'string' ? context.user_message : '';
  const response = await fetch('https://api.groq.com/openai/v1/chat/completions', { method: 'POST', headers: { Authorization: `Bearer ${key}`, 'Content-Type': 'application/json' }, body: JSON.stringify({ model: 'openai/gpt-oss-20b', messages: [{ role: 'system', content: SYSTEM_PROMPT }, { role: 'user', content: userMessage }], temperature: 0.2, max_tokens: 1200, response_format: { type: 'json_object' } }) });
  const raw = await response.text();
  if (!response.ok) throw new Error(`MODEL_PROVIDER_FAILED: Groq ${response.status}: ${raw.slice(0, 500)}`);
  const envelope = parseProviderEnvelope(raw);
  if (typeof envelope.response !== 'string') throw new Error('MODEL_PROVIDER_INVALID_OUTPUT: response must be a string');
  return { output: envelope.response, ...(signals(envelope.semantic_signals) ? { semantic_signals: signals(envelope.semantic_signals) } : {}) };
} }; }

function huggingFace(): Adapter { return { async generate(request) {
  const key = Deno.env.get('HUGGINGFACE_API_KEY');
  if (!key) throw new Error('MODEL_CONFIGURATION_ERROR: HUGGINGFACE_API_KEY is not configured');
  if (request.capability !== 'text') throw new Error('MODEL_REJECTED: Hugging Face adapter currently supports text only');
  const context = request.context as Record<string, unknown>;
  const userMessage = typeof context.user_message === 'string' ? context.user_message : '';
  const response = await fetch('https://router.huggingface.co/v1/chat/completions', { method: 'POST', headers: { Authorization: `Bearer ${key}`, 'Content-Type': 'application/json' }, body: JSON.stringify({ model: 'openai/gpt-oss-20b:groq', messages: [{ role: 'system', content: SYSTEM_PROMPT }, { role: 'user', content: userMessage }], temperature: 0.2, max_tokens: 1200, response_format: { type: 'json_object' } }) });
  const raw = await response.text();
  if (!response.ok) throw new Error(`MODEL_PROVIDER_FAILED: Hugging Face ${response.status}: ${raw.slice(0, 500)}`);
  const envelope = parseProviderEnvelope(raw);
  if (typeof envelope.response !== 'string') throw new Error('MODEL_PROVIDER_INVALID_OUTPUT: response must be a string');
  return { output: envelope.response, ...(signals(envelope.semantic_signals) ? { semantic_signals: signals(envelope.semantic_signals) } : {}) };
} }; }

function taskFor(message: string): Task { const text = message.toLowerCase(); if (/\b(draw|image|gambar|generate (an )?image|buat gambar|ilustrasi|foto)\b/.test(text)) return 'image'; if (/\b(analy[sz]e|reason|reasoning|deep dive|compare|bandingkan|jelaskan mendalam|debug|architecture|arsitektur)\b/.test(text)) return 'reasoning'; return 'conversation'; }

function select(candidates: Candidate[], capability: Capability, task: Task): Candidate {
  const eligible = candidates.filter(c => c.capability === capability && c.cost_tier === 'ZERO_BUDGET');
  eligible.sort((a, b) => (a.tasks?.includes(task) ? 0 : 1) - (b.tasks?.includes(task) ? 0 : 1) || (a.priority ?? 0) - (b.priority ?? 0));
  const candidate = eligible[0];
  if (!candidate) throw new Error('MODEL_SELECTION_FAILED: no zero-budget model available for capability/task');
  return candidate;
}

export async function executeModel(userMessage: string): Promise<{ response: Response; task: Task; model_id: string; provider: string; cost_tier: CostTier }> {
  const task = taskFor(userMessage);
  const capability: Capability = task === 'image' ? 'image' : 'text';
  const candidates: Candidate[] = [
    { id: 'openrouter/free', capability: 'text', cost_tier: 'ZERO_BUDGET', adapter: openRouter(), tasks: ['conversation', 'reasoning', 'semantic'], priority: 0 },
    { id: 'groq/openai/gpt-oss-20b', capability: 'text', cost_tier: 'ZERO_BUDGET', adapter: groq(), tasks: ['conversation', 'reasoning'], priority: 1 },
    { id: 'huggingface/openai/gpt-oss-20b:groq', capability: 'text', cost_tier: 'ZERO_BUDGET', adapter: huggingFace(), tasks: ['conversation', 'semantic'], priority: 2 },
  ];
  const failures: string[] = [];
  while (candidates.length) {
    let candidate: Candidate;
    try { candidate = select(candidates, capability, task); } catch (error) { throw new Error(error instanceof Error ? error.message : 'MODEL_SELECTION_FAILED'); }
    try {
      const result = await candidate.adapter.generate({ capability, context: { user_message: userMessage } });
      return { response: result, task, model_id: candidate.id, provider: candidate.id.split('/')[0], cost_tier: candidate.cost_tier };
    } catch (error) {
      failures.push(`${candidate.id}: ${error instanceof Error ? error.message : 'MODEL_PROVIDER_FAILED'}`);
      const index = candidates.findIndex(c => c.id === candidate.id); if (index >= 0) candidates.splice(index, 1);
    }
  }
  throw new Error(`MODEL_EXECUTION_FAILED_ALL_ZERO_BUDGET: ${failures.join(' | ')}`);
}

export type JourneyCandidate = { event_type: string; payload: Record<string, unknown>; source_ref?: string | null; occurred_at?: string | null; continuity_status?: string; gap_code?: string | null };
export type JourneyRecorder = { record(input: { sh_id: string; event_type: string; occurred_at?: string | null; continuity_status?: string; gap_code?: string | null; payload: Record<string, unknown>; source_ref?: string | null }): Promise<string> };

export function createJourneySink(detector: (response: unknown) => JourneyCandidate | undefined, recorder: JourneyRecorder) {
  return { async decideAndRecord(input: { sh_id: string; user_message: string; response: unknown; explicit?: boolean }) {
    const candidate = input.explicit ? { event_type: 'EXPERIENCE', continuity_status: 'CONTINUOUS', payload: { representation: input.user_message, capture_mode: 'EXPLICIT_USER' }, source_ref: 'runtime:p5a:explicit_user_capture' } : detector(input.response);
    if (!candidate) return { record: false, reason: 'NONE' as const };
    await recorder.record({ sh_id: input.sh_id, event_type: candidate.event_type, occurred_at: candidate.occurred_at, continuity_status: candidate.continuity_status, gap_code: candidate.gap_code, payload: candidate.payload, source_ref: candidate.source_ref });
    return { record: true, reason: input.explicit ? 'EXPLICIT' as const : 'AUTOMATIC' as const, candidate };
  } };
}

export function journeyCandidateFromResponse(response: unknown): JourneyCandidate | undefined {
  if (!response || typeof response !== 'object' || Array.isArray(response)) return undefined;
  const r = response as Record<string, unknown>;
  const semantic = r.semantic_signals && typeof r.semantic_signals === 'object' && !Array.isArray(r.semantic_signals) ? r.semantic_signals as Record<string, unknown> : r;
  const raw = semantic.journey_candidate;
  if (!raw || typeof raw !== 'object' || Array.isArray(raw)) return undefined;
  const c = raw as Record<string, unknown>;
  if (typeof c.event_type !== 'string' || !c.payload || typeof c.payload !== 'object' || Array.isArray(c.payload)) return undefined;
  return { event_type: c.event_type, payload: c.payload as Record<string, unknown>, source_ref: typeof c.source_ref === 'string' ? c.source_ref : 'runtime:p4d:journey_candidate', occurred_at: typeof c.occurred_at === 'string' ? c.occurred_at : null, continuity_status: typeof c.continuity_status === 'string' ? c.continuity_status : 'CONTINUOUS', gap_code: typeof c.gap_code === 'string' ? c.gap_code : null };
}
