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
        ShTopBar(title: 'About'),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 8, 22, 18),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(children: [
                  Container(
                    width: 132,
                    height: 132,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(colors: [shPurple, shElectric]),
                      boxShadow: const [BoxShadow(color: Color(0x442563EB), blurRadius: 28, spreadRadius: -8)],
                    ),
                    child: ClipOval(child: Image.asset('assets/brand/unity.png', fit: BoxFit.cover)),
                  ),
                  const SizedBox(height: 10),
                  const Text('SECOND HEAD', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700, letterSpacing: 3.2)),
                  const SizedBox(height: 4),
                  const Text('HUMAN × AI UNITY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: shCyan, letterSpacing: 2)),
                ]),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  decoration: BoxDecoration(color: shSurface, borderRadius: BorderRadius.circular(18), border: Border.all(color: shPurple.withValues(alpha: .55))),
                  child: const Text('A space where humans and AI collaborate to think deeper, work with clarity, and move forward with intention.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, height: 1.45, color: shMuted)),
                ),
                Row(children: [
                  Expanded(child: _InfoCard(label: 'VERSION', value: info?.version ?? '—')),
                  const SizedBox(width: 10),
                  Expanded(child: _InfoCard(label: 'BUILD', value: info == null ? '—' : '#${info.buildNumber}')),
                ]),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(color: shSurface, borderRadius: BorderRadius.circular(18), border: Border.all(color: shBorder)),
                  child: const Column(children: [
                    _AboutRow(icon: Icons.psychology_rounded, title: 'Human Centered', subtitle: 'AI as a partner, not a replacement'),
                    Divider(height: 1, indent: 64, color: shBorder),
                    _AboutRow(icon: Icons.all_inclusive_rounded, title: 'Unified Experience', subtitle: 'Conversation, Journey, Lifecycle, and more'),
                    Divider(height: 1, indent: 64, color: shBorder),
                    _AboutRow(icon: Icons.insights_rounded, title: 'Continuous Evolution', subtitle: 'Growing together, one step at a time'),
                  ]),
                ),
                const Column(children: [
                  Text('A Second Head for a more intentional life.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: shMuted)),
                  SizedBox(height: 8),
                  Text('SECOND HEAD · DEV', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: shMuted, letterSpacing: 1.4)),
                ]),
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
        padding: const EdgeInsets.fromLTRB(14, 11, 14, 12),
        decoration: BoxDecoration(color: shSurface, borderRadius: BorderRadius.circular(16), border: Border.all(color: shBorder)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w600, color: shMuted, letterSpacing: 1.3)),
          const SizedBox(height: 3),
          Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ]),
      );
}

class _AboutRow extends StatelessWidget {
  const _AboutRow({required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
        child: Row(children: [
          Container(width: 38, height: 38, decoration: BoxDecoration(shape: BoxShape.circle, color: shPurple.withValues(alpha: .12)), child: Icon(icon, size: 19, color: shPurple)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, color: shMuted)),
          ])),
        ]),
      );
}
