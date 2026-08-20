import { useCallback, useEffect, useMemo, useState } from 'react';
import { ActivityIndicator, Button, FlatList, Modal, Pressable, RefreshControl, StyleSheet, Text, View } from 'react-native';
import { Redirect } from 'expo-router';
import { useAuth } from '../state/auth-context';
import { loadJourneyEventsForAccount, type JourneyEvent } from '../features/journey/journey-service';
import { getJourneyRecordPolicy, setRecordPolicy, type JourneyRecordPolicy, type TransferPolicy, type RecordScope, type RecordVisibility } from '../features/inheritance/inheritance-service';

const FILTERS = ['All', 'Memory', 'Knowledge', 'Experience', 'Lifecycle / Other'] as const;
type Filter = typeof FILTERS[number];
const TRANSFER_POLICIES: TransferPolicy[] = ['NON_TRANSFERABLE', 'INHERITABLE', 'SUCCESSION', 'LEGACY'];

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
  if (type.includes('KNOWLEDGE') || source.includes('KNOWLEDGE') || type === 'LEARNING') return 'Knowledge';
  if (type.includes('EXPERIENCE') || source.includes('EXPERIENCE')) return 'Experience';
  return 'Lifecycle / Other';
}

function payloadText(payload: Record<string, unknown> | null) {
  if (!payload) return 'Tidak ada isi tambahan pada event ini.';
  const candidates = ['content', 'text', 'message', 'captured_text', 'representation', 'summary'];
  for (const key of candidates) {
    const value = payload[key];
    if (typeof value === 'string' && value.trim()) return value;
  }
  return JSON.stringify(payload, null, 2);
}

export default function JourneyScreen() {
  const { session, context } = useAuth();
  const primarySH = context?.shInstances.find((item) => item.is_primary) ?? context?.shInstances[0];
  const ownedShIds = useMemo(() => new Set((context?.shInstances ?? []).map((item) => item.sh_id)), [context?.shInstances]);
  const [events, setEvents] = useState<JourneyEvent[]>([]);
  const [filter, setFilter] = useState<Filter>('All');
  const [selected, setSelected] = useState<JourneyEvent | null>(null);
  const [recordPolicy, setRecordPolicyState] = useState<JourneyRecordPolicy | null>(null);
  const [editingPolicy, setEditingPolicy] = useState(false);
  const [draftScope, setDraftScope] = useState<RecordScope>('PRIVATE');
  const [draftVisibility, setDraftVisibility] = useState<RecordVisibility>('OWNER_ONLY');
  const [draftTransferPolicy, setDraftTransferPolicy] = useState<TransferPolicy>('NON_TRANSFERABLE');
  const [savingPolicy, setSavingPolicy] = useState(false);
  const [loadingPolicy, setLoadingPolicy] = useState(false);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const load = useCallback(async () => {
    if (!primarySH) return;
    try {
      setError(null);
      setEvents(await loadJourneyEventsForAccount());
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Unable to load Journey');
    } finally {
      setLoading(false);
    }
  }, [primarySH]);

  useEffect(() => { void load(); }, [load]);

  const openEvent = async (event: JourneyEvent) => {
    setSelected(event);
    setEditingPolicy(false);
    setRecordPolicyState(null);
    setError(null);
    if (!['Memory', 'Knowledge', 'Experience'].includes(category(event))) return;

    // Policy management is owner-only. Shared Journey projections remain
    // readable, but must not call the owner-scoped policy RPC.
    if (!ownedShIds.has(event.sh_id)) return;

    setLoadingPolicy(true);
    try {
      const policy = await getJourneyRecordPolicy(event.event_id);
      setRecordPolicyState(policy);
      if (policy) {
        setDraftScope(policy.scope);
        setDraftVisibility(policy.visibility);
        setDraftTransferPolicy(policy.transfer_policy);
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Unable to load record policy');
    } finally {
      setLoadingPolicy(false);
    }
  };

  const savePolicy = async () => {
    if (!recordPolicy || !selected || !ownedShIds.has(selected.sh_id)) return;
    setSavingPolicy(true);
    setError(null);
    try {
      await setRecordPolicy({
        domain: recordPolicy.domain,
        recordId: recordPolicy.record_id,
        scope: draftScope,
        visibility: draftVisibility,
        transferPolicy: draftTransferPolicy,
      });
      const refreshed = await getJourneyRecordPolicy(selected.event_id);
      setRecordPolicyState(refreshed);
      if (refreshed) {
        setDraftScope(refreshed.scope);
        setDraftVisibility(refreshed.visibility);
        setDraftTransferPolicy(refreshed.transfer_policy);
      }
      setEditingPolicy(false);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Record policy update failed');
    } finally {
      setSavingPolicy(false);
    }
  };

  const filteredEvents = useMemo(
    () => filter === 'All' ? events : events.filter((item) => category(item) === filter),
    [events, filter],
  );

  const header = useMemo(() => (
    <View style={styles.header}>
      <Text style={styles.title}>Journey</Text>
      <Text style={styles.subtitle}>{primarySH?.canonical_name ?? primarySH?.sh_id ?? 'SH'}</Text>
      <Text style={styles.description}>Continuity and lifecycle history for this Second Head.</Text>
      <Text style={styles.hint}>Pilih kategori lalu ketuk event untuk melihat detail dan, untuk Memory / Knowledge / Experience milik Owner, mengatur policy record.</Text>
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
          <Pressable style={styles.event} onPress={() => void openEvent(item)}>
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

              {loadingPolicy ? <ActivityIndicator /> : null}
              {recordPolicy ? (
                <View style={styles.policyBlock}>
                  <Text style={styles.label}>Visibility</Text>
                  <Text>{humanize(recordPolicy.scope)} / {humanize(recordPolicy.visibility)}</Text>
                  <Text style={styles.label}>Transfer policy</Text>
                  <Text>{humanize(recordPolicy.transfer_policy)}</Text>

                  {!editingPolicy ? (
                    <Button title="Edit policy" onPress={() => setEditingPolicy(true)} />
                  ) : (
                    <View style={styles.editor}>
                      <Text style={styles.label}>Scope</Text>
                      <View style={styles.optionRow}>
                        {(['PRIVATE', 'GENERAL'] as RecordScope[]).map((value) => (
                          <Pressable key={value} onPress={() => setDraftScope(value)} style={[styles.option, draftScope === value && styles.optionActive]}>
                            <Text style={{ color: draftScope === value ? '#fff' : '#111' }}>{humanize(value)}</Text>
                          </Pressable>
                        ))}
                      </View>
                      <Text style={styles.label}>Visibility</Text>
                      <View style={styles.optionRow}>
                        {(['OWNER_ONLY', 'SHARED'] as RecordVisibility[]).map((value) => (
                          <Pressable key={value} onPress={() => setDraftVisibility(value)} style={[styles.option, draftVisibility === value && styles.optionActive]}>
                            <Text style={{ color: draftVisibility === value ? '#fff' : '#111' }}>{humanize(value)}</Text>
                          </Pressable>
                        ))}
                      </View>
                      <Text style={styles.label}>Transfer policy</Text>
                      <View style={styles.optionColumn}>
                        {TRANSFER_POLICIES.map((value) => (
                          <Pressable key={value} onPress={() => setDraftTransferPolicy(value)} style={[styles.option, draftTransferPolicy === value && styles.optionActive]}>
                            <Text style={{ color: draftTransferPolicy === value ? '#fff' : '#111' }}>{humanize(value)}</Text>
                          </Pressable>
                        ))}
                      </View>
                      <Button title={savingPolicy ? 'Saving…' : 'Save policy'} disabled={savingPolicy} onPress={() => void savePolicy()} />
                      <Button title="Cancel" disabled={savingPolicy} onPress={() => { setEditingPolicy(false); if (recordPolicy) { setDraftScope(recordPolicy.scope); setDraftVisibility(recordPolicy.visibility); setDraftTransferPolicy(recordPolicy.transfer_policy); } }} />
                    </View>
                  )}
                </View>
              ) : null}

              <Button title="Close" onPress={() => setSelected(null)} />
            </View>
          </View>
        ) : null}
      </Modal>
    </View>
  );
}

