import { useEffect, useMemo, useRef, useState } from 'react';
import { Alert, Button, Modal, ScrollView, Share, Text, TextInput, View } from 'react-native';
import * as Clipboard from 'expo-clipboard';
import * as ImagePicker from 'expo-image-picker';
import * as DocumentPicker from 'expo-document-picker';
import * as FileSystem from 'expo-file-system';
import { AppState } from 'react-native';
import { deleteConversation as deletePersistedConversation, deleteConversationMessage, loadConversationHistoryRows, renameConversation as renamePersistedConversation, streamSHRuntime, updateConversationMessage, type ConversationHistoryRow, type ChatAttachment } from '../services/runtime-stream';
import { useAuth } from '../state/auth-context';
import { backend } from '../services/backend';
import { SHShell } from '../components/sh-shell';
import { loadSHContext } from '../services/context';

type PendingConfirmation = { confirmation_id: string; action_id: string; title: string; description: string };
type ChatLifecycleState = 'active' | 'background' | 'idle' | 'streaming' | 'cancelled' | 'error';
type Message = { id: string; role: 'user' | 'assistant' | 'system'; text: string; conversationId?: string; createdAt?: string; attachmentName?: string };
type ConversationRow = { id: string; role: Message['role']; content: string; created_at: string; metadata?: Record<string, unknown> | null };
type ConversationSession = { id: string; title: string; startedAt: string; endedAt: string; rows: ConversationHistoryRow[] };

function makeMessage(role: Message['role'], text: string, id?: string, conversationId?: string, createdAt?: string, attachmentName?: string): Message {
  return { id: id ?? `${Date.now()}-${Math.random()}`, role, text, conversationId, createdAt, attachmentName };
}

