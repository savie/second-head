import { createSemanticJourneySignalDetector } from './semantic_journey_signal.ts';

Deno.test('P5A semantic Journey detector accepts only structured journey_candidate', async () => {
  const detector = createSemanticJourneySignalDetector();
  const result = await detector.detect({
    sh_id: 'sh-001',
    user_message: 'ordinary prose',
    response: {
      semantic_signals: {
        journey_candidate: {
          event_type: 'LEARNING',
          payload: { representation: 'structured event' },
          source_ref: 'model:test',
        },
      },
    },
  });

  if (result.automatic_candidate?.event_type !== 'LEARNING') {
    throw new Error('structured Journey candidate was not adapted');
  }
});

Deno.test('P5A semantic Journey detector ignores ordinary prose', async () => {
  const detector = createSemanticJourneySignalDetector();
  const result = await detector.detect({
    sh_id: 'sh-001',
    user_message: 'this sounds important',
    response: 'this is an ordinary textual response',
  });

  if (result.automatic_candidate) {
    throw new Error('ordinary prose produced a Journey candidate');
  }
});
