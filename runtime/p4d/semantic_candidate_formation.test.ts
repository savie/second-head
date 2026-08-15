import { formSemanticSignalsFromModelOutput } from './semantic_candidate_formation.ts';

Deno.test('P4D forms semantic signals only from an explicit object envelope', () => {
  const signals = formSemanticSignalsFromModelOutput({
    semantic_signals: {
      memory_candidate: {
        content: 'User prefers concise replies.',
        confidence: 0.9,
        scope: 'PRIVATE',
        visibility: 'OWNER_ONLY',
        lifecycle: 'CANDIDATE',
      },
      knowledge_candidate: {
        content: 'An explicit learned rule.',
        source: 'runtime_semantic_output',
        origin: 'EXPLICIT_TEACHING',
      },
    },
  });

  if (!signals?.memory_candidate) throw new Error('memory candidate was not formed');
  if (signals.memory_candidate.content !== 'User prefers concise replies.') {
    throw new Error('memory candidate content changed');
  }
  if (signals.knowledge_candidate?.origin !== 'EXPLICIT_TEACHING') {
    throw new Error('knowledge origin changed');
  }
});

Deno.test('P4D forms semantic signals from an explicit JSON envelope', () => {
  const signals = formSemanticSignalsFromModelOutput(JSON.stringify({
    semantic_signals: {
      memory_candidate: { content: 'Candidate only.' },
    },
  }));

  if (signals?.memory_candidate?.content !== 'Candidate only.') {
    throw new Error('JSON semantic candidate was not formed');
  }
});

Deno.test('P4D does not infer candidates from ordinary prose', () => {
  if (formSemanticSignalsFromModelOutput('User prefers concise replies.')) {
    throw new Error('ordinary prose must not become a candidate');
  }
});

Deno.test('P4D rejects malformed explicit semantic envelopes', () => {
  if (formSemanticSignalsFromModelOutput({ semantic_signals: null })) {
    throw new Error('null semantic envelope accepted');
  }
  if (formSemanticSignalsFromModelOutput({ semantic_signals: [] })) {
    throw new Error('array semantic envelope accepted');
  }
  if (formSemanticSignalsFromModelOutput({ semantic_signals: { memory_candidate: [] } })) {
    throw new Error('array memory candidate accepted');
  }
});
