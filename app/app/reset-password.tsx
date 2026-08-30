import { useEffect, useMemo, useState } from 'react';
import { ActivityIndicator, Button, Text, TextInput, View } from 'react-native';
import * as Linking from 'expo-linking';
import { router } from 'expo-router';
import { backend } from '../services/backend';
import { exchangePasswordRecoveryCode, setPassword } from '../services/auth';

function readHashParams(url: string) {
  const hash = url.split('#')[1] ?? '';
  return new URLSearchParams(hash);
}

export default function ResetPasswordScreen() {
  const [password, setPasswordValue] = useState('');
  const [confirmation, setConfirmation] = useState('');
  const [ready, setReady] = useState(false);
  const [busy, setBusy] = useState(true);
  const [message, setMessage] = useState<string | null>(null);

  const initialUrl = Linking.useLinkingURL();
  const path = useMemo(() => initialUrl ? Linking.parse(initialUrl).path : null, [initialUrl]);

  useEffect(() => {
    let cancelled = false;

    async function establishRecoverySession(url: string | null) {
      try {
        if (url) {
          const parsed = Linking.parse(url);
          const code = typeof parsed.queryParams?.code === 'string'
            ? parsed.queryParams.code
            : null;

          if (code) {
            const result = await exchangePasswordRecoveryCode(code);
            if (result.error) throw result.error;
          } else {
            const hash = readHashParams(url);
            const accessToken = hash.get('access_token');
            const refreshToken = hash.get('refresh_token');

            if (accessToken && refreshToken) {
              const result = await backend.auth.setSession({
                access_token: accessToken,
                refresh_token: refreshToken,
              });
              if (result.error) throw result.error;
            }
          }
        }

        const { data, error } = await backend.auth.getSession();
        if (error) throw error;
        if (!data.session) {
          throw new Error('Recovery link is invalid or expired. Request a new password reset email.');
        }

        if (!cancelled) {
          setReady(true);
          setMessage(null);
        }
      } catch (err) {
        if (!cancelled) {
          setReady(false);
          setMessage(err instanceof Error ? err.message : 'Unable to open password recovery.');
        }
      } finally {
        if (!cancelled) setBusy(false);
      }
    }

    void establishRecoverySession(initialUrl);
    return () => {
      cancelled = true;
    };
  }, [initialUrl]);

  async function submit() {
    if (password.length < 8) {
      setMessage('Password must be at least 8 characters.');
      return;
    }
    if (password !== confirmation) {
      setMessage('Passwords do not match.');
      return;
    }

    setBusy(true);
    setMessage(null);
    try {
      const result = await setPassword(password);
      if (result.error) throw result.error;
      await backend.auth.signOut();
      router.replace('/login');
    } catch (err) {
      setMessage(err instanceof Error ? err.message : 'Password update failed.');
    } finally {
      setBusy(false);
    }
  }

  return (
    <View style={{ flex: 1, justifyContent: 'center', padding: 24, gap: 12 }}>
      <Text style={{ fontSize: 28, fontWeight: '700' }}>Set new password</Text>
      {busy ? <ActivityIndicator /> : null}
      {path !== 'reset-password' && !initialUrl ? (
        <Text>Open this screen from the password recovery email.</Text>
      ) : null}
      {ready ? (
        <>
          <TextInput
            secureTextEntry
            placeholder="New password"
            placeholderTextColor="#6B7280"
            value={password}
            onChangeText={setPasswordValue}
            style={{ borderWidth: 1, borderRadius: 8, padding: 12, color: '#111827' }}
          />
          <TextInput
            secureTextEntry
            placeholder="Confirm new password"
            placeholderTextColor="#6B7280"
            value={confirmation}
            onChangeText={setConfirmation}
            style={{ borderWidth: 1, borderRadius: 8, padding: 12, color: '#111827' }}
          />
          <Button title="Update password" onPress={() => void submit()} disabled={busy} />
        </>
      ) : null}
      {message ? <Text>{message}</Text> : null}
      <Button title="Back to login" onPress={() => router.replace('/login')} />
    </View>
  );
}
