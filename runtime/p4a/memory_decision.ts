export type MemoryCandidate = {
  content: string;
  memory_type?: 'SHORT_TERM' | 'LONG_TERM';
  source?: string;
  confidence?: number | null;
  scope?: 'PRIVATE' | 'GENERAL';
  visibility?: 'OWNER_ONLY' | 'SHARED';
  lifecycle?: 'CANDIDATE' | 'ACTIVE';
};

export type MemoryDecisionInput = {
  sh_id: string;
  user_message: string;
  response: unknown;
};

export function extractMemoryCandidate(response: unknown): MemoryCandidate | null {
  if (!response || typeof response !== 'object' || Array.isArray(response)) return null;
  const candidate = (response as Record<string, unknown>).memory_candidate;
  if (!candidate || typeof candidate !== 'object' || Array.isArray(candidate)) return null;
  const c = candidate as Record<string, unknown>;
  if (typeof c.content !== 'string' || !c.content.trim()) return null;
  if (c.memory_type !== undefined && c.memory_type !== 'SHORT_TERM' && c.memory_type !== 'LONG_TERM') return null;
  if (c.scope !== undefined && c.scope !== 'PRIVATE' && c.scope !== 'GENERAL') return null;
  if (c.visibility !== undefined && c.visibility !== 'OWNER_ONLY' && c.visibility !== 'SHARED') return null;
  if (c.lifecycle !== undefined && c.lifecycle !== 'CANDIDATE' && c.lifecycle !== 'ACTIVE') return null;
  if (c.confidence !== undefined && c.confidence !== null && (typeof c.confidence !== 'number' || c.confidence < 0 || c.confidence > 1)) return null;
  return {
    content: c.content.trim(),
    memory_type: c.memory_type as MemoryCandidate['memory_type'],
    source: typeof c.source === 'string' ? c.source : undefined,
    confidence: c.confidence as number | null | undefined,
    scope: c.scope as MemoryCandidate['scope'],
    visibility: c.visibility as MemoryCandidate['visibility'],
    lifecycle: c.lifecycle as MemoryCandidate['lifecycle'],
  };
}

export function createMemoryDecisionSink(rpc: (candidate: MemoryCandidate & { sh_id: string }) => Promise<void>) {
  return async function decide(input: MemoryDecisionInput): Promise<void> {
    const candidate = extractMemoryCandidate(input.response);
    if (!candidate) return;

    // A model may propose a memory; it does not grant itself authority to persist arbitrary state.
    // Default to private/owner-only and candidate lifecycle when omitted.
    await rpc({
      ...candidate,
      sh_id: input.sh_id,
      memory_type: candidate.memory_type ?? 'LONG_TERM',
      source: candidate.source ?? 'runtime_response',
      scope: candidate.scope ?? 'PRIVATE',
      visibility: candidate.visibility ?? 'OWNER_ONLY',
      lifecycle: candidate.lifecycle ?? 'CANDIDATE',
    });
  };
}
