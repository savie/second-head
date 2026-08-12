/**
 * P4E-001 / P4E-002 / P4E-003 — Tool execution boundary
 * Phase 4 — Runtime & Orchestration
 *
 * Minimal realization:
 * - available tools are explicitly registered;
 * - access is denied unless the caller supplies explicit authorization;
 * - tool inputs are validated before invocation;
 * - tool outputs are validated before downstream use;
 * - a tool is a capability, not an authority;
 * - validation does not create or mutate SH identity/ownership.
 */

export type ToolRequest = Readonly<{
  tool_id: string;
  sh_id: string;
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

/**
 * Registry is deliberately deny-by-default. Registration makes a capability
 * discoverable; it does not grant permission to invoke it.
 */
export class ToolRegistry {
  private readonly tools = new Map<string, ToolDefinition>();

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

  async invoke<TOutput = unknown>(
    request: ToolRequest,
    authorizer?: ToolAuthorizer,
  ): Promise<ToolInvocation<TOutput>> {
    if (!request.sh_id) throw new Error('TOOL_REJECTED: SH identity is required');

    const tool = this.tools.get(request.tool_id);
    if (!tool) throw new Error('TOOL_DENIED: tool is not registered');

    const authorized = authorizer
      ? await authorizer.isAuthorized(request)
      : false;

    if (!authorized) {
      throw new Error('TOOL_DENIED: explicit authorization is required');
    }

    if (!tool.input_schema.validate(request.input)) {
      throw new Error('TOOL_REJECTED: input schema validation failed');
    }

    const output = await tool.execute(request.input);

    if (!tool.output_schema.validate(output)) {
      throw new Error('TOOL_REJECTED: output schema validation failed');
    }

    return Object.freeze({
      tool_id: request.tool_id,
      output: output as TOutput,
    });
  }
}
