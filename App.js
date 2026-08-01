import { useState, useEffect, useRef } from 'react';
import {
  StyleSheet,
  Text,
  View,
  TextInput,
  TouchableOpacity,
  FlatList,
  KeyboardAvoidingView,
  Platform,
  ActivityIndicator,
  Image,
  AppState,
} from 'react-native';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { createClient } from '@supabase/supabase-js';

const SUPABASE_URL = 'https://fbiazqbrkwovzrirnzpb.supabase.co';
const ANON_KEY =
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZiaWF6cWJya3dvdnpyaXJuenBiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODUyMzgxNjUsImV4cCI6MjEwMDgxNDE2NX0.SZcO6PwXblTWReg_C7h5is45i9av63xxkeP3taSK0io';

const supabase = createClient(SUPABASE_URL, ANON_KEY, {
  auth: {
    storage: AsyncStorage,
    autoRefreshToken: true,
    persistSession: true,
    detectSessionInUrl: false,
  },
});

export default function App() {
  const [screen, setScreen] = useState('loading');
  const [user, setUser] = useState(null);
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [name, setName] = useState('');
  const [messages, setMessages] = useState([]);
  const [input, setInput] = useState('');
  const [loading, setLoading] = useState(false);
  const [loadingText, setLoadingText] = useState('');
  
  // Ref untuk mencegah multiple init_session call
  const hasInitializedSession = useRef(false);

  useEffect(() => {
    checkLogin();

    const { data: { subscription } } = supabase.auth.onAuthStateChange((_event, session) => {
      if (session?.user) {
        const userData = {
          id: session.user.id,
          email: session.user.email,
          name: session.user.user_metadata?.name || session.user.email?.split('@')[0] || 'Owner',
        };
        setUser(userData);
        setScreen('chat');
        
        if (!hasInitializedSession.current) {
          hasInitializedSession.current = true;
          initSession(session);
        }
      } else {
        setUser(null);
        setScreen('login');
        hasInitializedSession.current = false;
      }
    });

    // Handle app resume dari background
    const subscriptionAppState = AppState.addEventListener('change', nextAppState => {
      if (nextAppState === 'active') {
        supabase.auth.getSession().then(({ data: { session } }) => {
          if (session?.user) {
            initSession(session);
          }
        });
      }
    });

    return () => {
      subscription.unsubscribe();
      subscriptionAppState.remove();
    };
  }, []);

  const initSession = async (session) => {
    if (!session?.access_token) return;
    try {
      const res = await fetch(`${SUPABASE_URL}/functions/v1/chat`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${session.access_token}`,
          'apikey': ANON_KEY,
        },
        body: JSON.stringify({ action: 'init_session' }),
      });
      const data = await res.json();
      if (data.opening) {
        setMessages(prev => {
          if (prev.some(m => m.id === 'session-opening')) return prev;
          return [...prev, {
            id: 'session-opening',
            role: 'assistant',
            content: data.opening,
            transient: true,
          }];
        });
      }
    } catch (e) {
      console.log('init_session error:', e.message);
    }
  };

  const checkLogin = async () => {
    try {
      const { data: { session } } = await supabase.auth.getSession();

      if (session?.user) {
        const userData = {
          id: session.user.id,
          email: session.user.email,
          name: session.user.user_metadata?.name || session.user.email?.split('@')[0] || 'Owner',
        };
        setUser(userData);
        setMessages([{
          id: '1',
          role: 'assistant',
          content: 'Halo ' + userData.name + '! Gw Second Head. Ada yang bisa gw bantu?',
        }]);
        setScreen('chat');
        hasInitializedSession.current = true;
        await initSession(session);
        return;
      }
      setScreen('login');
    } catch (e) {
      console.error('Session restore error:', e);
      setScreen('login');
    }
  };

  const handleLogin = async () => {
    if (!email.trim() || !password.trim()) {
      alert('Email dan password wajib diisi.');
      return;
    }
    setLoading(true);
    try {
      let authResult = await supabase.auth.signInWithPassword({ email: email.trim(), password: password });
      let { data, error } = authResult;

      if (error) {
        if (error.message?.toLowerCase().includes('invalid login credentials')) {
          const signUpResult = await supabase.auth.signUp({
            email: email.trim(),
            password: password,
            options: { data: { name: name.trim() || email.trim().split('@')[0] } },
          });
          if (signUpResult.error) throw signUpResult.error;
          data = signUpResult.data;
          if (!data.session) {
            alert('Akun berhasil dibuat. Silakan konfirmasi email jika diminta.');
            return;
          }
        } else {
          throw error;
        }
      }

      if (!data?.user || !data?.session) throw new Error('Authentication session tidak tersedia.');

      const authenticatedUser = data.user;
      setUser({
        id: authenticatedUser.id,
        email: authenticatedUser.email,
        name: authenticatedUser.user_metadata?.name || authenticatedUser.email?.split('@')[0] || 'Owner',
      });
      setMessages([{
        id: '1',
        role: 'assistant',
        content: 'Halo ' + (authenticatedUser.user_metadata?.name || authenticatedUser.email?.split('@')[0] || 'Owner') + '! Gw Second Head. Ada yang bisa gw bantu?',
      }]);
      setScreen('chat');
      hasInitializedSession.current = true;
      await initSession(data.session);
    } catch (error) {
      alert('Login error: ' + error.message);
    } finally {
      setLoading(false);
    }
  };

  const handleLogout = async () => {
    await supabase.auth.signOut();
    setUser(null);
    setMessages([]);
    setScreen('login');
    hasInitializedSession.current = false;
  };

  const sendMessage = async () => {
    if (!input.trim() || loading) return;

    const userMsg = { id: Date.now().toString(), role: 'user', content: input };
    setMessages((prev) => [...prev, userMsg]);

    const currentInput = input;
    setInput('');
    setLoading(true);

    try {
      if (currentInput.startsWith('/image ')) {
        const prompt = currentInput.replace('/image ', '').trim();
        setLoadingText('Generate gambar...');

        // Pollinations AI (Flux model for better stability)
        const encodedPrompt = encodeURIComponent(prompt);
        const imageUrl = `https://image.pollinations.ai/prompt/${encodedPrompt}?width=512&height=512&nologo=true&model=flux&seed=${Date.now()}`;

        setMessages((prev) => [
          ...prev,
          {
            id: (Date.now() + 1).toString(),
            role: 'assistant',
            content: `Gambar "${prompt}" sedang diproses...`,
            image: imageUrl,
          },
        ]);
      } else {
        setLoadingText('Lagi mikir...');
        const { data: { session } } = await supabase.auth.getSession();
        if (!session) throw new Error('Session expired. Silakan login kembali.');

        const res = await fetch(SUPABASE_URL + '/functions/v1/chat', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            apikey: ANON_KEY,
            Authorization: `Bearer ${session.access_token}`,
          },
          body: JSON.stringify({ action: 'chat', message: currentInput }),
        });

        const data = await res.json();
        if (!res.ok) throw new Error(data.error || 'Chat request failed');

        const reply = data.response || data.reply;
        setMessages((prev) => [...prev, { id: (Date.now() + 1).toString(), role: 'assistant', content: reply || JSON.stringify(data) }]);
      }
    } catch (e) {
      setMessages((prev) => [...prev, { id: (Date.now() + 1).toString(), role: 'assistant', content: 'Error: ' + e.message }]);
    } finally {
      setLoading(false);
      setLoadingText('');
    }
  };

  if (screen === 'loading') {
    return (
      <View style={styles.centerScreen}>
        <ActivityIndicator color="#00ff88" size="large" />
      </View>
    );
  }

  if (screen === 'login') {
    return (
      <View style={styles.loginScreen}>
        <Text style={styles.loginTitle}>Second Head</Text>
        <Text style={styles.loginSubtitle}>Personal AI Assistant</Text>
        <TextInput style={styles.loginInput} value={email} onChangeText={setEmail} placeholder="Email lo" placeholderTextColor="#555" keyboardType="email-address" autoCapitalize="none" />
        <TextInput style={styles.loginInput} value={password} onChangeText={setPassword} placeholder="Password" placeholderTextColor="#555" secureTextEntry />
        <TextInput style={styles.loginInput} value={name} onChangeText={setName} placeholder="Nama lo (opsional, untuk signup)" placeholderTextColor="#555" />
        <TouchableOpacity style={styles.loginBtn} onPress={handleLogin} disabled={loading}>
          {loading ? <ActivityIndicator color="#000" /> : <Text style={styles.loginBtnText}>Masuk / Daftar</Text>}
        </TouchableOpacity>
      </View>
    );
  }

  return (
    <KeyboardAvoidingView style={styles.container} behavior={Platform.OS === 'ios' ? 'padding' : 'height'}>
      <View style={styles.header}>
        <Text style={styles.headerText}>Second Head</Text>
        <TouchableOpacity onPress={handleLogout}><Text style={styles.logoutText}>Keluar</Text></TouchableOpacity>
      </View>

      <FlatList
        data={messages}
        keyExtractor={(item) => item.id}
        style={styles.chatArea}
        contentContainerStyle={{ padding: 12 }}
        renderItem={({ item }) => (
          <View style={[styles.bubble, item.role === 'user' ? styles.userBubble : styles.aiBubble]}>
            {item.image ? (
              <View style={styles.imageContainer}>
                <Image
                  source={{ uri: item.image }}
                  style={styles.generatedImage}
                  resizeMode="contain"
                  onLoad={() => console.log('Image loaded')}
                  onError={(e) => {
                    console.error('Image load error:', e.nativeEvent.error);
                    setMessages(prev => prev.map(msg => msg.id === item.id ? { ...msg, content: 'Gagal memuat gambar. Coba prompt lain.', image: null } : msg));
                  }}
                />
              </View>
            ) : (
              <Text style={[styles.bubbleText, item.role === 'user' && styles.userText]}>{item.content}</Text>
            )}
          </View>
        )}
      />

      {loading && (
        <View style={styles.loadingRow}>
          <ActivityIndicator color="#00ff88" />
          <Text style={styles.loadingText}>{loadingText}</Text>
        </View>
      )}

      <View style={styles.inputArea}>
        <TextInput style={styles.input} value={input} onChangeText={setInput} placeholder="Ketik pesan atau /image kucing..." placeholderTextColor="#555" multiline />
        <TouchableOpacity style={styles.sendBtn} onPress={sendMessage}>
          <Text style={styles.sendText}>➤</Text>
        </TouchableOpacity>
      </View>
    </KeyboardAvoidingView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#0a0a0a' },
  centerScreen: { flex: 1, backgroundColor: '#0a0a0a', justifyContent: 'center', alignItems: 'center' },
  loginScreen: { flex: 1, backgroundColor: '#0a0a0a', justifyContent: 'center', padding: 24 },
  loginTitle: { color: '#00ff88', fontSize: 32, fontWeight: 'bold', textAlign: 'center', marginBottom: 8 },
  loginSubtitle: { color: '#555', fontSize: 16, textAlign: 'center', marginBottom: 40 },
  loginInput: { backgroundColor: '#1a1a1a', color: '#fff', borderRadius: 12, paddingHorizontal: 16, paddingVertical: 14, fontSize: 15, marginBottom: 12, borderWidth: 1, borderColor: '#333' },
  loginBtn: { backgroundColor: '#00ff88', borderRadius: 12, padding: 16, alignItems: 'center', marginTop: 8 },
  loginBtnText: { color: '#000', fontSize: 16, fontWeight: 'bold' },
  header: { backgroundColor: '#111', padding: 16, paddingTop: 48, alignItems: 'center', borderBottomWidth: 1, borderBottomColor: '#00ff88', flexDirection: 'row', justifyContent: 'space-between' },
  headerText: { color: '#00ff88', fontSize: 20, fontWeight: 'bold' },
  logoutText: { color: '#555', fontSize: 13 },
  chatArea: { flex: 1 },
  bubble: { maxWidth: '85%', padding: 12, borderRadius: 16, marginBottom: 8 },
  userBubble: { backgroundColor: '#00ff88', alignSelf: 'flex-end' },
  aiBubble: { backgroundColor: '#1a1a1a', alignSelf: 'flex-start', borderWidth: 1, borderColor: '#222' },
  bubbleText: { color: '#eee', fontSize: 15, lineHeight: 22 },
  userText: { color: '#000' },
  imageContainer: { width: 250, height: 250, backgroundColor: '#222', borderRadius: 12, overflow: 'hidden', justifyContent: 'center', alignItems: 'center' },
  generatedImage: { width: '100%', height: '100%' },
  loadingRow: { flexDirection: 'row', alignItems: 'center', paddingHorizontal: 16, paddingBottom: 8, gap: 8 },
  loadingText: { color: '#555', fontSize: 13 },
  inputArea: { flexDirection: 'row', padding: 8, backgroundColor: '#111', alignItems: 'flex-end', borderTopWidth: 1, borderTopColor: '#222' },
  input: { flex: 1, backgroundColor: '#1a1a1a', color: '#fff', borderRadius: 20, paddingHorizontal: 16, paddingVertical: 10, fontSize: 15, maxHeight: 100 },
  sendBtn: { backgroundColor: '#00ff88', width: 44, height: 44, borderRadius: 22, justifyContent: 'center', alignItems: 'center', marginLeft: 8 },
  sendText: { fontSize: 18 },
});
