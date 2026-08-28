import { PropsWithChildren, ReactNode, useState } from 'react';
import { Modal, Pressable, ScrollView, StyleSheet, Text, useWindowDimensions, View } from 'react-native';
import { router, usePathname } from 'expo-router';

type NavItem = { label: string; icon: string; route: string };

const NAV: NavItem[] = [
  { label: 'Chat', icon: '◌', route: '/(tabs)/chat' },
  { label: 'Journey', icon: '⌁', route: '/(tabs)/journey' },
  { label: 'Lifecycle', icon: '↻', route: '/(tabs)/lifecycle' },
  { label: 'More', icon: '⋯', route: '/(tabs)/more' },
];

function NavContent({ expanded, onNavigate }: { expanded: boolean; onNavigate: (route: string) => void }) {
  const pathname = usePathname();
  return (
    <View style={styles.navInner}>
      <View style={styles.brandMark}><Text style={styles.brandText}>S</Text></View>
      <View style={styles.navItems}>
        {NAV.map(item => {
          const active = pathname.includes(item.label.toLowerCase());
          return (
            <Pressable key={item.label} accessibilityRole="button" accessibilityLabel={item.label} onPress={() => onNavigate(item.route)} style={[styles.navItem, active && styles.navItemActive]}>
              <Text style={[styles.navIcon, active && styles.navIconActive]}>{item.icon}</Text>
              {expanded ? <Text style={[styles.navLabel, active && styles.navLabelActive]}>{item.label}</Text> : null}
            </Pressable>
          );
        })}
      </View>
      <View style={styles.navBottom}>
        {expanded ? <Text style={styles.navHint}>Second Head</Text> : <Text style={styles.navHint}>SH</Text>}
      </View>
    </View>
  );
}

