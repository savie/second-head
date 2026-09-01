import 'package:flutter/material.dart';

import '../conversation/conversation_view.dart';
import '../../core/theme/sh_theme.dart';
import '../../core/navigation/sh_navigation_shell.dart';
import '../../core/widgets/sh_brand_mark.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({super.key, required this.onSelectPage});

  final ValueChanged<int> onSelectPage;

  void _openPage(BuildContext context, int index) {
    Navigator.of(context).pop();
    onSelectPage(index);
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

  void _showInfo(BuildContext context, String title, String body) { showModalBottomSheet<void>(context: context, backgroundColor: shSurface, showDragHandle: true, builder: (_) => Padding(padding: const EdgeInsets.fromLTRB(20, 8, 20, 28), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)), const SizedBox(height: 12), Text(body, style: const TextStyle(color: shMuted, height: 1.5)), const SizedBox(height: 18), SizedBox(width: double.infinity, child: FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Close')))]))); }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: shBackground,
      width: 292,
      child: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(18),
              child: Row(children: [
                ShBrandMark(),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Savie', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      Text('savie@secondhead.app', style: TextStyle(fontSize: 9, color: shMuted)),
                    ],
                  ),
                ),
              ]),
            ),
            const Divider(color: shBorder),
            MenuTile(
              icon: Icons.chat_bubble_outline,
              label: 'Conversation',
              onTap: () => _openPage(context, 0),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ValueListenableBuilder<List<RecentConversationEntry>>(
                valueListenable: recentConversations,
                builder: (context, conversations, _) => Column(
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _openPage(context, 0),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        child: Row(children: [
                          Icon(Icons.add_rounded, size: 18, color: shCyan),
                          SizedBox(width: 10),
                          Text('New Conversation',
                              style: TextStyle(fontSize: 11, color: shCyan)),
                        ]),
                      ),
                    ),
                    for (var i = 0; i < conversations.length; i++)
                      GestureDetector(
                        onLongPress: () => _rename(context, i),
                        child: ListTile(
                          dense: true,
                          contentPadding: const EdgeInsets.only(left: 30, right: 4),
                          leading: const Icon(Icons.chat_bubble_outline, size: 14, color: shMuted),
                          title: Text(conversations[i].title,
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 10)),
                          subtitle: Text(conversations[i].preview,
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 8, color: shMuted)),
                          onTap: () {
                            conversationTitle.value = conversations[i].title;
                            _openPage(context, 0);
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const Divider(color: shBorder),
            MenuTile(icon: Icons.hexagon_outlined, label: 'Journey', onTap: () => _openPage(context, 1)),
            MenuTile(icon: Icons.event_note_outlined, label: 'Lifecycle', onTap: () => _openPage(context, 2)),
            MenuTile(icon: Icons.person_outline, label: 'Profile', onTap: () => _openPage(context, 3)),
            MenuTile(icon: Icons.help_outline, label: 'Help & Support', onTap: () => _showInfo(context, 'Help & Support', 'Help, guidance, and support for SECOND HEAD.')),
            MenuTile(icon: Icons.info_outline, label: 'About', onTap: () => _showInfo(context, 'About', 'SECOND HEAD\nVersion 1.0.0\nBuild #1')),
            const Spacer(),
            const Divider(color: shBorder),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 2, 10, 10),
              child: Row(children: [
                Expanded(child: MenuTile(icon: Icons.settings_outlined, label: 'Settings', onTap: () => Navigator.pop(context))),
                Expanded(child: MenuTile(icon: Icons.logout_rounded, label: 'Log Out', onTap: () => Navigator.popUntil(context, (route) => route.isFirst))),
              ]),
            ),
          ],
        ),
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


