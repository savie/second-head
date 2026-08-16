import { assertEquals } from 'jsr:@std/assert';
import { createRuntimeCoreLoop } from './runtime_core_loop.ts';
import { createReasoningEngine } from '../p4b/reasoning_context.ts';
import { createModelRegistry } from '../p4d/model_registry.ts';
import type { ModelAdapter } from '../p4d/model_abstraction.ts';

Deno.test('P4A-001 resolves existing SH identity and preserves it through model response', async () => {
  const calls: string[] = [];
  const runtime = createRuntimeCoreLoop({
    identityResolver: { async resolve(authUid) { calls.push(`identity:${authUid}`); return { account_id: 'account-1', sh_id: 'sh-001', ownership_role: 'owner' }; } },
    contextAssembler: { async assemble({ identity, user_message }) { calls.push(`context:${identity.sh_id}`); return { identity, user_message, entries: [] }; } },
    modelAdapter: { async generate(context) { calls.push(`model:${context.identity.sh_id}`); return { output: { type: 'text', content: 'ok' } }; } },
    journeyDecision: { async decideAndRecord({ sh_id }) { calls.push(`journey:${sh_id}`); return { record: false, reason: 'NONE' }; } },
    memoryDecision: { async decide({ identity }) { calls.push(`memory:${identity.sh_id}`); } },
  });
  const result = await runtime({ auth_uid: 'auth-user-1', user_message: 'hello' });
  if (result.sh_id !== 'sh-001') throw new Error('SH identity changed');
  if (calls.join('|') !== 'identity:auth-user-1|context:sh-001|model:sh-001|journey:sh-001|memory:sh-001') {
    throw new Error(`unexpected runtime order: ${calls.join('|')}`);
  }
});

Deno.test('P4A production composition resolves ModelCandidate[] through the P4D registry into ModelExecutor', async () => {
  const calls: string[] = [];
  const primary: ModelAdapter = { async generate() { calls.push('primary'); return { output: 'primary-response' }; } };
  const paid: ModelAdapter = { async generate() { calls.push('paid'); return { output: 'paid-response' }; } };

  const runtime = createRuntimeCoreLoop({
    identityResolver: { async resolve() { return { account_id: 'account-1', sh_id: 'sh-001', ownership_role: 'owner' }; } },
    contextAssembler: { async assemble({ identity, user_message }) { return { identity, user_message, entries: [] }; } },
    modelRegistry: createModelRegistry([
      { id: 'paid-first', capability: 'text', cost_tier: 'PAID', adapter: paid },
      { id: 'zero-budget-primary', capability: 'text', cost_tier: 'ZERO_BUDGET', adapter: primary },
    ]),
    journeyDecision: { async decideAndRecord() { return { record: false, reason: 'NONE' }; } },
    memoryDecision: { async decide() {} },
  });

  const result = await runtime({ auth_uid: 'auth-user-1', user_message: 'hello' });
  assertEquals(result.response, 'primary-response');
  assertEquals(calls, ['primary']);
});

