import { useCallback, useEffect, useMemo, useState } from 'react';
import { ActivityIndicator, Button, Pressable, ScrollView, Text } from 'react-native';
import { Redirect } from 'expo-router';
import { useAuth } from '../state/auth-context';
import { preserveSelectedTransferAsLegacy } from '../features/inheritance/inheritance-service';
import { loadJourneyEvents, type JourneyEvent } from '../features/journey/journey-service';

export default function LegacyScreen() {
  const { session, context } = useAuth();
  const currentShId = context?.shInstances[0]?.sh_id ?? ''; const currentAccountId = context?.account.account_id ?? '';
  const [events, setEvents] = useState<JourneyEvent[]>([]); const [selectedIds, setSelectedIds] = useState<string[]>([]);
  const [notice, setNotice] = useState<string | null>(null); const [error, setError] = useState<string | null>(null); const [loading, setLoading] = useState(true); const [busy, setBusy] = useState(false);
  const refresh = useCallback(async () => { if (!currentShId) return; setLoading(true); setError(null); try { setEvents(await loadJourneyEvents(currentShId)); } catch (e) { setError(e instanceof Error ? e.message : 'Unable to load Journey'); } finally { setLoading(false); } }, [currentShId]);
  useEffect(() => { void refresh(); }, [refresh]);
  if (!session) return <Redirect href="/login" />; if (!context) return <ActivityIndicator />;
  const eligible = useMemo(() => events.filter(e => e.transfer_policy !== 'NON_TRANSFERABLE'), [events]);
  const toggle = (id: string) => setSelectedIds(ids => ids.includes(id) ? ids.filter(v => v !== id) : [...ids, id]);
  async function preserve() { setBusy(true); setNotice(null); setError(null); try { const v = await preserveSelectedTransferAsLegacy({ sourceShId: currentShId, scope: { memory_ids: [], knowledge_ids: [], experience_ids: [], journey_event_ids: selectedIds } }); setNotice(`Legacy preserved: ${String(v)}`); } catch (e) { setError(e instanceof Error ? e.message : 'Unable to preserve Legacy'); } finally { setBusy(false); } }
  return <ScrollView contentContainerStyle={{ padding: 24, gap: 14 }}>
    <Text style={{ fontSize: 28, fontWeight: '700' }}>Legacy</Text><Text>Legacy preserves selected eligible Journey history. The current account and SH are informational.</Text>
    <Text style={{ fontWeight: '600' }}>Current account</Text><Text>{currentAccountId}</Text><Text style={{ fontWeight: '600' }}>Current SH</Text><Text>{currentShId}</Text>
    <Text style={{ fontWeight: '600' }}>Journey records eligible for Legacy</Text><Text>Select the history to preserve. NON_TRANSFERABLE records are excluded by policy.</Text>
    {loading ? <ActivityIndicator /> : null}{!loading && eligible.length === 0 ? <Text>No eligible Journey records are currently available.</Text> : null}
    {eligible.map(event => { const selected = selectedIds.includes(event.event_id); return <Pressable key={event.event_id} onPress={() => toggle(event.event_id)} style={{ borderWidth: 1, borderRadius: 10, padding: 12, borderColor: selected ? '#111827' : '#D1D5DB', backgroundColor: selected ? '#F3F4F6' : '#fff' }}><Text>{selected ? '☑' : '☐'} {event.event_type}</Text><Text>{event.occurred_at} · {event.transfer_policy}</Text></Pressable>; })}
    <Button title={`Preserve selected history (${selectedIds.length})`} disabled={busy || selectedIds.length === 0} onPress={() => void preserve()} />
    {notice ? <Text>{notice}</Text> : null}{error ? <Text>{error}</Text> : null}
  </ScrollView>;
}
