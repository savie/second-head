import { supabase } from './supabase';

const RUNTIME_URL = `${process.env.EXPO_PUBLIC_SUPABASE_URL}/functions/v1/runtime-p4a-001`;

type RuntimeStreamEvent =
  | { type: 'response'; sh_id: string; text: string }
  | { type: 'token'; text: string }
  | { type: 'confirmation'; confirmation_id: string; action_id: string; title: string; description: string }
  | { type: 'complete'; sh_id: string }
  | { type: 'error'; message: string };

export async function streamSHRuntime(
  userMessage: string,
  onEvent: (event: RuntimeStreamEvent) => void,
): Promise<void> {
  const message = userMessage.trim();
  if (!message) throw new Error('Runtime request requires a non-empty user message');

  const { data, error } = await supabase.auth.getSession();
  if (error) throw error;
  const token = data.session?.access_token;
  if (!token) throw new Error('Authenticated session required for runtime streaming');

  const response = await fetch(RUNTIME_URL, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${token}`,
      'Content-Type': 'application/json',
      Accept: 'text/event-stream',
    },
    body: JSON.stringify({ user_message: message, stream: true }),
  });

  if (!response.ok) {
    throw new Error(`SH_RUNTIME_STREAM_FAILED: ${await response.text()}`);
  }
  if (!response.body) throw new Error('SH_RUNTIME_STREAM_UNAVAILABLE');

  const reader = response.body.getReader();
  const decoder = new TextDecoder();
  let buffer = '';

  const handleFrame = (frame: string) => {
    const lines = frame.split('\n');
    const eventName = lines.find((line) => line.startsWith('event: '))?.slice(7).trim();
    const dataLine = lines.find((line) => line.startsWith('data: '))?.slice(6);
    if (!eventName || dataLine === undefined) return;
    const payload = JSON.parse(dataLine) as Record<string, unknown>;

    if (eventName === 'response') {
      onEvent({ type: 'response', sh_id: String(payload.sh_id ?? ''), text: String(payload.text ?? '') });
    } else if (eventName === 'token') {
      onEvent({ type: 'token', text: String(payload.text ?? '') });
    } else if (eventName === 'confirmation') {
      onEvent({
        type: 'confirmation',
        confirmation_id: String(payload.confirmation_id ?? ''),
        action_id: String(payload.action_id ?? ''),
        title: String(payload.title ?? 'Confirmation required'),
        description: String(payload.description ?? 'This action requires your explicit confirmation.'),
      });
    } else if (eventName === 'complete') {
      onEvent({ type: 'complete', sh_id: String(payload.sh_id ?? '') });
    }
  };

  while (true) {
    const { value, done } = await reader.read();
    buffer += decoder.decode(value ?? new Uint8Array(), { stream: !done });
    const frames = buffer.split('\n\n');
    buffer = frames.pop() ?? '';
    for (const frame of frames) handleFrame(frame);
    if (done) break;
  }

  if (buffer.trim()) handleFrame(buffer);
}
