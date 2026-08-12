import { resolveRuntimeIdentityAndState } from './identity_state_resolution.ts';

Deno.test('P4A-002 resolves existing identity into request-scoped runtime state', async () => {
  const result = await resolveRuntimeIdentityAndState(
    {
      async resolve(authUid) {
        if (authUid !== 'auth-user-1') throw new Error('unexpected auth uid');
        return {
          account_id: 'account-1',
          sh_id: 'sh-001',
          ownership_role: 'owner',
        };
      },
    },
    'auth-user-1',
  );

  if (result.identity.sh_id !== 'sh-001') throw new Error('SH identity changed');
  if (result.state.status !== 'RESOLVED') throw new Error('runtime state not resolved');
  if (result.state.sh_id !== 'sh-001') throw new Error('state SH identity mismatch');
  if (result.state.account_id !== 'account-1') throw new Error('state account mismatch');
});

Deno.test('P4A-002 fails closed for missing authentication', async () => {
  await resolveRuntimeIdentityAndState(
    { async resolve() { throw new Error('must not run'); } },
    '',
  )
    .then(() => { throw new Error('runtime should reject missing auth uid'); })
    .catch((error) => {
      if (!String(error).includes('authenticated identity is required')) throw error;
    });
});

Deno.test('P4A-002 fails closed when no existing SH identity is resolved', async () => {
  await resolveRuntimeIdentityAndState(
    { async resolve() { return null; } },
    'unknown-user',
  )
    .then(() => { throw new Error('runtime should reject unresolved identity'); })
    .catch((error) => {
      if (!String(error).includes('SH identity could not be resolved')) throw error;
    });
});
