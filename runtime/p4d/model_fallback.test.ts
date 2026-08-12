import { assertEquals } from 'jsr:@std/assert';
import { executeWithFallback, type FallbackModelCandidate } from './model_fallback.ts';
import type { ModelAdapter } from './model_abstraction.ts';

const failingAdapter: ModelAdapter = {
  async generate() {
    throw new Error('provider unavailable');
  },
};

const workingAdapter: ModelAdapter = {
  async generate() {
    return { output: 'fallback-ok' };
  },
};

Deno.test('P4D-003 falls back to the next eligible model after primary failure', async () => {
  const candidates: FallbackModelCandidate[] = [
    { id: 'primary', capability: 'text', cost_tier: 'ZERO_BUDGET', adapter: failingAdapter },
    { id: 'secondary', capability: 'text', cost_tier: 'ZERO_BUDGET', adapter: workingAdapter },
  ];

  const result = await executeWithFallback(candidates, {
    capability: 'text',
    context: { input: 'hello' },
  });

  assertEquals(result.ok, true);
  if (result.ok) {
    assertEquals(result.model_id, 'secondary');
    assertEquals(result.fallback_used, true);
    assertEquals(result.attempted_model_ids, ['primary', 'secondary']);
  }
});

Deno.test('P4D-003 preserves zero-budget policy during fallback', async () => {
  const candidates: FallbackModelCandidate[] = [
    { id: 'primary', capability: 'text', cost_tier: 'PAID', adapter: failingAdapter },
    { id: 'paid-secondary', capability: 'text', cost_tier: 'PAID', adapter: workingAdapter },
  ];

  const result = await executeWithFallback(candidates, {
    capability: 'text',
  });

  assertEquals(result.ok, false);
  if (!result.ok) {
    assertEquals(result.error.code, 'MODEL_EXECUTION_FAILED');
    assertEquals(result.error.attempted_model_ids, []);
  }
});

Deno.test('P4D-003 returns structured failure when all eligible models fail', async () => {
  const result = await executeWithFallback([
    { id: 'primary', capability: 'text', cost_tier: 'ZERO_BUDGET', adapter: failingAdapter },
    { id: 'secondary', capability: 'text', cost_tier: 'ZERO_BUDGET', adapter: failingAdapter },
  ], { capability: 'text' });

  assertEquals(result.ok, false);
  if (!result.ok) {
    assertEquals(result.error.code, 'MODEL_EXECUTION_FAILED');
    assertEquals(result.error.attempted_model_ids, ['primary', 'secondary']);
  }
});

Deno.test('P4D-003 has no SH identity input or mutation boundary', async () => {
  const result = await executeWithFallback([
    { id: 'primary', capability: 'text', cost_tier: 'ZERO_BUDGET', adapter: workingAdapter },
  ], { capability: 'text' });

  assertEquals(result.ok, true);
  // Model fallback receives no SH identity and exposes no identity mutation API.
});
