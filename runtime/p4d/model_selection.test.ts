import { assertEquals, assertRejects } from 'jsr:@std/assert';
import { selectModel, type ModelCandidate } from './model_selection.ts';
import type { ModelAdapter } from './model_abstraction.ts';

const adapter: ModelAdapter = { async generate() { return { output: 'ok' }; } };

const candidates: ModelCandidate[] = [
  { id: 'paid-primary', capability: 'text', cost_tier: 'PAID', adapter },
  { id: 'zero-budget-primary', capability: 'text', cost_tier: 'ZERO_BUDGET', adapter },
];

Deno.test('P4D-002 selects an eligible zero-budget model deterministically', () => {
  const selected = selectModel(candidates, { capability: 'text' });
  assertEquals(selected.model_id, 'zero-budget-primary');
  assertEquals(selected.cost_tier, 'ZERO_BUDGET');
});

Deno.test('P4D-002 does not silently select a paid model on zero-budget path', async () => {
  await assertRejects(
    () => Promise.resolve(selectModel(
      [{ id: 'paid-only', capability: 'text', cost_tier: 'PAID', adapter }],
      { capability: 'text' },
    )),
    Error,
    'no zero-budget model available',
  );
});

Deno.test('P4D-002 can select a paid model only when explicitly allowed', () => {
  const selected = selectModel(
    [{ id: 'paid-primary', capability: 'text', cost_tier: 'PAID', adapter }],
    { capability: 'text', require_zero_budget: false },
  );
  assertEquals(selected.model_id, 'paid-primary');
  assertEquals(selected.cost_tier, 'PAID');
});

Deno.test('P4D-002 exact task match outranks general candidate', () => {
  const selected = selectModel([
    { id: 'general', capability: 'text', cost_tier: 'ZERO_BUDGET', adapter, priority: 0 },
    { id: 'semantic-specialist', capability: 'text', cost_tier: 'ZERO_BUDGET', adapter, tasks: ['semantic'], priority: 5 },
  ], { capability: 'text', task: 'semantic' });
  assertEquals(selected.model_id, 'semantic-specialist');
});

Deno.test('P4D-002 keeps model selection independent from SH identity', () => {
  const selected = selectModel(candidates, { capability: 'text' });
  assertEquals(selected.model_id, 'zero-budget-primary');
});


Deno.test('P4D-002 selects the zero-budget image generation candidate', () => {
  const selected = selectModel([
    { id: 'openrouter/image-generation', capability: 'image', cost_tier: 'ZERO_BUDGET', adapter },
    { id: 'paid-image-fallback', capability: 'image', cost_tier: 'PAID', adapter, priority: 1 },
  ], { capability: 'image', task: 'image' });
  assertEquals(selected.model_id, 'openrouter/image-generation');
  assertEquals(selected.cost_tier, 'ZERO_BUDGET');
});
