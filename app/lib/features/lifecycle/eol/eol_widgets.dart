import 'package:flutter/material.dart';

import '../../../core/theme/sh_theme.dart';

class EolShell extends StatelessWidget {
  const EolShell({
    super.key,
    required this.title,
    required this.child,
    this.onBack,
  });

  final String title;
  final Widget child;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: shBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: onBack ?? () => Navigator.of(context).maybePop(),
        ),
        title: Text(title),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
          child: child,
        ),
      ),
    );
  }
}

class EolHero extends StatelessWidget {
  const EolHero({super.key});

  static const accent = Color(0xFFEC4899);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: shBackground,
            border: Border.all(color: accent.withValues(alpha: .42), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: .13),
                blurRadius: 28,
                spreadRadius: 4,
              ),
            ],
          ),
          child: const Icon(Icons.favorite_border_rounded, color: accent, size: 34),
        ),
        const SizedBox(height: 18),
        const Text(
          'End of Life',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w500, height: 1.1),
        ),
        const SizedBox(height: 9),
        const Text(
          'Close your Second Head through a governed lifecycle transition.',
          textAlign: TextAlign.center,
          style: TextStyle(color: shMuted, fontSize: 13, height: 1.45),
        ),
      ],
    );
  }
}

class EolCard extends StatelessWidget {
  const EolCard({super.key, required this.child, this.accent = EolHero.accent});

  final Widget child;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: shSurface.withValues(alpha: .72),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: accent.withValues(alpha: .24)),
      ),
      child: child,
    );
  }
}

class EolActionButton extends StatelessWidget {
  const EolActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.outlined = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18),
          const SizedBox(width: 8),
        ],
        Text(label),
      ],
    );

    return SizedBox(
      width: double.infinity,
      child: outlined
          ? OutlinedButton(onPressed: onPressed, child: child)
          : FilledButton(onPressed: onPressed, child: child),
    );
  }
}

class EolImpactRow extends StatelessWidget {
  const EolImpactRow({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 13),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: shBackground.withValues(alpha: .78),
                border: Border.all(color: shBorder),
              ),
              child: Icon(icon, size: 20, color: shMuted),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 3),
                  Text(subtitle, style: const TextStyle(fontSize: 11, color: shMuted, height: 1.35)),
                ],
              ),
            ),
            if (trailing != null)
              Text(trailing!, style: const TextStyle(fontSize: 12, color: shMuted)),
            if (onTap != null) const Icon(Icons.chevron_right_rounded, color: shMuted),
          ],
        ),
      ),
    );
  }
}
