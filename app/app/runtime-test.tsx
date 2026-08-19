import { useState } from 'react';
import * as Clipboard from 'expo-clipboard';
import { ActivityIndicator, Alert, Button, ScrollView, Text, TextInput, View } from 'react-native';
import { Redirect } from 'expo-router';
import { useAuth } from '../state/auth-context';
import { invokeSHRuntime } from '../services/runtime';
import { loadSHContext, type ContextResult } from '../services/context';

export default function RuntimeTestScreen() {
  const { session, context, loading } = useAuth();
  const [message, setMessage] = useState('SH runtime verification');
  const [query, setQuery] = useState('');
  const [busy, setBusy] = useState(false);
  const [contextBusy, setContextBusy] = useState(false);
  const [result, setResult] = useState<string | null>(null);
  const [contextResult, setContextResult] = useState<ContextResult | null>(null);
  const [contextError, setContextError] = useState<string | null>(null);

  if (loading) return <View style={{ flex: 1, alignItems: 'center', justifyContent: 'center' }}><ActivityIndicator /></View>;
  if (!session) return <Redirect href="/login" />;

  async function copy(text: string, label: string) {
    await Clipboard.setStringAsync(text);
    Alert.alert('Copied', `${label} is ready to paste into ChatGPT.`);
  }

  async function verify() {
    setBusy(true); setResult(null);
    try { setResult(JSON.stringify(await invokeSHRuntime({ userMessage: message }), null, 2)); }
    catch (error) { setResult(error instanceof Error ? error.message : 'Runtime verification failed'); }
    finally { setBusy(false); }
  }

  async function loadContext() {
    const sh = context?.shInstances.find((item) => item.is_primary) ?? context?.shInstances[0];
    if (!sh) { setContextError('No authorized SH instance is available.'); return; }
    setContextBusy(true); setContextError(null);
    try { setContextResult(await loadSHContext({ shId: sh.sh_id, query })); }
    catch (error) { setContextError(error instanceof Error ? error.message : 'Context retrieval failed'); }
    finally { setContextBusy(false); }
  }

  const inputStyle = { borderWidth: 1, borderRadius: 10, padding: 12, color: '#111827', borderColor: '#111827' };
  const fullDiagnostic = JSON.stringify({ runtime: result, context: contextResult, contextError }, null, 2);

  return (
    <ScrollView contentContainerStyle={{ padding: 24, gap: 12 }}>
      <Text style={{ fontSize: 24, fontWeight: '700' }}>Runtime Verification</Text>
      <Text>Gunakan ini untuk memeriksa SH langsung dari HP. Semua hasil diagnostik bisa dicopy sebagai text.</Text>

      <Text style={{ fontSize: 20, fontWeight: '700' }}>Runtime verification</Text>
      <Text>Pesan uji dikirim melalui authenticated SH Runtime.</Text>
      <Text style={{ fontWeight: '600' }}>Test message</Text>
      <TextInput value={message} onChangeText={setMessage} placeholder="Isi pesan uji untuk SH Runtime" placeholderTextColor="#6B7280" style={inputStyle} />
      {busy ? <ActivityIndicator /> : <Button title="Verify SH Runtime" onPress={() => void verify()} />}
      {result ? <>
        <Text style={{ fontWeight: '700' }}>Runtime result</Text>
        <Text selectable>{result}</Text>
        <Button title="Copy Result" onPress={() => void copy(result, 'Runtime result')} />
        <Button title="Copy Error / Result" onPress={() => void copy(result, 'Error / result')} />
      </> : null}

      <Text style={{ fontSize: 20, fontWeight: '700', marginTop: 16 }}>Authorized context lookup</Text>
      <Text>Cari context yang tersedia untuk SH owner. Kosongkan pencarian untuk memuat hasil yang tersedia.</Text>
      <Text style={{ fontWeight: '600' }}>Search query (optional)</Text>
      <TextInput value={query} onChangeText={setQuery} placeholder="Opsional: isi kata yang ingin dicari di context" placeholderTextColor="#6B7280" style={inputStyle} />
      {contextBusy ? <ActivityIndicator /> : <Button title="Search authorized context" onPress={() => void loadContext()} />}
      {contextError ? <Text selectable>{contextError}</Text> : null}
      {contextResult ? <>
        <Text style={{ fontWeight: '700' }}>Memory ({contextResult.memory.length})</Text>
        {contextResult.memory.length === 0 ? <Text>No authorized memory results.</Text> : contextResult.memory.map((item, index) => <Text selectable key={`memory-${index}`}>{String(item.content ?? '')}</Text>)}
        <Text style={{ fontWeight: '700' }}>Knowledge ({contextResult.knowledge.length})</Text>
        {contextResult.knowledge.length === 0 ? <Text>No shared knowledge results.</Text> : contextResult.knowledge.map((item, index) => <Text selectable key={`knowledge-${index}`}>{String(item.content ?? '')}</Text>)}
        <Text style={{ fontWeight: '700' }}>Journey ({contextResult.journey.length})</Text>
        {contextResult.journey.length === 0 ? <Text>No journey events recorded.</Text> : contextResult.journey.map((item, index) => <Text selectable key={`journey-${index}`}>{String(item.event_type ?? 'EVENT')} · {String(item.continuity_status ?? '')}</Text>)}
      </> : null}
      <Button title="Copy Full Diagnostic" onPress={() => void copy(fullDiagnostic, 'Full diagnostic')} />
    </ScrollView>
  );
}
