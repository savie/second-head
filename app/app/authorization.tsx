import { useCallback, useEffect, useState } from 'react';
import { ActivityIndicator, Button, ScrollView, Text, View } from 'react-native';
import { Redirect } from 'expo-router';
import { useAuth } from '../state/auth-context';
import { listInheritanceAuthorizations, type InheritanceAuthorization } from '../features/inheritance/inheritance-service';

export default function AuthorizationScreen() {
  const { session, context } = useAuth();
  const [items, setItems] = useState<InheritanceAuthorization[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const refresh = useCallback(async () => { setLoading(true); setError(null); try { setItems(await listInheritanceAuthorizations()); } catch (e) { setError(e instanceof Error ? e.message : 'Unable to load authorization status'); } finally { setLoading(false); } }, []);
  useEffect(() => { if (context) void refresh(); }, [context, refresh]);
  if (!session) return <Redirect href="/login" />;
  return <ScrollView contentContainerStyle={{ padding: 24, gap: 14 }}>
    <Text style={{ fontSize: 28, fontWeight: '700' }}>Authorization</Text>
    <Text>Authorization is the permission/status surface. Transfer configuration and execution remain in Lifecycle → Inheritance.</Text>
    <Text>Current account: {context?.account.account_id ?? '—'}</Text>
    {loading ? <ActivityIndicator /> : null}
    {error ? <Text>{error}</Text> : null}
    {!loading && items.length === 0 ? <Text>No authorization records are currently available.</Text> : null}
    {items.map(item => <View key={item.authorization_id} style={{ borderWidth: 1, padding: 12, borderRadius: 8, gap: 6 }}><Text>Authorization: {item.authorization_id}</Text><Text>Status: {item.status}</Text><Text>Source account: {item.source_account_id}</Text><Text>Target account: {item.target_account_id}</Text><Text>Scope: {JSON.stringify(item.scope)}</Text></View>)}
    <Button title="Refresh authorization status" onPress={() => void refresh()} />
  </ScrollView>;
}
