import { createJourneyRuntimeDecisionSink, decideJourney, type JourneyCandidate } from './journey_decision.ts';

const candidate: JourneyCandidate = {
  event_type: 'EXPERIENCE',
  payload: { summary: 'significant event' },
  source_ref: 'runtime:p4a',
};

Deno.test('P5A Journey decision records explicit intent', () => {
  const decision = decideJourney({
    sh_id: 'sh-001',
    user_message: 'ini masuk Journey',
    response: { type: 'text', content: 'ok' },
    explicit_intent: { requested: true, candidate },
  });

  if (!decision.record || decision.reason !== 'EXPLICIT') {
    throw new Error('explicit Journey intent was not selected');
  }
});

Deno.test('P5A Journey decision records automatic candidate when no explicit intent exists', () => {
  const decision = decideJourney({
    sh_id: 'sh-001',
    user_message: 'hari ini terjadi sesuatu penting',
    response: { type: 'text', content: 'ok' },
    automatic_candidate: candidate,
  });

  if (!decision.record || decision.reason !== 'AUTOMATIC') {
    throw new Error('automatic Journey candidate was not selected');
  }
});

Deno.test('P5A explicit intent wins when automatic and explicit candidates coexist', () => {
  const automatic: JourneyCandidate = { ...candidate, event_type: 'MEMORY' };
  const decision = decideJourney({
    sh_id: 'sh-001',
    user_message: 'jadikan ini perjalanan',
    response: { type: 'text', content: 'ok' },
    automatic_candidate: automatic,
    explicit_intent: { requested: true, candidate },
  });

  if (!decision.record || decision.reason !== 'EXPLICIT' || decision.candidate?.event_type !== 'EXPERIENCE') {
    throw new Error('explicit Journey intent did not take precedence');
  }
});

Deno.test('P5A Journey decision does not invent an event for an explicit request without a candidate', () => {
  const decision = decideJourney({
    sh_id: 'sh-001',
    user_message: 'ini masuk Journey',
    response: { type: 'text', content: 'ok' },
    explicit_intent: { requested: true },
  });

  if (decision.record || decision.reason !== 'NONE') {
    throw new Error('Journey decision invented an event without a candidate');
  }
});

Deno.test('P5A Journey runtime sink records selected candidate through recorder', async () => {
  const calls: string[] = [];
  const sink = createJourneyRuntimeDecisionSink(
    {
      async detect() {
        calls.push('detect');
        return { automatic_candidate: candidate };
      },
    },
    {
      async record(input) {
        calls.push(`record:${input.sh_id}:${input.event_type}`);
        return 'event-001';
      },
    },
  );

  const decision = await sink.decideAndRecord({
    sh_id: 'sh-001',
    user_message: 'important day',
    response: { type: 'text', content: 'ok' },
  });

  if (!decision.record || calls.join('|') !== 'detect|record:sh-001:EXPERIENCE') {
    throw new Error(`unexpected Journey decision flow: ${calls.join('|')}`);
  }
});

Deno.test('P5A runtime sink accepts explicit intent without detector inference', async () => {
  const calls: string[] = [];
  const sink = createJourneyRuntimeDecisionSink(
    {
      async detect() {
        calls.push('detect');
        return {};
      },
    },
    {
      async record(input) {
        calls.push(`record:${input.sh_id}:${input.event_type}`);
        return 'event-002';
      },
    },
  );

  const decision = await sink.decideAndRecord({
    sh_id: 'sh-001',
    user_message: 'save this',
    response: { type: 'text', content: 'ok' },
    explicit_intent: { requested: true, candidate },
  });

  if (!decision.record || decision.reason !== 'EXPLICIT' || calls.join('|') !== 'detect|record:sh-001:EXPERIENCE') {
    throw new Error(`explicit Journey capture failed: ${calls.join('|')}`);
  }
});
