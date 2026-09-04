import 'package:flutter/material.dart';
import '../../../core/navigation/sh_navigation_shell.dart';
import '../../../core/theme/sh_theme.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});
  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  bool message = true, activity = true, updates = true, sound = true, vibration = true;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: shBackground,
    body: Column(children: [
      ShTopBar(
        title: 'Notifications',
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      Expanded(child: ListView(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 30),
        children: [
          _NotificationSection(title: 'General', children: [
            _NotificationRow(icon: Icons.chat_bubble_outline, label: 'Message notifications', description: 'Alerts when new messages arrive', value: message, onChanged: (v) => setState(() => message = v)),
            _NotificationRow(icon: Icons.notifications_none_rounded, label: 'Activity notifications', description: 'Updates about activity in SH', value: activity, onChanged: (v) => setState(() => activity = v)),
          ]),
          const SizedBox(height: 16),
          _NotificationSection(title: 'Updates', children: [
            _NotificationRow(icon: Icons.auto_awesome_outlined, label: 'Second Head updates', description: 'Product and system updates', value: updates, onChanged: (v) => setState(() => updates = v)),
          ]),
          const SizedBox(height: 16),
          _NotificationSection(title: 'Notification behavior', children: [
            _NotificationRow(icon: Icons.volume_up_outlined, label: 'Sound', description: 'Play notification sounds', value: sound, onChanged: (v) => setState(() => sound = v)),
            _NotificationRow(icon: Icons.vibration_rounded, label: 'Vibration', description: 'Vibrate for notifications', value: vibration, onChanged: (v) => setState(() => vibration = v)),
          ]),
        ],
      )),
    ]),
  );
}

class _NotificationSection extends StatelessWidget {
  const _NotificationSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(
          title,
          style: const TextStyle(fontSize: 13, color: shMuted, fontWeight: FontWeight.w600),
        ),
      ),
      Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1) const SizedBox(height: 10),
          ],
        ],
      ),
    ],
  );
}

class _NotificationRow extends StatelessWidget {
  const _NotificationRow({
    required this.icon,
    required this.label,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: Container(
      constraints: const BoxConstraints(minHeight: 76),
      padding: const EdgeInsets.fromLTRB(16, 13, 12, 13),
      decoration: BoxDecoration(
        color: shSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: shBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: shSurface2,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: shBorder),
            ),
            child: Icon(icon, size: 21, color: value ? Colors.white : shMuted),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text(description, style: const TextStyle(fontSize: 11.5, color: shMuted)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch.adaptive(value: value, onChanged: onChanged),
        ],
      ),
    ),
  );
}