export function SHShell({ children, right, title, context }: PropsWithChildren<{ right?: ReactNode; title?: string; context?: ReactNode }>) {
  const { width } = useWindowDimensions();
  const mobile = width < 700;
  const tablet = width >= 700 && width < 980;
  const [expanded, setExpanded] = useState(false);
  const [mobileOpen, setMobileOpen] = useState(false);
  const [contextOpen, setContextOpen] = useState(false);

  const navigate = (route: string) => { setMobileOpen(false); router.push(route); };

  return (
    <View style={styles.root}>
      {!mobile ? (
        <View style={[styles.rail, tablet && styles.railTablet, expanded && !tablet && styles.railExpanded]}>
          <NavContent expanded={expanded} onNavigate={navigate} />
          <Pressable accessibilityRole="button" accessibilityLabel={expanded ? 'Collapse navigation' : 'Expand navigation'} onPress={() => setExpanded(v => !v)} style={[styles.expandButton, tablet && styles.expandButtonHidden]}>
            <Text style={styles.expandIcon}>{expanded ? '‹' : '›'}</Text>
          </Pressable>
        </View>
      ) : null}

      {mobile && mobileOpen ? (
        <Modal transparent animationType="fade" visible onRequestClose={() => setMobileOpen(false)}>
          <Pressable style={styles.mobileBackdrop} onPress={() => setMobileOpen(false)}>
            <Pressable style={styles.mobileDrawer} onPress={event => event.stopPropagation()}>
              <NavContent expanded onNavigate={navigate} />
            </Pressable>
          </Pressable>
        </Modal>
      ) : null}

      {mobile && context && contextOpen ? <Modal transparent animationType="slide" visible onRequestClose={() => setContextOpen(false)}><Pressable style={styles.contextMobileBackdrop} onPress={() => setContextOpen(false)}><Pressable style={styles.contextMobilePanel} onPress={event => event.stopPropagation()}><View style={styles.contextHeader}><Text style={styles.contextTitle}>Context</Text><Pressable accessibilityRole="button" accessibilityLabel="Close context" onPress={() => setContextOpen(false)}><Text style={styles.closeIcon}>×</Text></Pressable></View><ScrollView contentContainerStyle={styles.contextBody}>{context}</ScrollView></Pressable></Pressable></Modal> : null}

      <View style={styles.main}>
        <View style={styles.topbar}>
          {mobile ? <Pressable accessibilityRole="button" accessibilityLabel="Open navigation" onPress={() => setMobileOpen(true)} style={styles.menuButton}><Text style={styles.menuIcon}>☰</Text></Pressable> : null}
          <Text numberOfLines={1} style={styles.topTitle}>{title ?? 'Second Head'}</Text>
          <View style={styles.topActions}>
            {context ? <Pressable accessibilityRole="button" accessibilityLabel={contextOpen ? 'Close context' : 'Open context'} onPress={() => setContextOpen(v => !v)} style={[styles.contextButton, contextOpen && styles.contextButtonActive]}><Text style={styles.contextIcon}>◫</Text></Pressable> : null}
            {right ?? <View style={styles.topSpacer} />}
          </View>
        </View>
        <View style={styles.content}>{children}</View>
        {context && contextOpen && !mobile ? <View style={styles.contextPanel}><View style={styles.contextHeader}><Text style={styles.contextTitle}>Context</Text><Pressable accessibilityRole="button" accessibilityLabel="Close context" onPress={() => setContextOpen(false)}><Text style={styles.closeIcon}>×</Text></Pressable></View><ScrollView contentContainerStyle={styles.contextBody}>{context}</ScrollView></View> : null}
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  root: { flex: 1, flexDirection: 'row', backgroundColor: '#F6F5F2' },
  rail: { width: 68, borderRightWidth: 1, borderRightColor: '#E3E1DC', backgroundColor: '#FBFAF7', position: 'relative' },
  railExpanded: { width: 206 },
  railTablet: { width: 64 },
  navInner: { flex: 1, paddingVertical: 16, paddingHorizontal: 10 },
  brandMark: { width: 40, height: 40, borderRadius: 13, backgroundColor: '#181817', alignItems: 'center', justifyContent: 'center', alignSelf: 'center', marginBottom: 24 },
  brandText: { color: '#FFF', fontSize: 18, fontWeight: '800' },
  navItems: { gap: 7 },
  navItem: { minHeight: 46, borderRadius: 14, paddingHorizontal: 9, flexDirection: 'row', alignItems: 'center', gap: 12 },
  navItemActive: { backgroundColor: '#EAE7F7' },
  navIcon: { width: 28, textAlign: 'center', fontSize: 22, color: '#5F5E5A' },
  navIconActive: { color: '#5D45A5' },
  navLabel: { color: '#4D4C48', fontWeight: '600' },
  navLabelActive: { color: '#4A338E', fontWeight: '800' },
  navBottom: { marginTop: 'auto', alignItems: 'center' },
  navHint: { color: '#8B8982', fontSize: 11, fontWeight: '700' },
  expandButtonHidden: { display: 'none' },
  expandButton: { position: 'absolute', right: -12, top: 68, width: 24, height: 24, borderRadius: 12, backgroundColor: '#FFF', borderWidth: 1, borderColor: '#DDD9D1', alignItems: 'center', justifyContent: 'center' },
  expandIcon: { fontSize: 18, color: '#5D45A5', lineHeight: 20 },
  main: { flex: 1, minWidth: 0 },
  topbar: { minHeight: 58, paddingHorizontal: 18, flexDirection: 'row', alignItems: 'center', borderBottomWidth: 1, borderBottomColor: '#E7E4DE', backgroundColor: '#FBFAF7', gap: 10 },
  topTitle: { flex: 1, fontSize: 17, fontWeight: '800', color: '#22211F' },
  topSpacer: { width: 8 },
  topActions: { flexDirection: 'row', alignItems: 'center', gap: 8 },
  contextButton: { width: 40, height: 40, borderRadius: 12, alignItems: 'center', justifyContent: 'center', backgroundColor: '#ECE9E2' },
  contextButtonActive: { backgroundColor: '#EAE7F7' },
  contextIcon: { fontSize: 20, color: '#4A338E' },
  contextPanel: { width: 280, borderLeftWidth: 1, borderLeftColor: '#E3E1DC', backgroundColor: '#FBFAF7' },
  contextHeader: { minHeight: 58, paddingHorizontal: 16, flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', borderBottomWidth: 1, borderBottomColor: '#E7E4DE' },
  contextTitle: { fontSize: 17, fontWeight: '800', color: '#22211F' },
  closeIcon: { fontSize: 26, color: '#5F5E5A' },
  contextBody: { padding: 16, gap: 12 },
  contextMobileBackdrop: { flex: 1, backgroundColor: 'rgba(20,20,18,0.28)', justifyContent: 'flex-end' },
  contextMobilePanel: { maxHeight: '82%', minHeight: '45%', backgroundColor: '#FBFAF7', borderTopLeftRadius: 22, borderTopRightRadius: 22 },
  menuButton: { width: 40, height: 40, borderRadius: 12, alignItems: 'center', justifyContent: 'center', backgroundColor: '#ECE9E2' },
  menuIcon: { fontSize: 20, color: '#2D2C29' },
  content: { flex: 1 },
  mobileBackdrop: { flex: 1, backgroundColor: 'rgba(20,20,18,0.28)' },
  mobileDrawer: { width: 270, height: '100%', backgroundColor: '#FBFAF7', paddingTop: 14, borderTopRightRadius: 20, borderBottomRightRadius: 20 },
});
