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

// Konfigurasi Supabase V2.0.0
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

  const hasInitializedSession = useRef(false);

  useEffect(() => {
    checkLogin();

    const {
      data: { subscription },
    } = supabase.auth.onAuthStateChange((_event, session) => {
      if (session?.user) {
        const userData = {
          id: session.user.id,
          email: session.user.email,
          name:
            session.user.user_metadata?.name ||
            session.user.email?.split('@')[0] ||
            'Owner',
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

    const subscriptionAppState = AppState.addEventListener(
      'change',
      (nextAppState) => {
        if (nextAppState === 'active') {
          supabase.auth.getSession().then(({ data: { session } }) => {
            if (session?.user) {
              initSession(session);
            }
          });
        }
      }
    );

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
          Authorization: `Bearer ${session.access_token}`,
          apikey: ANON_KEY,
        },
        body: JSON.stringify({ action: 'init_session' }),
      });
      const data = await res.json();
      if (data.opening) {
        setMessages((prev) => {
          if (prev.some((m) => m.id === 'session-opening')) return prev;
          return [
            ...prev,
            {
              id: 'session-opening',
              role: 'assistant',
              content: data.opening,
              transient: true,
            },
          ];
        });
      }
    } catch (e) {
      console.log('init_session error:', e.message);
    }
  };

  const checkLogin = async () => {
    try {
      const {
        data: { session },
      } = await supabase.auth.getSession();

      if (session?.user) {
        const userData = {
          id: session.user.id,
          email: session.user.email,
          name:
            session.user.user_metadata?.name ||
            session.user.email?.split('@')[0] ||
            'Owner',
        };
        setUser(userData);
        setMessages([
          {
            id: '1',
            role: 'assistant',
            content:
              'Halo ' +
              userData.name +
              '! Gw Second Head. Ada yang bisa gw bantu?',
          },
        ]);
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
      let authResult = await supabase.auth.signInWithPassword({
        email: email.trim(),
        password: password,
      });
      let { data, error } = authResult;

      if (error) {
        if (
          error.message?.toLowerCase().includes('invalid login credentials')
        ) {
          const signUpResult = await supabase.auth.signUp({
            email: email.trim(),
            password: password,
            options: {
              data: { name: name.trim() || email.trim().split('@')[0] },
            },
          });
          if (signUpResult.error) throw signUpResult.error;
          data = signUpResult.data;
          if (!data.session) {
            alert(
              'Akun berhasil dibuat. Silakan konfirmasi email jika diminta.'
            );
            return;
          }
        } else {
          throw error;
        }
      }

      if (!data?.user || !data?.session)
        throw new Error('Authentication session tidak tersedia.');

      const authenticatedUser = data.user;
      setUser({
        id: authenticatedUser.id,
        email: authenticatedUser.email,
        name:
          authenticatedUser.user_metadata?.name ||
          authenticatedUser.email?.split('@')[0] ||
          'Owner',
      });
      setMessages([
        {
          id: '1',
          role: 'assistant',
          content:
            'Halo ' +
            (authenticatedUser.user_metadata?.name ||
              authenticatedUser.email?.split('@')[0] ||
              'Owner') +
            '! Gw Second Head. Ada yang bisa gw bantu?',
        },
      ]);
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

    const currentInput = input.trim();
    const userMsg = {
      id: Date.now().toString(),
      role: 'user',
      content: currentInput,
    };
    setMessages((prev) => [...prev, userMsg]);

    setInput('');
    setLoading(true);

    // =======================================================================
    // BARU: Logika Deteksi Bahasa Natural untuk Gambar (Smarter Routing)
    // =======================================================================
    
    // Pola Regex untuk instruksi gambar (Case-insensitive)
    const imagePatterns = [
      /^\/(image|gambar)\s+/i, // Mencari /image atau /gambar di awal
      /^(gambarkan|buat(kan)? gambar|bikin(kan)? gambar|lukis(kan)?|visualisasi(kan)?)\s+/i, // Triggers Bahasa Indonesia
      /^(draw|generate image|make (an )?image|paint|visualize)\s+/i // Triggers Bahasa Inggris
    ];

    // Cek apakah input cocok dengan salah satu pola permintaan gambar
    const isImageReq = imagePatterns.some(pattern => pattern.test(currentInput));

    try {
      if (isImageReq) {
        setLoadingText('Memproses gambar AI (butuh beberapa detik)...');

        // Bersihkan prompt dari prefix instruksi (agar model mendapatkan prompt bersih)
        let cleanPrompt = currentInput;
        const prefixesToRemove = [
          /^\/(image|gambar)\s+/i,
          /^(gambarkan|buat(kan)? gambar|bikin(kan)? gambar|lukis(kan)?|visualisasi(kan)?)\s*(tentang|berupa|sebuah)?\s*/i,
          /^(draw|generate image|make (an )?image|paint|visualize)\s*(of|a)?\s*/i
        ];

        prefixesToRemove.forEach(prefix => {
          cleanPrompt = cleanPrompt.replace(prefix, '');
        });

        const finalPromptForModel = cleanPrompt.trim() || currentInput;
        const encodedPrompt = encodeURIComponent(finalPromptForModel);

        // URL Tanpa parameter &model= agar tidak memicu HTTP 500 (Base64 fetching tetap dipakai agar stabil)
        const targetUrl = `https://image.pollinations.ai/prompt/${encodedPrompt}?width=512&height=512&nologo=true&seed=${Math.floor(Math.random() * 1000000)}`;

        // 1. Ambil gambar via JS Fetch (menghindari native network errors)
        const response = await fetch(targetUrl);
        if (!response.ok) {
          throw new Error(
            `Server Pollinations sibuk (HTTP ${response.status}). Silakan coba lagi.`
          );
        }

        // 2. Ubah hasil Blob menjadi Data URI (Base64)
        const blob = await response.blob();
        const base64Image = await new Promise((resolve, reject) => {
          const reader = new FileReader();
          reader.onloadend = () => resolve(reader.result);
          reader.onerror = reject;
          reader.readAsDataURL(blob);
        });

        // 3. Tampilkan Base64 di UI
        setMessages((prev) => [
          ...prev,
          {
            id: (Date.now() + 1).toString(),
            role: 'assistant',
            content: `Berikut hasil gambar untuk: "${finalPromptForModel}"`,
            image: base64Image,
          },
        ]);
      } else {
        // =======================================================================
        // Logika Text Chat Biasa (Ke Supabase Backend)
        // =======================================================================
        setLoadingText('Lagi mikir...');
        const {
          data: { session },
        } = await supabase.auth.getSession();
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
        setMessages((prev) => [
          ...prev,
          {
            id: (Date.now() + 1).toString(),
            role: 'assistant',
            content: reply || JSON.stringify(data),
          },
        ]);
      }
    } catch (e) {
      setMessages((prev) => [
        ...prev,
        {
          id: (Date.now() + 1).toString(),
          role: 'assistant',
          content: 'Gagal memproses permintaan: ' + e.message,
        },
      ]);
    } finally {
      setLoading(false);
      setLoadingText('');
    }
  };

  // --- Render UI Tetap Sama ---
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
        <TextInput
          style={styles.loginInput}
          value={email}
          onChangeText={setEmail}
          placeholder="Email lo"
          placeholderTextColor="#555"
          keyboardType="email-address"
          autoCapitalize="none"
        />
        <TextInput
          style={styles.loginInput}
          value={password}
          onChangeText={setPassword}
          placeholder="Password"
          placeholderTextColor="#555"
          secureTextEntry
        />
        <TextInput
          style={styles.loginInput}
          value={name}
          onChangeText={setName}
          placeholder="Nama lo (opsional, untuk signup)"
          placeholderTextColor="#555"
        />
        <TouchableOpacity
          style={styles.loginBtn}
          onPress={handleLogin}
          disabled={loading}
        >
          {loading ? (
            <ActivityIndicator color="#000" />
          ) : (
            <Text style={styles.loginBtnText}>Masuk / Daftar</Text>
          )}
        </TouchableOpacity>
      </View>
    );
  }

  return (
    <KeyboardAvoidingView
      style={styles.container}
      behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
    >
      <View style={styles.header}>
        <Text style={styles.headerText}>Second Head</Text>
        <TouchableOpacity onPress={handleLogout}>
          <Text style={styles.logoutText}>Keluar</Text>
        </TouchableOpacity>
      </View>

      <FlatList
        data={messages}
        keyExtractor={(item) => item.id}
        style={styles.chatArea}
        contentContainerStyle={{ padding: 12 }}
        renderItem={({ item }) => (
          <View
            style={[
              styles.bubble,
              item.role === 'user' ? styles.userBubble : styles.aiBubble,
            ]}
          >
            {item.content ? (
              <Text
                style={[
                  styles.bubbleText,
                  item.role === 'user' && styles.userText,
                  item.image ? { marginBottom: 8 } : null,
                ]}
              >
                {item.content}
              </Text>
            ) : null}

            {item.image ? (
              <View style={styles.imageContainer}>
                <Image
                  source={{ uri: item.image }}
                  style={styles.generatedImage}
                  resizeMode="cover"
                />
              </View>
            ) : null}
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
        <TextInput
          style={styles.input}
          value={input}
          onChangeText={setInput}
          placeholder="Ketik pesan atau Gambarkan kucing..."
          placeholderTextColor="#555"
          multiline
        />
        <TouchableOpacity style={styles.sendBtn} onPress={sendMessage}>
          <Text style={styles.sendText}>➤</Text>
        </TouchableOpacity>
      </View>
    </KeyboardAvoidingView>
  );
}

// --- Styles Tetap Sama ---
const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#0a0a0a' },
  centerScreen: {
    flex: 1,
    backgroundColor: '#0a0a0a',
    justifyContent: 'center',
    alignItems: 'center',
  },
  loginScreen: {
    flex: 1,
    backgroundColor: '#0a0a0a',
    justifyContent: 'center',
    padding: 24,
  },
  loginTitle: {
    color: '#00ff88',
    fontSize: 32,
    fontWeight: 'bold',
    textAlign: 'center',
    marginBottom: 8,
  },
  loginSubtitle: {
    color: '#555',
    fontSize: 16,
    textAlign: 'center',
    marginBottom: 40,
  },
  loginInput: {
    backgroundColor: '#1a1a1a',
    color: '#fff',
    borderRadius: 12,
    paddingHorizontal: 16,
    paddingVertical: 14,
    fontSize: 15,
    marginBottom: 12,
    borderWidth: 1,
    borderColor: '#333',
  },
  loginBtn: {
    backgroundColor: '#00ff88',
    borderRadius: 12,
    padding: 16,
    alignItems: 'center',
    marginTop: 8,
  },
  loginBtnText: { color: '#000', fontSize: 16, fontWeight: 'bold' },
  header: {
    backgroundColor: '#111',
    padding: 16,
    paddingTop: 48,
    alignItems: 'center',
    borderBottomWidth: 1,
    borderBottomColor: '#00ff88',
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  headerText: { color: '#00ff88', fontSize: 20, fontWeight: 'bold' },
  logoutText: { color: '#555', fontSize: 13 },
  chatArea: { flex: 1 },
  bubble: { maxWidth: '85%', padding: 12, borderRadius: 16, marginBottom: 8 },
  userBubble: { backgroundColor: '#00ff88', alignSelf: 'flex-end' },
  aiBubble: {
    backgroundColor: '#1a1a1a',
    alignSelf: 'flex-start',
    borderWidth: 1,
    borderColor: '#222',
  },
  bubbleText: { color: '#eee', fontSize: 15, lineHeight: 22 },
  userText: { color: '#000' },
  imageContainer: {
    width: 250,
    height: 250,
    backgroundColor: '#222',
    borderRadius: 12,
    overflow: 'hidden',
    justifyContent: 'center',
    alignItems: 'center',
  },
  generatedImage: { width: '100%', height: '100%' },
  loadingRow: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 16,
    paddingBottom: 8,
    gap: 8,
  },
  loadingText: { color: '#555', fontSize: 13 },
  inputArea: {
    flexDirection: 'row',
    padding: 8,
    backgroundColor: '#111',
    alignItems: 'flex-end',
    borderTopWidth: 1,
    borderTopColor: '#222',
  },
  input: {
    flex: 1,
    backgroundColor: '#1a1a1a',
    color: '#fff',
    borderRadius: 20,
    paddingHorizontal: 16,
    paddingVertical: 10,
    fontSize: 15,
    maxHeight: 100,
  },
  sendBtn: {
    backgroundColor: '#00ff88',
    width: 44,
    height: 44,
    borderRadius: 22,
    justifyContent: 'center',
    alignItems: 'center',
    marginLeft: 8,
  },
  sendText: { fontSize: 18 },
});
