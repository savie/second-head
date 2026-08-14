import { ActivityIndicator, Button, Text, View } from 'react-native';
import { Redirect, router } from 'expo-router';
import { useAuth } from '../state/auth-context';

export default function HomeScreen() {
  const { session, context, loading, error, logout } = useAuth();

  if (loading) {
    return <View style={{ flex: 1, alignItems: 'center', justifyContent: 'center' }}><ActivityIndicator /></View>;
  }

  if (!session) return <Redirect href="/login" />;

  if (error || !context) {
    return (
      <View style={{ flex: 1, alignItems: 'center', justifyContent: 'center', padding: 24, gap: 12 }}>
        <Text>Authenticated session found, but SH account context could not be loaded.</Text>
        {error ? <Text>{error}</Text> : null}
        <Button title="Sign out" onPress={() => void logout()} />
      </View>
    );
  }

  return (
    <View style={{ flex: 1, alignItems: 'center', justifyContent: 'center', padding: 24, gap: 12 }}>
      <Text style={{ fontSize: 28, fontWeight: '700' }}>Second Head</Text>
      <Text>Authenticated.</Text>
      <Text>Account: {context.account.account_id}</Text>
      <Text>SH instances: {context.shInstances.length}</Text>
      <Button title="Open SH Chat" onPress={() => router.push('/chat')} />
      <Button title="Open Journey" onPress={() => router.push('/journey')} />
      <Button title="Open Clone" onPress={() => router.push('/clone')} />
      <Button title="Open Recovery" onPress={() => router.push('/recovery')} />
      <Button title="Runtime verification" onPress={() => router.push('/runtime-test')} />
      <Button title="Sign out" onPress={() => void logout()} />
    </View>
  );
}
