import { Redirect } from 'expo-router';
import { ActivityIndicator, StyleSheet, Text, View } from 'react-native';
import { useAuth } from '../state/auth-context';

export default function HomeScreen() {
  const { session, context, loading, error, logout } = useAuth();

  if (loading) return <View style={styles.center}><ActivityIndicator /></View>;
  if (!session) return <Redirect href="/login" />;

  if (error || !context) {
    return (
      <View style={styles.center}>
        <Text style={styles.title}>Second Head</Text>
        <Text>Authenticated session found, but SH account context could not be loaded.</Text>
        {error ? <Text style={styles.error}>{error}</Text> : null}
        <Text onPress={() => void logout()} style={styles.link}>Sign out</Text>
      </View>
    );
  }

  // Authenticated entry is intentionally the Chat tab. Home is retained only as
  // a route-level compatibility target for older deep links.
  return <Redirect href="/(tabs)/chat" />;
}

const styles = StyleSheet.create({
  center: { flex: 1, alignItems: 'center', justifyContent: 'center', padding: 24, gap: 12 },
  title: { fontSize: 28, fontWeight: '800' },
  error: { color: '#991b1b', textAlign: 'center' },
  link: { fontWeight: '700', textDecorationLine: 'underline' },
});
