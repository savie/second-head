import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../auth/auth_screens.dart';
import '../conversation/conversation_view.dart';
import '../../core/navigation/sh_navigation_shell.dart';
import '../../core/state/sh_profile_state.dart';
import '../../core/theme/sh_theme.dart';
import 'help_support_view.dart';
import 'more_widgets.dart';

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
    const entry = RecentConversationEntry('New Conversation', 'New conversation');
    recentConversations.value = [
      entry,
      ...recentConversations.value.where((item) => item.title != entry.title),
    ];
    conversationTitle.value = entry.title;
    conversationRevision.value++;
    _closeDrawer();
    widget.onSelectPage(0);
  }

  void _openRecent(int index) {
    final conversations = recentConversations.value;
    if (index < 0 || index >= conversations.length) return;
    conversationTitle.value = conversations[index].title;
    _closeDrawer();
    widget.onSelectPage(0);
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
            const Text(
              'Rename conversation',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            TextField(controller: controller, autofocus: true),
            const SizedBox(height: 14),
            Row(
              children: [
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
                        list[index] =
                            RecentConversationEntry(name, item.preview);
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
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAbout(BuildContext context) async {
    final info = await PackageInfo.fromPlatform();
    if (!context.mounted) return;

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
            const Center(
              child: Text(
                'About',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 22),
            AboutRow('Version', info.version),
            const SizedBox(height: 8),
            AboutRow('Build', '#' + info.buildNumber),
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

  Widget _conversationEntries() {
    return ValueListenableBuilder<List<RecentConversationEntry>>(
      valueListenable: recentConversations,
      builder: (context, conversations, _) => Padding(
        padding: const EdgeInsets.only(left: 20, right: 10, bottom: 6),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 38, bottom: 4),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: _startNewConversation,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: shSurface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: shBorder),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.add, size: 18, color: shCyan),
                      SizedBox(width: 9),
                      Text(
                        'New Conversation',
                        style: TextStyle(fontSize: 11, color: shCyan),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            for (var i = 0; i < conversations.length; i++)
              GestureDetector(
                onLongPress: () => _rename(context, i),
                child: ListTile(
                  dense: true,
                  visualDensity: const VisualDensity(vertical: -2),
                  contentPadding: const EdgeInsets.only(left: 36, right: 4),
                  leading: const Icon(
                    Icons.chat_bubble_outline,
                    size: 16,
                    color: shMuted,
                  ),
                  title: Text(
                    conversations[i].title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11),
                  ),
                  onTap: () => _openRecent(i),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _primaryPanel(BuildContext context) {
    return SizedBox(
      width: 292,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  const ShProfileMark(size: 52),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ValueListenableBuilder<String>(
                      valueListenable: profileName,
                      builder: (context, name, _) => ValueListenableBuilder<String>(
                        valueListenable: profileEmail,
                        builder: (context, email, _) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              email,
                              style: const TextStyle(fontSize: 9, color: shMuted),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: shBorder),
            MenuTile(
              icon: Icons.chat_bubble_outline,
              label: 'Conversation',
              onTap: () => setState(
                () => _conversationExpanded = !_conversationExpanded,
              ),
            ),
            if (_conversationExpanded) _conversationEntries(),
            MenuTile(
              customIcon: const ShSectionNavIcon.journey(),
              label: 'Journey',
              onTap: () => _openPage(1),
            ),
            MenuTile(
              customIcon: const ShSectionNavIcon.lifecycle(),
              label: 'Lifecycle',
              onTap: () => _openPage(2),
            ),
            MenuTile(
              icon: Icons.person_outline,
              label: 'Profile',
              onTap: () => _openPage(3),
            ),
            MenuTile(
              icon: Icons.help_outline,
              label: 'Help & Support',
              onTap: () {
                _closeDrawer();
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const HelpSupportView(),
                  ),
                );
              },
            ),
            MenuTile(
              icon: Icons.info_outline,
              label: 'About',
              onTap: () => _showAbout(context),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: MenuTile(
                  icon: Icons.logout_outlined,
                  label: 'Log Out',
                  onTap: _logout,
                  danger: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: shBackground,
      width: 292,
      child: _primaryPanel(context),
    );
  }
}
