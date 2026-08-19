import { router } from 'expo-router';
import { Pressable, ScrollView, StyleSheet, Text, View } from 'react-native';
import { useAuth } from '../../state/auth-context';

const items = [
  ['Runtime Verification', '/runtime-test', 'Run checks on the phone and copy diagnostic text.'],
  ['Authorization', '/inheritance', 'Open the current authorization workflow.'],
  ['Error', '/runtime-test', 'Inspect runtime and context errors from the diagnostic surface.'],
] as const;

export default function MoreScreen() {
  const { logout } = useAuth();
  return (
    <ScrollView contentContainerStyle={styles.content}>
      <Text style={styles.title}>More</Text>
      <Text style={styles.subtitle}>Technical tools and account controls. Daily use stays in Chat, Journey, and Lifecycle.</Text>
      {items.map(([title, route, description]) => (
        <Pressable key={title} style={styles.card} onPress={() => router.push(route)}>
          <Text style={styles.cardTitle}>{title}</Text>
          <Text style={styles.cardText}>{description}</Text>
        </Pressable>
      ))}
      <Pressable style={styles.card} onPress={() => void logout()}>
        <Text style={styles.cardTitle}>Account</Text>
        <Text style={styles.cardText}>Sign out of this Second Head session.</Text>
      </Pressable>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  content: { padding: 20, paddingBottom: 36, gap: 12 },
  title: { fontSize: 32, fontWeight: '800' },
  subtitle: { color: '#555', lineHeight: 20, marginBottom: 8 },
  card: { backgroundColor: '#fff', borderRadius: 14, padding: 16, gap: 7 },
  cardTitle: { fontSize: 18, fontWeight: '700' },
  cardText: { color: '#555', lineHeight: 19 },
});
