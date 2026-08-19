import { router } from 'expo-router';
import { Pressable, ScrollView, StyleSheet, Text, View } from 'react-native';

const actions = [
  ['Clone', '/clone', 'Create a separate SH through the approved clone flow.'],
  ['Recovery', '/recovery', 'Restore through the recovery workflow.'],
  ['Inheritance', '/inheritance', 'Configure and execute inheritance workflows.'],
  ['Succession', '/inheritance', 'Succession settings remain distinct within lifecycle management.'],
  ['End-of-Life', '/inheritance', 'Open the current lifecycle action surface for end-of-life controls.'],
  ['Legacy', '/inheritance', 'Open the current lifecycle action surface for legacy handling.'],
] as const;

export default function LifecycleScreen() {
  return (
    <ScrollView contentContainerStyle={styles.content}>
      <Text style={styles.title}>Lifecycle</Text>
      <Text style={styles.subtitle}>Run lifecycle and transfer processes here. Results and history are recorded in Journey.</Text>
      {actions.map(([title, route, description]) => (
        <Pressable key={title} style={styles.card} onPress={() => router.push(route)}>
          <Text style={styles.cardTitle}>{title}</Text>
          <Text style={styles.cardText}>{description}</Text>
          <Text style={styles.open}>Open →</Text>
        </Pressable>
      ))}
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
  open: { fontWeight: '700', marginTop: 3 },
});
