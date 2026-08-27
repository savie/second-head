import { supabase } from './supabase';

const RUNTIME_URL = `${process.env.EXPO_PUBLIC_SUPABASE_URL}/functions/v1/runtime-p4a-001`;
const CONVERSATION_URL = `${process.env.EXPO_PUBLIC_SUPABASE_URL}/functions/v1/runtime-p4a-005`;

const authHeaders = (token: string) => ({
  apikey: process.env.EXPO_PUBLIC_SUPABASE_ANON_KEY ?? '',
  Authorization: `Bearer ${token}`,
});

type RuntimeStreamEvent =
  | { type: 'response'; sh_id: string; text: string }
  | { type: 'token'; text: string }
  | { type: 'confirmation'; confirmation_id: string; action_id: string; title: string; description: string }
  | { type: 'complete'; sh_id: string }
  | { type: 'error'; message: string };

export type ConversationHistoryRow = {
  conversation_id: string;
  sh_id: string;
  role: 'user' | 'assistant' | 'system';
  content: string;
  created_at: string;
  metadata?: Record<string, unknown> | null;
};

export async function loadConversationHistoryRows(limit = 100): Promise<ConversationHistoryRow[]> {
  const { data, error } = await supabase.auth.getSession();
  if (error) throw error;
  const token = data.session?.access_token;
  if (!token) throw new Error('Authenticated session required for conversation history');
  const response = await fetch(CONVERSATION_URL + '?limit=' + encodeURIComponent(String(limit)), {
    method: 'GET',
    headers: { ...authHeaders(token), Accept: 'application/json' },
  });
  if (!response.ok) throw new Error('SH_CONVERSATION_HISTORY_FAILED: ' + await response.text());
  const payload = (await response.json()) as { conversations?: ConversationHistoryRow[] };
  return (payload.conversations ?? []).slice().sort((a, b) => {
    const time = Date.parse(a.created_at) - Date.parse(b.created_at);
    return time || a.conversation_id.localeCompare(b.conversation_id);
  });
}

export async function loadConversationHistory(limit = 100): Promise<string[]> {
  const rows = await loadConversationHistoryRows(limit);
  return rows.map(row => row.role === 'user' ? 'You: ' + row.content : row.role === 'assistant' ? 'SH: ' + row.content : 'System: ' + row.content);
}
function parseSseText(text: string, onEvent: (event: RuntimeStreamEvent) => void) { for (const frame of text.split(/\r?\n\r?\n/)) { const lines = frame.split(/\r?\n/); const eventName = lines.find(line => line.startsWith('event: '))?.slice(7).trim(); const dataLine = lines.find(line => line.startsWith('data: '))?.slice(6); if (!eventName || dataLine === undefined) continue; const payload = JSON.parse(dataLine) as Record<string, unknown>; if (eventName === 'response') onEvent({ type: 'response', sh_id: String(payload.sh_id ?? ''), text: String(payload.text ?? '') }); else if (eventName === 'token') onEvent({ type: 'token', text: String(payload.text ?? '') }); else if (eventName === 'confirmation') onEvent({ type: 'confirmation', confirmation_id: String(payload.confirmation_id ?? ''), action_id: String(payload.action_id ?? ''), title: String(payload.title ?? 'Confirmation required'), description: String(payload.description ?? 'This action requires your explicit confirmation.') }); else if (eventName === 'complete') onEvent({ type: 'complete', sh_id: String(payload.sh_id ?? '') }); } }
async function getAccessToken() {
  const { data, error } = await supabase.auth.getSession();
  if (error) throw error;
  if (!data.session?.access_token) throw new Error('Authenticated session required for runtime access');
  const { data: userData, error: userError } = await supabase.auth.getUser();
  if (!userError && userData.user) return data.session.access_token;
  const { data: refreshed, error: refreshError } = await supabase.auth.refreshSession();
  if (refreshError || !refreshed.session?.access_token) throw new Error('Authenticated session could not be refreshed for runtime access');
  return refreshed.session.access_token;
}

export async function captureJourneyEvent(representation: string, scope: 'PRIVATE' | 'GENERAL' = 'PRIVATE', visibility: 'OWNER_ONLY' | 'SHARED' = 'OWNER_ONLY'): Promise<void> {
  const value = representation.trim(); if (!value) throw new Error('Journey capture requires a non-empty representation');
  const token = await getAccessToken();
  const response = await fetch(RUNTIME_URL, { method: 'POST', headers: { ...authHeaders(token), 'Content-Type': 'application/json', Accept: 'application/json' }, body: JSON.stringify({ journey_only: true, explicit_journey_capture: true, journey_representation: value }) });
  if (!response.ok) throw new Error(`SH_JOURNEY_CAPTURE_FAILED: ${await response.text()}`);
  const payload = (await response.json()) as { experience_id?: string };
  if (!payload.experience_id) throw new Error('SH_JOURNEY_CAPTURE_FAILED: Experience id was not returned');
  const { error } = await supabase.rpc('runtime_classify_experience', { p_experience_id: payload.experience_id, p_scope: scope, p_visibility: visibility });
  if (error) throw new Error(`EXPERIENCE_CLASSIFICATION_FAILED: ${error.message}`);
}

export async function streamSHRuntime(userMessage: string, onEvent: (event: RuntimeStreamEvent) => void, signal?: AbortSignal): Promise<void> {
  const message = userMessage.trim(); if (!message) throw new Error('Runtime request requires a non-empty user message'); const token = await getAccessToken();
  const response = await fetch(RUNTIME_URL, { method: 'POST', headers: { ...authHeaders(token), 'Content-Type': 'application/json', Accept: 'text/event-stream' }, body: JSON.stringify({ user_message: message, stream: true }), signal });
  if (!response.ok) throw new Error(`SH_RUNTIME_STREAM_FAILED: ${await response.text()}`);
  if (!response.body) { parseSseText(await response.text(), onEvent); return; }
  const reader = response.body.getReader(); const decoder = new TextDecoder(); let buffer = '';
  const handleFrame = (frame: string) => parseSseText(frame, onEvent);
  while (true) { const { value, done } = await reader.read(); buffer += decoder.decode(value ?? new Uint8Array(), { stream: !done }); const frames = buffer.split(/\r?\n\r?\n/); buffer = frames.pop() ?? ''; for (const frame of frames) handleFrame(frame); if (done) break; }
  if (buffer.trim()) handleFrame(buffer);
}


async function rpc<T = unknown>(fn: string, args: Record<string, unknown>): Promise<T> {
  const { data, error } = await supabase.rpc(fn, args);
  if (error) throw error;
  return data as T;
}

export async function updateConversationMessage(row: ConversationHistoryRow, newContent: string): Promise<void> {
  await rpc('runtime_update_conversation_message', {
    p_conversation_id: row.conversation_id,
    p_created_at: row.created_at,
    p_role: row.role,
    p_old_content: row.content,
    p_new_content: newContent,
  });
}

export async function deleteConversationMessage(row: ConversationHistoryRow): Promise<void> {
  await rpc('runtime_delete_conversation_message', {
    p_conversation_id: row.conversation_id,
    p_created_at: row.created_at,
    p_role: row.role,
    p_content: row.content,
  });
}

export async function deleteConversation(conversationId: string): Promise<void> {
  await rpc('runtime_delete_conversation', { p_conversation_id: conversationId });
}

export async function renameConversation(conversationId: string, title: string): Promise<void> {
  await rpc('runtime_rename_conversation', { p_conversation_id: conversationId, p_title: title });
}
