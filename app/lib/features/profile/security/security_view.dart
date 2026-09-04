import 'package:flutter/material.dart';
import '../../../core/navigation/sh_navigation_shell.dart';
import '../../../core/theme/sh_theme.dart';
import 'password_view.dart';

class SecurityView extends StatelessWidget {
  const SecurityView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: shBackground,
      body: Column(
        children: [
          ShTopBar(
            title: 'Security',
            leading: IconButton(
              tooltip: 'Back',
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 30),
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 4, bottom: 8),
                  child: Text(
                    'Authentication',
                    style: TextStyle(fontSize: 13, color: shMuted, fontWeight: FontWeight.w600),
                  ),
                ),
                _SecurityRow(
                  icon: Icons.mail_outline_rounded,
                  label: 'Sign-in method',
                  value: 'Email',
                ),
                const SizedBox(height: 10),
                _SecurityRow(
                  icon: Icons.lock_outline_rounded,
                  label: 'Password',
                  value: 'Not configured yet',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const PasswordView()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SecurityRow extends StatelessWidget {
  const _SecurityRow({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 70),
        padding: const EdgeInsets.fromLTRB(16, 12, 14, 12),
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
              child: Icon(icon, size: 21, color: onTap == null ? shMuted : Colors.white),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 3),
                  Text(value, style: const TextStyle(fontSize: 11.5, color: shMuted)),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(Icons.chevron_right_rounded, size: 21, color: shMuted),
          ],
        ),
      ),
    ),
  );
}
