import { useState } from 'react';
import { Button, ScrollView, Text, TextInput } from 'react-native';
import { Redirect } from 'expo-router';
import { useAuth } from '../state/auth-context';
import { createSuccessionRule } from '../features/inheritance/inheritance-service';

export default function SuccessionScreen() {
  const { session, context } = useAuth();
  const [sourceShId, setSourceShId] = useState(context?.shInstances[0]?.sh_id ?? '');
  const [successorAccountId, setSuccessorAccountId] = useState('');
  const [scopeJson, setScopeJson] = useState('{"memory_ids":[],"knowledge_ids":[],"experience_ids":[],"journey_event_ids":[]}');
  const [notice, setNotice] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);
  const input = { borderWidth: 1, borderRadius: 8, padding: 12, color: '#111827', borderColor: '#111827' };
  if (!session) return <Redirect href="/login" />;
  if (!context) return null;
  async function create() {
    setNotice(null); setError(null);
    try {
      const value = await createSuccessionRule({ sourceShId, successorAccountId, scope: JSON.parse(scopeJson) });
      setNotice(`Succession rule created: ${String((value as { succession_id?: string }).succession_id ?? value)}`);
    } catch (e) { setError(e instanceof Error ? e.message : 'Unable to create succession rule'); }
  }
  return <ScrollView contentContainerStyle={{ padding: 24, gap: 14 }}>
    <Text style={{ fontSize: 28, fontWeight: '700' }}>Succession</Text>
    <Text>Succession is a separate lifecycle process. Its successor settings are not the same as Inheritance.</Text>
    <Text style={{ fontWeight: '600' }}>Source SH ID</Text>
    <TextInput placeholder="Isi Source SH ID untuk Succession" placeholderTextColor="#6B7280" value={sourceShId} onChangeText={setSourceShId} style={input} />
    <Text style={{ fontWeight: '600' }}>Successor Account ID</Text>
    <TextInput placeholder="Isi Account ID penerus" placeholderTextColor="#6B7280" value={successorAccountId} onChangeText={setSuccessorAccountId} style={input} />
    <Text style={{ fontWeight: '600' }}>Succession scope</Text>
    <TextInput multiline placeholder="Isi scope JSON Succession" placeholderTextColor="#6B7280" value={scopeJson} onChangeText={setScopeJson} style={{ ...input, minHeight: 100, textAlignVertical: 'top' }} />
    <Button title="Create succession rule" disabled={!sourceShId.trim() || !successorAccountId.trim()} onPress={() => void create()} />
    {notice ? <Text>{notice}</Text> : null}{error ? <Text>{error}</Text> : null}
  </ScrollView>;
}
