import { useCallback, useEffect, useState } from 'react';
import { ActivityIndicator, Button, Pressable, ScrollView, Text, View } from 'react-native';
import { router } from 'expo-router';
import {
  getExperience,
  listExperiences,
  setExperiencePolicy,
  type Experience,
  type ExperienceScope,
  type ExperienceTransferPolicy,
  type ExperienceVisibility,
} from '../services/experience';

const TRANSFER_POLICIES: ExperienceTransferPolicy[] = [
  'NON_TRANSFERABLE',
  'INHERITABLE',
  'SUCCESSION',
  'LEGACY',
];

function humanize(value: string) {
  return value.replaceAll('_', ' ');
}

export default function ExperienceScreen() {
  const [items, setItems] = useState<Experience[]>([]);
  const [selected, setSelected] = useState<Experience | null>(null);
  const [editing, setEditing] = useState(false);
  const [draftScope, setDraftScope] = useState<ExperienceScope>('PRIVATE');
  const [draftVisibility, setDraftVisibility] = useState<ExperienceVisibility>('OWNER_ONLY');
  const [draftTransferPolicy, setDraftTransferPolicy] = useState<ExperienceTransferPolicy>('NON_TRANSFERABLE');
  const [saving, setSaving] = useState(false);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const load = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      setItems(await listExperiences());
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Experience retrieval failed');
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    void load();
  }, [load]);

  const openExperience = async (experienceId: string) => {
    try {
      setError(null);
      const experience = await getExperience(experienceId);
      setSelected(experience);
      setEditing(false);
      setDraftScope(experience.scope);
      setDraftVisibility(experience.visibility);
      setDraftTransferPolicy(experience.transfer_policy);
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Experience retrieval failed');
    }
  };

  const savePolicy = async () => {
    if (!selected) return;
    setSaving(true);
    setError(null);
    try {
      await setExperiencePolicy({
        experienceId: selected.experience_id,
        scope: draftScope,
        visibility: draftVisibility,
        transferPolicy: draftTransferPolicy,
      });
      const refreshed = await getExperience(selected.experience_id);
      setSelected(refreshed);
      setItems((current) => current.map((item) => item.experience_id === refreshed.experience_id ? refreshed : item));
      setDraftScope(refreshed.scope);
      setDraftVisibility(refreshed.visibility);
      setDraftTransferPolicy(refreshed.transfer_policy);
      setEditing(false);
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Experience policy update failed');
    } finally {
      setSaving(false);
    }
  };

  return (
    <View style={{ flex: 1, padding: 20, gap: 12 }}>
      <Text style={{ fontSize: 28, fontWeight: '700' }}>Experience</Text>
      <Text>Owner-scoped recorded Experience for the current SH.</Text>

      {loading ? <ActivityIndicator /> : null}
      {error ? <Text>ERROR: {error}</Text> : null}

      {!loading && !error && items.length === 0 ? (
        <Text>No recorded Experience.</Text>
      ) : null}

      <ScrollView contentContainerStyle={{ gap: 10 }}>
        {items.map((item) => (
          <View key={item.experience_id} style={{ borderWidth: 1, borderRadius: 10, padding: 12, gap: 6 }}>
            <Text style={{ fontWeight: '700' }}>{item.experience_type}</Text>
            <Text>{item.content}</Text>
            <Text>Scope: {humanize(item.scope)}</Text>
            <Text>Visibility: {humanize(item.visibility)}</Text>
            <Text>Transfer policy: {humanize(item.transfer_policy)}</Text>
            <Text>Lifecycle: {item.lifecycle}</Text>
            <Text>Source: {item.source_ref ?? '—'}</Text>
            <Button title="Open Experience" onPress={() => void openExperience(item.experience_id)} />
          </View>
        ))}
      </ScrollView>

      {selected ? (
        <ScrollView style={{ maxHeight: '55%' }} contentContainerStyle={{ borderWidth: 1, borderRadius: 10, padding: 12, gap: 8 }}>
          <Text style={{ fontWeight: '700', fontSize: 18 }}>Experience Detail</Text>
          <Text>{selected.content}</Text>

          <Text style={{ fontWeight: '700', marginTop: 6 }}>Visibility</Text>
          <Text>{humanize(selected.scope)} / {humanize(selected.visibility)}</Text>

          <Text style={{ fontWeight: '700', marginTop: 6 }}>Transfer policy</Text>
          <Text>{humanize(selected.transfer_policy)}</Text>

          {!editing ? (
            <Button title="Edit policy" onPress={() => setEditing(true)} />
          ) : (
            <View style={{ gap: 10, marginTop: 4 }}>
              <Text style={{ fontWeight: '700' }}>Scope</Text>
              <View style={{ flexDirection: 'row', gap: 8 }}>
                {(['PRIVATE', 'GENERAL'] as ExperienceScope[]).map((value) => (
                  <Pressable key={value} onPress={() => setDraftScope(value)} style={{ borderWidth: 1, borderRadius: 8, padding: 10, backgroundColor: draftScope === value ? '#111' : '#fff' }}>
                    <Text style={{ color: draftScope === value ? '#fff' : '#111' }}>{humanize(value)}</Text>
                  </Pressable>
                ))}
              </View>

              <Text style={{ fontWeight: '700' }}>Visibility</Text>
              <View style={{ flexDirection: 'row', gap: 8 }}>
                {(['OWNER_ONLY', 'SHARED'] as ExperienceVisibility[]).map((value) => (
                  <Pressable key={value} onPress={() => setDraftVisibility(value)} style={{ borderWidth: 1, borderRadius: 8, padding: 10, backgroundColor: draftVisibility === value ? '#111' : '#fff' }}>
                    <Text style={{ color: draftVisibility === value ? '#fff' : '#111' }}>{humanize(value)}</Text>
                  </Pressable>
                ))}
              </View>

              <Text style={{ fontWeight: '700' }}>Transfer policy</Text>
              <View style={{ gap: 8 }}>
                {TRANSFER_POLICIES.map((value) => (
                  <Pressable key={value} onPress={() => setDraftTransferPolicy(value)} style={{ borderWidth: 1, borderRadius: 8, padding: 10, backgroundColor: draftTransferPolicy === value ? '#111' : '#fff' }}>
                    <Text style={{ color: draftTransferPolicy === value ? '#fff' : '#111' }}>{humanize(value)}</Text>
                  </Pressable>
                ))}
              </View>

              <Button title={saving ? 'Saving…' : 'Save policy'} disabled={saving} onPress={() => void savePolicy()} />
              <Button title="Cancel" disabled={saving} onPress={() => { setEditing(false); setDraftScope(selected.scope); setDraftVisibility(selected.visibility); setDraftTransferPolicy(selected.transfer_policy); }} />
            </View>
          )}
        </ScrollView>
      ) : null}

      <Button title="Refresh" onPress={() => void load()} />
      <Button title="Back Home" onPress={() => router.replace('/')} />
    </View>
  );
}
