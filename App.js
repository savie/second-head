import { useState, useEffect } from 'react';
import { StyleSheet, Text, View, TextInput, TouchableOpacity, FlatList, KeyboardAvoidingView, Platform, ActivityIndicator, Image } from 'react-native';
import AsyncStorage from '@react-native-async-storage/async-storage';

const SUPABASE_URL = 'https://fbiazqbrkwovzrirnzpb.supabase.co';
const ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZiaWF6cWJya3dvdnpyaXJuenBiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODUyMzgxNjUsImV4cCI6MjEwMDgxNDE2NX0.SZcO6PwXblTWReg_C7h5is45i9av63xxkeP3taSK0io';
const HEADERS = { 'Content-Type': 'application/json', 'apikey': ANON_KEY, 'Authorization': 'Bearer ' + ANON_KEY };

export default function App() {
  const [screen, setScreen] = useState('loading');
  const [user, setUser] = useState(null);
  const [email, setEmail] = useState('');
  const [name, setName] = useState('');
  const [messages, setMessages] = useState([]);
  const [input, setInput] = useState('');
  const [loading, setLoading] = useState(false);
  const [loadingText, setLoadingText] = useState('');

  useEffect(() => { checkLogin(); }, []);

  const checkLogin = async () => {
    try {
      const saved = await AsyncStorage.getItem('sh_user');
      if (saved) {
        const userData = JSON.parse(saved);
        setUser(userData);
        setMessages([{ id: '1', role: 'assistant', content: 'Halo ' + userData.name + '! Gw Second Head. Ada yang bisa gw bantu?' }]);
        setScreen('chat');
      } else {
        setScreen('login');
      }
    } catch (e) {
      setScreen('login');
    }
  };

  const handleLogin = async () => {
    if (!email.trim()) return;
    setLoading(true);
    try {
      const res = await fetch(SUPABASE_URL + '/functions/v1/auth', {
        method: 'POST',
        headers: HEADERS,
        body: JSON.stringify({ email: email.trim(), name: name.trim() }),
      });
      const data = await res.json();
      if (data.user) {
        await AsyncStorage.setItem('sh_user', JSON.stringify(data.user));
        setUser(data.user);
        setMessages([{ id: '1', role: 'assistant', content: 'Halo ' + data.user.name + '! Gw Second Head. Ada yang bisa gw bantu?' }]);
        setScreen('chat');
      } else {
        alert('Login gagal: ' + JSON.stringify(data));
      }
    } catch (e) {
      alert('Login error: ' + e.message);
    } finally {
      setLoading(false);
    }
  };

  const handleLogout = async () => {
    await AsyncStorage.removeItem('sh_user');
    setUser(null);
    setMessages([]);
    setScreen('login');
  };

  const sendMessage = async () => {
    if (!input.trim() || loading) return;
    const userMsg = { id: Date.now().toString(), role: 'user', content: input };
    setMessages(prev => [...prev, userMsg]);
    const currentInput = input;
    setInput('');
    setLoading(true);
    try {
      if (currentInput.startsWith('/image ')) {
        const prompt = currentInput.replace('/image ', '').trim();
        setLoadingText('Generate gambar...');
        const imageUrl = 'https://image.pollinations.ai/prompt/' + encodeURIComponent(prompt) + '?width=512&height=512&nologo=true';
        setMessages(prev => [...prev, { id: (Date.now() + 1).toString(), role: 'assistant', content: '', image: imageUrl }]);
      } else {
        setLoadingText('Lagi mikir...');
        const res = await fetch(SUPABASE_URL + '/functions/v1/chat', {
          method: 'POST',
          headers: HEADERS,
          body: JSON.stringify({ user_id: user.id, message: currentInput }),
        });
        const data = await res.json();
        setMessages(prev => [...prev, { id: (Date.now() + 1).toString(), role: 'assistant', content: data.reply || JSON.stringify(data) }]);
      }
    } catch (e) {
      setMessages(prev => [...prev, { id: (Date.now() + 1).toString(), role: 'assistant', content: 'Error: ' + e.message }]);
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
        <TextInput style={styles.loginInput} value={name} onChangeText={setName} placeholder="Nama lo (opsional)" placeholderTextColor="#555" />
        <TouchableOpacity style={styles.loginBtn} onPress={handleLogin} disabled={loading}>
          {loading ? <ActivityIndicator color="#000" /> : <Text style={styles.loginBtnText}>Masuk</Text>}
        </TouchableOpacity>
      </View>
    );
  }

  return (
    <KeyboardAvoidingView style={styles.container} behavior={Platform.OS === 'ios' ? 'padding' : 'height'}>
      <View style={styles.header}>
        <Text style={styles.headerText}>Second Head</Text>
        <TouchableOpacity onPress={handleLogout}>
          <Text style={styles.logoutText}>Keluar</Text>
        </TouchableOpacity>
      </View>
      <FlatList
        data={messages}
        keyExtractor={item => item.id}
        style={styles.chatArea}
        contentContainerStyle={{ padding: 12 }}
        renderItem={({ item }) => (
          <View style={[styles.bubble, item.role === 'user' ? styles.userBubble : styles.aiBubble]}>
            {item.image
              ? <Image source={{ uri: item.image }} style={styles.generatedImage} resizeMode="contain" />
              : <Text style={[styles.bubbleText, item.role === 'user' && styles.userText]}>{item.content}</Text>
            }
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
  generatedImage: { width: 250, height: 250, borderRadius: 12 },
  loadingRow: { flexDirection: 'row', alignItems: 'center', paddingHorizontal: 16, paddingBottom: 8, gap: 8 },
  loadingText: { color: '#555', fontSize: 13 },
  inputArea: { flexDirection: 'row', padding: 8, backgroundColor: '#111', alignItems: 'flex-end', borderTopWidth: 1, borderTopColor: '#222' },
  input: { flex: 1, backgroundColor: '#1a1a1a', color: '#fff', borderRadius: 20, paddingHorizontal: 16, paddingVertical: 10, fontSize: 15, maxHeight: 100 },
  sendBtn: { backgroundColor: '#00ff88', width: 44, height: 44, borderRadius: 22, justifyContent: 'center', alignItems: 'center', marginLeft: 8 },
  sendText: { fontSize: 18 }
});
