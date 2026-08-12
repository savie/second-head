import { createModelExecutor, type ModelAdapter } from './model_abstraction.ts';

Deno.test('P4D-001 keeps model execution behind a provider-independent adapter', async () => {
  const calls: unknown[] = [];
  const adapter: ModelAdapter = {
    async generate(request) {
      calls.push(request);
      return { output: { provider_result: 'ok' } };
    },
  };

  const executor = createModelExecutor(adapter);
  const result = await executor.execute({
    capability: 'text',
    context: { identity: { sh_id: 'sh-001' }, prompt: 'hello' },
  });

  if (JSON.stringify(result.output) !== JSON.stringify({ provider_result: 'ok' })) {
    throw new Error('unexpected model response');
  }
  if (calls.length !== 1) throw new Error('adapter was not invoked exactly once');
  if ((calls[0] as { capability: string }).capability !== 'text') {
    throw new Error('capability did not cross the abstraction boundary');
  }
});

Deno.test('P4D-001 supports future model capabilities without binding identity to a provider', async () => {
  const capabilities: string[] = [];
  const executor = createModelExecutor({
    async generate(request) {
      capabilities.push(request.capability);
      return { output: request.capability };
    },
  });

  for (const capability of ['text', 'vision', 'image'] as const) {
    const result = await executor.execute({ capability, context: { sh_id: 'sh-001' } });
    if (result.output !== capability) throw new Error(`unexpected ${capability} result`);
  }

  if (capabilities.join(',') !== 'text,vision,image') {
    throw new Error('model capability dispatch is not deterministic');
  }
});

Deno.test('P4D-001 rejects missing model context before provider execution', async () => {
  let called = false;
  const executor = createModelExecutor({
    async generate() {
      called = true;
      return { output: 'must not execute' };
    },
  });

  await executor.execute({ capability: 'text', context: null })
    .then(() => { throw new Error('missing context should be rejected'); })
    .catch((error) => {
      if (!String(error).includes('MODEL_REJECTED: context is required')) throw error;
    });

  if (called) throw new Error('provider executed after boundary rejection');
});
