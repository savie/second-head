import { useCallback, useEffect, useState } from 'react';
import { ActivityIndicator, Button, ScrollView, Text, View } from 'react-native';
import { router } from 'expo-router';
import { getExperience, listExperiences, type Experience } from '../services/experience';

export default function ExperienceScreen() {
  const [items, setItems] = useState<Experience[]>([]);
  const [selected, setSelected] = useState<Experience | null>(null);
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
            <Text>Scope: {item.scope}</Text>
            <Text>Visibility: {item.visibility}</Text>
            <Text>Lifecycle: {item.lifecycle}</Text>
            <Text>Source: {item.source_ref ?? '—'}</Text>
            <Button
              title="Open Experience"
              onPress={() => void getExperience(item.experience_id).then(setSelected).catch((e) => setError(e instanceof Error ? e.message : 'Experience retrieval failed'))}
            />
          </View>
        ))}
      </ScrollView>

      {selected ? (
        <View style={{ borderWidth: 1, borderRadius: 10, padding: 12, gap: 6 }}>
          <Text style={{ fontWeight: '700' }}>Retrieved Experience</Text>
          <Text>{selected.content}</Text>
          <Text>Visibility: {selected.visibility}</Text>
          <Text>Scope: {selected.scope}</Text>
        </View>
      ) : null}

      <Button title="Refresh" onPress={() => void load()} />
      <Button title="Back Home" onPress={() => router.replace('/')} />
    </View>
  );
}
