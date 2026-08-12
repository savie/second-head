/**
 * P4E-001 / P4E-002 / P4E-003 / P4E-004 — Tool execution boundary
 * Phase 4 — Runtime & Orchestration
 *
 * Minimal realization:
 * - available tools are explicitly registered;
 * - access is denied unless the caller supplies explicit authorization;
 * - tool inputs are validated before invocation;
 * - tool outputs are validated before downstream use;
 * - every invocation attempt is audited;
 * - a tool is a capability, not an authority;
 * - validation/auditing does not create or mutate SH identity/ownership.
 */

import type { RuntimeAuditSink } from '../p4a/runtime_audit_persistence.ts';

export type ToolRequest = Readonly<{
  tool_id: string;
  sh_id: string;
  account_id: string;
  actor_id: string;
  input: unknown;
}>;

export type ToolSchema<T = unknown> = Readonly<{
  validate: (value: unknown) => value is T;
}>;

export type ToolDefinition<TInput = unknown, TOutput = unknown> = Readonly<{
  id: string;
  input_schema: ToolSchema<TInput>;
  output_schema: ToolSchema<TOutput>;
  execute: (input: TInput) => Promise<TOutput>;
}>;

export interface ToolAuthorizer {
  isAuthorized(request: ToolRequest): boolean | Promise<boolean>;
}

export type ToolInvocation<TOutput = unknown> = Readonly<{
  tool_id: string;
  output: TOutput;
}>;

async function sha256(value: unknown): Promise<string> {
  const encoded = new TextEncoder().encode(JSON.stringify(value));
  const digest = await crypto.subtle.digest('SHA-256', encoded);
  return [...new Uint8Array(digest)]
    .map((byte) => byte.toString(16).padStart(2, '0'))
    .join('');
}

/**
 * Registry is deliberately deny-by-default. Registration makes a capability
 * discoverable; it does not grant permission to invoke it.
 */
export class ToolRegistry {
  private readonly tools = new Map<string, ToolDefinition>();

  constructor(private readonly auditSink: RuntimeAuditSink) {}

  register(tool: ToolDefinition): void {
    if (!tool.id.trim()) throw new Error('TOOL_REGISTRY_REJECTED: tool id is required');
    if (this.tools.has(tool.id)) {
      throw new Error('TOOL_REGISTRY_REJECTED: duplicate tool id');
    }
    this.tools.set(tool.id, tool);
  }

  list(): readonly string[] {
    return Object.freeze([...this.tools.keys()]);
  }

  private async audit(
    request: ToolRequest,
    status: 'SUCCESS' | 'REJECTED' | 'FAILED',
    result: unknown,
    reason?: string,
  ): Promise<void> {
    await this.auditSink.append({
      account_id: request.account_id,
      sh_id: request.sh_id,
      event_type: 'TOOL_INVOCATION',
      status,
      metadata: {
        actor_id: request.actor_id,
        tool_id: request.tool_id,
        result_hash: await sha256(result),
        ...(reason ? { reason } : {}),
      },
    });
  }

  async invoke<TOutput = unknown>(
    request: ToolRequest,
    authorizer?: ToolAuthorizer,
  ): Promise<ToolInvocation<TOutput>> {
    if (!request.sh_id || !request.account_id || !request.actor_id) {
      throw new Error('TOOL_REJECTED: audit identity context is required');
    }

    const tool = this.tools.get(request.tool_id);
    if (!tool) {
      const error = new Error('TOOL_DENIED: tool is not registered');
      await this.audit(request, 'REJECTED', error.message, error.message);
      throw error;
    }

    let authorized = false;
    try {
      authorized = authorizer
        ? await authorizer.isAuthorized(request)
        : false;
    } catch (error) {
      const reason = error instanceof Error ? error.message : 'authorization failed';
      await this.audit(request, 'FAILED', reason, reason);
      throw error;
    }

    if (!authorized) {
      const error = new Error('TOOL_DENIED: explicit authorization is required');
      await this.audit(request, 'REJECTED', error.message, error.message);
      throw error;
    }

    if (!tool.input_schema.validate(request.input)) {
      const error = new Error('TOOL_REJECTED: input schema validation failed');
      await this.audit(request, 'REJECTED', error.message, error.message);
      throw error;
    }

    try {
      const output = await tool.execute(request.input);

      if (!tool.output_schema.validate(output)) {
        const error = new Error('TOOL_REJECTED: output schema validation failed');
        await this.audit(request, 'REJECTED', error.message, error.message);
        throw error;
      }

      await this.audit(request, 'SUCCESS', output);

      return Object.freeze({
        tool_id: request.tool_id,
        output: output as TOutput,
      });
    } catch (error) {
      if (error instanceof Error && error.message.startsWith('TOOL_REJECTED: output schema')) {
        throw error;
      }

      const reason = error instanceof Error ? error.message : 'tool execution failed';
      await this.audit(request, 'FAILED', reason, reason);
      throw error;
    }
  }
}
