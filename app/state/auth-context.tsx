import { createContext, useContext, useEffect, useMemo, useState, type ReactNode } from 'react';
import type { Session } from '@supabase/supabase-js';
import { getSession, onAuthStateChange, signOut } from '../services/auth';
import { loadAuthenticatedContext } from '../services/account';
import { backend } from '../services/backend';

export type AuthContextValue = {
  session: Session | null;
  context: Awaited<ReturnType<typeof loadAuthenticatedContext>>;
  loading: boolean;
  error: string | null;
  logout: () => Promise<void>;
};

const AuthContext = createContext<AuthContextValue | null>(null);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [session, setSession] = useState<Session | null>(null);
  const [context, setContext] = useState<AuthContextValue['context']>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  async function bootstrap(nextSession: Session | null) {
    setSession(nextSession);
    setError(null);
    if (!nextSession) {
      setContext(null);
      setLoading(false);
      return;
    }

    try {
      setLoading(true);
      let nextContext = await loadAuthenticatedContext();

      if (nextContext?.account.status === 'deactivated') {
        await signOut();
        setSession(null);
        setContext(null);
        setError('ACCOUNT_DEACTIVATED: this account is permanently deactivated and cannot sign in.');
        return;
      }

      if (nextContext) {
        const { error: cloneError } = await backend.rpc('runtime_materialize_registered_clone');
        if (cloneError) throw cloneError;
        nextContext = await loadAuthenticatedContext();
      }

      setContext(nextContext);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Unable to load authenticated context');
      setContext(null);
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    let mounted = true;

    getSession()
      .then(({ data, error: sessionError }) => {
        if (!mounted) return;
        if (sessionError) throw sessionError;
        return bootstrap(data.session);
      })
      .catch((err) => {
        if (!mounted) return;
        setError(err instanceof Error ? err.message : 'Unable to restore session');
        setLoading(false);
      });

    const { data } = onAuthStateChange(async (_event, nextSession) => {
      await bootstrap(nextSession);
    });

    return () => {
      mounted = false;
      data.subscription.unsubscribe();
    };
  }, []);

  const value = useMemo<AuthContextValue>(() => ({
    session,
    context,
    loading,
    error,
    logout: async () => {
      await signOut();
    },
  }), [session, context, loading, error]);

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth() {
  const value = useContext(AuthContext);
  if (!value) throw new Error('useAuth must be used inside AuthProvider');
  return value;
}
