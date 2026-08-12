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

const auditEvents: Array<Record<string, unknown>> = [];
const auditSink = {
  async append(event: Record<string, unknown>) {
    auditEvents.push(event);
  },
};

const request = {
  tool_id: 'example.lookup',
  sh_id: 'sh-1',
  account_id: 'account-1',
  actor_id: 'actor-1',
  input: 'x',
};

Deno.test('P4E-001 registers tools without granting invocation permission', async () => {
  const registry = new ToolRegistry(auditSink);
  registry.register(tool);

  assertEquals(registry.list(), ['example.lookup']);
  await assertRejects(
    () => registry.invoke(request),
    Error,
    'explicit authorization is required',
  );
});

Deno.test('P4E-001 invokes a registered tool only after explicit authorization', async () => {
  const registry = new ToolRegistry(auditSink);
  registry.register(tool);

  const result = await registry.invoke(
    request,
    { isAuthorized: () => true },
  );

  assertEquals(result.tool_id, 'example.lookup');
  assertEquals(result.output, { received: 'x' });
});

Deno.test('P4E-001 authorization denial blocks invocation', async () => {
  const registry = new ToolRegistry(auditSink);
  registry.register(tool);

  await assertRejects(
    () => registry.invoke(request, { isAuthorized: () => false }),
    Error,
    'explicit authorization is required',
  );
});

Deno.test('P4E-001 unregistered tools remain denied', async () => {
  const registry = new ToolRegistry(auditSink);

  await assertRejects(
    () => registry.invoke({ ...request, tool_id: 'missing.tool', input: null }, { isAuthorized: () => true }),
    Error,
    'tool is not registered',
  );
});

Deno.test('P4E-003 rejects invalid input before the tool executes', async () => {
  const registry = new ToolRegistry(auditSink);
  let executed = false;
  registry.register({
    ...tool,
    async execute(input) {
      executed = true;
      return tool.execute(input);
    },
  });

  await assertRejects(
    () => registry.invoke({ ...request, input: 42 }, { isAuthorized: () => true }),
    Error,
    'input schema validation failed',
  );
  assertEquals(executed, false);
});

Deno.test('P4E-003 rejects invalid output before downstream use', async () => {
  const registry = new ToolRegistry(auditSink);
  registry.register({
    ...tool,
    async execute() {
      return { received: 42 } as unknown as { received: string };
    },
  });

  await assertRejects(
    () => registry.invoke(request, { isAuthorized: () => true }),
    Error,
    'output schema validation failed',
  );
});

Deno.test('P4E-004 records tool, actor, SH and result hash on success', async () => {
  auditEvents.length = 0;
  const registry = new ToolRegistry(auditSink);
  registry.register(tool);

  await registry.invoke(request, { isAuthorized: () => true });

  assertEquals(auditEvents.length, 1);
  assertEquals(auditEvents[0].event_type, 'TOOL_INVOCATION');
  assertEquals(auditEvents[0].status, 'SUCCESS');
  const metadata = auditEvents[0].metadata as Record<string, unknown>;
  assertEquals(metadata.actor_id, 'actor-1');
  assertEquals(metadata.tool_id, 'example.lookup');
  assertEquals(typeof metadata.result_hash, 'string');
  assertEquals((metadata.result_hash as string).length, 64);
});

Deno.test('P4E-004 records rejected and failed invocations', async () => {
  auditEvents.length = 0;
  const registry = new ToolRegistry(auditSink);
  registry.register({
    ...tool,
    async execute() {
      throw new Error('upstream timeout');
    },
  });

  await assertRejects(
    () => registry.invoke(request, { isAuthorized: () => true }),
    Error,
    'upstream timeout',
  );

  await assertRejects(
    () => registry.invoke(request, { isAuthorized: () => false }),
    Error,
    'explicit authorization is required',
  );

  assertEquals(auditEvents.length, 2);
  assertEquals(auditEvents[0].status, 'FAILED');
  assertEquals(auditEvents[1].status, 'REJECTED');
});