Deno.test('P4A/P3D authenticated deterministic E2E hands semantic Knowledge candidate to Acquisition without validating in P4A', async () => {
  const seenMemory: unknown[] = [];
  const seenKnowledge: unknown[] = [];
  const seenJourney: unknown[] = [];
  const deterministicReasoning = createReasoningEngine({
    async generate() {
      return {
        output: 'deterministic model response',
        semantic_signals: {
          memory_candidate: { content: 'User prefers concise replies.', confidence: 0.91 },
          knowledge_candidate: {
            content: 'A rule explicitly proposed for acquisition.',
            source: 'deterministic-test-adapter',
            origin: 'EXPLICIT_TEACHING',
            scope: 'PRIVATE',
            visibility: 'OWNER_ONLY',
          },
        },
      };
    },
  });

  const runtime = createRuntimeCoreLoop({
    identityResolver: { async resolve(authUid) { if (authUid !== 'auth-user-1') return null; return { account_id: 'account-1', sh_id: 'sh-001', ownership_role: 'owner' }; } },
    contextAssembler: { async assemble({ identity, user_message }) { return { identity, user_message, entries: [] }; } },
    modelAdapter: { async generate() { throw new Error('must not run when reasoningEngine is provided'); } },
    reasoningEngine: deterministicReasoning,
    journeyDecision: { async decideAndRecord(input) { seenJourney.push(input); return { record: false, reason: 'NONE' }; } },
    memoryDecision: { async decide(input) { seenMemory.push(input); } },
    knowledgeAcquisition: { async acquire(input) { seenKnowledge.push(input); } },
  });

  const result = await runtime({ auth_uid: 'auth-user-1', user_message: 'I am teaching SH a rule.' });
  if (result.sh_id !== 'sh-001') throw new Error('authenticated SH identity changed');
  if (seenJourney.length !== 1) throw new Error('Journey insertion point was not reached exactly once');
  if (seenMemory.length !== 1) throw new Error('Memory decision was not reached exactly once');
  if (seenKnowledge.length !== 1) throw new Error('Knowledge acquisition was not reached exactly once');

  const memoryInput = seenMemory[0] as Record<string, unknown>;
  const memoryResponse = memoryInput.response as Record<string, unknown>;
  const memorySignals = memoryResponse.semantic_signals as Record<string, unknown>;
  const memoryCandidate = memorySignals.memory_candidate as Record<string, unknown>;
  if ((memoryInput.identity as { sh_id: string }).sh_id !== 'sh-001') throw new Error('Memory identity changed');
  if (memoryCandidate.content !== 'User prefers concise replies.') throw new Error('Memory candidate was lost');

  const knowledgeInput = seenKnowledge[0] as Record<string, unknown>;
  const knowledgeIdentity = knowledgeInput.identity as { sh_id: string };
  const knowledgeCandidate = knowledgeInput.candidate as Record<string, unknown>;
  if (knowledgeIdentity.sh_id !== 'sh-001') throw new Error('Knowledge identity changed');
  if (knowledgeCandidate.content !== 'A rule explicitly proposed for acquisition.') throw new Error('Knowledge candidate was lost');
  if (knowledgeCandidate.origin !== 'EXPLICIT_TEACHING') throw new Error('Knowledge origin was changed');
  if (knowledgeCandidate.visibility !== 'OWNER_ONLY') throw new Error('Knowledge privacy boundary was changed');
  if ('validation' in knowledgeInput) throw new Error('P4A must not perform P3D validation');
});

Deno.test('P3D invalid Knowledge candidate is still handed to Acquisition; validation is downstream', async () => {
  const seen: unknown[] = [];
  const deterministicReasoning = createReasoningEngine({
    async generate() {
      return { output: 'response', semantic_signals: { knowledge_candidate: { content: ' ', source: 'test', origin: 'EXPLICIT_TEACHING' } } };
    },
  });
  const runtime = createRuntimeCoreLoop({
    identityResolver: { async resolve() { return { account_id: 'account-1', sh_id: 'sh-001', ownership_role: 'owner' }; } },
    contextAssembler: { async assemble({ identity, user_message }) { return { identity, user_message, entries: [] }; } },
    modelAdapter: { async generate() { throw new Error('must not run'); } },
    reasoningEngine: deterministicReasoning,
    journeyDecision: { async decideAndRecord() { return { record: false, reason: 'NONE' }; } },
    memoryDecision: { async decide() {} },
    knowledgeAcquisition: { async acquire(input) { seen.push(input); } },
  });
  await runtime({ auth_uid: 'auth-user-1', user_message: 'invalid candidate' });
  if (seen.length !== 1) throw new Error('Acquisition boundary did not receive candidate');
  const input = seen[0] as Record<string, unknown>;
  if ((input.candidate as Record<string, unknown>).content !== ' ') throw new Error('candidate changed before acquisition');
});

Deno.test('P4A-001 fails closed when identity cannot be resolved', async () => {
  const runtime = createRuntimeCoreLoop({
    identityResolver: { async resolve() { return null; } },
    contextAssembler: { async assemble() { throw new Error('must not run'); } },
    modelAdapter: { async generate() { throw new Error('must not run'); } },
    journeyDecision: { async decideAndRecord() { throw new Error('must not run'); } },
    memoryDecision: { async decide() { throw new Error('must not run'); } },
  });
  await runtime({ auth_uid: 'unknown-user', user_message: 'hello' })
    .then(() => { throw new Error('runtime should reject unresolved identity'); })
    .catch((error) => { if (!String(error).includes('SH identity could not be resolved')) throw error; });
});

Deno.test('P4A-001 rejects unauthenticated runtime input before dependency calls', async () => {
  const runtime = createRuntimeCoreLoop({
    identityResolver: { async resolve() { throw new Error('must not run'); } },
    contextAssembler: { async assemble() { throw new Error('must not run'); } },
    modelAdapter: { async generate() { throw new Error('must not run'); } },
    journeyDecision: { async decideAndRecord() { throw new Error('must not run'); } },
    memoryDecision: { async decide() { throw new Error('must not run'); } },
  });
  await runtime({ auth_uid: '', user_message: 'hello' })
    .then(() => { throw new Error('runtime should reject missing auth uid'); })
    .catch((error) => { if (!String(error).includes('authenticated identity is required')) throw error; });
});
