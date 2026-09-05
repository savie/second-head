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
    _load();
  }

  Future<void> _load() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) setState(() => _info = info);
  }

  @override
  Widget build(BuildContext context) {
    final info = _info;

    return Column(
      children: [
        const ShTopBar(title: 'About'),
        Expanded(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            children: [
              const SizedBox(height: 4),
              const Center(
                child: SizedBox(
                  width: 250,
                  height: 250,
                  child: Image.asset(
                    'assets/brand/unity.png',
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'SECOND HEAD',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 4.0,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'HUMAN × AI UNITY',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: shCyan,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 22),
              _AboutStatement(
                child: const Text(
                  'Second Head adalah ruang kolaborasi antara manusia dan AI untuk berpikir lebih dalam, berproses lebih jernih, dan melangkah lebih jauh.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.55,
                    color: shMuted,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _InfoCard(
                      label: 'VERSION',
                      value: info?.version ?? '—',
                      icon: Icons.auto_awesome_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _InfoCard(
                      label: 'BUILD',
                      value: info == null ? '—' : '#${info.buildNumber}',
                      icon: Icons.tag_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const _AboutPrinciples(),
              const SizedBox(height: 14),
              const _AboutQuote(),
              const SizedBox(height: 22),
              const _StatusLine(),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  '© 2026 second head',
                  style: TextStyle(fontSize: 11, color: shMuted),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AboutStatement extends StatelessWidget {
  const _AboutStatement({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [shSurface2, shSurface],
        ),
        border: Border.all(color: shPurple.withValues(alpha: 0.65)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x332563EB),
            blurRadius: 28,
            spreadRadius: -10,
          ),
        ],
      ),
      child: child,
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 15),
      decoration: BoxDecoration(
        color: shSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: shBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: shPurple),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: shMuted,
              letterSpacing: 1.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutPrinciples extends StatelessWidget {
  const _AboutPrinciples();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: shSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: shBorder),
      ),
      child: const Column(
        children: [
          _PrincipleRow(
            icon: Icons.psychology_rounded,
            title: 'Human Centered',
            subtitle: 'AI sebagai partner, bukan pengganti',
            iconColor: shPurple,
          ),
          _PrincipleDivider(),
          _PrincipleRow(
            icon: Icons.all_inclusive_rounded,
            title: 'Unified Experience',
            subtitle: 'Chat, Journey, Lifecycle, dan lebih banyak',
            iconColor: shElectric,
          ),
          _PrincipleDivider(),
          _PrincipleRow(
            icon: Icons.insights_rounded,
            title: 'Continuous Evolution',
            subtitle: 'Bersama berkembang, langkah demi langkah',
            iconColor: shCyan,
          ),
        ],
      ),
    );
  }
}

class _PrincipleRow extends StatelessWidget {
  const _PrincipleRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 13, 12, 13),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: iconColor.withValues(alpha: 0.12),
            ),
            child: Icon(icon, size: 21, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: shMuted,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, size: 21, color: shMuted),
        ],
      ),
    );
  }
}

class _PrincipleDivider extends StatelessWidget {
  const _PrincipleDivider();

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.only(left: 70),
        child: Divider(height: 1, color: shBorder),
      );
}

class _AboutQuote extends StatelessWidget {
  const _AboutQuote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 17),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [shSurface2, shSurface],
        ),
        border: Border.all(color: shPurple.withValues(alpha: 0.55)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '“',
            style: TextStyle(
              fontSize: 42,
              height: 0.75,
              color: shPurple,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'A Second Head\nfor a more intentional life.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    fontStyle: FontStyle.italic,
                    color: shMuted,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  '— SECOND HEAD',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.4,
                    color: shPurple,
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

class _StatusLine extends StatelessWidget {
  const _StatusLine();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _StatusDot(),
        SizedBox(width: 8),
        Text(
          'SECOND HEAD · DEV',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: shMuted,
            letterSpacing: 1.4,
          ),
        ),
      ],
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      height: 7,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: shCyan,
        boxShadow: [
          BoxShadow(color: Color(0x5522D3EE), blurRadius: 8),
        ],
      ),
    );
  }
}
