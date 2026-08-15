import { useState } from 'react';
import { ActivityIndicator, Button, ScrollView, Text, TextInput, View } from 'react-native';
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

  return (
    <ScrollView contentContainerStyle={{ padding: 24, gap: 12 }}>
      <Text style={{ fontSize: 24, fontWeight: '700' }}>Runtime + Context Verification</Text>
      <Text>Developer / diagnostic tool for checking authenticated runtime access and authorized context retrieval. It is not required for normal Chat, Journey, Clone, Recovery, or Inheritance use.</Text>

      <Text style={{ fontSize: 20, fontWeight: '700' }}>Runtime verification</Text>
      <Text>Send a test message through the authenticated SH Runtime and display the returned result.</Text>
      <Text style={{ fontWeight: '600' }}>Test message</Text>
      <TextInput value={message} onChangeText={setMessage} placeholder="Enter a test message" style={{ borderWidth: 1, borderRadius: 10, padding: 12 }} />
      {busy ? <ActivityIndicator /> : <Button title="Verify SH Runtime" onPress={() => void verify()} />}
      {result ? <Text selectable>{result}</Text> : null}

      <Text style={{ fontSize: 20, fontWeight: '700', marginTop: 16 }}>Authorized context lookup</Text>
      <Text>Search the context available to the authenticated SH. Leave the search empty to refresh the available results.</Text>
      <Text style={{ fontWeight: '600' }}>Search query (optional)</Text>
      <TextInput value={query} onChangeText={setQuery} placeholder="Enter a context search term, or leave empty" style={{ borderWidth: 1, borderRadius: 10, padding: 12 }} />
      {contextBusy ? <ActivityIndicator /> : <Button title="Search authorized context" onPress={() => void loadContext()} />}
      {contextError ? <Text>{contextError}</Text> : null}
      {contextResult ? <>
        <Text style={{ fontWeight: '700' }}>Memory ({contextResult.memory.length})</Text>
        {contextResult.memory.length === 0 ? <Text>No authorized memory results.</Text> : contextResult.memory.map((item, index) => <Text key={`memory-${index}`}>{String(item.content ?? '')}</Text>)}
        <Text style={{ fontWeight: '700' }}>Knowledge ({contextResult.knowledge.length})</Text>
        {contextResult.knowledge.length === 0 ? <Text>No shared knowledge results.</Text> : contextResult.knowledge.map((item, index) => <Text key={`knowledge-${index}`}>{String(item.content ?? '')}</Text>)}
        <Text style={{ fontWeight: '700' }}>Journey ({contextResult.journey.length})</Text>
        {contextResult.journey.length === 0 ? <Text>No journey events recorded.</Text> : contextResult.journey.map((item, index) => <Text key={`journey-${index}`}>{String(item.event_type ?? 'EVENT')} · {String(item.continuity_status ?? '')}</Text>)}
      </> : null}
    </ScrollView>
  );
}
