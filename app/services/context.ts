import { backend } from './backend';

export type ContextResult = {
  sh_id: string;
  query: string;
  memory: Array<Record<string, unknown>>;
  knowledge: Array<Record<string, unknown>>;
  journey: Array<Record<string, unknown>>;
  bounds: { memory_limit: number; knowledge_limit: number; journey_limit: number };
};

export async function loadSHContext(input: {
  shId: string;
  query?: string;
  memoryLimit?: number;
  knowledgeLimit?: number;
  journeyLimit?: number;
}): Promise<ContextResult> {
  const query = input.query?.trim() ?? '';
  const memoryLimit = Math.min(Math.max(Math.trunc(input.memoryLimit ?? 10), 1), 20);
  const knowledgeLimit = Math.min(Math.max(Math.trunc(input.knowledgeLimit ?? 10), 1), 20);
  const journeyLimit = Math.min(Math.max(Math.trunc(input.journeyLimit ?? 20), 1), 50);

  if (!input.shId) throw new Error('SH_CONTEXT_REQUIRES_SH_ID');
  if (query.length > 2_000) throw new Error('SH_CONTEXT_QUERY_TOO_LARGE');

  const { data: context, error: contextError } = await backend.rpc('assemble_context', {
    p_sh_id: input.shId,
    p_query_text: query,
    p_memory_limit: memoryLimit,
    p_knowledge_limit: knowledgeLimit,
  });
  if (contextError) throw new Error(`SH_CONTEXT_ASSEMBLY_FAILED: ${contextError.message}`);

  const { data: journey, error: journeyError } = await backend
    .from('journey_events')
    .select('event_id,event_type,occurred_at,continuity_status,gap_code,payload,source_ref,created_at')
    .eq('sh_id', input.shId)
    .order('occurred_at', { ascending: false })
    .limit(journeyLimit);
  if (journeyError) throw new Error(`SH_JOURNEY_RETRIEVAL_FAILED: ${journeyError.message}`);

  const normalized = (context && typeof context === 'object' ? context : {}) as {
    memory?: unknown;
    knowledge?: unknown;
  };

  return {
    sh_id: input.shId,
    query,
    memory: Array.isArray(normalized.memory) ? normalized.memory as Array<Record<string, unknown>> : [],
    knowledge: Array.isArray(normalized.knowledge) ? normalized.knowledge as Array<Record<string, unknown>> : [],
    journey: (journey ?? []) as Array<Record<string, unknown>>,
    bounds: { memory_limit: memoryLimit, knowledge_limit: knowledgeLimit, journey_limit: journeyLimit },
  };
}
