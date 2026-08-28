import { useState } from 'react';
import { ActivityIndicator, Button, Modal, ScrollView, StyleSheet, Text, View } from 'react-native';
import { Redirect, router } from 'expo-router';
import { useAuth } from '../state/auth-context';
import { backend } from '../services/backend';

export default function EndOfLifeScreen() {
  const { session, context, logout } = useAuth(); const current = context?.shInstances.find(v => v.is_primary) ?? context?.shInstances[0];
  const [busy, setBusy] = useState(false); const [confirmOpen, setConfirmOpen] = useState(false); const [notice, setNotice] = useState<string | null>(null); const [error, setError] = useState<string | null>(null);
  if (!session) return <Redirect href="/login" />; if (!context || !current) return <ActivityIndicator />;
  const currentShId = current.sh_id;
  async function confirmEndOfLife() { setConfirmOpen(false); setBusy(true); setNotice(null); setError(null); const { error: rpcError } = await backend.rpc('runtime_end_of_life_sh', { p_sh_id: currentShId, p_reason: 'Owner confirmed End-of-Life from Second Head app' }); if (rpcError) setError(`END_OF_LIFE_FAILED: ${rpcError.message}`); else { setNotice('End-of-Life completed. Account and SH are now deactivated.'); await logout(); router.replace('/login'); } setBusy(false); }
  return <View style={styles.screen}><ScrollView contentContainerStyle={styles.content}><Text style={styles.title}>End-of-Life</Text><Text>Review the authenticated account and SH below. This action is terminal and cannot be undone from the app.</Text><Text style={styles.label}>Account</Text><Text>{context.account.account_id}</Text><Text style={styles.label}>SH</Text><Text>{currentShId}</Text><Text style={styles.label}>Email</Text><Text>{context.account.email}</Text><Text style={styles.label}>Current status</Text><Text>{context.account.status} / {current.status}</Text><Text>End-of-Life first asks for confirmation. Nothing is executed until you choose Yes.</Text><Button title="End-of-Life" disabled={busy} onPress={() => setConfirmOpen(true)} /><Button title="Back" disabled={busy} onPress={() => router.back()} />{busy ? <ActivityIndicator /> : null}{notice ? <Text>{notice}</Text> : null}{error ? <Text>{error}</Text> : null}</ScrollView>
    <Modal visible={confirmOpen} transparent animationType="fade" onRequestClose={() => setConfirmOpen(false)}><View style={styles.backdrop}><View style={styles.dialog}><Text style={styles.dialogTitle}>Confirm End-of-Life</Text><Text>Yakin ingin mengakhiri lifecycle Account dan SH ini? Tindakan ini terminal.</Text><Button title="No" onPress={() => setConfirmOpen(false)} /><Button title="Yes" disabled={busy} onPress={() => void confirmEndOfLife()} /></View></View></Modal>
  </View>;
}
const styles = StyleSheet.create({ screen: { flex: 1 }, content: { padding: 24, gap: 14 }, title: { fontSize: 28, fontWeight: '700' }, label: { fontWeight: '600', marginTop: 4 }, backdrop: { flex: 1, justifyContent: 'center', padding: 24, backgroundColor: 'rgba(0,0,0,0.45)' }, dialog: { backgroundColor: '#fff', borderRadius: 14, padding: 20, gap: 12 }, dialogTitle: { fontSize: 20, fontWeight: '700' } });
