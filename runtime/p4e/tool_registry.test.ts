import { assertEquals, assertRejects } from 'jsr:@std/assert';
import { ToolRegistry, type ToolDefinition } from './tool_registry.ts';

const tool: ToolDefinition = {
  id: 'example.lookup',
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
