import { createMemoryJourneySignalDetector } from './memory_journey_signal.ts';

Deno.test('P5A MEMORY producer adapts only a structured memory candidate', async () => {
  const detector = createMemoryJourneySignalDetector();

  const none = await detector.detect({
    sh_id: 'sh-001',
    user_message: 'I like concise replies',
    response: { type: 'text', content: 'ok' },
  });
  if (none.automatic_candidate) throw new Error('ordinary response must not become MEMORY Journey automatically');

  const signal = await detector.detect({
    sh_id: 'sh-001',
    user_message: 'remember this',
    response: {
      memory_candidate: {
        content: 'User prefers concise replies',
        memory_type: 'LONG_TERM',
        lifecycle: 'CANDIDATE',
        scope: 'PRIVATE',
        visibility: 'OWNER_ONLY',
      },
    },
  });

  const candidate = signal.automatic_candidate;
  if (!candidate) throw new Error('MEMORY Journey candidate was not produced');
  if (candidate.event_type !== 'MEMORY') throw new Error('wrong Journey event type');
  if (candidate.source_ref !== 'runtime:p4a:memory_candidate') throw new Error('wrong source reference');
  if (candidate.payload.scope !== 'PRIVATE') throw new Error('MEMORY signal changed scope');
  if (candidate.payload.visibility !== 'OWNER_ONLY') throw new Error('MEMORY signal changed visibility');
});
