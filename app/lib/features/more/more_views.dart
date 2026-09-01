import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

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
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Text(body, style: const TextStyle(color: shMuted, height: 1.5)),
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
            const Text(
              'About',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 14),
            AboutRow('Version', info.version),
            const Divider(height: 1, color: shBorder),
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
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Savie',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'savie@secondhead.app',
                          style: TextStyle(fontSize: 9, color: shMuted),
                        ),
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
              icon: Icons.settings_outlined,
              label: 'Settings',
              onTap: () => Navigator.pop(context),
            ),
            MenuTile(
              icon: Icons.help_outline,
              label: 'Help & Support',
              onTap: () => _showInfo(
                context,
                'Help & Support',
                'Help, guidance, and support for SECOND HEAD.',
              ),
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
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
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
            Text(
              value,
              style: const TextStyle(fontSize: 10, color: shMuted),
            ),
          ],
        ),
      );
}

class MenuTile extends StatelessWidget {
  const MenuTile({
    this.icon,
    this.customIcon,
    required this.label,
    this.onTap,
    this.danger = false,
  });

  final IconData? icon;
  final Widget? customIcon;
  final String label;
  final VoidCallback? onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18),
        minLeadingWidth: 34,
        horizontalTitleGap: 12,
        leading: IconTheme.merge(
          data: const IconThemeData(size: 28, color: Colors.white),
          child: customIcon == null
              ? Icon(
                icon,
                size: 28,
                color: danger ? Colors.redAccent : Colors.white,
              )
              : Transform.scale(scale: 1.12, child: customIcon),
        ),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: danger ? Colors.redAccent : Colors.white,
          ),
        ),
        onTap: onTap ?? () => Navigator.of(context).pop(),
      ),
    );
  }
}
