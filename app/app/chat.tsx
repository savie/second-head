import { useEffect, useMemo, useRef, useState } from 'react';
import { Alert, Button, ScrollView, Share, Text, TextInput, View } from 'react-native';
import * as Clipboard from 'expo-clipboard';
import { AppState } from 'react-native';
import { deleteConversation, deleteConversationMessage, loadConversationHistoryRows, renameConversation, streamSHRuntime, updateConversationMessage, type ConversationHistoryRow } from '../services/runtime-stream';
import { useAuth } from '../state/auth-context';
import { supabase } from '../services/supabase';

type PendingConfirmation = { confirmation_id: string; action_id: string; title: string; description: string };
type ChatLifecycleState = 'active' | 'background' | 'idle' | 'streaming' | 'cancelled' | 'error';
type Message = { id: string; role: 'user' | 'assistant' | 'system'; text: string; conversationId?: string; createdAt?: string };
type ConversationRow = { id: string; role: Message['role']; content: string; created_at: string; metadata?: Record<string, unknown> | null };
type ConversationSession = { id: string; title: string; startedAt: string; endedAt: string; rows: ConversationHistoryRow[] };

function makeMessage(role: Message['role'], text: string, id?: string): Message {
  return { id: id ?? `${Date.now()}-${Math.random()}`, role, text };
}

function buildVirtualSessions(rows: ConversationHistoryRow[]): ConversationSession[] {
  const sessions: ConversationSession[] = [];
  const gapSeconds = 3600;
  for (const row of rows) {
    const previous = sessions.at(-1);
    const gap = previous ? (Date.parse(row.created_at) - Date.parse(previous.endedAt)) / 1000 : Infinity;
    if (!previous || gap > gapSeconds) {
      sessions.push({
        id: row.conversation_id,
        title: row.role === 'user' ? row.content.slice(0, 42) : 'Conversation',
        startedAt: row.created_at,
        endedAt: row.created_at,
        rows: [row],
      });
    } else {
      previous.rows.push(row);
      previous.endedAt = row.created_at;
      if (previous.title === 'Conversation' && row.role === 'user') previous.title = row.content.slice(0, 42);
    }
  }
  return sessions.reverse();
}

function isVerificationArtifact(row: Pick<ConversationRow, 'content' | 'metadata'> | Pick<ConversationHistoryRow, 'content' | 'metadata'>): boolean {
  const metadata = row.metadata;
  if (metadata && (metadata.persistence === 'verification-only' || metadata.verification_only === true)) return true;
  const text = row.content.trim().toLowerCase();
  return [
    'sh runtime controlled verification',
    'streaming verification',
    'runtime controlled verification',
  ].some(marker => text.includes(marker));
}

