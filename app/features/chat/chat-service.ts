import { invokeSHRuntime } from '../../services/runtime';
import type { RuntimeInvocationResponse } from '../../types/runtime';

export async function sendChatMessage(userMessage: string): Promise<RuntimeInvocationResponse> {
  return invokeSHRuntime({ userMessage });
}
