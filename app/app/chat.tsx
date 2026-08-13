import { useState } from 'react';
import { Button, ScrollView, Text, TextInput, View } from 'react-native';
import { sendChatMessage } from '../features/chat/chat-service';

export default function ChatScreen() {
  const [draft, setDraft] = useState('');
  const [messages, setMessages] = useState<string[]>([]);
  const [sending, setSending] = useState(false);

  async function onSend() {
    const message = draft.trim();
    if (!message || sending) return;
    setDraft('');
    setSending(true);
    setMessages((current) => [...current, `You: ${message}`]);
    try {
      const result = await sendChatMessage(message);
      setMessages((current) => [...current, `SH: ${result.response}`]);
    } catch (error) {
      const text = error instanceof Error ? error.message : 'Chat request failed';
      setMessages((current) => [...current, `Error: ${text}`]);
    } finally {
      setSending(false);
    }
  }

  return (
    <View style={{ flex: 1, padding: 20, gap: 12 }}>
      <Text style={{ fontSize: 28, fontWeight: '700' }}>SH Chat</Text>
      <Text>App → Runtime → response</Text>
      <ScrollView style={{ flex: 1 }} contentContainerStyle={{ gap: 12, paddingVertical: 12 }}>
        {messages.length === 0 ? <Text>Tulis pesan untuk menguji chat SH.</Text> : null}
        {messages.map((item, index) => <Text key={`${index}-${item}`}>{item}</Text>)}
      </ScrollView>
      <TextInput
        value={draft}
        onChangeText={setDraft}
        placeholder="Tulis pesan..."
        multiline
        style={{ minHeight: 54, borderWidth: 1, borderRadius: 10, padding: 12 }}
      />
      <Button title={sending ? 'Mengirim...' : 'Kirim'} onPress={() => void onSend()} disabled={sending || !draft.trim()} />
    </View>
  );
}
