import type { ReactNode } from 'react';
import { ActivityIndicator, Button, StyleSheet, Text, View } from 'react-native';
import { Redirect, router } from 'expo-router';
import { useAuth } from '../state/auth-context';

function Section({ title, description, children }: { title: string; description: string; children: ReactNode }) {
  return (
    <View style={styles.section}>
      <Text style={styles.sectionTitle}>{title}</Text>
      <Text style={styles.sectionDescription}>{description}</Text>
      <View style={styles.actions}>{children}</View>
    </View>
  );
}

export default function HomeScreen() {
  const { session, context, loading, error, logout } = useAuth();

  if (loading) {
    return <View style={styles.center}><ActivityIndicator /></View>;
  }

  if (!session) return <Redirect href="/login" />;

  if (error || !context) {
    return (
      <View style={styles.center}>
        <Text style={styles.errorTitle}>Second Head</Text>
        <Text>Authenticated session found, but SH account context could not be loaded.</Text>
        {error ? <Text style={styles.error}>{error}</Text> : null}
        <Button title="Sign out" onPress={() => void logout()} />
      </View>
    );
  }

  return (
    <View style={styles.screen}>
      <Text style={styles.brand}>SECOND HEAD</Text>
      <Text style={styles.subtitle}>Your SH, in one place.</Text>

      <View style={styles.identityCard}>
        <Text style={styles.identityTitle}>Your Second Head</Text>
        <Text>Account: {context.account.account_id}</Text>
        <Text>SH instances: {context.shInstances.length}</Text>
      </View>

      <Section title="Talk to SH" description="Chat langsung dengan Second Head.">
        <Button title="Open Chat" onPress={() => router.push('/chat')} />
      </Section>

      <Section title="Continuity" description="Lihat perjalanan dan kejadian yang tercatat pada SH.">
        <Button title="Open Journey" onPress={() => router.push('/journey')} />
      </Section>

      <Section title="SH Data" description="Data pengalaman yang tersimpan untuk owner. Memory dan Knowledge tetap dikelola melalui runtime sampai surface khususnya tersedia.">
        <Button title="Open Experience" onPress={() => router.push('/experience')} />
      </Section>

      <Section title="Lifecycle & Transfer" description="Fitur pengelolaan SH yang berdampak pada lifecycle atau perpindahan data.">
        <Button title="Clone" onPress={() => router.push('/clone')} />
        <Button title="Recovery" onPress={() => router.push('/recovery')} />
        <Button title="Inheritance / Succession / Legacy" onPress={() => router.push('/inheritance')} />
      </Section>

      <Section title="Developer / Verification" description="Surface pengujian runtime; bukan fitur harian owner.">
        <Button title="Runtime Verification" onPress={() => router.push('/runtime-test')} />
      </Section>

      <View style={styles.footer}>
        <Button title="Sign out" onPress={() => void logout()} />
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  screen: { flex: 1, padding: 20, backgroundColor: '#f7f7f7' },
  center: { flex: 1, alignItems: 'center', justifyContent: 'center', padding: 24, gap: 12 },
  brand: { fontSize: 30, fontWeight: '800', marginTop: 12 },
  subtitle: { marginTop: 4, marginBottom: 18, color: '#555' },
  identityCard: { backgroundColor: '#fff', borderRadius: 14, padding: 16, gap: 6, marginBottom: 14 },
  identityTitle: { fontSize: 18, fontWeight: '700' },
  section: { backgroundColor: '#fff', borderRadius: 14, padding: 16, marginBottom: 12, gap: 8 },
  sectionTitle: { fontSize: 18, fontWeight: '700' },
  sectionDescription: { color: '#555', lineHeight: 20 },
  actions: { gap: 8 },
  footer: { marginTop: 4, paddingBottom: 20 },
  errorTitle: { fontSize: 28, fontWeight: '800' },
  error: { color: '#991b1b' },
});
