import { validateKnowledgeCandidate } from './knowledge_acquisition_validation.ts';

Deno.test('P3D validation accepts minimum valid explicit teaching candidate', () => {
  const result = validateKnowledgeCandidate({
    content: 'A rule explicitly proposed for acquisition.',
    source: 'deterministic-test-adapter',
    origin: 'EXPLICIT_TEACHING',
    scope: 'PRIVATE',
    visibility: 'OWNER_ONLY',
  });

  if (result.outcome !== 'VALID') throw new Error(`expected VALID, got ${result.outcome}`);
});

Deno.test('P3D validation rejects empty content', () => {
  const result = validateKnowledgeCandidate({
    content: '   ',
    source: 'test',
    origin: 'EXPLICIT_TEACHING',
  });

  if (result.outcome !== 'INVALID') throw new Error(`expected INVALID, got ${result.outcome}`);
  if (result.reason !== 'CONTENT_REQUIRED') throw new Error(`unexpected reason: ${result.reason}`);
});

Deno.test('P3D validation does not silently promote general scope to shared visibility', () => {
  const result = validateKnowledgeCandidate({
    content: 'A general candidate requiring explicit sharing.',
    source: 'test',
    origin: 'EXPLICIT_TEACHING',
    scope: 'GENERAL',
    visibility: 'OWNER_ONLY',
  });

  if (result.outcome !== 'NEEDS_REVIEW') throw new Error(`expected NEEDS_REVIEW, got ${result.outcome}`);
});

Deno.test('P3D validation rejects out-of-range confidence', () => {
  const result = validateKnowledgeCandidate({
    content: 'candidate',
    source: 'test',
    origin: 'MEMORY',
    confidence: 1.1,
  });

  if (result.outcome !== 'INVALID') throw new Error(`expected INVALID, got ${result.outcome}`);
});
