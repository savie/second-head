import { useCallback, useEffect, useState } from 'react';
import { ActivityIndicator, Button, ScrollView, Text, TextInput, View } from 'react-native';
import { Redirect } from 'expo-router';
import { useAuth } from '../state/auth-context';
import { approveInheritance, createInheritanceAuthorization, listInheritanceAuthorizations, recordInheritance, type InheritanceAuthorization, type TransferSelection } from '../features/inheritance/inheritance-service';

export default function InheritanceScreen() {
  const { session, context } = useAuth();
  const [sourceShId, setSourceShId] = useState(''); const [targetShId, setTargetShId] = useState('');
  const [sourceAccountId, setSourceAccountId] = useState(''); const [targetAccountId, setTargetAccountId] = useState(context?.account.account_id ?? '');
  const [scopeJson, setScopeJson] = useState('{"memory_ids":[],"knowledge_ids":[],"experience_ids":[],"journey_event_ids":[]}');
  const [items, setItems] = useState<InheritanceAuthorization[]>([]); const [loading, setLoading] = useState(true); const [busy, setBusy] = useState(false); const [notice, setNotice] = useState<string | null>(null); const [error, setError] = useState<string | null>(null);
  const currentAccountId = context?.account.account_id ?? '';
  const refresh = useCallback(async () => { setLoading(true); setError(null); try { setItems(await listInheritanceAuthorizations()); } catch (e) { setError(e instanceof Error ? e.message : 'Unable to load inheritance authorizations'); } finally { setLoading(false); } }, []);
  useEffect(() => { if (context) void refresh(); }, [context, refresh]);
  if (!session) return <Redirect href="/login" />; if (!context) return <ActivityIndicator />;
  async function create() { setBusy(true); setError(null); setNotice(null); try { const v = await createInheritanceAuthorization({ sourceShId, targetShId, sourceAccountId, targetAccountId, scope: JSON.parse(scopeJson) as TransferSelection }); setNotice(`Authorization created: ${String((v as InheritanceAuthorization).authorization_id)}`); await refresh(); } catch (e) { setError(e instanceof Error ? e.message : 'Unable to create inheritance authorization'); } finally { setBusy(false); } }
  async function approve(id: string) { setBusy(true); setError(null); try { await approveInheritance(id); setNotice(`Inheritance approved: ${id}`); await refresh(); } catch (e) { setError(e instanceof Error ? e.message : 'Unable to approve inheritance'); } finally { setBusy(false); } }
  async function execute(id: string) { setBusy(true); setError(null); try { await recordInheritance(id); setNotice(`Inheritance executed: ${id}`); await refresh(); } catch (e) { setError(e instanceof Error ? e.message : 'Unable to execute inheritance'); } finally { setBusy(false); } }
  const input = { borderWidth: 1, borderRadius: 8, padding: 12, color: '#111827', borderColor: '#111827' };
  return <ScrollView contentContainerStyle={{ padding: 24, gap: 14 }}>
    <Text style={{ fontSize: 28, fontWeight: '700' }}>Inheritance</Text><Text>Configure an explicit inheritance transfer. Succession and Legacy are separate lifecycle processes.</Text>
    <Text style={{ fontWeight: '600' }}>Source SH ID</Text><TextInput placeholder="Isi Source SH ID yang akan ditransfer" placeholderTextColor="#6B7280" value={sourceShId} onChangeText={setSourceShId} style={input} />
    <Text style={{ fontWeight: '600' }}>Target SH ID</Text><TextInput placeholder="Isi Target SH ID penerima" placeholderTextColor="#6B7280" value={targetShId} onChangeText={setTargetShId} style={input} />
    <Text style={{ fontWeight: '600' }}>Source Account ID</Text><TextInput placeholder="Isi Account ID pemilik Source SH" placeholderTextColor="#6B7280" value={sourceAccountId} onChangeText={setSourceAccountId} style={input} />
    <Text style={{ fontWeight: '600' }}>Target Account ID</Text><TextInput placeholder="Isi Account ID penerima" placeholderTextColor="#6B7280" value={targetAccountId} onChangeText={setTargetAccountId} style={input} />
    <Text style={{ fontWeight: '600' }}>Selected transfer scope</Text><TextInput multiline placeholder="Isi scope JSON: memory_ids, knowledge_ids, experience_ids, journey_event_ids" placeholderTextColor="#6B7280" value={scopeJson} onChangeText={setScopeJson} style={{ ...input, minHeight: 100, textAlignVertical: 'top' }} />
    <Button title="Create inheritance authorization" disabled={busy || !sourceShId || !targetShId || !sourceAccountId || !targetAccountId} onPress={() => void create()} />
    {loading ? <ActivityIndicator /> : null}{notice ? <Text>{notice}</Text> : null}{error ? <Text>{error}</Text> : null}
    {items.map(item => <View key={item.authorization_id} style={{ borderWidth: 1, padding: 12, borderRadius: 8, gap: 6 }}><Text>Authorization: {item.authorization_id}</Text><Text>Status: {item.status}</Text><Text>Scope: {JSON.stringify(item.scope)}</Text>{item.status === 'PENDING' && item.source_account_id === currentAccountId ? <Button title="Approve" disabled={busy} onPress={() => void approve(item.authorization_id)} /> : null}{item.status === 'APPROVED' && item.source_account_id === currentAccountId ? <Button title="Execute inheritance" disabled={busy} onPress={() => void execute(item.authorization_id)} /> : null}</View>)}
    <Button title="Refresh" disabled={busy} onPress={() => void refresh()} />
  </ScrollView>;
}
