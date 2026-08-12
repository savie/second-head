import { createMemoryDecisionSink, extractMemoryCandidate } from './memory_decision.ts';

Deno.test('P4A-003 ignores ordinary model output and does not create memory implicitly', async () => {
  let writes = 0;
  const sink = createMemoryDecisionSink(async () => { writes += 1; });
  await sink({ sh_id: 'sh-001', user_message: 'hello', response: { type: 'text', content: 'ok' } });
  if (writes !== 0) throw new Error('ordinary response must not become memory automatically');
});

Deno.test('P4A-003 accepts an explicit memory candidate with safe defaults', async () => {
  const seen: unknown[] = [];
  const sink = createMemoryDecisionSink(async (candidate) => { seen.push(candidate); });
  await sink({
    sh_id: 'sh-001',
    user_message: 'remember this',
    response: { memory_candidate: { content: 'User prefers concise replies' } },
  });
  const candidate = seen[0] as Record<string, unknown>;
  if (candidate.sh_id !== 'sh-001') throw new Error('SH identity changed');
  if (candidate.scope !== 'PRIVATE') throw new Error('default scope must be private');
  if (candidate.visibility !== 'OWNER_ONLY') throw new Error('default visibility must be owner-only');
  if (candidate.lifecycle !== 'CANDIDATE') throw new Error('default lifecycle must be candidate');
});

Deno.test('P4A-003 rejects malformed memory candidates', () => {
  if (extractMemoryCandidate({ memory_candidate: { content: '' } }) !== null) throw new Error('empty candidate must be rejected');
  if (extractMemoryCandidate({ memory_candidate: { content: 'x', confidence: 2 } }) !== null) throw new Error('invalid confidence must be rejected');
  if (extractMemoryCandidate({ memory_candidate: { content: 'x', scope: 'SYSTEM' } }) !== null) throw new Error('invalid scope must be rejected');
});
