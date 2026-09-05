import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/navigation/sh_navigation_shell.dart';
import '../../../core/theme/sh_theme.dart';

class AboutView extends StatefulWidget {
  const AboutView({super.key});

  @override
  State<AboutView> createState() => _AboutViewState();
}

class _AboutViewState extends State<AboutView> {
  PackageInfo? _info;

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((value) {
      if (mounted) setState(() => _info = value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final info = _info;

    return Column(
      children: [
        const ShTopBar(title: 'About'),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 4, 22, 14),
            child: Column(
              children: [
                const SizedBox(height: 4),
                Container(
                  width: 92,
                  height: 92,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [shPurple, shElectric],
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x442563EB),
                        blurRadius: 22,
                        spreadRadius: -8,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Container(
                      color: shBackground,
                      padding: const EdgeInsets.all(8),
                      child: Image.asset(
                        'assets/brand/unity.png',
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 7),
                const Text(
                  'SECOND HEAD',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.8,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'HUMAN × AI UNITY',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: shCyan,
                    letterSpacing: 1.8,
                  ),
                ),
                const SizedBox(height: 13),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 11,
                  ),
                  decoration: BoxDecoration(
                    color: shSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: shPurple.withValues(alpha: .55),
                    ),
                  ),
                  child: const Text(
                    'A space where humans and AI collaborate to think deeper, work with clarity, and move forward with intention.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      height: 1.35,
                      color: shMuted,
                    ),
                  ),
                ),
                const SizedBox(height: 11),
                Row(
                  children: [
                    Expanded(
                      child: _InfoCard(
                        label: 'VERSION',
                        value: info?.version ?? '—',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _InfoCard(
                        label: 'BUILD',
                        value: info == null ? '—' : '#${info.buildNumber}',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 11),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: shSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: shBorder),
                  ),
                  child: const Column(
                    children: [
                      _AboutRow(
                        icon: Icons.psychology_rounded,
                        title: 'Human Centered',
                        subtitle: 'AI as a partner, not a replacement',
                      ),
                      Divider(height: 1, indent: 60, color: shBorder),
                      _AboutRow(
                        icon: Icons.all_inclusive_rounded,
                        title: 'Unified Experience',
                        subtitle: 'Conversation, Journey, Lifecycle, and more',
                      ),
                      Divider(height: 1, indent: 60, color: shBorder),
                      _AboutRow(
                        icon: Icons.insights_rounded,
                        title: 'Continuous Evolution',
                        subtitle: 'Growing together, one step at a time',
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                const Text(
                  'A Second Head for a more intentional life.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                    color: shMuted,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'SECOND HEAD · DEV',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                    color: shMuted,
                    letterSpacing: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(13, 9, 13, 10),
        decoration: BoxDecoration(
          color: shSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: shBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 7,
                fontWeight: FontWeight.w600,
                color: shMuted,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
}

class _AboutRow extends StatelessWidget {
  const _AboutRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: shPurple.withValues(alpha: .12),
              ),
              child: Icon(icon, size: 17, color: shPurple),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 9, color: shMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}
