import 'package:flutter/material.dart';

import '../../core/theme/sh_theme.dart';

class AboutRow extends StatelessWidget {
  const AboutRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                color: shMuted,
              ),
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
