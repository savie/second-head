import { supabase } from './backend';
import type { RuntimeInvocationInput, RuntimeInvocationResponse } from '../types/runtime';

const RUNTIME_FUNCTION = 'runtime-p4a-001';

export async function invokeSHRuntime(input: RuntimeInvocationInput): Promise<RuntimeInvocationResponse> {
  const userMessage = input.userMessage.trim();
  if (!userMessage) throw new Error('Runtime request requires a non-empty user message');

  const { data: sessionData, error: sessionError } = await backend.auth.getSession();
  if (sessionError) throw sessionError;
  if (!sessionData.session) throw new Error('Authenticated session required for runtime invocation');

  const { data, error } = await backend.functions.invoke(RUNTIME_FUNCTION, {
    body: { user_message: userMessage },
    headers: { Authorization: `Bearer ${sessionData.session.access_token}` },
  });

  if (error) throw new Error(`SH_RUNTIME_INVOCATION_FAILED: ${error.message}`);
  if (!data || typeof data !== 'object') throw new Error('SH_RUNTIME_INVALID_RESPONSE');

  const response = data as Partial<RuntimeInvocationResponse>;
  if (typeof response.sh_id !== 'string' || typeof response.response !== 'string') {
    throw new Error('SH_RUNTIME_INVALID_RESPONSE');
  }

  return response as RuntimeInvocationResponse;
}
