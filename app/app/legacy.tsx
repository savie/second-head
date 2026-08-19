import { useState } from 'react';
import { Button, ScrollView, Text, TextInput } from 'react-native';
import { Redirect } from 'expo-router';
import { useAuth } from '../state/auth-context';
import { preserveSelectedTransferAsLegacy, recordLegacy, type LegacyRecord } from '../features/inheritance/inheritance-service';

export default function LegacyScreen() {
  const { session } = useAuth();
  const [sourceShId, setSourceShId] = useState('');
  const [legacyType, setLegacyType] = useState<LegacyRecord['legacy_type']>('HISTORY');
  const [scopeJson, setScopeJson] = useState('{"memory_ids":[],"knowledge_ids":[],"experience_ids":[],"journey_event_ids":[]}');
  const [notice, setNotice] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);
  if (!session) return <Redirect href="/login" />;
  const input = { borderWidth: 1, borderRadius: 8, padding: 12, color: '#111827', borderColor: '#111827' };
  async function preserve() { setNotice(null); setError(null); try { const v = await preserveSelectedTransferAsLegacy({ sourceShId, scope: JSON.parse(scopeJson) }); setNotice(`Legacy preserved: ${String(v)}`); } catch (e) { setError(e instanceof Error ? e.message : 'Unable to preserve Legacy'); } }
  async function record() { setNotice(null); setError(null); try { const v = await recordLegacy({ sourceShId, legacyType }); setNotice(`Legacy recorded: ${String(v)}`); } catch (e) { setError(e instanceof Error ? e.message : 'Unable to record Legacy'); } }
  return <ScrollView contentContainerStyle={{ padding: 24, gap: 14 }}>
    <Text style={{ fontSize: 28, fontWeight: '700' }}>Legacy</Text>
    <Text>Legacy preserves selected lifecycle history. Results are recorded in Journey.</Text>
    <Text style={{ fontWeight: '600' }}>Source SH ID</Text><TextInput placeholder="Isi Source SH ID untuk Legacy" placeholderTextColor="#6B7280" value={sourceShId} onChangeText={setSourceShId} style={input} />
    <Text style={{ fontWeight: '600' }}>Legacy type</Text><TextInput placeholder="Isi tipe Legacy, misalnya HISTORY" placeholderTextColor="#6B7280" value={legacyType} onChangeText={v => setLegacyType(v.toUpperCase() as LegacyRecord['legacy_type'])} style={input} />
    <Text style={{ fontWeight: '600' }}>Selected scope</Text><TextInput multiline placeholder="Isi scope JSON Legacy" placeholderTextColor="#6B7280" value={scopeJson} onChangeText={setScopeJson} style={{ ...input, minHeight: 100, textAlignVertical: 'top' }} />
    <Button title="Preserve selected transfer as Legacy" disabled={!sourceShId.trim()} onPress={() => void preserve()} />
    <Button title="Record Legacy type" disabled={!sourceShId.trim() || !legacyType} onPress={() => void record()} />
    {notice ? <Text>{notice}</Text> : null}{error ? <Text>{error}</Text> : null}
  </ScrollView>;
}
