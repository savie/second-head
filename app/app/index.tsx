import { Text, View } from 'react-native';

export default function HomeScreen() {
  return (
    <View style={{ flex: 1, alignItems: 'center', justifyContent: 'center', padding: 24 }}>
      <Text style={{ fontSize: 28, fontWeight: '700' }}>Second Head</Text>
      <Text style={{ marginTop: 12, textAlign: 'center' }}>
        App skeleton — delivery layer only.
      </Text>
    </View>
  );
}
