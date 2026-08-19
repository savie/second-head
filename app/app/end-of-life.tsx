import { useState } from 'react';
import { Button, ScrollView, Text, TextInput } from 'react-native';
import { Redirect } from 'expo-router';
import { useAuth } from '../state/auth-context';

export default function EndOfLifeScreen() {
  const { session } = useAuth();
  const [shId, setShId] = useState('');
  const [confirmation, setConfirmation] = useState('');
  const [notice, setNotice] = useState<string | null>(null);
  if (!session) return <Redirect href="/login" />;
  return <ScrollView contentContainerStyle={{ padding: 24, gap: 14 }}>
    <Text style={{ fontSize: 28, fontWeight: '700' }}>End-of-Life</Text>
    <Text>This is the dedicated End-of-Life action surface. Execution must remain explicit and is recorded in Journey.</Text>
    <Text style={{ fontWeight: '600' }}>SH ID</Text>
    <TextInput placeholder="Isi SH ID yang akan diakhiri" placeholderTextColor="#6B7280" value={shId} onChangeText={setShId} style={{ borderWidth: 1, borderRadius: 8, padding: 12, color: '#111827', borderColor: '#111827' }} />
    <Text style={{ fontWeight: '600' }}>Confirmation</Text>
    <TextInput placeholder="Ketik END-OF-LIFE untuk konfirmasi" placeholderTextColor="#6B7280" value={confirmation} onChangeText={setConfirmation} autoCapitalize="characters" style={{ borderWidth: 1, borderRadius: 8, padding: 12, color: '#111827', borderColor: '#111827' }} />
    <Button title="Confirm End-of-Life action" disabled={!shId.trim() || confirmation !== 'END-OF-LIFE'} onPress={() => setNotice('End-of-Life action is prepared. No backend mutation is exposed by the current FE service surface.')}/>
    {notice ? <Text>{notice}</Text> : null}
  </ScrollView>;
}
