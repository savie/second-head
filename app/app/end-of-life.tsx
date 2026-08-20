import { useState } from 'react';
import { ActivityIndicator, Button, ScrollView, Text } from 'react-native';
import { Redirect, router } from 'expo-router';
import { useAuth } from '../state/auth-context';
import { supabase } from '../services/supabase';

export default function EndOfLifeScreen() {
  const { session, context, logout } = useAuth();
  const current = context?.shInstances[0];
  const [busy, setBusy] = useState(false); const [notice, setNotice] = useState<string | null>(null); const [error, setError] = useState<string | null>(null);
  if (!session) return <Redirect href="/login" />; if (!context || !current) return <ActivityIndicator />;
  async function confirmEndOfLife() {
    setBusy(true); setNotice(null); setError(null);
    const { error: rpcError } = await supabase.rpc('runtime_end_of_life_sh', { p_sh_id: current.sh_id, p_reason: 'Owner confirmed End-of-Life from Second Head app' });
    if (rpcError) setError(`END_OF_LIFE_FAILED: ${rpcError.message}`);
    else { setNotice('End-of-Life completed. Account and SH are now deactivated.'); await logout(); router.replace('/login'); }
    setBusy(false);
  }
  return <ScrollView contentContainerStyle={{ padding: 24, gap: 14 }}>
    <Text style={{ fontSize: 28, fontWeight: '700' }}>End-of-Life</Text>
    <Text>Review the authenticated account and SH below. This action is terminal and cannot be undone from the app.</Text>
    <Text style={{ fontWeight: '600' }}>Account</Text><Text>{context.account.account_id}</Text>
    <Text style={{ fontWeight: '600' }}>SH</Text><Text>{current.sh_id}</Text>
    <Text style={{ fontWeight: '600' }}>Email</Text><Text>{context.account.email}</Text>
    <Text style={{ fontWeight: '600' }}>Current status</Text><Text>{context.account.status} / {current.status}</Text>
    <Text>After confirmation, the account and SH are deactivated and this login session ends.</Text>
    <Button title="No, cancel" disabled={busy} onPress={() => router.back()} />
    <Button title="Yes, End-of-Life" disabled={busy} onPress={() => void confirmEndOfLife()} />
    {busy ? <ActivityIndicator /> : null}{notice ? <Text>{notice}</Text> : null}{error ? <Text>{error}</Text> : null}
  </ScrollView>;
}
