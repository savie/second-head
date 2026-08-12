/**
 * P4E-002 — Tool Invocation & Untrusted Data Boundary
 * Phase 4 — Runtime & Orchestration
 *
 * Minimal realization:
 * - authorized invocation is performed by the existing ToolRegistry;
 * - returned tool content is explicitly wrapped as UNTRUSTED external data;
 * - the wrapper carries no authority semantics and cannot grant system/model authority;
 * - downstream layers must treat `data` as content, never as instructions.
 */

export type UntrustedToolResult<T = unknown> = Readonly<{
  source: 'TOOL';
  trust: 'UNTRUSTED_EXTERNAL_DATA';
  tool_id: string;
  data: T;
}>;

/**
 * Converts an already-authorized tool result into the only boundary shape
 * exposed to downstream reasoning/context code.
 *
 * No content is promoted to system/developer/user authority here.
 */
export function wrapToolResultAsUntrusted<T>(
  tool_id: string,
  data: T,
): UntrustedToolResult<T> {
  if (!tool_id.trim()) {
    throw new Error('TOOL_RESULT_REJECTED: tool id is required');
  }

  return Object.freeze({
    source: 'TOOL' as const,
    trust: 'UNTRUSTED_EXTERNAL_DATA' as const,
    tool_id,
    data,
  });
}
