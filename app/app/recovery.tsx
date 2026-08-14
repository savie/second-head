import { useCallback, useEffect, useState } from 'react';
import { ActivityIndicator, Button, ScrollView, Text, View } from 'react-native';
import { Redirect } from 'expo-router';
import { useAuth } from '../state/auth-context';
import {
  createPortabilityExport,
  createRecoverySnapshot,
  listPortabilityExports,
  listRecoveryEvents,
  listRecoverySnapshots,
  restoreRecoverySnapshot,
  type PortabilityExport,
  type RecoveryEvent,
  type RecoverySnapshot,
} from '../features/recovery/recovery-service';

export default function RecoveryScreen() {
  const { session, context } = useAuth();
  const [snapshots, setSnapshots] = useState<RecoverySnapshot[]>([]);
  const [events, setEvents] = useState<RecoveryEvent[]>([]);
  const [exports, setExports] = useState<PortabilityExport[]>([]);
  const [loading, setLoading] = useState(true);
  const [busy, setBusy] = useState<string | null>(null);
  const [notice, setNotice] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);

  const shId = context?.shInstances.find((item) => item.is_primary)?.sh_id ?? context?.shInstances[0]?.sh_id ?? '';

  const refresh = useCallback(async () => {
    if (!shId) return;
    setLoading(true);
    setError(null);
    try {
      const [nextSnapshots, nextEvents, nextExports] = await Promise.all([
        listRecoverySnapshots(shId),
        listRecoveryEvents(shId),
        listPortabilityExports(shId),
      ]);
      setSnapshots(nextSnapshots);
      setEvents(nextEvents);
      setExports(nextExports);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Unable to load recovery state');
    } finally {
      setLoading(false);
    }
  }, [shId]);

  useEffect(() => {
    if (context) void refresh();
  }, [context, refresh]);

  if (!session) return <Redirect href="/login" />;
  if (!context) return <View style={{ flex: 1, alignItems: 'center', justifyContent: 'center' }}><ActivityIndicator /></View>;

  async function createSnapshot() {
    setBusy('snapshot'); setNotice(null); setError(null);
    try {
      const snapshotId = await createRecoverySnapshot(shId);
      setNotice(`Snapshot created: ${snapshotId}`);
      await refresh();
    } catch (err) { setError(err instanceof Error ? err.message : 'Unable to create snapshot'); }
    finally { setBusy(null); }
  }

  async function restore(snapshotId: string) {
    setBusy(snapshotId); setNotice(null); setError(null);
    try {
      const eventId = await restoreRecoverySnapshot(snapshotId);
      setNotice(`Recovery completed: ${eventId}`);
      await refresh();
    } catch (err) { setError(err instanceof Error ? err.message : 'Unable to restore snapshot'); }
    finally { setBusy(null); }
  }

  async function exportSnapshot(snapshotId: string) {
    setBusy(`export:${snapshotId}`); setNotice(null); setError(null);
    try {
      const exportId = await createPortabilityExport(snapshotId);
      setNotice(`Portability export created: ${exportId}`);
      await refresh();
    } catch (err) { setError(err instanceof Error ? err.message : 'Unable to create portability export'); }
    finally { setBusy(null); }
  }

  return (
    <ScrollView contentContainerStyle={{ padding: 24, gap: 16 }}>
      <Text style={{ fontSize: 28, fontWeight: '700' }}>Recovery</Text>
      <Text>SH: {shId}</Text>
      <Text>Create a full recovery snapshot, restore it for the same SH, or create a JSON portability export.</Text>
      <Button title={busy === 'snapshot' ? 'Creating…' : 'Create snapshot'} onPress={() => void createSnapshot()} disabled={busy !== null || !shId} />
      {loading ? <ActivityIndicator /> : null}
      {notice ? <Text>{notice}</Text> : null}
      {error ? <Text>{error}</Text> : null}

      <Text style={{ fontSize: 20, fontWeight: '700' }}>Snapshots</Text>
      {snapshots.length === 0 ? <Text>No recovery snapshots.</Text> : snapshots.map((snapshot) => (
        <View key={snapshot.snapshot_id} style={{ borderWidth: 1, padding: 12, borderRadius: 8, gap: 8 }}>
          <Text>Snapshot: {snapshot.snapshot_id}</Text>
          <Text>Kind: {snapshot.snapshot_kind}</Text>
          <Text>Created: {snapshot.created_at}</Text>
          <Button title={busy === snapshot.snapshot_id ? 'Restoring…' : 'Restore'} onPress={() => void restore(snapshot.snapshot_id)} disabled={busy !== null} />
          <Button title={busy === `export:${snapshot.snapshot_id}` ? 'Exporting…' : 'Create JSON export'} onPress={() => void exportSnapshot(snapshot.snapshot_id)} disabled={busy !== null} />
        </View>
      ))}

      <Text style={{ fontSize: 20, fontWeight: '700' }}>Recovery events</Text>
      {events.length === 0 ? <Text>No recovery events.</Text> : events.map((event) => (
        <View key={event.recovery_event_id} style={{ borderWidth: 1, padding: 12, borderRadius: 8 }}>
          <Text>Outcome: {event.outcome}</Text>
          <Text>Continuity: {event.continuity_status}</Text>
          {event.gap_code ? <Text>Gap: {event.gap_code}</Text> : null}
          <Text>{event.created_at}</Text>
        </View>
      ))}

      <Text style={{ fontSize: 20, fontWeight: '700' }}>Portability exports</Text>
      {exports.length === 0 ? <Text>No portability exports.</Text> : exports.map((item) => (
        <View key={item.export_id} style={{ borderWidth: 1, padding: 12, borderRadius: 8 }}>
          <Text>Export: {item.export_id}</Text>
          <Text>Format: {item.format}</Text>
          <Text>Status: {item.status}</Text>
        </View>
      ))}
      <Button title="Refresh" onPress={() => void refresh()} disabled={busy !== null} />
    </ScrollView>
  );
}