export default function ChatScreen() {
  const { context } = useAuth();
  const [draft, setDraft] = useState('');
  const [messages, setMessages] = useState<Message[]>([]);
  const [sending, setSending] = useState(false);
  const [pendingConfirmation, setPendingConfirmation] = useState<PendingConfirmation | null>(null);
  const [confirmationState, setConfirmationState] = useState<'idle' | 'cancelled' | 'confirmed'>('idle');
  const [lifecycleState, setLifecycleState] = useState<ChatLifecycleState>('active');
  const [menuOpen, setMenuOpen] = useState(false);
  const [historyOpen, setHistoryOpen] = useState(false);
  const [historySessions, setHistorySessions] = useState<ConversationSession[]>([]);
  const [historyLoading, setHistoryLoading] = useState(false);
  const [findOpen, setFindOpen] = useState(false);
  const [findQuery, setFindQuery] = useState('');
  const [conversationTitle, setConversationTitle] = useState('New conversation');
  const [currentConversationId, setCurrentConversationId] = useState<string | null>(null);
  const [editingId, setEditingId] = useState<string | null>(null);
  const [editingText, setEditingText] = useState('');
  const [attachmentName, setAttachmentName] = useState<string | null>(null);
  const abortControllerRef = useRef<AbortController | null>(null);
  const mountedRef = useRef(true);

  useEffect(() => {
    mountedRef.current = true;
    const subscription = AppState.addEventListener('change', nextState => {
      if (!mountedRef.current) return;
      if (nextState === 'active') {
        setLifecycleState('active');
        return;
      }
      setLifecycleState('background');
      if (abortControllerRef.current) {
        abortControllerRef.current.abort();
        abortControllerRef.current = null;
      }
      setSending(false);
    });
    return () => {
      mountedRef.current = false;
      subscription.remove();
      if (abortControllerRef.current) abortControllerRef.current.abort();
    };
  }, []);

  useEffect(() => {
    let cancelled = false;
    async function loadRecentConversation() {
      if (!context?.sh_id) return;
      try {
        const data = await loadConversationHistoryRows(100);
        if (cancelled) return;
        const rows = data.filter(row => row?.content && !isVerificationArtifact(row));
        const sessions = buildVirtualSessions(rows);
        setHistorySessions(sessions);
        const latest = sessions[0];
        if (!latest) return;
        const recentRows = latest.rows.slice(-14);
        setMessages(recentRows.map(messageFromRow));
        setCurrentConversationId(latest.id);
        if (latest.title) setConversationTitle(latest.title);
      } catch {
        // History loading must not block the chat UI from opening.
      }
    }
    void loadRecentConversation();
    return () => { cancelled = true; };
  }, [context?.sh_id]);

  const canSend = lifecycleState === 'active' && !sending && !pendingConfirmation && !!draft.trim();
  const visibleMatches = useMemo(() => {
    const query = findQuery.trim().toLowerCase();
    if (!query) return [];
    return messages.filter(message => message.text.toLowerCase().includes(query));
  }, [findQuery, messages]);

  async function onSend() {
    const message = draft.trim();
    if (!message || !canSend) return;
    const controller = new AbortController();
    abortControllerRef.current = controller;
    setDraft('');
    setAttachmentName(null);
    setSending(true);
    setLifecycleState('streaming');
    setConfirmationState('idle');
    if (conversationTitle === 'New conversation') setConversationTitle(message.slice(0, 42));
    setMessages(current => [...current, makeMessage('user', message), makeMessage('assistant', '')]);
    try {
      await streamSHRuntime(message, event => {
        if (!mountedRef.current) return;
        if (event.type === 'token') {
          setMessages(current => {
            const next = [...current];
            const last = next[next.length - 1];
            if (last?.role === 'assistant') last.text += event.text;
            return next;
          });
        }
        if (event.type === 'response') {
          setMessages(current => {
            const next = [...current];
            const last = next[next.length - 1];
            if (last?.role === 'assistant') last.text = event.text;
            return next;
          });
        }
        if (event.type === 'confirmation') {
          setPendingConfirmation(event);
          setConfirmationState('idle');
        }
        if (event.type === 'complete') setLifecycleState('active');
      }, controller.signal);
    } catch (error) {
      if (!mountedRef.current) return;
      if (controller.signal.aborted) {
        setLifecycleState('cancelled');
        setMessages(current => [...current, makeMessage('system', 'Streaming dibatalkan.')]);
        return;
      }
      setLifecycleState('error');
      setMessages(current => [...current, makeMessage('system', error instanceof Error ? error.message : 'Chat streaming failed')]);
    } finally {
      if (abortControllerRef.current === controller) abortControllerRef.current = null;
      if (mountedRef.current) {
        setSending(false);
        setLifecycleState(current => current === 'streaming' ? 'active' : current);
      }
    }
  }

  function newChat() {
    const start = () => {
      setMessages([]);
      setConversationTitle('New conversation');
      setCurrentConversationId(null);
      setFindQuery('');
      setHistoryOpen(false);
      setMenuOpen(false);
    };
    if (messages.length > 0) {
      Alert.alert('New chat', 'Mulai sesi chat baru?', [
        { text: 'Cancel', style: 'cancel' },
        { text: 'New chat', onPress: start },
      ]);
      return;
    }
    start();
  }

  async function openHistory() {
    setMenuOpen(false);
    setHistoryOpen(true);
    setHistoryLoading(true);
    try {
      const rows = await loadConversationHistoryRows(100);
      setHistorySessions(buildVirtualSessions(rows.filter(row => row?.content && !isVerificationArtifact(row))));
    } catch {
      Alert.alert('History', 'Conversation history tidak dapat dimuat.');
    } finally {
      setHistoryLoading(false);
    }
  }

  function openHistorySession(session: ConversationSession) {
    setMessages(session.rows.map(messageFromRow));
    setCurrentConversationId(session.id);
    setConversationTitle(session.title || 'Conversation');
    setHistoryOpen(false);
  }

  function clearChat() {
    Alert.alert('Clear chat', 'Semua history pada sesi chat ini akan hilang dari sesi.', [
      { text: 'Cancel', style: 'cancel' },
      { text: 'Clear', style: 'destructive', onPress: () => { setMessages([]); setConversationTitle('New conversation'); setCurrentConversationId(null); setMenuOpen(false); } },
    ]);
  }

  function deleteConversation() {
    Alert.alert('Delete conversation', 'Percakapan ini akan dihapus dari daftar chat.', [
      { text: 'Cancel', style: 'cancel' },
      { text: 'Delete', style: 'destructive', onPress: () => { setMessages([]); setConversationTitle('New conversation'); setCurrentConversationId(null); setMenuOpen(false); } },
    ]);
  }

  function renameConversationAction() {
    if (!currentConversationId) return Alert.alert('Rename conversation', 'Belum ada conversation yang tersimpan.');
    Alert.prompt?.('Rename conversation', 'Masukkan nama baru', async text => {
      const title = text?.trim();
      if (!title) return;
      try {
        await renameConversation(currentConversationId, title);
        setConversationTitle(title);
        setMenuOpen(false);
      } catch (error) {
        Alert.alert('Rename failed', error instanceof Error ? error.message : 'Conversation rename failed');
      }
    }, 'plain-text', conversationTitle);
  }

  async function copyConversation() {
    const text = messages.map(message => `${message.role === 'user' ? 'You' : message.role === 'assistant' ? 'SH' : 'System'}: ${message.text}`).join('\n\n');
    await Clipboard.setStringAsync(text);
    setMenuOpen(false);
    Alert.alert('Copied', 'Isi conversation sudah disalin.');
  }

  async function copyMessage(message: Message) {
    await Clipboard.setStringAsync(message.text);
    Alert.alert('Copied', 'Pesan sudah disalin.');
  }

  function editMessage(message: Message) {
    setEditingId(message.id);
    setEditingText(message.text);
  }

  async function saveEditedMessage() {
    if (!editingId || !editingText.trim()) return;
    const target = messages.find(message => message.id === editingId);
    if (!target?.conversationId || !target.createdAt) return Alert.alert('Edit message', 'Pesan belum tersimpan di database. Tunggu sampai response selesai lalu edit lagi.');
    try {
      const row: ConversationHistoryRow = { conversation_id: target.conversationId, sh_id: context?.sh_id ?? '', role: target.role, content: target.text, created_at: target.createdAt };
      await updateConversationMessage(row, editingText.trim());
      setMessages(current => current.map(message => message.id === editingId ? { ...message, text: editingText.trim() } : message));
      setEditingId(null); setEditingText('');
    } catch (error) {
      Alert.alert('Edit failed', error instanceof Error ? error.message : 'Message edit failed');
    }
  }

  function deleteMessage(messageId: string) {
    const target = messages.find(message => message.id === messageId);
    if (!target?.conversationId || !target.createdAt) return Alert.alert('Delete message', 'Pesan belum tersimpan di database. Tunggu sampai response selesai lalu hapus lagi.');
    Alert.alert('Delete message', 'Hapus pesan ini dari conversation?', [
      { text: 'Cancel', style: 'cancel' },
      { text: 'Delete', style: 'destructive', onPress: async () => {
        try {
          const row: ConversationHistoryRow = { conversation_id: target.conversationId!, sh_id: context?.sh_id ?? '', role: target.role, content: target.text, created_at: target.createdAt! };
          await deleteConversationMessage(row);
          setMessages(current => current.filter(message => message.id !== messageId));
        } catch (error) {
          Alert.alert('Delete failed', error instanceof Error ? error.message : 'Message deletion failed');
        }
      } },
    ]);
  }

  async function regenerateResponse() {
    if (sending) return;
    const rows = await loadConversationHistoryRows(100);
    const visible = rows.filter(row => row?.content && !isVerificationArtifact(row));
    const lastUser = [...messages].reverse().find(message => message.role === 'user');
    if (!lastUser) return;
    const assistant = [...messages].reverse().find(message => message.role === 'assistant' && message.text);
    try {
      if (assistant?.conversationId && assistant.createdAt) {
        const row = visible.find(item => item.conversation_id === assistant.conversationId && item.created_at === assistant.createdAt);
        if (row) await deleteConversationMessage(row);
      }
      setMessages(current => {
        const index = current.findIndex(message => message.id === assistant?.id);
        return index >= 0 ? current.slice(0, index) : current;
      });
      setDraft('');
      await streamSHRuntime(lastUser.text, event => {
        if (event.type === 'token') setMessages(current => [...current, makeMessage('assistant', event.text)]);
        if (event.type === 'response') setMessages(current => {
          const next = [...current];
          const last = next[next.length - 1];
          if (last?.role === 'assistant') last.text = event.text;
          return next;
        });
      });
    } catch (error) {
      Alert.alert('Regenerate failed', error instanceof Error ? error.message : 'Regenerate failed');
    }
  }

  function openMessageActions(message: Message) {
    const actions = [
      { text: 'Copy', onPress: () => void copyMessage(message) },
      ...(message.role === 'user' ? [{ text: 'Edit', onPress: () => editMessage(message) }] : []),
      { text: 'Delete', style: 'destructive' as const, onPress: () => deleteMessage(message.id) },
      ...(message.role === 'assistant' ? [{ text: 'Regenerate', onPress: regenerateResponse }] : []),
      { text: 'Cancel', style: 'cancel' as const },
    ];
    Alert.alert(message.role === 'user' ? 'Your message' : 'SH response', undefined, actions);
  }

  function handleAttachment(kind: string) {
    setAttachmentName(`${kind} ready`);
    Alert.alert(kind, 'UI attachment sudah siap. Penyimpanan/upload BE akan di-wire berikutnya.');
  }

  function cancelStreaming() {
    abortControllerRef.current?.abort();
    abortControllerRef.current = null;
    setSending(false);
    setLifecycleState('cancelled');
  }

  function cancelConfirmation() {
    setPendingConfirmation(null);
    setConfirmationState('cancelled');
    setMessages(current => [...current, makeMessage('system', 'High-risk confirmation cancelled.')]);
  }

  function confirmConfirmation() {
    setPendingConfirmation(null);
    setConfirmationState('confirmed');
    setMessages(current => [...current, makeMessage('system', 'Explicit confirmation recorded; Runtime authorization is still required.')]);
  }

  const inputStyle = { minHeight: 52, borderWidth: 1, borderRadius: 14, padding: 12, color: '#111827', borderColor: '#D1D5DB', backgroundColor: '#FFFFFF' };

  return (
    <View style={{ flex: 1, backgroundColor: '#F8FAFC' }}>
      <View style={{ paddingHorizontal: 16, paddingTop: 18, paddingBottom: 10, borderBottomWidth: 1, borderBottomColor: '#E5E7EB', backgroundColor: '#FFFFFF' }}>
        <View style={{ flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between' }}>
          <View style={{ flex: 1, marginRight: 12 }}>
            <Text style={{ fontSize: 20, fontWeight: '700', color: '#111827' }}>{conversationTitle}</Text>
            <Text style={{ color: '#6B7280', marginTop: 3 }}>Second Head · {lifecycleState}</Text>
          </View>
          <Button title="⋮" onPress={() => setMenuOpen(value => !value)} />
        </View>
        {menuOpen ? <View style={{ marginTop: 10, borderWidth: 1, borderColor: '#E5E7EB', borderRadius: 12, padding: 8, backgroundColor: '#FFFFFF', gap: 4 }}>
          <Button title="＋ New chat" onPress={newChat} />
          <Button title="Conversation history" onPress={() => void openHistory()} />
          <Button title="✎ Rename conversation" onPress={renameConversationAction} />
          <Button title="⌕ Find in chat" onPress={() => { setFindOpen(true); setMenuOpen(false); }} />
          <Button title="Copy conversation" onPress={() => void copyConversation()} />
          <Button title="Clear chat" onPress={clearChat} />
          <Button title="Delete conversation" onPress={deleteConversationAction} />
          <Button title="Share conversation" onPress={() => { const text = messages.map(message => `${message.role === 'user' ? 'You' : message.role === 'assistant' ? 'SH' : 'System'}: ${message.text}`).join('\n\n'); void Share.share({ message: text, title: conversationTitle }); setMenuOpen(false); }} />
          <Button title="Export conversation" onPress={() => { const text = messages.map(message => `${message.role === 'user' ? 'You' : message.role === 'assistant' ? 'SH' : 'System'}: ${message.text}`).join('\n\n'); void Share.share({ message: text, title: `Export — ${conversationTitle}` }); setMenuOpen(false); }} />
        </View> : null}
        {historyOpen ? <View style={{ marginTop: 10, borderWidth: 1, borderColor: '#E5E7EB', borderRadius: 12, padding: 8, backgroundColor: '#FFFFFF', gap: 6 }}>
          <Text style={{ fontSize: 16, fontWeight: '700', color: '#111827' }}>Conversation history</Text>
          {historyLoading ? <Text style={{ color: '#6B7280' }}>Loading history…</Text> : null}
          {!historyLoading && historySessions.length === 0 ? <Text style={{ color: '#6B7280' }}>Belum ada conversation history.</Text> : null}
          {!historyLoading ? historySessions.map(session => <Button key={session.id} title={session.title || 'Conversation'} onPress={() => openHistorySession(session)} />) : null}
          <Button title="Close history" onPress={() => setHistoryOpen(false)} />
        </View> : null}
        {findOpen ? <View style={{ marginTop: 10, gap: 6 }}>
          <TextInput value={findQuery} onChangeText={setFindQuery} autoFocus placeholder="Find in chat..." placeholderTextColor="#6B7280" style={inputStyle} />
          {findQuery ? <Text style={{ color: '#6B7280' }}>{visibleMatches.length} pesan cocok</Text> : null}
          <Button title="Close find" onPress={() => { setFindOpen(false); setFindQuery(''); }} />
        </View> : null}
      </View>

      <ScrollView style={{ flex: 1 }} contentContainerStyle={{ padding: 16, gap: 12 }}>
        {messages.length === 0 ? <View style={{ paddingVertical: 50, alignItems: 'center' }}><Text style={{ fontSize: 24, fontWeight: '700', color: '#111827' }}>Start a chat</Text><Text style={{ color: '#6B7280', marginTop: 8 }}>Ngobrol biasa. SH Core yang memilah konteksnya.</Text></View> : null}
        {messages.map(message => <View key={message.id} style={{ alignItems: message.role === 'user' ? 'flex-end' : 'flex-start' }}>
          <View style={{ maxWidth: '88%', borderRadius: 16, padding: 12, backgroundColor: message.role === 'user' ? '#E0F2FE' : '#FFFFFF', borderWidth: 1, borderColor: '#E5E7EB' }}>
            <Text style={{ fontSize: 12, fontWeight: '700', color: '#6B7280', marginBottom: 5 }}>{message.role === 'user' ? 'You' : message.role === 'assistant' ? 'SH' : 'System'}</Text>
            {editingId === message.id ? <View style={{ gap: 8 }}><TextInput value={editingText} onChangeText={setEditingText} multiline style={inputStyle} /><View style={{ flexDirection: 'row', gap: 8 }}><Button title="Save" onPress={saveEditedMessage} /><Button title="Cancel" onPress={() => { setEditingId(null); setEditingText(''); }} /></View></View> : <Text style={{ color: '#111827', lineHeight: 21 }}>{message.text || (sending && message.role === 'assistant' ? 'SH is thinking…' : '')}</Text>}
            {!editingId && message.text ? <View style={{ alignItems: 'flex-end', marginTop: 6 }}><Button title="⋮" onPress={() => openMessageActions(message)} /></View> : null}
          </View>
        </View>)}
        {pendingConfirmation ? <View style={{ borderWidth: 1, borderRadius: 12, padding: 12, backgroundColor: '#FFFFFF', gap: 8 }}><Text style={{ fontSize: 18, fontWeight: '700' }}>{pendingConfirmation.title}</Text><Text>{pendingConfirmation.description}</Text><Text>Action: {pendingConfirmation.action_id}</Text><View style={{ flexDirection: 'row', gap: 8 }}><Button title="Cancel" onPress={cancelConfirmation} /><Button title="Confirm" onPress={confirmConfirmation} /></View></View> : null}
        {confirmationState !== 'idle' ? <Text>{confirmationState === 'cancelled' ? 'High-risk confirmation cancelled.' : 'Explicit confirmation recorded; no App-side authorization or execution occurred.'}</Text> : null}
      </ScrollView>

      <View style={{ padding: 12, borderTopWidth: 1, borderTopColor: '#E5E7EB', backgroundColor: '#FFFFFF', gap: 8 }}>
        {attachmentName ? <Text style={{ color: '#374151' }}>📎 {attachmentName}</Text> : null}
        <View style={{ flexDirection: 'row', alignItems: 'flex-end', gap: 8 }}>
          <View style={{ gap: 4 }}>
            <Button title="＋" onPress={() => Alert.alert('Attach', 'Pilih attachment', [
              { text: 'File', onPress: () => handleAttachment('File') },
              { text: 'Photo', onPress: () => handleAttachment('Photo') },
              { text: 'Camera', onPress: () => handleAttachment('Camera') },
              { text: 'Cancel', style: 'cancel' },
            ])} />
          </View>
          <TextInput value={draft} onChangeText={setDraft} placeholder="Message SH…" placeholderTextColor="#6B7280" multiline editable={!sending && lifecycleState === 'active'} style={[inputStyle, { flex: 1, maxHeight: 130 }]} />
          {sending ? <Button title="Stop" onPress={cancelStreaming} /> : <Button title="Send" onPress={() => void onSend()} disabled={!canSend} />}
        </View>
      </View>
    </View>
  );
}
