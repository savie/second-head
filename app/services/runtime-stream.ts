import { supabase } from './supabase';

const RUNTIME_URL = `${process.env.EXPO_PUBLIC_SUPABASE_URL}/functions/v1/runtime-p4a-001`;
const CONVERSATION_URL = `${process.env.EXPO_PUBLIC_SUPABASE_URL}/functions/v1/runtime-p4a-005`;

type RuntimeStreamEvent =
  | { type: 'response'; sh_id: string; text: string }
  | { type: 'token'; text: string }
  | { type: 'confirmation'; confirmation_id: string; action_id: string; title: string; description: string }
  | { type: 'complete'; sh_id: string }
  | { type: 'error'; message: string };

export async function loadConversationHistory(limit = 50): Promise<string[]> {
  const { data, error } = await supabase.auth.getSession();
  if (error) throw error;
  const token = data.session?.access_token;
  if (!token) throw new Error('Authenticated session required for conversation history');

  const response = await fetch(`${CONVERSATION_URL}?limit=${encodeURIComponent(String(limit))}`, {
    method: 'GET',
    headers: { Authorization: `Bearer ${token}`, Accept: 'application/json' },
  });

  if (!response.ok) {
    throw new Error(`SH_CONVERSATION_HISTORY_FAILED: ${await response.text()}`);
  }

  const payload = (await response.json()) as {
    conversations?: Array<{ role: 'user' | 'assistant' | 'system'; content: string }>;
  };

  return (payload.conversations ?? []).map((row) => {
    if (row.role === 'user') return `You: ${row.content}`;
    if (row.role === 'assistant') return `SH: ${row.content}`;
    return `System: ${row.content}`;
  });
}

function parseSseText(text: string, onEvent: (event: RuntimeStreamEvent) => void) {
  const frames = text.split(/\r?\n\r?\n/);

  for (const frame of frames) {
    const lines = frame.split(/\r?\n/);
    const eventName = lines.find((line) => line.startsWith('event: '))?.slice(7).trim();
    const dataLine = lines.find((line) => line.startsWith('data: '))?.slice(6);
    if (!eventName || dataLine === undefined) continue;

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
  }
}

export async function streamSHRuntime(
  userMessage: string,
  onEvent: (event: RuntimeStreamEvent) => void,
  signal?: AbortSignal,
  options?: { explicitJourneyCapture?: boolean },
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
    body: JSON.stringify({
      user_message: message,
      stream: true,
      explicit_journey_capture: options?.explicitJourneyCapture === true,
    }),
    signal,
  });

  if (!response.ok) {
    throw new Error(`SH_RUNTIME_STREAM_FAILED: ${await response.text()}`);
  }

  // Some React Native Android fetch implementations expose no response.body
  // even though the request succeeded. Do not issue a second Runtime request:
  // the first request already persisted the turn. Instead, consume the same
  // response as text and parse the buffered SSE frames.
  if (!response.body) {
    parseSseText(await response.text(), onEvent);
    return;
  }

  const reader = response.body.getReader();
  const decoder = new TextDecoder();
  let buffer = '';

  const handleFrame = (frame: string) => {
    parseSseText(frame, onEvent);
  };

  while (true) {
    const { value, done } = await reader.read();
    buffer += decoder.decode(value ?? new Uint8Array(), { stream: !done });
    const frames = buffer.split(/\r?\n\r?\n/);
    buffer = frames.pop() ?? '';
    for (const frame of frames) handleFrame(frame);
    if (done) break;
  }

  if (buffer.trim()) handleFrame(buffer);
}
