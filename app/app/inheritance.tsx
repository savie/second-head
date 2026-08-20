import { useCallback, useEffect, useMemo, useState } from 'react';
import { ActivityIndicator, Button, Pressable, ScrollView, Text, TextInput, View } from 'react-native';
import { Redirect } from 'expo-router';
import { useAuth } from '../state/auth-context';
import { approveInheritance, createInheritanceAuthorization, listExperiences, listInheritanceAuthorizations, recordInheritance, type Experience, type InheritanceAuthorization, type TransferSelection } from '../features/inheritance/inheritance-service';
import { loadJourneyEvents, type JourneyEvent } from '../features/journey/journey-service';

export default function InheritanceScreen() {
  const { session, context } = useAuth();
  const currentShId = context?.shInstances[0]?.sh_id ?? '';
  const currentAccountId = context?.account.account_id ?? '';
  const [targetShId, setTargetShId] = useState('');
  const [targetAccountId, setTargetAccountId] = useState('');
  const [events, setEvents] = useState<JourneyEvent[]>([]);
  const [experiences, setExperiences] = useState<Experience[]>([]);
  const [selectedJourneyIds, setSelectedJourneyIds] = useState<string[]>([]);
  const [selectedExperienceIds, setSelectedExperienceIds] = useState<string[]>([]);
  const [items, setItems] = useState<InheritanceAuthorization[]>([]);
  const [loading, setLoading] = useState(true); const [busy, setBusy] = useState(false);
  const [notice, setNotice] = useState<string | null>(null); const [error, setError] = useState<string | null>(null);

  const refresh = useCallback(async () => {
    if (!context || !currentShId) return;
    setLoading(true); setError(null);
    try {
      const [journey, allExperiences, auths] = await Promise.all([loadJourneyEvents(currentShId), listExperiences(), listInheritanceAuthorizations()]);
      setEvents(journey);
      setExperiences(allExperiences.filter(experience => experience.sh_id === currentShId && experience.lifecycle === 'ACTIVE'));
      setItems(auths);
    } catch (e) { setError(e instanceof Error ? e.message : 'Unable to load inheritance data'); }
    finally { setLoading(false); }
  }, [context, currentShId]);
  useEffect(() => { void refresh(); }, [refresh]);
  if (!session) return <Redirect href="/login" />; if (!context) return <ActivityIndicator />;

  const eligibleEvents = useMemo(() => events.filter(e => e.transfer_policy !== 'NON_TRANSFERABLE'), [events]);
  const eligibleExperiences = useMemo(() => experiences.filter(e => e.scope !== 'PRIVATE' && e.visibility !== 'OWNER_ONLY'), [experiences]);
  const toggleJourney = (id: string) => setSelectedJourneyIds(ids => ids.includes(id) ? ids.filter(v => v !== id) : [...ids, id]);
  const toggleExperience = (id: string) => setSelectedExperienceIds(ids => ids.includes(id) ? ids.filter(v => v !== id) : [...ids, id]);

  async function create() {
    setBusy(true); setError(null); setNotice(null);
    try {
      const scope: TransferSelection = { memory_ids: [], knowledge_ids: [], experience_ids: selectedExperienceIds, journey_event_ids: selectedJourneyIds };
      const v = await createInheritanceAuthorization({ sourceShId: currentShId, targetShId, sourceAccountId: currentAccountId, targetAccountId, scope });
      setNotice(`Authorization created: ${String((v as InheritanceAuthorization).authorization_id)}`); await refresh();
    } catch (e) { setError(e instanceof Error ? e.message : 'Unable to create inheritance authorization'); }
    finally { setBusy(false); }
  }
  async function approve(id: string) { setBusy(true); setError(null); try { await approveInheritance(id); setNotice(`Inheritance approved: ${id}`); await refresh(); } catch (e) { setError(e instanceof Error ? e.message : 'Unable to approve inheritance'); } finally { setBusy(false); } }
  async function execute(id: string) { setBusy(true); setError(null); try { await recordInheritance(id); setNotice(`Inheritance executed: ${id}`); await refresh(); } catch (e) { setError(e instanceof Error ? e.message : 'Unable to execute inheritance'); } finally { setBusy(false); } }

  const input = { borderWidth: 1, borderRadius: 8, padding: 12, color: '#111827', borderColor: '#111827' };
  const totalSelected = selectedJourneyIds.length + selectedExperienceIds.length;
  return <ScrollView contentContainerStyle={{ padding: 24, gap: 14 }}>
    <Text style={{ fontSize: 28, fontWeight: '700' }}>Inheritance</Text>
    <Text>Current account and SH are detected from the authenticated session. Only the target is entered here.</Text>
    <Text style={{ fontWeight: '600' }}>Current account</Text><Text>{currentAccountId}</Text>
    <Text style={{ fontWeight: '600' }}>Current SH</Text><Text>{currentShId}</Text>
    <Text style={{ fontWeight: '600' }}>Target account</Text><TextInput placeholder="Isi Account ID penerima" placeholderTextColor="#6B7280" value={targetAccountId} onChangeText={setTargetAccountId} style={input} />
    <Text style={{ fontWeight: '600' }}>Target SH</Text><TextInput placeholder="Isi SH ID penerima" placeholderTextColor="#6B7280" value={targetShId} onChangeText={setTargetShId} style={input} />

    <Text style={{ fontWeight: '600' }}>Experience records eligible for Inheritance</Text>
    <Text>Eligible Experience records are shown from the current SH. Owner-only/private Experience is excluded from transfer selection.</Text>
    {loading ? <ActivityIndicator /> : null}
    {!loading && eligibleExperiences.length === 0 ? <Text>No eligible Experience records are currently available.</Text> : null}
    {eligibleExperiences.map(experience => { const selected = selectedExperienceIds.includes(experience.experience_id); return <Pressable key={experience.experience_id} onPress={() => toggleExperience(experience.experience_id)} style={{ borderWidth: 1, borderRadius: 10, padding: 12, borderColor: selected ? '#111827' : '#D1D5DB', backgroundColor: selected ? '#F3F4F6' : '#fff' }}><Text>{selected ? '☑' : '☐'} EXPERIENCE</Text><Text>{experience.content}</Text><Text>{experience.occurred_at}</Text><Text>Scope: {experience.scope} / Visibility: {experience.visibility}</Text></Pressable>; })}

    <Text style={{ fontWeight: '600' }}>Journey records eligible for Inheritance</Text>
    <Text>Select Journey records that should be included. NON_TRANSFERABLE records are excluded by policy.</Text>
    {!loading && eligibleEvents.length === 0 ? <Text>No eligible Journey records are currently available.</Text> : null}
    {eligibleEvents.map(event => { const selected = selectedJourneyIds.includes(event.event_id); return <Pressable key={event.event_id} onPress={() => toggleJourney(event.event_id)} style={{ borderWidth: 1, borderRadius: 10, padding: 12, borderColor: selected ? '#111827' : '#D1D5DB', backgroundColor: selected ? '#F3F4F6' : '#fff' }}><Text>{selected ? '☑' : '☐'} {event.event_type}</Text><Text>{event.occurred_at}</Text><Text>Policy: {event.transfer_policy}</Text></Pressable>; })}
    <Button title={`Create inheritance authorization (${totalSelected} selected)`} disabled={busy || !targetShId.trim() || !targetAccountId.trim() || totalSelected === 0} onPress={() => void create()} />
    {notice ? <Text>{notice}</Text> : null}{error ? <Text>{error}</Text> : null}
    {items.map(item => <View key={item.authorization_id} style={{ borderWidth: 1, padding: 12, borderRadius: 8, gap: 6 }}><Text>Authorization: {item.authorization_id}</Text><Text>Status: {item.status}</Text><Text>Selected Journey: {JSON.stringify(item.scope?.journey_event_ids ?? [])}</Text><Text>Selected Experience: {JSON.stringify(item.scope?.experience_ids ?? [])}</Text>{item.status === 'PENDING' && item.source_account_id === currentAccountId ? <Button title="Approve" disabled={busy} onPress={() => void approve(item.authorization_id)} /> : null}{item.status === 'APPROVED' && item.source_account_id === currentAccountId ? <Button title="Execute inheritance" disabled={busy} onPress={() => void execute(item.authorization_id)} /> : null}</View>)}
    <Button title="Refresh" disabled={busy} onPress={() => void refresh()} />
  </ScrollView>;
}
