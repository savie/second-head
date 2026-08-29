import { backend } from './backend';

export type GlobalSearchDomain = 'CONVERSATION' | 'MEMORY' | 'KNOWLEDGE' | 'EXPERIENCE' | 'JOURNEY';
export type GlobalSearchResult = { result_id: string; domain: GlobalSearchDomain; title: string; snippet: string; source_ref: string | null; provenance: Record<string, unknown> | null; occurred_at: string; relevance_score: number; };
export type GlobalSearchPage = { results: GlobalSearchResult[]; query: string; offset: number; limit: number; has_more: boolean; };

export async function globalSearch(input: { shId: string; query: string; limit?: number; offset?: number; domains?: GlobalSearchDomain[] }): Promise<GlobalSearchPage> {
  const invocationId = crypto.randomUUID();
  const query = input.query.trim();
  if (!input.shId) throw new Error('GLOBAL_SEARCH_REQUIRES_SH_ID');
  if (!query) throw new Error('GLOBAL_SEARCH_REQUIRES_QUERY');
  if (query.length > 2000) throw new Error('GLOBAL_SEARCH_QUERY_TOO_LARGE');
  const limit = Math.min(Math.max(Math.trunc(input.limit ?? 20), 1), 50);
  const offset = Math.min(Math.max(Math.trunc(input.offset ?? 0), 0), 200);
  const { data, error } = await backend.rpc('global_search_bounded', { p_sh_id: input.shId, p_query_text: query, p_limit: limit + 1, p_offset: offset, p_domains: input.domains?.length ? input.domains : null, p_invocation_id: invocationId });
  if (error) throw new Error('GLOBAL_SEARCH_FAILED: ' + error.message);
  const rows = (Array.isArray(data) ? data : []) as GlobalSearchResult[];
  return { results: rows.slice(0, limit), query, offset, limit, has_more: rows.length > limit };
}