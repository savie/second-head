import { assertEquals, assertRejects } from 'jsr:@std/assert';
import { ToolRegistry, type ToolDefinition } from './tool_registry.ts';

const schema = <T>(validate: (value: unknown) => value is T) => ({ validate });

const tool: ToolDefinition<string, { received: string }> = {
  id: 'example.lookup',
  input_schema: schema((value): value is string => typeof value === 'string'),
  output_schema: schema(
    (value): value is { received: string } =>
      typeof value === 'object' &&
      value !== null &&
      'received' in value &&
      typeof value.received === 'string',
  ),
  async execute(input) {
    return { received: input };
  },
};

Deno.test('P4E-001 registers tools without granting invocation permission', async () => {
  const registry = new ToolRegistry();
  registry.register(tool);

  assertEquals(registry.list(), ['example.lookup']);
  await assertRejects(
    () => registry.invoke({ tool_id: 'example.lookup', sh_id: 'sh-1', input: 'x' }),
    Error,
    'explicit authorization is required',
  );
});

Deno.test('P4E-001 invokes a registered tool only after explicit authorization', async () => {
  const registry = new ToolRegistry();
  registry.register(tool);

  const result = await registry.invoke(
    { tool_id: 'example.lookup', sh_id: 'sh-1', input: 'x' },
    { isAuthorized: () => true },
  );

  assertEquals(result.tool_id, 'example.lookup');
  assertEquals(result.output, { received: 'x' });
});

Deno.test('P4E-001 authorization denial blocks invocation', async () => {
  const registry = new ToolRegistry();
  registry.register(tool);

  await assertRejects(
    () => registry.invoke(
      { tool_id: 'example.lookup', sh_id: 'sh-1', input: 'x' },
      { isAuthorized: () => false },
    ),
    Error,
    'explicit authorization is required',
  );
});

Deno.test('P4E-001 unregistered tools remain denied', async () => {
  const registry = new ToolRegistry();

  await assertRejects(
    () => registry.invoke(
      { tool_id: 'missing.tool', sh_id: 'sh-1', input: null },
      { isAuthorized: () => true },
    ),
    Error,
    'tool is not registered',
  );
});

Deno.test('P4E-003 rejects invalid input before the tool executes', async () => {
  const registry = new ToolRegistry();
  let executed = false;
  registry.register({
    ...tool,
    async execute(input) {
      executed = true;
      return tool.execute(input);
    },
  });

  await assertRejects(
    () => registry.invoke(
      { tool_id: 'example.lookup', sh_id: 'sh-1', input: 42 },
      { isAuthorized: () => true },
    ),
    Error,
    'input schema validation failed',
  );
  assertEquals(executed, false);
});

Deno.test('P4E-003 rejects invalid output before downstream use', async () => {
  const registry = new ToolRegistry();
  registry.register({
    ...tool,
    async execute() {
      return { received: 42 } as unknown as { received: string };
    },
  });

  await assertRejects(
    () => registry.invoke(
      { tool_id: 'example.lookup', sh_id: 'sh-1', input: 'x' },
      { isAuthorized: () => true },
    ),
    Error,
    'output schema validation failed',
  );
});
