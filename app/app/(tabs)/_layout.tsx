import { Tabs } from 'expo-router';

export default function TabLayout() {
  return (
    <Tabs screenOptions={{ headerShown: false, tabBarHideOnKeyboard: true }}>
      <Tabs.Screen name="chat" options={{ title: 'Chat' }} />
      <Tabs.Screen name="journey" options={{ title: 'Journey' }} />
      <Tabs.Screen name="lifecycle" options={{ title: 'Lifecycle' }} />
      <Tabs.Screen name="more" options={{ title: 'More' }} />
    </Tabs>
  );
}
