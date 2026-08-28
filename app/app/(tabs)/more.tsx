import { SHShell } from '../../components/sh-shell';
import { router } from 'expo-router';
import { Pressable, ScrollView, StyleSheet, Text } from 'react-native';
import { useAuth } from '../../state/auth-context';

const items = [
  ['Runtime Verification', '/runtime-test', 'Run checks on the phone and copy diagnostic text.'],
  ['Authorization', '/authorization', 'View authorization status and scope.'],
] as const;

export default function MoreScreen() {
  const { logout } = useAuth();
  async function signOut() {
    await logout();
    router.replace('/login');
  }
  return <SHShell title="More" context={<><Text style={{ color: '#6B6A66', lineHeight: 20 }}>Technical and account controls live here, away from the primary conversation flow.</Text><Text style={{ marginTop: 8, fontWeight: '800', color: '#4A338E' }}>Build 0.1.0 · DEV</Text></>}><ScrollView contentContainerStyle={styles.content}>
    <Text style={styles.title}>More</Text>
    <Text style={styles.subtitle}>Technical tools and account controls. Daily use stays in Chat, Journey, and Lifecycle.</Text>
    <Text style={styles.buildStamp}>Version 0.1.0 • Build #{process.env.EXPO_PUBLIC_BUILD_NUMBER ?? 'DEV'}</Text>
    {items.map(([title, route, description]) => <Pressable key={title} style={styles.card} onPress={() => router.push(route)}><Text style={styles.cardTitle}>{title}</Text><Text style={styles.cardText}>{description}</Text></Pressable>)}
    <Pressable style={styles.card} onPress={() => void signOut()}><Text style={styles.cardTitle}>Account</Text><Text style={styles.cardText}>Sign out and return to Login.</Text></Pressable>
  </ScrollView></SHShell>;
}

const styles = StyleSheet.create({ content: { padding: 20, paddingBottom: 36, gap: 12 }, title: { fontSize: 32, fontWeight: '800' }, subtitle: { color: '#555', lineHeight: 20, marginBottom: 8 }, card: { backgroundColor: '#fff', borderRadius: 14, padding: 16, gap: 7 }, cardTitle: { fontSize: 18, fontWeight: '700' }, cardText: { color: '#555', lineHeight: 19 }, buildStamp: { color: '#777', fontSize: 13, marginBottom: 4 } });
