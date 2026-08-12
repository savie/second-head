import { strict as assert } from 'node:assert';
import { createReasoningEngine, type ReasoningContext, type ReasoningEvidence } from './reasoning_context.ts';

Deno.test('P4B-002 records bounded reasoning-cycle evidence', async () => {
  const events: ReasoningEvidence[] = [];
  const context: ReasoningContext = {
    identity: { sh_id: 'sh-test' },
    user_message: 'hello',
    entries: [{ kind: 'context', value: 'bounded' }],
  };

  const engine = createReasoningEngine(
    {
      async generate() {
        return { output: { answer: 'ok' } };
      },
    },
    { append: async (event) => events.push(event) },
  );

  const result = await engine.process({ context });

  assert.deepEqual(result.output, { answer: 'ok' });
  assert.equal(events.length, 2);
  assert.equal(events[0].sh_id, 'sh-test');
  assert.equal(events[0].metadata.phase, 'MODEL_INPUT');
  assert.equal(events[1].metadata.phase, 'MODEL_OUTPUT');
  assert.equal(typeof events[0].metadata.context_hash, 'string');
  assert.equal(typeof events[1].metadata.output_hash, 'string');
  assert.equal(events[0].metadata.evidence_version, 'P4B-002.v1');
  assert.equal(Object.prototype.hasOwnProperty.call(events[0].metadata, 'user_message'), false);
  assert.equal(Object.prototype.hasOwnProperty.call(events[1].metadata, 'output'), false);

  console.log('P4B-002 reasoning process evidence logging: PASS');
});

Deno.test('P4B-002 records model failure without exposing raw error details', async () => {
  const events: ReasoningEvidence[] = [];
  const engine = createReasoningEngine(
    {
      async generate() {
        throw new Error('provider secret detail');
      },
    },
    { append: async (event) => events.push(event) },
  );

  await assert.rejects(() => engine.process({
    context: { identity: { sh_id: 'sh-test' }, user_message: 'hello', entries: [] },
  }));

  assert.equal(events.length, 2);
  assert.equal(events[1].status, 'FAILED');
  assert.equal(events[1].metadata.error_type, 'Error');
  assert.equal(Object.prototype.hasOwnProperty.call(events[1].metadata, 'error_message'), false);
});
