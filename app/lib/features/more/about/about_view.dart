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
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 26),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [shSurface2, shSurface],
                  ),
                  border: Border.all(color: shBorder),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x332563EB),
                      blurRadius: 32,
                      spreadRadius: -10,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 116,
                      height: 116,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [shPurple, shElectric],
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x447C3AED),
                            blurRadius: 28,
                            spreadRadius: -4,
                          ),
                        ],
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: shBackground,
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Image.asset(
                          'assets/brand/unity.png',
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'SECOND HEAD',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 3.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Human × AI Unity',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: shCyan,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'A second head for thinking, continuity,\nand meaningful action.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.55,
                        color: shMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
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
                      icon: Icons.rocket_launch_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Row(
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
              ),
              const SizedBox(height: 10),
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
      padding: const EdgeInsets.fromLTRB(14, 15, 14, 16),
      decoration: BoxDecoration(
        color: shSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: shBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: shPurple),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: shMuted,
              letterSpacing: 1.2,
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
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
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
