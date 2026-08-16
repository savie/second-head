import { assertEquals, assertRejects } from 'jsr:@std/assert';
import { createModelRegistry } from './model_registry.ts';
import type { ModelAdapter } from './model_abstraction.ts';
import type { ModelCandidate } from './model_selection.ts';

const adapter: ModelAdapter = {
  async generate() {
    return { output: 'ok' };
  },
};

Deno.test('P4D registry preserves an ordered multi-candidate set', () => {
  const candidates: ModelCandidate[] = [
    { id: 'provider-a', capability: 'text', cost_tier: 'ZERO_BUDGET', adapter },
    { id: 'provider-b', capability: 'text', cost_tier: 'PAID', adapter },
  ];
  const registry = createModelRegistry(candidates);
  assertEquals(registry.candidates().map((item) => item.id), ['provider-a', 'provider-b']);
});

Deno.test('P4D registry rejects duplicate candidate ids', async () => {
  await assertRejects(
    () => Promise.resolve(createModelRegistry([
      { id: 'same', capability: 'text', cost_tier: 'ZERO_BUDGET', adapter },
      { id: 'same', capability: 'text', cost_tier: 'ZERO_BUDGET', adapter },
    ])),
    Error,
    'duplicate candidate id',
  );
});

Deno.test('P4D registry returns an immutable candidate collection', () => {
  const registry = createModelRegistry([
    { id: 'provider-a', capability: 'text', cost_tier: 'ZERO_BUDGET', adapter },
  ]);
  if (!Object.isFrozen(registry.candidates())) throw new Error('registry candidates must be immutable');
});