const styles = StyleSheet.create({
  screen: { flex: 1, backgroundColor: '#f7f7f7' },
  content: { padding: 16, paddingBottom: 32 },
  header: { marginBottom: 16 },
  title: { fontSize: 28, fontWeight: '700' },
  subtitle: { marginTop: 4, fontSize: 14, fontWeight: '600' },
  description: { marginTop: 4, color: '#555' },
  hint: { marginTop: 10, color: '#666', lineHeight: 20 },
  filters: { flexDirection: 'row', flexWrap: 'wrap', gap: 8, marginTop: 14 },
  filter: { paddingHorizontal: 12, paddingVertical: 8, borderRadius: 18, backgroundColor: '#e7e7e7' },
  filterActive: { backgroundColor: '#111' },
  filterText: { color: '#222' },
  filterTextActive: { color: '#fff' },
  error: { marginTop: 10, color: '#b00020' },
  empty: { padding: 16, borderRadius: 10, backgroundColor: '#eee' },
  emptyTitle: { fontWeight: '700' },
  emptyText: { marginTop: 4, color: '#555' },
  event: { flexDirection: 'row', padding: 14, marginBottom: 10, borderRadius: 12, backgroundColor: '#fff' },
  marker: { width: 8, borderRadius: 4, backgroundColor: '#111', marginRight: 12 },
  eventBody: { flex: 1 },
  eventTop: { flexDirection: 'row', justifyContent: 'space-between', gap: 8 },
  eventType: { flex: 1, fontWeight: '700' },
  date: { color: '#666', fontSize: 12 },
  status: { marginTop: 4, color: '#555' },
  preview: { marginTop: 8, lineHeight: 20 },
  source: { marginTop: 8, color: '#666', fontSize: 12 },
  view: { marginTop: 10, fontWeight: '600' },
  center: { flex: 1, alignItems: 'center', justifyContent: 'center', padding: 24 },
  loadingText: { marginTop: 8 },
  modalBackdrop: { flex: 1, justifyContent: 'flex-end', backgroundColor: 'rgba(0,0,0,0.35)' },
  modalCard: { maxHeight: '90%', padding: 20, borderTopLeftRadius: 18, borderTopRightRadius: 18, backgroundColor: '#fff', gap: 8 },
  modalTitle: { fontSize: 22, fontWeight: '700' },
  modalDate: { color: '#666' },
  label: { marginTop: 8, fontWeight: '700' },
  policyBlock: { marginTop: 8, paddingTop: 8, borderTopWidth: 1, borderTopColor: '#ddd', gap: 6 },
  editor: { gap: 8 },
  optionRow: { flexDirection: 'row', flexWrap: 'wrap', gap: 8 },
  optionColumn: { gap: 8 },
  option: { paddingHorizontal: 12, paddingVertical: 9, borderRadius: 8, borderWidth: 1, borderColor: '#ccc', backgroundColor: '#fff' },
  optionActive: { backgroundColor: '#111', borderColor: '#111' },
});
