import { persistRuntimeAudit, type RuntimeAuditEvent, type RuntimeAuditSink } from './runtime_audit_persistence.ts';

function makeSink() {
  const events: RuntimeAuditEvent[] = [];
  const sink: RuntimeAuditSink = {
    async append(event) { events.push(event); },
  };
  return { sink, events };
}

test('persists a bounded runtime audit event', async () => {
  const { sink, events } = makeSink();
  await persistRuntimeAudit(sink, {
    sh_id: 'sh-test',
    account_id: 'acct-test',
    event_type: 'RUNTIME_RESPONSE',
    status: 'SUCCESS',
    metadata: { phase: 'P4A-004' },
  });

  expect(events).toHaveLength(1);
  expect(events[0].sh_id).toBe('sh-test');
  expect(events[0].event_type).toBe('RUNTIME_RESPONSE');
});

test('rejects audit persistence without resolved identity context', async () => {
  const { sink } = makeSink();
  await expect(persistRuntimeAudit(sink, {
    sh_id: '',
    account_id: 'acct-test',
    event_type: 'RUNTIME_REQUEST',
    status: 'REJECTED',
  })).rejects.toThrow('RUNTIME_AUDIT_REJECTED');
});

test('does not mutate the supplied metadata object', async () => {
  const { sink, events } = makeSink();
  const metadata = { phase: 'P4A-004' };
  await persistRuntimeAudit(sink, {
    sh_id: 'sh-test',
    account_id: 'acct-test',
    event_type: 'RUNTIME_REQUEST',
    status: 'SUCCESS',
    metadata,
  });

  expect(metadata).toEqual({ phase: 'P4A-004' });
  expect(events[0].metadata).toEqual({ phase: 'P4A-004' });
});
