import { useCallback, useEffect, useMemo, useState } from 'react';
import { ActivityIndicator, Button, FlatList, Modal, RefreshControl, StyleSheet, Text, View } from 'react-native';
import { Redirect, router } from 'expo-router';
import { useAuth } from '../state/auth-context';
import { loadJourneyEvents, type JourneyEvent } from '../features/journey/journey-service';

function formatDate(value: string) {
  const date = new Date(value);
  return Number.isNaN(date.getTime()) ? value : date.toLocaleString();
}

function humanize(value: string) {
  return value.replaceAll('_', ' ');
}

function payloadText(payload: Record<string, unknown> | null) {
  if (!payload) return 'Tidak ada isi tambahan pada event ini.';
  const candidates = ['content', 'text', 'message', 'captured_text', 'summary'];
  for (const key of candidates) {
    const value = payload[key];
    if (typeof value === 'string' && value.trim()) return value;
  }
  return JSON.stringify(payload, null, 2);
}

export default function JourneyScreen() {
  const { session, context } = useAuth();
  const primarySH = context?.shInstances.find((item) => item.is_primary) ?? context?.shInstances[0];
  const [events, setEvents] = useState<JourneyEvent[]>([]);
  const [selected, setSelected] = useState<JourneyEvent | null>(null);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const load = useCallback(async () => {
    if (!primarySH) return;
    try {
      setError(null);
      setEvents(await loadJourneyEvents(primarySH.sh_id));
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Unable to load Journey');
    } finally {
      setLoading(false);
    }
  }, [primarySH]);

  useEffect(() => {
    void load();
  }, [load]);

  const header = useMemo(() => (
    <View style={styles.header}>
      <Text style={styles.title}>Journey</Text>
      <Text style={styles.subtitle}>{primarySH?.canonical_name ?? primarySH?.sh_id ?? 'SH'}</Text>
      <Text style={styles.description}>Continuity and lifecycle events for this Second Head.</Text>
      <Text style={styles.hint}>Tap an event to see what happened and what was recorded.</Text>
      {error ? <Text style={styles.error}>{error}</Text> : null}
      {events.length === 0 && !loading && !error ? (
        <View style={styles.empty}><Text style={styles.emptyTitle}>No Journey events yet</Text><Text style={styles.emptyText}>Events will appear here as continuity activity is recorded.</Text></View>
      ) : null}
    </View>
  ), [error, events.length, loading, primarySH]);

  if (!session) return <Redirect href="/login" />;
  if (!context) return <View style={styles.center}><ActivityIndicator /></View>;
  if (!primarySH) return <View style={styles.center}><Text>No SH instance is available for this account.</Text></View>;
  if (loading) return <View style={styles.center}><ActivityIndicator /><Text style={styles.loadingText}>Loading Journey…</Text></View>;

  return (
    <View style={styles.screen}>
      <FlatList
        data={events}
        keyExtractor={(item) => item.event_id}
        ListHeaderComponent={header}
        contentContainerStyle={styles.content}
        refreshControl={<RefreshControl refreshing={refreshing} onRefresh={async () => { setRefreshing(true); await load(); setRefreshing(false); }} />}
        renderItem={({ item }) => (
          <View style={styles.event}>
            <View style={styles.marker} />
            <View style={styles.eventBody}>
              <View style={styles.eventTop}>
                <Text style={styles.eventType}>{humanize(item.event_type)}</Text>
                <Text style={styles.date}>{formatDate(item.occurred_at)}</Text>
              </View>
              <Text style={styles.status}>{humanize(item.continuity_status)}</Text>
              {item.gap_code ? <Text style={styles.gap}>Gap: {humanize(item.gap_code)}</Text> : null}
              {item.source_ref ? <Text style={styles.source}>Source: {item.source_ref}</Text> : null}
              <Button title="View details" onPress={() => setSelected(item)} />
            </View>
          </View>
        )}
        ListFooterComponent={<View style={styles.footer}><Button title="Back to Home" onPress={() => router.replace('/')} /></View>}
      />

      <Modal visible={!!selected} animationType="slide" transparent onRequestClose={() => setSelected(null)}>
        {selected ? (
          <View style={styles.modalBackdrop}>
            <View style={styles.modalCard}>
              <Text style={styles.modalTitle}>{humanize(selected.event_type)}</Text>
              <Text style={styles.modalDate}>{formatDate(selected.occurred_at)}</Text>

              <Text style={styles.label}>Status</Text>
              <Text>{humanize(selected.continuity_status)}</Text>

              <Text style={styles.label}>What was recorded</Text>
              <Text selectable>{payloadText(selected.payload)}</Text>

              <Text style={styles.label}>Visibility</Text>
              <Text>{humanize(selected.visibility)}</Text>

              <Text style={styles.label}>Transfer policy</Text>
              <Text>{humanize(selected.transfer_policy)}</Text>

              {selected.source_ref ? <><Text style={styles.label}>Source</Text><Text selectable>{selected.source_ref}</Text></> : null}
              {selected.gap_code ? <><Text style={styles.label}>Gap</Text><Text>{humanize(selected.gap_code)}</Text></> : null}

              <View style={styles.modalActions}>
                <Button title="Close" onPress={() => setSelected(null)} />
              </View>
            </View>
          </View>
        ) : null}
      </Modal>
    </View>
  );
}

const styles = StyleSheet.create({
  screen: { flex: 1, backgroundColor: '#f7f7f7' },
  content: { padding: 20, paddingBottom: 36 },
  header: { marginBottom: 20 },
  title: { fontSize: 32, fontWeight: '800', marginBottom: 4 },
  subtitle: { fontSize: 16, fontWeight: '600', marginBottom: 8 },
  description: { fontSize: 14, color: '#555' },
  hint: { marginTop: 10, fontSize: 14, color: '#333' },
  error: { marginTop: 12, color: '#a11' },
  empty: { marginTop: 20, padding: 18, borderRadius: 12, backgroundColor: '#fff' },
  emptyTitle: { fontSize: 16, fontWeight: '700', marginBottom: 6 },
  emptyText: { color: '#666' },
  event: { flexDirection: 'row', marginBottom: 12, padding: 16, borderRadius: 12, backgroundColor: '#fff' },
  marker: { width: 8, borderRadius: 4, marginRight: 12, backgroundColor: '#222' },
  eventBody: { flex: 1, gap: 6 },
  eventTop: { gap: 4 },
  eventType: { fontSize: 16, fontWeight: '700' },
  date: { fontSize: 12, color: '#666' },
  status: { marginTop: 2, fontSize: 13, fontWeight: '600' },
  gap: { fontSize: 12, color: '#8a4b00' },
  source: { fontSize: 12, color: '#666' },
  center: { flex: 1, alignItems: 'center', justifyContent: 'center', padding: 24, gap: 12 },
  loadingText: { marginTop: 8 },
  footer: { marginTop: 12 },
  modalBackdrop: { flex: 1, justifyContent: 'flex-end', backgroundColor: 'rgba(0,0,0,0.35)' },
  modalCard: { maxHeight: '85%', backgroundColor: '#fff', borderTopLeftRadius: 20, borderTopRightRadius: 20, padding: 22, gap: 8 },
  modalTitle: { fontSize: 24, fontWeight: '800' },
  modalDate: { color: '#666', marginBottom: 8 },
  label: { marginTop: 8, fontWeight: '700' },
  modalActions: { marginTop: 12 },
});
