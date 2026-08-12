import { createRuntimeCoreLoop } from './runtime_core_loop.ts';

Deno.test('P4A-001 resolves existing SH identity and preserves it through model response', async () => {
  const calls: string[] = [];

  const runtime = createRuntimeCoreLoop({
    identityResolver: {
      async resolve(authUid) {
        calls.push(`identity:${authUid}`);
        return {
          account_id: 'account-1',
          sh_id: 'sh-001',
          ownership_role: 'owner',
        };
      },
    },
    contextAssembler: {
      async assemble({ identity, user_message }) {
        calls.push(`context:${identity.sh_id}`);
        return {
          identity,
          user_message,
          entries: [],
        };
      },
    },
    modelAdapter: {
      async generate(context) {
        calls.push(`model:${context.identity.sh_id}`);
        return { output: { type: 'text', content: 'ok' } };
      },
    },
    memoryDecision: {
      async decide({ identity }) {
        calls.push(`memory:${identity.sh_id}`);
      },
    },
  });

  const result = await runtime({
    auth_uid: 'auth-user-1',
    user_message: 'hello',
  });

  if (result.sh_id !== 'sh-001') throw new Error('SH identity changed');
  if (calls.join('|') !== 'identity:auth-user-1|context:sh-001|model:sh-001|memory:sh-001') {
    throw new Error(`unexpected runtime order: ${calls.join('|')}`);
  }
});

Deno.test('P4A-001 fails closed when identity cannot be resolved', async () => {
  const runtime = createRuntimeCoreLoop({
    identityResolver: { async resolve() { return null; } },
    contextAssembler: { async assemble() { throw new Error('must not run'); } },
    modelAdapter: { async generate() { throw new Error('must not run'); } },
    memoryDecision: { async decide() { throw new Error('must not run'); } },
  });

  await runtime({ auth_uid: 'unknown-user', user_message: 'hello' })
    .then(() => { throw new Error('runtime should reject unresolved identity'); })
    .catch((error) => {
      if (!String(error).includes('SH identity could not be resolved')) throw error;
    });
});

Deno.test('P4A-001 rejects unauthenticated runtime input before dependency calls', async () => {
  const runtime = createRuntimeCoreLoop({
    identityResolver: { async resolve() { throw new Error('must not run'); } },
    contextAssembler: { async assemble() { throw new Error('must not run'); } },
    modelAdapter: { async generate() { throw new Error('must not run'); } },
    memoryDecision: { async decide() { throw new Error('must not run'); } },
  });

  await runtime({ auth_uid: '', user_message: 'hello' })
    .then(() => { throw new Error('runtime should reject missing auth uid'); })
    .catch((error) => {
      if (!String(error).includes('authenticated identity is required')) throw error;
    });
});
