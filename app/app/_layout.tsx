import { Stack } from 'expo-router';
import { AuthProvider } from '../state/auth-context';

export default function RootLayout() {
  return (
    <AuthProvider>
      <Stack />
    </AuthProvider>
  );
}
