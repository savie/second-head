import { useCallback, useEffect, useMemo, useState } from 'react';
import { ActivityIndicator, Button, FlatList, Modal, Pressable, RefreshControl, StyleSheet, Text, View } from 'react-native';
import { Redirect, router } from 'expo-router';
import { useAuth } from '../state/auth-context';
import { loadJourneyEvents, type JourneyEvent } from '../features/journey/journey-service';

const FILTERS = ['All', 'Memory', 'Knowledge', 'Experience', 'Lifecycle / Other'] as const;
type Filter = typeof FILTERS[number];

function formatDate(value: string) {
  const date = new Date(value);
  return Number.isNaN(date.getTime()) ? value : date.toLocaleString();
}

function humanize(value: string) {
  return value.replaceAll('_', ' ');
}

function category(item: JourneyEvent): Filter {
  const type = item.event_type.toUpperCase();
  const source = (item.source_ref ?? '').toUpperCase();
  if (type.includes('MEMORY') || source.includes('MEMORY')) return 'Memory';
  if (type.includes('KNOWLEDGE') || source.includes('KNOWLEDGE')) return 'Knowledge';
  if (type.includes('EXPERIENCE') || source.includes('EXPERIENCE')) return 'Experience';
  return 'Lifecycle / Other';
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
  const [filter, setFilter] = useState<Filter>('All');
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

  useEffect(() => { void load(); }, [load]);

  const filteredEvents = useMemo(
    () => filter === 'All' ? events : events.filter((item) => category(item) === filter),
    [events, filter],
  );

  const header = useMemo(() => (
    <View style={styles.header}>
      <Text style={styles.title}>Journey</Text>
      <Text style={styles.subtitle}>{primarySH?.canonical_name ?? primarySH?.sh_id ?? 'SH'}</Text>
      <Text style={styles.description}>Continuity and lifecycle history for this Second Head.</Text>
      <Text style={styles.hint}>Pilih kategori lalu ketuk event untuk melihat isi sebenarnya.</Text>
      <View style={styles.filters}>
        {FILTERS.map((item) => (
          <Pressable key={item} onPress={() => setFilter(item)} style={[styles.filter, filter === item && styles.filterActive]}>
            <Text style={[styles.filterText, filter === item && styles.filterTextActive]}>{item}</Text>
          </Pressable>
        ))}
      </View>
      {error ? <Text style={styles.error}>{error}</Text> : null}
      {filteredEvents.length === 0 && !loading && !error ? <View style={styles.empty}><Text style={styles.emptyTitle}>No events in this category</Text><Text style={styles.emptyText}>Coba All atau refresh Journey.</Text></View> : null}
    </View>
  ), [error, filter, filteredEvents.length, loading, primarySH]);

  if (!session) return <Redirect href="/login" />;
  if (!context) return <View style={styles.center}><ActivityIndicator /></View>;
  if (!primarySH) return <View style={styles.center}><Text>No SH instance is available for this account.</Text></View>;
  if (loading) return <View style={styles.center}><ActivityIndicator /><Text style={styles.loadingText}>Loading Journey…</Text></View>;

  return (
    <View style={styles.screen}>
      <FlatList
        data={filteredEvents}
        keyExtractor={(item) => item.event_id}
        ListHeaderComponent={header}
        contentContainerStyle={styles.content}
        refreshControl={<RefreshControl refreshing={refreshing} onRefresh={async () => { setRefreshing(true); await load(); setRefreshing(false); }} />}
        renderItem={({ item }) => (
          <Pressable style={styles.event} onPress={() => setSelected(item)}>
            <View style={styles.marker} />
            <View style={styles.eventBody}>
              <View style={styles.eventTop}><Text style={styles.eventType}>{humanize(item.event_type)}</Text><Text style={styles.date}>{formatDate(item.occurred_at)}</Text></View>
              <Text style={styles.status}>{humanize(item.continuity_status)}</Text>
              <Text numberOfLines={2} style={styles.preview}>{payloadText(item.payload)}</Text>
              {item.source_ref ? <Text style={styles.source}>Source: {item.source_ref}</Text> : null}
              <Text style={styles.view}>Tap to view details →</Text>
            </View>
          </Pressable>
        )}
      />

      <Modal visible={!!selected} animationType="slide" transparent onRequestClose={() => setSelected(null)}>
        {selected ? (
          <View style={styles.modalBackdrop}>
            <View style={styles.modalCard}>
              <Text style={styles.modalTitle}>{humanize(selected.event_type)}</Text>
              <Text style={styles.modalDate}>{formatDate(selected.occurred_at)}</Text>
              <Text style={styles.label}>What happened</Text><Text selectable>{payloadText(selected.payload)}</Text>
              <Text style={styles.label}>Status</Text><Text>{humanize(selected.continuity_status)}</Text>
              <Text style={styles.label}>Visibility</Text><Text>{humanize(selected.visibility)}</Text>
              <Text style={styles.label}>Policy</Text><Text>{humanize(selected.transfer_policy)}</Text>
              {selected.source_ref ? <><Text style={styles.label}>Source</Text><Text selectable>{selected.source_ref}</Text></> : null}
              {selected.gap_code ? <><Text style={styles.label}>Gap</Text><Text>{humanize(selected.gap_code)}</Text></> : null}
              <View style={styles.modalActions}><Button title="Close" onPress={() => setSelected(null)} /></View>
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
  header: { marginBottom: 16 },
  title: { fontSize: 32, fontWeight: '800', marginBottom: 4 },
  subtitle: { fontSize: 16, fontWeight: '600', marginBottom: 8 },
  description: { fontSize: 14, color: '#555' },
  hint: { marginTop: 10, fontSize: 14, color: '#333' },
  filters: { flexDirection: 'row', flexWrap: 'wrap', gap: 8, marginTop: 14 },
  filter: { borderWidth: 1, borderColor: '#bbb', borderRadius: 20, paddingHorizontal: 12, paddingVertical: 8, backgroundColor: '#fff' },
  filterActive: { backgroundColor: '#111', borderColor: '#111' },
  filterText: { color: '#222' },
  filterTextActive: { color: '#fff', fontWeight: '700' },
  error: { marginTop: 12, color: '#a11' },
  empty: { marginTop: 16, padding: 18, borderRadius: 12, backgroundColor: '#fff' },
  emptyTitle: { fontSize: 16, fontWeight: '700', marginBottom: 6 },
  emptyText: { color: '#666' },
  event: { flexDirection: 'row', marginBottom: 12, padding: 16, borderRadius: 12, backgroundColor: '#fff' },
  marker: { width: 8, borderRadius: 4, marginRight: 12, backgroundColor: '#222' },
  eventBody: { flex: 1, gap: 6 },
  eventTop: { gap: 4 },
  eventType: { fontSize: 16, fontWeight: '700' },
  date: { fontSize: 12, color: '#666' },
  status: { fontSize: 13, fontWeight: '600' },
  preview: { color: '#333', lineHeight: 19 },
  source: { fontSize: 12, color: '#666' },
  view: { fontWeight: '700', marginTop: 2 },
  center: { flex: 1, alignItems: 'center', justifyContent: 'center', padding: 24, gap: 12 },
  loadingText: { marginTop: 8 },
  modalBackdrop: { flex: 1, justifyContent: 'flex-end', backgroundColor: 'rgba(0,0,0,0.35)' },
  modalCard: { maxHeight: '85%', backgroundColor: '#fff', borderTopLeftRadius: 20, borderTopRightRadius: 20, padding: 22, gap: 8 },
  modalTitle: { fontSize: 24, fontWeight: '800' },
  modalDate: { color: '#666', marginBottom: 8 },
  label: { marginTop: 8, fontWeight: '700' },
  modalActions: { marginTop: 12 },
});
