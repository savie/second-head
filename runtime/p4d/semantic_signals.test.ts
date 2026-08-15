import { isSemanticSignals, type SemanticSignals } from './semantic_signals.ts';
import { createModelExecutor } from './model_abstraction.ts';

Deno.test('P4D semantic signals are optional and provider-neutral', async () => {
  const signals: SemanticSignals = {
    memory_candidate: {
      content: 'User prefers concise answers.',
      confidence: 0.91,
      scope: 'PRIVATE',
      visibility: 'OWNER_ONLY',
      lifecycle: 'CANDIDATE',
    },
    knowledge_candidate: {
      content: 'A concise rule learned from the interaction.',
      source: 'runtime_semantic_output',
      origin: 'MEMORY',
      scope: 'PRIVATE',
      visibility: 'OWNER_ONLY',
    },
  };

  const executor = createModelExecutor({
    async generate() {
      return { output: 'normal response', semantic_signals: signals };
    },
  });

  const result = await executor.execute({
    capability: 'text',
    context: { prompt: 'hello' },
  });

  if (!isSemanticSignals(result.semantic_signals)) {
    throw new Error('semantic signals were not preserved through P4D');
  }
  if (result.semantic_signals?.memory_candidate?.content !== 'User prefers concise answers.') {
    throw new Error('memory candidate was not preserved');
  }
  if (result.semantic_signals?.knowledge_candidate?.origin !== 'MEMORY') {
    throw new Error('knowledge acquisition origin was not preserved');
  }
});

Deno.test('P4D does not require semantic signals for ordinary model output', async () => {
  const executor = createModelExecutor({
    async generate() {
      return { output: 'ordinary response' };
    },
  });

  const result = await executor.execute({
    capability: 'text',
    context: { prompt: 'hello' },
  });

  if (result.output !== 'ordinary response') throw new Error('ordinary output changed');
  if (result.semantic_signals !== undefined) throw new Error('semantic signals became mandatory');
});

Deno.test('P4D semantic signal validation rejects non-object envelopes', () => {
  if (isSemanticSignals(null)) throw new Error('null accepted');
  if (isSemanticSignals('signals')) throw new Error('string accepted');
  if (isSemanticSignals([])) throw new Error('array accepted');
});

Deno.test('P4D semantic signals do not contain persistence or authority fields', () => {
  const signals: SemanticSignals = {
    memory_candidate: {
      content: 'candidate only',
      lifecycle: 'CANDIDATE',
      visibility: 'OWNER_ONLY',
    },
    knowledge_candidate: {
      content: 'acquisition candidate only',
      source: 'runtime_semantic_output',
      origin: 'EXPLICIT_TEACHING',
    },
  };

  const forbidden = ['sh_id', 'account_id', 'trusted', 'accepted', 'persist', 'journey_event'];
  const serialized = JSON.stringify(signals);
  for (const field of forbidden) {
    if (serialized.includes(`"${field}"`)) throw new Error(`forbidden authority field: ${field}`);
  }
});
