import { useCallback, useEffect, useState } from 'react';
import { ActivityIndicator, Button, ScrollView, Text, View } from 'react-native';
import * as Linking from 'expo-linking';
import { Redirect } from 'expo-router';
import { useAuth } from '../state/auth-context';
import { listInheritanceAuthorizations, type InheritanceAuthorization } from '../features/inheritance/inheritance-service';
import {
  disconnectGoogleCalendar,
  getGoogleCalendarConnection,
  startGoogleCalendarConnection,
  type GoogleConnection,
} from '../services/google-authorization';

export default function AuthorizationScreen() {
  const { session, context } = useAuth();
  const [items, setItems] = useState<InheritanceAuthorization[]>([]);
  const [google, setGoogle] = useState<GoogleConnection | null>(null);
  const [loading, setLoading] = useState(true);
  const [googleBusy, setGoogleBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [googleMessage, setGoogleMessage] = useState<string | null>(null);

  const refresh = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const [inheritance, connection] = await Promise.all([
        listInheritanceAuthorizations(),
        getGoogleCalendarConnection(),
      ]);
      setItems(inheritance);
      setGoogle(connection);
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Unable to load authorization status');
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    if (context) void refresh();
  }, [context, refresh]);

  useEffect(() => {
    const handleUrl = (event: { url: string }) => {
      const parsed = Linking.parse(event.url);
      if (parsed.queryParams?.provider === 'google') {
        const status = String(parsed.queryParams?.status ?? '');
        setGoogleMessage(
          status === 'connected'
            ? 'Google Calendar connected.'
            : `Google authorization did not complete: ${String(parsed.queryParams?.code ?? 'unknown error')}`,
        );
        void refresh();
      }
    };
    const subscription = Linking.addEventListener('url', handleUrl);
    void Linking.getInitialURL().then((url) => {
      if (url) handleUrl({ url });
    });
    return () => subscription.remove();
  }, [refresh]);

  async function connectGoogle() {
    setGoogleBusy(true);
    setGoogleMessage(null);
    try {
      await startGoogleCalendarConnection();
      setGoogleMessage('Google authorization opened. Complete the Google consent screen, then return to SH.');
    } catch (e) {
      setGoogleMessage(e instanceof Error ? e.message : 'Unable to start Google authorization');
    } finally {
      setGoogleBusy(false);
    }
  }

  async function disconnectGoogle() {
    setGoogleBusy(true);
    setGoogleMessage(null);
    try {
      await disconnectGoogleCalendar();
      setGoogleMessage('Google Calendar disconnected. R4 can no longer use the stored authorization.');
      await refresh();
    } catch (e) {
      setGoogleMessage(e instanceof Error ? e.message : 'Unable to disconnect Google');
    } finally {
      setGoogleBusy(false);
    }
  }

  if (!session) return <Redirect href="/login" />;

  return <ScrollView contentContainerStyle={{ padding: 24, gap: 14 }}>
    <Text style={{ fontSize: 28, fontWeight: '700' }}>Authorization</Text>
    <Text>Authorization is the permission/status surface. Transfer configuration and execution remain in Lifecycle → Inheritance.</Text>
    <Text>Current account: {context?.account.account_id ?? '—'}</Text>

    <View style={{ borderWidth: 1, padding: 14, borderRadius: 10, gap: 8 }}>
      <Text style={{ fontSize: 20, fontWeight: '700' }}>Google Calendar · R4</Text>
      <Text>Target: your primary Google Calendar. Connecting does not create or change any calendar event.</Text>
      <Text>Status: {google?.status ?? 'NOT_CONNECTED'}</Text>
      {google?.status === 'CONNECTED' ? (
        <>
          <Text>Scope: {google.scopes.join(', ')}</Text>
          <Button title={googleBusy ? 'Working…' : 'Disconnect Google'} disabled={googleBusy} onPress={() => void disconnectGoogle()} />
        </>
      ) : (
        <Button title={googleBusy ? 'Opening Google…' : 'Connect Google Calendar'} disabled={googleBusy} onPress={() => void connectGoogle()} />
      )}
      {googleMessage ? <Text>{googleMessage}</Text> : null}
    </View>

    {loading ? <ActivityIndicator /> : null}
    {error ? <Text>{error}</Text> : null}
    {!loading && items.length === 0 ? <Text>No inheritance authorization records are currently available.</Text> : null}
    {items.map(item => <View key={item.authorization_id} style={{ borderWidth: 1, padding: 12, borderRadius: 8, gap: 6 }}>
      <Text>Authorization: {item.authorization_id}</Text>
      <Text>Status: {item.status}</Text>
      <Text>Source account: {item.source_account_id}</Text>
      <Text>Target account: {item.target_account_id}</Text>
      <Text>Scope: {JSON.stringify(item.scope)}</Text>
    </View>)}
    <Button title="Refresh authorization status" onPress={() => void refresh()} />
  </ScrollView>;
}
