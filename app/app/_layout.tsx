import { Stack } from 'expo-router';
import { AuthProvider } from '../state/auth-context';

export default function RootLayout() {
  return (
    <AuthProvider>
      <Stack screenOptions={{ headerShown: false }}>
        <Stack.Screen name="(tabs)" />
        <Stack.Screen name="login" options={{ headerShown: false }} />
        <Stack.Screen name="search" options={{ headerShown: false }} />
      </Stack>
    </AuthProvider>
  );
}
