import { useState } from 'react';
import { ActivityIndicator, Button, Text, TextInput, View } from 'react-native';
import { Redirect } from 'expo-router';
import { useAuth } from '../state/auth-context';
import { invokeSHRuntime } from '../services/runtime';

export default function RuntimeTestScreen() {
  const { session, loading } = useAuth();
  const [message, setMessage] = useState('SH runtime verification');
  const [busy, setBusy] = useState(false);
  const [result, setResult] = useState<string | null>(null);

  if (loading) return <View style={{ flex: 1, alignItems: 'center', justifyContent: 'center' }}><ActivityIndicator /></View>;
  if (!session) return <Redirect href="/login" />;

  async function verify() {
    setBusy(true);
    setResult(null);
    try {
      const response = await invokeSHRuntime({ userMessage: message });
      setResult(JSON.stringify(response, null, 2));
    } catch (error) {
      setResult(error instanceof Error ? error.message : 'Runtime verification failed');
    } finally {
      setBusy(false);
    }
  }

  return (
    <View style={{ flex: 1, padding: 24, justifyContent: 'center', gap: 12 }}>
      <Text style={{ fontSize: 24, fontWeight: '700' }}>Runtime Verification</Text>
      <TextInput value={message} onChangeText={setMessage} placeholder="Message" />
      {busy ? <ActivityIndicator /> : <Button title="Invoke SH Runtime" onPress={() => void verify()} />}
      {result ? <Text selectable>{result}</Text> : null}
    </View>
  );
}
