import { useState } from 'react';
import { Button, ScrollView, Text, TextInput, View } from 'react-native';
import { streamSHRuntime } from '../services/runtime-stream';

type PendingConfirmation = {
  confirmation_id: string;
  action_id: string;
  title: string;
  description: string;
};

export default function ChatScreen() {
  const [draft, setDraft] = useState('');
  const [messages, setMessages] = useState<string[]>([]);
  const [sending, setSending] = useState(false);
  const [pendingConfirmation, setPendingConfirmation] = useState<PendingConfirmation | null>(null);
  const [confirmationState, setConfirmationState] = useState<'idle' | 'cancelled' | 'confirmed'>('idle');

  async function onSend() {
    const message = draft.trim();
    if (!message || sending || pendingConfirmation) return;
    setDraft('');
    setSending(true);
    setConfirmationState('idle');
    setMessages((current) => [...current, `You: ${message}`, 'SH: ']);
    try {
      await streamSHRuntime(message, (event) => {
        if (event.type === 'token') {
          setMessages((current) => {
            if (current.length === 0) return current;
            const next = [...current];
            next[next.length - 1] = `${next[next.length - 1]}${event.text}`;
            return next;
          });
        }
        if (event.type === 'confirmation') {
          setPendingConfirmation(event);
          setConfirmationState('idle');
        }
      });
    } catch (error) {
      const text = error instanceof Error ? error.message : 'Chat streaming failed';
      setMessages((current) => [...current, `Error: ${text}`]);
    } finally {
      setSending(false);
    }
  }

  function cancelConfirmation() {
    setPendingConfirmation(null);
    setConfirmationState('cancelled');
    setMessages((current) => [...current, 'SH: High-risk action cancelled.']);
  }

  function confirmConfirmation() {
    // This button records explicit user intent only. It does NOT authorize or execute.
    // A confirmation request must be re-validated and executed by Runtime.
    setPendingConfirmation(null);
    setConfirmationState('confirmed');
    setMessages((current) => [...current, 'SH: Confirmation recorded; Runtime authorization is still required.']);
  }

  return (
    <View style={{ flex: 1, padding: 20, gap: 12 }}>
      <Text style={{ fontSize: 28, fontWeight: '700' }}>SH Chat</Text>
      <Text>App → authenticated Runtime → streaming events</Text>
      <ScrollView style={{ flex: 1 }} contentContainerStyle={{ gap: 12, paddingVertical: 12 }}>
        {messages.length === 0 ? <Text>Tulis pesan untuk menguji streaming SH.</Text> : null}
        {messages.map((item, index) => <Text key={`${index}-${item}`}>{item}</Text>)}
      </ScrollView>

      {pendingConfirmation ? (
        <View style={{ gap: 8, borderWidth: 1, borderRadius: 10, padding: 12 }}>
          <Text style={{ fontSize: 18, fontWeight: '700' }}>{pendingConfirmation.title}</Text>
          <Text>{pendingConfirmation.description}</Text>
          <Text>Action: {pendingConfirmation.action_id}</Text>
          <Text>SH App hanya mengumpulkan konfirmasi. Runtime tetap pemilik authorization.</Text>
          <View style={{ gap: 8 }}>
            <Button title="Cancel" onPress={cancelConfirmation} />
            <Button title="Confirm" onPress={confirmConfirmation} />
          </View>
        </View>
      ) : null}

      {confirmationState !== 'idle' ? (
        <Text accessibilityRole="text">
          {confirmationState === 'cancelled'
            ? 'High-risk confirmation cancelled.'
            : 'Explicit confirmation recorded; no App-side authorization or execution occurred.'}
        </Text>
      ) : null}

      <TextInput
        value={draft}
        onChangeText={setDraft}
        placeholder="Tulis pesan..."
        multiline
        style={{ minHeight: 54, borderWidth: 1, borderRadius: 10, padding: 12 }}
      />
      <Button title={sending ? 'Streaming...' : 'Kirim'} onPress={() => void onSend()} disabled={sending || !draft.trim() || !!pendingConfirmation} />
    </View>
  );
}
