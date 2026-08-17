import { useEffect, useRef, useState } from 'react';
import { AppState, Button, ScrollView, Text, TextInput, View } from 'react-native';
import { loadConversationHistory, streamSHRuntime } from '../services/runtime-stream';
import { supabase } from '../services/supabase';
import { loadAuthenticatedContext } from '../services/account';

type PendingConfirmation = {
  confirmation_id: string;
  action_id: string;
  title: string;
  description: string;
};

type ChatLifecycleState =
  | 'active'
  | 'background'
  | 'idle'
  | 'streaming'
  | 'cancelled'
  | 'error';

export default function ChatScreen() {
  const [draft, setDraft] = useState('');
  const [messages, setMessages] = useState<string[]>([]);
  const [sending, setSending] = useState(false);
  const [pendingConfirmation, setPendingConfirmation] =
    useState<PendingConfirmation | null>(null);
  const [confirmationState, setConfirmationState] = useState<
    'idle' | 'cancelled' | 'confirmed'
  >('idle');
  const [lifecycleState, setLifecycleState] =
    useState<ChatLifecycleState>('active');
  const [lastUserMessage, setLastUserMessage] = useState<string | null>(null);
  const [journeyCaptureState, setJourneyCaptureState] = useState<
    'idle' | 'saving' | 'saved' | 'error'
  >('idle');

  const abortControllerRef = useRef<AbortController | null>(null);
  const mountedRef = useRef(true);

  useEffect(() => {
    mountedRef.current = true;

    void loadConversationHistory()
      .then((history) => {
        if (mountedRef.current && history.length > 0) {
          setMessages(history);
        }
      })
      .catch(() => {
        // History loading must not block the chat UI from opening.
      });

    const subscription = AppState.addEventListener('change', (nextState) => {
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

      if (abortControllerRef.current) {
        abortControllerRef.current.abort();
        abortControllerRef.current = null;
      }
    };
  }, []);

  async function onSend() {
    const message = draft.trim();

    if (
      !message ||
      sending ||
      pendingConfirmation ||
      lifecycleState === 'background'
    ) {
      return;
    }

    const controller = new AbortController();
    abortControllerRef.current = controller;

    setDraft('');
    setLastUserMessage(message);
    setJourneyCaptureState('idle');
    setSending(true);
    setLifecycleState('streaming');
    setConfirmationState('idle');

    setMessages((current) => [
      ...current,
      `You: ${message}`,
      'SH: ',
    ]);

    try {
      await streamSHRuntime(
        message,
        (event) => {
          if (!mountedRef.current) return;

          if (event.type === 'token') {
            setMessages((current) => {
              if (current.length === 0) return current;

              const next = [...current];
              next[next.length - 1] = `${next[next.length - 1]}${event.text}`;
              return next;
            });
          }

          if (event.type === 'response') {
            setMessages((current) => {
              if (current.length === 0) return current;

              const next = [...current];
              if (event.text) next[next.length - 1] = `SH: ${event.text}`;
              return next;
            });
          }

          if (event.type === 'confirmation') {
            setPendingConfirmation(event);
            setConfirmationState('idle');
          }

          if (event.type === 'complete') {
            setLifecycleState('idle');
          }
        },
        controller.signal,
      );
    } catch (error) {
      if (!mountedRef.current) return;

      if (controller.signal.aborted) {
        setLifecycleState('cancelled');
        setMessages((current) => [
          ...current,
          'SH: Streaming cancelled because the App left the foreground or the request was cancelled.',
        ]);
        return;
      }

      const text =
        error instanceof Error ? error.message : 'Chat streaming failed';

      setLifecycleState('error');
      setMessages((current) => [...current, `Error: ${text}`]);
    } finally {
      if (abortControllerRef.current === controller) {
        abortControllerRef.current = null;
      }

      if (mountedRef.current) {
        setSending(false);
        setLifecycleState((current) =>
          current === 'streaming' ? 'idle' : current,
        );
      }
    }
  }

  async function saveLastMessageToJourney() {
    if (!lastUserMessage || sending || journeyCaptureState === 'saving') return;

    setJourneyCaptureState('saving');
    try {
      const context = await loadAuthenticatedContext();
      const shId = context?.shInstances[0]?.sh_id;
      if (!shId) throw new Error('JOURNEY_SH_ID_REQUIRED');

      const { error } = await supabase.rpc('runtime_record_journey_event', {
        p_sh_id: shId,
        p_event_type: 'EXPERIENCE',
        p_occurred_at: new Date().toISOString(),
        p_continuity_status: 'CONTINUOUS',
        p_gap_code: null,
        p_payload: {
          representation: lastUserMessage,
          capture_mode: 'EXPLICIT_USER',
        },
        p_source_ref: 'app:chat:explicit_journey_capture',
      });

      if (error) throw error;
      setJourneyCaptureState('saved');
    } catch {
      setJourneyCaptureState('error');
    }
  }

  function cancelStreaming() {
    if (!abortControllerRef.current) return;

    abortControllerRef.current.abort();
    abortControllerRef.current = null;
    setSending(false);
    setLifecycleState('cancelled');
  }

  function cancelConfirmation() {
    setPendingConfirmation(null);
    setConfirmationState('cancelled');
    setMessages((current) => [
      ...current,
      'SH: High-risk action cancelled.',
    ]);
  }

  function confirmConfirmation() {
    setPendingConfirmation(null);
    setConfirmationState('confirmed');
    setMessages((current) => [
      ...current,
      'SH: Confirmation recorded; Runtime authorization is still required.',
    ]);
  }

  const canSend =
    lifecycleState === 'active' &&
    !sending &&
    !pendingConfirmation &&
    !!draft.trim();

  return (
    <View style={{ flex: 1, padding: 20, gap: 12 }}>
      <Text style={{ fontSize: 28, fontWeight: '700' }}>
        SH Chat
      </Text>

      <Text>
        App → authenticated Runtime → lifecycle-aware streaming
      </Text>

      <Text>
        State: {lifecycleState}
      </Text>

      <ScrollView
        style={{ flex: 1 }}
        contentContainerStyle={{
          gap: 12,
          paddingVertical: 12,
        }}
      >
        {messages.length === 0 ? (
          <Text>
            Tulis pesan untuk menguji streaming SH.
          </Text>
        ) : null}

        {messages.map((item, index) => (
          <Text key={`${index}-${item}`}>
            {item}
          </Text>
        ))}
      </ScrollView>

      {lastUserMessage && !sending ? (
        <View style={{ gap: 6 }}>
          <Button
            title={journeyCaptureState === 'saving'
              ? 'Saving to Journey...'
              : 'SAVE LAST MESSAGE TO JOURNEY'}
            onPress={() => void saveLastMessageToJourney()}
            disabled={journeyCaptureState === 'saving'}
          />
          {journeyCaptureState === 'saved' ? (
            <Text>Journey event saved.</Text>
          ) : null}
          {journeyCaptureState === 'error' ? (
            <Text>Journey capture failed.</Text>
          ) : null}
        </View>
      ) : null}

      {pendingConfirmation ? (
        <View
          style={{
            gap: 8,
            borderWidth: 1,
            borderRadius: 10,
            padding: 12,
          }}
        >
          <Text
            style={{
              fontSize: 18,
              fontWeight: '700',
            }}
          >
            {pendingConfirmation.title}
          </Text>

          <Text>{pendingConfirmation.description}</Text>

          <Text>
            Action: {pendingConfirmation.action_id}
          </Text>

          <Text>
            SH App hanya mengumpulkan konfirmasi.
            Runtime tetap pemilik authorization.
          </Text>

          <Button
            title="Cancel"
            onPress={cancelConfirmation}
          />

          <Button
            title="Confirm"
            onPress={confirmConfirmation}
          />
        </View>
      ) : null}

      {confirmationState !== 'idle' ? (
        <Text accessibilityRole="text">
          {confirmationState === 'cancelled'
            ? 'High-risk confirmation cancelled.'
            : 'Explicit confirmation recorded; no App-side authorization or execution occurred.'}
        </Text>
      ) : null}

      {sending ? (
        <Button
          title="Cancel streaming"
          onPress={cancelStreaming}
        />
      ) : null}

      <TextInput
        value={draft}
        onChangeText={setDraft}
        placeholder="Tulis pesan..."
        multiline
        editable={!sending && lifecycleState === 'active'}
        style={{
          minHeight: 54,
          borderWidth: 1,
          borderRadius: 10,
          padding: 12,
        }}
      />

      <Button
        title={sending ? 'Streaming...' : 'Kirim'}
        onPress={() => void onSend()}
        disabled={!canSend}
      />
    </View>
  );
}
