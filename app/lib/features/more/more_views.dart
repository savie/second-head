import 'package:flutter/material.dart';

import '../conversation/conversation_view.dart';
import '../../core/theme/sh_theme.dart';
import '../../core/state/sh_profile_state.dart';
import '../auth/auth_screens.dart';
import '../../core/navigation/sh_navigation_shell.dart';
import '../../core/widgets/sh_brand_mark.dart';

class SideMenu extends StatefulWidget {
  const SideMenu({super.key, required this.onSelectPage});

  final ValueChanged<int> onSelectPage;

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  bool _conversationExpanded = false;

  void _closeDrawer() => Navigator.of(context).pop();

  void _openPage(int index) {
    _closeDrawer();
    widget.onSelectPage(index);
  }

  void _startNewConversation() {
    conversationTitle.value = 'New Conversation';
    conversationRevision.value++;
    _openPage(0);
  }

  void _openRecent(int index) {
    final conversations = recentConversations.value;
    if (index < 0 || index >= conversations.length) return;
    conversationTitle.value = conversations[index].title;
    _openPage(0);
  }

  void _rename(BuildContext context, int index) {
    final item = recentConversations.value[index];
    final controller = TextEditingController(text: item.title);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: shSurface,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheet) => Padding(
        padding: EdgeInsets.fromLTRB(
          18, 8, 18, MediaQuery.of(sheet).viewInsets.bottom + 18,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Rename conversation',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            TextField(controller: controller, autofocus: true),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(sheet),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    final name = controller.text.trim();
                    if (name.isNotEmpty) {
                      final list = [...recentConversations.value];
                      list[index] = RecentConversationEntry(name, item.preview);
                      recentConversations.value = list;
                      if (conversationTitle.value == item.title) {
                        conversationTitle.value = name;
                      }
                    }
                    Navigator.pop(sheet);
                  },
                  child: const Text('Save'),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  void _showInfo(BuildContext context, String title, String body) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: shSurface,
      showDragHandle: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Text(body, style: const TextStyle(color: shMuted, height: 1.5)),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _logout() {
    AuthSession.isAuthenticated = false;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Widget _primaryPanel(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final panelWidth = _conversationExpanded
        ? screenWidth * .52
        : 292.0;
    return SizedBox(
      width: panelWidth,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  const ShProfileMark(size: 52),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Savie', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        Text('savie@secondhead.app', style: TextStyle(fontSize: 9, color: shMuted)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: shBorder),
            MenuTile(
              icon: Icons.chat_bubble_outline,
              label: 'Conversation',
              onTap: () => setState(() => _conversationExpanded = true),
            ),
            const Divider(color: shBorder),
            MenuTile(icon: Icons.hexagon_outlined, label: 'Journey', onTap: () => _openPage(1)),
            MenuTile(icon: Icons.event_note_outlined, label: 'Lifecycle', onTap: () => _openPage(2)),
            MenuTile(icon: Icons.person_outline, label: 'Profile', onTap: () => _openPage(3)),
            MenuTile(
              icon: Icons.help_outline,
              label: 'Help & Support',
              onTap: () => _showInfo(context, 'Help & Support', 'Help, guidance, and support for SECOND HEAD.'),
            ),
            MenuTile(
              icon: Icons.info_outline,
              label: 'About',
              onTap: () => _showInfo(context, 'About', 'SECOND HEAD\\nVersion 1.0.0\\nBuild #1'),
            ),
            const Spacer(),
            const Divider(color: shBorder),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 2, 10, 10),
              child: Row(
                children: [
                  Expanded(
                    child: MenuTile(
                      icon: Icons.settings_outlined,
                      label: 'Settings',
                      onTap: () => Navigator.pop(context),
                    ),
                  ),
                  Expanded(
                    child: MenuTile(
                      icon: Icons.logout_outlined,
                      label: 'Log Out',
                      onTap: _logout,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _conversationPanel(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: const BoxDecoration(
          border: Border(left: BorderSide(color: shBorder)),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 22, 12, 12),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Conversation',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Close',
                      onPressed: () => setState(() => _conversationExpanded = false),
                      icon: const Icon(Icons.close, size: 20),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: _startNewConversation,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
                    decoration: BoxDecoration(
                      color: shSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: shBorder),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.add, size: 20, color: shCyan),
                        SizedBox(width: 10),
                        Text('New Conversation', style: TextStyle(fontSize: 13, color: shCyan)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                child: Text(
                  'Recent',
                  style: TextStyle(fontSize: 12, color: shMuted, fontWeight: FontWeight.w600),
                ),
              ),
              Expanded(
                child: ValueListenableBuilder<List<RecentConversationEntry>>(
                  valueListenable: recentConversations,
                  builder: (context, conversations, _) => ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 2, 12, 16),
                    itemCount: conversations.length,
                    itemBuilder: (context, i) => GestureDetector(
                      onLongPress: () => _rename(context, i),
                      child: ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                        leading: const Icon(Icons.chat_bubble_outline, size: 17, color: shMuted),
                        title: Text(
                          conversations[i].title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12),
                        ),
                        subtitle: Text(
                          conversations[i].preview,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 9, color: shMuted),
                        ),
                        onTap: () => _openRecent(i),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: shBackground,
      width: _conversationExpanded ? MediaQuery.sizeOf(context).width : 292,
      child: Row(
        children: [
          _primaryPanel(context),
          if (_conversationExpanded) _conversationPanel(context),
        ],
      ),
    );
  }
}

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const ShTopBar(title: 'About'),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 26, 18, 24),
            children: [
              const SizedBox(height: 8),
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 82,
                      height: 82,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [shPurple, shElectric],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: shPurple.withValues(alpha: .22),
                            blurRadius: 28,
                          ),
                        ],
                      ),
                      child: const ShBrandMark(),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'SECOND HEAD',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Your second head, built for continuity.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 10, color: shMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Container(
                decoration: BoxDecoration(
                  color: shSurface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: shBorder),
                ),
                child: const Column(
                  children: [
                    AboutRow('Version', '1.0.0'),
                    Divider(height: 1, color: shBorder),
                    AboutRow('Build', '#1'),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const Center(
                child: Text(
                  'Second Head',
                  style: TextStyle(fontSize: 9, color: shMuted),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class AboutRow extends StatelessWidget {
  const AboutRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    child: Row(
      children: [
        Text(label, style: const TextStyle(fontSize: 11)),
        const Spacer(),
        Text(value, style: const TextStyle(fontSize: 10, color: shMuted)),
      ],
    ),
  );
}

class MenuTile extends StatelessWidget {
  const MenuTile({required this.icon, required this.label, this.onTap, this.danger = false});
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: Icon(icon, size: 19, color: danger ? Colors.redAccent : shMuted),
      title: Text(label, style: TextStyle(fontSize: 12, color: danger ? Colors.redAccent : Colors.white)),
      onTap: onTap ?? () => Navigator.of(context).pop(),
    );
  }
}


