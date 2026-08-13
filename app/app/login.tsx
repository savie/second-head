import { useState } from 'react';
import { ActivityIndicator, Button, Text, TextInput, View } from 'react-native';
import { router } from 'expo-router';
import { signInWithPassword, signUpWithPassword } from '../services/auth';

export default function LoginScreen() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function submit(mode: 'signIn' | 'signUp') {
    setBusy(true);
    setError(null);
    try {
      const result = mode === 'signIn'
        ? await signInWithPassword(email.trim(), password)
        : await signUpWithPassword(email.trim(), password);
      if (result.error) throw result.error;
      if (mode === 'signUp' && !result.data.session) {
        setError('Account created. Complete the configured email verification, then sign in.');
        return;
      }
      router.replace('/');
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Authentication failed');
    } finally {
      setBusy(false);
    }
  }

  return (
    <View style={{ flex: 1, justifyContent: 'center', padding: 24, gap: 12 }}>
      <Text style={{ fontSize: 28, fontWeight: '700' }}>Second Head</Text>
      <TextInput autoCapitalize="none" keyboardType="email-address" placeholder="Email" value={email} onChangeText={setEmail} />
      <TextInput secureTextEntry placeholder="Password" value={password} onChangeText={setPassword} />
      {error ? <Text>{error}</Text> : null}
      {busy ? <ActivityIndicator /> : (
        <>
          <Button title="Sign in" onPress={() => void submit('signIn')} />
          <Button title="Create account" onPress={() => void submit('signUp')} />
        </>
      )}
    </View>
  );
}
