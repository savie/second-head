import * as Linking from 'expo-linking';
import { backend } from './backend';

const FUNCTION_URL = `${process.env.EXPO_PUBLIC_SUPABASE_URL}/functions/v1/r4-google-oauth`;

export type GoogleConnection = {
  connection_id: string;
  provider: string;
  target_type: string;
  target_id: string;
  scopes: string[];
  status: 'CONNECTED' | 'REVOKED' | 'ERROR';
  connected_at: string | null;
  revoked_at: string | null;
  last_verified_at: string | null;
};

async function authHeaders() {
  const { data, error } = await backend.auth.getSession();
  if (error) throw error;
  if (!data.session) throw new Error('Authenticated session required');
  return { Authorization: `Bearer ${data.session.access_token}`, 'Content-Type': 'application/json' };
}

export async function startGoogleCalendarConnection() {
  const headers = await authHeaders();
  const response = await fetch(`${FUNCTION_URL}?action=start`, {
    method: 'POST',
    headers,
    body: '{}',
  });
  const body = await response.json().catch(() => ({}));
  if (!response.ok) throw new Error(body.error ?? 'Unable to start Google authorization');
  if (typeof body.authorization_url !== 'string') throw new Error('R4_GOOGLE_AUTH_URL_MISSING');
  await Linking.openURL(body.authorization_url);
}

export async function getGoogleCalendarConnection(): Promise<GoogleConnection | null> {
  const { data, error } = await backend.rpc('r4_google_connection_status');
  if (error) throw error;
  return Array.isArray(data) && data.length > 0 ? data[0] as GoogleConnection : null;
}

export async function disconnectGoogleCalendar() {
  const headers = await authHeaders();
  const response = await fetch(`${FUNCTION_URL}?action=disconnect`, {
    method: 'POST',
    headers,
    body: '{}',
  });
  const body = await response.json().catch(() => ({}));
  if (!response.ok) throw new Error(body.error ?? 'Unable to disconnect Google');
}
