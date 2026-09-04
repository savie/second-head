import 'package:flutter/material.dart';
import '../../../core/navigation/sh_navigation_shell.dart';
import '../../../core/theme/sh_theme.dart';

class DPSubPage extends StatelessWidget {
  const DPSubPage({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: shBackground,
    body: Column(
      children: [
        ShTopBar(
          title: title,
          leading: IconButton(
            tooltip: 'Back',
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 32),
            children: children,
          ),
        ),
      ],
    ),
  );
}

class DPInfoCard extends StatelessWidget {
  const DPInfoCard({
    required this.icon,
    required this.title,
    required this.description,
    this.destructive = false,
  });

  final IconData icon;
  final String title;
  final String description;
  final bool destructive;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(17),
    decoration: BoxDecoration(
      gradient: const LinearGradient(colors: [shSurface2, shSurface]),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: shBorder),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: shSurface2,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: shBorder),
          ),
          child: Icon(icon, size: 22, color: destructive ? Colors.redAccent : shCyan),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: destructive ? Colors.redAccent : Colors.white)),
              const SizedBox(height: 5),
              Text(description, style: const TextStyle(fontSize: 11.5, color: shMuted, height: 1.45)),
            ],
          ),
        ),
      ],
    ),
  );
}

class DPOptionCard extends StatelessWidget {
  const DPOptionCard({required this.icon, required this.title, required this.subtitle});

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(15, 14, 14, 14),
    decoration: BoxDecoration(
      color: shSurface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: shBorder),
    ),
    child: Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: shSurface2,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: shBorder),
          ),
          child: Icon(icon, size: 20, color: shMuted),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(height: 3),
              Text(subtitle, style: const TextStyle(fontSize: 11.5, color: shMuted)),
            ],
          ),
        ),
      ],
    ),
  );
}

class DPActionCard extends StatelessWidget {
  const DPActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(15, 14, 14, 14),
        decoration: BoxDecoration(
          color: shSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: destructive ? Colors.redAccent.withValues(alpha: .45) : shBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: shSurface2,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: shBorder),
              ),
              child: Icon(icon, size: 20, color: destructive ? Colors.redAccent : shCyan),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: destructive ? Colors.redAccent : Colors.white)),
                  const SizedBox(height: 3),
                  Text(subtitle, style: const TextStyle(fontSize: 11.5, color: shMuted)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, size: 22, color: shMuted),
          ],
        ),
      ),
    ),
  );
}

class DPSectionLabel extends StatelessWidget {
  const DPSectionLabel(this.text);
  final String text;
  @override Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 4),
    child: Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.3, color: shMuted)),
  );
}

class DPCard extends StatelessWidget {
  const DPCard({required this.icon, required this.title, required this.subtitle, required this.onTap, this.destructive = false});
  final IconData icon;
  final String title, subtitle;
  final VoidCallback onTap;
  final bool destructive;
  @override Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 15, 14, 15),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [shSurface2, shSurface]),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: shBorder),
        ),
        child: Row(children: [
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(
              color: destructive ? shSurface : shSurface2,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: shBorder),
            ),
            child: Icon(icon, size: 22, color: destructive ? Colors.redAccent : Colors.white),
          ),
          const SizedBox(width: 13),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: destructive ? Colors.redAccent : Colors.white)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(fontSize: 11.5, color: shMuted)),
          ])),
          const Icon(Icons.chevron_right_rounded, size: 22, color: shMuted),
        ]),
      ),
    ),
  );
}