function messageFromRow(row: ConversationHistoryRow): Message {
  const names = Array.isArray(row.metadata?.attachment_names) ? row.metadata.attachment_names.filter((value): value is string => typeof value === 'string') : [];
  const attachmentName = names.join(', ') || (typeof row.metadata?.attachment_name === 'string' ? row.metadata.attachment_name : undefined);
  return makeMessage(row.role, row.content, `${row.conversation_id}:${row.created_at}`, row.conversation_id, row.created_at, attachmentName);
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
        title: typeof row.metadata?.conversation_title === 'string' && row.metadata.conversation_title.trim() ? row.metadata.conversation_title : (row.role === 'user' ? row.content.slice(0, 42) : 'Conversation'),
        startedAt: row.created_at,
        endedAt: row.created_at,
        rows: [row],
      });
    } else {
      previous.rows.push(row);
      previous.endedAt = row.created_at;
      if (previous.title === 'Conversation' && row.role === 'user') previous.title = row.content.slice(0, 42);
      if (typeof row.metadata?.conversation_title === 'string' && row.metadata.conversation_title.trim()) previous.title = row.metadata.conversation_title;
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
  const [findIndex, setFindIndex] = useState(0);
  const [conversationTitle, setConversationTitle] = useState('New conversation');
  const [renameOpen, setRenameOpen] = useState(false);
  const [renameText, setRenameText] = useState('');
  const [messageActionTarget, setMessageActionTarget] = useState<Message | null>(null);
  const [memoryOpen, setMemoryOpen] = useState(false);
  const [memoryLoading, setMemoryLoading] = useState(false);
  const [memoryError, setMemoryError] = useState<string | null>(null);
  const [memoryRows, setMemoryRows] = useState<Array<Record<string, unknown>>>([]);
  const [currentConversationId, setCurrentConversationId] = useState<string | null>(null);
  const [editingId, setEditingId] = useState<string | null>(null);
  const [editingText, setEditingText] = useState('');
  const [attachments, setAttachments] = useState<ChatAttachment[]>([]);
  const [attachmentState, setAttachmentState] = useState<'idle' | 'preparing' | 'ready' | 'failed'>('idle');
  const [attachmentError, setAttachmentError] = useState<string | null>(null);
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


  async function openMemorySurface() {
    if (!context?.sh_id) return;
    setMemoryOpen(true);
    setMemoryLoading(true);
    setMemoryError(null);
    try {
      const result = await loadSHContext({ shId: context.sh_id, query: draft.trim() || conversationTitle, memoryLimit: 10, knowledgeLimit: 1, journeyLimit: 1 });
      setMemoryRows(result.memory);
    } catch (error) {
      setMemoryError(error instanceof Error ? error.message : 'Memory could not be loaded.');
      setMemoryRows([]);
    } finally {
      setMemoryLoading(false);
    }
  }

  const canSend = lifecycleState === 'active' && !sending && !pendingConfirmation && !!draft.trim();
  const visibleMatches = useMemo(() => {
    const query = findQuery.trim().toLowerCase();
    if (!query) return [];
    return messages.map((message, index) => ({ message, index })).filter(item => item.message.text.toLowerCase().includes(query));
  }, [findQuery, messages]);
  useEffect(() => { setFindIndex(0); }, [findQuery]);

  async function onSend() {
    const message = draft.trim();
    if (!message || !canSend) return;
    const controller = new AbortController();
    abortControllerRef.current = controller;
    setDraft('');
    setAttachments([]);
    setAttachmentState('idle');
    setAttachmentError(null);
    setSending(true);
    setLifecycleState('streaming');
    setConfirmationState('idle');
    if (conversationTitle === 'New conversation') setConversationTitle(message.slice(0, 42));
    setMessages(current => [...current, makeMessage('user', message, undefined, undefined, undefined, attachments.map(item => item.name ?? 'attachment').join(', ') || undefined), makeMessage('assistant', '')]);
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
      }, controller.signal, attachments);
      const rows = await loadConversationHistoryRows(100);
      const sessionRows: ConversationHistoryRow[] = rows.filter((row): row is ConversationHistoryRow => Boolean(row?.content) && !isVerificationArtifact(row));
       const sessions = buildVirtualSessions(sessionRows);
      const latest = sessions[0];
      if (latest) {
        setCurrentConversationId(latest.id);
        setConversationTitle(latest.title || conversationTitle);
        setMessages(latest.rows.map(messageFromRow));
      }
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
      ], { cancelable: false });
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
    ], { cancelable: false });
  }

  function deleteConversation() {
    Alert.alert('Delete conversation', 'Percakapan ini akan dihapus dari daftar chat.', [
      { text: 'Cancel', style: 'cancel' },
      { text: 'Delete', style: 'destructive', onPress: () => { setMessages([]); setConversationTitle('New conversation'); setCurrentConversationId(null); setMenuOpen(false); } },
    ], { cancelable: false });
  }

  function deleteConversationAction() {
    if (!currentConversationId) return Alert.alert('Delete conversation', 'Belum ada conversation yang tersimpan.');
    const id = currentConversationId;
    Alert.alert('Delete conversation', 'Percakapan ini akan dihapus dari database.', [
      { text: 'Cancel', style: 'cancel' },
      { text: 'Delete', style: 'destructive', onPress: async () => {
        try {
          await deletePersistedConversation(id);
          setMessages([]);
          setConversationTitle('New conversation');
          setCurrentConversationId(null);
          setMenuOpen(false);
          setHistorySessions(current => current.filter(session => session.id !== id));
        } catch (error) {
          Alert.alert('Delete failed', error instanceof Error ? error.message : 'Conversation deletion failed');
        }
      } },
    ], { cancelable: false });
  }

  function renameConversationAction() {
    if (!currentConversationId) return Alert.alert('Rename conversation', 'Belum ada conversation yang tersimpan.', [{ text: 'OK' }], { cancelable: false });
    setMenuOpen(false);
    setRenameText(conversationTitle === 'New conversation' ? '' : conversationTitle);
    setRenameOpen(true);
  }

  async function saveRename() {
    const title = renameText.trim();
    if (!currentConversationId || !title) return;
    try {
      await renamePersistedConversation(currentConversationId, title);
      setConversationTitle(title);
      setHistorySessions(current => current.map(session => session.id === currentConversationId ? { ...session, title } : session));
      setRenameOpen(false);
    } catch (error) {
      Alert.alert('Rename failed', error instanceof Error ? error.message : 'Conversation rename failed', [{ text: 'OK' }], { cancelable: false });
    }
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
    ], { cancelable: false });
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
        const index = assistant ? current.findIndex(message => message.id === assistant.id) : -1;
        return index >= 0 ? current.slice(0, index) : current;
      });
      setSending(true);
      setLifecycleState('streaming');
      const controller = new AbortController();
      abortControllerRef.current = controller;
      let assistantText = '';
      let assistantId: string | undefined;
      await streamSHRuntime(lastUser.text, event => {
        if (!mountedRef.current) return;
        if (event.type === 'token') {
          assistantText += event.text;
          setMessages(current => {
            const next = [...current];
            const last = next[next.length - 1];
            if (last?.role === 'assistant' && last.id === assistantId) last.text = assistantText;
            else {
              assistantId = `regen-${Date.now()}`;
              next.push(makeMessage('assistant', assistantText, assistantId));
            }
            return next;
          });
        }
        if (event.type === 'response') {
          assistantText = event.text;
          setMessages(current => {
            const next = [...current];
            const last = next[next.length - 1];
            if (last?.role === 'assistant' && last.id === assistantId) last.text = assistantText;
            else next.push(makeMessage('assistant', assistantText, assistantId ?? `regen-${Date.now()}`));
            return next;
          });
        }
        if (event.type === 'complete') setLifecycleState('active');
      }, controller.signal);
      const refreshed = buildVirtualSessions((await loadConversationHistoryRows(100)).filter(row => row?.content && !isVerificationArtifact(row)));
      const latest = refreshed[0];
      if (latest) { setCurrentConversationId(latest.id); setConversationTitle(latest.title || conversationTitle); setMessages(latest.rows.map(messageFromRow)); }
    } catch (error) {
      Alert.alert('Regenerate failed', error instanceof Error ? error.message : 'Regenerate failed');
    } finally {
      abortControllerRef.current = null;
      setSending(false);
      setLifecycleState('active');
    }
  }

  function openMessageActions(message: Message) {
    setMessageActionTarget(message);
  }

  function closeMessageActions() {
    setMessageActionTarget(null);
  }

  async function handleAttachment(kind: 'File' | 'Photo' | 'Camera') {
    setAttachmentState('preparing');
    setAttachmentError(null);
    try {
      if (kind === 'Photo') {
        const permission = await ImagePicker.requestMediaLibraryPermissionsAsync();
        if (!permission.granted) return Alert.alert('Photo', 'Izin galeri diperlukan untuk memilih foto.');
        const result = await ImagePicker.launchImageLibraryAsync({ mediaTypes: ['images'], base64: true, quality: 0.85, selectionLimit: 1 });
        if (result.canceled || !result.assets?.[0]) return;
        const asset = result.assets[0];
        if (!asset.base64) throw new Error('Photo data could not be read.');
        setAttachments(current => [...current, { uri: asset.uri, name: asset.fileName ?? 'photo.jpg', mimeType: asset.mimeType ?? 'image/jpeg', base64: asset.base64 ?? undefined }]);
        setAttachmentState('ready');
        return;
      }
      if (kind === 'Camera') {
        const permission = await ImagePicker.requestCameraPermissionsAsync();
        if (!permission.granted) return Alert.alert('Camera', 'Izin kamera diperlukan untuk mengambil foto.');
        const result = await ImagePicker.launchCameraAsync({ mediaTypes: ['images'], base64: true, quality: 0.85 });
        if (result.canceled || !result.assets?.[0]) return;
        const asset = result.assets[0];
        if (!asset.base64) throw new Error('Camera image data could not be read.');
        setAttachments(current => [...current, { uri: asset.uri, name: asset.fileName ?? 'camera.jpg', mimeType: asset.mimeType ?? 'image/jpeg', base64: asset.base64 ?? undefined }]);
        setAttachmentState('ready');
        return;
      }
      const result = await DocumentPicker.getDocumentAsync({ type: '*/*', copyToCacheDirectory: true, multiple: false });
      if (result.canceled || !result.assets?.[0]) return;
      const asset = result.assets[0];
      const base64 = await FileSystem.readAsStringAsync(asset.uri, { encoding: FileSystem.EncodingType.Base64 });
      setAttachments(current => [...current, { uri: asset.uri, name: asset.name, mimeType: asset.mimeType ?? 'application/octet-stream', base64 }]);
      setAttachmentState('ready');
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Attachment could not be prepared.';
      setAttachmentState('failed');
      setAttachmentError(message);
      Alert.alert('Attachment failed', message);
    }
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
    <>
      <Modal visible={memoryOpen} transparent animationType="slide" onRequestClose={() => setMemoryOpen(false)}>
        <View style={{ flex: 1, justifyContent: 'flex-end', backgroundColor: 'rgba(0,0,0,0.35)' }}>
          <View style={{ maxHeight: '78%', backgroundColor: '#FFFFFF', padding: 16, gap: 10, borderTopLeftRadius: 20, borderTopRightRadius: 20 }}>
            <View style={{ flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between' }}>
              <View><Text style={{ fontSize: 20, fontWeight: '800', color: '#22211F' }}>Memory</Text><Text style={{ color: '#6B6A66', marginTop: 3 }}>Authorized owner context · bounded</Text></View>
              <Button title="Close" onPress={() => setMemoryOpen(false)} />
            </View>
            {memoryLoading ? <View style={{ paddingVertical: 24, alignItems: 'center' }}><Text style={{ color: '#6B6A66' }}>Loading Memory…</Text></View> : null}
            {memoryError ? <View style={{ borderWidth: 1, borderColor: '#E3E1DC', borderRadius: 12, padding: 12 }}><Text style={{ color: '#9A3412', fontWeight: '700' }}>Memory unavailable</Text><Text style={{ color: '#6B6A66', marginTop: 4 }}>{memoryError}</Text></View> : null}
            {!memoryLoading && !memoryError && memoryRows.length === 0 ? <View style={{ paddingVertical: 24, alignItems: 'center' }}><Text style={{ color: '#6B6A66' }}>Tidak ada Memory yang relevan untuk context ini.</Text></View> : null}
            {!memoryLoading && !memoryError ? <ScrollView contentContainerStyle={{ gap: 8 }}>{memoryRows.map((row, index) => {
              const content = typeof row.content === 'string' ? row.content : typeof row.text === 'string' ? row.text : JSON.stringify(row);
              const source = typeof row.source_ref === 'string' ? row.source_ref : typeof row.provenance === 'string' ? row.provenance : 'Memory runtime';
              return <View key={String(row.memory_id ?? row.id ?? index)} style={{ borderWidth: 1, borderColor: '#E3E1DC', borderRadius: 14, padding: 12, backgroundColor: '#FBFAF7', gap: 5 }}><Text style={{ color: '#22211F', lineHeight: 20 }}>{content}</Text><Text style={{ color: '#77736B', fontSize: 11 }}>Source: {source}</Text></View>;
            })}</ScrollView> : null}
          </View>
        </View>
      </Modal>
      <Modal visible={messageActionTarget !== null} transparent animationType="fade" onRequestClose={() => {}}>
        <View style={{ flex: 1, justifyContent: 'flex-end', backgroundColor: 'rgba(0,0,0,0.35)' }}>
          <View style={{ backgroundColor: '#FFFFFF', padding: 16, gap: 8, borderTopLeftRadius: 18, borderTopRightRadius: 18 }}>
            <Text style={{ fontSize: 18, fontWeight: '700', color: '#111827' }}>
              {messageActionTarget?.role === 'user' ? 'Your message' : 'SH response'}
            </Text>
            <Button title="Copy" onPress={() => { const target = messageActionTarget; closeMessageActions(); if (target) void copyMessage(target); }} />
            {messageActionTarget?.role === 'user' ? <Button title="Edit" onPress={() => { const target = messageActionTarget; closeMessageActions(); if (target) editMessage(target); }} /> : null}
            <Button title="Delete" onPress={() => { const target = messageActionTarget; closeMessageActions(); if (target) deleteMessage(target.id); }} />
            {messageActionTarget?.role === 'assistant' ? <Button title="Regenerate" onPress={() => { closeMessageActions(); void regenerateResponse(); }} /> : null}
            <Button title="Cancel" onPress={closeMessageActions} />
          </View>
        </View>
      </Modal>
      <Modal visible={renameOpen} transparent animationType="fade" onRequestClose={() => {}}>
        <View style={{ flex: 1, justifyContent: 'center', padding: 24, backgroundColor: 'rgba(0,0,0,0.35)' }}>
          <View style={{ borderRadius: 16, padding: 16, backgroundColor: '#FFFFFF', gap: 12 }}>
            <Text style={{ fontSize: 18, fontWeight: '700', color: '#111827' }}>Rename conversation</Text>
            <TextInput
              value={renameText}
              onChangeText={setRenameText}
              autoFocus
              placeholder="New conversation name"
              placeholderTextColor="#6B7280"
              style={inputStyle}
            />
            <View style={{ flexDirection: 'row', justifyContent: 'flex-end', gap: 8 }}>
              <Button title="Cancel" onPress={() => setRenameOpen(false)} />
              <Button title="Rename" onPress={() => void saveRename()} disabled={!renameText.trim()} />
            </View>
          </View>
        </View>
      </Modal>
      <SHShell title="Chat" context={<>
        <View style={{ gap: 5 }}><Text style={{ fontSize: 13, fontWeight: '800', color: '#5D45A5' }}>CURRENT</Text><Text style={{ fontSize: 16, fontWeight: '700', color: '#22211F' }}>{conversationTitle}</Text><Text style={{ color: '#6B6A66' }}>{lifecycleState === 'streaming' ? 'SH sedang memproses percakapan.' : 'Conversation context.'}</Text></View>
        <View style={{ borderWidth: 1, borderColor: '#E3E1DC', borderRadius: 14, padding: 13, gap: 5, backgroundColor: '#FFFFFF' }}><Text style={{ fontWeight: '800', color: '#22211F' }}>Journey</Text><Text style={{ color: '#6B6A66' }}>Continuity surface tersedia dari navigation.</Text></View>
        <View style={{ borderWidth: 1, borderColor: '#E3E1DC', borderRadius: 14, padding: 13, gap: 5, backgroundColor: '#FFFFFF' }}><Text style={{ fontWeight: '800', color: '#22211F' }}>Memory</Text><Text style={{ color: '#6B6A66' }}>Bounded owner context tersedia dari Runtime.</Text><Button title="Open Memory" onPress={() => void openMemorySurface()} /></View>
        <View style={{ borderWidth: 1, borderColor: '#E3E1DC', borderRadius: 14, padding: 13, gap: 5, backgroundColor: '#FFFFFF' }}><Text style={{ fontWeight: '800', color: '#22211F' }}>Memory · Knowledge · Experience</Text><Text style={{ color: '#6B6A66' }}>Contextual domains — bukan top-level navigation.</Text></View>
        {attachments.length ? <View style={{ borderWidth: 1, borderColor: '#E3E1DC', borderRadius: 14, padding: 13, gap: 5, backgroundColor: '#FFFFFF' }}><Text style={{ fontWeight: '800', color: '#22211F' }}>Attachments</Text><Text style={{ color: '#6B6A66' }}>{attachments.length} selected</Text></View> : null}
      </>}><View style={{ flex: 1, backgroundColor: '#F8FAFC' }}>
      <View style={{ paddingHorizontal: 16, paddingTop: 18, paddingBottom: 10, borderBottomWidth: 1, borderBottomColor: '#E5E7EB', backgroundColor: '#FFFFFF' }}>
        <View style={{ flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between' }}>
          <View style={{ flex: 1, marginRight: 12 }}>
            <View style={{ flex: 1, marginRight: 12 }}>
            <Text style={{ fontSize: 20, fontWeight: '700', color: '#111827' }}>{conversationTitle}</Text>
            <Text style={{ color: '#6B7280', marginTop: 3 }}>Second Head · {lifecycleState}</Text>
          </View>
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
          {findQuery ? <View style={{ gap: 6 }}>
            <Text style={{ color: '#6B7280' }}>{visibleMatches.length ? `Match ${Math.min(findIndex + 1, visibleMatches.length)} / ${visibleMatches.length}` : '0 pesan cocok'}</Text>
            {visibleMatches.length ? <Button title="Jump to match" onPress={() => { setFindIndex(index => (index + 1) % visibleMatches.length); setTimeout(() => {}, 0); }} /> : null}
            {visibleMatches.length ? <Text style={{ color: '#111827' }}>Pesan: {visibleMatches[findIndex % visibleMatches.length].message.text.slice(0, 100)}</Text> : null}
          </View> : null}
          <Button title="Close find" onPress={() => { setFindOpen(false); setFindQuery(''); }} />
        </View> : null}
      </View>

      <ScrollView style={{ flex: 1 }} contentContainerStyle={{ padding: 16, gap: 12 }}>
        {messages.length === 0 ? <View style={{ paddingVertical: 50, alignItems: 'center' }}><Text style={{ fontSize: 24, fontWeight: '700', color: '#111827' }}>Start a chat</Text><Text style={{ color: '#6B7280', marginTop: 8 }}>Ngobrol biasa. SH Core yang memilah konteksnya.</Text></View> : null}
        {messages.map(message => <View key={message.id} style={{ alignItems: message.role === 'user' ? 'flex-end' : 'flex-start' }}>
          <View style={{ maxWidth: '88%', borderRadius: 16, padding: 12, backgroundColor: message.role === 'user' ? '#E0F2FE' : '#FFFFFF', borderWidth: 1, borderColor: '#E5E7EB' }}>
            <Text style={{ fontSize: 12, fontWeight: '700', color: '#6B7280', marginBottom: 5 }}>{message.role === 'user' ? 'You' : message.role === 'assistant' ? 'SH' : 'System'}</Text>
            {message.attachmentName ? <Text style={{ color: '#374151', marginBottom: 6 }}>📎 {message.attachmentName}</Text> : null}
            {editingId === message.id ? <View style={{ gap: 8 }}><TextInput value={editingText} onChangeText={setEditingText} multiline style={inputStyle} /><View style={{ flexDirection: 'row', gap: 8 }}><Button title="Save" onPress={saveEditedMessage} /><Button title="Cancel" onPress={() => { setEditingId(null); setEditingText(''); }} /></View></View> : <Text style={{ color: '#111827', lineHeight: 21 }}>{message.text || (sending && message.role === 'assistant' ? 'SH is thinking…' : '')}</Text>}
            {!editingId && message.text ? <View style={{ alignItems: 'flex-end', marginTop: 6 }}><Button title="⋮" onPress={() => openMessageActions(message)} /></View> : null}
          </View>
        </View>)}
        {pendingConfirmation ? <View style={{ borderWidth: 1, borderRadius: 12, padding: 12, backgroundColor: '#FFFFFF', gap: 8 }}><Text style={{ fontSize: 18, fontWeight: '700' }}>{pendingConfirmation.title}</Text><Text>{pendingConfirmation.description}</Text><Text>Action: {pendingConfirmation.action_id}</Text><View style={{ flexDirection: 'row', gap: 8 }}><Button title="Cancel" onPress={cancelConfirmation} /><Button title="Confirm" onPress={confirmConfirmation} /></View></View> : null}
        {confirmationState !== 'idle' ? <Text>{confirmationState === 'cancelled' ? 'High-risk confirmation cancelled.' : 'Explicit confirmation recorded; no App-side authorization or execution occurred.'}</Text> : null}
      </ScrollView>

      <View style={{ padding: 12, borderTopWidth: 1, borderTopColor: '#E5E7EB', backgroundColor: '#FFFFFF', gap: 8 }}>
        {attachments.length ? <View style={{ borderWidth: 1, borderColor: attachmentState === 'failed' ? '#D97706' : '#E3E1DC', borderRadius: 12, padding: 10, backgroundColor: '#FBFAF7', gap: 6 }}>
          {attachments.map((item, index) => <Text key={String(index)} style={{ color: '#374151', fontWeight: '700' }}>📎 {item.name ?? 'Attachment'}</Text>)}
          <Text style={{ color: attachmentState === 'failed' ? '#B45309' : '#6B6A66', fontSize: 12 }}>
            {attachmentState === 'preparing' ? 'Preparing attachment…' : attachmentState === 'ready' ? 'Ready to send' : attachmentState === 'failed' ? (attachmentError ?? 'Attachment failed') : ''}
          </Text>
          {attachmentState !== 'preparing' ? <View style={{ flexDirection: 'row', gap: 8 }}><Button title="Remove all" onPress={() => { setAttachments([]); setAttachmentState('idle'); setAttachmentError(null); }} /><Button title="Replace" onPress={() => Alert.alert('Replace attachment', 'Pilih attachment baru', [{ text: 'File', onPress: () => void handleAttachment('File') }, { text: 'Photo', onPress: () => void handleAttachment('Photo') }, { text: 'Camera', onPress: () => void handleAttachment('Camera') }, { text: 'Cancel', style: 'cancel' }], { cancelable: false })} /></View> : null}
        </View> : null}
        <View style={{ flexDirection: 'row', alignItems: 'flex-end', gap: 8 }}>
          <View style={{ gap: 4 }}>
            <Button title="＋" onPress={() => Alert.alert('Attach', 'Pilih attachment', [
              { text: 'File', onPress: () => void handleAttachment('File') },
              { text: 'Photo', onPress: () => void handleAttachment('Photo') },
              { text: 'Camera', onPress: () => void handleAttachment('Camera') },
              { text: 'Cancel', style: 'cancel' },
            ], { cancelable: false })} />
          </View>
          <TextInput value={draft} onChangeText={setDraft} placeholder="Message SH…" placeholderTextColor="#6B7280" multiline editable={!sending && lifecycleState === 'active'} style={[inputStyle, { flex: 1, maxHeight: 130 }]} />
          {sending ? <Button title="Stop" onPress={cancelStreaming} /> : <Button title="Send" onPress={() => void onSend()} disabled={!canSend} />}
        </View>
      </View>
      </View></SHShell>
    </>
  );
}
