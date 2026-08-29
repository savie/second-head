import { backend } from './backend';

export type AuthorizedReadScope = 'PRIVATE' | 'GENERAL';
export type AuthorizedReadResult = { result_id: string; content: string; knowledge_class: string; source: string; scope: AuthorizedReadScope; visibility: string; provenance: Record<string, unknown> | null; occurred_at: string; };

export async function authorizedRead(input: { shId: string; source: string; scope: AuthorizedReadScope; query?: string; limit?: number; offset?: number }): Promise<AuthorizedReadResult[]> {
  const invocationId = crypto.randomUUID();
  if (!input.shId) throw new Error('R2_REQUIRES_SH_ID');
  if (!input.source.trim()) throw new Error('R2_REQUIRES_SOURCE');
  const query = input.query?.trim() || null;
  if (query && query.length > 2000) throw new Error('R2_QUERY_TOO_LARGE');
  const limit = Math.min(Math.max(Math.trunc(input.limit ?? 20), 1), 50);
  const offset = Math.min(Math.max(Math.trunc(input.offset ?? 0), 0), 200);
  const { data, error } = await backend.rpc('authorized_read_retrieve_bounded', { p_sh_id: input.shId, p_source: input.source.trim(), p_scope: input.scope, p_query: query, p_limit: limit, p_offset: offset, p_invocation_id: invocationId });
  if (error) throw new Error('R2_FAILED: ' + error.message);
  return (Array.isArray(data) ? data : []) as AuthorizedReadResult[];
}
